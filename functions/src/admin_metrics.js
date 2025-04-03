const admin = require("firebase-admin");
const express = require('express');
const app = express();
const functions = require("firebase-functions");
const db = admin.firestore();

module.exports = function (e) {
    app.get('/metrics/get', async (req, res) => {
        let totalSavingsAccBal = 0;
        let totalGroupSavings = 0;
        let totalActiveLoans = 0;
        let totalUserBalances = 0;
        let totalAgentBalances = 0;
        let totalMerchantBals = 0;

        const users = await db
            .collection("Users")
            .where("AccountType", "==", "Personal")
            .get();

        const agents = await db
            .collection("Users")
            .where("AccountType", "==", "Agent")
            .get();

        const merchants = await db
            .collection("Users")
            .where("AccountType", "==", "Merchant")
            .get();

        const savGroups = await db
            .collection("Savings Groups")
            .where("Active", "==", true)
            .get();

        const savAccs = await db
            .collection("Saving Accounts")
            .where("Active", "==", true)
            .get();

        const loans = await db
            .collection("Loans")
            .where("LoadCurrentStatus", "not-in", ["Pending", "Rejected", "Defaulted"])
            .get();

        const allTransactions = await db
            .collection("Transactions")
            .get();

        const withdrawTransactions = await db
            .collection("Transactions")
            .where("TransactionType", "==", "Withdrawal")
            .where("Status", "==", "Pending")
            .get();

        const requests = await db
            .collection("Requests")
            .get();

        const agentOffences = await db
            .collection("Requests")
            .get();

        const ltdTimeTranx = await db
            .collection("Requests")
            .get();

        const getMetrics = async () => {
            for (let i = 0; i < savAccs.docs.length; i++) {
                totalSavingsAccBal += savAccs.docs[i].get("Balance");
            }

            for (let i = 0; i < savGroups.docs.length; i++) {
                totalGroupSavings += savGroups.docs[i].get("GroupTotalSavings");
            }

            for (let i = 0; i < loans.docs.length; i++) {
                totalActiveLoans += loans.docs[i].get("Amount");
            }

            for (let i = 0; i < users.docs.length; i++) {
                totalUserBalances += users.docs[i].get("Balance");
            }

            for (let i = 0; i < agents.docs.length; i++) {
                totalAgentBalances += agents.docs[i].get("Float");
            }

            for (let i = 0; i < merchants.docs.length; i++) {
                totalMerchantBals += merchants.docs[i].get("Balance");
            }

            await db.collection("Admin").doc("Metrics").update({
                LastUpdated: admin.firestore.FieldValue.serverTimestamp(),
                NumberOfUsers: users.docs.length,
                NumberOfAgents: agents.docs.length,
                NumberOfMerchants: merchants.docs.length,
                NumberOfsavGroups: savGroups.docs.length,
                NumberOfsavAccs: savAccs.docs.length,
                NumberOfloans: loans.docs.length,
                NumberOfrequests: requests.docs.length,
                NumberOfallTransactions: allTransactions.docs.length,
                NumberOfpendingWithdraws: withdrawTransactions.docs.length,
                NumberOfagentOffences: agentOffences.docs.length,
                NumberOfltdTimeTranx: ltdTimeTranx.docs.length,
                totalSavingsAccBal: totalSavingsAccBal,
                totalGroupSavings: totalGroupSavings,
                totalActiveLoans: totalActiveLoans,
                totalUserBalances: totalUserBalances,
                totalMerchantBals: totalMerchantBals,
                totalAgentBalances: totalAgentBalances,
            });

            await db.collection("Admin").doc("Metrics").collection("Growth").add({
                DateCreated: admin.firestore.FieldValue.serverTimestamp(),
                NumberOfUsers: users.docs.length,
                NumberOfAgents: agents.docs.length,
                NumberOfMerchants: merchants.docs.length,
                NumberOfsavGroups: savGroups.docs.length,
                NumberOfsavAccs: savAccs.docs.length,
                NumberOfloans: loans.docs.length,
                NumberOfrequests: requests.docs.length,
                NumberOfallTransactions: allTransactions.docs.length,
                NumberOfpendingWithdraws: withdrawTransactions.docs.length,
                NumberOfagentOffences: agentOffences.docs.length,
                NumberOfltdTimeTranx: ltdTimeTranx.docs.length,
                totalSavingsAccBal: totalSavingsAccBal,
                totalGroupSavings: totalGroupSavings,
                totalActiveLoans: totalActiveLoans,
                totalUserBalances: totalUserBalances,
                totalMerchantBals: totalMerchantBals,
                totalAgentBalances: totalAgentBalances,
            });

            res.status(201).send({
                "status": "Success",
                "Code": 201,
                "ReponseMessage": {
                    "users": users.docs.length,
                    "agents": agents.docs.length,
                    "merchants": merchants.docs.length,
                    "savGroups": savGroups.docs.length,
                    "savAccs": savAccs.docs.length,
                    "loans": loans.docs.length,
                    "requests": requests.docs.length,
                    "allTransactions": allTransactions.docs.length,
                    "withdrawTransactions": withdrawTransactions.docs.length,
                    "agentOffences": agentOffences.docs.length,
                    "ltdTimeTranx": ltdTimeTranx.docs.length,
                    "totalSavingsAccBal": totalSavingsAccBal,
                    "totalGroupSavings": totalGroupSavings,
                    "totalActiveLoans": totalActiveLoans,
                    "totalUserBalances": totalUserBalances,
                    "totalMerchantBals": totalMerchantBals,
                    "totalAgentBalances": totalAgentBalances,
                },
            });
        };

        await getMetrics();
    });

    e.admin = functions.https.onRequest(app);
};
