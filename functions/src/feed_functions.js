const admin = require("firebase-admin");
const functions = require("firebase-functions");
const db = admin.firestore();

module.exports = function (e) {
    e.sendPostToContacts = functions.firestore
    .document("Users/{UserID}/Timeline/{PostID}")
    .onCreate(async (snap, context) => {
        const postData = snap.data();
        const sendPostToContacts = [];

        const contacts = await db
            .collection("Users")
            .doc(postData.SenderUID)
            .collection("Contacts")
            .where("IsJaybenUser", "==", true)
            .get();

        if (contacts.docs.length > 0) {
            for (let i = 0; i < contacts.docs.length; i++) {
                sendPostToContacts.push(
                    db
                        .collection("Users")
                        .doc(contacts.docs[i].id)
                        .collection("Timeline")
                        .doc(postData.PostID)
                        .set(postData),
                );
            }
        }

        await Promise.all(sendPostToContacts);

        return "";
    });

    e.checkIfJaybenUser = functions.firestore
    .document("Users/{UserID}/Contacts/{ContactID}")
    .onCreate(async (snap, context) => {
        const contactData = snap.data();
        const markAsJaybenUser = [];

        console.log(contactData['Phone Number'][0]);

        console.log(snap['Phone Number'][0]);

        const contacts = await db
            .collection("Users")
            .where("PhoneNumber", "in", contactData['Phone Number'])
            .get();

        if (contacts.docs.length > 0) {
            markAsJaybenUser.push(
                db
                    .collection("Users")
                    .doc(contactData.UserID)
                    .collection("Contacts")
                    .doc(contactData.ContactID)
                    .update({
                        isJaybenUser: true,
                        FullNames: contacts.docs[0].get("FirstName") + " " + contacts.docs[0].get("LastName"),
                        ContactsAccountID: contacts.docs[0].id,
                        ActualAccountPhoneNumber: contacts.docs[0].get("PhoneNumber"),
                        AccountProfileIcon: contacts.docs[0].get("ProfileImage"),
                    }),
            );
        }

        await Promise.all(markAsJaybenUser);

        return "";
    });
};
