const admin = require("firebase-admin");
const functions = require("firebase-functions");
const db = admin.firestore();
const express = require('express');
const cors = require('cors')({ origin: true });
const app = express();
app.use(cors);

module.exports = function (e) {
    app.post('/checkIfPhoneNumberAlreadyExists', async (req, res) => {
        const requestDetails = req.body;

        /*
            body preview:
                {
                    "PhoneNumber": "String",
                }
        */

        const checkIfPhoneNumberAlreadyExists = async () => {
            const users = await db.collection("Users").where("PhoneNumber", "==", requestDetails.PhoneNumber).get();

            if (users.docs.length == 0) {
                res.status(200).send("false");
            } else if (users.docs.length > 0) {
                res.status(200).send("true");
            }
        };

        await checkIfPhoneNumberAlreadyExists();
    });

    app.post('/checkIfUsernameExists', async (req, res) => {
        const requestDetails = req.body;

        /*
            body preview:
                {
                    "Username": "String",
                }
        */

        const checkIfUsernameExists = async () => {
            const users = await db.collection("Users").where("Username_searchable", "==", requestDetails.Username).get();

            if (users.docs.length == 0) {
                res.status(200).send("false");
            } else if (users.docs.length > 0) {
                res.status(200).send("true");
            }
        };

        await checkIfUsernameExists();
    });

    app.post('/merchant/checkIfEmailExists', async (req, res) => {
        const requestDetails = req.body;

        /*
        body preview:
            {
                "Email": "String"
            }
        */

        const checkIfEmailExists = async () => {
            const users = await db.collection("Merchants").where("Email_lowercase", "==", requestDetails.Email).get();

            if (users.docs.length == 0) {
                res.status(200).send("False");
            } else if (users.docs.length > 0) {
                res.status(200).send("True");
            }
        };

        await checkIfEmailExists();
    });

    app.post('/user/checkIfEmailExists', async (req, res) => {
        const requestDetails = req.body;

        /*
        body preview:
            {
            "Email": "String"
            }
        */

        const checkIfEmailExists = async () => {
            const users = await db.collection("Users").where("Email_lowercase", "==", requestDetails.Email).get();

            if (users.docs.length == 0) {
                res.status(200).send("False");
            } else if (users.docs.length > 0) {
                res.status(200).send("True");
            }
        };

        await checkIfEmailExists();
    });

    app.get('/getTOS', async (req, res) => {
        const getTOS = async () => {
            const tosDoc = await db.collection("Admin").doc("Terms & Conditions").get();

            res.status(200).send(tosDoc.get("Eula"));
        };

        await getTOS();
    });

    app.post('/encryptPin', async (req, res) => {
        // const body = req.body;

        const tosDoc = await db.collection("Admin").doc("Terms & Conditions").get();

        res.status(200).send(tosDoc.get("Eula"));
    });

    app.post('/banUser', async (req, res) => {
        const body = req.body;

        /*
            body preview
            {
                "user_id": text,
            }
        */

        // marks user's account as banned
        await db.collection("Users").doc(body.user_id).update({
            "OnHold": true,
        });

        res.status(200).send("Done");
    });

    e.auth = functions.https.onRequest(app);
};
