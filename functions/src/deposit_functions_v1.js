/* eslint-disable camelcase */
const functions = require("firebase-functions");
const admin = require("firebase-admin");
// const { v4: uuidv4 } = require('uuid');
// const jwt = require("jsonwebtoken");
const express = require('express');
const needle = require('needle');
const axios = require("axios");
const db = admin.firestore();
const app = express();

// ============ V1 Client App Deposit functions
// please note this only exists because user TJfxazHoJPRoeqG3Ti4QqRnWYW32 refuses to update their app
// and still uses these functions. Newer users from v1.00.36 all use V2 deposit functions in client_app_deposit_functions.js

module.exports = function (e) {
    e.initiateDeposit = functions.firestore
        .document("Users/{UserID}/Deposits/{DepositID}")
        .onCreate(async (snap, context) => {
            const depoData = snap.data();
            // const sparcoKeyDoc = await db.collection("Admin").doc("Legal").collection("Sparco").doc("Keys").get();
            const userDoc = await db.collection("Users").doc(depoData.UserID).get();

            const initiateDeposit = async () => {
                await admin.messaging().sendToDevice(
                    userDoc.get("NotificationToken"), {
                    notification: {
                        title: "Deposits Currently Offline",
                        body: 'Deposits are currently offline. You will be notified when they are back online.',
                        icon: "@drawable/ic_stat_jayben_logo_1_044317_copy_3",
                        clickAction: "FLUTTER_NOTIFICATION_CLICK",
                    },
                    data: {
                        UserID: "",
                    },
                });
                // Deposits Initiated
                // A USSD request will appear shortly and you will be required to enter your Mobile Money PIN to approve the deposit.
                // send notification

                // const data = await axios.post(sparcoKeyDoc.get("DepositRequestUrl"),
                //     {
                //         payload: jwt.sign(
                //             JSON.stringify(
                //                 {
                //                     "amount": depoData.Amount,
                //                     "currency": depoData.Currency,
                //                     "customerEmail": depoData.Email,
                //                     "customerFirstName": depoData.FirstName,
                //                     "customerLastName": depoData.LastName,
                //                     "customerPhone": depoData.PhoneNumber,
                //                     "merchantPublicKey": sparcoKeyDoc.get("Public_Key"),
                //                     "transactionName": depoData.DepositID,
                //                     "transactionReference": uuidv4(),
                //                     "wallet": depoData.PhoneNumber,
                //                     "chargeMe": sparcoKeyDoc.get("ChargeCustomerDepositFee"),
                //                 },
                //             ),
                //             sparcoKeyDoc.get("Secret_Key"),
                //         ),
                //     });

                // await db.collection("Users").doc(depoData.UserID).collection("Deposits").doc(depoData.DepositID).update({
                //     Reference: data.data.reference,
                //     RequestMessage: data.data.message,
                //     MerchantReference: data.data.transactionReference,
                // });
                // uploads the merchant reference & reference
            };

            try {
                await initiateDeposit();
            } catch (error) {
                const smsKeys = await db.collection("Admin").doc("Legal").collection("APIs").doc("PaymentAPI").get();
                // gets sms doc containing keys

                await admin.messaging().sendToDevice(
                    userDoc.get("NotificationToken"), {
                    notification: {
                        title: "Deposit Error Occurred",
                        body: 'An error occurred during your recent deposit request. Please try again later. If problem persists, contact support at ' + smsKeys.get("SupportLine"),
                        icon: "@drawable/ic_stat_jayben_logo_1_044317_copy_3",
                        clickAction: "FLUTTER_NOTIFICATION_CLICK",
                    },
                    data: {
                        UserID: "",
                    },
                });
                // send notification

                await db.collection("Deposit Errors").doc(depoData.DepositID).set({
                    DepositStatus: "Failed",
                    UserID: depoData.UserID,
                    DepositID: depoData.DepositID,
                    ErrorMessage: error,
                    Stage: "Initiate deposit stage",
                    AttednedTo: false,
                });
                // records an error

                await needle(
                    'post',
                    'https://www.smszambia.com/smsservice/jsonapi',
                    JSON.stringify(
                        {
                            "auth": {
                                "username": "sm7-jayben",
                                "password": "J@yEnt",
                                "sender_id": "JaybenError",
                            }, "messages": [
                                {
                                    "phone": `${smsKeys.get("TechSupportLine").replace("+", "")}`,
                                    "message": `A deposit error was detected at the Initiate deposit stage boss`,
                                },
                            ],
                        },
                    ), { json: true });
                // sends sms to support number
            }

            return "";
        });

    app.post('/getDepositStatus', async (req, res) => {
        const body = req.body;

        const userDoc = await db.collection("Users").doc(body.UserID).get();

        const sparcoKeyDoc = await db.collection("Admin").doc("Legal").collection("Sparco").doc("Keys").get();

        const depositDoc = await db.collection("Users").doc(body.UserID).collection("Deposits").doc(body.DepositID).get();

        // sends a referral commission to the user's referrer 
        const payReferrerCommission = async () => {
            // gets the public admin document that stores the app settings
            const adminDoc = await db.collection("Admin").doc("Legal").get();

            if (adminDoc.get("PayReferrers")) {
                // gets the referrer's user document
                const referrersDoc = await db.collection("Users").where("Username_searchable", "==", userDoc.get("ReferralCode").toLowerCase()).get();

                // calculates the referral commission amount
                const commissionAmount = depositDoc.get("Amount") * (adminDoc.get("ReferrerCommissionPercentage") / 100);

                // if the referrer exists and if both the referrer and depositer have the same currency
                if (referrersDoc.docs.length != 0 && userDoc.get("Currency") === referrersDoc.docs[0].get("Currency")) {
                    // 1). adds the commission to the referrer's wallet balance
                    // 2). sends the referrer a commission notification
                    // 3). records the payment in the admin metrics document
                    await Promise.all([
                        db.collection("Users").doc(referrersDoc.docs[0].id).update({
                            Balance: admin.firestore.FieldValue.increment(commissionAmount),
                        }),
                        admin.messaging().sendToDevice(
                            referrersDoc.docs[0].get("NotificationToken"), {
                            notification: {
                                body: `You have been paid! 😏💰 ${userDoc.get("Currency")} ${commissionAmount} has been deposited into your wallet. Share this on whatsapp, refer more friends & keep up the good work 💪`,
                                icon: "@drawable/ic_stat_jayben_logo_1_044317_copy_3",
                                clickAction: "FLUTTER_NOTIFICATION_CLICK",
                                title: "Referral Commission Paid 💰",
                            },
                            data: {
                                UserID: "",
                            },
                        }),
                        db.collection("Admin").doc("Metrics").update({
                            TotalReferralCommissionsPaidInKwacha: admin.firestore.FieldValue.increment(commissionAmount),
                            TotalNumberOfReferralCommissionsPaid: admin.firestore.FieldValue.increment(1),
                        }),
                    ]);

                    // gets the public supabase keys document
                    const supabase_keys = await db.collection("Admin").doc("Legal").collection("Supabase").doc("keys").get();

                    // creates a new row that stores the referral commission's details
                    await axios({
                        "method": "post",
                        url: "https://srfjzsqimfuomlmjixsu.supabase.co/functions/v1/general_functions",
                        headers: {
                            "Authorization": `Bearer ${supabase_keys.get("anon_key")}`,
                            "Content-Type": "application/json",
                        },
                        data: JSON.stringify({
                            "table_name": "referral_commission_transactions",
                            "request_type": "create_update_row_record",
                            "operation_type": "create_row",
                            "data": {
                                "comment": "",
                                "is_public": false,
                                "attended_to": false,
                                "status": "Completed",
                                "currency_symbol": "K",
                                "amount": commissionAmount,
                                "sent_received": "Received",
                                "transaction_type": "Deposit",
                                "description": "Paid To Wallet",
                                "method": "Referral Commission",
                                "user_id": referrersDoc.docs[0].id,
                                "transaction_id": depositDoc.get("DepositID"),
                                "country": referrersDoc.docs[0].get("Country"),
                                "currency": referrersDoc.docs[0].get("Currency"),
                                "user_is_verified": referrersDoc.docs[0].get("isVerified"),
                                "wallet_balance_details": {
                                    "wallet_balances_difference": commissionAmount,
                                    "wallet_balance_before_transaction": referrersDoc.docs[0].get("Balance"),
                                    "wallet_balance_after_transaction": referrersDoc.docs[0].get("Balance") + commissionAmount,
                                },
                                "full_names": `${referrersDoc.docs[0].get("FirstName")} ${referrersDoc.docs[0].get("LastName")}`,
                            },
                        }),
                    }).then(async function (response) {
                        console.log("The supabase API was called successfully");
                    }).catch(async function (error) {
                        console.log(error);
                        console.log(`There was an error: trying to create a new referral_commission_transactions row in supabase`);
                    });
                }
            }
        };

        const checkForTransaction = async () => {
            axios({
                method: 'get',
                url: sparcoKeyDoc.get("QueryTransactionURL") +
                    '?reference=' + depositDoc.get("Reference") +
                    '&merchantReference=' + depositDoc.get("MerchantReference"),
                headers: {
                    "pubKey": sparcoKeyDoc.get("Public_Key"),
                },
            }).then(async function (response) {
                if (response.data.status == "TXN_AUTH_SUCCESSFUL" &&
                    depositDoc.get("DepositStatus") == "Pending") {
                    const tranxID = Math.random().toString(36).substr(2, 10);
                    await db.collection("Users").doc(body.UserID).collection("Deposits").doc(body.DepositID).update({
                        DepositStatus: "Successful",
                        ErrorMessage: "",
                    });
                    // uploads the merchant reference & reference

                    await db.collection("Users").doc(body.UserID).update({
                        Balance: admin.firestore.FieldValue.increment(depositDoc.get("Amount")),
                    });
                    // increases user's balance

                    // records the deposit to the admin metrics
                    await db.collection("Admin").doc("Metrics").update({
                        dailyDepositsTotalProcessed: admin.firestore.FieldValue.increment(depositDoc.get("Amount")),
                        totalUserBalances: admin.firestore.FieldValue.increment(depositDoc.get("Amount")),
                        dailyNumberOfDepositsMade: admin.firestore.FieldValue.increment(1),
                    });

                    await db.collection("Transactions").doc(tranxID).set({
                        FullNames: `${depositDoc.get("FirstName")} ${depositDoc.get("LastName")}`,
                        DateCreated: admin.firestore.FieldValue.serverTimestamp(),
                        Amount: depositDoc.get("Amount"),
                        Status: "Completed",
                        UserID: body.UserID,
                        AttendedTo: false,
                        IsPublic: false,
                        Comment: "",
                        TransactionID: tranxID,
                        SentReceived: "Received",
                        TransactionType: "Deposit",
                        TransactionFeeDetails: null,
                        Currency: depositDoc.get("Currency"),
                        Method: depositDoc.get("DepositMethod"),
                        PhoneNumber: `+${depositDoc.get("PhoneNumber")}`,
                        Details: {
                            Provider: "Sparco",
                            DepositMethod: "Mobile Money",
                            ChargeMe: sparcoKeyDoc.get("ChargeCustomerDepositFee"),
                        },
                        WalletBalanceDetails: {
                            WalletBalanceBeforeTransaction: userDoc.get("Balance"),
                            WalletBalanceAfterTransaction: userDoc.get("Balance") + body.Amount,
                        },
                    });
                    //   records the transaction

                    await admin.messaging().sendToDevice(
                        userDoc.get("NotificationToken"), {
                        notification: {
                            title: "Deposit Successful 💰",
                            body: 'You have deposited ' + userDoc.get("Currency") + ' ' + depositDoc.get("Amount") + ' to your Wallet via ' + depositDoc.get("DepositMethod"),
                            icon: "@drawable/ic_stat_jayben_logo_1_044317_copy_3",
                            clickAction: "FLUTTER_NOTIFICATION_CLICK",
                        },
                        data: {
                            UserID: "",
                        },
                    });
                    // send notification

                    // gets benson & justin's user document
                    const justins_user_document = await db.collection("Users").doc("ONQUtMhhrRQS82CJBYzppRcIeqr2").get();
                    const bensons_user_document = await db.collection("Users").doc("8nYSYEXEEmYb8KYa61wRZrHseGv2").get();

                    // sends Justin a new deposit alert
                    admin.messaging().sendToDevice(
                        [justins_user_document.get("NotificationToken"), bensons_user_document.get("NotificationToken")], {
                        notification: {
                            title: "New User Deposit Made 💰",
                            body: `Jayben has received a new user deposit of ${userDoc.get("Currency")} ${body.Amount}`,
                            icon: "@drawable/ic_stat_jayben_logo_1_044317_copy_3",
                            clickAction: "FLUTTER_NOTIFICATION_CLICK",
                        },
                        data: {
                            UserID: "",
                        },
                    });

                    // pays the referrer a referral commission
                    await payReferrerCommission();

                    res.status(201).send("Success");
                } else if (response.data.status == "TXN_AUTH_UNSUCCESSFUL" &&
                    depositDoc.get("DepositStatus") == "Pending") {
                    const userDoc = await db.collection("Users").doc(body.UserID).get();

                    await db.collection("Users").doc(body.UserID).collection("Deposits").doc(body.DepositID).update({
                        DepositStatus: "Failed",
                        ErrorMessage: 'Failed',
                    });
                    // uploads the merchant reference & reference

                    await admin.messaging().sendToDevice(
                        userDoc.get("NotificationToken"), {
                        notification: {
                            title: "Deposit Failed",
                            body: 'Your recent deposit attempt failed. Please try again.',
                            icon: "@drawable/ic_stat_jayben_logo_1_044317_copy_3",
                            clickAction: "FLUTTER_NOTIFICATION_CLICK",
                        },
                        data: {
                            UserID: "",
                        },
                    });
                    // send notification

                    res.status(201).send("Failed");
                }
            }).catch(async function (error) {
                const smsKeys = await db.collection("Admin").doc("Legal").collection("APIs").doc("PaymentAPI").get();
                // gets sms doc containing keys

                const userDoc = await db.collection("Users").doc(body.UserID).get();
                // gets user's doc

                await admin.messaging().sendToDevice(
                    userDoc.get("NotificationToken"), {
                    notification: {
                        title: "Deposit Error Occurred",
                        body: 'An error occurred during your recent deposit request. Please try again later. If problem persists, contact support at ' + smsKeys.get("SupportLine"),
                        icon: "@drawable/ic_stat_jayben_logo_1_044317_copy_3",
                        clickAction: "FLUTTER_NOTIFICATION_CLICK",
                    },
                    data: {
                        UserID: "",
                    },
                });
                // send notification

                await db.collection("Deposit Errors").doc(body.DepositID).set({
                    DepositStatus: "Failed",
                    UserID: body.UserID,
                    DepositID: body.DepositID,
                    ErrorMessage: 'Failed: ' + error.message,
                    Error: error,
                    Stage: "Check deposit status stage",
                    AttednedTo: false,
                });
                // records an error

                await needle(
                    'post',
                    'https://www.smszambia.com/smsservice/jsonapi',
                    JSON.stringify(
                        {
                            "auth": {
                                "username": "sm7-jayben",
                                "password": "J@yEnt",
                                "sender_id": "JaybenError",
                            }, "messages": [
                                {
                                    "phone": `${smsKeys.get("TechSupportLine").replace("+", "")}`,
                                    "message": ` deposit error was detected at the Initiate deposit stage boss`,
                                },
                            ],
                        },
                    ), { json: true });
                // sends sms to tech support

                res.status(201).send("Failed");
            });
        };

        await checkForTransaction();
    });

    e.onDepositCheck = functions.https.onRequest(app);
};
