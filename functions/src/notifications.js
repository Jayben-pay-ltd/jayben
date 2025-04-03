// deno-lint-ignore-file prefer-const
/* eslint-disable prefer-const */
/* eslint-disable camelcase */
const functions = require("firebase-functions");
const cors = require('cors')({ origin: true });
const admin = require("firebase-admin");
const express = require('express');
const axios = require("axios");
const db = admin.firestore();
const app = express();
app.use(cors);

module.exports = function (e) {
    // ================= Http Notification Functions

    // called by supabase trigger
    app.post('/v1/send/firebase', async (req, res) => {
        const notifBody = req.body;

        /*
            BODY PREVIEW
            {
                "body": "String",
                "title": "string",
                "data": {
                    "UserID": "string"
                },
                "notification_tokens": <String>[],
            }
        */

        console.log("Test point 1");

        // sends notification(s) to the token(s) provided
        const sendNotifications = async () => {
            console.log("Test point 2");

            if (notifBody.notification_tokens.length !== 0) {
                console.log("Test point 3");

                if (notifBody.data != "{}") {
                    await admin.messaging().sendToDevice(notifBody.notification_tokens, {
                        notification: {
                            icon: "@drawable/ic_stat_jayben_logo_1_044317_copy_3",
                            clickAction: "FLUTTER_NOTIFICATION_CLICK",
                            title: notifBody.title,
                            body: notifBody.body,
                        },
                        data: notifBody.data,
                    });
                } else {
                    await admin.messaging().sendToDevice(notifBody.notification_tokens, {
                        notification: {
                            icon: "@drawable/ic_stat_jayben_logo_1_044317_copy_3",
                            clickAction: "FLUTTER_NOTIFICATION_CLICK",
                            title: notifBody.title,
                            body: notifBody.body,
                        },
                        data: {
                            UserID: "",
                        },
                    });
                }

                console.log("Test point 4");
            }

            console.log("Test point 5");

            res.status(200).send("Success");
        };

        console.log("Test point 6");

        try {
            console.log("Test point 7");
            await sendNotifications();
            console.log("Test point 8");
        } catch (e) {
            console.log("Test point 9");

            console.log(e);

            res.status(200).send("Failed");
        }

        console.log("Test point 10");
    });

    app.post('/v1/send/firebase/users/all/broadcast', async (req, res) => {
        const notifBody = req.body;

        /*
            BODY PREVIEW
            {
                "body": "String",
                "title": "string",
                "data": {
                    "UserID": "string"
                },
            }
        */

        console.log("Test point 1");

        // sends notification(s) to the token(s) provided
        const sendNotifications = async () => {
            console.log("Test point 2");

            // gets the public supabase keys document
            const supabase_keys = await db.collection("Admin").doc("Legal").collection("Supabase").doc("keys").get();

            let notification_tokens = [];

            // calls a supabase api that gets all the user's notif tokens
            await axios({
                "method": "post",
                url: "https://srfjzsqimfuomlmjixsu.supabase.co/functions/v1/general_functions",
                headers: {
                    "Authorization": `Bearer ${supabase_keys.get("anon_key")}`,
                    "Content-Type": "application/json",
                },
                data: JSON.stringify({
                    "request_type": "get_all_notification_tokens"
                }),
            }).then(async function (response) {
                notification_tokens = response.data.data;

                console.log(response.data.data);

                console.log("The supabase API was called successfully");
            }).catch(async function (error) {
                console.log(error);

                console.log(`There was an error copying while updating an existing transaction document`);
            });

            console.log("The number of tokens to send the notifications to is: ", notification_tokens.length);

            let send_operations = [];

            // creates a send operation for each notif token
            for (let i = 0; i < notification_tokens.length; i++) {
                send_operations.push(admin.messaging().sendToDevice(notification_tokens[i], {
                    notification: {
                        icon: "@drawable/ic_stat_jayben_logo_1_044317_copy_3",
                        clickAction: "FLUTTER_NOTIFICATION_CLICK",
                        title: notifBody.title,
                        body: notifBody.body,
                    },
                    data: {
                        UserID: "",
                    },
                }));
            }

            console.log("Now sending the notifications");

            await Promise.all(send_operations);

            console.log("Done sending the notifications");

            // creates a record of the notification
            await db.collection("SentAppWideNotifications").add({
                "DateCreated": admin.firestore.FieldValue.serverTimestamp(),
                "NumberOfPeopleSentTo": send_operations.length,
                "NotificationData": notifBody.data,
                "Title": notifBody.title,
                "Body": notifBody.body,
            });

            console.log("Test point 5");

            res.status(200).send("Success");
        };

        console.log("Test point 6");

        try {
            console.log("Test point 7");
            await sendNotifications();
            console.log("Test point 8");
        } catch (e) {
            console.log("Test point 9");

            console.log(e);

            res.status(200).send("Failed");
        }

        console.log("Test point 10");
    });

    app.post('/v1/send/firebase/users/k2/broadcast', async (req, res) => {
        const notifBody = req.body;

        /*
            BODY PREVIEW
            {
                "body": "String",
                "title": "string",
                "data": {
                    "UserID": "string"
                },
            }
        */

        console.log("Test point 1");

        // sends notification(s) to the token(s) provided
        const sendNotifications = async () => {
            console.log("Test point 2");

            // gets the public supabase keys document
            const users_w_k2_or_less = await db.collection("Users").where("Balance", "<", 2.1).get();

            let send_operations = [];

            // creates a send operation for each notif token
            for (let i = 0; i < users_w_k2_or_less.docs.length; i++) {
                send_operations.push(admin.messaging().sendToDevice(users_w_k2_or_less.docs[i].get("NotificationToken"), {
                    notification: {
                        icon: "@drawable/ic_stat_jayben_logo_1_044317_copy_3",
                        clickAction: "FLUTTER_NOTIFICATION_CLICK",
                        title: notifBody.title,
                        body: notifBody.body,
                    },
                    data: {
                        UserID: "",
                    },
                }));
            }

            console.log("The number of operations to send the notifications to is: ", send_operations.length);

            console.log("Now sending the notifications");

            // await Promise.all(send_operations);

            console.log("Done sending the notifications");

            // creates a record of the notification
            // await db.collection("SentAppWideNotifications").add({
            //     "DateCreated": admin.firestore.FieldValue.serverTimestamp(),
            //     "NumberOfPeopleSentTo": send_operations.length,
            //     "NotificationData": notifBody.data,
            //     "Title": notifBody.title,
            //     "Body": notifBody.body,
            // });

            console.log("Test point 5");

            res.status(200).send("Success");
        };

        console.log("Test point 6");

        try {
            console.log("Test point 7");
            await sendNotifications();
            console.log("Test point 8");
        } catch (e) {
            console.log("Test point 9");

            console.log(e);

            res.status(200).send("Failed");
        }

        console.log("Test point 10");
    });

    e.notifications = functions.runWith({
        timeoutSeconds: 540,
        memory: '1GB',
    }).https.onRequest(app);
};
