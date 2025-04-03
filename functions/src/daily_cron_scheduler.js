/* eslint-disable prefer-const */
/* eslint-disable camelcase */
/* eslint-disable no-unused-vars */
const functions = require("firebase-functions");
const admin = require("firebase-admin");
const needle = require("needle");
const axios = require("axios");
const uuid = require("uuid");
const db = admin.firestore();

module.exports = function (e) {
    // runs everyday at 24 hours (00:00) in CAT (Central African Time)
    e.dailyCronScheuler = functions.pubsub
        .schedule("00 00 * * *")
        .timeZone("Africa/Lusaka")
        .onRun(async (context) => {
            const dayToday = parseInt(Date().toString().substring(10, 8));
            // Gets the 1 - 31 value of the month
            const currentServerDate = Date().toString().substring(15, 4);
            // example: Apr 15 2022

            // ============= No access savings account related

            const noAccessSavingsAccount = async () => {
                const noAccessSavAccounts = await db.collection("Saving Accounts").where("Active", "==", true).where("AccountType", "==", "No Access Savings Account").get();

                if (noAccessSavAccounts.docs.lenth != 0) {
                    const updateAccounts = [];

                    let savings_balances = 0.0;

                    let numberOfSavAccountsToBeExpired = 0;

                    noAccessSavAccounts.forEach(async (doc) => {
                        // gets the savings account owner's user document
                        const ownersDoc = await db.collection("Users").where("UserID", "==", doc.get("UserID")).get();

                        // the savings accounts with 1 day left
                        if (doc.get("DaysLeft") === "1" && ownersDoc.docs.length != 0) {
                            const tranxID = uuid.v4();

                            // keeps a record of the accounts that 
                            // are about to be expired and closed
                            savings_balances += doc.get("Balance");

                            // counts the number of savings accounts
                            // that are about to be markes as inactive
                            numberOfSavAccountsToBeExpired++;

                            updateAccounts.push(
                                db.collection("Saving Accounts").doc(doc.id).update({
                                    NumberOfWithdraws: 1,
                                    isDeleted: true,
                                    Active: false,
                                    DaysLeft: "0",
                                    Expired: true,
                                    Balance: 0,
                                }),
                                // deactivates the savings account
                                db.collection("Users").doc(doc.get("UserID")).update({
                                    Balance: admin.firestore.FieldValue.increment(doc.get("Balance")),
                                }),
                                // increases the owner's balance
                                db.collection("Transactions").doc(tranxID).set({
                                    Comment: "",
                                    AttendedTo: true,
                                    Status: "Completed",
                                    TransactionID: tranxID,
                                    SentReceived: "Received",
                                    withdrawal_details: null,
                                    p2p_sender_details: null,
                                    TransactionType: "Deposit",
                                    Amount: doc.get("Balance"),
                                    p2p_recipient_details: null,
                                    UserID: ownersDoc.docs[0].id,
                                    transaction_fee_details: null,
                                    Method: 'From No Access Savings',
                                    Currency: ownersDoc.docs[0].get("Currency"),
                                    SavingsAccount: {
                                        AccountID: doc.get("AccountID"),
                                        AccountName: doc.get("AccountName"),
                                        AccountType: doc.get("AccountType"),
                                        AccountBalanceBeforeDeposit: doc.get("Balance"),
                                    },
                                    wallet_balance_details: {
                                        wallet_balance_after_transaction: ownersDoc.docs[0].get("Balance") + doc.get("Balance"),
                                        wallet_balance_before_transaction: ownersDoc.docs[0].get("Balance"),
                                        wallet_balances_difference: doc.get("Balance"),
                                    },
                                    // shows as a deposit to the user's acc
                                    PhoneNumber: `From account: ${doc.get("AccountName")}`,
                                    DateCreated: admin.firestore.FieldValue.serverTimestamp(),
                                    FullNames: ownersDoc.docs[0].get("FirstName") + " " + ownersDoc.docs[0].get("LastName"),
                                }),
                                // submits a deposit transaction
                                db.collection("Saving Accounts").doc(doc.id).collection("Transactions").doc(tranxID)
                                    .set({
                                        DateCreated: admin.firestore.FieldValue.serverTimestamp(),
                                        Amount: doc.get("Balance"),
                                        UserID: doc.get("UserID"),
                                        SavingsAccountID: doc.id,
                                        Status: "Completed",
                                        AttendedTo: true,
                                        Method: "Account Closure",
                                        TransactionID: tranxID,
                                        TransactionType: "Withdrawal",
                                        FullNames: doc.get("FullNames"),
                                        Currency: doc.get("Currency"),
                                        Txref: "",
                                        PhoneNumber: doc.get("UserPhoneNumber"),
                                    }),
                                // records the transction in the deactivated account
                                admin.messaging().sendToDevice(
                                    ownersDoc.docs[0].get("NotificationToken"), {
                                    notification: {
                                        title: 'Congrats 🥳',
                                        body: 'Your previously locked up money has been released and added to your wallet from No Access Account: ' + doc.get("AccountName"),
                                        icon: "@drawable/ic_stat_jayben_logo_1_044317_copy_3",
                                        clickAction: "FLUTTER_NOTIFICATION_CLICK",
                                    },
                                    data: {
                                        UserID: "",
                                    },
                                }),
                                // send notification
                            );
                        } else if (doc.get("DaysLeft") != "1" && ownersDoc.docs.length != 0) {
                            // if the days left is greater than 1, reduce the days
                            const daysLeftInt = parseInt(doc.get("DaysLeft"));
                            const newDaysLeft = daysLeftInt - 1;
                            updateAccounts.push(
                                db
                                    .collection("Saving Accounts")
                                    .doc(doc.id)
                                    .update({
                                        DaysLeft: newDaysLeft.toString(),
                                    }),
                                // reduces the days left count
                            );
                        }

                        // updates the admins metric document
                        await db.collection("Admin").doc("Metrics").update({
                            totalNumberOfActiveSavingsAccounts: admin.firestore.FieldValue.increment(-numberOfSavAccountsToBeExpired),
                            totalAmountInSavings: admin.firestore.FieldValue.increment(-savings_balances),
                        });
                    });

                    await Promise.all(updateAccounts);
                    // closes accounts & reduces the days left
                }
            };

            // ============= Time Limited Transactions related

            const timeLimitedTrancactions = async () => {
                const getTimeLtdTrax = await db.collection("Time Limited Transactions").where("hasExpired", "==", false).where("DateCreatedFormatted", "!=", currentServerDate).get();

                let operations = [];

                for (let i = 0; i < getTimeLtdTrax.docs.length; i++) {
                    if (getTimeLtdTrax.docs[i].get("NumberOfDaysLeft") > 1) {
                        // if the number of days is more than 1, just reduce the daysLeft count...
                        operations.push(db
                            .collection("Time Limited Transactions")
                            .doc(getTimeLtdTrax.docs[i].get("TransactionID"))
                            .update({
                                NumberOfDaysLeft: admin.firestore.FieldValue.increment(-1),
                            }));
                    } else if (getTimeLtdTrax.docs[i].get("NumberOfDaysLeft") <= 1) {
                        // if the daysLeft is 1 or less than 1, close acc, record tranx,
                        // increase receiver bal & send notification...

                        operations.push(db
                            .collection("Time Limited Transactions")
                            .doc(getTimeLtdTrax.docs[i].get("TransactionID"))
                            .update({
                                hasExpired: true,
                                HasTimeLimit: false,
                                NumberOfDaysLeft: 0,
                                Status: "Completed",
                            }),
                            db.collection("Transactions").doc(getTimeLtdTrax.docs[i].get("TransactionID")).set({
                                AttendedTo: true,
                                Status: "Completed",
                                TransactionType: "Transfer",
                                Method: 'Time limited Wallet Transfer',
                                Amount: getTimeLtdTrax.docs[i].get("Amount"),
                                UserID: getTimeLtdTrax.docs[i].get("UserID"),
                                Currency: getTimeLtdTrax.docs[i].get("Currency"),
                                FullNames: getTimeLtdTrax.docs[i].get("FullNames"),
                                Comment: getTimeLtdTrax.docs[i].get("SentReceived"),
                                PhoneNumber: getTimeLtdTrax.docs[i].get("PhoneNumber"),
                                SentReceived: getTimeLtdTrax.docs[i].get("SentReceived"),
                                DateCreated: admin.firestore.FieldValue.serverTimestamp(),
                                TransactionID: getTimeLtdTrax.docs[i].get("TransactionID"),
                            }),
                        );

                        // updates the receiver's balance
                        if (getTimeLtdTrax.docs[i].get("SentReceived") == "Received") {
                            operations.push(db
                                .collection("Users")
                                .doc(getTimeLtdTrax.docs[i].get("UserID"))
                                .update({
                                    Balance: admin.firestore.FieldValue.increment(getTimeLtdTrax.docs[i].get("Amount")),
                                }));
                        }

                        // gets user's doc to get their notificaiton token
                        const userDataAfter = await db
                            .collection("Users")
                            .doc(getTimeLtdTrax.docs[i].get("UserID"))
                            .get();

                        if (userDataAfter.get("NotificationToken") != "") {
                            // sends notification to the user
                            operations.push(admin.messaging().sendToDevice(
                                userDataAfter.get("NotificationToken"), {
                                notification: {
                                    body: 'Congrats! 🥳 One of your Time Limited Transcations has just been completed. Check your transactions to view more details.',
                                    icon: "@drawable/ic_stat_jayben_logo_1_044317_copy_3",
                                    clickAction: "FLUTTER_NOTIFICATION_CLICK",
                                    title: "Transaction Successful 🥳",
                                },
                                data: {
                                    UserID: "",
                                },
                            }));
                        }
                    }
                }

                await Promise.all(operations);
            };

            // ============ Metrics

            // records the daily metrics
            const updateDailyAppWideMetrics = async () => {
                let operations = [];

                // gets a snapshot of the day's metrics
                const app_wide_metrics_doc = await db.collection("Admin").doc("Metrics").get();

                // 1). creates a record of the current daily metrics
                // 2). resets the day's metrics to be ready for the next day
                operations.push(db.collection("Admin").doc("Metrics").collection("Growth").add({
                    "DateCreated": admin.firestore.FieldValue.serverTimestamp(),
                    ...app_wide_metrics_doc.data(),
                }), db.collection("Admin").doc("Metrics").update({
                    LastUpdated: admin.firestore.FieldValue.serverTimestamp(),
                    dailyNumberOfTransfersToNoAccessAccounts: 0,
                    dailyTotalAmountSavedInNoAccessAccounts: 0,
                    dailyWithdrawalTotalProcessed: 0,
                    dailyNumberOfWithdrawalsMade: 0,
                    dailyDepositsTotalProcessed: 0,
                    dailyNumberOfDepositsMade: 0,
                    dailyNewUserSignUps: 0,
                }));

                await Promise.all(operations);
            };

            // calls the supaabase api to create a copy of the app's daily metrics
            const call_supabase_record_daily_metrics_api = async (data, transaction_type) => {
                // gets the public supabase keys document
                const supabase_keys = await db.collection("Admin").doc("Legal").collection("Supabase").doc("keys").get();

                await axios({
                    "method": "post",
                    url: "https://srfjzsqimfuomlmjixsu.supabase.co/functions/v1/general_functions",
                    headers: {
                        "Authorization": `Bearer ${supabase_keys.get("anon_key")}`,
                        "Content-Type": "application/json",
                    },
                    data: JSON.stringify({
                        "request_type": "record_daily_metrics"

                    }),
                }).then(async function (response) {
                    console.log("The supabase API was called successfully");
                }).catch(async function (error) {
                    console.log(error);

                    console.log(`There was an error: ${transaction_type}`);
                });
            };

            // calls a supabase API to create daily copies of all user accounts 
            const create_daily_copies_of_each_user_record = async () => {
                await axios({
                    "method": "post",
                    url: "https://srfjzsqimfuomlmjixsu.supabase.co/functions/v1/general_functions",
                    headers: {
                        "Authorization": `Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InNyZmp6c3FpbWZ1b21sbWppeHN1Iiwicm9sZSI6ImFub24iLCJpYXQiOjE2OTIyNjcxODUsImV4cCI6MjAwNzg0MzE4NX0.NpqWE-1xwM3ZLTbR8Er01GfuKjyijy0IlseWc4UCdSU`,
                        "Content-Type": "application/json",
                    },
                    data: JSON.stringify({
                        "request_type": "record_all_user_accounts"
                    }),
                }).then(async function (response) {
                    console.log(response.data);
                }).catch(async function (error) {
                    console.log(error);
                });
            };

            // =============

            // gets the document that stores the sms api keys
            const supportDoc = await db.collection("Admin").doc("Legal").collection("APIs").doc("PaymentAPI").get();

            // gets justin's user document
            const justins_user_document = await db.collection("Users").doc("ONQUtMhhrRQS82CJBYzppRcIeqr2").get();

            try {
                await Promise.all([
                    create_daily_copies_of_each_user_record(),
                    call_supabase_record_daily_metrics_api(),
                    updateDailyAppWideMetrics(),
                    timeLimitedTrancactions(),
                    noAccessSavingsAccount(),
                ]);

                // sends Justin a notification receipt of a successful daily cron job
                await admin.messaging().sendToDevice(
                    [justins_user_document.get("NotificationToken")], {
                    notification: {
                        body: `Just ran the dialy cron scheduler and it was successful`,
                        icon: "@drawable/ic_stat_jayben_logo_1_044317_copy_3",
                        clickAction: "FLUTTER_NOTIFICATION_CLICK",
                        title: "Successful Daily Cron Scheduler",
                    },
                    data: {
                        UserID: "",
                    },
                });
            } catch (e) {
                console.log(e);

                // sends Justin, benson & thaddeus a new user sign up alert
                await admin.messaging().sendToDevice(
                    [justins_user_document.get("NotificationToken")], {
                    notification: {
                        body: `There was a problem running the daily cron scheduler sir`,
                        icon: "@drawable/ic_stat_jayben_logo_1_044317_copy_3",
                        clickAction: "FLUTTER_NOTIFICATION_CLICK",
                        title: "Failed Daily Cron Scheduler",
                    },
                    data: {
                        UserID: "",
                    },
                });
            }

            return null;
        });
};
