const admin = require("firebase-admin");
const express = require('express');
const app = express();
const functions = require("firebase-functions");
const db = admin.firestore();

module.exports = function (e) {
    app.post('/transfer', async (req, res) => {
        const body = req.body;

        const receiversDoc = await db
            .collection("Users")
            .where("PhoneNumber", "==", body.PhoneNumber)
            .get();

        const apiUsers = await db
            .collection("API Users")
            .where("API_Key", "==", body.APIKey)
            .limit(1)
            .get();

        if (apiUsers.docs.length > 0 && apiUsers.docs[0].get("Active") == true) {
            if (apiUsers.docs[0].get("Points") >= body.PointsToTransfer) {
                const tranxID = Math.random().toString(36).substr(2, 10);
                const pointsTranxID = Math.random().toString(36).substr(2, 10);

                const transferPoints = async () => {
                    await db
                        .collection("Users")
                        .doc(receiversDoc.docs[0].id)
                        .update({
                            Points: admin.firestore.FieldValue.increment(body.PointsToTransfer),
                        });
                    // gives points to the receiver

                    await db.collection("Transactions").doc(tranxID).set({
                        DateCreated: admin.firestore.FieldValue.serverTimestamp(),
                        Amount: body.PointsToTransfer,
                        UserID: receiversDoc.docs[0].id,
                        FullNames: receiversDoc.docs[0].get("FirstName") + " " + receiversDoc.docs[0].get("LastName"),
                        Status: "Completed",
                        AttendedTo: true,
                        Currency: receiversDoc.docs[0].get("Currency"),
                        Method: "Points",
                        Txref: "",
                        TransactionID: tranxID,
                        Comment: "",
                        SentReceived: 'Received',
                        TransactionType: "Deposit",
                        PhoneNumber: 'To ' + body.PhoneNumber,
                    });
                    // records the transaction

                    await db
                        .collection("API Users")
                        .doc(apiUsers.docs[0].get("AccountID"))
                        .update({
                            Points: admin.firestore.FieldValue.increment(-body.PointsToTransfer),
                        });
                    // updates the api owner points balance

                    await db
                        .collection("API Users")
                        .doc(apiUsers.docs[0].get("AccountID"))
                        .collection("Transactions")
                        .doc(pointsTranxID)
                        .set({
                            DateCreated: admin.firestore.FieldValue.serverTimestamp(),
                            Amount: body.PointsToTransfer,
                            ReceiverID: receiversDoc.docs[0].id,
                            ReceiverFullNames: receiversDoc.docs[0].get("FirstName") + " " + receiversDoc.docs[0].get("LastName"),
                            ReceiverPhoneNumber: body.PhoneNumber,
                            ReceiverUserID: receiversDoc.docs[0].id,
                            TransactionID: pointsTranxID,
                            MyAccountID: apiUsers.docs[0].get("AccountID"),
                        });
                    // records the transaction for the api user
                };

                await transferPoints();

                res.status(201).send(JSON.stringify({
                    "status": "Success",
                    "Code": 201,
                    "Response": "Points have been transfered successfully",
                }));
            } else if (apiUsers.docs[0].get("Points") < body.PointsToTransfer) {
                res.status(400).send(JSON.stringify({
                    "Status": "error",
                    "Code": 400,
                    "Response": "Insufficient Points, please topup more to continue.",
                }));
            }
        } else if (apiUsers.docs.length == 0) {
            res.status(400).send(JSON.stringify({
                "Status": "error",
                "Code": 400,
                "Response": "Invalid API Key",
            }));
        } else if (apiUsers.docs[0].get("Active") == false) {
            res.status(400).send(JSON.stringify({
                "Status": "error",
                "Code": 400,
                "Response": "Your Account has been deactivated - Please contact support " + "+260977980371",
            }));
        }
    });

    e.points = functions.https.onRequest(app);
};
