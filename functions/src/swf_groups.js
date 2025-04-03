const admin = require("firebase-admin");
const express = require('express');
const app = express();
const functions = require("firebase-functions");
const db = admin.firestore();

module.exports = function (e) {
    app.post('/swf/go_in_chat', async (req, res) => {
        const body = req.body;

        const goInChat = async () => {
            await db.collection("Savings Groups").doc(body.GroupID).update({
                MembersCurrentlyInChat: admin.firestore.FieldValue.arrayUnion(body.UserID),
                GroupLastMessageReadBy: admin.firestore.FieldValue.arrayUnion(body.UserID),
            });
        };

        await goInChat();
    });

    app.post('/swf/go_out_chat', async (req, res) => {
        const body = req.body;

        const goOutChat = async () => {
            await db.collection("Savings Groups").doc(body.GroupID).update({
                MembersCurrentlyInChat: admin.firestore.FieldValue.arrayRemove(body.UserID),
            });
        };

        await goOutChat();
    });

    app.post('/swf/create_group', async (req, res) => {
        const body = req.body;
        const createGroup = async () => {
            const messageID = Math.random().toString(36).substr(2, 10);

            const adminDoc = await db.collection("Admin").doc("Legal").collection("Savings").doc("Groups").get();

            await db.collection("Users").doc(body.UserID).collection("Groups").doc(body.GroupID).set({
                GroupID: body.GroupID,
                GroupType: "Savings Group",
                GroupName: body.GroupName,
                DateJoined: admin.firestore.FieldValue.serverTimestamp(),
            });
            // deducts from money from user's balance

            await db.collection("Savings Groups").doc(body.GroupID).collection("Members").doc(body.UserID).set({
                    Username: body.Username,
                    UserID: body.UserID,
                    GroupID: body.GroupID,
                    PhoneNumber: body.PhoneNumber,
                    NotificationToken: body.NotificationToken,
                    ProfileIcon: body.ProfileIconUrl,
                    IsAdmin: true,
                    IsSuperAdmin: true,
                    IsBanned: false,
                    ReceiveNotifications: true,
                    Balance: 0.0,
            });
            // add user to group member's list

            await db.collection("Savings Groups").doc(body.GroupID).set({
                GroupLastMessage: 'Group created',
                GroupLastMessageUsername: body.Username,
                GroupLastMessageUserID: body.UserID,
                GroupLastMessageType: "Prompt",
                GroupLastMessageDateSent: admin.firestore.FieldValue.serverTimestamp(),
                GroupLastMessageReadBy: [body.UserID],
                MembersCurrentlyInChat: [],
                GroupMembers: [body.UserID],
                GroupDateCreated: admin.firestore.FieldValue.serverTimestamp(),
                GroupID: body.GroupID,
                GroupName: body.GroupName,
                GroupIconUrl: "",
                GroupVerified: false,
                GroupTotalSavings: 0.0,
                GroupInterestRate: adminDoc.get("MemberInterestRate"),
                GroupCurrency: body.Currency,
                GroupActive: true,
                GroupJoinLink: "",
                GroupType: "SWF",
                VillageBanking: false,
                GroupDescription: "",
                OnlyAdminCanPost: false,
                GroupCreatorUID: body.UserID,
                GroupCreatorUsername: body.Username,
                NumberOfMembers: 1,
            });
            //  creates the group doc

            await db.collection("Savings Groups").doc(body.GroupID).collection("Messages").doc(messageID).set({
                    DateCreated: admin.firestore.FieldValue.serverTimestamp(),
                    MessageID: messageID,
                    MessageReadBy: [body.UserID],
                    OwnerUserID: body.UserID,
                    OwnerUsername: body.Username,
                    Message: 'Group created',
                    MessageType: "Prompt",
                    GroupID: body.GroupID,
                    MessageIsSeen: false,
                    Caption: "",
                    MessageExtension: "",
                    ReplyMessage: "",
                    ReplyCaption: "",
                    ReplySentByUsername: "",
                    ReplySentByUID: "",
                    VideoReplyMessage: "",
                    ReplyMessageType: "",
            });
            //   sends group created message to group

            res.status(201).send("Success");
        };

        try {
            await createGroup();
        } catch (error) {
            res.status(400).send("Failed");
            console.log(error);
        }
    });

    app.post('/swf/get_messages', async (req, res) => {
        const body = req.body;

        const getMessages = async () => {
            // const listOfMsgs = [];
            const numOfMessages = await db.collection("Savings Groups").doc(body.GroupID).collection("Messages").get();

            const messages = await db.collection("Savings Groups").doc(body.GroupID).collection("Messages").orderBy("DateCreated", "desc")
                .limit(numOfMessages.docs.length >= body.NumberOfMessages ? body.NumberOfMessages : numOfMessages.docs.length).get();

            // for (let i = 0; i < messages.docs.length; i++) {
            //     listOfMsgs.push(messages.docs[i].data());
            // }

            res.status(201).send(messages.docs.map((doc) => doc.data()));
        };

        try {
            await getMessages();
        } catch (e) {
            res.status(400).send("Failed");
        }

        // add code to check if user is part of group before making deposit
    });

    app.post('/swf/ban_member', async (req, res) => {
        const body = req.body;

        const groupDoc = await db.collection("Savings Groups").doc(body.GroupID).get();

        const banMember = async () => {
            const messageID = Math.random().toString(36).substr(2, 10);

            await db.collection("Savings Groups").doc(body.GroupID).collection("Members").doc(body.MemberUserID).update({
                IsBanned: true,
            });
            // add user to group member's list

            await db.collection("Savings Groups").doc(body.GroupID).update({
                GroupLastMessage: body.AdminUsername + ' banned ' + body.MemberUsername,
                GroupLastMessageUsername: body.AdminUsername,
                GroupLastMessageUserID: body.AdminUserID,
                GroupLastMessageType: "Prompt",
                GroupLastMessageDateSent: admin.firestore.FieldValue.serverTimestamp(),
                GroupLastMessageReadBy: groupDoc.get("MembersCurrentlyInChat"),
            });
            //  updates the group doc

            await db.collection("Savings Groups").doc(body.GroupID).collection("Messages").doc(messageID).set({
                    DateCreated: admin.firestore.FieldValue.serverTimestamp(),
                    MessageID: messageID,
                    MessageReadBy: [],
                    OwnerUserID: body.AdminUserID,
                    OwnerUsername: body.AdminUsername,
                    Message: body.AdminUsername + ' banned ' + body.MemberUsername,
                    MessageType: "Prompt",
                    GroupID: body.GroupID,
                    MessageIsSeen: false,
                    Caption: "",
                    MessageExtension: "",
                    ReplyMessage: "",
                    ReplyCaption: "",
                    ReplySentByUsername: "",
                    ReplySentByUID: "",
                    VideoReplyMessage: "",
                    ReplyMessageType: "",
            });
            //   sends group created message to group

            const memberDoc = await db.collection("Users").doc(body.MemberUserID).get();

            await admin.messaging().sendToDevice(
                memberDoc.get("NotificationToken"), {
                notification: {
                    title: 'You have banned from ' + body.GroupName,
                    body: 'You have banned from ' + body.GroupName + ' you can nolonger see & post messages and deposit any savings. ',
                    icon: "@drawable/ic_stat_jayben_logo_1_044317_copy_3",
                    clickAction: "FLUTTER_NOTIFICATION_CLICK",
                },
                data: {
                    UserID: "",
                },
            });
            // send notification

            await admin.messaging().sendToDevice(
                body.AdminNotificationToken, {
                notification: {
                    title: 'You have banned ' + body.MemberUsername + ' from ' + body.GroupName,
                    body: body.MemberUsername + ' has been banned from ' + body.GroupName,
                    icon: "@drawable/ic_stat_jayben_logo_1_044317_copy_3",
                    clickAction: "FLUTTER_NOTIFICATION_CLICK",
                },
                data: {
                    UserID: "",
                },
            });
            // send notification

            res.status(201).send("Success");
        };

        try {
            await banMember();
        } catch (e) {
            res.status(400).send("Failed");
        }

        // add code to check if user is part of group before making deposit
    });

    app.post('/swf/add_member', async (req, res) => {
        const body = req.body;

        const groupDoc = await db.collection("Savings Groups").doc(body.GroupID).get();

        const userDocQS = await db.collection("Users").where('Username_searchable', '==', body.MemberUsername).get();

        const addMember = async () => {
            const messageID = Math.random().toString(36).substr(2, 10);

            await db.collection("Users").doc(userDocQS.docs[0].id).collection("Groups").doc(body.GroupID).set({
                GroupID: body.GroupID,
                GroupType: "Savings Group",
                GroupName: body.GroupName,
                DateJoined: admin.firestore.FieldValue.serverTimestamp(),
            });
            // adds a record of the group

            await db.collection("Savings Groups").doc(body.GroupID).collection("Members").doc(userDocQS.docs[0].id).set({
                Username: userDocQS.docs[0].get("Username"),
                UserID: userDocQS.docs[0].id,
                GroupID: body.GroupID,
                PhoneNumber: userDocQS.docs[0].get("PhoneNumber"),
                NotificationToken: userDocQS.docs[0].get("NotificationToken"),
                ProfileIcon: userDocQS.docs[0].get("ProfileImage"),
                IsAdmin: false,
                IsSuperAdmin: false,
                IsBanned: false,
                ReceiveNotifications: true,
                Balance: 0.0,
            });
            // add user to group member's list

            await db.collection("Savings Groups").doc(body.GroupID).update({
                GroupLastMessage: body.InviterUsername + ' has added ' + userDocQS.docs[0].get("Username"),
                GroupLastMessageUsername: body.InviterUsername,
                GroupLastMessageUserID: body.InviterUserID,
                GroupLastMessageType: "Prompt",
                GroupLastMessageDateSent: admin.firestore.FieldValue.serverTimestamp(),
                GroupLastMessageReadBy: groupDoc.get("MembersCurrentlyInChat"),
                GroupMembers: admin.firestore.FieldValue.arrayUnion(userDocQS.docs[0].id),
                NumberOfMembers: admin.firestore.FieldValue.increment(1),
            });
            //  updates the group doc

            await db.collection("Savings Groups").doc(body.GroupID).collection("Messages").doc(messageID).set({
                DateCreated: admin.firestore.FieldValue.serverTimestamp(),
                MessageID: messageID,
                MessageReadBy: [],
                OwnerUserID: body.InviterUserID,
                OwnerUsername: body.InviterUsername,
                Message: body.InviterUsername + ' has added ' + userDocQS.docs[0].get("Username"),
                MessageType: "Prompt",
                GroupID: body.GroupID,
                MessageIsSeen: false,
                Caption: "",
                MessageExtension: "",
                ReplyMessage: "",
                ReplyCaption: "",
                ReplySentByUsername: "",
                ReplySentByUID: "",
                VideoReplyMessage: "",
                ReplyMessageType: "",
            });
            //   sends group created message to group

            await admin.messaging().sendToDevice(
                userDocQS.docs[0].get("NotificationToken"), {
                notification: {
                    title: 'You have added to a group',
                    body: 'Congrats! You have been added to new group by ' + body.InviterUsername,
                    icon: "@drawable/ic_stat_jayben_logo_1_044317_copy_3",
                    clickAction: "FLUTTER_NOTIFICATION_CLICK",
                },
                data: {
                    UserID: "",
                },
            });
            // send notification

            res.status(201).send("Success");
        };

        try {
            await addMember();
        } catch (e) {
            res.status(400).send("Failed");
            console.log(e);
        }

        const group = await db.collection("Savings Groups").get();
        const adminSavGroupDoc = await db.collection("Admin").doc("Legal").collection("Savings").doc("Groups").get();

        if (group.get("NumberOfMembers") >= adminSavGroupDoc.get("MemberThresholdToIncreaseInterestRate")) {
            const updateInterestRate = async () => {
                await db.collection("Savings Groups").doc(body.GroupID).update({
                    GroupInterestRate: adminSavGroupDoc.get("PassedMemberThresholdInterstRate"),
                });
            };

            await updateInterestRate();
        }

        // add code to check if user is part of group before making deposit
    });

    app.post('/swf/remove_member', async (req, res) => {
        const body = req.body;

        const groupDoc = await db.collection("Savings Groups").doc(body.GroupID).get();

        const userDocQS = await db.collection("Users").doc(body.MemberUserID).get();

        const addMember = async () => {
            const messageID = Math.random().toString(36).substr(2, 10);

            await db.collection("Users").doc(body.MemberUserID).collection("Groups").doc(body.GroupID).delete();
            // adds a record of the group

            await db.collection("Savings Groups").doc(body.GroupID).collection("Members").doc(body.MemberUserID).delete();
            // add user to group member's list

            await db.collection("Savings Groups").doc(body.GroupID).update({
                GroupLastMessage: body.InviterUsername + ' removed ' + userDocQS.get("Username"),
                GroupLastMessageUsername: body.InviterUsername,
                GroupLastMessageUserID: body.InviterUserID,
                GroupLastMessageType: "Prompt",
                GroupLastMessageDateSent: admin.firestore.FieldValue.serverTimestamp(),
                GroupLastMessageReadBy: groupDoc.get("MembersCurrentlyInChat"),
                GroupMembers: admin.firestore.FieldValue.arrayRemove(body.MemberUserID),
                NumberOfMembers: admin.firestore.FieldValue.increment(-1),
            });
            //  updates the group doc

            await db.collection("Savings Groups").doc(body.GroupID).collection("Messages").doc(messageID).set({
                    DateCreated: admin.firestore.FieldValue.serverTimestamp(),
                    MessageID: messageID,
                    MessageReadBy: [],
                    OwnerUserID: body.InviterUserID,
                    OwnerUsername: body.InviterUsername,
                    Message: body.InviterUsername + ' removed ' + userDocQS.get("Username"),
                    MessageType: "Prompt",
                    GroupID: body.GroupID,
                    MessageIsSeen: false,
                    Caption: "",
                    MessageExtension: "",
                    ReplyMessage: "",
                    ReplyCaption: "",
                    ReplySentByUsername: "",
                    ReplySentByUID: "",
                    VideoReplyMessage: "",
                    ReplyMessageType: "",
            });
            //   sends group created message to group

            await admin.messaging().sendToDevice(
                userDocQS.get("NotificationToken"), {
                notification: {
                    title: "You've been removed from a group",
                    body: 'You have been removed from one of your groups by ' + body.InviterUsername,
                    icon: "@drawable/ic_stat_jayben_logo_1_044317_copy_3",
                    clickAction: "FLUTTER_NOTIFICATION_CLICK",
                },
                data: {
                    UserID: "",
                },
            });
            // send notification

            res.status(201).send("Success");
        };

        try {
            await addMember();
        } catch (e) {
            res.status(400).send("Failed");
        }

        // add code to check if user is part of group before making deposit
    });

    app.post('/swf/leave_group', async (req, res) => {
        const body = req.body;
        const groupDoc = await db.collection("Savings Groups").doc(body.GroupID).get();

        const addMember = async () => {
            const messageID = Math.random().toString(36).substr(2, 10);
            const newAdminMessageID = Math.random().toString(36).substr(2, 10);

            await db.collection("Users").doc(body.UserID).collection("Groups").doc(body.GroupID).delete();
            // adds a record of the group

            await db.collection("Savings Groups").doc(body.GroupID).collection("Members").doc(body.UserID).delete();
            // add user to group member's list

            await db.collection("Savings Groups").doc(body.GroupID).update({
                GroupLastMessage: body.Username + ' left',
                GroupLastMessageUsername: body.Username,
                GroupLastMessageUserID: body.UserID,
                GroupLastMessageType: "Prompt",
                GroupLastMessageDateSent: admin.firestore.FieldValue.serverTimestamp(),
                GroupLastMessageReadBy: groupDoc.get("MembersCurrentlyInChat"),
                GroupMembers: admin.firestore.FieldValue.arrayRemove(body.UserID),
                NumberOfMembers: admin.firestore.FieldValue.increment(-1),
            });
            //  updates the group doc

            await db.collection("Savings Groups").doc(body.GroupID).collection("Messages").doc(messageID).set({
                    DateCreated: admin.firestore.FieldValue.serverTimestamp(),
                    MessageID: messageID,
                    MessageReadBy: [],
                    OwnerUserID: body.UserID,
                    OwnerUsername: body.Username,
                    Message: body.Username + ' left',
                    MessageType: "Prompt",
                    GroupID: body.GroupID,
                    MessageIsSeen: false,
                    Caption: "",
                    MessageExtension: "",
                    ReplyMessage: "",
                    ReplyCaption: "",
                    ReplySentByUsername: "",
                    ReplySentByUID: "",
                    VideoReplyMessage: "",
                    ReplyMessageType: "",
            });
            //  sends group created message to group

            const admins = await db.collection("Savings Groups").doc(body.GroupID).collection("Members").where("IsAdmin", "==", true).get();

            if (admins.docs.length == 0) {
                const newAdmin = await db
                    .collection("Savings Groups")
                    .doc(body.GroupID)
                    .collection("Members")
                    .where("IsAdmin", "==", false)
                    .get();

                await db
                    .collection("Savings Groups")
                    .doc(body.GroupID)
                    .collection("Members")
                    .doc(newAdmin.docs[0].id)
                    .update({
                        IsAdmin: true,
                    });

                await db.collection("Savings Groups").doc(body.GroupID).set({
                    GroupLastMessage: newAdmin.docs[0].get("Username") + ' is now admin.',
                    GroupLastMessageUsername: newAdmin.docs[0].get("Username"),
                    GroupLastMessageUserID: newAdmin.docs[0].id,
                    GroupLastMessageType: "Prompt",
                    GroupLastMessageDateSent: admin.firestore.FieldValue.serverTimestamp(),
                    GroupLastMessageReadBy: groupDoc.get("MembersCurrentlyInChat"),
                });
                //  updates the group doc

                await db
                    .collection("Savings Groups")
                    .doc(body.GroupID)
                    .collection("Messages")
                    .doc(newAdminMessageID)
                    .set({
                        DateCreated: admin.firestore.FieldValue.serverTimestamp(),
                        MessageID: newAdminMessageID,
                        MessageReadBy: [],
                        OwnerUserID: newAdmin.docs[0].id,
                        OwnerUsername: newAdmin.docs[0].get("Username"),
                        Message: newAdmin.docs[0].get("Username") + ' is now admin',
                        MessageType: "Prompt",
                        GroupID: body.GroupID,
                        MessageIsSeen: false,
                        Caption: "",
                        MessageExtension: "",
                        ReplyMessage: "",
                        ReplyCaption: "",
                        ReplySentByUsername: "",
                        ReplySentByUID: "",
                        VideoReplyMessage: "",
                        ReplyMessageType: "",
                    });
                //  sends new admin message
            }

            res.status(201).send("Success");
        };

        try {
            await addMember();
        } catch (e) {
            res.status(400).send("Failed");
        }

        // add code to check if user is part of group before making deposit
    });

    app.post('/swf/send_message', async (req, res) => {
        const body = req.body;
        const groupNotifTokens = [];
        const sendMessage = async () => {
            const groupMembers = await db.collection("Savings Groups").doc(body.GroupID).collection("Members").where("ReceiveNotifications", "==", true).get();

            const groupDoc = await db.collection("Savings Groups").doc(body.GroupID).get();

            for (let i = 0; i < groupMembers.docs.length; i++) {
                if (groupMembers.docs[i].get("NotificationToken") != body.NotificationToken) {
                    groupNotifTokens.push(groupMembers.docs[i].get("NotificationToken"));
                }
            }

            await db.collection("Savings Groups").doc(body.GroupID).update({
                GroupLastMessage: body.Message,
                GroupLastMessageUsername: body.OwnerUsername,
                GroupLastMessageUserID: body.OwnerUserID,
                GroupLastMessageType: body.MessageType,
                GroupLastMessageDateSent: admin.firestore.FieldValue.serverTimestamp(),
                GroupLastMessageReadBy: groupDoc.get("MembersCurrentlyInChat"),
            });
            // updates the groupDoc

            await db.collection("Savings Groups").doc(body.GroupID).collection("Messages").doc(body.MessageID).set({
                    DateCreated: admin.firestore.FieldValue.serverTimestamp(),
                    GroupID: body.GroupID,
                    OwnerUserID: body.OwnerUserID,
                    OwnerUsername: body.OwnerUsername,
                    Caption: body.Caption,
                    MessageID: body.MessageID,
                    Message: body.Message,
                    MessageType: body.MessageType,
                    MessageIsSeen: false,
                    MessageExtension: body.MessageExtension,
                    ReplyMessage: body.ReplyMessage,
                    ReplyCaption: body.ReplyCaption,
                    ReplySentByUsername: body.ReplySentByUsername,
                    ReplySentByUID: body.ReplySentByUID,
                    ReplyMessageType: body.ReplyMessageType,
                    VideoReplyMessage: body.VideoReplyMessage,
            });
            // sends group created message to group

            await admin.messaging().sendToDevice(
                groupNotifTokens, {
                notification: {
                    title: body.GroupName,
                    body: body.OwnerUsername + ': ' + body.Message,
                    icon: "@drawable/ic_stat_jayben_logo_1_044317_copy_3",
                    clickAction: "FLUTTER_NOTIFICATION_CLICK",
                },
                data: {
                    UserID: "",
                },
            });
            // send notifications to the group members

            res.status(201).send("Success");
        };

        try {
            await sendMessage();
        } catch (error) {
            res.status(201).send("Failed");
        }
    });

    app.post('/swf/make_admin', async (req, res) => {
        const body = req.body;
        const messageID = Math.random().toString(36).substr(2, 10);

        const groupDoc = await db
            .collection("Savings Groups")
            .doc(body.GroupID)
            .get();

        const makeAdmin = async () => {
            await db
                .collection("Savings Groups")
                .doc(body.GroupID)
                .collection("Members")
                .doc(body.NewAdminUserID)
                .update({
                    IsAdmin: true,
                });
            // makes user an admin

            await db.collection("Savings Groups").doc(body.GroupID).update({
                GroupLastMessage: body.AdminUsername + ' has made ' + body.NewAdminUsername + ' an admin',
                GroupLastMessageUsername: body.AdminUsername,
                GroupLastMessageUserID: body.AdminUserID,
                GroupLastMessageType: 'Prompt',
                GroupLastMessageDateSent: admin.firestore.FieldValue.serverTimestamp(),
                GroupLastMessageReadBy: groupDoc.get("MembersCurrentlyInChat"),
            });
            // increases the group's balance

            await db
                .collection("Savings Groups")
                .doc(body.GroupID)
                .collection("Messages")
                .doc(messageID)
                .set({
                    DateCreated: admin.firestore.FieldValue.serverTimestamp(),
                    MessageID: messageID,
                    OwnerUserID: body.AdminUserID,
                    OwnerUsername: body.AdminUsername,
                    Message: body.AdminUsername + ' has made ' + body.NewAdminUsername + ' an admin',
                    MessageType: "Prompt",
                    GroupID: body.GroupID,
                    MessageIsSeen: false,
                    Caption: "",
                    MessageExtension: "",
                    ReplyMessage: "",
                    ReplyCaption: "",
                    ReplySentByUsername: "",
                    ReplySentByUID: "",
                    VideoReplyMessage: "",
                    ReplyMessageType: "",
                });
            // sends a message to group

            await admin.messaging().sendToDevice(
                body.AdminNotificationToken, {
                notification: {
                    title: "New admin",
                    body: body.NewAdminUsername + ' is now an admin.',
                    icon: "@drawable/ic_stat_jayben_logo_1_044317_copy_3",
                    clickAction: "FLUTTER_NOTIFICATION_CLICK",
                },
                data: {
                    UserID: "",
                },
            });
            // send notification to the user

            res.status(201).send("Success");
        };

        try {
            await makeAdmin();
        } catch (e) {
            res.status(201).send("Failed");
        }

        // add code to check if user is part of group before making deposit
    });

    app.post('/swf/remove_admin', async (req, res) => {
        const body = req.body;
        const messageID = Math.random().toString(36).substr(2, 10);

        const groupDoc = await db
            .collection("Savings Groups")
            .doc(body.GroupID)
            .get();

        const removeAdmin = async () => {
            await db.collection("Savings Groups").doc(body.GroupID).collection("Members").doc(body.RemoveAdminUserID).update({
                    IsAdmin: false,
            });
            // makes user an admin

            await db.collection("Savings Groups").doc(body.GroupID).update({
                GroupLastMessage: body.RemoveAdminUsername + ' is nolonger an admin',
                GroupLastMessageUsername: body.AdminUsername,
                GroupLastMessageUserID: body.AdminUserID,
                GroupLastMessageType: 'Prompt',
                GroupLastMessageDateSent: admin.firestore.FieldValue.serverTimestamp(),
                GroupLastMessageReadBy: groupDoc.get("MembersCurrentlyInChat"),
            });
            // increases the group's balance

            await db.collection("Savings Groups").doc(body.GroupID).collection("Messages").doc(messageID).set({
                    DateCreated: admin.firestore.FieldValue.serverTimestamp(),
                    MessageID: messageID,
                    OwnerUserID: body.AdminUserID,
                    OwnerUsername: body.AdminUsername,
                    Message: body.RemoveAdminUsername + ' is nolonger an admin',
                    MessageType: "Prompt",
                    GroupID: body.GroupID,
                    MessageIsSeen: false,
                    Caption: "",
                    MessageExtension: "",
                    ReplyMessage: "",
                    ReplyCaption: "",
                    ReplySentByUsername: "",
                    ReplySentByUID: "",
                    VideoReplyMessage: "",
                    ReplyMessageType: "",
            });
            // sends a message to group

            await admin.messaging().sendToDevice(
                body.AdminNotificationToken, {
                notification: {
                    title: "Admin removed",
                    body: body.RemoveAdminUsername + ' is nolonger an admin.',
                    icon: "@drawable/ic_stat_jayben_logo_1_044317_copy_3",
                    clickAction: "FLUTTER_NOTIFICATION_CLICK",
                },
                data: {
                    UserID: "",
                },
            });
            // send notification to the user

            res.status(201).send("Success");
        };

        try {
            await removeAdmin();
        } catch (e) {
            res.status(201).send("Failed");
        }

        // add code to check if user is part of group before making deposit
    });

    app.post('/swf/exit_group', async (req, res) => {
        const body = req.body;
        const messageID = Math.random().toString(36).substr(2, 10);

        const groupDoc = await db.collection("Savings Groups").doc(body.GroupID).get();

        const removeAdmin = async () => {
            await db.collection("Savings Groups").doc(body.GroupID).collection("Members").doc(body.RemoveAdminUserID).update({
                    IsAdmin: false,
            });
            // makes user an admin

            await db.collection("Savings Groups").doc(body.GroupID).update({
                GroupLastMessage: body.RemoveAdminUsername + ' is nolonger an admin',
                GroupLastMessageUsername: body.AdminUsername,
                GroupLastMessageUserID: body.AdminUserID,
                GroupLastMessageType: 'Prompt',
                GroupLastMessageDateSent: admin.firestore.FieldValue.serverTimestamp(),
                GroupLastMessageReadBy: groupDoc.get("MembersCurrentlyInChat"),
            });
            // increases the group's balance

            await db.collection("Savings Groups").doc(body.GroupID).collection("Messages").doc(messageID).set({
                    DateCreated: admin.firestore.FieldValue.serverTimestamp(),
                    MessageID: messageID,
                    OwnerUserID: body.AdminUserID,
                    OwnerUsername: body.AdminUsername,
                    Message: body.RemoveAdminUsername + ' is nolonger an admin',
                    MessageType: "Prompt",
                    GroupID: body.GroupID,
                    MessageIsSeen: false,
                    Caption: "",
                    MessageExtension: "",
                    ReplyMessage: "",
                    ReplyCaption: "",
                    ReplySentByUsername: "",
                    ReplySentByUID: "",
                    VideoReplyMessage: "",
                    ReplyMessageType: "",
            });
            // sends a message to group

            await admin.messaging().sendToDevice(
                body.AdminNotificationToken, {
                notification: {
                    title: "Admin removed",
                    body: body.RemoveAdminUsername + ' is nolonger an admin.',
                    icon: "@drawable/ic_stat_jayben_logo_1_044317_copy_3",
                    clickAction: "FLUTTER_NOTIFICATION_CLICK",
                },
                data: {
                    UserID: "",
                },
            });
            // send notification to the user

            res.status(201).send("Success");
        };

        try {
            await removeAdmin();
        } catch (e) {
            res.status(201).send("Failed");
        }


        // add code to check if user is part of group before making deposit
    });

    app.post('/swf/deposit', async (req, res) => {
        const body = req.body;
        const depositID = Math.random().toString(36).substr(2, 10);
        const groupNotifTokens = [];

        const userDoc = await db.collection("Users").doc(body.UserID).get();

        const groupMembers = await db.collection("Savings Groups").doc(body.GroupID).collection("Members").where("ReceiveNotifications", "==", true).get();

        const groupDoc = await db.collection("Savings Groups").doc(body.GroupID).get();

        const makeADeposit = async () => {
            for (let i = 0; i < groupMembers.docs.length; i++) {
                if (groupMembers.docs[i].get("NotificationToken") != body.NotificationToken) {
                    groupNotifTokens.push(groupMembers.docs[i].get("NotificationToken"));
                }
            }

            await db.collection("Users").doc(body.UserID).update({
                Balance: admin.firestore.FieldValue.increment(-body.Amount),
            });
            // deducts from money from user's balance

            await db.collection("Savings Groups").doc(body.GroupID).collection("Members").doc(body.UserID).update({
                Balance: admin.firestore.FieldValue.increment(body.Amount),
            });
            // adds money to the member doc

            await db.collection("Savings Groups").doc(body.GroupID).update({
                GroupTotalSavings: admin.firestore.FieldValue.increment(body.Amount),
                GroupLastMessage: body.Username + ' deposited ' + userDoc.get("Currency") + ' ' + body.Amount.toString() + ' 💰',
                GroupLastMessageUsername: body.Username,
                GroupLastMessageUserID: body.UserID,
                GroupLastMessageType: 'Prompt',
                GroupLastMessageDateSent: admin.firestore.FieldValue.serverTimestamp(),
                GroupLastMessageReadBy: groupDoc.get("MembersCurrentlyInChat"),
            });
            //  increases the group's balance

            await db.collection("Savings Groups").doc(body.GroupID).collection("Messages").doc(depositID).set({
                    DateCreated: admin.firestore.FieldValue.serverTimestamp(),
                    MessageID: depositID,
                    OwnerUserID: body.UserID,
                    OwnerUsername: body.Username,
                    Message: body.Username + ' deposited ' + userDoc.get("Currency") + ' ' + body.Amount.toString() + ' 💰',
                    MessageType: "Prompt",
                    GroupID: body.GroupID,
                    MessageIsSeen: false,
                    Caption: "",
                    MessageExtension: "",
                    ReplyMessage: "",
                    ReplyCaption: "",
                    ReplySentByUsername: "",
                    ReplySentByUID: "",
                    VideoReplyMessage: "",
                    ReplyMessageType: "",
            });
            //   sends a message to group

            const adminSavGroupDoc = await db.collection("Admin").doc("Legal").collection("Savings").doc("Groups").get();

            const dateToday = new Date();
            dateToday.setMonth(dateToday.getMonth() + adminSavGroupDoc.get("PaymentPeriodMonths"));
            const expirationDateFormatted = dateToday.toString().substring(4, 15);
            // formats expiration date to eg: "Jul 13 2022"

            await db.collection("Groups Transactions").doc(depositID).set({
                DateCreated: admin.firestore.FieldValue.serverTimestamp(),
                ExpirationDate: dateToday.toString(),
                ExpirationDateFormatted: expirationDateFormatted,
                isExpired: false,
                Amount: body.Amount,
                InterestRate: groupDoc.get("GroupInterestRate"),
                SendToWalletOnExp: true,
                UserID: body.UserID,
                GroupID: body.GroupID,
                FullNames: userDoc.get("FirstName") + " " + userDoc.get("LastName"),
                Status: "Pending",
                AttendedTo: false,
                Currency: userDoc.get("Currency"),
                Method: "Wallet Transfer",
                Txref: "",
                TransactionID: depositID,
                Comment: "",
                SentReceived: "Received",
                TransactionType: "Deposit",
                PhoneNumber: "To " + groupDoc.get("GroupName"),
            });
            //   records the transaction for the group

            await db.collection("Transactions").doc(depositID).set({
                DateCreated: admin.firestore.FieldValue.serverTimestamp(),
                Amount: body.Amount,
                UserID: body.UserID,
                FullNames: userDoc.get("FirstName") + " " + userDoc.get("LastName"),
                Status: "Completed",
                AttendedTo: false,
                Currency: userDoc.get("Currency"),
                Method: "Deposit into a Sav Group",
                Txref: "",
                TransactionID: depositID,
                Comment: "Deposited money into a group",
                SentReceived: "Sent",
                TransactionType: "Transfer",
                PhoneNumber: "To " + groupDoc.get("GroupName"),
            });
            //   records the transaction

            await admin.messaging().sendToDevice(
                userDoc.get("NotificationToken"), {
                notification: {
                    title: "Group Deposit Successful 💰",
                    body: 'You have deposited ' + userDoc.get("Currency") + ' ' + body.Amount.toString() + ' to ' + groupDoc.get("GroupName"),
                    icon: "@drawable/ic_stat_jayben_logo_1_044317_copy_3",
                    clickAction: "FLUTTER_NOTIFICATION_CLICK",
                },
                data: {
                    UserID: "",
                },
            });
            // send notification to the user

            await admin.messaging().sendToDevice(
                groupNotifTokens, {
                notification: {
                    title: groupDoc.get("GroupName"),
                    body: body.Username + ' deposited ' + userDoc.get("Currency") + ' ' + body.Amount.toString() + ' 💰',
                    icon: "@drawable/ic_stat_jayben_logo_1_044317_copy_3",
                    clickAction: "FLUTTER_NOTIFICATION_CLICK",
                },
                data: {
                    UserID: "",
                },
            });
            // send notifications to the group members

            res.status(201).send("Success");
        };

        try {
            if (userDoc.get("Balance") >= body.Amount) {
                await makeADeposit();
            } else {
                res.status(201).send("Failed - User balance not sufficient");
            }
        } catch (e) {
            res.status(201).send("Failed");
            console.log(e);
        }

        // add code to check if user is part of group before making deposit
    });

    e.groupsFunctions = functions.https.onRequest(app);
};
