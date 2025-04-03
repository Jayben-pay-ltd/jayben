/* eslint-disable camelcase */
const functions = require("firebase-functions");
const cors = require("cors")({ origin: true });
const admin = require("firebase-admin");
const { v4: uuidv4 } = require('uuid');
const jwt = require("jsonwebtoken");
const express = require('express');
const crypto = require('crypto');
const needle = require("needle");
const axios = require("axios");
const db = admin.firestore();
const uuid = require("uuid");
const app = express();
app.use(express.json());
app.use(express.urlencoded({ extended: true }));
app.use(cors);

module.exports = function (e) {
    // ============ V2 Client App Deposit Functions

    /*
        The production V2 url being used in apps is
        https://us-central1-jayben-de41c.cloudfunctions.net/credit/api/v2/client/deposit/wallet/
    */


    // for mobile money in zambia that uses sparco
    app.post('/api/v2/client/deposit/wallet/', async (req, res) => {
        const body = req.body;
        // let stopLoop = false;

        console.log("00000000000000");

        /*
            This is how the body looks
            {
                "UserID": "string",
                "Amount": "double 2dp",
                "PhoneNumber": "string - country code not included"
            }
        */

        const depositID = uuidv4();
        const userDoc = await db.collection("Users").doc(body.UserID).get();
        // const sparcoKeyDoc = await db.collection("Admin").doc("Legal").collection("Sparco").doc("Keys").get();

        console.log("111111111111111");

        // 1). Sends user a USSD Push notification to their phone number
        // 2). Creates a deposit document to record the deposit progress
        // 3). Runs a for loop to check and confirm the deposit for 180 seconds
        const initiatePayment = async () => {
            console.log("AAAAAA");
            // sends ussd push notification to the user

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
            // Deposit Initiated
            // 'A USSD request will appear shortly and you will be required to enter your Mobile Money PIN to approve the deposit.',
            // send notification

            // const data = await axios.post(sparcoKeyDoc.get("DepositRequestUrl"),
            //     {
            //         payload: jwt.sign(
            //             JSON.stringify(
            //                 {
            //                     "webhookUrl": "https://us-central1-jayben-de41c.cloudfunctions.net/credit/v2/deposit/checkout/sparco/sparco_webhook",
            //                     "customerFirstName": `${userDoc.get("FirstName")} ${userDoc.get("LastName")}`,
            //                     "customerLastName": `${userDoc.get("Username_searchable")}`,
            //                     "chargeMe": sparcoKeyDoc.get("ChargeCustomerDepositFee"),
            //                     "merchantPublicKey": sparcoKeyDoc.get("Public_Key"),
            //                     "customerPhone": userDoc.get("PhoneNumber"),
            //                     "customerEmail": userDoc.get("Email"),
            //                     "currency": userDoc.get("Currency"),
            //                     "transactionReference": depositID,
            //                     "transactionName": body.UserID,
            //                     "wallet": body.PhoneNumber,
            //                     "amount": body.Amount,
            //                 },
            //             ),
            //             sparcoKeyDoc.get("Secret_Key"),
            //         ),
            //     });

            // console.log("BBBBBB");

            // // creates the deposit record to track the deposit inside collection DepositsViaMobileMoney
            // await db.collection("DepositsViaMobileMoney").doc(depositID).set({
            //     ErrorMessage: "",
            //     UserID: body.UserID,
            //     Amount: body.Amount,
            //     DepositID: depositID,
            //     DepositStatus: "Pending",
            //     TransactionType: "Deposit",
            //     Email: userDoc.get("Email"),
            //     PhoneNumber: body.PhoneNumber,
            //     DepositMethod: "Mobile Money",
            //     Reference: data.data.reference,
            //     Country: userDoc.get("Country"),
            //     Currency: userDoc.get("Currency"),
            //     LastName: userDoc.get("LastName"),
            //     RequestMessage: data.data.message,
            //     FirstName: userDoc.get("FirstName"),
            //     MyNotifToken: userDoc.get("NotificationToken"),
            //     MerchantReference: data.data.transactionReference,
            //     DateCreated: admin.firestore.FieldValue.serverTimestamp(),
            // });

            console.log("CCCCCCC");
        };

        try {
            await initiatePayment();
        } catch (e) {
            console.log(e);

            const supportDoc = await db.collection("Admin").doc("Legal").collection("APIs").doc("PaymentAPI").get();

            // 1). Creates a record of the deposit error
            await db.collection("Deposit Errors").doc(depositID).set({
                AttednedTo: false,
                Error: e.toString(),
                UserID: body.UserID,
                DepositID: depositID,
                DepositStatus: "Failed",
                ErrorMessage: "Failed: " + e,
                DateCreated: admin.firestore.FieldValue.serverTimestamp(),
                Stage: "Confirm deposit status stage: To be specific, this is a more general error, happened maybe not during deposit confirmation but somewhere throughout the process. Check logs for more details",
            });

            // Sends tech support an sms notifying them about the error
            try {
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
                                    "phone": `${supportDoc.get("TechSupportLine").replace("+", "")}`,
                                    "message": `An error attempting a deposit ${e.toString()}`,
                                },
                            ],
                        },
                    ), { json: true });
            } catch (e) {
                console.log(e);
            }

            res.status(400).send("Failed");
        }

        res.status(200).send("ending server now...");
    });

    // this is the new v2 API that uses the SamPay Payment Collections API
    app.post('/api/v2/client/deposit/wallet/sampay', async (req, res) => {
        const body = req.body;
        // let stopLoop = false;

        console.log("00000000000000");

        /*
            This is how the body looks
            {
                "UserID": "string",
                "Amount": "double 2dp",
                "PhoneNumber": "string - country code not included"
            }
        */

        const depositID = uuidv4();
        const userDoc = await db.collection("Users").doc(body.UserID).get();
        const userID = body.UserID;

        // calculates the exact amount minus the 2.9% fee
        const amount_exact = body.Amount - (body.Amount * 2.9 / 100);

        // calculates the rounded amount
        let amount = 0.0;

        if (amount_exact < 1) {
            amount = Math.round(amount_exact);
        } else {
            amount = amount_exact;
        }

        console.log(`The amount is ${amount}`);

        let service = "";

        console.log("111111111111111");

        // sends a referral commission to the user's referrer 
        const payReferrerCommission = async () => {
            // gets the public admin document that stores the app settings
            const adminDoc = await db.collection("Admin").doc("Legal").get();

            if (adminDoc.get("PayReferrers")) {
                // gets the referrer's user document
                const referrersDoc = await db.collection("Users").where("Username_searchable", "==", userDoc.get("ReferralCode").toLowerCase()).get();

                // calculates the referral commission amount
                const amount_calculated = amount * (adminDoc.get("ReferrerCommissionPercentage") / 100);

                const commissionAmount = amount_calculated.toFixed(2);

                const commission_float = parseFloat(commissionAmount.toString());

                // if the referrer exists and if both the referrer and depositer have the same currency
                if (referrersDoc.docs.length != 0 && userDoc.get("Currency") === referrersDoc.docs[0].get("Currency")) {
                    // 1). adds the commission to the referrer's wallet balance
                    // 2). sends the referrer a commission notification
                    // 3). records the payment in the admin metrics document
                    await Promise.all([
                        db.collection("Users").doc(referrersDoc.docs[0].id).update({
                            Balance: admin.firestore.FieldValue.increment(commission_float),
                        }),
                        admin.messaging().sendToDevice(
                            referrersDoc.docs[0].get("NotificationToken"), {
                            notification: {
                                body: `You have been paid! 😏💰 ${userDoc.get("Currency")} ${commission_float} has been deposited into your wallet. Share this on whatsapp, refer more friends & keep up the good work 💪`,
                                icon: "@drawable/ic_stat_jayben_logo_1_044317_copy_3",
                                clickAction: "FLUTTER_NOTIFICATION_CLICK",
                                title: "Referral Commission Paid 💰",
                            },
                            data: {
                                UserID: "",
                            },
                        }),
                        db.collection("Admin").doc("Metrics").update({
                            TotalReferralCommissionsPaidInKwacha: admin.firestore.FieldValue.increment(commission_float),
                            TotalNumberOfReferralCommissionsPaid: admin.firestore.FieldValue.increment(1),
                        }),
                    ]);

                    // gets the public supabase keys document
                    const supabase_keys = await db.collection("Admin").doc("Legal").collection("Supabase").doc("keys").get();

                    const commission_id = uuidv4();

                    // creates a new row that stores the referral commission's details
                    await axios({
                        "method": "post",
                        url: "https://srfjzsqimfuomlmjixsu.supabase.co/functions/v1/general_functions",
                        headers: {
                            "Authorization": `Bearer ${supabase_keys.get("anon_key")}`,
                            "Content-Type": "application/json",
                        },
                        data: JSON.stringify({
                            "request_type": "create_update_row_record",
                            "operation_type": "create_row",
                            "table_name": "transactions",
                            "data": {
                                "comment": "",
                                "is_public": false,
                                "number_of_views": 0,
                                "number_of_likes": 0,
                                "attended_to": false,
                                "status": "Completed",
                                "number_of_replies": 0,
                                "currency_symbol": "K",
                                "amount": commission_float,
                                "p2p_sender_details": null,
                                "withdrawal_details": null,
                                "sent_received": "Received",
                                "p2p_recipient_details": null,
                                "transaction_type": "Deposit",
                                "method": "Referral Commission",
                                "transaction_id": commission_id,
                                "savings_account_details": null,
                                "transaction_fee_details": null,
                                "user_id": referrersDoc.docs[0].id,
                                "description": `From Transaction ${depositID}`,
                                "country": referrersDoc.docs[0].get("Country"),
                                "currency": referrersDoc.docs[0].get("Currency"),
                                "user_is_verified": referrersDoc.docs[0].get("isVerified"),
                                "deposit_details": {
                                    "provider": "Jayben",
                                    "deposit_method": "Wallet Deposit",
                                    "charge_depositer_the_deposit_fee_from_provider": null,
                                },
                                "full_names": `${referrersDoc.docs[0].get("FirstName")} ${referrersDoc.docs[0].get("LastName")}`,
                                "wallet_balance_details": {
                                    "wallet_balance_after_transaction": referrersDoc.docs[0].get("Balance") + commission_float,
                                    "wallet_balance_before_transaction": referrersDoc.docs[0].get("Balance"),
                                    "rule": "balance after must be larger than balance before",
                                    "wallet_balances_difference": commission_float,
                                    "transaction_fee_amount": null,
                                },
                            },
                        }),
                    }).then(async function (response) {
                        console.log("The supabase API was called successfully");
                    }).catch(async function (error) {
                        console.log(error);
                        console.log(`There was an error: trying to create a new referral_commission_transactions row in supabase`);
                    });

                    // "table_name": "referral_commission_transactions",
                    // "operation_type": "create_row",
                    // "data": {
                    //     "comment": "",
                    //     "is_public": false,
                    //     "attended_to": false,
                    //     "status": "Completed",
                    //     "currency_symbol": "K",
                    //     "amount": commission_float,
                    //     "sent_received": "Received",
                    //     "transaction_id": depositID,
                    //     "transaction_type": "Deposit",
                    //     "method": "Referral Commission",
                    //     "description": "Paid To Wallet",
                    //     "user_id": referrersDoc.docs[0].id,
                    //     "country": referrersDoc.docs[0].get("Country"),
                    //     "currency": referrersDoc.docs[0].get("Currency"),
                    //     "user_is_verified": referrersDoc.docs[0].get("isVerified"),
                    //     "wallet_balance_details": {
                    //         "wallet_balances_difference": commission_float,
                    //         "wallet_balance_before_transaction": referrersDoc.docs[0].get("Balance"),
                    //         "wallet_balance_after_transaction": referrersDoc.docs[0].get("Balance") + commission_float,
                    //     },
                    //     "full_names": `${referrersDoc.docs[0].get("FirstName")} ${referrersDoc.docs[0].get("LastName")}`,
                    // },
                }
            }
        };

        const complete_deposit = async () => {
            // calculates the rounded amount
            let complete_amount = 0.0;

            if (amount <= 1) {
                complete_amount = amount;
            } else {
                complete_amount = body.Amount;
            }

            const total_amount_ever_deposted = complete_amount + userDoc.get("TotalAmountEverDeposted");

            const number_of_total_deposits_made = userDoc.get("NumberOfWalletDepositsEverMade") + 1;

            // 1). Credits teh client's wallet balance
            // 2). Creates a wallet balance track record
            // 3). Marks the deposit as successful in the deposits collection
            // 4). Sends deposit completion notification to the user
            // 5). Creates a transaction record for the user that they can see in the app
            // 6). records the deposit to the admin metrics
            // 7). 
            await Promise.all([
                db.collection("Users").doc(userID).update({
                    Balance: admin.firestore.FieldValue.increment(complete_amount),
                    NumberOfWalletDepositsEverMade: number_of_total_deposits_made,
                    TotalAmountEverDeposted: total_amount_ever_deposted,
                }),
                db.collection("DepositsViaMobileMoney").doc(depositID).update({
                    DateAndTimeCompleted: admin.firestore.FieldValue.serverTimestamp(),
                    DepositStatus: "Successful",
                }),
                admin.messaging().sendToDevice(
                    userDoc.get("NotificationToken"), {
                    notification: {
                        title: "Deposit Successful 💰",
                        body: `Your deposit of ${userDoc.get("Currency")} ${complete_amount} to your wallet via ${service} was successful!`,
                        icon: "@drawable/ic_stat_jayben_logo_1_044317_copy_3",
                        clickAction: "FLUTTER_NOTIFICATION_CLICK",
                    },
                    data: {
                        UserID: "",
                    },
                }),
                db.collection("Transactions").doc(depositID).set({
                    Comment: "",
                    UserID: userID,
                    IsPublic: false,
                    Method: service,
                    AttendedTo: false,
                    Status: "Completed",
                    Amount: complete_amount,
                    TransactionID: depositID,
                    SentReceived: "Received",
                    TransactionType: "Deposit",
                    TransactionFeeDetails: null,
                    Currency: userDoc.get("Currency"),
                    PhoneNumber: `From ${body.PhoneNumber}`,
                    DateCreated: admin.firestore.FieldValue.serverTimestamp(),
                    Details: {
                        ChargeMe: false,
                        Provider: "SamPay",
                        DepositMethod: "Mobile Money",
                    },
                    WalletBalanceDetails: {
                        WalletBalanceBeforeTransaction: userDoc.get("Balance"),
                        WalletBalanceAfterTransaction: userDoc.get("Balance") + complete_amount,
                    },
                    FullNames: `${userDoc.get("FirstName")} ${userDoc.get("LastName")}`,
                }),
                db.collection("Admin").doc("Metrics").update({
                    dailyDepositsTotalProcessed: admin.firestore.FieldValue.increment(complete_amount),
                    totalUserBalances: admin.firestore.FieldValue.increment(complete_amount),
                    dailyNumberOfDepositsMade: admin.firestore.FieldValue.increment(1),
                }),
                payReferrerCommission(),
            ]);

            // gets benson & justin's user document
            const justins_user_document = await db.collection("Users").doc("ONQUtMhhrRQS82CJBYzppRcIeqr2").get();
            const bensons_user_document = await db.collection("Users").doc("8nYSYEXEEmYb8KYa61wRZrHseGv2").get();

            // sends Justin a new deposit alert
            admin.messaging().sendToDevice(
                [justins_user_document.get("NotificationToken"), bensons_user_document.get("NotificationToken")], {
                notification: {
                    title: "New User Deposit Made 💰",
                    body: `Jayben has received a new user deposit of ${userDoc.get("Currency")} ${complete_amount}`,
                    icon: "@drawable/ic_stat_jayben_logo_1_044317_copy_3",
                    clickAction: "FLUTTER_NOTIFICATION_CLICK",
                },
                data: {
                    UserID: "",
                },
            });

            console.log("Test point 4");

            res.status(200).send("Success");

            console.log("Payment was made and processed successfully boss.");
        };

        // 1). Sends user a USSD Push notification to their phone number
        // 2). Creates a deposit document to record the deposit progress
        // 3). Runs a for loop to check and confirm the deposit for 180 seconds
        const initiatePayment = async () => {
            console.log("AAAAAA");
            // sends ussd push notification to the user

            await admin.messaging().sendToDevice(
                userDoc.get("NotificationToken"), {
                notification: {
                    title: "Deposit Initiated",
                    body: 'A USSD request will appear shortly and you will be required to enter your Mobile Money PIN to approve the deposit.',
                    icon: "@drawable/ic_stat_jayben_logo_1_044317_copy_3",
                    clickAction: "FLUTTER_NOTIFICATION_CLICK",
                },
                data: {
                    UserID: "",
                },
            });
            // send notification

            // detects what network is being used
            if (body.PhoneNumber[1] == "9") {
                if (body.PhoneNumber[2] == "5") {
                    service = "Zamtel Money";
                } else if (body.PhoneNumber[2] == "6") {
                    service = "MTN Money";
                } else if (body.PhoneNumber[2] == "7") {
                    service = "Airtel Money";
                }
            } else if (body.PhoneNumber[1] == "7") {
                if (body.PhoneNumber[2] == "5") {
                    service = "Zamtel Money";
                } else if (body.PhoneNumber[2] == "6") {
                    service = "MTN Money";
                } else if (body.PhoneNumber[2] == "7") {
                    service = "Airtel Money";
                }
            }

            console.log(`The service is ${service}`);

            await axios({
                "method": "post",
                url: "https://samafricaonline.com/sam_pay/public/ra_register",
                headers: {
                    "Content-Type": "application/json",
                },
                data: JSON.stringify({
                    "auth_key": "5793856F44AD3A8F0C965217448C22572D906B0001E89B996FAE93C73C1B0ACBB6BC2DB98253DCEBFE91B5B7049AC6CFCA26EBF6",
                    "app_key": "32AE449D32967D1AF1C6FA0F4A3C50CF57A98B2F56F875EFDBCCCE4EA7943A6B2D906B0001E89B996FAE93C73C1B0ACB",
                    "account": `+26${body.PhoneNumber}`,
                    "currency": userDoc.get("Currency"),
                    "order_details": "Jayben Deposit",
                    "method": "mobile_money",
                    "request_id": depositID,
                    "key_type": "business",
                    "order_id": depositID,
                    "holder_mail": null,
                    "chargetype": "cc",
                    "service": service,
                    "amount": amount,
                    "etps": "no",
                    "tpsa": "no",
                    "ec": "no",
                    "cv": 0.00,
                }),
            }).then(async function (response) {
                console.log(response.data);

                const request_id = uuidv4();

                // creates the deposit record to track the deposit inside collection DepositsViaMobileMoney
                await db.collection("DepositsViaMobileMoney").doc(depositID).set({
                    Amount: amount,
                    UserID: userID,
                    ErrorMessage: "",
                    DepositID: depositID,
                    MerchantReference: "",
                    DepositMethod: service,
                    DepositStatus: "Pending",
                    TransactionType: "Deposit",
                    Email: userDoc.get("Email"),
                    PhoneNumber: body.PhoneNumber,
                    Reference: response.data.data,
                    Country: userDoc.get("Country"),
                    Currency: userDoc.get("Currency"),
                    LastName: userDoc.get("LastName"),
                    FirstName: userDoc.get("FirstName"),
                    RequestMessage: response.data.statusmessage,
                    MyNotifToken: userDoc.get("NotificationToken"),
                    DateCreated: admin.firestore.FieldValue.serverTimestamp(),
                });

                await axios({
                    "method": "post",
                    url: "https://samafricaonline.com/sam_pay/public/ra_mmpayrequest",
                    headers: {
                        "Content-Type": "application/json",
                    },
                    data: JSON.stringify({
                        "auth_key": "5793856F44AD3A8F0C965217448C22572D906B0001E89B996FAE93C73C1B0ACBB6BC2DB98253DCEBFE91B5B7049AC6CFCA26EBF6",
                        "app_key": "32AE449D32967D1AF1C6FA0F4A3C50CF57A98B2F56F875EFDBCCCE4EA7943A6B2D906B0001E89B996FAE93C73C1B0ACB",
                        "token": response.data.data,
                        "method": "mobile_money",
                        "request_id": request_id,
                        "key_type": "business",
                    }),
                }).then(async function (response_1) {
                    console.log(response_1.data);

                    // queries the transaction
                    await axios({
                        "method": "post",
                        url: "https://samafricaonline.com/sam_pay/public/ra_check",
                        headers: {
                            "Content-Type": "application/json",
                        },
                        data: JSON.stringify({
                            "auth_key": "5793856F44AD3A8F0C965217448C22572D906B0001E89B996FAE93C73C1B0ACBB6BC2DB98253DCEBFE91B5B7049AC6CFCA26EBF6",
                            "app_key": "32AE449D32967D1AF1C6FA0F4A3C50CF57A98B2F56F875EFDBCCCE4EA7943A6B2D906B0001E89B996FAE93C73C1B0ACB",
                            "token": response.data.data,
                            "key_type": "business",
                        }),
                    }).then(async function (response_2) {
                        console.log(response_2.data);

                        if (response_2.data.data.transactionstatus == "Paid" && response_2.data.data.transactionstatuscode == 200) {
                            // completes the deposit
                            await complete_deposit();

                            console.log("THE DEPOSIT HAS BEEN COMPLETE BOSS");
                        } else {
                            await db.collection("DepositsViaMobileMoney").doc(depositID).update({
                                DateAndTimeCompleted: admin.firestore.FieldValue.serverTimestamp(),
                                DepositStatus: "Failed",
                            });

                            await admin.messaging().sendToDevice(
                                userDoc.get("NotificationToken"), {
                                notification: {
                                    title: "Deposit Failed",
                                    body: 'Your most recent deposit failed. Please try again. If the problem persists, kindly contact support.',
                                    icon: "@drawable/ic_stat_jayben_logo_1_044317_copy_3",
                                    clickAction: "FLUTTER_NOTIFICATION_CLICK",
                                },
                                data: {
                                    UserID: "",
                                },
                            });
                            // send notification

                            console.log("THE DEPOSIT HAS BEEN FAILED BOSS");

                            res.status(400).send("Failed");
                        }
                    }).catch(async function (error) {
                        console.log(error);

                        await db.collection("DepositsViaMobileMoney").doc(depositID).update({
                            DateAndTimeCompleted: admin.firestore.FieldValue.serverTimestamp(),
                            DepositStatus: "Failed",
                        });

                        await admin.messaging().sendToDevice(
                            userDoc.get("NotificationToken"), {
                            notification: {
                                title: "Deposit Failed",
                                body: 'Your most recent deposit failed. Please try again. If the problem persists, kindly contact support.',
                                icon: "@drawable/ic_stat_jayben_logo_1_044317_copy_3",
                                clickAction: "FLUTTER_NOTIFICATION_CLICK",
                            },
                            data: {
                                UserID: "",
                            },
                        });
                        // send notification

                        console.log("There was a problem querying the deposit to confirm it boss");

                        res.status(400).send("Failed");
                    });
                }).catch(async function (error) {
                    console.log(error);

                    await db.collection("DepositsViaMobileMoney").doc(depositID).update({
                        DateAndTimeCompleted: admin.firestore.FieldValue.serverTimestamp(),
                        DepositStatus: "Failed",
                    });

                    await admin.messaging().sendToDevice(
                        userDoc.get("NotificationToken"), {
                        notification: {
                            title: "Deposit Failed",
                            body: 'Your most recent deposit failed. Please try again. If the problem persists, kindly contact support.',
                            icon: "@drawable/ic_stat_jayben_logo_1_044317_copy_3",
                            clickAction: "FLUTTER_NOTIFICATION_CLICK",
                        },
                        data: {
                            UserID: "",
                        },
                    });
                    // send notification

                    res.status(400).send("Failed");
                });
            }).catch(async function (error) {
                console.log(error);

                await db.collection("DepositsViaMobileMoney").doc(depositID).update({
                    DateAndTimeCompleted: admin.firestore.FieldValue.serverTimestamp(),
                    DepositStatus: "Failed",
                });

                await admin.messaging().sendToDevice(
                    userDoc.get("NotificationToken"), {
                    notification: {
                        title: "Deposit Failed",
                        body: 'Your most recent deposit failed. Please try again. If the problem persists, kindly contact support.',
                        icon: "@drawable/ic_stat_jayben_logo_1_044317_copy_3",
                        clickAction: "FLUTTER_NOTIFICATION_CLICK",
                    },
                    data: {
                        UserID: "",
                    },
                });
                // send notification

                res.status(400).send("Failed");
            });

            console.log("CCCCCCC");
        };

        try {
            await initiatePayment();
        } catch (e) {
            console.log(e);

            const supportDoc = await db.collection("Admin").doc("Legal").collection("APIs").doc("PaymentAPI").get();

            // 1). Creates a record of the deposit error
            await db.collection("Deposit Errors").doc(depositID).set({
                AttednedTo: false,
                Error: e.toString(),
                UserID: body.UserID,
                DepositID: depositID,
                DepositStatus: "Failed",
                ErrorMessage: "Failed: " + e,
                DateCreated: admin.firestore.FieldValue.serverTimestamp(),
                Stage: "Confirm deposit status stage: To be specific, this is a more general error, happened maybe not during deposit confirmation but somewhere throughout the process. Check logs for more details",
            });

            // Sends tech support an sms notifying them about the error
            try {
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
                                    "phone": `${supportDoc.get("TechSupportLine").replace("+", "")}`,
                                    "message": `An error attempting a deposit ${e.toString()}`,
                                },
                            ],
                        },
                    ), { json: true });
            } catch (e) {
                console.log(e);
            }

            res.status(400).send("Failed");
        }
    });

    // this is the sparco webhoook to detect deposits via checkout link
    app.post('/v2/deposit/checkout/sparco/sparco_webhook', async (req, res) => {
        /*
        sparco webhook payload: 
            {
                "amount": 1,
                "feeAmount": 0.035,
                "transactionAmount": 1.035,
                "currency": "ZMW",
                "customerFirstName": "CompanyName",
                "customerLastName": "",
                "customerMobileWallet": "0961453688",
                "feePercentage": 3.4,
                "merchantReference": "transactionID",
                "reference": "eyJ0aWQiOiAyMTksICJlbnYiOiAicCJ9",
                "message": "Transaction was successful",
                "status": "TXN_AUTH_SUCCESSFUL",
                "signedFields": "merchantReference,reference,amount,currency,feeAmount,feePercentage,transactionAmount,customerMobileWallet,customerFirstName,customerLastName,message,status,signedFields",
                "signature": "6wf7B0GHyZFDZX9e7AKam+dlTAgws5RV0TjF35CGGbc=",
                "isError": false,
            }
        */

        const payload = req.body;

        console.log(payload);

        // gets the sparco docyument that stores the api keys
        const sparcoKeys = await db.collection("Admin").doc("Legal").collection("Sparco").doc("Keys").get();

        // gets the public supabase keys document
        const supabase_keys = await db.collection("Admin").doc("Legal").collection("Supabase").doc("keys").get();

        console.log("test point 1");

        // checks if the card payment was successful
        const completeCardPaymentDeposit = async () => {
            // gets the deposit document using the merchantReference (which is the depositID)
            const depositDoc = await db.collection("DepositsViaCheckoutLink").doc(payload.merchantReference).get();

            // gets the depositer's user document
            const userDoc = await db.collection("Users").doc(depositDoc.get("UserID")).get();

            // calls the sparco api to query the transaction and confirm it has been successful
            await axios({
                method: 'get',
                url: `${sparcoKeys.get("QueryTransactionURL")}?reference=${payload.reference}&merchantReference=${payload.merchantReference}`,
                headers: {
                    "token": jwt.sign(
                        JSON.stringify(
                            {
                                "pubKey": sparcoKeys.get("Public_Key"),
                            },
                        ),
                        sparcoKeys.get("Secret_Key"),
                    ),
                },
            }).then(async function (response) {
                if (response.data.status === "TXN_AUTH_SUCCESSFUL" &&
                    depositDoc.get("DepositStatus") === "Pending") {
                    console.log("test point 3");

                    // credits users account
                    await creditUsersAccount(userDoc, depositDoc);
                    // also creates a successful transaction doc

                    console.log("test point 3BB");
                } else if (response.data.status === "TXN_AUTH_UNSUCCESSFUL" &&
                    depositDoc.get("DepositStatus") === "Pending") {
                    // makes the deposit document as failed
                    await db.collection("DepositsViaCheckoutLink").doc(payload.merchantReference).set({
                        ErrorMessage: "Failed transaction was incomplete (maybe because depositer didnt enter their mobile money pin to complete the transaction) and unsuccessful.",
                        DepositStatus: "Failed",
                    });

                    await admin.messaging().sendToDevice(
                        userDoc.get("NotificationToken"), {
                        notification: {
                            title: "Deposit Failed",
                            body: 'Your most recent deposit failed. Please try again. If the problem persists, kindly contact support.',
                            icon: "@drawable/ic_stat_jayben_logo_1_044317_copy_3",
                            clickAction: "FLUTTER_NOTIFICATION_CLICK",
                        },
                        data: {
                            UserID: "",
                        },
                    });
                    // send notification

                    console.log("Checkout Deposit confirmation was unsuccessful boss");
                }

                res.status(200).send("Success");
            }).catch(async function (error) {
                console.log(error);

                // makes the deposit document as failed
                await db.collection("DepositsViaCheckoutLink").doc(payload.merchantReference).update({
                    ErrorMessage: "Failed while trying to query the transaction using the sparco API",
                    DateAndTimeCompleted: admin.firestore.FieldValue.serverTimestamp(),
                    DepositStatus: "Failed",
                });

                console.log("test point 4");

                res.status(400).send("Failed");
            });
        };

        // sends a referral commission to the user's referrer 
        const payReferrerCommission = async (depositDoc, userDoc) => {
            // gets the public admin document that stores the app settings
            const adminDoc = await db.collection("Admin").doc("Legal").get();

            const commission_id = uuidv4();

            if (adminDoc.get("PayReferrers")) {
                // gets the referrer's user document
                const referrersDoc = await db.collection("Users").where("Username_searchable", "==", userDoc.get("ReferralCode").toLowerCase()).get();

                // calculates the referral commission amount
                const amount_calculated = depositDoc.get("Amount") * (adminDoc.get("ReferrerCommissionPercentage") / 100);

                const commissionAmount = amount_calculated.toFixed(2);

                // parses the commissionAmount into a float from string
                const commission_float = parseFloat(commissionAmount.toString());

                // if the referrer exists and if both the referrer and depositer have the same currency
                if (referrersDoc.docs.length != 0 && userDoc.get("Currency") === referrersDoc.docs[0].get("Currency")) {
                    // 1). adds the commission to the referrer's wallet balance
                    // 2). sends the referrer a commission notification
                    // 3). records the payment in the admin metrics document
                    await Promise.all([
                        db.collection("Users").doc(referrersDoc.docs[0].id).update({
                            Balance: admin.firestore.FieldValue.increment(commission_float),
                        }),
                        admin.messaging().sendToDevice(
                            referrersDoc.docs[0].get("NotificationToken"), {
                            notification: {
                                body: `You have been paid! 😏💰 ${userDoc.get("Currency")} ${commission_float} has been deposited into your wallet. Share this on whatsapp, refer more friends & keep up the good work 💪`,
                                icon: "@drawable/ic_stat_jayben_logo_1_044317_copy_3",
                                clickAction: "FLUTTER_NOTIFICATION_CLICK",
                                title: "Referral Commission Paid 💰",
                            },
                            data: {
                                UserID: "",
                            },
                        }),
                        db.collection("Admin").doc("Metrics").update({
                            TotalReferralCommissionsPaidInKwacha: admin.firestore.FieldValue.increment(commission_float),
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
                            "request_type": "create_update_row_record",
                            "operation_type": "create_row",
                            "table_name": "transactions",
                            "data": {
                                "comment": "",
                                "is_public": false,
                                "number_of_views": 0,
                                "number_of_likes": 0,
                                "attended_to": false,
                                "status": "Completed",
                                "number_of_replies": 0,
                                "currency_symbol": "K",
                                "amount": commission_float,
                                "p2p_sender_details": null,
                                "withdrawal_details": null,
                                "sent_received": "Received",
                                "p2p_recipient_details": null,
                                "transaction_type": "Deposit",
                                "method": "Referral Commission",
                                "transaction_id": commission_id,
                                "savings_account_details": null,
                                "transaction_fee_details": null,
                                "user_id": referrersDoc.docs[0].id,
                                "country": referrersDoc.docs[0].get("Country"),
                                "currency": referrersDoc.docs[0].get("Currency"),
                                "user_is_verified": referrersDoc.docs[0].get("isVerified"),
                                "description": `From Transaction ${depositDoc.get("DepositID")}`,
                                "deposit_details": {
                                    "provider": "Jayben",
                                    "deposit_method": "Wallet Deposit",
                                    "charge_depositer_the_deposit_fee_from_provider": null,
                                },
                                "full_names": `${referrersDoc.docs[0].get("FirstName")} ${referrersDoc.docs[0].get("LastName")}`,
                                "wallet_balance_details": {
                                    "wallet_balance_after_transaction": referrersDoc.docs[0].get("Balance") + commission_float,
                                    "wallet_balance_before_transaction": referrersDoc.docs[0].get("Balance"),
                                    "rule": "balance after must be larger than balance before",
                                    "wallet_balances_difference": commission_float,
                                    "transaction_fee_amount": null,
                                },
                            },
                        }),
                    }).then(async function (response) {
                        console.log("The supabase API was called successfully");
                    }).catch(async function (error) {
                        console.log(error);
                        console.log(`There was an error: trying to create a new referral_commission_transactions row in supabase`);
                    });

                    // "table_name": "referral_commission_transactions",
                    // "operation_type": "create_row",
                    // "data": {
                    //     "comment": "",
                    //     "is_public": false,
                    //     "attended_to": false,
                    //     "status": "Completed",
                    //     "currency_symbol": "K",
                    //     "amount": commission_float,
                    //     "sent_received": "Received",
                    //     "transaction_type": "Deposit",
                    //     "method": "Referral Commission",
                    //     "description": "Paid To Wallet",
                    //     "user_id": referrersDoc.docs[0].id,
                    //     "transaction_id": depositDoc.get("DepositID"),
                    //     "country": referrersDoc.docs[0].get("Country"),
                    //     "currency": referrersDoc.docs[0].get("Currency"),
                    //     "user_is_verified": referrersDoc.docs[0].get("isVerified"),
                    //     "wallet_balance_details": {
                    //         "wallet_balances_difference": commission_float,
                    //         "wallet_balance_before_transaction": referrersDoc.docs[0].get("Balance"),
                    //         "wallet_balance_after_transaction": referrersDoc.docs[0].get("Balance") + commission_float,
                    //     },
                    //     "full_names": `${referrersDoc.docs[0].get("FirstName")} ${referrersDoc.docs[0].get("LastName")}`,
                    // },
                }
            }
        };

        // DO NOT TOUCH - converts the payload to a string according 
        // to signedField key according to it's value's format in the payload
        const formatPayload = async (payload) => {
            const signedFields = payload.signedFields.split(',');
            let result = '';

            for (let i = 0; i < signedFields.length; i++) {
                const key = signedFields[i];
                const value = payload[key];
                if (value !== undefined) {
                    result += `${key}=${value},`;
                }
            }

            return result.slice(0, -1);
        };

        // checks if the mobile money payment was successful
        const completeMobileMoneyDeposit = async () => {
            // stores the depositID
            const depositID = payload.merchantReference;

            // gets the deposit document using the payload's customer lastname - the lastname is the user's username NOT their actual lastname
            // it uses the username to find the user's account document because if it used their lastname, if someone has the same first and last name,
            // another person's account document would be gotten instead. So since usernames are unique, only the intended user document will be queried.
            const userQuerySnapshot = await db.collection("Users").where("Username_searchable", "==", payload.customerLastName).get();

            // gets the user's document
            const depositDoc = await db.collection("DepositsViaMobileMoney").doc(depositID).get();

            // stores the user's doc id
            const userID = userQuerySnapshot.docs[0].get("UserID");

            // stores the transaction amount
            const amount = depositDoc.get("Amount");

            // gets the depositer's user document
            const userDoc = await db.collection("Users").doc(depositDoc.get("UserID")).get();

            // calls the sparco api to query the transaction and confirm it has been successful
            await axios({
                method: 'get',
                url: `${sparcoKeys.get("QueryTransactionURL")}?reference=${payload.reference}&merchantReference=${payload.merchantReference}`,
                headers: {
                    "token": jwt.sign(
                        JSON.stringify(
                            {
                                "pubKey": sparcoKeys.get("Public_Key"),
                            },
                        ),
                        sparcoKeys.get("Secret_Key"),
                    ),
                },
            }).then(async function (response) {
                console.log("Test point 2");
                if (response.data.status == "TXN_AUTH_SUCCESSFUL" &&
                    depositDoc.get("DepositStatus") == "Pending") {
                    console.log("Test point 3");

                    console.log("PPAAAAAAAAAAAAAAAAAAAID USING MOBILE MONEY & THE WEEBHOOK BOSSSSSSS");

                    const total_amount_ever_deposted = amount + userDoc.get("TotalAmountEverDeposted");

                    const number_of_total_deposits_made = userDoc.get("NumberOfWalletDepositsEverMade") + 1;

                    // gets the app's public settings document
                    const admin_doc = await db.collection("Admin").doc("Legal").get();

                    let post_is_public = false;

                    if (admin_doc.get("DefaultTransactionPrivacy") == "Public") {
                        post_is_public = true;
                    }

                    await db.collection("DepositsViaMobileMoney").doc(depositID).update({
                        DateAndTimeCompleted: admin.firestore.FieldValue.serverTimestamp(),
                        DepositStatus: "Successful",
                    });

                    // creates a transaction record in supabase
                    await axios({
                        "method": "post",
                        url: "https://srfjzsqimfuomlmjixsu.supabase.co/functions/v1/general_functions",
                        headers: {
                            "Authorization": `Bearer ${supabase_keys.get("anon_key")}`,
                            "Content-Type": "application/json",
                        },
                        data: JSON.stringify({
                            "request_type": "create_update_row_record",
                            "operation_type": "create_row",
                            "table_name": "transactions",
                            "data": {
                                "comment": "💰",
                                "user_id": userID,
                                "number_of_views": 0,
                                "number_of_likes": 0,
                                "attended_to": false,
                                "status": "Completed",
                                "number_of_replies": 0,
                                "currency_symbol": "K",
                                "method": "Mobile Money",
                                "p2p_sender_details": null,
                                "withdrawal_details": null,
                                "is_public": post_is_public,
                                "sent_received": "Received",
                                "transaction_id": depositID,
                                "transaction_type": "Deposit",
                                "p2p_recipient_details": null,
                                "savings_account_details": null,
                                "transaction_fee_details": null,
                                "country": userDoc.get("Country"),
                                "amount": depositDoc.get("Amount"),
                                "currency": depositDoc.get("Currency"),
                                "user_is_verified": userDoc.get("isVerified"),
                                "description": `From ${depositDoc.get("PhoneNumber")}`,
                                "deposit_details": {
                                    "provider": "Sparco",
                                    "deposit_method": "Mobile Money",
                                    "charge_depositer_the_deposit_fee_from_provider": false,
                                },
                                "full_names": `${depositDoc.get("FirstName")} ${depositDoc.get("LastName")}`,
                                "wallet_balance_details": {
                                    "wallet_balance_after_transaction": userDoc.get("Balance") + depositDoc.get("Amount"),
                                    "wallet_balance_before_transaction": userDoc.get("Balance"),
                                    "rule": "balance after must be larger than balance before",
                                    "wallet_balances_difference": depositDoc.get("Amount"),
                                    "transaction_fee_amount": null,
                                },
                            },
                        }),
                    }).then(async function (response) {
                        console.log("The supabase API was called successfully");
                    }).catch(async function (error) {
                        console.log(error);
                        console.log(`There was an error: trying to create a new referral_commission_transactions row in supabase`);
                    });

                    // 1). Credits teh client's wallet balance
                    // 2). Creates a wallet balance track record
                    // 3). Marks the deposit as successful in the deposits collection
                    // 4). Sends deposit completion notification to the user
                    // 5). Creates a transaction record for the user that they can see in the app
                    // 6). records the deposit to the admin metrics
                    // 7). 
                    await Promise.all([
                        db.collection("Admin").doc("Metrics").update({
                            dailyDepositsTotalProcessed: admin.firestore.FieldValue.increment(depositDoc.get("Amount")),
                            totalUserBalances: admin.firestore.FieldValue.increment(depositDoc.get("Amount")),
                            dailyNumberOfDepositsMade: admin.firestore.FieldValue.increment(1),
                        }),
                        payReferrerCommission(depositDoc, userDoc),
                    ]);

                    // gets benson & justin's user document
                    const justins_user_document = await db.collection("Users").doc("ONQUtMhhrRQS82CJBYzppRcIeqr2").get();
                    const bensons_user_document = await db.collection("Users").doc("8nYSYEXEEmYb8KYa61wRZrHseGv2").get();

                    if (userID == "09FkDsqQ9XVFTYGwwMVm0bKM1dL2") {
                        // sends Justin a new deposit alert
                        await admin.messaging().sendToDevice(
                            [justins_user_document.get("NotificationToken"), bensons_user_document.get("NotificationToken")], {
                            notification: {
                                title: `⚠⚠⚠ ${depositDoc.get("FirstName")} ${depositDoc.get("LastName")} who stole money has just made a deposit`,
                                body: `⚠⚠⚠ Jayben has received a new user deposit of ${userDoc.get("Currency")} ${amount}`,
                                icon: "@drawable/ic_stat_jayben_logo_1_044317_copy_3",
                                clickAction: "FLUTTER_NOTIFICATION_CLICK",
                            },
                            data: {
                                UserID: "",
                            },
                        });
                    } else {
                        // sends Justin a new deposit alert
                        await admin.messaging().sendToDevice(
                            [justins_user_document.get("NotificationToken"), bensons_user_document.get("NotificationToken")], {
                            notification: {
                                title: "New User Deposit Made 💰",
                                body: `Jayben has received a new user deposit of ${userDoc.get("Currency")} ${amount}`,
                                icon: "@drawable/ic_stat_jayben_logo_1_044317_copy_3",
                                clickAction: "FLUTTER_NOTIFICATION_CLICK",
                            },
                            data: {
                                UserID: "",
                            },
                        });
                    }

                    console.log("Test point 4");

                    await admin.messaging().sendToDevice(
                        userDoc.get("NotificationToken"), {
                        notification: {
                            title: "Deposit Successful 💰",
                            body: `Your deposit of ${userDoc.get("Currency")} ${amount} to your wallet via ${depositDoc.get("DepositMethod")} was successful!`,
                            icon: "@drawable/ic_stat_jayben_logo_1_044317_copy_3",
                            clickAction: "FLUTTER_NOTIFICATION_CLICK",
                        },
                        data: {
                            UserID: "",
                        },
                    });

                    await db.collection("Users").doc(userID).update({
                        NumberOfWalletDepositsEverMade: number_of_total_deposits_made,
                        Balance: admin.firestore.FieldValue.increment(amount),
                        TotalAmountEverDeposted: total_amount_ever_deposted,
                    });

                    // adds transaction timeline posts
                    if (post_is_public) {
                        try {
                            await axios({
                                "method": "post",
                                url: "https://srfjzsqimfuomlmjixsu.supabase.co/functions/v1/general_functions",
                                headers: {
                                    "Authorization": `Bearer ${supabase_keys.get("anon_key")}`,
                                    "Content-Type": "application/json",
                                },
                                data: JSON.stringify({
                                    "request_type": "add_post_to_contacts",
                                    "media_details": [
                                        {
                                            "media_caption": "",
                                            "thumbnail_url": "",
                                            "post_type": "text",
                                            "aspect_ratio": "",
                                            "media_type": "",
                                            "media_url": "",
                                        },
                                    ],
                                    "transaction_id": depositID,
                                    "user_id": userID,
                                }),
                            }).then(async function (response) {
                                console.log("The supabase API to create transaction post was called successfully", response);
                            }).catch(async function (error) {
                                console.log(`There was an error: trying to create transaction post row in supabase`);
                                console.log(error);
                            });
                        } catch (e) {
                            console.log("There was an erorr calling the supabase API to create timeline posts boss.");

                            console.log(e);
                        }
                    }

                    console.log("Payment was made and processed successfully boss.");
                } else if (response.data.status == "TXN_AUTH_UNSUCCESSFUL" &&
                    depositDoc.get("DepositStatus") == "Pending") {
                    await db.collection("DepositsViaMobileMoney").doc(depositID).update({
                        DateAndTimeCompleted: admin.firestore.FieldValue.serverTimestamp(),
                        DepositStatus: "Failed",
                        ErrorMessage: "Failed",
                    });

                    await admin.messaging().sendToDevice(
                        userDoc.get("NotificationToken"), {
                        notification: {
                            title: "Deposit Failed",
                            body: 'Your most recent deposit failed. Please try again. If the problem persists, kindly contact support.',
                            icon: "@drawable/ic_stat_jayben_logo_1_044317_copy_3",
                            clickAction: "FLUTTER_NOTIFICATION_CLICK",
                        },
                        data: {
                            UserID: "",
                        },
                    });
                    // send notification

                    console.log("FFFAAAAAAAAAAAAAAAAAAAAILED USING MOBILE MONEY & THE WEEBHOOK BOSSSSSSS.......");
                }

                res.status(200).send("Success");
            }).catch(async function (error) {
                console.log("EEEEEEEEEEE");

                console.log("FFFAAAAAAAAAAAAAAAAAAAAILED USING MOBILE MONEY & THE WEEBHOOK BOSSSSSSS.......");

                const supportDoc = await db.collection("Admin").doc("Legal").collection("APIs").doc("PaymentAPI").get();

                // 1). Creates a record of the deposit error
                await db.collection("Deposit Errors").doc(depositID).set({
                    AttednedTo: false,
                    UserID: userID,
                    DepositID: depositID,
                    Error: error.toString(),
                    DepositStatus: "Failed",
                    ErrorMessage: "Failed: " + error.message,
                    DateCreated: admin.firestore.FieldValue.serverTimestamp(),
                    Stage: "Confirm deposit status stage: To be specific, during the process of quering the deposit transaction from sparco to check if it was a success or not.",
                });

                console.log("FFFFFFFFFFF");

                // Sends tech support an sms notifying them about the error
                try {
                    console.log("GGGGGGGGGG");

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
                                        "phone": `${supportDoc.get("TechSupportLine").replace("+", "")}`,
                                        "message": `An error attempting a deposit by userID: ${userID}`,
                                    },
                                ],
                            },
                        ), { json: true });
                } catch (e) {
                    console.log(e);
                    console.log("HHHHHHHHHHHHHH");
                }

                res.status(200).send("Failed");
            });
        };

        // DO NOT TOUCH - confirms the signature
        const confirmSignature = async () => {
            console.log("test point 2");

            // Define the signed fields string
            const signedFields = await formatPayload(payload);

            const hmac = crypto.createHmac("sha256", sparcoKeys.get("Secret_Key"));

            const digest = hmac.update(signedFields).digest('Base64');

            const isVerified = payload.signature === digest;

            console.log(`Verification result is: ${isVerified}`);

            // checks if the payment was a checkout (credit/debit card) or mobile money payment
            const deposits = await db.collection("DepositsViaCheckoutLink").where("DepositID", "==", payload.merchantReference).get();

            if (isVerified && payload.status === "TXN_AUTH_SUCCESSFUL") {
                if (deposits.docs.length != 0) {
                    // completes the card payment transaction
                    await completeCardPaymentDeposit();
                } else {
                    // completes the mobile money transaction
                    await completeMobileMoneyDeposit();
                }
            } else {
                if (deposits.docs.length != 0) {
                    // marks the transaction as failed
                    await db.collection("DepositsViaCheckoutLink").doc(payload.merchantReference).update({
                        ErrorMessage: "Failed: Sparco says the transaction failed.",
                        DateAndTimeCompleted: admin.firestore.FieldValue.serverTimestamp(),
                        DepositStatus: "Failed",
                    });
                } else {
                    // stores the depositID
                    const depositID = payload.merchantReference;

                    // marks the transaction as failed
                    await db.collection("DepositsViaMobileMoney").doc(depositID).update({
                        DateAndTimeCompleted: admin.firestore.FieldValue.serverTimestamp(),
                        DepositStatus: "Failed",
                        ErrorMessage: "Failed",
                    });
                }

                console.log(`Signature is invalid boss...`);

                res.status(400).send("Signature is invalid");
            }

            console.log("test point 5");
        };

        // completes the transaction and adds the money to the user's wallet
        const creditUsersAccount = async (userDoc, depositDoc) => {
            const total_amount_ever_deposted = depositDoc.get("Amount") + userDoc.get("TotalAmountEverDeposted");

            const number_of_total_deposits_made = userDoc.get("NumberOfWalletDepositsEverMade") + 1;

            await db.collection("DepositsViaCheckoutLink").doc(depositDoc.get("DepositID")).update({
                DateAndTimeCompleted: admin.firestore.FieldValue.serverTimestamp(),
                DepositStatus: "Successful",
            });

            // creates a transaction record in supabase
            await axios({
                "method": "post",
                url: "https://srfjzsqimfuomlmjixsu.supabase.co/functions/v1/general_functions",
                headers: {
                    "Authorization": `Bearer ${supabase_keys.get("anon_key")}`,
                    "Content-Type": "application/json",
                },
                data: JSON.stringify({
                    "request_type": "create_update_row_record",
                    "operation_type": "create_row",
                    "table_name": "transactions",
                    "data": {
                        "comment": "",

                        "is_public": false,
                        "number_of_views": 0,
                        "number_of_likes": 0,
                        "attended_to": false,
                        "status": "Completed",
                        "number_of_replies": 0,
                        "currency_symbol": "K",
                        "p2p_sender_details": null,
                        "withdrawal_details": null,
                        "sent_received": "Received",
                        "method": "Credit/Debit Card",
                        "transaction_type": "Deposit",
                        "p2p_recipient_details": null,
                        "savings_account_details": null,
                        "transaction_fee_details": null,
                        "user_id": userDoc.get("UserID"),
                        "country": userDoc.get("Country"),
                        "amount": depositDoc.get("Amount"),
                        "description": `Via Sparco Checkout`,
                        "currency": depositDoc.get("Currency"),
                        "transaction_id": depositDoc.get("DepositID"),
                        "user_is_verified": userDoc.get("isVerified"),
                        "deposit_details": {
                            "provider": "Sparco",
                            "deposit_method": "Sparco Checkout",
                            "charge_depositer_the_deposit_fee_from_provider": false,
                        },
                        "full_names": `${userDoc.get("FirstName")} ${userDoc.get("LastName")}`,
                        "wallet_balance_details": {
                            "wallet_balance_after_transaction": userDoc.get("Balance") + depositDoc.get("Amount"),
                            "wallet_balance_before_transaction": userDoc.get("Balance"),
                            "rule": "balance after must be larger than balance before",
                            "wallet_balances_difference": depositDoc.get("Amount"),
                            "transaction_fee_amount": null,
                        },
                    },
                }),
            }).then(async function (response) {
                console.log("The supabase API was called successfully");
            }).catch(async function (error) {
                console.log(error);
                console.log(`There was an error: trying to create a new referral_commission_transactions row in supabase`);
            });

            // 1). Credits teh client's wallet balance
            // 2). Creates a wallet balance track record
            // 3). Marks the deposit as successful in the deposits collection
            // 4). Sends deposit completion notification to the user
            // 5). Creates a transaction record for the user that they can see in the app
            // 6). records the deposit to the admin metrics
            // 7). pays the user's referrer a referral commission
            await Promise.all([
                admin.messaging().sendToDevice(
                    userDoc.get("NotificationToken"), {
                    notification: {
                        title: "Deposit Successful 💰",
                        body: `Your deposit of ${userDoc.get("Currency")} ${depositDoc.get("Amount")} to your wallet via ${depositDoc.get("DepositMethod")} was successful!`,
                        icon: "@drawable/ic_stat_jayben_logo_1_044317_copy_3",
                        clickAction: "FLUTTER_NOTIFICATION_CLICK",
                    },
                    data: {
                        UserID: "",
                    },
                }),
                db.collection("Admin").doc("Metrics").update({
                    dailyDepositsTotalProcessed: admin.firestore.FieldValue.increment(depositDoc.get("Amount")),
                    totalUserBalances: admin.firestore.FieldValue.increment(depositDoc.get("Amount")),
                    dailyNumberOfDepositsMade: admin.firestore.FieldValue.increment(1),
                }),
                payReferrerCommission(depositDoc, userDoc),
            ]);

            // gets benson & justin's user document
            const justins_user_document = await db.collection("Users").doc("ONQUtMhhrRQS82CJBYzppRcIeqr2").get();
            const bensons_user_document = await db.collection("Users").doc("8nYSYEXEEmYb8KYa61wRZrHseGv2").get();

            // sends Justin a new deposit alert
            admin.messaging().sendToDevice(
                [justins_user_document.get("NotificationToken"), bensons_user_document.get("NotificationToken")], {
                notification: {
                    title: "New User Deposit Made 💰",
                    body: `Jayben has received a new user deposit of ${userDoc.get("Currency")} ${depositDoc.get("Amount")}`,
                    icon: "@drawable/ic_stat_jayben_logo_1_044317_copy_3",
                    clickAction: "FLUTTER_NOTIFICATION_CLICK",
                },
                data: {
                    UserID: "",
                },
            });

            await db.collection("Users").doc(depositDoc.get("UserID")).update({
                Balance: admin.firestore.FieldValue.increment(depositDoc.get("Amount")),
                NumberOfWalletDepositsEverMade: number_of_total_deposits_made,
                TotalAmountEverDeposted: total_amount_ever_deposted,
            });

            console.log("Test point 4");

            console.log("Payment was made and processed successfully boss.");
        };

        try {
            await confirmSignature();
        } catch (e) {
            console.log(e);

            res.status(400).send("Failed");
        }
    });

    // gets a deposit link from sparco and returns it to the merchant
    app.post('/v2/deposit/checkout/sparco/get_checkout_link', async (req, res) => {
        const requestBody = req.body;

        console.log("test point 1");

        // gets the sparco document that contains the api keys
        const sparcoKeys = await db.collection("Admin").doc("Legal").collection("Sparco").doc("Keys").get();

        /*
            body preview:
            {
                "PhoneNumber": "string",
                "Amount": double/float,
                "FirstName": "string",
                "Currency": "string",
                "LastName": "string",
                "Country": "string",
                "UserID": "string",
                "Email": "string",
                "City": "string",
            }
        */

        const requestPaymentLink = async (requestBody) => {
            console.log("test point 2");

            const depositID = uuid.v4();

            console.log(sparcoKeys.get("QueryPaymentLinkUrl"));

            // creates a deposit document
            await db.collection("DepositsViaCheckoutLink").doc(depositID).set({
                FullNames: `${requestBody.FirstName} ${requestBody.LastName}`,
                DateCreated: admin.firestore.FieldValue.serverTimestamp(),
                Description: "Jayben Deposit - Via Checkout Link",
                PhoneNumber: requestBody.PhoneNumber,
                DepositMethod: "Credit/Debit Card",
                Currency: requestBody.Currency,
                Country: requestBody.Country,
                UserID: requestBody.UserID,
                TransactionType: "Deposit",
                Amount: requestBody.Amount,
                Email: requestBody.Email,
                DepositStatus: "Pending",
                City: requestBody.City,
                DepositID: depositID,
                ErrorMessage: "",
                PaymentLink: "",
                ErrorDate: null,
                Reference: "",
            });

            axios({
                method: 'post',
                url: sparcoKeys.get("QueryPaymentLinkUrl"),
                data: {
                    "transactionName": "Jayben Deposit - Via Checkout Link",
                    "merchantPublicKey": sparcoKeys.get("Public_Key"),
                    "customerFirstName": requestBody.FirstName,
                    "customerPhone": requestBody.PhoneNumber,
                    "customerLastName": requestBody.LastName,
                    "customerEmail": requestBody.Email,
                    "transactionReference": depositID,
                    "currency": requestBody.Currency,
                    "amount": requestBody.Amount,
                },
            }).then(async function (response) {
                console.log(response.data);

                if (response.data.message === "" && !response.data.isError && response.data.paymentUrl !== "") {
                    await db.collection("DepositsViaCheckoutLink").doc(depositID).update({
                        PaymentLink: response.data.paymentUrl,
                        Reference: response.data.reference,
                    });

                    res.status(203).send(response.data.paymentUrl);
                }
            }).catch(async function (error) {
                console.log(error);

                console.log("test point 4");

                await db.collection("DepositsViaCheckoutLink").doc(depositID).update({
                    ErrorMessage: "There was an error: Please check cloud function logs at ErrorDate timestamp, Justine.",
                    ErrorDate: admin.firestore.FieldValue.serverTimestamp(),
                    DepositStatus: "Failed",
                });

                res.status(407).send("Failed");
            });

            console.log("test point 5");
        };

        try {
            await requestPaymentLink(requestBody);
        } catch (e) {
            console.log(e);

            res.status(400).send("failed");
        }
    });

    // ======================= 

    // VERSION 1 - this is acts as a sparco webhoook caller to detect deposits via mobile money when sparco doesn't call our webhook
    app.post('/v1/deposit/checkout/sparco/sparco_webhook/manual/call', async (req, res) => {
        /*
        body preview payload: 
            {
                "deposit_id": string,
                "user_id": 1.035,
            }
        */

        const payload = req.body;

        console.log(payload);

        // gets the sparco docyument that stores the api keys
        const sparcoKeys = await db.collection("Admin").doc("Legal").collection("Sparco").doc("Keys").get();

        // gets the public supabase keys document
        const supabase_keys = await db.collection("Admin").doc("Legal").collection("Supabase").doc("keys").get();

        console.log("test point 1");

        // sends a referral commission to the user's referrer 
        const payReferrerCommission = async (depositDoc, userDoc) => {
            // gets the public admin document that stores the app settings
            const adminDoc = await db.collection("Admin").doc("Legal").get();

            if (adminDoc.get("PayReferrers")) {
                // gets the referrer's user document
                const referrersDoc = await db.collection("Users").where("Username_searchable", "==", userDoc.get("ReferralCode").toLowerCase()).get();

                // calculates the referral commission amount
                const amount_calculated = depositDoc.get("Amount") * (adminDoc.get("ReferrerCommissionPercentage") / 100);

                const commissionAmount = amount_calculated.toFixed(2);

                // parses the commissionAmount into a float from string
                const commission_float = parseFloat(commissionAmount.toString());

                // if the referrer exists and if both the referrer and depositer have the same currency
                if (referrersDoc.docs.length != 0 && userDoc.get("Currency") === referrersDoc.docs[0].get("Currency")) {
                    // 1). adds the commission to the referrer's wallet balance
                    // 2). sends the referrer a commission notification
                    // 3). records the payment in the admin metrics document
                    await Promise.all([
                        db.collection("Users").doc(referrersDoc.docs[0].id).update({
                            Balance: admin.firestore.FieldValue.increment(commission_float),
                        }),
                        admin.messaging().sendToDevice(
                            referrersDoc.docs[0].get("NotificationToken"), {
                            notification: {
                                body: `You have been paid! 😏💰 ${userDoc.get("Currency")} ${commission_float} has been deposited into your wallet. Share this on whatsapp, refer more friends & keep up the good work 💪`,
                                icon: "@drawable/ic_stat_jayben_logo_1_044317_copy_3",
                                clickAction: "FLUTTER_NOTIFICATION_CLICK",
                                title: "Referral Commission Paid 💰",
                            },
                            data: {
                                UserID: "",
                            },
                        }),
                        db.collection("Admin").doc("Metrics").update({
                            TotalReferralCommissionsPaidInKwacha: admin.firestore.FieldValue.increment(commission_float),
                            TotalNumberOfReferralCommissionsPaid: admin.firestore.FieldValue.increment(1),
                        }),
                    ]);

                    // gets the public supabase keys document
                    const supabase_keys = await db.collection("Admin").doc("Legal").collection("Supabase").doc("keys").get();

                    const commission_id = uuidv4();

                    // creates a new row that stores the referral commission's details
                    await axios({
                        "method": "post",
                        url: "https://srfjzsqimfuomlmjixsu.supabase.co/functions/v1/general_functions",
                        headers: {
                            "Authorization": `Bearer ${supabase_keys.get("anon_key")}`,
                            "Content-Type": "application/json",
                        },
                        data: JSON.stringify({
                            "request_type": "create_update_row_record",
                            "operation_type": "create_row",
                            "table_name": "transactions",
                            "data": {
                                "comment": "",
                                "is_public": false,
                                "number_of_views": 0,
                                "number_of_likes": 0,
                                "attended_to": false,
                                "status": "Completed",
                                "number_of_replies": 0,
                                "currency_symbol": "K",
                                "amount": commission_float,
                                "p2p_sender_details": null,
                                "withdrawal_details": null,
                                "sent_received": "Received",
                                "p2p_recipient_details": null,
                                "transaction_type": "Deposit",
                                "method": "Referral Commission",
                                "transaction_id": commission_id,
                                "savings_account_details": null,
                                "transaction_fee_details": null,
                                "user_id": referrersDoc.docs[0].id,
                                "country": referrersDoc.docs[0].get("Country"),
                                "currency": referrersDoc.docs[0].get("Currency"),
                                "user_is_verified": referrersDoc.docs[0].get("isVerified"),
                                "description": `From Transaction ${depositDoc.get("DepositID")}`,
                                "deposit_details": {
                                    "provider": "Jayben",
                                    "deposit_method": "Wallet Deposit",
                                    "charge_depositer_the_deposit_fee_from_provider": null,
                                },
                                "full_names": `${referrersDoc.docs[0].get("FirstName")} ${referrersDoc.docs[0].get("LastName")}`,
                                "wallet_balance_details": {
                                    "wallet_balance_after_transaction": referrersDoc.docs[0].get("Balance") + commission_float,
                                    "wallet_balance_before_transaction": referrersDoc.docs[0].get("Balance"),
                                    "rule": "balance after must be larger than balance before",
                                    "wallet_balances_difference": commission_float,
                                    "transaction_fee_amount": null,
                                },
                            },
                        }),
                    }).then(async function (response) {
                        console.log("The supabase API was called successfully");
                    }).catch(async function (error) {
                        console.log(error);
                        console.log(`There was an error: trying to create a new referral_commission_transactions row in supabase`);
                    });

                    // "table_name": "referral_commission_transactions",
                    // "operation_type": "create_row",
                    // "data": {
                    //     "comment": "",
                    //     "is_public": false,
                    //     "attended_to": false,
                    //     "status": "Completed",
                    //     "currency_symbol": "K",
                    //     "amount": commission_float,
                    //     "sent_received": "Received",
                    //     "transaction_type": "Deposit",
                    //     "method": "Referral Commission",
                    //     "description": "Paid To Wallet",
                    //     "user_id": referrersDoc.docs[0].id,
                    //     "transaction_id": depositDoc.get("DepositID"),
                    //     "country": referrersDoc.docs[0].get("Country"),
                    //     "currency": referrersDoc.docs[0].get("Currency"),
                    //     "user_is_verified": referrersDoc.docs[0].get("isVerified"),
                    //     "wallet_balance_details": {
                    //         "wallet_balances_difference": commission_float,
                    //         "wallet_balance_before_transaction": referrersDoc.docs[0].get("Balance"),
                    //         "wallet_balance_after_transaction": referrersDoc.docs[0].get("Balance") + commission_float,
                    //     },
                    //     "full_names": `${referrersDoc.docs[0].get("FirstName")} ${referrersDoc.docs[0].get("LastName")}`,
                    // },
                }
            }
        };

        // checks if the mobile money payment was successful
        const completeMobileMoneyDeposit = async () => {
            // stores the depositID
            const depositID = payload.deposit_id.replace(" ", "");

            const userID = payload.user_id;

            // gets the user's document
            const depositDoc = await db.collection("Users").doc(userID).collection("Deposits_v2").doc(depositID).get();

            // stores the transaction amount
            const amount = depositDoc.get("Amount");

            // gets the depositer's user document
            const userDoc = await db.collection("Users").doc(depositDoc.get("UserID")).get();

            // calls the sparco api to query the transaction and confirm it has been successful
            await axios({
                method: 'get',
                url: `${sparcoKeys.get("QueryTransactionURL")}?reference=${depositDoc.get("Reference")}&merchantReference=${depositDoc.get("MerchantReference")}`,
                headers: {
                    "token": jwt.sign(
                        JSON.stringify(
                            {
                                "pubKey": sparcoKeys.get("Public_Key"),
                            },
                        ),
                        sparcoKeys.get("Secret_Key"),
                    ),
                },
            }).then(async function (response) {
                console.log("Test point 2");
                if (response.data.status == "TXN_AUTH_SUCCESSFUL" &&
                    depositDoc.get("DepositStatus") == "Pending") {
                    console.log("Test point 3");

                    console.log("PPAAAAAAAAAAAAAAAAAAAID USING MOBILE MONEY & THE WEEBHOOK BOSSSSSSS");

                    const total_amount_ever_deposted = amount + userDoc.get("TotalAmountEverDeposted");

                    const number_of_total_deposits_made = userDoc.get("NumberOfWalletDepositsEverMade") + 1;

                    await db.collection("Users").doc(userID).collection("Deposits_v2").doc(depositID).update({
                        DateAndTimeCompleted: admin.firestore.FieldValue.serverTimestamp(),
                        DepositStatus: "Successful",
                    });

                    // creates a transaction record in supabase
                    await axios({
                        "method": "post",
                        url: "https://srfjzsqimfuomlmjixsu.supabase.co/functions/v1/general_functions",
                        headers: {
                            "Authorization": `Bearer ${supabase_keys.get("anon_key")}`,
                            "Content-Type": "application/json",
                        },
                        data: JSON.stringify({
                            "request_type": "create_update_row_record",
                            "operation_type": "create_row",
                            "table_name": "transactions",
                            "data": {
                                "comment": "",
                                "user_id": userID,
                                "is_public": false,
                                "number_of_views": 0,
                                "number_of_likes": 0,
                                "attended_to": false,
                                "status": "Completed",
                                "number_of_replies": 0,
                                "currency_symbol": "K",
                                "method": "Mobile Money",
                                "p2p_sender_details": null,
                                "withdrawal_details": null,
                                "sent_received": "Received",
                                "transaction_id": depositID,
                                "transaction_type": "Deposit",
                                "p2p_recipient_details": null,
                                "savings_account_details": null,
                                "transaction_fee_details": null,
                                "country": userDoc.get("Country"),
                                "amount": depositDoc.get("Amount"),
                                "currency": depositDoc.get("Currency"),
                                "user_is_verified": userDoc.get("isVerified"),
                                "description": `From ${depositDoc.get("PhoneNumber")}`,
                                "deposit_details": {
                                    "provider": "Sparco",
                                    "deposit_method": "Mobile Money",
                                    "charge_depositer_the_deposit_fee_from_provider": false,
                                },
                                "full_names": `${depositDoc.get("FirstName")} ${depositDoc.get("LastName")}`,
                                "wallet_balance_details": {
                                    "wallet_balance_after_transaction": userDoc.get("Balance") + depositDoc.get("Amount"),
                                    "wallet_balance_before_transaction": userDoc.get("Balance"),
                                    "rule": "balance after must be larger than balance before",
                                    "wallet_balances_difference": depositDoc.get("Amount"),
                                    "transaction_fee_amount": null,
                                },
                            },
                        }),
                    }).then(async function (response) {
                        console.log("The supabase API was called successfully");
                    }).catch(async function (error) {
                        console.log(error);
                        console.log(`There was an error: trying to create a new referral_commission_transactions row in supabase`);
                    });

                    // 1). Credits teh client's wallet balance
                    // 2). Creates a wallet balance track record
                    // 3). Marks the deposit as successful in the deposits collection
                    // 4). Sends deposit completion notification to the user
                    // 5). Creates a transaction record for the user that they can see in the app
                    // 6). records the deposit to the admin metrics
                    // 7). 
                    await Promise.all([
                        db.collection("Admin").doc("Metrics").update({
                            dailyDepositsTotalProcessed: admin.firestore.FieldValue.increment(depositDoc.get("Amount")),
                            totalUserBalances: admin.firestore.FieldValue.increment(depositDoc.get("Amount")),
                            dailyNumberOfDepositsMade: admin.firestore.FieldValue.increment(1),
                        }),
                        payReferrerCommission(depositDoc, userDoc),
                    ]);

                    // gets benson & justin's user document
                    const justins_user_document = await db.collection("Users").doc("ONQUtMhhrRQS82CJBYzppRcIeqr2").get();
                    const bensons_user_document = await db.collection("Users").doc("8nYSYEXEEmYb8KYa61wRZrHseGv2").get();

                    // sends Justin a new deposit alert
                    admin.messaging().sendToDevice(
                        [justins_user_document.get("NotificationToken"), bensons_user_document.get("NotificationToken")], {
                        notification: {
                            title: "New User Deposit Made 💰",
                            body: `Jayben has received a new user deposit of ${userDoc.get("Currency")} ${amount}`,
                            icon: "@drawable/ic_stat_jayben_logo_1_044317_copy_3",
                            clickAction: "FLUTTER_NOTIFICATION_CLICK",
                        },
                        data: {
                            UserID: "",
                        },
                    });

                    console.log("Test point 4");

                    await admin.messaging().sendToDevice(
                        userDoc.get("NotificationToken"), {
                        notification: {
                            title: "Deposit Successful 💰",
                            body: `Your deposit of ${userDoc.get("Currency")} ${amount} to your wallet via ${depositDoc.get("DepositMethod")} was successful!`,
                            icon: "@drawable/ic_stat_jayben_logo_1_044317_copy_3",
                            clickAction: "FLUTTER_NOTIFICATION_CLICK",
                        },
                        data: {
                            UserID: "",
                        },
                    });

                    await db.collection("Users").doc(userID).update({
                        NumberOfWalletDepositsEverMade: number_of_total_deposits_made,
                        Balance: admin.firestore.FieldValue.increment(amount),
                        TotalAmountEverDeposted: total_amount_ever_deposted,
                    });

                    console.log("Payment was made and processed successfully boss.");
                } else if (response.data.status == "TXN_AUTH_UNSUCCESSFUL" &&
                    depositDoc.get("DepositStatus") == "Pending") {
                    await db.collection("Users").doc(userID).collection("Deposits_v2").doc(depositID).update({
                        DateAndTimeCompleted: admin.firestore.FieldValue.serverTimestamp(),
                        DepositStatus: "Failed",
                        ErrorMessage: "Failed",
                    });

                    await admin.messaging().sendToDevice(
                        userDoc.get("NotificationToken"), {
                        notification: {
                            title: "Deposit Failed",
                            body: 'Your most recent deposit failed. Please try again. If the problem persists, kindly contact support.',
                            icon: "@drawable/ic_stat_jayben_logo_1_044317_copy_3",
                            clickAction: "FLUTTER_NOTIFICATION_CLICK",
                        },
                        data: {
                            UserID: "",
                        },
                    });
                    // send notification

                    console.log("FFFAAAAAAAAAAAAAAAAAAAAILED USING MOBILE MONEY & THE WEEBHOOK BOSSSSSSS.......");
                }

                res.status(200).send("Success");
            });
        };

        try {
            await completeMobileMoneyDeposit();
        } catch (e) {
            console.log(e);

            res.status(400).send("Failed");
        }
    });

    // this is acts as a sparco webhoook caller to detect deposits via mobile money when sparco doesn't call our webhook
    app.post('/v2/deposit/checkout/sparco/sparco_webhook/manual/call', async (req, res) => {
        /*
        body preview payload: 
            {
                "deposit_id": string,
                "user_id": 1.035,
            }
        */

        const payload = req.body;

        console.log(payload);

        // gets the sparco docyument that stores the api keys
        const sparcoKeys = await db.collection("Admin").doc("Legal").collection("Sparco").doc("Keys").get();

        // gets the public supabase keys document
        const supabase_keys = await db.collection("Admin").doc("Legal").collection("Supabase").doc("keys").get();

        console.log("test point 1");

        // sends a referral commission to the user's referrer 
        const payReferrerCommission = async (depositDoc, userDoc) => {
            // gets the public admin document that stores the app settings
            const adminDoc = await db.collection("Admin").doc("Legal").get();

            if (adminDoc.get("PayReferrers")) {
                // gets the referrer's user document
                const referrersDoc = await db.collection("Users").where("Username_searchable", "==", userDoc.get("ReferralCode").toLowerCase()).get();

                // calculates the referral commission amount
                const amount_calculated = depositDoc.get("Amount") * (adminDoc.get("ReferrerCommissionPercentage") / 100);

                const commissionAmount = amount_calculated.toFixed(2);

                // parses the commissionAmount into a float from string
                const commission_float = parseFloat(commissionAmount.toString());

                // if the referrer exists and if both the referrer and depositer have the same currency
                if (referrersDoc.docs.length != 0 && userDoc.get("Currency") === referrersDoc.docs[0].get("Currency")) {
                    // 1). adds the commission to the referrer's wallet balance
                    // 2). sends the referrer a commission notification
                    // 3). records the payment in the admin metrics document
                    await Promise.all([
                        db.collection("Users").doc(referrersDoc.docs[0].id).update({
                            Balance: admin.firestore.FieldValue.increment(commission_float),
                        }),
                        admin.messaging().sendToDevice(
                            referrersDoc.docs[0].get("NotificationToken"), {
                            notification: {
                                body: `You have been paid! 😏💰 ${userDoc.get("Currency")} ${commission_float} has been deposited into your wallet. Share this on whatsapp, refer more friends & keep up the good work 💪`,
                                icon: "@drawable/ic_stat_jayben_logo_1_044317_copy_3",
                                clickAction: "FLUTTER_NOTIFICATION_CLICK",
                                title: "Referral Commission Paid 💰",
                            },
                            data: {
                                UserID: "",
                            },
                        }),
                        db.collection("Admin").doc("Metrics").update({
                            TotalReferralCommissionsPaidInKwacha: admin.firestore.FieldValue.increment(commission_float),
                            TotalNumberOfReferralCommissionsPaid: admin.firestore.FieldValue.increment(1),
                        }),
                    ]);

                    // gets the public supabase keys document
                    const supabase_keys = await db.collection("Admin").doc("Legal").collection("Supabase").doc("keys").get();

                    const commission_id = uuidv4();

                    // creates a new row that stores the referral commission's details
                    await axios({
                        "method": "post",
                        url: "https://srfjzsqimfuomlmjixsu.supabase.co/functions/v1/general_functions",
                        headers: {
                            "Authorization": `Bearer ${supabase_keys.get("anon_key")}`,
                            "Content-Type": "application/json",
                        },
                        data: JSON.stringify({
                            "request_type": "create_update_row_record",
                            "operation_type": "create_row",
                            "table_name": "transactions",
                            "data": {
                                "comment": "",
                                "is_public": false,
                                "number_of_views": 0,
                                "number_of_likes": 0,
                                "attended_to": false,
                                "status": "Completed",
                                "number_of_replies": 0,
                                "currency_symbol": "K",
                                "amount": commission_float,
                                "p2p_sender_details": null,
                                "withdrawal_details": null,
                                "sent_received": "Received",
                                "p2p_recipient_details": null,
                                "transaction_type": "Deposit",
                                "method": "Referral Commission",
                                "transaction_id": commission_id,
                                "savings_account_details": null,
                                "transaction_fee_details": null,
                                "user_id": referrersDoc.docs[0].id,
                                "country": referrersDoc.docs[0].get("Country"),
                                "currency": referrersDoc.docs[0].get("Currency"),
                                "user_is_verified": referrersDoc.docs[0].get("isVerified"),
                                "description": `From Transaction ${depositDoc.get("DepositID")}`,
                                "deposit_details": {
                                    "provider": "Jayben",
                                    "deposit_method": "Wallet Deposit",
                                    "charge_depositer_the_deposit_fee_from_provider": null,
                                },
                                "full_names": `${referrersDoc.docs[0].get("FirstName")} ${referrersDoc.docs[0].get("LastName")}`,
                                "wallet_balance_details": {
                                    "wallet_balance_after_transaction": referrersDoc.docs[0].get("Balance") + commission_float,
                                    "wallet_balance_before_transaction": referrersDoc.docs[0].get("Balance"),
                                    "rule": "balance after must be larger than balance before",
                                    "wallet_balances_difference": commission_float,
                                    "transaction_fee_amount": null,
                                },
                            },
                        }),
                    }).then(async function (response) {
                        console.log("The supabase API was called successfully");
                    }).catch(async function (error) {
                        console.log(error);
                        console.log(`There was an error: trying to create a new referral_commission_transactions row in supabase`);
                    });

                    // "table_name": "referral_commission_transactions",
                    // "operation_type": "create_row",
                    // "data": {
                    //     "comment": "",
                    //     "is_public": false,
                    //     "attended_to": false,
                    //     "status": "Completed",
                    //     "currency_symbol": "K",
                    //     "amount": commission_float,
                    //     "sent_received": "Received",
                    //     "transaction_type": "Deposit",
                    //     "method": "Referral Commission",
                    //     "description": "Paid To Wallet",
                    //     "user_id": referrersDoc.docs[0].id,
                    //     "transaction_id": depositDoc.get("DepositID"),
                    //     "country": referrersDoc.docs[0].get("Country"),
                    //     "currency": referrersDoc.docs[0].get("Currency"),
                    //     "user_is_verified": referrersDoc.docs[0].get("isVerified"),
                    //     "wallet_balance_details": {
                    //         "wallet_balances_difference": commission_float,
                    //         "wallet_balance_before_transaction": referrersDoc.docs[0].get("Balance"),
                    //         "wallet_balance_after_transaction": referrersDoc.docs[0].get("Balance") + commission_float,
                    //     },
                    //     "full_names": `${referrersDoc.docs[0].get("FirstName")} ${referrersDoc.docs[0].get("LastName")}`,
                    // },
                }
            }
        };

        // checks if the mobile money payment was successful
        const completeMobileMoneyDeposit = async () => {
            // stores the depositID
            const depositID = payload.deposit_id.replace(" ", "");

            const userID = payload.user_id;

            // gets the user's document
            const depositDoc = await db.collection("DepositsViaMobileMoney").doc(depositID).get();

            // stores the transaction amount
            const amount = depositDoc.get("Amount");

            // gets the depositer's user document
            const userDoc = await db.collection("Users").doc(depositDoc.get("UserID")).get();

            // calls the sparco api to query the transaction and confirm it has been successful
            await axios({
                method: 'get',
                url: `${sparcoKeys.get("QueryTransactionURL")}?reference=${depositDoc.get("Reference")}&merchantReference=${depositDoc.get("MerchantReference")}`,
                headers: {
                    "token": jwt.sign(
                        JSON.stringify(
                            {
                                "pubKey": sparcoKeys.get("Public_Key"),
                            },
                        ),
                        sparcoKeys.get("Secret_Key"),
                    ),
                },
            }).then(async function (response) {
                console.log("Test point 2");
                if (response.data.status == "TXN_AUTH_SUCCESSFUL" &&
                    depositDoc.get("DepositStatus") == "Pending") {
                    console.log("Test point 3");

                    console.log("PPAAAAAAAAAAAAAAAAAAAID USING MOBILE MONEY & THE WEEBHOOK BOSSSSSSS");

                    const total_amount_ever_deposted = amount + userDoc.get("TotalAmountEverDeposted");

                    const number_of_total_deposits_made = userDoc.get("NumberOfWalletDepositsEverMade") + 1;

                    await db.collection("DepositsViaMobileMoney").doc(depositID).update({
                        DateAndTimeCompleted: admin.firestore.FieldValue.serverTimestamp(),
                        DepositStatus: "Successful",
                    });

                    // creates a transaction record in supabase
                    await axios({
                        "method": "post",
                        url: "https://srfjzsqimfuomlmjixsu.supabase.co/functions/v1/general_functions",
                        headers: {
                            "Authorization": `Bearer ${supabase_keys.get("anon_key")}`,
                            "Content-Type": "application/json",
                        },
                        data: JSON.stringify({
                            "request_type": "create_update_row_record",
                            "operation_type": "create_row",
                            "table_name": "transactions",
                            "data": {
                                "comment": "",
                                "user_id": userID,
                                "is_public": false,
                                "number_of_views": 0,
                                "number_of_likes": 0,
                                "attended_to": false,
                                "status": "Completed",
                                "number_of_replies": 0,
                                "currency_symbol": "K",
                                "method": "Mobile Money",
                                "p2p_sender_details": null,
                                "withdrawal_details": null,
                                "sent_received": "Received",
                                "transaction_id": depositID,
                                "transaction_type": "Deposit",
                                "p2p_recipient_details": null,
                                "savings_account_details": null,
                                "transaction_fee_details": null,
                                "country": userDoc.get("Country"),
                                "amount": depositDoc.get("Amount"),
                                "currency": depositDoc.get("Currency"),
                                "user_is_verified": userDoc.get("isVerified"),
                                "description": `From ${depositDoc.get("PhoneNumber")}`,
                                "deposit_details": {
                                    "provider": "Sparco",
                                    "deposit_method": "Mobile Money",
                                    "charge_depositer_the_deposit_fee_from_provider": false,
                                },
                                "full_names": `${depositDoc.get("FirstName")} ${depositDoc.get("LastName")}`,
                                "wallet_balance_details": {
                                    "wallet_balance_after_transaction": userDoc.get("Balance") + depositDoc.get("Amount"),
                                    "wallet_balance_before_transaction": userDoc.get("Balance"),
                                    "rule": "balance after must be larger than balance before",
                                    "wallet_balances_difference": depositDoc.get("Amount"),
                                    "transaction_fee_amount": null,
                                },
                            },
                        }),
                    }).then(async function (response) {
                        console.log("The supabase API was called successfully");
                    }).catch(async function (error) {
                        console.log(error);
                        console.log(`There was an error: trying to create a new referral_commission_transactions row in supabase`);
                    });

                    // 1). Credits teh client's wallet balance
                    // 2). Creates a wallet balance track record
                    // 3). Marks the deposit as successful in the deposits collection
                    // 4). Sends deposit completion notification to the user
                    // 5). Creates a transaction record for the user that they can see in the app
                    // 6). records the deposit to the admin metrics
                    // 7). 
                    await Promise.all([
                        db.collection("Admin").doc("Metrics").update({
                            dailyDepositsTotalProcessed: admin.firestore.FieldValue.increment(depositDoc.get("Amount")),
                            totalUserBalances: admin.firestore.FieldValue.increment(depositDoc.get("Amount")),
                            dailyNumberOfDepositsMade: admin.firestore.FieldValue.increment(1),
                        }),
                        payReferrerCommission(depositDoc, userDoc),
                    ]);

                    // gets benson & justin's user document
                    const justins_user_document = await db.collection("Users").doc("ONQUtMhhrRQS82CJBYzppRcIeqr2").get();
                    const bensons_user_document = await db.collection("Users").doc("8nYSYEXEEmYb8KYa61wRZrHseGv2").get();

                    // sends Justin a new deposit alert
                    admin.messaging().sendToDevice(
                        [justins_user_document.get("NotificationToken"), bensons_user_document.get("NotificationToken")], {
                        notification: {
                            title: "New User Deposit Made 💰",
                            body: `Jayben has received a new user deposit of ${userDoc.get("Currency")} ${amount}`,
                            icon: "@drawable/ic_stat_jayben_logo_1_044317_copy_3",
                            clickAction: "FLUTTER_NOTIFICATION_CLICK",
                        },
                        data: {
                            UserID: "",
                        },
                    });

                    console.log("Test point 4");

                    await admin.messaging().sendToDevice(
                        userDoc.get("NotificationToken"), {
                        notification: {
                            title: "Deposit Successful 💰",
                            body: `Your deposit of ${userDoc.get("Currency")} ${amount} to your wallet via ${depositDoc.get("DepositMethod")} was successful!`,
                            icon: "@drawable/ic_stat_jayben_logo_1_044317_copy_3",
                            clickAction: "FLUTTER_NOTIFICATION_CLICK",
                        },
                        data: {
                            UserID: "",
                        },
                    });

                    await db.collection("Users").doc(userID).update({
                        NumberOfWalletDepositsEverMade: number_of_total_deposits_made,
                        Balance: admin.firestore.FieldValue.increment(amount),
                        TotalAmountEverDeposted: total_amount_ever_deposted,
                    });

                    console.log("Payment was made and processed successfully boss.");
                } else if (response.data.status == "TXN_AUTH_UNSUCCESSFUL" &&
                    depositDoc.get("DepositStatus") == "Pending") {
                    await db.collection("DepositsViaMobileMoney").doc(depositID).update({
                        DateAndTimeCompleted: admin.firestore.FieldValue.serverTimestamp(),
                        DepositStatus: "Failed",
                        ErrorMessage: "Failed",
                    });

                    await admin.messaging().sendToDevice(
                        userDoc.get("NotificationToken"), {
                        notification: {
                            title: "Deposit Failed",
                            body: 'Your most recent deposit failed. Please try again. If the problem persists, kindly contact support.',
                            icon: "@drawable/ic_stat_jayben_logo_1_044317_copy_3",
                            clickAction: "FLUTTER_NOTIFICATION_CLICK",
                        },
                        data: {
                            UserID: "",
                        },
                    });
                    // send notification

                    console.log("FFFAAAAAAAAAAAAAAAAAAAAILED USING MOBILE MONEY & THE WEEBHOOK BOSSSSSSS.......");
                }

                res.status(200).send("Success");
            });
        };

        try {
            await completeMobileMoneyDeposit();
        } catch (e) {
            console.log(e);

            res.status(400).send("Failed");
        }
    });

    // gets all the pending deposit requests and creates deposit transaction records for them if they were successful
    app.post('/v1/deposit/checkout/sparco/confirm/manual/call/all', async (req, res) => {
        /*
        body preview payload is empty
            {
            }
        */

        let depositID = "";

        let userID = "";

        // gets all the pending deposit requests
        const all_pending_deposits = await db.collection("DepositsViaMobileMoney").where("DepositStatus", "==", "Pending").get();

        // gets all the pending deposits that have been initiated by users
        // const all_pending_deposit_documents = await db.collection("DepositsViaMobileMoney").where("DepositStatus", "==", "Pending").get();

        // gets the sparco docyument that stores the api keys
        const sparcoKeys = await db.collection("Admin").doc("Legal").collection("Sparco").doc("Keys").get();

        // gets the public supabase keys document
        const supabase_keys = await db.collection("Admin").doc("Legal").collection("Supabase").doc("keys").get();

        console.log("test point 1");

        // sends a referral commission to the user's referrer 
        // const payReferrerCommission = async (depositDoc, userDoc) => {
        //     // gets the public admin document that stores the app settings
        //     const adminDoc = await db.collection("Admin").doc("Legal").get();

        //     if (adminDoc.get("PayReferrers")) {
        //         // gets the referrer's user document
        //         const referrersDoc = await db.collection("Users").where("Username_searchable", "==", userDoc.get("ReferralCode").toLowerCase()).get();

        //         // calculates the referral commission amount
        //         const amount_calculated = depositDoc.get("Amount") * (adminDoc.get("ReferrerCommissionPercentage") / 100);

        //         const commissionAmount = amount_calculated.toFixed(2);

        //         // parses the commissionAmount into a float from string
        //         const commission_float = parseFloat(commissionAmount.toString());

        //         // if the referrer exists and if both the referrer and depositer have the same currency
        //         if (referrersDoc.docs.length != 0 && userDoc.get("Currency") === referrersDoc.docs[0].get("Currency")) {
        //             // 1). adds the commission to the referrer's wallet balance
        //             // 2). sends the referrer a commission notification
        //             // 3). records the payment in the admin metrics document
        //             await Promise.all([
        //                 db.collection("Users").doc(referrersDoc.docs[0].id).update({
        //                     Balance: admin.firestore.FieldValue.increment(commission_float),
        //                 }),
        //                 admin.messaging().sendToDevice(
        //                     referrersDoc.docs[0].get("NotificationToken"), {
        //                     notification: {
        //                         body: `You have been paid! 😏💰 ${userDoc.get("Currency")} ${commission_float} has been deposited into your wallet. Share this on whatsapp, refer more friends & keep up the good work 💪`,
        //                         icon: "@drawable/ic_stat_jayben_logo_1_044317_copy_3",
        //                         clickAction: "FLUTTER_NOTIFICATION_CLICK",
        //                         title: "Referral Commission Paid 💰",
        //                     },
        //                     data: {
        //                         UserID: "",
        //                     },
        //                 }),
        //                 db.collection("Admin").doc("Metrics").update({
        //                     TotalReferralCommissionsPaidInKwacha: admin.firestore.FieldValue.increment(commission_float),
        //                     TotalNumberOfReferralCommissionsPaid: admin.firestore.FieldValue.increment(1),
        //                 }),
        //             ]);

        //             // gets the public supabase keys document
        //             const supabase_keys = await db.collection("Admin").doc("Legal").collection("Supabase").doc("keys").get();

        //             const commission_id = uuidv4();

        //             // creates a new row that stores the referral commission's details
        //             await axios({
        //                 "method": "post",
        //                 url: "https://srfjzsqimfuomlmjixsu.supabase.co/functions/v1/general_functions",
        //                 headers: {
        //                     "Authorization": `Bearer ${supabase_keys.get("anon_key")}`,
        //                     "Content-Type": "application/json",
        //                 },
        //                 data: JSON.stringify({
            //                  "request_type": "create_update_row_record",
        //                     "operation_type": "create_row",
        //                     "table_name": "transactions",
        //                     "data": {
        //                         "comment": "",
        //                         "is_public": false,
        //                         "number_of_views": 0,
        //                         "number_of_likes": 0,
        //                         "attended_to": false,
        //                         "status": "Completed",
        //                         "number_of_replies": 0,
        //                         "currency_symbol": "K",
        //                         "amount": commission_float,
        //                         "p2p_sender_details": null,
        //                         "withdrawal_details": null,
        //                         "sent_received": "Received",
        //                         "p2p_recipient_details": null,
        //                         "transaction_type": "Deposit",
        //                         "method": "Referral Commission",
        //                         "transaction_id": commission_id,
        //                         "savings_account_details": null,
        //                         "transaction_fee_details": null,
        //                         "user_id": referrersDoc.docs[0].id,
        //                         "country": referrersDoc.docs[0].get("Country"),
        //                         "currency": referrersDoc.docs[0].get("Currency"),
        //                         "user_is_verified": referrersDoc.docs[0].get("isVerified"),
        //                         "description": `From Transaction ${depositDoc.get("DepositID")}`,
        //                         "deposit_details": {
        //                             "provider": "Jayben",
        //                             "deposit_method": "Wallet Deposit",
        //                             "charge_depositer_the_deposit_fee_from_provider": null,
        //                         },
        //                         "full_names": `${referrersDoc.docs[0].get("FirstName")} ${referrersDoc.docs[0].get("LastName")}`,
        //                         "wallet_balance_details": {
        //                             "wallet_balance_after_transaction": referrersDoc.docs[0].get("Balance") + commission_float,
        //                             "wallet_balance_before_transaction": referrersDoc.docs[0].get("Balance"),
        //                             "rule": "balance after must be larger than balance before",
        //                             "wallet_balances_difference": commission_float,
        //                             "transaction_fee_amount": null,
        //                         },
        //                     },
        //                 }),
        //             }).then(async function (response) {
        //                 console.log("The supabase API was called successfully");
        //             }).catch(async function (error) {
        //                 console.log(error);
        //                 console.log(`There was an error: trying to create a new referral_commission_transactions row in supabase`);
        //             });

        //             // "table_name": "referral_commission_transactions",
        //             // "operation_type": "create_row",
        //             // "data": {
        //             //     "comment": "",
        //             //     "is_public": false,
        //             //     "attended_to": false,
        //             //     "status": "Completed",
        //             //     "currency_symbol": "K",
        //             //     "amount": commission_float,
        //             //     "sent_received": "Received",
        //             //     "transaction_type": "Deposit",
        //             //     "method": "Referral Commission",
        //             //     "description": "Paid To Wallet",
        //             //     "user_id": referrersDoc.docs[0].id,
        //             //     "transaction_id": depositDoc.get("DepositID"),
        //             //     "country": referrersDoc.docs[0].get("Country"),
        //             //     "currency": referrersDoc.docs[0].get("Currency"),
        //             //     "user_is_verified": referrersDoc.docs[0].get("isVerified"),
        //             //     "wallet_balance_details": {
        //             //         "wallet_balances_difference": commission_float,
        //             //         "wallet_balance_before_transaction": referrersDoc.docs[0].get("Balance"),
        //             //         "wallet_balance_after_transaction": referrersDoc.docs[0].get("Balance") + commission_float,
        //             //     },
        //             //     "full_names": `${referrersDoc.docs[0].get("FirstName")} ${referrersDoc.docs[0].get("LastName")}`,
        //             // },
        //         }
        //     }
        // };

        // checks if the mobile money payment was successful
        const completeMobileMoneyDeposit = async () => {
            // gets the user's document
            const depositDoc = await db.collection("DepositsViaMobileMoney").doc(depositID).get();

            // stores the transaction amount
            // const amount = depositDoc.get("Amount");

            // gets the depositer's user document
            const userDoc = await db.collection("Users").doc(depositDoc.get("UserID")).get();

            // calls the sparco api to query the transaction and confirm it has been successful
            await axios({
                method: 'get',
                url: `${sparcoKeys.get("QueryTransactionURL")}?reference=${depositDoc.get("Reference")}&merchantReference=${depositDoc.get("MerchantReference")}`,
                headers: {
                    "token": jwt.sign(
                        JSON.stringify(
                            {
                                "pubKey": sparcoKeys.get("Public_Key"),
                            },
                        ),
                        sparcoKeys.get("Secret_Key"),
                    ),
                },
            }).then(async function (response) {
                console.log("Test point 2");
                if (response.data.status == "TXN_AUTH_SUCCESSFUL" &&
                    depositDoc.get("DepositStatus") == "Pending") {
                    console.log("Test point 3");

                    console.log("PPAAAAAAAAAAAAAAAAAAAID USING MOBILE MONEY & THE WEEBHOOK BOSSSSSSS");

                    // const total_amount_ever_deposted = amount + userDoc.get("TotalAmountEverDeposted");

                    // const number_of_total_deposits_made = userDoc.get("NumberOfWalletDepositsEverMade") + 1;

                    await db.collection("DepositsViaMobileMoney").doc(depositID).update({
                        DateAndTimeCompleted: admin.firestore.FieldValue.serverTimestamp(),
                        DepositStatus: "Successful",
                    });

                    // creates a transaction record in supabase
                    await axios({
                        "method": "post",
                        url: "https://srfjzsqimfuomlmjixsu.supabase.co/functions/v1/general_functions",
                        headers: {
                            "Authorization": `Bearer ${supabase_keys.get("anon_key")}`,
                            "Content-Type": "application/json",
                        },
                        data: JSON.stringify({
                            "request_type": "create_update_row_record",
                            "operation_type": "create_row",
                            "table_name": "transactions",
                            "data": {
                                "comment": "",
                                "user_id": userID,
                                "is_public": false,
                                "number_of_views": 0,
                                "number_of_likes": 0,
                                "attended_to": false,
                                "status": "Completed",
                                "number_of_replies": 0,
                                "currency_symbol": "K",
                                "method": "Mobile Money",
                                "p2p_sender_details": null,
                                "withdrawal_details": null,
                                "sent_received": "Received",
                                "transaction_id": depositID,
                                "transaction_type": "Deposit",
                                "p2p_recipient_details": null,
                                "savings_account_details": null,
                                "transaction_fee_details": null,
                                "country": userDoc.get("Country"),
                                "amount": depositDoc.get("Amount"),
                                "currency": depositDoc.get("Currency"),
                                "user_is_verified": userDoc.get("isVerified"),
                                "description": `From ${depositDoc.get("PhoneNumber")}`,
                                "deposit_details": {
                                    "provider": "Sparco",
                                    "deposit_method": "Mobile Money",
                                    "charge_depositer_the_deposit_fee_from_provider": false,
                                },
                                "full_names": `${depositDoc.get("FirstName")} ${depositDoc.get("LastName")}`,
                                "wallet_balance_details": {
                                    "wallet_balance_after_transaction": userDoc.get("Balance") + depositDoc.get("Amount"),
                                    "wallet_balance_before_transaction": userDoc.get("Balance"),
                                    "rule": "balance after must be larger than balance before",
                                    "wallet_balances_difference": depositDoc.get("Amount"),
                                    "transaction_fee_amount": null,
                                },
                            },
                        }),
                    }).then(async function (response) {
                        console.log("The supabase API was called successfully");
                    }).catch(async function (error) {
                        console.log(error);
                        console.log(`There was an error: trying to create a new referral_commission_transactions row in supabase`);
                    });

                    console.log(`The deposit doc's date created date is `, depositDoc.get("DateCreated").toDate().toISOString());

                    // updates withdrawal row to the original date
                    await axios({
                        "method": "post",
                        url: "https://srfjzsqimfuomlmjixsu.supabase.co/functions/v1/general_functions",
                        headers: {
                            "Authorization": `Bearer ${supabase_keys.get("anon_key")}`,
                            "Content-Type": "application/json",
                        },
                        data: JSON.stringify({
                            "request_type": "create_update_row_record",
                            "primary_column_name": "transaction_id",
                            "operation_type": "update_row",
                            "table_name": "transactions",
                            "row_id": depositID,
                            "data": {
                                "created_at": depositDoc.get("DateCreated").toDate().toISOString(),
                            },
                        }),
                    }).then(async function (response) {
                        console.log("The supabase API update transaction to fraggaed was called successfully", response);
                    }).catch(async function (error) {
                        console.log(`There was an error: trying to update the withdrawal transaction status to flagged row in supabase`);
                        console.log(error);
                    });

                    // creates a record that shows which users have not received money to their balances
                    await db.collection("ManualDepositConfirmations").doc(depositID).set({
                        date_created: depositDoc.get("DateCreated"),
                        has_credited_amount_to_users_bal: false,
                        amount: depositDoc.get("Amount"),
                        deposit_method: "Mobile Money",
                        transaction_id: depositID,
                        user_id: userID,
                    });

                    // 1). Credits teh client's wallet balance
                    // 2). Creates a wallet balance track record
                    // 3). Marks the deposit as successful in the deposits collection
                    // 4). Sends deposit completion notification to the user
                    // 5). Creates a transaction record for the user that they can see in the app
                    // 6). records the deposit to the admin metrics
                    // 7). 
                    // await Promise.all([
                    //     db.collection("Admin").doc("Metrics").update({
                    //         dailyDepositsTotalProcessed: admin.firestore.FieldValue.increment(depositDoc.get("Amount")),
                    //         totalUserBalances: admin.firestore.FieldValue.increment(depositDoc.get("Amount")),
                    //         dailyNumberOfDepositsMade: admin.firestore.FieldValue.increment(1),
                    //     }),
                    //     payReferrerCommission(depositDoc, userDoc),
                    // ]);

                    // // gets benson & justin's user document
                    // const justins_user_document = await db.collection("Users").doc("ONQUtMhhrRQS82CJBYzppRcIeqr2").get();
                    // const bensons_user_document = await db.collection("Users").doc("8nYSYEXEEmYb8KYa61wRZrHseGv2").get();

                    // // sends Justin a new deposit alert
                    // admin.messaging().sendToDevice(
                    //     [justins_user_document.get("NotificationToken"), bensons_user_document.get("NotificationToken")], {
                    //     notification: {
                    //         title: "New User Deposit Made 💰",
                    //         body: `Jayben has received a new user deposit of ${userDoc.get("Currency")} ${amount}`,
                    //         icon: "@drawable/ic_stat_jayben_logo_1_044317_copy_3",
                    //         clickAction: "FLUTTER_NOTIFICATION_CLICK",
                    //     },
                    //     data: {
                    //         UserID: "",
                    //     },
                    // });

                    console.log("Test point 4");

                    // await admin.messaging().sendToDevice(
                    //     userDoc.get("NotificationToken"), {
                    //     notification: {
                    //         title: "Deposit Successful 💰",
                    //         body: `Your deposit of ${userDoc.get("Currency")} ${amount} to your wallet via ${depositDoc.get("DepositMethod")} was successful!`,
                    //         icon: "@drawable/ic_stat_jayben_logo_1_044317_copy_3",
                    //         clickAction: "FLUTTER_NOTIFICATION_CLICK",
                    //     },
                    //     data: {
                    //         UserID: "",
                    //     },
                    // });

                    // await db.collection("Users").doc(userID).update({
                    //     NumberOfWalletDepositsEverMade: number_of_total_deposits_made,
                    //     Balance: admin.firestore.FieldValue.increment(amount),
                    //     TotalAmountEverDeposted: total_amount_ever_deposted,
                    // });

                    console.log("Payment was made and processed successfully boss.");
                } else if (response.data.status == "TXN_AUTH_UNSUCCESSFUL" &&
                    depositDoc.get("DepositStatus") == "Pending") {
                    // marks the deposit request as failed
                    await db.collection("DepositsViaMobileMoney").doc(depositID).update({
                        DateAndTimeCompleted: admin.firestore.FieldValue.serverTimestamp(),
                        DepositStatus: "Failed",
                        ErrorMessage: "Failed",
                    });

                    // await admin.messaging().sendToDevice(
                    //     userDoc.get("NotificationToken"), {
                    //     notification: {
                    //         title: "Deposit Failed",
                    //         body: 'Your most recent deposit failed. Please try again. If the problem persists, kindly contact support.',
                    //         icon: "@drawable/ic_stat_jayben_logo_1_044317_copy_3",
                    //         clickAction: "FLUTTER_NOTIFICATION_CLICK",
                    //     },
                    //     data: {
                    //         UserID: "",
                    //     },
                    // });
                    // send notification

                    console.log("FFFAAAAAAAAAAAAAAAAAAAAILED USING MOBILE MONEY & THE WEEBHOOK BOSSSSSSS.......");
                }
            });
        };

        try {
            for (let i = 0; i < all_pending_deposits.docs.length; i++) {
                depositID = all_pending_deposits.docs[i].get("DepositID");

                userID = all_pending_deposits.docs[i].get("UserID");

                await completeMobileMoneyDeposit();
            }

            res.status(200).send("Success");
        } catch (e) {
            console.log(e);

            res.status(400).send("Failed");
        }
    });

    // confirms deposit & then creates only a missing deposit record for successful payments
    app.post('/v1/deposit/mobile_money/sparco/sparco_webhook/manual/call/only_create_deposit_record', async (req, res) => {
        /*
        body preview payload: 
            {
                "deposit_id": string,
                "user_id": 1.035,
            }
        */

        const payload = req.body;

        console.log(payload);

        // gets the sparco docyument that stores the api keys
        const sparcoKeys = await db.collection("Admin").doc("Legal").collection("Sparco").doc("Keys").get();

        // gets the public supabase keys document
        const supabase_keys = await db.collection("Admin").doc("Legal").collection("Supabase").doc("keys").get();

        console.log("test point 1");

        // checks if the mobile money payment was successful
        const completeMobileMoneyDeposit = async () => {
            // stores the depositID
            const depositID = payload.deposit_id.replace(" ", "");

            const userID = payload.user_id;

            // gets the user's document
            const depositDoc = await db.collection("DepositsViaMobileMoney").doc(depositID).get();

            // gets the depositer's user document
            const userDoc = await db.collection("Users").doc(depositDoc.get("UserID")).get();

            // calls the sparco api to query the transaction and confirm it has been successful
            await axios({
                method: 'get',
                url: `${sparcoKeys.get("QueryTransactionURL")}?reference=${depositDoc.get("Reference")}&merchantReference=${depositDoc.get("MerchantReference")}`,
                headers: {
                    "token": jwt.sign(
                        JSON.stringify(
                            {
                                "pubKey": sparcoKeys.get("Public_Key"),
                            },
                        ),
                        sparcoKeys.get("Secret_Key"),
                    ),
                },
            }).then(async function (response) {
                console.log("Test point 2");
                if (response.data.status == "TXN_AUTH_SUCCESSFUL") {
                    console.log("Test point 3");

                    console.log("Payment was successful & deposit record is now being the created");

                    // creates a transaction record in supabase
                    await axios({
                        "method": "post",
                        url: "https://srfjzsqimfuomlmjixsu.supabase.co/functions/v1/general_functions",
                        headers: {
                            "Authorization": `Bearer ${supabase_keys.get("anon_key")}`,
                            "Content-Type": "application/json",
                        },
                        data: JSON.stringify({
                            "request_type": "create_update_row_record",
                            "operation_type": "create_row",
                            "table_name": "transactions",
                            "data": {
                                "comment": "",
                                "user_id": userID,
                                "is_public": false,
                                "number_of_views": 0,
                                "number_of_likes": 0,
                                "attended_to": false,
                                "status": "Completed",
                                "number_of_replies": 0,
                                "currency_symbol": "K",
                                "method": "Mobile Money",
                                "p2p_sender_details": null,
                                "withdrawal_details": null,
                                "sent_received": "Received",
                                "transaction_id": depositID,
                                "transaction_type": "Deposit",
                                "p2p_recipient_details": null,
                                "savings_account_details": null,
                                "transaction_fee_details": null,
                                "country": userDoc.get("Country"),
                                "amount": depositDoc.get("Amount"),
                                "currency": depositDoc.get("Currency"),
                                "user_is_verified": userDoc.get("isVerified"),
                                "description": `From ${depositDoc.get("PhoneNumber")}`,
                                "created_at": depositDoc.get("DateCreated").toDate().toISOString(),
                                "deposit_details": {
                                    "provider": "Sparco",
                                    "deposit_method": "Mobile Money",
                                    "charge_depositer_the_deposit_fee_from_provider": false,
                                },
                                "full_names": `${depositDoc.get("FirstName")} ${depositDoc.get("LastName")}`,
                                "wallet_balance_details": {
                                    "wallet_balance_after_transaction": userDoc.get("Balance") + depositDoc.get("Amount"),
                                    "wallet_balance_before_transaction": userDoc.get("Balance"),
                                    "rule": "balance after must be larger than balance before",
                                    "wallet_balances_difference": depositDoc.get("Amount"),
                                    "transaction_fee_amount": null,
                                },
                            },
                        }),
                    }).then(async function (response) {
                        console.log("The supabase API was called successfully - deposit record has been created boss");
                    }).catch(async function (error) {
                        console.log(error);
                        console.log(`There was an error: trying to create a new deposit row in supabase`);
                    });

                    console.log("The payment has been confirmed and the deposit record has been created successfully boss.");

                    res.status(200).send("Success - Payment was successful & a deposit record has been created boss");
                } else if (response.data.status == "TXN_AUTH_UNSUCCESSFUL") {
                    console.log("The payment was confirmed and had NOT gone through boss");

                    res.status(200).send("Success - Deposit record NOT created because payment was unsuccessful boss");
                }
            });
        };

        try {
            await completeMobileMoneyDeposit();
        } catch (e) {
            console.log(e);

            res.status(400).send("Failed");
        }
    });

    // creates a deposit record from scratch without confirming anything
    app.post('/v1/deposit/mobile_money/create_missing_deposit_from_scratch_without_confirming_with_gateway', async (req, res) => {
        /*
        body preview payload: 
            {
                "created_at": "2023-10-22T06:53:11.000",
                "wallet_balance_before_transaction": ,
                "wallet_balance_after_transaction": , 
                "amount": double,
                "user_id": text,
            }
        */

        const payload = req.body;

        // gets the public supabase keys document
        const supabase_keys = await db.collection("Admin").doc("Legal").collection("Supabase").doc("keys").get();

        console.log("test point 1");

        // checks if the mobile money payment was successful
        const createDepositRecord = async () => {
            // creates a new deposit id
            const depositID = uuidv4();

            const userID = payload.user_id;

            // gets the depositer's user document
            const userDoc = await db.collection("Users").doc(userID).get();

            /*
                when it comes to creation codes, these help keep track of who created
                the deposit records. Justin's record is Justo31925. Any other codes entered
                are from thaddeus, or anybody else who has access to this api code to call it
            */

            // creates a transaction record in supabase
            await axios({
                "method": "post",
                url: "https://srfjzsqimfuomlmjixsu.supabase.co/functions/v1/general_functions",
                headers: {
                    "Authorization": `Bearer ${supabase_keys.get("anon_key")}`,
                    "Content-Type": "application/json",
                },
                data: JSON.stringify({
                    "request_type": "create_update_row_record",
                    "operation_type": "create_row",
                    "table_name": "transactions",
                    "data": {
                        "comment": "",
                        "user_id": userID,
                        "is_public": false,
                        "number_of_views": 0,
                        "number_of_likes": 0,
                        "attended_to": false,
                        "status": "Completed",
                        "number_of_replies": 0,
                        "currency_symbol": "K",
                        "method": "Mobile Money",
                        "amount": payload.amount,
                        "p2p_sender_details": null,
                        "withdrawal_details": null,
                        "sent_received": "Received",
                        "transaction_id": depositID,
                        "transaction_type": "Deposit",
                        "p2p_recipient_details": null,
                        "savings_account_details": null,
                        "transaction_fee_details": null,
                        "created_at": payload.created_at,
                        "country": userDoc.get("Country"),
                        "currency": userDoc.get("Currency"),
                        "user_is_verified": userDoc.get("isVerified"),
                        "deposit_details": {
                            "provider": "Sparco",
                            "manually_created": true,
                            "deposit_method": "Mobile Money",
                            "manually_created_by": payload.creation_code,
                            "manuaally_created_date": new Date().toISOString(),
                            "charge_depositer_the_deposit_fee_from_provider": false,
                        },
                        "full_names": `${userDoc.get("FirstName")} ${userDoc.get("LastName")}`,
                        "description": `From ${userDoc.get("PhoneNumber").replace("+26", "")}`,
                        "wallet_balance_details": {
                            "wallet_balance_after_transaction": payload.wallet_balance_after_transaction,
                            "wallet_balance_before_transaction": payload.wallet_balance_before_transaction,
                            "rule": "balance after must be larger than balance before",
                            "wallet_balances_difference": payload.amount,
                            "transaction_fee_amount": null,
                        },
                    },
                }),
            }).then(async function (response) {
                console.log("The supabase API was called successfully - deposit record has been created boss");

                res.status(200).send("Success - Deposit record has been created boss. Please adjust the datetime to where you want it to appear");
            }).catch(async function (error) {
                console.log(error);

                console.log(`There was an error: trying to create a new deposit row in supabase`);

                res.status(200).send("Failed - Deposit record NOT created. Please contact Justin for more information");
            });
        };

        try {
            await createDepositRecord();
        } catch (e) {
            console.log(e);

            res.status(400).send("Failed");
        }
    });

    e.credit = functions.runWith({
        timeoutSeconds: 180,
    }).https.onRequest(app);
};
