/* eslint-disable prefer-const */
/* eslint-disable no-unused-vars */
/* eslint-disable camelcase */
const functions = require("firebase-functions");
const cors = require("cors")({ origin: true });
const admin = require("firebase-admin");
const { v4: uuidv4 } = require('uuid');
const express = require('express');
const axios = require("axios");
const db = admin.firestore();
const app = express();
app.use(express.json());
app.use(express.urlencoded({ extended: true }));
app.use(cors);

module.exports = function (e) {
    // ================= Http Notification Functions

    // VERSION 1 - submits a mobile money withdrawal request - NO TIMELINE POST
    app.post('/v1/withdraw/mobile_money', async (req, res) => {
        const user_data = req.body;

        /*
            BODY PREVIEW
            {
                "user_id": box("user_id"),
                "country": box("country"),
                "currency": box("currency"),
                "method": paymentInfo['paymentMethod'],
                "reference": paymentInfo['phoneNumber'],
                "phone_number": paymentInfo['reference'],
                "transaction_fee_currency": box("currency"),
                "full_names": "${box("first_name")} ${box("last_name")}",
                "amount_to_withdraw_plus_fee": paymentInfo['amountPlusFee'],
                "amount_to_withdraw_minus_fee": paymentInfo['amountBeforeFee'],
                "transaction_fee_percentage": box("agent_payments_withdraw_fee_percent").toString(),
                "transaction_fee_amount": paymentInfo['amountPlusFee'] - paymentInfo['amountBeforeFee'],
                "description": "To ${paymentInfo['phoneNumber']} "
                "${paymentInfo['reference']}",
            }
        */

        // gets the transaction owner's document
        const transaction_owner_doc = await db.collection("Users").doc(user_data.user_id).get();

        // gets sms doc containing keys
        const smsKeys = await db.collection("Admin").doc("Legal").collection("APIs").doc("PaymentAPI").get();

        const auth_token = "Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InNyZmp6c3FpbWZ1b21sbWppeHN1Iiwicm9sZSI6ImFub24iLCJpYXQiOjE2OTIyNjcxODUsImV4cCI6MjAwNzg0MzE4NX0.NpqWE-1xwM3ZLTbR8Er01GfuKjyijy0IlseWc4UCdSU";

        // gets the public supabase keys document
        // const supabase_keys = await db.collection("Admin").doc("Legal").collection("Supabase").doc("keys").get();

        // sends notification(s) to the token(s) provided
        const submit_withdrawal_request = async () => {
            const transaction_id = uuidv4();

            console.log(`The transaction ID is ${transaction_id}`);

            if (transaction_owner_doc.get("Balance") >= user_data.amount_to_withdraw_plus_fee) {
                // creates a supabase withdrawal record
                // DO NOT MOVE - this has to be at the top so that the fraud check
                // can see if this transaction will make the total money out to go beyond the total
                // money in - and when that happens, the transction will be flagged as fraudulent
                await axios({
                    "method": "post",
                    url: "https://srfjzsqimfuomlmjixsu.supabase.co/functions/v1/general_functions",
                    headers: {
                        "Content-Type": "application/json",
                        "Authorization": auth_token,
                    },
                    data: JSON.stringify({
                        "request_type": "create_update_row_record",
                        "operation_type": "create_row",
                        "table_name": "transactions",
                        "data": {
                            "comment": "",
                            "is_public": false,
                            "status": "Pending",
                            "country": "Zambia",
                            "number_of_views": 0,
                            "number_of_likes": 0,
                            "attended_to": false,
                            "number_of_replies": 0,
                            "currency_symbol": "K",
                            "deposit_details": null,
                            "sent_received": "Sent",
                            "p2p_sender_details": null,
                            "method": user_data.method,
                            "user_id": user_data.user_id,
                            "p2p_recipient_details": null,
                            "currency": user_data.currency,
                            "savings_account_details": null,
                            "transaction_id": transaction_id,
                            "transaction_type": "Withdrawal",
                            "full_names": user_data.full_names,
                            "description": user_data.description,
                            "amount": user_data.amount_to_withdraw_minus_fee,
                            "user_is_verified": transaction_owner_doc.get("isVerified"),
                            "withdrawal_details": {
                                "bank_name": "",
                                "bank_branch": "",
                                "bank_country": "",
                                "bank_address": "",
                                "bank_sort_code": "",
                                "bank_swift_code": "",
                                "bank_account_number": "",
                                "bank_routing_number": "",
                                "bank_account_holder_name": "",
                                "reference": user_data.reference,
                                "phone_number": user_data.phone_number,
                                "picked_withdraw_method": user_data.method,
                                "withdraw_amount_plus_fee": user_data.amount_to_withdraw_plus_fee,
                                "withdraw_amount_minus_fee": user_data.amount_to_withdraw_minus_fee,
                                "withdraw_amount_to_send_to_method": user_data.amount_to_withdraw_minus_fee,
                            },
                            "transaction_fee_details": {
                                "transaction_local_bank_tranfer_fee": "",
                                "transcation_bank_transfer_fee_currency": "",
                                "transaction_international_bank_tranfer_fee": "",
                                "transaction_total_fee_currency": user_data.currency,
                                "transaction_fee_amount": user_data.transaction_fee_amount,
                                "transaction_total_fee_percentage": user_data.transaction_fee_percentage,
                            },
                            "wallet_balance_details": {
                                "wallet_balance_after_transaction": transaction_owner_doc.get("Balance") - user_data.amount_to_withdraw_plus_fee,
                                "wallet_balance_before_transaction": transaction_owner_doc.get("Balance"),
                                "wallet_balances_difference": user_data.amount_to_withdraw_minus_fee,
                                "rule": "balance before must be larger than balance after",
                                "transaction_fee_amount": user_data.transaction_fee_amount,
                            },
                        },
                    }),
                }).then(async function (response) {
                    console.log("The supabase API was called successfully");
                }).catch(async function (error) {
                    console.log(error);
                    console.log(`There was an error: trying to create a new referral_commission_transactions row in supabase`);
                });

                let fraud_res = "";

                // checks if the user has conducted any fraudulent
                await axios({
                    "method": "post",
                    url: "https://srfjzsqimfuomlmjixsu.supabase.co/functions/v1/check_for_fraudulent_transactions",
                    headers: {
                        "Content-Type": "application/json",
                        "Authorization": auth_token,
                    },
                    data: JSON.stringify({
                        user_id: user_data.user_id,
                    }),
                }).then(async function (response1) {
                    fraud_res = response1.data.data;

                    console.log(response1.data);
                }).catch(async function (error) {
                    console.log(error);
                });

                // console.log(`The fraud response is ${fraud_res}`);

                // if the user has passed our fraud check
                if (fraud_res == "Everything looks good boss. No fraudulent activity detected." || fraud_res == "") {
                    // deducts the withdraw amount + fee from the user's balance
                    await db.collection("Users").doc(user_data.user_id).update({
                        Balance: admin.firestore.FieldValue.increment(-user_data.amount_to_withdraw_plus_fee),
                    });

                    // sends notification to the user
                    await admin.messaging().sendToDevice(transaction_owner_doc.get("NotificationToken"), {
                        notification: {
                            body: `You have withdrawn ${user_data.currency} ${user_data.amount_to_withdraw_minus_fee} to ${user_data.method}. It will be processed shortly, please be patient.`,
                            icon: "@drawable/ic_stat_jayben_logo_1_044317_copy_3",
                            clickAction: "FLUTTER_NOTIFICATION_CLICK",
                            title: "Withdrawal Submitted",
                        },
                        data: {
                            userID: "",
                        },
                    });

                    // updates the admins metric document
                    await db.collection("Admin").doc("Metrics").update({
                        numberOfPendingWithdrawals: admin.firestore.FieldValue.increment(1),
                        dailyNumberOfWithdrawalsMade: admin.firestore.FieldValue.increment(1),
                        totalUserBalances: admin.firestore.FieldValue.increment(user_data.amount_to_withdraw_minus_fee),
                    });

                    // sends justin an sms so he can process the withdrawal
                    require('africastalking')({
                        apiKey: '7eef716206eb9b641718604995f48bd165663a4005ea37f7db6af4f7297ab5ee',
                        username: 'Jayben_zambia',
                    }).SMS.send({
                        to: [smsKeys.get("SupportLine")],
                        message: `New withdrawal of ${user_data.currency} ${user_data.amount_to_withdraw_minus_fee} to ${user_data.phone_number} to ${user_data.method} by ${user_data.full_names}`,
                        from: 'Jayben_ZM',
                    })
                        .then(console.log)
                        .catch(console.log);

                    res.status(200).send("Success");
                } else {
                    // updates withdrawal row to show it has been flagged
                    await axios({
                        "method": "post",
                        url: "https://srfjzsqimfuomlmjixsu.supabase.co/functions/v1/general_functions",
                        headers: {
                            "Content-Type": "application/json",
                            "Authorization": auth_token,
                        },
                        data: JSON.stringify({
                            "request_type": "create_update_row_record",
                            "primary_column_name": "transaction_id",
                            "operation_type": "update_row",
                            "table_name": "transactions",
                            "row_id": transaction_id,
                            "data": {
                                "status": "Flagged",
                            },
                        }),
                    }).then(async function (response) {
                        console.log("The supabase API update transaction to fraggaed was called successfully", response);
                    }).catch(async function (error) {
                        console.log(`There was an error: trying to update the withdrawal transaction status to flagged row in supabase`);
                        console.log(error);
                    });

                    // puts the user's account on hold
                    // when a transaction has been flagged, the balance remains the same
                    await db.collection("Users").doc(user_data.user_id).update({
                        OnHold: true,
                    });

                    // sends notification to the user
                    await admin.messaging().sendToDevice(transaction_owner_doc.get("NotificationToken"), {
                        notification: {
                            body: `Your withdrawal has been flagged. Please contact customer support on ${smsKeys.get("ContactUsLine")}.`,
                            icon: "@drawable/ic_stat_jayben_logo_1_044317_copy_3",
                            clickAction: "FLUTTER_NOTIFICATION_CLICK",
                            title: "Withdrawal Flagged 🚩",
                        },
                        data: {
                            userID: "",
                        },
                    });

                    // sends justin an sms so he can process the withdrawal
                    require('africastalking')({
                        apiKey: '7eef716206eb9b641718604995f48bd165663a4005ea37f7db6af4f7297ab5ee',
                        username: 'Jayben_zambia',
                    }).SMS.send({
                        to: ["+260977980371"],
                        message: `FLAGGED WITHDRAWAL DETECTED: ${user_data.currency} ${user_data.amount_to_withdraw_minus_fee} to ${user_data.phone_number} to ${user_data.method} by ${user_data.full_names}`,
                        from: 'Jayben_ZM',
                    })
                        .then(console.log)
                        .catch(console.log);

                    res.status(200).send("Failed");
                }
            } else {
                // sends notification to the user
                await admin.messaging().sendToDevice(transaction_owner_doc.get("NotificationToken"), {
                    notification: {
                        body: `You have insufficient balance to conduct this withdrawal.`,
                        icon: "@drawable/ic_stat_jayben_logo_1_044317_copy_3",
                        clickAction: "FLUTTER_NOTIFICATION_CLICK",
                        title: "Withdrawal Declined",
                    },
                    data: {
                        userID: "",
                    },
                });

                res.status(200).send("Failed");
            }
        };

        try {
            await submit_withdrawal_request();
        } catch (e) {
            console.log("Test point 9");

            console.log(e);

            res.status(200).send("Failed");
        }

        console.log("Test point 10");
    });

    // VERSION 2 - submits a mobile money withdrawal request - CREATES A TIMELINE POST WITH MEDIA (FOR user with v1.00.80 and above of Jayben)
    app.post('/v2/withdraw/mobile_money', async (req, res) => {
        const user_data = req.body;

        /*
            BODY PREVIEW
            {
                "user_id": box("user_id"),
                "country": box("country"),
                "currency": box("currency"),
                "method": paymentInfo['paymentMethod'],
                "reference": paymentInfo['phoneNumber'],
                "phone_number": paymentInfo['reference'],
                "transaction_fee_currency": box("currency"),
                "full_names": "${box("first_name")} ${box("last_name")}",
                "amount_to_withdraw_plus_fee": paymentInfo['amountPlusFee'],
                "amount_to_withdraw_minus_fee": paymentInfo['amountBeforeFee'],
                "transaction_fee_percentage": box("agent_payments_withdraw_fee_percent").toString(),
                "transaction_fee_amount": paymentInfo['amountPlusFee'] - paymentInfo['amountBeforeFee'],
                "description": "To ${paymentInfo['phoneNumber']} ${paymentInfo['reference']}",
            }
        */

        // gets the transaction owner's document
        const transaction_owner_doc = await db.collection("Users").doc(user_data.user_id).get();

        // gets sms doc containing keys
        const smsKeys = await db.collection("Admin").doc("Legal").collection("APIs").doc("PaymentAPI").get();

        const auth_token = "Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InNyZmp6c3FpbWZ1b21sbWppeHN1Iiwicm9sZSI6ImFub24iLCJpYXQiOjE2OTIyNjcxODUsImV4cCI6MjAwNzg0MzE4NX0.NpqWE-1xwM3ZLTbR8Er01GfuKjyijy0IlseWc4UCdSU";

        // gets the public supabase keys document
        // const supabase_keys = await db.collection("Admin").doc("Legal").collection("Supabase").doc("keys").get();

        // sends notification(s) to the token(s) provided
        const submit_withdrawal_request = async () => {
            const transaction_id = uuidv4();

            console.log(`The transaction ID is ${transaction_id}`);

            if (transaction_owner_doc.get("Balance") >= user_data.amount_to_withdraw_plus_fee) {
                // // gets the app's public settings document
                // const admin_doc = await db.collection("Admin").doc("Legal").get();

                // let post_is_public = false;

                // if (admin_doc.get("DefaultTransactionPrivacy") == "Public") {
                //     post_is_public = true;
                // }

                // creates a supabase withdrawal record
                // DO NOT MOVE - this has to be at the top so that the fraud check
                // can see if this transaction will make the total money out to go beyond the total
                // money in - and when that happens, the transction will be flagged as fraudulent
                await axios({
                    "method": "post",
                    url: "https://srfjzsqimfuomlmjixsu.supabase.co/functions/v1/general_functions",
                    headers: {
                        "Content-Type": "application/json",
                        "Authorization": auth_token,
                    },
                    data: JSON.stringify({
                        "request_type": "create_update_row_record",
                        "operation_type": "create_row",
                        "table_name": "transactions",
                        "data": {
                            "comment": "",
                            "is_public": false,
                            "status": "Pending",
                            "country": "Zambia",
                            "number_of_views": 0,
                            "number_of_likes": 0,
                            "attended_to": false,
                            "number_of_replies": 0,
                            "currency_symbol": "K",
                            "deposit_details": null,
                            "sent_received": "Sent",
                            "p2p_sender_details": null,
                            "method": user_data.method,
                            "user_id": user_data.user_id,
                            "p2p_recipient_details": null,
                            "currency": user_data.currency,
                            "savings_account_details": null,
                            "transaction_id": transaction_id,
                            "transaction_type": "Withdrawal",
                            "full_names": user_data.full_names,
                            "description": user_data.description,
                            "amount": user_data.amount_to_withdraw_minus_fee,
                            "user_is_verified": transaction_owner_doc.get("isVerified"),
                            "withdrawal_details": {
                                "bank_name": "",
                                "bank_branch": "",
                                "bank_country": "",
                                "bank_address": "",
                                "bank_sort_code": "",
                                "bank_swift_code": "",
                                "bank_account_number": "",
                                "bank_routing_number": "",
                                "bank_account_holder_name": "",
                                "reference": user_data.reference,
                                "phone_number": user_data.phone_number,
                                "picked_withdraw_method": user_data.method,
                                "withdraw_amount_plus_fee": user_data.amount_to_withdraw_plus_fee,
                                "withdraw_amount_minus_fee": user_data.amount_to_withdraw_minus_fee,
                                "withdraw_amount_to_send_to_method": user_data.amount_to_withdraw_minus_fee,
                            },
                            "transaction_fee_details": {
                                "transaction_local_bank_tranfer_fee": "",
                                "transcation_bank_transfer_fee_currency": "",
                                "transaction_international_bank_tranfer_fee": "",
                                "transaction_total_fee_currency": user_data.currency,
                                "transaction_fee_amount": user_data.transaction_fee_amount,
                                "transaction_total_fee_percentage": user_data.transaction_fee_percentage,
                            },
                            "wallet_balance_details": {
                                "wallet_balance_after_transaction": transaction_owner_doc.get("Balance") - user_data.amount_to_withdraw_plus_fee,
                                "wallet_balance_before_transaction": transaction_owner_doc.get("Balance"),
                                "wallet_balances_difference": user_data.amount_to_withdraw_minus_fee,
                                "rule": "balance before must be larger than balance after",
                                "transaction_fee_amount": user_data.transaction_fee_amount,
                            },
                        },
                    }),
                }).then(async function (response) {
                    console.log("The supabase API was called successfully");
                }).catch(async function (error) {
                    console.log(error);
                    console.log(`There was an error: trying to create a new referral_commission_transactions row in supabase`);
                });

                let fraud_res = "";

                // checks if the user has conducted any fraudulent
                await axios({
                    "method": "post",
                    url: "https://srfjzsqimfuomlmjixsu.supabase.co/functions/v1/check_for_fraudulent_transactions",
                    headers: {
                        "Content-Type": "application/json",
                        "Authorization": auth_token,
                    },
                    data: JSON.stringify({
                        user_id: user_data.user_id,
                    }),
                }).then(async function (response1) {
                    fraud_res = response1.data.data;

                    console.log(response1.data);
                }).catch(async function (error) {
                    console.log(error);
                });

                // console.log(`The fraud response is ${fraud_res}`);

                // if the user has passed our fraud check
                if (fraud_res == "Everything looks good boss. No fraudulent activity detected.") {
                    // deducts the withdraw amount + fee from the user's balance
                    await db.collection("Users").doc(user_data.user_id).update({
                        Balance: admin.firestore.FieldValue.increment(-user_data.amount_to_withdraw_plus_fee),
                    });

                    // sends notification to the user
                    await admin.messaging().sendToDevice(transaction_owner_doc.get("NotificationToken"), {
                        notification: {
                            body: `You have withdrawn ${user_data.currency} ${user_data.amount_to_withdraw_minus_fee} to ${user_data.method}. It will be processed shortly, please be patient.`,
                            icon: "@drawable/ic_stat_jayben_logo_1_044317_copy_3",
                            clickAction: "FLUTTER_NOTIFICATION_CLICK",
                            title: "Withdrawal Submitted",
                        },
                        data: {
                            userID: "",
                        },
                    });

                    // updates the admins metric document
                    await db.collection("Admin").doc("Metrics").update({
                        numberOfPendingWithdrawals: admin.firestore.FieldValue.increment(1),
                        dailyNumberOfWithdrawalsMade: admin.firestore.FieldValue.increment(1),
                        totalUserBalances: admin.firestore.FieldValue.increment(user_data.amount_to_withdraw_minus_fee),
                    });

                    // sends justin an sms so he can process the withdrawal
                    require('africastalking')({
                        apiKey: '7eef716206eb9b641718604995f48bd165663a4005ea37f7db6af4f7297ab5ee',
                        username: 'Jayben_zambia',
                    }).SMS.send({
                        to: [smsKeys.get("SupportLine")],
                        message: `New withdrawal of ${user_data.currency} ${user_data.amount_to_withdraw_minus_fee} to ${user_data.phone_number} to ${user_data.method} of reference ${user_data.reference} initiated by ${user_data.full_names}`,
                        from: 'Jayben_ZM',
                    })
                        .then(console.log)
                        .catch(console.log);

                    // adds transaction timeline posts
                    // if (post_is_public) {
                    //     try {
                    //         await axios({
                    //             "method": "post",
                    //             url: "https://srfjzsqimfuomlmjixsu.supabase.co/functions/v1/general_functions",
                    //             headers: {
                    //                 "Content-Type": "application/json",
                    //                 "Authorization": auth_token,
                    //             },
                    //             data: JSON.stringify({
                                    // "request_type": "add_post_to_contacts",
                    //                 "media_details": user_data.media_details,
                    //                 "transaction_id": transaction_id,
                    //                 "user_id": user_data.user_id,
                    //             }),
                    //         }).then(async function (response) {
                    //             console.log("The supabase API to create transaction post was called successfully", response);
                    //         }).catch(async function (error) {
                    //             console.log(`There was an error: trying to create transaction post row in supabase`);
                    //             console.log(error);
                    //         });
                    //     } catch (e) {
                    //         console.log("There was an erorr calling the supabase API to create timeline posts boss.");
                    //         console.log(e);
                    //     }
                    // }

                    res.status(200).send("Success");
                } else {
                    // updates withdrawal row to show it has been flagged
                    await axios({
                        "method": "post",
                        url: "https://srfjzsqimfuomlmjixsu.supabase.co/functions/v1/general_functions",
                        headers: {
                            "Content-Type": "application/json",
                            "Authorization": auth_token,
                        },
                        data: JSON.stringify({
                            "request_type": "create_update_row_record",
                            "primary_column_name": "transaction_id",
                            "operation_type": "update_row",
                            "table_name": "transactions",
                            "row_id": transaction_id,
                            "data": {
                                "status": "Flagged",
                            },
                        }),
                    }).then(async function (response) {
                        console.log("The supabase API update transaction to fraggaed was called successfully", response);
                    }).catch(async function (error) {
                        console.log(`There was an error: trying to update the withdrawal transaction status to flagged row in supabase`);
                        console.log(error);
                    });

                    // puts the user's account on hold
                    // when a transaction has been flagged, the balance remains the same
                    await db.collection("Users").doc(user_data.user_id).update({
                        OnHold: true,
                    });

                    // sends notification to the user
                    await admin.messaging().sendToDevice(transaction_owner_doc.get("NotificationToken"), {
                        notification: {
                            body: `Your withdrawal has been flagged. Please contact customer support on ${smsKeys.get("ContactUsLine")}.`,
                            icon: "@drawable/ic_stat_jayben_logo_1_044317_copy_3",
                            clickAction: "FLUTTER_NOTIFICATION_CLICK",
                            title: "Withdrawal Flagged 🚩",
                        },
                        data: {
                            userID: "",
                        },
                    });

                    // sends justin an sms so he can process the withdrawal
                    require('africastalking')({
                        apiKey: '7eef716206eb9b641718604995f48bd165663a4005ea37f7db6af4f7297ab5ee',
                        username: 'Jayben_zambia',
                    }).SMS.send({
                        to: ["+260977980371"],
                        message: `FLAGGED WITHDRAWAL DETECTED: ${user_data.currency} ${user_data.amount_to_withdraw_minus_fee} to ${user_data.phone_number} to ${user_data.method} by ${user_data.full_names}`,
                        from: 'Jayben_ZM',
                    })
                        .then(console.log)
                        .catch(console.log);

                    res.status(200).send("Failed");
                }
            } else {
                // sends notification to the user
                await admin.messaging().sendToDevice(transaction_owner_doc.get("NotificationToken"), {
                    notification: {
                        body: `You have insufficient balance to conduct this withdrawal.`,
                        icon: "@drawable/ic_stat_jayben_logo_1_044317_copy_3",
                        clickAction: "FLUTTER_NOTIFICATION_CLICK",
                        title: "Withdrawal Declined",
                    },
                    data: {
                        userID: "",
                    },
                });

                res.status(200).send("Failed");
            }
        };

        try {
            await submit_withdrawal_request();
        } catch (e) {
            console.log("Test point 9");

            console.log(e);

            res.status(200).send("Failed");
        }

        console.log("Test point 10");
    });

    // ======================= P2P Wallet Transfers

    // VERSION 1 - NO TIMELINE POST (FOR user with v1.00.78 and below of Jayben)
    app.post('/v1/transfer/p2p/wallet', async (req, res) => {
        const user_data = req.body;

        /*
            BODY PREVIEW
            {
                "receiver_user_id": paymentInfo['receiverDoc'].get("UserID"),
                "comment": paymentInfo['comment'],
                "amount": paymentInfo["amount"],
                "currency": box("currency"),
                "user_id": box("user_id"),
                "country": box("country"),
            }
        */

        const auth_token = "Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InNyZmp6c3FpbWZ1b21sbWppeHN1Iiwicm9sZSI6ImFub24iLCJpYXQiOjE2OTIyNjcxODUsImV4cCI6MjAwNzg0MzE4NX0.NpqWE-1xwM3ZLTbR8Er01GfuKjyijy0IlseWc4UCdSU";
        const fraud_detected_response = "Fraudulent activity detected: This person is trying to withdraw more money than they have ever deposited.";

        // gets the public supabase keys document
        // const supabase_keys = await db.collection("Admin").doc("Legal").collection("Supabase").doc("keys").get();

        // gets the receiver's user document
        const receiver_user_doc = await db.collection("Users").doc(user_data.receiver_user_id).get();

        // gets the sender's user document
        const sender_user_doc = await db.collection("Users").doc(user_data.user_id).get();

        // transfers money from the sender to the receiver
        const send_money = async () => {
            if (sender_user_doc.get("Balance") >= user_data["amount"]) {
                const receiver_transaction_id = uuidv4();
                const sender_transaction_id = uuidv4();

                const recipient_wallet_bal_after_transaction =
                    parseFloat(receiver_user_doc.get("Balance").toString()) +
                    user_data["amount"];

                const sender_wallet_bal_after_transaction =
                    parseFloat(sender_user_doc.get("Balance").toString()) - user_data["amount"];

                // creates a supabase transaction record for the sender
                await axios({
                    "method": "post",
                    url: "https://srfjzsqimfuomlmjixsu.supabase.co/functions/v1/general_functions",
                    headers: {
                        "Authorization": auth_token,
                        "Content-Type": "application/json",
                    },
                    data: JSON.stringify({
                        "request_type": "create_update_row_record",
                        "operation_type": "create_row",
                        "table_name": "transactions",
                        "data": {
                            "is_public": false,
                            "country": "Zambia",
                            "number_of_views": 0,
                            "number_of_likes": 0,
                            "attended_to": false,
                            "status": "Completed",
                            "number_of_replies": 0,
                            "currency_symbol": "K",
                            "deposit_details": null,
                            "sent_received": "Sent",
                            "p2p_sender_details": null,
                            "amount": user_data.amount,
                            "withdrawal_details": null,
                            "method": user_data.method,
                            "user_id": user_data.user_id,
                            "transaction_type": "Transfer",
                            "currency": user_data.currency,
                            "comment": user_data["comment"],
                            "savings_account_details": null,
                            "transaction_fee_details": null,
                            "transaction_id": sender_transaction_id,
                            "user_is_verified": sender_user_doc.get("isVerified"),
                            "p2p_recipient_details": {
                                "user_id": receiver_user_doc.id,
                                "recipient_wallet_balance_after_transaction":
                                    recipient_wallet_bal_after_transaction,
                                "recipient_wallet_balance_before_transaction":
                                    parseFloat(receiver_user_doc.get("Balance")),
                                "phone_number": receiver_user_doc.get("PhoneNumber"),
                                "full_names": `${receiver_user_doc.get("FirstName")} ${receiver_user_doc.get("LastName")}`,
                            },
                            "full_names": `${sender_user_doc.get("FirstName")} ${sender_user_doc.get("LastName")}`,
                            "description": `To ${receiver_user_doc.get("FirstName")} ${receiver_user_doc.get("LastName")}`,
                            "wallet_balance_details": {
                                "wallet_balance_after_transaction": sender_user_doc.get("Balance") - user_data.amount,
                                "wallet_balance_before_transaction": sender_user_doc.get("Balance"),
                                "rule": "balance before must be larger than balance after",
                                "wallet_balances_difference": user_data.amount,
                                "transaction_fee_amount": 0,
                            },
                        },
                    }),
                }).then(async function (response) {
                    console.log("The supabase API was called successfully");
                }).catch(async function (error) {
                    console.log(error);

                    console.log(`There was an error submitting a withdrawal request boss`);
                });

                // creates a supabase transaction record for the receiver
                await axios({
                    "method": "post",
                    url: "https://srfjzsqimfuomlmjixsu.supabase.co/functions/v1/general_functions",
                    headers: {
                        "Authorization": auth_token,
                        "Content-Type": "application/json",
                    },
                    data: JSON.stringify({
                        "request_type": "create_update_row_record",
                        "operation_type": "create_row",
                        "table_name": "transactions",
                        "data": {
                            "is_public": false,
                            "country": "Zambia",
                            "number_of_views": 0,
                            "number_of_likes": 0,
                            "attended_to": false,
                            "status": "Completed",
                            "number_of_replies": 0,
                            "currency_symbol": "K",
                            "deposit_details": null,
                            "amount": user_data.amount,
                            "withdrawal_details": null,
                            "method": user_data.method,
                            "sent_received": "Received",
                            "p2p_recipient_details": null,
                            "transaction_type": "Transfer",
                            "currency": user_data.currency,
                            "comment": user_data["comment"],
                            "savings_account_details": null,
                            "transaction_fee_details": null,
                            "user_id": user_data.receiver_user_id,
                            "transaction_id": receiver_transaction_id,
                            "user_is_verified": receiver_user_doc.get("isVerified"),
                            "p2p_sender_details": {
                                "user_id": sender_user_doc.id,
                                "senders_wallet_balance_after_transaction":
                                    sender_wallet_bal_after_transaction,
                                "senders_wallet_balance_before_transaction":
                                    parseFloat(sender_user_doc.get("Balance")),
                                "phone_number": sender_user_doc.get("PhoneNumber"),
                                "full_names": `${sender_user_doc.get("FirstName")} ${sender_user_doc.get("LastName")}`,
                            },
                            "full_names": `${receiver_user_doc.get("FirstName")} ${receiver_user_doc.get("LastName")}`,
                            "description": `From ${sender_user_doc.get("FirstName")} ${sender_user_doc.get("LastName")}`,
                            "wallet_balance_details": {
                                "wallet_balance_after_transaction": receiver_user_doc.get("Balance") + user_data.amount,
                                "wallet_balance_before_transaction": receiver_user_doc.get("Balance"),
                                "rule": "balance after must be larger than balance before",
                                "wallet_balances_difference": user_data.amount,
                                "transaction_fee_amount": 0,
                            },
                        },
                    }),
                }).then(async function (response) {
                    console.log("The supabase API was called successfully");
                }).catch(async function (error) {
                    console.log(error);
                    console.log(`There was an error: trying to create a new referral_commission_transactions row in supabase`);
                });

                // deducts the amount from the sender's user document
                await db.collection("Users").doc(user_data.user_id).update({
                    Balance: admin.firestore.FieldValue.increment(-user_data.amount),
                });

                // credits the receiver's user document
                await db.collection("Users").doc(user_data.receiver_user_id).update({
                    Balance: admin.firestore.FieldValue.increment(user_data.amount),
                });

                // sends notification to the receiver
                await admin.messaging().sendToDevice(receiver_user_doc.get("NotificationToken"), {
                    notification: {
                        title: `🤑 ${sender_user_doc.get("FirstName")} sent you K${user_data.amount} 💰💸`,
                        icon: "@drawable/ic_stat_jayben_logo_1_044317_copy_3",
                        clickAction: "FLUTTER_NOTIFICATION_CLICK",
                        body: user_data["comment"],
                    },
                    data: {
                        userID: "",
                    },
                });

                // sends notification to the sender
                await admin.messaging().sendToDevice(sender_user_doc.get("NotificationToken"), {
                    notification: {
                        body: `You sent K${user_data.amount} to ${receiver_user_doc.get("FirstName")} ${receiver_user_doc.get("LastName")}`,
                        icon: "@drawable/ic_stat_jayben_logo_1_044317_copy_3",
                        clickAction: "FLUTTER_NOTIFICATION_CLICK",
                        title: "Money Sent! 💸",
                    },
                    data: {
                        userID: "",
                    },
                });

                res.status(200).send("Success");
            } else {
                // sends notification to the user
                await admin.messaging().sendToDevice(sender_user_doc.get("NotificationToken"), {
                    notification: {
                        body: `You have insufficient balance to conduct this transfer.`,
                        icon: "@drawable/ic_stat_jayben_logo_1_044317_copy_3",
                        clickAction: "FLUTTER_NOTIFICATION_CLICK",
                        title: "Transfer Declined",
                    },
                    data: {
                        userID: "",
                    },
                });

                res.status(200).send("Failed");
            }
        };

        console.log("Test point 6");

        const run_anti_fraud_check = async () => {
            // run fraud check only with unrestricted users
            if (sender_user_doc.get("OnHold") == false) {
                let fraud_res = "";

                // checks if the user has conducted any fraudulent
                await axios({
                    "method": "post",
                    url: "https://srfjzsqimfuomlmjixsu.supabase.co/functions/v1/check_for_fraudulent_transactions",
                    headers: {
                        "Content-Type": "application/json",
                        "Authorization": auth_token,
                    },
                    data: JSON.stringify({
                        user_id: sender_user_doc.get("UserID"),
                    }),
                }).then(async function (response1) {
                    fraud_res = response1.data.data;

                    console.log(response1.data);
                }).catch(async function (error) {
                    console.log(error);
                });

                if (fraud_res == fraud_detected_response) {
                    // puts the user's account on hold
                    // when a transaction has been flagged, the balance remains the same
                    await db.collection("Users").doc(sender_user_doc.get("UserID")).update({
                        OnHoldReason: "Money in - money out ratio is off.",
                        OnHold: true,
                    });

                    // gets sms doc containing keys
                    const smsKeys = await db.collection("Admin").doc("Legal").collection("APIs").doc("PaymentAPI").get();

                    // sends notification to the user
                    await admin.messaging().sendToDevice(sender_user_doc.get("NotificationToken"), {
                        notification: {
                            body: `Your account has been flagged. Please contact customer support on ${smsKeys.get("jayben_primary_customer_support_hotline")}.`,
                            icon: "@drawable/ic_stat_jayben_logo_1_044317_copy_3",
                            clickAction: "FLUTTER_NOTIFICATION_CLICK",
                            title: "Account Flagged 🚩",
                        },
                        data: {
                            userID: "",
                        },
                    });

                    // sends justin an sms so he can process the withdrawal
                    require('africastalking')({
                        apiKey: '7eef716206eb9b641718604995f48bd165663a4005ea37f7db6af4f7297ab5ee',
                        username: 'Jayben_zambia',
                    }).SMS.send({
                        to: ["+260977980371"],
                        message: `FLAGGED P2P TRANSFER DETECTED: By ${sender_user_doc.docs[0].get("FirstName")} ${sender_user_doc.get("LastName")} of UserID: ${sender_user_doc.get("UserID")} DO NOT FULFILL THEIR WITHDRAWAL`,
                        from: 'Jayben_ZM',
                    })
                        .then(console.log)
                        .catch(console.log);
                } else {
                    await send_money();
                }
            }
        };

        try {
            // await run_anti_fraud_check();

            // sends notification to the sender
            await admin.messaging().sendToDevice(sender_user_doc.get("NotificationToken"), {
                notification: {
                    body: `Internal transfers are currently offline. You will be notified when they are back online.`,
                    icon: "@drawable/ic_stat_jayben_logo_1_044317_copy_3",
                    clickAction: "FLUTTER_NOTIFICATION_CLICK",
                    title: "Transfer Unsuccessful",
                },
                data: {
                    userID: "",
                },
            });

            res.status(200).send("Failed");
        } catch (e) {
            console.log("Test point 9");

            console.log(e);

            res.status(200).send("Failed");
        }

        console.log("Test point 10");
    });

    // VERSION 2 - CREATES A TEXT ONLY TIMELINE POST (FOR user with v1.00.79 of Jayben)
    app.post('/v2/transfer/p2p/wallet', async (req, res) => {
        const user_data = req.body;

        /*
            BODY PREVIEW
            {
                "receiver_user_id": paymentInfo['receiverDoc'].get("UserID"),
                "comment": paymentInfo['comment'],
                "amount": paymentInfo["amount"],
                "currency": box("currency"),
                "user_id": box("user_id"),
                "country": box("country"),
                "post_is_public": boolean,
            }
        */

        const auth_token = "Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InNyZmp6c3FpbWZ1b21sbWppeHN1Iiwicm9sZSI6ImFub24iLCJpYXQiOjE2OTIyNjcxODUsImV4cCI6MjAwNzg0MzE4NX0.NpqWE-1xwM3ZLTbR8Er01GfuKjyijy0IlseWc4UCdSU";

        // gets the receiver's user document
        const receiver_user_doc = await db.collection("Users").doc(user_data.receiver_user_id).get();

        // gets the sender's user document
        const sender_user_doc = await db.collection("Users").doc(user_data.user_id).get();

        const receiver_transaction_id = uuidv4();
        const sender_transaction_id = uuidv4();

        // transfers money from the sender to the receiver
        const send_money = async () => {
            if (sender_user_doc.get("Balance") >= user_data["amount"]) {
                const recipient_wallet_bal_after_transaction =
                    parseFloat(receiver_user_doc.get("Balance").toString()) +
                    user_data["amount"];

                const sender_wallet_bal_after_transaction =
                    parseFloat(sender_user_doc.get("Balance").toString()) - user_data["amount"];

                // creates a supabase for the sender
                await axios({
                    "method": "post",
                    url: "https://srfjzsqimfuomlmjixsu.supabase.co/functions/v1/general_functions",
                    headers: {
                        "Content-Type": "application/json",
                        "Authorization": auth_token,
                    },
                    data: JSON.stringify({
                        "request_type": "create_update_row_record",
                        "operation_type": "create_row",
                        "table_name": "transactions",
                        "data": {
                            "country": "Zambia",
                            "number_of_views": 0,
                            "number_of_likes": 0,
                            "attended_to": false,
                            "status": "Completed",
                            "number_of_replies": 0,
                            "currency_symbol": "K",
                            "deposit_details": null,
                            "sent_received": "Sent",
                            "p2p_sender_details": null,
                            "amount": user_data.amount,
                            "withdrawal_details": null,
                            "method": user_data.method,
                            "user_id": user_data.user_id,
                            "transaction_type": "Transfer",
                            "currency": user_data.currency,
                            "comment": user_data["comment"],
                            "savings_account_details": null,
                            "transaction_fee_details": null,
                            "is_public": user_data.post_is_public,
                            "transaction_id": sender_transaction_id,
                            "user_is_verified": sender_user_doc.get("isVerified"),
                            "p2p_recipient_details": {
                                "user_id": receiver_user_doc.id,
                                "recipient_wallet_balance_after_transaction":
                                    recipient_wallet_bal_after_transaction,
                                "recipient_wallet_balance_before_transaction":
                                    parseFloat(receiver_user_doc.get("Balance")),
                                "phone_number": receiver_user_doc.get("PhoneNumber"),
                                "full_names": `${receiver_user_doc.get("FirstName")} ${receiver_user_doc.get("LastName")}`,
                            },
                            "full_names": `${sender_user_doc.get("FirstName")} ${sender_user_doc.get("LastName")}`,
                            "description": `To ${receiver_user_doc.get("FirstName")} ${receiver_user_doc.get("LastName")}`,
                            "wallet_balance_details": {
                                "wallet_balance_after_transaction": sender_user_doc.get("Balance") - user_data.amount,
                                "wallet_balance_before_transaction": sender_user_doc.get("Balance"),
                                "rule": "balance before must be larger than balance after",
                                "wallet_balances_difference": user_data.amount,
                                "transaction_fee_amount": 0,
                            },
                        },
                    }),
                }).then(async function (response) {
                    console.log("The supabase API was called successfully");
                }).catch(async function (error) {
                    console.log(error);

                    console.log(`There was an error submitting a withdrawal request boss`);
                });

                // creates a supabase for the receiver
                await axios({
                    "method": "post",
                    url: "https://srfjzsqimfuomlmjixsu.supabase.co/functions/v1/general_functions",
                    headers: {
                        "Content-Type": "application/json",
                        "Authorization": auth_token,
                    },
                    data: JSON.stringify({
                        "request_type": "create_update_row_record",
                        "operation_type": "create_row",
                        "table_name": "transactions",
                        "data": {
                            "is_public": false,
                            "country": "Zambia",
                            "number_of_views": 0,
                            "number_of_likes": 0,
                            "attended_to": false,
                            "status": "Completed",
                            "number_of_replies": 0,
                            "currency_symbol": "K",
                            "deposit_details": null,
                            "amount": user_data.amount,
                            "withdrawal_details": null,
                            "method": user_data.method,
                            "sent_received": "Received",
                            "p2p_recipient_details": null,
                            "transaction_type": "Transfer",
                            "currency": user_data.currency,
                            "comment": user_data["comment"],
                            "savings_account_details": null,
                            "transaction_fee_details": null,
                            "user_id": user_data.receiver_user_id,
                            "transaction_id": receiver_transaction_id,
                            "user_is_verified": receiver_user_doc.get("isVerified"),
                            "p2p_sender_details": {
                                "user_id": sender_user_doc.id,
                                "senders_wallet_balance_after_transaction":
                                    sender_wallet_bal_after_transaction,
                                "senders_wallet_balance_before_transaction":
                                    parseFloat(sender_user_doc.get("Balance")),
                                "phone_number": sender_user_doc.get("PhoneNumber"),
                                "full_names": `${sender_user_doc.get("FirstName")} ${sender_user_doc.get("LastName")}`,
                            },
                            "full_names": `${receiver_user_doc.get("FirstName")} ${receiver_user_doc.get("LastName")}`,
                            "description": `From ${sender_user_doc.get("FirstName")} ${sender_user_doc.get("LastName")}`,
                            "wallet_balance_details": {
                                "wallet_balance_after_transaction": receiver_user_doc.get("Balance") + user_data.amount,
                                "wallet_balance_before_transaction": receiver_user_doc.get("Balance"),
                                "rule": "balance after must be larger than balance before",
                                "wallet_balances_difference": user_data.amount,
                                "transaction_fee_amount": 0,
                            },
                        },
                    }),
                }).then(async function (response) {
                    console.log("The supabase API was called successfully");
                }).catch(async function (error) {
                    console.log(error);
                    console.log(`There was an error: trying to create a new referral_commission_transactions row in supabase`);
                });

                // deducts the amount from the sender's user document
                await db.collection("Users").doc(user_data.user_id).update({
                    Balance: admin.firestore.FieldValue.increment(-user_data.amount),
                });

                // credits the receiver's user document
                await db.collection("Users").doc(user_data.receiver_user_id).update({
                    Balance: admin.firestore.FieldValue.increment(user_data.amount),
                });

                // sends notification to the receiver
                await admin.messaging().sendToDevice(receiver_user_doc.get("NotificationToken"), {
                    notification: {
                        title: `🤑 ${sender_user_doc.get("FirstName")} sent you K${user_data.amount} 💰💸`,
                        icon: "@drawable/ic_stat_jayben_logo_1_044317_copy_3",
                        clickAction: "FLUTTER_NOTIFICATION_CLICK",
                        body: user_data["comment"],
                    },
                    data: {
                        userID: "",
                    },
                });

                // sends notification to the sender
                await admin.messaging().sendToDevice(sender_user_doc.get("NotificationToken"), {
                    notification: {
                        body: `You sent K${user_data.amount} to ${receiver_user_doc.get("FirstName")} ${receiver_user_doc.get("LastName")}`,
                        icon: "@drawable/ic_stat_jayben_logo_1_044317_copy_3",
                        clickAction: "FLUTTER_NOTIFICATION_CLICK",
                        title: "Money Sent! 💸",
                    },
                    data: {
                        userID: "",
                    },
                });

                // adds transaction timeline posts
                if (user_data.post_is_public) {
                    try {
                        await axios({
                            "method": "post",
                            url: "https://srfjzsqimfuomlmjixsu.supabase.co/functions/v1/general_functions",
                            headers: {
                                "Content-Type": "application/json",
                                "Authorization": auth_token,
                            },
                            data: JSON.stringify({
                                "request_type": "add_post_to_contacts",
                                "transaction_id": sender_transaction_id,
                                "user_id": user_data.user_id,
                                "media_details": [{
                                    "post_type": "text",
                                    "thumbnail_url": "",
                                    "media_caption": "",
                                    "media_type": "",
                                    "media_url": "",
                                }],
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

                res.status(200).send("Success");
            } else {
                // sends notification to the user
                await admin.messaging().sendToDevice(sender_user_doc.get("NotificationToken"), {
                    notification: {
                        body: `You have insufficient balance to conduct this transfer.`,
                        icon: "@drawable/ic_stat_jayben_logo_1_044317_copy_3",
                        clickAction: "FLUTTER_NOTIFICATION_CLICK",
                        title: "Transfer Declined",
                    },
                    data: {
                        userID: "",
                    },
                });

                res.status(200).send("Failed");
            }
        };

        console.log("Test point 6");

        try {
            // await send_money();
            // sends notification to the sender
            await admin.messaging().sendToDevice(sender_user_doc.get("NotificationToken"), {
                notification: {
                    body: `Internal transfers are currently offline. You will be notified when they are back online.`,
                    icon: "@drawable/ic_stat_jayben_logo_1_044317_copy_3",
                    clickAction: "FLUTTER_NOTIFICATION_CLICK",
                    title: "Transfer Unsuccessful",
                },
                data: {
                    userID: "",
                },
            });

            res.status(200).send("Failed");
        } catch (e) {
            console.log("Test point 9");

            console.log(e);

            res.status(200).send("Failed");
        }

        console.log("Test point 10");
    });

    // VERSION 3 - CREATES A TIMELINE POST WITH MEDIA (FOR user with v1.00.80 and above of Jayben)
    app.post('/v3/transfer/p2p/wallet', async (req, res) => {
        const user_data = req.body;

        /*
            BODY PREVIEW
            {
                "receiver_user_id": postInfo["receiver_map"]["user_id"],
                "amount": postInfo["payment_info"]["amount"],
                "media_details": [
                    {
                    "media_type": postInfo['media_type'],
                    "media_caption": postInfo['comment'],
                    "post_type": postInfo['media_type'],
                    "thumbnail_url": string,
                    "aspect_ratio": numeral,
                    "media_url": string,
                    }
                ],
                "comment": postInfo['comment'],
                "method": "Wallet transfer",
                "currency": box("currency"),
                "user_id": box("user_id"),
                "country": box("country"),
                "post_is_public": bool,
            }
        */

        const auth_token = "Bearer ";

        // gets the receiver's user document
        const receiver_user_doc = await db.collection("Users").doc(user_data.receiver_user_id).get();

        // gets the sender's user document
        const sender_user_doc = await db.collection("Users").doc(user_data.user_id).get();

        const receiver_transaction_id = uuidv4();
        const sender_transaction_id = uuidv4();

        // transfers money from the sender to the receiver
        const send_money = async () => {
            if (sender_user_doc.get("Balance") >= user_data["amount"]) {
                const recipient_wallet_bal_after_transaction =
                    parseFloat(receiver_user_doc.get("Balance").toString()) +
                    user_data["amount"];

                const sender_wallet_bal_after_transaction =
                    parseFloat(sender_user_doc.get("Balance").toString()) - user_data["amount"];

                // creates a supabase transaction row for the sender
                await axios({
                    "method": "post",
                    url: "https://srfjzsqimfuomlmjixsu.supabase.co/functions/v1/general_functions",
                    headers: {
                        "Content-Type": "application/json",
                        "Authorization": auth_token,
                    },
                    data: JSON.stringify({
                        "request_type": "create_update_row_record",
                        "operation_type": "create_row",
                        "table_name": "transactions",
                        "data": {
                            "country": "Zambia",
                            "number_of_views": 0,
                            "number_of_likes": 0,
                            "attended_to": false,
                            "status": "Completed",
                            "number_of_replies": 0,
                            "currency_symbol": "K",
                            "deposit_details": null,
                            "sent_received": "Sent",
                            "p2p_sender_details": null,
                            "amount": user_data.amount,
                            "withdrawal_details": null,
                            "method": user_data.method,
                            "user_id": user_data.user_id,
                            "transaction_type": "Transfer",
                            "currency": user_data.currency,
                            "comment": user_data["comment"],
                            "savings_account_details": null,
                            "transaction_fee_details": null,
                            "is_public": user_data.post_is_public,
                            "transaction_id": sender_transaction_id,
                            "user_is_verified": sender_user_doc.get("isVerified"),
                            "p2p_recipient_details": {
                                "user_id": receiver_user_doc.id,
                                "recipient_wallet_balance_after_transaction":
                                    recipient_wallet_bal_after_transaction,
                                "recipient_wallet_balance_before_transaction":
                                    parseFloat(receiver_user_doc.get("Balance")),
                                "phone_number": receiver_user_doc.get("PhoneNumber"),
                                "full_names": `${receiver_user_doc.get("FirstName")} ${receiver_user_doc.get("LastName")}`,
                            },
                            "full_names": `${sender_user_doc.get("FirstName")} ${sender_user_doc.get("LastName")}`,
                            "description": `To ${receiver_user_doc.get("FirstName")} ${receiver_user_doc.get("LastName")}`,
                            "wallet_balance_details": {
                                "wallet_balance_after_transaction": sender_user_doc.get("Balance") - user_data.amount,
                                "wallet_balance_before_transaction": sender_user_doc.get("Balance"),
                                "rule": "balance before must be larger than balance after",
                                "wallet_balances_difference": user_data.amount,
                                "transaction_fee_amount": 0,
                            },
                        },
                    }),
                }).then(async function (response) {
                    console.log("The supabase API was called successfully");
                }).catch(async function (error) {
                    console.log(error);

                    console.log(`There was an error submitting a withdrawal request boss`);
                });

                // creates a supabase transaction row for the receiver
                await axios({
                    "method": "post",
                    url: "https://srfjzsqimfuomlmjixsu.supabase.co/functions/v1/general_functions",
                    headers: {
                        "Content-Type": "application/json",
                        "Authorization": auth_token,
                    },
                    data: JSON.stringify({
                        "request_type": "create_update_row_record",
                        "operation_type": "create_row",
                        "table_name": "transactions",
                        "data": {
                            "country": "Zambia",
                            "number_of_views": 0,
                            "number_of_likes": 0,
                            "attended_to": false,
                            "status": "Completed",
                            "number_of_replies": 0,
                            "currency_symbol": "K",
                            "deposit_details": null,
                            "amount": user_data.amount,
                            "withdrawal_details": null,
                            "method": user_data.method,
                            "sent_received": "Received",
                            "p2p_recipient_details": null,
                            "transaction_type": "Transfer",
                            "currency": user_data.currency,
                            "comment": user_data["comment"],
                            "savings_account_details": null,
                            "transaction_fee_details": null,
                            "is_public": user_data.post_is_public,
                            "user_id": user_data.receiver_user_id,
                            "transaction_id": receiver_transaction_id,
                            "user_is_verified": receiver_user_doc.get("isVerified"),
                            "p2p_sender_details": {
                                "user_id": sender_user_doc.id,
                                "senders_wallet_balance_after_transaction":
                                    sender_wallet_bal_after_transaction,
                                "senders_wallet_balance_before_transaction":
                                    parseFloat(sender_user_doc.get("Balance")),
                                "phone_number": sender_user_doc.get("PhoneNumber"),
                                "full_names": `${sender_user_doc.get("FirstName")} ${sender_user_doc.get("LastName")}`,
                            },
                            "full_names": `${receiver_user_doc.get("FirstName")} ${receiver_user_doc.get("LastName")}`,
                            "description": `From ${sender_user_doc.get("FirstName")} ${sender_user_doc.get("LastName")}`,
                            "wallet_balance_details": {
                                "wallet_balance_after_transaction": receiver_user_doc.get("Balance") + user_data.amount,
                                "wallet_balance_before_transaction": receiver_user_doc.get("Balance"),
                                "rule": "balance after must be larger than balance before",
                                "wallet_balances_difference": user_data.amount,
                                "transaction_fee_amount": 0,
                            },
                        },
                    }),
                }).then(async function (response) {
                    console.log("The supabase API was called successfully");
                }).catch(async function (error) {
                    console.log(error);
                    console.log(`There was an error: trying to create a new referral_commission_transactions row in supabase`);
                });

                // deducts the amount from the sender's user document
                await db.collection("Users").doc(user_data.user_id).update({
                    Balance: admin.firestore.FieldValue.increment(-user_data.amount),
                });

                // credits the receiver's user document
                await db.collection("Users").doc(user_data.receiver_user_id).update({
                    Balance: admin.firestore.FieldValue.increment(user_data.amount),
                });

                // sends notification to the receiver
                await admin.messaging().sendToDevice(receiver_user_doc.get("NotificationToken"), {
                    notification: {
                        title: `🤑 ${sender_user_doc.get("FirstName")} sent you K${user_data.amount} 💰💸`,
                        icon: "@drawable/ic_stat_jayben_logo_1_044317_copy_3",
                        clickAction: "FLUTTER_NOTIFICATION_CLICK",
                        body: user_data["comment"],
                    },
                    data: {
                        userID: "",
                    },
                });

                // sends notification to the sender
                await admin.messaging().sendToDevice(sender_user_doc.get("NotificationToken"), {
                    notification: {
                        body: `You sent K${user_data.amount} to ${receiver_user_doc.get("FirstName")} ${receiver_user_doc.get("LastName")}`,
                        icon: "@drawable/ic_stat_jayben_logo_1_044317_copy_3",
                        clickAction: "FLUTTER_NOTIFICATION_CLICK",
                        title: "Money Sent! 💸",
                    },
                    data: {
                        userID: "",
                    },
                });

                // adds transaction timeline posts
                if (user_data.post_is_public) {
                    try {
                        await axios({
                            "method": "post",
                            url: "https://srfjzsqimfuomlmjixsu.supabase.co/functions/v1/general_functions",
                            headers: {
                                "Content-Type": "application/json",
                                "Authorization": auth_token,
                            },
                            data: JSON.stringify({
                                "request_type": "add_post_to_contacts",
                                "media_details": user_data.media_details,
                                "transaction_id": sender_transaction_id,
                                "user_id": user_data.user_id,
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

                res.status(200).send("Success");
            } else {
                // sends notification to the user
                await admin.messaging().sendToDevice(sender_user_doc.get("NotificationToken"), {
                    notification: {
                        body: `You have insufficient balance to conduct this transfer.`,
                        icon: "@drawable/ic_stat_jayben_logo_1_044317_copy_3",
                        clickAction: "FLUTTER_NOTIFICATION_CLICK",
                        title: "Transfer Declined",
                    },
                    data: {
                        userID: "",
                    },
                });

                res.status(200).send("Failed");
            }
        };

        console.log("Test point 6");

        try {
            // await send_money();

            // sends notification to the sender
            await admin.messaging().sendToDevice(sender_user_doc.get("NotificationToken"), {
                notification: {
                    body: `Internal transfers are currently offline. You will be notified when they are back online.`,
                    icon: "@drawable/ic_stat_jayben_logo_1_044317_copy_3",
                    clickAction: "FLUTTER_NOTIFICATION_CLICK",
                    title: "Transfer Unsuccessful",
                },
                data: {
                    userID: "",
                },
            });

            res.status(200).send("Failed");
        } catch (e) {
            console.log("Test point 9");

            console.log(e);

            res.status(200).send("Failed");
        }

        console.log("Test point 10");
    });

    // ========================

    app.post('/v1/users/verify_everyone', async (req, res) => {
        const all_user_accounts = await db.collection("Users").where("isVerified", "==", false).get();

        let operations = [];

        for (let i = 0; i < all_user_accounts.docs.length; i++) {
            operations.push(
                db.collection("Users").doc(all_user_accounts.docs[i].id).update({
                    "dateVerified": admin.firestore.FieldValue.serverTimestamp(),
                    "wasVerifiedDuringHalt": true,
                    "isVerified": true,
                }),
            );
        }

        console.log(`Number of users to verify is ${operations.length}`);

        try {
            console.log("Now running all operations...");

            await Promise.all(operations);

            console.log("Finished running all operations...");

            res.status(200).send("Success");
        } catch (e) {
            console.log("Test point 9");

            console.log(e);

            res.status(400).send("Failed");
        }

        console.log("Test point 10");
    });

    e.transactions = functions.runWith({
        timeoutSeconds: 180,
    }).https.onRequest(app);
};
