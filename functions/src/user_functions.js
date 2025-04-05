/* eslint-disable prefer-const */
/* eslint-disable no-unused-vars */
/* eslint-disable camelcase */
/**
 * @module africastalking
 * if africastalking isn't being found/underfined, 
 * delete package-lock.json file and try to redeploy
*/

const africastalking = require("africastalking");
const functions = require("firebase-functions");
const admin = require("firebase-admin");
const needle = require("needle");
const axios = require("axios");
const db = admin.firestore();

module.exports = function (e) {
    e.onNewUser = functions.firestore
        .document("Users/{UserID}")
        .onCreate(async (snap, context) => {
            let promises = [];
            const userData = snap.data();
            const adminDoc = await db.collection("Admin").doc("Legal").get();
            const supabase_keys = await db.collection("Admin").doc("Legal").collection("Supabase").doc("keys").get();

            // bans all new accounts due to bank of zambia order
            await db.collection("Users").doc(userData.UserID).update({
                "OnHoldReason": "BOZ Cease & desist",
                "OnHold": true,
            });

            // if someone has the user as their contact, this marks
            // the contact record to show that they are now on jayben
            const mark_all_contacts_as_jayben_user = async () => {
                axios({
                    "method": "post",
                    url: "https://srfjzsqimfuomlmjixsu.supabase.co/functions/v1/general_functions",
                    headers: {
                        "Authorization": `Bearer ${supabase_keys.get("anon_key")}`,
                        "Content-Type": "application/json",
                    },
                    data: JSON.stringify({
                        "request_type": "mark_contact_as_existing_jayben_user",
                        "user_id": userData.UserID,
                    }),
                }).then(async function (response) {
                    console.log("The supabase API was called successfully");
                }).catch(async function (error) {
                    console.log(error);
                });
            };

            // creates a user row record in supabase
            const copy_user_to_supabase = async () => {
                axios({
                    "method": "post",
                    url: "https://srfjzsqimfuomlmjixsu.supabase.co/functions/v1/general_functions",
                    headers: {
                        "Authorization": `Bearer ${supabase_keys.get("anon_key")}`,
                        "Content-Type": "application/json",
                    },
                    data: JSON.stringify({
                        "request_type": "create_update_row_record",
                        "operation_type": "create_row",
                        "table_name": "users",
                        "data": {
                            "last_time_online_timestamp": userData.LastTimeOnline.toDate().toISOString(),
                            'date_of_birth': userData.DateOfBirth.toDate().toISOString(),
                            "number_of_savings_deposits_ever_made_to_nas_accounts": 0,
                            'created_at': userData.DateJoined.toDate().toISOString(),
                            "current_device_ip_address": userData.CurrentIPAddress,
                            "current_build_version": userData.CurrentBuildVersion,
                            "username_searchable": userData.Username_searchable,
                            "email_address_lowercase": userData.Email_lowercase,
                            "current_activity_level_completion_percentage": 0,
                            "number_of_contacts_uploaded_with_jayben_accs": 0,
                            "notification_token": userData.NotificationToken,
                            "current_os_platform": userData.CurrentPlatform,
                            "account_kyc_is_verified": userData.isVerified,
                            "total_amount_ever_saved_in_nas_accounts": 0,
                            "timeline_privacy_setting": "All contacts",
                            "currency_symbol": userData.CurrencySymbol,
                            "profile_image_url": userData.ProfileImage,
                            'is_currently_online': userData.isOnline,
                            "number_of_wallet_deposits_ever_made": 0,
                            "total_number_of_contacts_uploaded": 0,
                            "referral_code": userData.ReferralCode,
                            "account_is_on_hold": userData.OnHold,
                            "blocked_peoples_user_details": null,
                            "daily_user_minutes_spent_in_app": 0,
                            "country_code": userData.CountryCode,
                            "physical_address": userData.Address,
                            'phone_number': userData.PhoneNumber,
                            "account_type": userData.AccountType,
                            "daily_minutes_spent_in_timeline": 0,
                            'first_name': userData.FirstName,
                            "nas_deposits_are_allowed": true,
                            "email_address": userData.Email,
                            "total_amount_ever_deposted": 0,
                            "withdrawals_are_allowed": true,
                            'last_name': userData.LastName,
                            "user_code": userData.UserCode,
                            'username': userData.Username,
                            "currency": userData.Currency,
                            "deposits_are_allowed": true,
                            'country': userData.Country,
                            "black_listed_user_ids": [],
                            "balance": userData.Balance,
                            'user_id': userData.UserID,
                            "show_update_alert": false,
                            "account_is_banned": false,
                            "points": userData.Points,
                            'gender': userData.Gender,
                            "pin_code": userData.PIN,
                            "current_device_id": "",
                            'city': userData.City,
                            "activity_level": 1,
                        },
                    }),
                }).then(async function (response) {
                    // marks the user's contact records as jayben user
                    await mark_all_contacts_as_jayben_user();
                    console.log("The supabase API was called successfully");
                }).catch(async function (error) {
                    console.log(error);
                });
            };

            promises.push(
                admin.messaging().sendToDevice(userData.NotificationToken, {
                    notification: {
                        body: `Hi ${userData.FirstName} 👋, welcome to Jayben. Let's create you a piggybank and show you how it works.`,
                        icon: "@drawable/ic_stat_jayben_logo_1_044317_copy_3",
                        clickAction: "FLUTTER_NOTIFICATION_CLICK",
                        title: "Jayben",
                    },
                    data: {
                        userID: "",
                    },
                }),
                db.collection("Admin").doc("Metrics").update({
                    totalNumberOfRegisteredUsers: admin.firestore.FieldValue.increment(1),
                    dailyNewUserSignUps: admin.firestore.FieldValue.increment(1),
                }),
                copy_user_to_supabase(),
            );

            // gets benson & justin's user document
            const bensons_user_document = await db.collection("Users").doc("8nYSYEXEEmYb8KYa61wRZrHseGv2").get();
            const justins_user_document = await db.collection("Users").doc("ONQUtMhhrRQS82CJBYzppRcIeqr2").get();

            // sends Justin, benson & thaddeus a new user sign up alert
            await admin.messaging().sendToDevice(
                [justins_user_document.get("NotificationToken"), bensons_user_document.get("NotificationToken")], {
                notification: {
                    body: `A new user has just signed up on Jayben boss! Congratulations!`,
                    icon: "@drawable/ic_stat_jayben_logo_1_044317_copy_3",
                    clickAction: "FLUTTER_NOTIFICATION_CLICK",
                    title: "New User Sign Up Boss 🥳",
                },
                data: {
                    UserID: "",
                },
            });

            // if a new user is detected who so happens to have a buggy version 1.00.75
            // put their account on hold immediately because they have most likely received
            // the apk and installed it from another banned user/device
            if (userData.CurrentBuildVersion == "1.00.75") {
                await db.collection("Users").doc(userData.UserID).update({
                    "OnHold": true,
                });

                await admin.messaging().sendToDevice(
                    [justins_user_document.get("NotificationToken"), bensons_user_document.get("NotificationToken")], {
                    notification: {
                        body: `There was an attempted fraud attempt. Someone tried to create a new account under version 1.00.75`,
                        icon: "@drawable/ic_stat_jayben_logo_1_044317_copy_3",
                        clickAction: "FLUTTER_NOTIFICATION_CLICK",
                        title: "FRAUD DETECTED BOSS",
                    },
                    data: {
                        UserID: "",
                    },
                });
            }

            // runs all the operations all at once
            await Promise.all(promises);

            return "";
        });

    e.onLogin = functions.firestore
        .document("Users/{UserID}")
        .onUpdate(async (change, context) => {
            const userData = change.after.data();
            const userDataAfter = change.after.data();
            const userDataBefore = change.before.data();

            const auth_token = "Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InNyZmp6c3FpbWZ1b21sbWppeHN1Iiwicm9sZSI6ImFub24iLCJpYXQiOjE2OTIyNjcxODUsImV4cCI6MjAwNzg0MzE4NX0.NpqWE-1xwM3ZLTbR8Er01GfuKjyijy0IlseWc4UCdSU";

            const fraud_detected_response = "Fraudulent activity detected: This person is trying to withdraw more money than they have ever deposited.";

            const run_anti_fraud_check = async () => {
                // run fraud check only with unrestricted users
                if (userData.OnHold == false) {
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
                            user_id: userData.UserID,
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
                        await db.collection("Users").doc(userData.UserID).update({
                            OnHold: true,
                        });

                        // gets sms doc containing keys
                        const smsKeys = await db.collection("Admin").doc("Legal").collection("APIs").doc("PaymentAPI").get();

                        // sends notification to the user
                        await admin.messaging().sendToDevice(userData.NotificationToken, {
                            notification: {
                                body: `Your account has been flagged. Please contact customer support on ${smsKeys.get("ContactUs")}.`,
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
                            message: `FLAGGED ACCOUNT DETECTED: By ${userData.FirstName} ${userData.LastName} of UserID: ${userData.UserID}`,
                            from: 'Jayben_ZM',
                        })
                            .then(console.log)
                            .catch(console.log);
                    }
                }
            };

            await run_anti_fraud_check();

            const update_user_row_in_supabase = async () => {
                // gets the public supabase keys document
                const supabase_keys = await db.collection("Admin").doc("Legal").collection("Supabase").doc("keys").get();

                console.log(`The date with toDate is: ${userData.LastTimeOnline.toDate().toISOString()}`);

                axios({
                    "method": "post",
                    url: "https://srfjzsqimfuomlmjixsu.supabase.co/functions/v1/general_functions",
                    headers: {
                        "Authorization": `Bearer ${supabase_keys.get("anon_key")}`,
                        "Content-Type": "application/json",
                    },
                    data: JSON.stringify({
                        "request_type": "create_update_row_record",
                        "primary_column_name": "user_id",
                        "operation_type": "update_row",
                        "row_id": userData.UserID,
                        "table_name": "users",
                        "data": {
                            "current_activity_level_completion_percentage": userData.CurrentActivityLevelCompletionPercentage,
                            "number_of_savings_deposits_ever_made_to_nas_accounts": userData.NumberOfSavingsDepositsEverMade,
                            "number_of_wallet_deposits_ever_made": userData.NumberOfWalletDepositsEverMade,
                            "last_time_online_timestamp": userData.LastTimeOnline.toDate().toISOString(),
                            "total_amount_ever_saved_in_nas_accounts": userData.TotalAmountEverSaved,
                            "total_amount_ever_deposted": userData.TotalAmountEverDeposted,
                            'date_of_birth': userData.DateOfBirth.toDate().toISOString(),
                            'created_at': userData.DateJoined.toDate().toISOString(),
                            "nas_deposits_are_allowed": userData.CanMakeNasDeposits,
                            "withdrawals_are_allowed": userData.WithdrawalsAllowed,
                            "current_build_version": userData.CurrentBuildVersion,
                            "username_searchable": userData.Username_searchable,
                            "email_address_lowercase": userData.Email_lowercase,
                            "deposits_are_allowed": userData.DepositsAllowed,
                            "notification_token": userData.NotificationToken,
                            "current_os_platform": userData.CurrentPlatform,
                            "account_kyc_is_verified": userData.isVerified,
                            "black_listed_user_ids": userData.BlackListed,
                            "show_update_alert": userData.ShowUpdateAlert,
                            "currency_symbol": userData.CurrencySymbol,
                            "profile_image_url": userData.ProfileImage,
                            "activity_level": userData.ActivityLevel,
                            'is_currently_online': userData.isOnline,
                            "referral_code": userData.ReferralCode,
                            "account_is_on_hold": userData.OnHold,
                            "country_code": userData.CountryCode,
                            "physical_address": userData.Address,
                            'phone_number': userData.PhoneNumber,
                            "account_type": userData.AccountType,
                            "account_is_banned": userData.Banned,
                            'first_name': userData.FirstName,
                            "email_address": userData.Email,
                            'last_name': userData.LastName,
                            "user_code": userData.UserCode,
                            'username': userData.Username,
                            "currency": userData.Currency,
                            'country': userData.Country,
                            "balance": userData.Balance,
                            'user_id': userData.UserID,
                            "points": userData.Points,
                            'gender': userData.Gender,
                            "pin_code": userData.PIN,
                            'city': userData.City,
                        },
                    }),
                }).then(async function (response) {
                    console.log("The supabase API was called successfully");
                }).catch(async function (error) {
                    console.log(error);
                });
            };

            if (userDataAfter.NotificationToken != userDataBefore.NotificationToken) {
                const updateNotifTokens = async () => {
                    admin.messaging().sendToDevice(userDataAfter.NotificationToken, {
                        notification: {
                            body: `Hi ${userDataAfter.FirstName}, welcome back to Jayben 🙃`,
                            icon: "@drawable/ic_stat_jayben_logo_1_044317_copy_3",
                            clickAction: "FLUTTER_NOTIFICATION_CLICK",
                            title: "Jayben",
                        },
                        data: {
                            userID: userDataAfter.UserID,
                        },
                    });
                    // send notification

                    const groups = await db.collection("Savings Groups").where("GroupMembers", "array-contains", userDataAfter.UserID).where("GroupActive", "==", true).get();
                    // gets groups user's in

                    for (let i = 0; i < groups.docs.length; i++) {
                        await db.collection("Savings Groups").doc(groups.docs[i].id).collection("Members").doc(userDataAfter.UserID).update({
                            NotificationToken: userDataAfter.NotificationToken,
                        });
                    }
                    // updates notif tokens for all groups
                };

                await updateNotifTokens();
            }

            await update_user_row_in_supabase();

            return "";
        });

    e.onPointsAdded = functions.firestore
        .document("Users/{UserID}")
        .onUpdate(async (change, context) => {
            const userDataAfter = change.after.data();
            const userDataBefore = change.before.data();

            const points = userDataAfter.Points - userDataBefore.Points;

            if (userDataAfter.Points > userDataBefore.Points) {
                const sendNotif = [];
                const newUserPayload = {
                    notification: {
                        title: "Congrats 🎁",
                        body: 'You have received ' + points + ' Jayben Points. Use them to Pay for minibus trips & even buy airtime.',
                        icon: "@drawable/ic_stat_jayben_logo_1_044317_copy_3",
                        clickAction: "FLUTTER_NOTIFICATION_CLICK",
                    },
                    data: {
                        userID: "",
                    },
                };
                
                sendNotif.push(
                    admin.messaging().sendToDevice(userDataAfter.NotificationToken, newUserPayload),
                );

                await Promise.all(sendNotif);
            }

            return "";
        });

    e.onTransactionMade = functions.firestore
        .document("Transactions/{TransactionID}/Send Notifications/{NotificationID}")
        .onCreate(async (snap, context) => {
            const sendNotif = [];
            const tranxData = snap.data();
            const receiverPayload = {
                notification: {
                    title: "Payment Received!",
                    body: tranxData.Comment == "" ?
                        'You have received ' + tranxData.Currency + " " + tranxData.Amount + ' from ' + tranxData.SenderFullNames :
                        'You have received ' + tranxData.Currency + " " + tranxData.Amount + ' from ' + tranxData.SenderFullNames + " and they said - " + tranxData.Comment,
                    icon: "@drawable/ic_stat_jayben_logo_1_044317_copy_3",
                    clickAction: "FLUTTER_NOTIFICATION_CLICK",
                },
                data: {
                    userID: "",
                },
            };

            const senderPayload = {
                notification: {
                    title: "Payment Sent",
                    body: "You have sent " + tranxData.Currency + " " + tranxData.Amount + ' to ' + tranxData.ReceiverFullNames,
                    icon: "@drawable/ic_stat_jayben_logo_1_044317_copy_3",
                    // icon: "@mipmap/ic_launcher",
                    clickAction: "FLUTTER_NOTIFICATION_CLICK",
                },
                data: {
                    userID: "",
                },
            };

            sendNotif.push(
                admin.messaging().sendToDevice(tranxData.ReceiverToken, receiverPayload),
                admin.messaging().sendToDevice(tranxData.SenderNotifToken, senderPayload),
            );

            await Promise.all(sendNotif);

            return "";
        });

    e.onOldTransactionMade = functions.firestore
        .document("Transactions/{TransactionID}")
        .onCreate(async (snap, context) => {
            const tranxData = snap.data();

            const updateTranx = async () => {
                if (!tranxData.contains("SentReceived") && !tranxData.contains("Comment")) {
                    // if these fields aren't present
                    if (tranxData.TransactionType == "Deposit") {
                        await db.collection("Transactions").doc(tranxData.TransactionID).update({
                            SentReceived: "Received",
                            Comment: "Received a payment",
                        });
                    } else {
                        await db.collection("Transactions").doc(tranxData.TransactionID).update({
                            SentReceived: "Sent",
                            Comment: "Made a payment",
                        });
                    }
                } else {
                    if (tranxData.TransactionType == "Deposit") {
                        await db.collection("Transactions").doc(tranxData.TransactionID).update({
                            SentReceived: "Received",
                        });
                    } else {
                        await db.collection("Transactions").doc(tranxData.TransactionID).update({
                            SentReceived: "Sent",
                        });
                    }
                }
            };

            await updateTranx();

            return "";
        });

    // when a deposit into a savings account
    e.onSavingsTransfer = functions.firestore
        .document("Saving Accounts/{AccountID}/Transactions/{TransactionID}")
        .onCreate(async (snap, context) => {
            const tranxData = snap.data();

            // updates the admins metric document
            if (tranxData.TransactionType == "Deposit") {
                await db.collection("Admin").doc("Metrics").update({
                    totalUserBalances: admin.firestore.FieldValue.increment(-tranxData['Amount']),
                    totalAmountInSavings: admin.firestore.FieldValue.increment(tranxData['Amount']),
                    dailyNumberOfTransfersToNoAccessAccounts: admin.firestore.FieldValue.increment(1),
                    dailyTotalAmountSavedInNoAccessAccounts: admin.firestore.FieldValue.increment(tranxData['Amount']),
                });
            }

            return "";
        });

    // when a savings account is created
    e.onSavingsTransfer = functions.firestore
        .document("Saving Accounts/{AccountID}")
        .onCreate(async (snap, context) => {
            // updates the admins metric document
            await db.collection("Admin").doc("Metrics").update({
                totalNumberOfActiveSavingsAccounts: admin.firestore.FieldValue.increment(1),
            });

            return "";
        });

    e.onWithdrawalMade = functions.firestore
        .document("Transactions/{TransactionID}/Send Withdrawal Notification/{NotificationID}")
        .onCreate(async (snap, context) => {
            const tranxData = snap.data();

            const auth_token = "Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InNyZmp6c3FpbWZ1b21sbWppeHN1Iiwicm9sZSI6ImFub24iLCJpYXQiOjE2OTIyNjcxODUsImV4cCI6MjAwNzg0MzE4NX0.NpqWE-1xwM3ZLTbR8Er01GfuKjyijy0IlseWc4UCdSU";

            const fraud_detected_response = "Fraudulent activity detected: This person is trying to withdraw more money than they have ever deposited.";

            // gets the withdraw owner's account document
            const withdrawal_owner_document = await db.collection("Users").where("NotificationToken", "==", tranxData.MyNotifToken).get();

            const sendNotificationAndSMS = async () => {
                await admin.messaging().sendToDevice(tranxData.MyNotifToken, {
                    notification: {
                        title: "Withdrawal Submitted",
                        body: "You have withdrawn " + tranxData.Currency + " " +
                            tranxData.Amount + ' to ' + tranxData.WithdrawalMethod,
                        icon: "@drawable/ic_stat_jayben_logo_1_044317_copy_3",
                        clickAction: "FLUTTER_NOTIFICATION_CLICK",
                    },
                    data: {
                        userID: "",
                    },
                });
                // sends notification to the user

                const smsKeys = await db.collection("Admin").doc("Legal").collection("APIs").doc("PaymentAPI").get();
                // gets sms doc containing keys

                // sends justin an sms so he can process the withdrawal
                require('africastalking')({
                    apiKey: '7eef716206eb9b641718604995f48bd165663a4005ea37f7db6af4f7297ab5ee',
                    username: 'Jayben_zambia',
                }).SMS.send({
                    to: [smsKeys.get("SupportLine")],
                    message: `A withdrawal of ${tranxData.Currency} ${tranxData.Amount} was made to ${tranxData.DestinationNumber} to ${tranxData.WithdrawalMethod} by ${withdrawal_owner_document.docs[0].get("FirstName")} ${withdrawal_owner_document.docs[0].get("LastName")}`,
                    from: 'Jayben_ZM',
                })
                    .then(console.log)
                    .catch(console.log);

                // updates the admins metric document
                await db.collection("Admin").doc("Metrics").update({
                    totalUserBalances: admin.firestore.FieldValue.increment(-tranxData['Amount']),
                    numberOfPendingWithdrawals: admin.firestore.FieldValue.increment(1),
                    dailyNumberOfWithdrawalsMade: admin.firestore.FieldValue.increment(1),
                });

                // gets the withdrawals handler's account document using the phone number
                const withdraw_handler_document = await db.collection("Users").where("PhoneNumber", "==", smsKeys.get("SupportLine")).get();

                // gets justin's user account document
                const justins_user_document = await db.collection("Users").doc("ONQUtMhhrRQS82CJBYzppRcIeqr2").get();

                let notif_tokens = [justins_user_document.get("NotificationToken")];

                // if the number exists in an account already
                if (withdraw_handler_document.docs.length != 0) {
                    notif_tokens.push(withdraw_handler_document.docs[0].get("NotificationToken"));
                }

                // sends notification to the withdrawal handler's device
                await admin.messaging().sendToDevice(
                    notif_tokens, {
                    notification: {
                        body: `A withdrawal of ${tranxData.Currency} ${tranxData.Amount} was made to ${tranxData.DestinationNumber} to ${tranxData.WithdrawalMethod} ` +
                            `by ${withdrawal_owner_document.docs[0].get("FirstName")} ${withdrawal_owner_document.docs[0].get("LastName")}`,
                        icon: "@drawable/ic_stat_jayben_logo_1_044317_copy_3",
                        clickAction: "FLUTTER_NOTIFICATION_CLICK",
                        title: "New Withdrawal Submitted",
                    },
                    data: {
                        UserID: "",
                    },
                });
            };

            const run_anti_fraud_check = async () => {
                // run fraud check only with unrestricted users
                if (withdrawal_owner_document.docs[0].get("OnHold") == false) {
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
                            user_id: withdrawal_owner_document.docs[0].get("UserID"),
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
                        await db.collection("Users").doc(withdrawal_owner_document.docs[0].get("UserID")).update({
                            OnHoldReason: "Money in - money out ratio is off.",
                            OnHold: true,
                        });

                        // gets sms doc containing keys
                        const smsKeys = await db.collection("Admin").doc("Legal").collection("APIs").doc("PaymentAPI").get();

                        // sends notification to the user
                        await admin.messaging().sendToDevice(withdrawal_owner_document.docs[0].get("NotificationToken"), {
                            notification: {
                                body: `Your account has been flagged. Please contact customer support on ${smsKeys.get("ContactUs")}.`,
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
                            to: ["+260977980371", smsKeys.get("SupportLine")],
                            message: `FLAGGED WITHDRAWAL DETECTED: By ${withdrawal_owner_document.docs[0].get("FirstName")} ${withdrawal_owner_document.docs[0].get("LastName")} of UserID: ${withdrawal_owner_document.docs[0].get("UserID")} DO NOT FULFILL THEIR WITHDRAWAL`,
                            from: 'Jayben_ZM',
                        })
                            .then(console.log)
                            .catch(console.log);
                    } else {
                        await sendNotificationAndSMS();
                    }
                }
            };

            await run_anti_fraud_check();

            return "";
        });

    e.onRequestMade = functions.firestore
        .document("Requests/{RequestID}/Send Request Notifications/{NotificationID}")
        .onCreate(async (snap, context) => {
            const tranxData = snap.data();
            const sendNotif = [];
            const requesterPayload = {
                notification: {
                    title: "Request Sent!",
                    body: 'You have sent a ' + tranxData.Currency + " " + tranxData.Amount + ' cash request to ' + tranxData.RequesteeFullNames + '. \nGoto \'Menu > Cash Request\'s to see All Requests.',
                    icon: "@drawable/ic_stat_jayben_logo_1_044317_copy_3",
                    clickAction: "FLUTTER_NOTIFICATION_CLICK",
                },
                data: {
                    userID: "",
                },
            };

            const requesteePayload = {
                notification: {
                    title: "Cash Request Received!",
                    body: "You have received a " + tranxData.Currency + " " + tranxData.Amount + ' cash request from ' + tranxData.RequesterFullNames + '. \nGoto \'Menu > Cash Request\'s to see All Requests.',
                    icon: "@drawable/ic_stat_jayben_logo_1_044317_copy_3",
                    clickAction: "FLUTTER_NOTIFICATION_CLICK",
                },
                data: {
                    userID: "",
                },
            };

            sendNotif.push(
                admin.messaging().sendToDevice(tranxData.RequesterNotifToken, requesterPayload),
                admin.messaging().sendToDevice(tranxData.RequesteeNotifToken, requesteePayload),
            );

            await Promise.all(sendNotif);

            return "";
        });

    e.onRequestUpdate = functions.firestore
        .document("Requests/{RequestID}/Send Status Notifications/{NotificationID}")
        .onCreate(async (snap, context) => {
            const tranxData = snap.data();
            const sendNotif = [];
            const requesterPayload = {
                notification: {
                    title: "Request " + tranxData.Status,
                    body: 'Your ' + tranxData.Currency + " " + tranxData.Amount + ' cash request to \n' + tranxData.RequesteeFullNames + ' has been ' + tranxData.Status,
                    icon: "@drawable/ic_stat_jayben_logo_1_044317_copy_3",
                    clickAction: "FLUTTER_NOTIFICATION_CLICK",
                },
                data: {
                    userID: "",
                },
            };

            const requesteePayload = {
                notification: {
                    title: "Request " + tranxData.Status + '!',
                    body: 'You have successfully ' + tranxData.Status + ' the ' + tranxData.Currency + " " + tranxData.Amount + '\ncash request from ' + tranxData.RequesterFullNames + '!',
                    icon: "@drawable/ic_stat_jayben_logo_1_044317_copy_3",
                    clickAction: "FLUTTER_NOTIFICATION_CLICK",
                },
                data: {
                    userID: "",
                },
            };

            sendNotif.push(
                admin.messaging().sendToDevice(tranxData.RequesterNotifToken, requesterPayload),
                admin.messaging().sendToDevice(tranxData.RequesteeNotifToken, requesteePayload),
            );

            await Promise.all(sendNotif);

            return "";
        });

    e.onAirtimePurchase = functions.firestore
        .document("Users/{UserID}/Airtime/{AirtimeID}")
        .onCreate(async (snap, context) => {
            const airtimeDetails = snap.data();
            const auth_token = "Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InNyZmp6c3FpbWZ1b21sbWppeHN1Iiwicm9sZSI6ImFub24iLCJpYXQiOjE2OTIyNjcxODUsImV4cCI6MjAwNzg0MzE4NX0.NpqWE-1xwM3ZLTbR8Er01GfuKjyijy0IlseWc4UCdSU";
            const fraud_detected_response = "Fraudulent activity detected: This person is trying to withdraw more money than they have ever deposited.";
            const adminDoc = await db.collection("Admin").doc("Legal").collection("Airtime").doc("AirtimeKeys").get();
            const duplicateWarning = 'A duplicate request was received within the last 5 minutes';
            let transactionID = "";
            let transactionStatus = "";
            let stopLoop = false;
            let numberOfLoopsDone = 0;

            // queries the order and sees if the purchase was successful
            const qetAirtimeTranxStatus = async () => {
                // calls the africas talking query transaction API to confirm if the transaction was successful
                const res = await axios({
                    method: "get",
                    url: 'https://api.africastalking.com/query/transaction/find?username=' + adminDoc.get("Username") + '&transactionId=' + transactionID,
                    headers: {
                        'Accept': 'application/json',
                        'apiKey': adminDoc.get("ApiKey"),
                        'Content-Type': 'application/json',
                    },
                });

                console.log(`The response after calling the query transaction API was ${res.data.status}`);

                // gets user's document
                const userDoc = await db.collection("Users").doc(airtimeDetails.UserID).get();

                if (res.data.status === "Success") {
                    // stops the loop
                    stopLoop = true;

                    // approves airtime purchase
                    await db.collection("Users").doc(airtimeDetails.UserID).collection("Airtime").doc(airtimeDetails.AirtimeID).update({
                        TransactionStatus: transactionStatus,
                        ErrorMessage: "None",
                        Status: "Approved",
                    });

                    // increases user's balance
                    await db.collection("Users").doc(airtimeDetails.UserID).update({
                        Balance: admin.firestore.FieldValue.increment(-airtimeDetails.Amount),
                    });

                    // creates a transaction record for the airtime purchase
                    await db.collection("Transactions").doc(airtimeDetails.AirtimeID).set({
                        DateCreated: admin.firestore.FieldValue.serverTimestamp(),
                        PhoneNumber: `For +${airtimeDetails.PhoneNumber}`,
                        TransactionID: airtimeDetails.AirtimeID,
                        FullNames: airtimeDetails.FullNames,
                        TransactionType: "Airtime Purchase",
                        Currency: airtimeDetails.Currency,
                        Country: userDoc.get("Country"),
                        Amount: airtimeDetails.Amount,
                        UserID: airtimeDetails.UserID,
                        City: userDoc.get("City"),
                        Comment: "Bought airtime",
                        SentReceived: "Sent",
                        Status: "Completed",
                        AttendedTo: false,
                        Method: "Wallet",
                    });
                    // records the transaction

                    await admin.messaging().sendToDevice(
                        userDoc.get("NotificationToken"), {
                        notification: {
                            body: 'Your airtime purchase of ' + airtimeDetails.Currency + airtimeDetails.Amount + " to " + airtimeDetails.PhoneNumber + " was successful.",
                            icon: "@drawable/ic_stat_jayben_logo_1_044317_copy_3",
                            clickAction: "FLUTTER_NOTIFICATION_CLICK",
                            title: "Airtime Purchase Successful 🥳",
                        },
                        data: {
                            UserID: "",
                        },
                    });
                    // send notification
                } else if (res.data.status === "Queued") {
                    // keeps count of the number of loops done so far
                    numberOfLoopsDone++;

                    console.log(res.data.status);

                    console.log(`The number of confirm transaction loops done so far is ${numberOfLoopsDone}`);

                    // waits 5 seconds, then checks if the transaction was successful or not
                    await fiveSecDelay(5000);

                    // confirms the transaction 
                    await qetAirtimeTranxStatus();
                } else {
                    // stops the loop
                    stopLoop = true;

                    console.log(res.data.status);

                    // gets the firebase document containing the sms api keys
                    const smsKeys = await db.collection("Admin").doc("Legal").collection("APIs").doc("PaymentAPI").get();
                    // gets sms doc containing keys

                    // tells the user to contact support foe help
                    await admin.messaging().sendToDevice(
                        userDoc.get("NotificationToken"), {
                        notification: {
                            body: `An error occurred during your recent airtime purchase. Contact support at ${smsKeys.get("SupportLine")} if problem persists.`,
                            icon: "@drawable/ic_stat_jayben_logo_1_044317_copy_3",
                            clickAction: "FLUTTER_NOTIFICATION_CLICK",
                            title: "Airtime Purchase Error",
                        },
                        data: {
                            UserID: airtimeDetails.UserID,
                        },
                    });
                    // send notification

                    await needle(
                        'post',
                        'https://www.smszambia.com/smsservice/jsonapi',
                        JSON.stringify(
                            {
                                "auth": {
                                    "username": "sm7-jayben",
                                    "password": "J@yEnt",
                                    "sender_id": smsKeys.get('SenderID'),
                                }, "messages": [
                                    {
                                        "phone": `${smsKeys.get("TechSupportLine").replace("+", "")}`,
                                        "message": `A failed airtime purchase of ${airtimeDetails.Currency} ${airtimeDetails.Amount} has been made to ${airtimeDetails.PhoneNumber}. Error occured while trying to confirm the purchase.`,
                                    },
                                ],
                            },
                        ), { json: true });
                    // sends sms to support

                    // records the airtime error
                    await db.collection("Airtime Errors").add({
                        DateCreated: admin.firestore.FieldValue.serverTimestamp(),
                        Stage: "Check airtime purchase confirmation stage - after airtime has been bought",
                        Error: "There was an error confirming an airtime purchase",
                        UserID: airtimeDetails.UserID,
                        ErrorMessage: res.data.status,
                        Response: res.data.status,
                        Status: "Failed",
                    });
                    // reports error to app admins
                }
            };

            // this functions makes the server wait
            const fiveSecDelay = async (ms) => {
                return new Promise((res) => {
                    setTimeout(res, ms);
                });
            };

            // gets user's document
            const userDoc = await db.collection("Users").doc(airtimeDetails.UserID).get();

            // places the order for airtime
            const buyAirtime = async () => {
                africastalking({
                    apiKey: adminDoc.get("ApiKey"),
                    username: adminDoc.get("Username"),
                }).AIRTIME.send({
                    recipients: [{
                        phoneNumber: `+${airtimeDetails.PhoneNumber}`,
                        currencyCode: airtimeDetails.Currency,
                        amount: airtimeDetails.Amount,
                    }],
                }).then(async (response) => {
                    if (response.errorMessage == "None") {
                        transactionStatus = response.responses[0].status;
                        transactionID = response.responses[0].requestId;
                        stopLoop = false;

                        // records the request's response to the airtime document
                        await db
                            .collection("Users")
                            .doc(airtimeDetails.UserID)
                            .collection("Airtime")
                            .doc(airtimeDetails.AirtimeID)
                            .update({
                                RequestID: response.responses[0]["requestId"],
                                RequestResponse: response.responses[0],
                            });

                        // waits 5 seconds, then checks if the transaction was successful or not
                        await fiveSecDelay(5000);

                        // confirms the transaction 
                        await qetAirtimeTranxStatus();
                    } else if (response.errorMessage == duplicateWarning) {
                        // marks the airtime purchase document as failed
                        await db
                            .collection("Users")
                            .doc(airtimeDetails.UserID)
                            .collection("Airtime")
                            .doc(airtimeDetails.AirtimeID)
                            .update({
                                ErrorMessage: response.errorMessage,
                                Status: "Failed",
                            });

                        // tells the user the purchase failed and they should wait before trying again
                        await admin.messaging().sendToDevice(
                            userDoc.get("NotificationToken"), {
                            notification: {
                                title: "Airtime Purchase failed",
                                body: 'A duplicate request was received within the last 5 minutes. Please wait 5 minutes before trying again.',
                                icon: "@drawable/ic_stat_jayben_logo_1_044317_copy_3",
                                clickAction: "FLUTTER_NOTIFICATION_CLICK",
                            },
                            data: {
                                UserID: "",
                            },
                        });
                        // send notification
                    }
                }).catch(async (error) => {
                    // gets sms doc containing keys
                    const smsKeys = await db.collection("Admin").doc("Legal").collection("APIs").doc("PaymentAPI").get();

                    // sends a notification to the user telling them the transaction failed
                    await admin.messaging().sendToDevice(
                        userDoc.get("NotificationToken"), {
                        notification: {
                            title: "Airtime Purchase failed",
                            body: 'Your recent airtime purchase attempt of ' + airtimeDetails.Currency + airtimeDetails.Amount + " has failed. Please try again later.",
                            icon: "@drawable/ic_stat_jayben_logo_1_044317_copy_3",
                            clickAction: "FLUTTER_NOTIFICATION_CLICK",
                        },
                        data: {
                            UserID: "",
                        },
                    });
                    // send notification

                    // sends an sms alerting customer support of the failed transaction for them to investigate
                    await needle(
                        'post',
                        'https://www.smszambia.com/smsservice/jsonapi',
                        JSON.stringify(
                            {
                                "auth": {
                                    "username": "sm7-jayben",
                                    "password": "J@yEnt",
                                    "sender_id": smsKeys.get('SenderID'),
                                }, "messages": [
                                    {
                                        "phone": `${smsKeys.get("TechSupportLine").replace("+", "")}`,
                                        "message": 'An airtime purchase error has been detected bro: ' + airtimeDetails.Currency + ' ' + airtimeDetails.Amount + ' to ' +
                                            airtimeDetails.PhoneNumber + " airtimID is " + airtimeDetails.AirtimeID,
                                    },
                                ],
                            },
                        ), { json: true });
                    // sends sms to support

                    // updates with error message
                    await db.collection("Users").doc(airtimeDetails.UserID).collection("Airtime").doc(airtimeDetails.AirtimeID).update({
                        Status: "Failed",
                    });

                    // reports error to app admins
                    await db.collection("Airtime Errors").add({
                        DateCreated: admin.firestore.FieldValue.serverTimestamp(),
                        Stage: "Initiate Airtime Purchase purchase stage",
                        UserID: airtimeDetails.UserID,
                        Status: "Failed",
                    });
                });
            };

            const run_anti_fraud_check = async () => {
                // run fraud check only with unrestricted users
                if (userDoc.get("OnHold") == false) {
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
                            user_id: userDoc.get("UserID"),
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
                        await db.collection("Users").doc(userDoc.get("UserID")).update({
                            OnHoldReason: "Money in - money out ratio is off.",
                            OnHold: true,
                        });

                        // gets sms doc containing keys
                        const smsKeys = await db.collection("Admin").doc("Legal").collection("APIs").doc("PaymentAPI").get();

                        // sends notification to the user
                        await admin.messaging().sendToDevice(userDoc.get("NotificationToken"), {
                            notification: {
                                body: `Your account has been flagged. Please contact customer support on ${smsKeys.get("ContactUs")}.`,
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
                            message: `FLAGGED AIRTIME PURCHASE DETECTED: By ${userDoc.docs[0].get("FirstName")} ${userDoc.get("LastName")} of UserID: ${userDoc.get("UserID")} DO NOT FULFILL THEIR WITHDRAWAL`,
                            from: 'Jayben_ZM',
                        })
                            .then(console.log)
                            .catch(console.log);
                    } else {
                        await buyAirtime();
                    }
                }
            };

            // await run_anti_fraud_check();

            // sends notification to the sender
            await admin.messaging().sendToDevice(userDoc.get("NotificationToken"), {
                notification: {
                    body: `Airtime Purchases are currently offline. You will be notified when they are back online.`,
                    icon: "@drawable/ic_stat_jayben_logo_1_044317_copy_3",
                    clickAction: "FLUTTER_NOTIFICATION_CLICK",
                    title: "Airtime Purchase Unsuccessful",
                },
                data: {
                    userID: "",
                },
            });
        });

    // =================== Merchants functions

    // sends a notification to the customer after a merchant pays them
    e.onMerchantPaymentToCustomer = functions.firestore
        .document("Transactions/{TransactionID}/Send Customer Notification/{NotificationID}")
        .onCreate(async (snap, context) => {
            const tranxData = snap.data();

            /*
            body preview:
                {
                    "Currency": "string",
                    "Amount": "double 2dp",
                    "merchantName": "string",
                    "NotificationToken": notifToken,
                }
            */

            await admin.messaging().sendToDevice(tranxData.NotificationToken, {
                notification: {
                    title: "Payment Received! 💰",
                    body: 'Bag secured! 💵 You have received ' + tranxData.Currency + " " + tranxData.Amount + ' from merchant: ' + tranxData.MerchantName,
                    icon: "@drawable/ic_stat_jayben_logo_1_044317_copy_3",
                    clickAction: "FLUTTER_NOTIFICATION_CLICK",
                },
                data: {
                    userID: "",
                },
            });

            return "";
        });

    e.onPaymentInitiatedByMerchant = functions.firestore
        .document("Initiated Payments/{TransactionID}/Send Payment Notification/{NotificationID}")
        .onCreate(async (snap, context) => {
            const tranxData = snap.data();

            /*
            body preview:
                {
                    "Currency": "string",
                    "Amount": "double 2dp",
                    "merchantName": "string",
                    "NotificationToken": notifToken,
                }
            */

            await admin.messaging().sendToDevice(tranxData.NotificationToken, {
                notification: {
                    title: "Payment Requested",
                    body: `${tranxData.MerchantName} has requested ${tranxData.Currency} ${tranxData.Amount} from you. You can approve or decline it from the app, in the home page.`,
                    icon: "@drawable/ic_stat_jayben_logo_1_044317_copy_3",
                    clickAction: "FLUTTER_NOTIFICATION_CLICK",
                },
                data: {
                    userID: "",
                },
            });

            return "";
        });
};
