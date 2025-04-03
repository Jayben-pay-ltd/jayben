/* eslint-disable no-unused-vars */
/* eslint-disable camelcase */
/**
 * @module africastalking
 * if africastalking isn't being found/underfined, 
 * delete package-lock.json file and try to redeploy
*/

const functions = require("firebase-functions");
const cors = require("cors")({ origin: true });
const admin = require("firebase-admin");
const express = require('express');
const needle = require("needle");
const axios = require("axios");
const db = admin.firestore();
const uuid = require("uuid");
const app = express();
app.use(express.json());
app.use(express.urlencoded({ extended: true }));
app.use(cors);

module.exports = function (e) {
    e.migrateTransactionCreation = functions.firestore
        .document("Transactions/{TransactionID}")
        .onCreate(async (snap, context) => {
            const user_data = snap.data();
            const method = user_data.Method;
            const sent_received = user_data.SentReceived;
            const tranx_type = user_data.TransactionType;

            // gets the transaction owner's document
            const transaction_owner_doc = await db.collection("Users").doc(user_data.UserID).get();

            // gets the public supabase keys document
            const supabase_keys = await db.collection("Admin").doc("Legal").collection("Supabase").doc("keys").get();

            // calls the supaabase api to create a copy of the transaction
            const call_supabase_api = async (data, transaction_type) => {
                await axios({
                    "method": "post",
                    url: "https://srfjzsqimfuomlmjixsu.supabase.co/functions/v1/migration_functions",
                    headers: {
                        "Authorization": `Bearer ${supabase_keys.get("anon_key")}`,
                        "Content-Type": "application/json",
                    },
                    data: JSON.stringify(data),
                }).then(async function (response) {
                    console.log("The supabase API was called successfully");
                }).catch(async function (error) {
                    console.log(error);

                    console.log(`There was an error: ${transaction_type}`);
                });
            };

            if (tranx_type === "Withdrawal") {
                // when user is moving money from Jayben wallet to their bank account/mobile money account

                await call_supabase_api(
                    {
                        "request_type": "Withdrawal Transaction: To Bank, Mobile money",
                        "data": {
                            "is_public": false,
                            "country": "Zambia",
                            "number_of_views": 0,
                            "number_of_likes": 0,
                            "number_of_replies": 0,
                            "currency_symbol": "K",
                            "deposit_details": null,
                            "user_is_verified": false,
                            "amount": user_data.Amount,
                            "status": user_data.Status,
                            "p2p_sender_details": null,
                            "method": user_data.Method,
                            "user_id": user_data.UserID,
                            "comment": user_data.Comment,
                            "p2p_recipient_details": null,
                            "currency": user_data.Currency,
                            "savings_account_details": null,
                            "full_names": user_data.FullNames,
                            "withdrawal_details": {
                                "bank_branch": "",
                                "bank_address": "",
                                "bank_sort_code": "",
                                "bank_swift_code": "",
                                "bank_country": "Zambia",
                                "bank_routing_number": "",
                                "bank_name": user_data.WithdrawInfo.BankName,
                                "bank_account_holder_name": user_data.FullNames,
                                "phone_number": user_data.WithdrawInfo.PhoneNumber,
                                "picked_withdraw_method": user_data.WithdrawInfo.PaymentMethod,
                                "bank_account_number": user_data.WithdrawInfo.BankAccountNumber,
                                "final_withdraw_amount": user_data.WithdrawInfo.AmountBeforeFee,
                                "withdraw_amount_plus_fee": user_data.WithdrawInfo.AmountPlusfee,
                                "withdraw_amount_minus_fee": user_data.WithdrawInfo.AmountBeforeFee,
                            },
                            "attended_to": user_data.AttendedTo,
                            "description": user_data.PhoneNumber,
                            "sent_received": user_data.SentReceived,
                            "transaction_id": user_data.TransactionID,
                            "transaction_type": user_data.TransactionType,
                            "transaction_fee_details": {
                                "transaction_international_bank_tranfer_fee": user_data.WithdrawInfo.IntlBankTransferFee,
                                "transaction_local_bank_tranfer_fee": user_data.WithdrawInfo.LocalBankTransferFee,
                                "transaction_total_fee_percentage": user_data.WithdrawInfo.WithdrawFeePercent,
                                "transaction_fee_amount": user_data.WithdrawInfo.TotalFee,
                                "transaction_total_fee_currency": user_data.Currency,
                                "transcation_bank_transfer_fee_currency": "USD",
                            },
                            "wallet_balance_details": {
                                "wallet_balance_before_transaction": transaction_owner_doc.get("Balance") + user_data.Amount,
                                "wallet_balance_after_transaction": transaction_owner_doc.get("Balance"),
                                "wallet_balances_difference": user_data.Amount,
                            },
                        },
                    }, "Withdrawal - from jayben wallet to bank or mobile money");
            } else if (tranx_type === "Airtime Purchase") {
                // when user has bought airtime using their wallet balance

                await call_supabase_api(
                    {
                        "request_type": "Airtime Purchase Transaction: From jayben wallet",
                        "data": {
                            "is_public": true,
                            "country": "Zambia",
                            "number_of_views": 0,
                            "number_of_likes": 0,
                            "number_of_replies": 0,
                            "currency_symbol": "K",
                            "deposit_details": null,
                            "user_is_verified": false,
                            "withdrawal_details": null,
                            "amount": user_data.Amount,
                            "status": user_data.Status,
                            "p2p_sender_details": null,
                            "method": user_data.Method,
                            "user_id": user_data.UserID,
                            "comment": user_data.Comment,
                            "p2p_recipient_details": null,
                            "currency": user_data.Currency,
                            "transaction_fee_details": null,
                            "savings_account_details": null,
                            "full_names": user_data.FullNames,
                            "attended_to": user_data.AttendedTo,
                            "description": user_data.PhoneNumber,
                            "sent_received": user_data.SentReceived,
                            "transaction_id": user_data.TransactionID,
                            "transaction_type": user_data.TransactionType,
                            "wallet_balance_details": {
                                "wallet_balance_before_transaction": transaction_owner_doc.get("Balance") + user_data.Amount,
                                "wallet_balance_after_transaction": transaction_owner_doc.get("Balance"),
                                "wallet_balances_difference": user_data.Amount,
                            },
                        },
                    }, "Withdrawal - from jayben wallet to bank or mobile money");
            } else if (tranx_type === "Savings Transfer") {
                // when user is moving money from Jayben wallet to a no access savings account

                const savings_account_before_transation = user_data.SavingsAccount.AccountBalanceBeforeDeposit;
                const savings_account_after_transaction = savings_account_before_transation + user_data.Amount;

                // gets the savings account document
                const savings_account_document = await db.collection("Saving Accounts").doc(user_data.SavingsAccount.AccountID).get();

                await call_supabase_api(
                    {
                        "request_type": "Savings Transfer Transaction: To No access savings account",
                        "data": {
                            "is_public": true,
                            "country": "Zambia",
                            "number_of_views": 0,
                            "number_of_likes": 0,
                            "number_of_replies": 0,
                            "currency_symbol": "K",
                            "deposit_details": null,
                            "user_is_verified": false,
                            "amount": user_data.Amount,
                            "status": user_data.Status,
                            "withdrawal_details": null,
                            "method": user_data.Method,
                            "p2p_sender_details": null,
                            "user_id": user_data.UserID,
                            "comment": user_data.Comment,
                            "p2p_recipient_details": null,
                            "currency": user_data.Currency,
                            "transaction_fee_details": null,
                            "full_names": user_data.FullNames,
                            "attended_to": user_data.AttendedTo,
                            "description": user_data.PhoneNumber,
                            "sent_received": user_data.SentReceived,
                            "transaction_id": user_data.TransactionID,
                            "transaction_type": user_data.TransactionType,
                            "savings_account_details": {
                                "savings_account_id": user_data.SavingsAccount.AccountID,
                                "savings_account_name": user_data.SavingsAccount.AccountName,
                                "savings_account_type": user_data.SavingsAccount.AccountType,
                                "savings_account_days_left": savings_account_document.get("DaysLeft"),
                                "savings_account_balance_after_transaction": savings_account_after_transaction,
                                "savings_account_balance_before_transaction": savings_account_before_transation,
                            },
                            "wallet_balance_details": {
                                "wallet_balance_before_transaction": transaction_owner_doc.get("Balance") + user_data.Amount,
                                "wallet_balance_after_transaction": transaction_owner_doc.get("Balance"),
                                "wallet_balances_difference": user_data.Amount,
                            },
                        },
                    }, "Savings transfer - from jayben wallet to NAS account");
            } else if (tranx_type === "Transfer") {
                // when moving money from one Jayben Wallet to another Jayben Wallet

                if (sent_received == "Received") {
                    // gets the sender's user document
                    const sender_doc = await db.collection("Users").doc(user_data.sender.UserID).get();

                    // creates the receiver's transaction row in supabase
                    await call_supabase_api(
                        {
                            "request_type": "Transfer Transaction: Sender",
                            "data": {
                                "is_public": true,
                                "country": "Zambia",
                                "number_of_views": 0,
                                "number_of_likes": 0,
                                "number_of_replies": 0,
                                "currency_symbol": "K",
                                "deposit_details": null,
                                "user_is_verified": false,
                                "amount": user_data.Amount,
                                "status": user_data.Status,
                                "withdrawal_details": null,
                                "method": user_data.Method,
                                "user_id": user_data.UserID,
                                "comment": user_data.Comment,
                                "p2p_recipient_details": null,
                                "currency": user_data.Currency,
                                "savings_account_details": null,
                                "transaction_fee_details": null,
                                "full_names": user_data.FullNames,
                                "attended_to": user_data.AttendedTo,
                                "description": user_data.PhoneNumber,
                                "sent_received": user_data.SentReceived,
                                "transaction_id": user_data.TransactionID,
                                "transaction_type": user_data.TransactionType,
                                "p2p_sender_details": {
                                    "user_id": user_data.sender.UserID,
                                    "full_names": user_data.sender.FullNames,
                                    "phone_number": user_data.sender.PhoneNumber,
                                    "senders_wallet_balance_after_transaction": sender_doc.get("Balance"),
                                    "senders_wallet_balance_before_transaction": sender_doc.get("Balance") + user_data.Amount,
                                },
                                "wallet_balance_details": {
                                    "wallet_balance_before_transaction": transaction_owner_doc.get("Balance") - user_data.Amount,
                                    "wallet_balance_after_transaction": transaction_owner_doc.get("Balance"),
                                    "wallet_balances_difference": user_data.Amount,
                                },
                            },
                        }, "Transfer - jayben wallet to jayben wallet");
                } else {
                    // gets the receiver's user document
                    const receiver_doc = await db.collection("Users").doc(user_data.sender.UserID).get();

                    await call_supabase_api(
                        {
                            "request_type": "Transfer Transaction: Receiver",
                            "data": {
                                "is_public": true,
                                "country": "Zambia",
                                "number_of_views": 0,
                                "number_of_likes": 0,
                                "currency_symbol": "K",
                                "number_of_replies": 0,
                                "deposit_details": null,
                                "user_is_verified": false,
                                "amount": user_data.Amount,
                                "status": user_data.Status,
                                "withdrawal_details": null,
                                "method": user_data.Method,
                                "p2p_sender_details": null,
                                "user_id": user_data.UserID,
                                "comment": user_data.Comment,
                                "currency": user_data.Currency,
                                "savings_account_details": null,
                                "transaction_fee_details": null,
                                "full_names": user_data.FullNames,
                                "attended_to": user_data.AttendedTo,
                                "description": user_data.PhoneNumber,
                                "sent_received": user_data.SentReceived,
                                "transaction_id": user_data.TransactionID,
                                "transaction_type": user_data.TransactionType,
                                "p2p_recipient_details": {
                                    "user_id": user_data.receiver.UserID,
                                    "full_names": user_data.receiver.FullNames,
                                    "phone_number": user_data.receiver.PhoneNumber,
                                    "recipient_wallet_balance_after_transaction": receiver_doc.get("Balance"),
                                    "recipient_wallet_balance_before_transaction": receiver_doc.get("Balance") - user_data.Amount,
                                },
                                "wallet_balance_details": {
                                    "wallet_balance_before_transaction": transaction_owner_doc.get("Balance") + user_data.Amount,
                                    "wallet_balance_after_transaction": transaction_owner_doc.get("Balance"),
                                    "wallet_balances_difference": user_data.Amount,
                                },
                            },
                        }, "Transfer - jayben wallet to jayben wallet");
                }
            } else if (tranx_type === "Deposit" && method === "From No Access Savings") {
                // when money is moving from a no access savings account to a Jayben wallet

                await call_supabase_api(
                    {
                        "request_type": "Deposit Transaction: No access savings account",
                        "data": {
                            "is_public": false,
                            "country": "Zambia",
                            "number_of_views": 0,
                            "number_of_likes": 0,
                            "number_of_replies": 0,
                            "currency_symbol": "K",
                            "deposit_details": null,
                            "user_is_verified": false,

                            "amount": user_data.Amount,
                            "status": user_data.Status,
                            "withdrawal_details": null,
                            "method": user_data.Method,
                            "user_id": user_data.UserID,
                            "comment": user_data.Comment,
                            "p2p_recipient_details": null,
                            "currency": user_data.Currency,
                            "savings_account_details": null,
                            "transaction_fee_details": null,
                            "full_names": user_data.FullNames,
                            "attended_to": user_data.AttendedTo,
                            "description": user_data.PhoneNumber,
                            "sent_received": user_data.SentReceived,
                            "transaction_id": user_data.TransactionID,
                            "transaction_type": user_data.TransactionType,
                            "p2p_sender_details": null,
                            "wallet_balance_details": {
                                "wallet_balance_before_transaction": transaction_owner_doc.get("Balance") - user_data.Amount,
                                "wallet_balance_after_transaction": transaction_owner_doc.get("Balance"),
                                "wallet_balances_difference": user_data.Amount,
                            },
                        },
                    }, "Deposit - From no access savings account");
            } else if (tranx_type === "Deposit" && method != "From No Access Savings") {
                // when money is being deposited from bank or mobile money to a Jayben wallet

                await call_supabase_api({
                    "request_type": "Deposit Transaction: Bank, Mobile money",
                    "data": {
                        "is_public": false,
                        "country": "Zambia",
                        "number_of_views": 0,
                        "number_of_likes": 0,
                        "number_of_replies": 0,
                        "currency_symbol": "K",
                        "user_is_verified": false,
                        "amount": user_data.Amount,
                        "status": user_data.Status,
                        "withdrawal_details": null,
                        "method": user_data.Method,
                        "p2p_sender_details": null,
                        "user_id": user_data.UserID,
                        "comment": user_data.Comment,
                        "p2p_recipient_details": null,
                        "currency": user_data.Currency,
                        "savings_account_details": null,
                        "transaction_fee_details": null,
                        "full_names": user_data.FullNames,
                        "attended_to": user_data.AttendedTo,
                        "description": user_data.PhoneNumber,
                        "sent_received": user_data.SentReceived,
                        "transaction_id": user_data.TransactionID,
                        "transaction_type": user_data.TransactionType,
                        "deposit_details": {
                            "provider": user_data.Details.Provider,
                            "deposit_method": user_data.Details.DepositMethod,
                            "charge_depositer_the_deposit_fee_from_provider": user_data.Details.ChargeMe,
                        },
                        "wallet_balance_details": {
                            "wallet_balance_before_transaction": transaction_owner_doc.get("Balance") - user_data.Amount,
                            "wallet_balance_after_transaction": transaction_owner_doc.get("Balance"),
                            "wallet_balances_difference": user_data.Amount,
                        },
                    },
                }, "Deposit - From bank or mobile money");
            }

            return "";
        });

    e.migrateTransactionUpdate = functions.firestore
        .document("Transactions/{TransactionID}")
        .onUpdate(async (change, context) => {
            const user_data_after = change.after.data();

            // only executes for withdrawal transaction updates
            if (user_data_after.TransactionType === "Withdrawal") {
                // gets the public supabase keys document
                const supabase_keys = await db.collection("Admin").doc("Legal").collection("Supabase").doc("keys").get();

                // calls a supabase api that updates a transaction's status
                await axios({
                    "method": "post",
                    url: "https://srfjzsqimfuomlmjixsu.supabase.co/functions/v1/migration_functions",
                    headers: {
                        "Authorization": `Bearer ${supabase_keys.get("anon_key")}`,
                        "Content-Type": "application/json",
                    },
                    data: JSON.stringify({
                        "request_type": "Update Transaction: for withdrawal transactions",
                        "data": {
                            "transaction_id": user_data_after.TransactionID,
                            "status": user_data_after.Status,
                        },
                    }),
                }).then(async function (response) {
                    console.log("The supabase API was called succeffully");
                }).catch(async function (error) {
                    console.log(error);

                    console.log(`There was an error copying while updating an existing transaction document`);
                });

                // updates the admin metrics document
                await db.collection("Admin").doc("Metrics").update({
                    dailyWithdrawalTotalProcessed: admin.firestore.FieldValue.increment(user_data_after.Amount),
                    numberOfPendingWithdrawals: admin.firestore.FieldValue.increment(-1),
                });

                // gets the transaction owner's account document
                const transaction_owner_user_doc = await db.collection("Users").doc(user_data_after.UserID).get();

                // removes the "+26" from the phone number
                // example: from +260977980371 to 0977980371
                const tranx_owner_phone_number = transaction_owner_user_doc.get("PhoneNumber").replace("+26", "");

                // removes the "To " from the phone number/description
                // example: from "To 0977980371" to "0977980371"
                const recipient_phone_number = user_data_after.PhoneNumber.replace("To ", "");

                if (user_data_after.Status === "Completed" && user_data_after.WithdrawInfo.PaymentMethod != "Bank") {
                    // sends a notification to the sender's app
                    await admin.messaging().sendToDevice(
                        transaction_owner_user_doc.get("NotificationToken"), {
                        notification: {
                            title: "Withdrawal Completed",
                            body: `Hello customer, your withdraw of ${user_data_after.Currency} ${user_data_after.Amount} has been completed. Withdraw ID ${user_data_after.TransactionID}`,
                            icon: "@drawable/ic_stat_jayben_logo_1_044317_copy_3",
                            clickAction: "FLUTTER_NOTIFICATION_CLICK",
                        },
                        data: {
                            UserID: "",
                        },
                    });

                    console.log(`The sender's phone number is ${tranx_owner_phone_number} & the recipient number is ${recipient_phone_number}`);

                    // if the recipient number isn't the sender's phone number,
                    // it sends a referral sms to the receiver to acquire them as a new user
                    if (tranx_owner_phone_number != recipient_phone_number) {
                        await needle(
                            'post',
                            'https://www.smszambia.com/smsservice/jsonapi',
                            JSON.stringify(
                                {
                                    "auth": {
                                        "username": "sm7-jayben",
                                        "password": "J@yEnt",
                                        "sender_id": "Jayben",
                                    }, "messages": [
                                        {
                                            "phone": `${recipient_phone_number}`,
                                            "message": `Hello there, you have just been sent ${user_data_after.Currency} ${user_data_after.Amount} by ${user_data_after.FullNames} to your Mobile Money, via Jayben - Lock & Save Money App (Available on Android and iOS).`,
                                        },
                                    ],
                                },
                            ), { json: true });
                    }
                }
            }

            return "";
        });

    // gets a deposit link from sparco and returns it to the merchant
    app.post('/v1/migrate_inwards/users/update/balance', async (req, res) => {
        const body = req.body;

        /*
            body preview
            {
                "user_id": "string",
                "amount": "double/float"
            }
        */

        try {
            // edits the user's balance
            await db.collection("Users").doc(body.user_id).update({
                Balance: admin.firestore.FieldValue.increment(body.amount),
            });

            res.status(200).send("Success");
        } catch (e) {
            console.log(e);

            res.status(400).send("Failed");
        }
    });

    e.migrate = functions.https.onRequest(app);
};
