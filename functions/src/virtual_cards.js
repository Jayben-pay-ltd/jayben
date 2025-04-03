const admin = require("firebase-admin");
const axios = require('axios');
const functions = require("firebase-functions");
const db = admin.firestore();

module.exports = function (e) {
    const path2 = "/Card Creation Check/{CardCreationCheckID}";
    const path1 = "Users/{UserID}/CardSubmissions/{CardID}";
    // these paths belong to the onCreateCardCheck function
    
    e.onCreateVirtualCard = functions
        .firestore
        .document("Users/{UserID}/CardSubmissions/{CardID}")
        .onCreate(async (snap, context) => {
            const submissionDetails = snap.data();
    
            const userDoc = await db.collection("Users").doc(submissionDetails.UserID).get();
    
            const adminDoc = await db.collection("Admin").doc("Legal").get();
    
            const data = JSON.stringify({
                "currency": "USD",
                "amount": submissionDetails.Amount,
                "debit_currency": "USD",
                "billing_name": submissionDetails.FullNames,
                "billing_address": submissionDetails.Address,
                "billing_city": submissionDetails.City,
                "billing_state": submissionDetails.State,
                "billing_postal_code": submissionDetails.PostalCodee,
                "billing_country": "US",
            });
            const config = {
                method: "post",
                url: "https://api.flutterwave.com/v3/virtual-cards",
                headers: {
                    "Content-Type": "application/json",
                    "Authorization": adminDoc.get("secretKey"),
                },
                data: data,
            };
    
            const createVirtualCard = [];
            const reportCardCreationError = [];
            const approveCardCreationStatus = [];
    
            createVirtualCard.push(
                axios(config)
                    .then(function (response) {
                        approveCardCreationStatus.push(
                            db.collection("Users")
                                .doc(submissionDetails.UserID)
                                .collection("Cards")
                                .doc(response.data.data.id)
                                .set({
                                    CardID: response.data.data.id,
                                    DateCreated: admin.firestore.FieldValue.serverTimestamp(),
                                    Balance: response.data.data.amount,
                                    Currency: response.data.data.currency,
                                    Card_hash: response.data.data.card_hash,
                                    Card_pan: response.data.data.card_pan,
                                    Masked_pan: response.data.data.masked_pan,
                                    City: response.data.data.city,
                                    State: response.data.data.state,
                                    Address_1: response.data.data.address_1,
                                    Zip_code: response.data.data.zip_code,
                                    Cvv: response.data.data.cvv,
                                    Expiration: response.data.data.expiration,
                                    Card_type: response.data.data.card_type,
                                    Name_on_card: response.data.data.name_on_card,
                                    Created_at: response.data.data.created_at,
                                    Is_active: response.data.data.is_active,
                                }),
                            db
                                .collection("Users")
                                .doc(submissionDetails.UserID)
                                .collection("CardSubmissions")
                                .doc(submissionDetails.SubmissionID)
                                .update({
                                    CreationStatus: "Approved",
                                }),
                            admin.messaging().sendToDevice(
                                userDoc.get("NotificationToken"), {
                                notification: {
                                    title: "Card Creation Successful 🥳",
                                    body: "You have successfully created a new virtual card.",
                                    icon: "@drawable/ic_stat_jayben_logo_1_044317_copy_3",
                                    clickAction: "FLUTTER_NOTIFICATION_CLICK",
                                },
                                data: {
                                    UserID: "",
                                },
                            }),
                            // send notification
                        );
                        // updates the card creation
                    })
                    .catch(function (error) {
                        reportCardCreationError.push(
                            db
                                .collection("Users")
                                .doc(submissionDetails.UserID)
                                .collection("CardSubmissions")
                                .doc(submissionDetails.SubmissionID)
                                .update({
                                    CreationStatus: "Failed",
                                    ErrorMessage: error.response.data.message,
                                }),
                            db
                                .collection("Card Creation Errors")
                                .doc(submissionDetails.SubmissionID)
                                .set({
                                    UserID: submissionDetails.UserID,
                                    ErrorDate: admin.firestore.FieldValue.serverTimestamp(),
                                    Amount: submissionDetails.Amount,
                                    UserNames: submissionDetails.FullNames,
                                    CreationStatus: "Failed",
                                    ErrorMessage: error.response.data.message,
                                }),
                            admin.messaging().sendToDevice(
                                userDoc.get("NotificationToken"), {
                                notification: {
                                    title: "Card Creation failed",
                                    body: "Your recent card creation attempt has failed. Please try again later.",
                                    icon: "@drawable/ic_stat_jayben_logo_1_044317_copy_3",
                                    clickAction: "FLUTTER_NOTIFICATION_CLICK",
                                },
                                data: {
                                    UserID: "",
                                },
                            }),
                            // send notification
                        );
                    }),
            );
    
            await Promise.all(createVirtualCard);
            await Promise.all(approveCardCreationStatus);
            await Promise.all(reportCardCreationError);
        });
    
    e.onCreateCardCheck = functions
        .firestore
        .document(path1 + path2)
        .onCreate(async (snap, context) => {
            const cardCreationCheckDetails = snap.data();
    
            const adminDoc = await db.collection("Admin").doc("Legal").get();
    
            const config = {
                method: "get",
                url: "https://api.flutterwave.com/v3/virtual-cards",
                headers: {
                    "Content-Type": "application/json",
                    "Authorization": adminDoc.get("secretKey"),
                },
            };
    
            const createVirtualCard = [];
            const approveCardSubmission = [];
    
            createVirtualCard.push(
                axios(config)
                    .then(function (response) {
                        // console.log(JSON.stringify(response.data.data));
    
                        for (let i = 0; i < response.data.data.length; i++) {
                            if (response.data.data[i].name_on_card ==
                                cardCreationCheckDetails.FullNames) {
                                createVirtualCard.push(
                                    db.collection("Users")
                                        .doc(cardCreationCheckDetails.UserID)
                                        .collection("Cards")
                                        .doc(response.data.data[i].id)
                                        .set({
                                            CardID: response.data.data[i].id,
                                            DateCreated: admin.firestore.FieldValue.serverTimestamp(),
                                            Balance: response.data.data[i].amount,
                                            Currency: response.data.data[i].currency,
                                            Card_hash: response.data.data[i].card_hash,
                                            Card_pan: response.data.data[i].card_pan,
                                            Masked_pan: response.data.data[i].masked_pan,
                                            City: response.data.data[i].city,
                                            State: response.data.data[i].state,
                                            Address_1: response.data.data[i].address_1,
                                            Zip_code: response.data.data[i].zip_code,
                                            Cvv: response.data.data[i].cvv,
                                            Expiration: response.data.data[i].expiration,
                                            Card_type: response.data.data[i].card_type,
                                            Name_on_card: response.data.data[i].name_on_card,
                                            Created_at: response.data.data[i].created_at,
                                            Is_active: response.data.data[i].is_active,
                                        }),
                                );
                            }
                            // break;
                        }
    
                        approveCardSubmission.push(
                            db
                                .collection("Users")
                                .doc(cardCreationCheckDetails.UserID)
                                .collection("CardSubmissions")
                                .doc(cardCreationCheckDetails.CardSubmissionID)
                                .update({
                                    CreationStatus: "Approved",
                                }),
                        );
                    })
                    .catch(function (error) {
                    }),
            );
    
            await Promise.all(createVirtualCard);
            await Promise.all(approveCardSubmission);
        });
};
