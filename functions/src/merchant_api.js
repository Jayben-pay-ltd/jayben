const functions = require("firebase-functions");
const cors = require("cors")({ origin: true });
const admin = require("firebase-admin");
const express = require('express');
const crypto = require('crypto');
const needle = require('needle');
const axios = require("axios");
const db = admin.firestore();
const uuid = require("uuid");
const app = express();
app.use(express.json());
app.use(express.urlencoded({ extended: true }));
app.use(cors);

module.exports = function (e) {
    // this calls the merchant's webhook url 
    app.post('/v1/internal/admin/merchant/webhook/call', async (req, res) => {
        const body = req.body;

        /*
        body preview:
            {
                "userID": "string",
                "reference": "string",
                "merchantUID": "string",
                "amountToPay": "double",
                "transactionID": "string",
            }
        */

        const merchantDoc = await db.collection("Merchants").doc(body.merchantUID).get();

        const senderDoc = await db.collection("Users").doc(body.userID).get();

        const callWebhook = async () => {
            console.log("Calling merchant's webhook now boss...");

            axios({
                method: 'post',
                url: merchantDoc.get("WebhookUrl"),
                headers: {
                    "secret-hash": merchantDoc.get("SecretHash"),
                },
                data: {
                    event: "payment.completed",
                    data: {
                        tranx_id: body.transactionID,
                        reference: body.reference,
                        amount: body.amountToPay,
                        currency: senderDoc.get("Currency"),
                        country: senderDoc.get("Country"),
                        charged_amount: body.amountToPay,
                        merchant_fee: 0,
                        processor_response: "Approved by Financial Institution",
                        status: "successful",
                        payment_type: "internal transfer",
                        created_at: admin.firestore.FieldValue.serverTimestamp(),
                        account_id: merchantDoc.get("AccountID"),
                        customer: {
                            id: senderDoc.get("UserID"),
                            name: `${senderDoc.get("FirstName")} ${senderDoc.get("LastName")}`,
                            phone_number: senderDoc.get("PhoneNumber"),
                            username: senderDoc.get("Username"),
                            email: senderDoc.get("Email"),
                        },
                    },
                },
            }).then(async function (response) {
                console.log(response.data);

                console.log("Everything looks good, we've gotten a response from the merchant's webhook and call is now being terminated boss");

                res.status(201).send("Success");
            }).catch(async function (error) {
                console.log(error);

                console.log("There was an error calling merchant's webhook boss. Error has been printed out for you to see...");

                // gets sms doc containing keys
                const smsKeys = await db.collection("Admin").doc("Legal").collection("APIs").doc("PaymentAPI").get();

                // 1). records the error in Webhook errors 
                // 2). sends sms to tech support number
                await Promise.all([db.collection("Webhook Errors").doc(body.transactionID).set({
                    AttednedTo: false,
                    UserID: body.userID,
                    DepositStatus: "Failed",
                    Error: error.toString(),
                    TransactionID: body.transactionID,
                    Stage: "Check webhook status stage",
                    MerchantID: merchantDoc.get("AccountID"),
                    ErrorMessage: 'Failed: ' + error.message,
                    DateCreated: admin.firestore.FieldValue.serverTimestamp(),
                }),
                needle(
                    'post',
                    'https://www.smszambia.com/smsservice/jsonapi',
                    JSON.stringify(
                        {
                            "auth": {
                                "username": "sm7-jayben",
                                "password": "J@yEnt",
                                "sender_id": "JaybenError",
                            }, "messages": [
                                {
                                    "phone": `${smsKeys.get("TechSupportLine").replace("+", "")}`,
                                    "message": `A deposit error was detected at the webhook status stage boss`,
                                },
                            ],
                        },
                    ), { json: true }),
                ]);

                res.status(400).send("Failed");
            });
        };

        try {
            await callWebhook();
        } catch (e) {
            console.log(e);

            res.status(400).send("failed");
        }
    });

    // this is a test webhook
    app.post('/66398fnskfj/test/webhook/jayben-webhook', async (req, res) => {
        const payload = req.body;

        const merchantDoc = await db.collection("Merchants").doc(payload.data.account_id).get();
        const secretHash = merchantDoc.get("SecretHash");
        const signature = req.headers['secret-hash'];

        console.log("test point 1");

        const verifyPaymentAndDeliverProduct = async () => {
            console.log("test point 2");

            axios({
                method: 'post',
                url: 'https://us-central1-jayben-de41c.cloudfunctions.net/api/v1/transfer/verify',
                data: {
                    auth: {
                        account_id: payload.data.account_id,
                        api_key: merchantDoc.get("LiveApiKey"),
                    },
                    tranx_id: payload.data.tranx_id,
                },
            }).then(async function (response) {
                console.log("test point 3");
                if (response.data.status === "success") {
                    console.log(`Product/service ${payload.data.reference} has successfully been confirmed and delivered`);
                }

                res.status(200).send("success");
            }).catch(async function (error) {
                console.log(error);
                console.log("test point 4");

                res.status(400).send("Failed");
            });

            console.log("test point 5");
        };

        if (signature !== secretHash) {
            console.log("test point 8");
            // This request isn't from Jayben; discard
            res.status(401).send("Fuck off!");
        } else {
            console.log("test point 6");
            verifyPaymentAndDeliverProduct();
            console.log("test point 7");
        }
    });

    // this is the sparco webhoook to detect merchant deposits
    app.post('/v1/merchant/sparco-webhook', async (req, res) => {
        /*
        sparco webhook payload: 
            {
                "amount": 1,
                "feeAmount": 0.035,
                "transactionAmount": 1.035,
                "currency": "ZMW",
                "customerFirstName": "CompanyName",
                "customerLastName": "",
                "customerMobileWallet": "0961453688",
                "feePercentage": 3.4,
                "merchantReference": "transactionID",
                "reference": "eyJ0aWQiOiAyMTksICJlbnYiOiAicCJ9",
                "message": "Transaction was successful",
                "status": "TXN_AUTH_SUCCESSFUL",
                "signedFields": "merchantReference,reference,amount,currency,feeAmount,feePercentage,transactionAmount,customerMobileWallet,customerFirstName,customerLastName,message,status,signedFields",
                "signature": "6wf7B0GHyZFDZX9e7AKam+dlTAgws5RV0TjF35CGGbc=",
                "isError": false,
            }
        */

        const payload = req.body;

        console.log(payload);

        const sparcoKeys = await db.collection("Admin").doc("Legal").collection("Sparco").doc("Keys").get();

        console.log("test point 1");
        const verifyDepositTransaction = async () => {
            const merchantDocs = await db.collection("Merchants").where("CompanyName", "==", payload.customerFirstName).get();
            const depositDoc = await db.collection("Merchants").doc(merchantDocs.docs[0].id).collection("Deposits").doc(payload.merchantReference).get();

            axios({
                method: 'get',
                url: `https://live.sparco.io/gateway/api/v1/transaction/query?reference=${payload.reference}&merchantReference=${payload.merchantReference}`,
                headers: {
                    "pubKey": sparcoKeys.get("Public_Key"),
                },
            }).then(async function (response) {
                if (response.data.status === "TXN_AUTH_SUCCESSFUL" &&
                    depositDoc.get("DepositStatus") === "Pending") {
                    console.log("test point 3");

                    // credits merchant account
                    await creditMerchantAccount(merchantDocs);
                    // creates a successful transaction record as well

                    console.log("test point 3BB");
                } else if (response.data.status === "TXN_AUTH_UNSUCCESSFUL" &&
                    depositDoc.get("DepositStatus") === "Pending") {
                    // makes the deposit document as failed
                    await db.collection("Merchants").doc(merchantDocs.docs[0].id).collection("Deposits").doc(payload.merchantReference).set({
                        DepositStatus: "Failed",
                    });

                    console.log("Merchant Payment confirmation was unsuccessful boss");

                    res.status(201).send("Failed");
                }
            }).catch(async function (error) {
                console.log(error);
                console.log("test point 4");

                res.status(400).send("Failed");
            });
        };

        // converts the payload to a string according 
        // to signedField key according to it's value's format in the payload
        const formatPayload = async (payload) => {
            const signedFields = payload.signedFields.split(',');
            let result = '';

            for (let i = 0; i < signedFields.length; i++) {
                const key = signedFields[i];
                const value = payload[key];
                if (value !== undefined) {
                    result += `${key}=${value},`;
                }
            }

            return result.slice(0, -1);
        };

        const confirmSignature = async () => {
            console.log("test point 2");

            // Define the signed fields string
            const signedFields = await formatPayload(payload);

            const hmac = crypto.createHmac("sha256", sparcoKeys.get("Secret_Key"));

            const digest = hmac.update(signedFields).digest('Base64');

            const isVerified = payload.signature === digest;

            console.log(`Verification result is: ${isVerified}`);

            if (isVerified && payload.status === "TXN_AUTH_SUCCESSFUL") {
                console.log(`We are now verifying the deposit transaction boss...`);
                await verifyDepositTransaction();
                console.log(`deposit transaction verification has completed boss...`);
            } else {
                console.log(`Signature is invalid boss...`);

                res.status(400).send("Signature is invalid");
            }

            console.log("test point 5");
        };

        const creditMerchantAccount = async (merchantDocs) => {
            // credit merchant account, and creates a successful transaction record
            await Promise.all([
                db.collection("Merchants").doc(merchantDocs.docs[0].id).update({
                    Balance: admin.firestore.FieldValue.increment(payload.transactionAmount),
                    BalanceAtLastDeposit: merchantDocs.docs[0].get("Balance"),
                }),
                db.collection("Merchants").doc(merchantDocs.docs[0].id).collection("Transactions").doc(payload.merchantReference).set({
                    Comment: "",
                    Currency: "ZMW",
                    Type: "Deposit",
                    AttendedTo: false,
                    Status: "Completed",
                    SentReceived: "Received",
                    TransactionType: "Deposit",
                    Reference: "Float Deposit",
                    Amount: payload.transactionAmount,
                    Method: "Deposit to Float Balance",
                    TransactionID: payload.merchantReference,
                    Country: merchantDocs.docs[0].get("Country"),
                    AccountID: merchantDocs.docs[0].get("AccountID"),
                    MerchantCode: merchantDocs.docs[0].get("MerchantCode"),
                    DateCreated: admin.firestore.FieldValue.serverTimestamp(),
                    Customer: {
                        Email: "---",
                        UserID: "---",
                        Username: "---",
                        PhoneNumber: "---",
                        FullNames: "---",
                    },
                    DepositDetails: {
                        isError: false,
                        amount: payload.amount,
                        status: payload.status,
                        message: payload.message,
                        currency: payload.currency,
                        feeAmount: payload.feeAmount,
                        reference: payload.reference,
                        signature: payload.signature,
                        signedFields: payload.signedFields,
                        feePercentage: payload.feePercentage,
                        customerLastName: payload.customerLastName,
                        transactionAmount: payload.transactionAmount,
                        customerFirstName: payload.customerFirstName,
                        merchantReference: payload.merchantReference,
                        customerMobileWallet: payload.customerMobileWallet,
                    },
                }),
                db.collection("Merchants").doc(merchantDocs.docs[0].id).collection("Deposits").doc(payload.merchantReference).set({
                    DepositStatus: "Successful",
                }),
            ]);

            res.status(201).send("Success");
        };

        try {
            await confirmSignature();
        } catch (e) {
            console.log(e);

            res.status(400).send("Failed");
        }
    });

    // gets a deposit link from sparco and returns it to the merchant
    app.post('/v1/merchant/deposit/get_payment_link', async (req, res) => {
        const requestBody = req.body;

        console.log("test point 1");

        const sparcoKeys = await db.collection("Admin").doc("Legal").collection("Sparco").doc("Keys").get();

        /*
        client body preview:
            {
                "Amount": double,
                "Name": "string",
                "Email": "string",
                "Currency": "string",
                "MerchantUID": _myUID,
                "PhoneNumber": "string",
            }
        */

        const requestPaymentLink = async (requestBody) => {
            console.log("test point 2");

            const depositID = uuid.v4();

            console.log(sparcoKeys.get("QueryPaymentLinkUrl"));

            // creates a deposit document
            await db.collection("Merchants").doc(requestBody.MerchantUID).collection("Deposits").doc(depositID).set({
                Currency: "ZMW",
                ErrorMessage: "",
                DepositID: depositID,
                Name: requestBody.Name,
                DepositStatus: "Pending",
                Email: requestBody.Email,
                Amount: requestBody.Amount,
                TransactionType: "Deposit",
                PhoneNumber: requestBody.PhoneNumber,
                MerchantUID: requestBody.MerchantUID,
                DateCreated: admin.firestore.FieldValue.serverTimestamp(),
            });

            axios({
                method: 'post',
                url: sparcoKeys.get("QueryPaymentLinkUrl"),
                data: {
                    "merchantPublicKey": sparcoKeys.get("Public_Key"),
                    "customerPhone": requestBody.PhoneNumber,
                    "transactionName": "Merchant Float Deposit",
                    "customerFirstName": requestBody.Name,
                    "customerEmail": requestBody.Email,
                    "transactionReference": depositID,
                    "customerLastName": "Jayben ZM",
                    "amount": requestBody.Amount,
                    "currency": "ZMW",
                },
            }).then(async function (response) {
                console.log(response.data);

                if (response.data.message === "" && !response.data.isError && response.data.paymentUrl !== "") {
                    await db.collection("Merchants").doc(requestBody.MerchantUID).collection("Deposits").doc(depositID).update({
                        Reference: response.data.reference,
                        PaymentLink: response.data.paymentUrl,
                    });

                    res.status(203).send(response.data.paymentUrl);
                }
            }).catch(async function (error) {
                console.log(error);

                console.log("test point 4");

                await db.collection("Merchants").doc(requestBody.MerchantUID).collection("Deposits").doc(depositID).update({
                    ErrorMessage: "There was an error: Please check cloud function logs at ErrorDate timestamp, Justine.",
                    ErrorDate: admin.firestore.FieldValue.serverTimestamp(),
                    DepositStatus: "Failed",
                });

                res.status(407).send("Failed");
            });

            console.log("test point 5");
        };

        try {
            await requestPaymentLink(requestBody);
        } catch (e) {
            console.log(e);

            res.status(409).send("failed");
        }
    });

    // ===================== APIs merchants can call from their backends

    // allows merchants to transfer money to clients
    app.post('/v1/transfer/customer', async (req, res) => {
        const requestDetails = req.body;
        const apiKey = requestDetails["auth"]["api_key"];
        const accountID = requestDetails["auth"]["account_id"];
        const merchantDoc = await db.collection("Merchants").where("AccountID", "==", accountID).get();
        const customerDoc = await db.collection("Users").where("Username_searchable", "==", requestDetails['customer']['customer_username'].toString().toLowerCase()).get();
        const numOfAccs = merchantDoc.docs.length;

        /*
        body preview:
        {
            'amount': 20,
            'country': 'ZM',
            'currency': 'ZMW',
            'tranx_id': '288200108',
            'auth': {
                'account_id': 'string',
                'api_key': 'string',
            },
            'customer': {
                'customer_name': 'Justine Katebe',
                'customer_username': 'Just0',
                'customer_phone_number': '260977888707',
            },
            'merchant': {
                'merchant_code': 'uwed15',
            },
        },
        */

        const transfer = async () => {
            // gets transactions that have the same tranx_id as the current transaction
            const duplicateIDCheck = await db.collection("Merchants").doc(accountID).collection("Transactions").where("TransactionID", "==", requestDetails["tranx_id"]).get();

            // if user is using a duplicate transaction id, send error
            if (duplicateIDCheck.docs.length != 0) {
                res.status(400).send({
                    'status': 'failed',
                    'code': '400',
                    'message': 'Duplicate tranx_id found. Please use another transaction ID.',
                    'data': {
                        'tranx_id': requestDetails["tranx_id"],
                        'amount': requestDetails["amount"],
                        'currency': requestDetails["currency"],
                        'country': requestDetails["country"],
                    },
                });
            } else {
                // 1). Deducts amount from merchant's account balance
                // 2). Records the transactions on the merchant's side
                // 3). Records the transactions on the customer's side
                // 4). Sends customer a payment notifications
                await Promise.all([
                    db.collection("Merchants").doc(accountID).update({
                        AmountSentThisMonthSoFar: admin.firestore.FieldValue.increment(requestDetails.amount),
                        AmountSentTodaySoFar: admin.firestore.FieldValue.increment(requestDetails.amount),
                        TotalAmountSent: admin.firestore.FieldValue.increment(requestDetails.amount),
                        NumberOfTransactionsThisMonthSoFar: admin.firestore.FieldValue.increment(1),
                        Balance: admin.firestore.FieldValue.increment(-requestDetails.amount),
                        NumberOfTransactionsToday: admin.firestore.FieldValue.increment(1),
                        NumberOfTransactions: admin.firestore.FieldValue.increment(1),
                        BalanceAtLastDeposit: merchantDoc.docs[0].get("Balance"),
                    }),
                    db.collection("Transactions").doc(requestDetails["tranx_id"]).set({
                        Comment: "",
                        Type: "Deposit",
                        AttendedTo: false,
                        Status: "Completed",
                        SentReceived: "Received",
                        TransactionType: "Deposit",
                        Method: "Payment from Merchant",
                        Amount: requestDetails['amount'],
                        Country: requestDetails["country"],
                        Currency: requestDetails["currency"],
                        UserID: customerDoc.docs[0].get("UserID"),
                        TransactionID: requestDetails["tranx_id"],
                        FullNames: requestDetails["customer"]["customer_name"],
                        DateCreated: admin.firestore.FieldValue.serverTimestamp(),
                        PhoneNumber: `From ${merchantDoc.docs[0].get("CompanyName")}`,
                        Merchant: {
                            MerchantUID: merchantDoc.docs[0].get("AccountID"),
                            MerchantName: merchantDoc.docs[0].get("CompanyName"),
                            MerchantCode: merchantDoc.docs[0].get("MerchantCode"),
                            MerchantLogoUrl: merchantDoc.docs[0].get("MerchantCode"),
                        },
                    }),
                    db.collection("Merchants").doc(accountID).collection("Transactions").doc(requestDetails["tranx_id"]).set({
                        Comment: "",
                        Reference: "---",
                        Type: "Transfer",
                        AttendedTo: false,
                        Status: "Completed",
                        SentReceived: "Sent",
                        Method: "Float Balance",
                        TransactionType: "Transfer",
                        Amount: requestDetails['amount'],
                        Country: requestDetails["country"],
                        Currency: requestDetails["currency"],
                        TransactionID: requestDetails["tranx_id"],
                        AccountID: merchantDoc.docs[0].get("AccountID"),
                        MerchantCode: requestDetails["merchant"]["merchant_code"],
                        DateCreated: admin.firestore.FieldValue.serverTimestamp(),
                        Customer: {
                            Email: customerDoc.docs[0].get("Email"),
                            UserID: customerDoc.docs[0].get("UserID"),
                            Username: customerDoc.docs[0].get("Username"),
                            PhoneNumber: customerDoc.docs[0].get("PhoneNumber"),
                            FullNames: `${customerDoc.docs[0].get("FirstName")} ${customerDoc.docs[0].get("LastName")}`,
                        },
                    }),
                    db.collection("Transactions").doc(requestDetails["tranx_id"]).collection("Send Customer Notification").add({
                        Amount: requestDetails['amount'],
                        Currency: requestDetails['currency'],
                        MerchantName: merchantDoc.docs[0].get("CompanyName"),
                        NotificationToken: customerDoc.docs[0].get("NotificationToken"),
                    }),
                ]);

                // TODO add code to send money to the merchants mobile money account

                // sends success response
                res.status(200).send({
                    'status': 'success',
                    'code': '200',
                    'message': 'Transfer successful',
                    'data': {
                        'tranx_id': requestDetails["tranx_id"],
                        'amount': requestDetails["amount"],
                        'currency': requestDetails["currency"],
                        'country': requestDetails["country"],
                    },
                });
            }
        };

        // checks if Account ID and API Key are valid, if account is active, and if balance
        const runPreTransferChecks = async () => {
            if (numOfAccs === 0) {
                merchantAccountNotFound(res, requestDetails);
            } else {
                const active = merchantDoc.docs[0].get("Active");
                const accBal = merchantDoc.docs[0].get("Balance");
                const liveAK = merchantDoc.docs[0].get("LiveApiKey");
                const testAK = merchantDoc.docs[0].get("TestApiKey");
                const accMode = merchantDoc.docs[0].get("AccountMode");

                if (active === false) {
                    merchantAccountNotActive(res, requestDetails);
                } else {
                    if (accMode === "Test" && testAK != apiKey) {
                        testAPIKeyInvalid(res, requestDetails);
                    } else {
                        // TODO add code to check if the merchant is active here

                        if (accMode === "Test" && testAK === apiKey) {
                            // adds a test transaction and sends a success res to user
                            await runProcessTestModeCall(res, requestDetails, accountID);
                            // this func doesn't transfer any money
                        } else {
                            if (accMode === "Live" && liveAK != apiKey) {
                                liveAPIKeyInvalid(res, requestDetails);
                            } else {
                                if (accBal < requestDetails.amount) {
                                    merchantBalanceNotEnough(res, requestDetails);
                                } else {
                                    // records real transfer records
                                    await transfer();
                                    // also conducts a transfer from 
                                    // apiUser acc to merchant
                                }
                            }
                        }
                    }
                }
            }
        };

        try {
            if (customerDoc.docs.length != 0) {
                await runPreTransferChecks();
            } else {
                customerAccNotFound(res, requestDetails);
            }
        } catch (e) {
            console.log(e);

            const supportDoc = await db.collection("Admin").doc("Legal").collection("APIs").doc("PaymentAPI").get();

            res.status(400).send({
                'status': 'failed',
                'code': '400',
                'message': `An internal error occurred on our end. Please contact support ${supportDoc.get("TechSupportLine")} via call, text, or whatsapp to report issue.`,
                'data': {
                    'tranx_id': requestDetails["tranx_id"],
                    'amount': requestDetails["amount"],
                    'currency': requestDetails["currency"],
                    'country': requestDetails["country"],
                },
            });
        }

        // ================================== sub functions

        function liveAPIKeyInvalid(res, requestDetails) {
            res.status(400).send({
                'status': 'failed',
                'code': '400',
                'message': 'Invalid API Key',
                'data': {
                    'tranx_id': requestDetails["tranx_id"],
                    'amount': requestDetails["amount"],
                    'currency': requestDetails["currency"],
                    'country': requestDetails["country"],
                },
            });
        }

        function merchantBalanceNotEnough(res, requestDetails) {
            // if account balance is not enough
            res.status(400).send({
                'status': 'failed',
                'code': '400',
                'message': 'Your account balance not enough',
                'data': {
                    'tranx_id': requestDetails["tranx_id"],
                    'amount': requestDetails["amount"],
                    'currency': requestDetails["currency"],
                    'country': requestDetails["country"],
                },
            });
        }

        function testAPIKeyInvalid(res, requestDetails) {
            // if is in test mode and test api key is invalid
            res.status(400).send({
                'status': 'failed',
                'code': '400',
                'message': 'Test Mode API Key is invalid',
                'data': {
                    'tranx_id': requestDetails["tranx_id"],
                    'amount': requestDetails["amount"],
                    'currency': requestDetails["currency"],
                    'country': requestDetails["country"],
                },
            });
        }

        async function runProcessTestModeCall(res, requestDetails, accountID) {
            // if is in test mode and test api key is valid
            // this is clearly when a dev is testing the api
            const duplicateIDCheck = await db.collection("Merchants").doc(accountID).collection("Test Mode Transactions").where("TransactionID", "==", requestDetails["tranx_id"]).get();

            // if user is using a duplicate transaction id, send error
            if (duplicateIDCheck.docs.length != 0) {
                res.status(400).send({
                    'status': 'failed',
                    'code': '400',
                    'message': 'Duplicate tranx_id found. Please use another transaction ID.',
                    'data': {
                        'tranx_id': requestDetails["tranx_id"],
                        'amount': requestDetails["amount"],
                        'currency': requestDetails["currency"],
                        'country': requestDetails["country"],
                    },
                });
            } else {
                // records the test transaction on the apiUser side
                await db.collection("Merchants").doc(accountID).collection("Test Mode Transactions").doc(requestDetails["tranx_id"]).set({
                    Comment: "",
                    Reference: "---",
                    Type: "Transfer",
                    AttendedTo: false,
                    Status: "Completed",
                    SentReceived: "Sent",
                    Method: "Float Balance",
                    TransactionType: "Transfer",
                    Amount: requestDetails['amount'],
                    Country: requestDetails["country"],
                    Currency: requestDetails["currency"],
                    TransactionID: requestDetails["tranx_id"],
                    AccountID: merchantDoc.docs[0].get("AccountID"),
                    MerchantCode: requestDetails["merchant"]["merchant_code"],
                    DateCreated: admin.firestore.FieldValue.serverTimestamp(),
                    Customer: {
                        Email: customerDoc.docs[0].get("Email"),
                        UserID: customerDoc.docs[0].get("UserID"),
                        Username: customerDoc.docs[0].get("Username"),
                        PhoneNumber: customerDoc.docs[0].get("PhoneNumber"),
                        FullNames: `${customerDoc.docs[0].get("FirstName")} ${customerDoc.docs[0].get("LastName")}`,
                    },
                });

                // sends response
                res.status(200).send({
                    'status': 'success',
                    'code': '200',
                    'message': 'Test mode transfer successful',
                    'data': {
                        'tranx_id': requestDetails["tranx_id"],
                        'amount': requestDetails["amount"],
                        'currency': requestDetails["currency"],
                        'country': requestDetails["country"],
                    },
                });
            }
        }

        function merchantAccountNotActive(res, requestDetails) {
            // if account is not active, send error
            res.status(400).send({
                'status': 'failed',
                'code': '400',
                'message': 'Account not active, please contact support',
                'data': {
                    'tranx_id': requestDetails["tranx_id"],
                    'amount': requestDetails["amount"],
                    'currency': requestDetails["currency"],
                    'country': requestDetails["country"],
                },
            });
        }

        function customerAccNotFound(res, requestDetails) {
            // if customer account is not found, send error
            res.status(400).send({
                'status': 'failed',
                'code': '400',
                'message': 'Customer account not found. Try using a different customer_username',
                'data': {
                    'tranx_id': requestDetails["tranx_id"],
                    'amount': requestDetails["amount"],
                    'currency': requestDetails["currency"],
                    'country': requestDetails["country"],
                },
            });
        }

        function merchantAccountNotFound(res, requestDetails) {
            // if the account ID is non existent, send error
            res.status(400).send({
                'status': 'failed',
                'code': '400',
                'message': 'Invalid Account ID',
                'data': {
                    'tranx_id': requestDetails["tranx_id"],
                    'amount': requestDetails["amount"],
                    'currency': requestDetails["currency"],
                    'country': requestDetails["country"],
                },
            });
        }
    });

    // allows merchants to query and verify payments
    app.post('/v1/transfer/verify', async (req, res) => {
        const requestDetails = req.body;
        const apiKey = requestDetails["auth"]["api_key"];
        const transactionID = requestDetails["tranx_id"];
        const accountID = requestDetails["auth"]["account_id"];
        const merchantDoc = await db.collection("Merchants").where("AccountID", "==", accountID).get();
        const numOfAccs = merchantDoc.docs.length;

        /*
        body preview:
            {
                'auth': {
                    'account_id': 'string',
                    'api_key': 'string',
                },
                'tranx_id': 'string',
            }
        */

        const returnTransaction = async () => {
            const merchantTransactions = await db.collection("Merchants").doc(accountID).collection("Transactions").where("TransactionID", "==", transactionID).get();

            // if transaction doesnt exist
            if (merchantTransactions.docs.length === 0) {
                res.status(200).send({
                    'status': 'failed',
                    'code': '400',
                    'message': 'Transfer not found. Try to use another tranx_id',
                    'data': {
                        'tranx_id': '',
                        'amount': null,
                        'currency': '',
                        'country': '',
                        'status': '',
                        'customer': {
                            'customer_name': '',
                            'customer_username': '',
                            'customer_phone_number': '',
                        },
                        'merchant': {
                            'merchant_code': '',
                        },
                    },
                });
            } else {
                // send success response
                res.status(200).send({
                    'status': 'success',
                    'code': '200',
                    'message': 'Query successful',
                    'data': {
                        'tranx_id': merchantTransactions.docs[0].get("TransactionID"),
                        'amount': merchantTransactions.docs[0].get("Amount"),
                        'currency': merchantTransactions.docs[0].get("Currency"),
                        'country': merchantTransactions.docs[0].get("Country"),
                        'status': merchantTransactions.docs[0].get("Status"),
                        'customer': {
                            'customer_name': merchantTransactions.docs[0].get("Customer")['FullNames'],
                            'customer_username': merchantTransactions.docs[0].get("Customer")['Username'],
                            'customer_phone_number': merchantTransactions.docs[0].get("Customer")['PhoneNumber'],
                        },
                        'merchant': {
                            'merchant_code': merchantTransactions.docs[0].get("MerchantCode"),
                        },
                    },
                });
            }
        };

        // checks if Account ID and API Key are valid, if account is active, and if balance
        const runPreTransferVerifyChecks = async () => {
            if (numOfAccs === 0) {
                merchantAccountNotFound(res, requestDetails);
            } else {
                const active = merchantDoc.docs[0].get("Active");
                const liveAK = merchantDoc.docs[0].get("LiveApiKey");
                const testAK = merchantDoc.docs[0].get("TestApiKey");
                const accMode = merchantDoc.docs[0].get("AccountMode");

                if (active === false) {
                    merchantAccountNotActive(res);
                } else {
                    if (accMode === "Test" && testAK != apiKey) {
                        testAPIKeyInvalid(res);
                    } else {
                        if (accMode === "Test" && testAK === apiKey) {
                            // adds a test transaction and sends a success res to user
                            await runProcessTestModeQueryCall(res, accountID, transactionID);
                        } else {
                            if (accMode === "Live" && liveAK != apiKey) {
                                liveAPIKeyInvalid(res);
                            } else {
                                // return the transaction details to the apiUser
                                await returnTransaction();
                            }
                        }
                    }
                }
            }
        };

        try {
            await runPreTransferVerifyChecks();
        } catch (e) {
            console.log(e);

            const supportDoc = await db.collection("Admin").doc("Legal").collection("APIs").doc("PaymentAPI").get();

            res.status(400).send({
                'status': 'failed',
                'code': '400',
                'message': `An internal error occurred on our end. Please contact support ${supportDoc.get("TechSupportLine")} via call, text, or whatsapp to report issue.`,
                'data': {
                    'tranx_id': '',
                    'amount': null,
                    'currency': '',
                    'country': '',
                    'status': '',
                    'customer': {
                        'customer_name': '',
                        'customer_username': '',
                        'customer_phone_number': '',
                    },
                    'merchant': {
                        'merchant_code': '',
                    },
                },
            });
        }

        // ================================== sub functions

        function liveAPIKeyInvalid(res) {
            res.status(400).send({
                'status': 'failed',
                'code': '400',
                'message': 'Invalid API Key',
                'data': {
                    'tranx_id': '',
                    'amount': null,
                    'currency': '',
                    'country': '',
                    'status': '',
                    'customer': {
                        'customer_name': '',
                        'customer_username': '',
                        'customer_phone_number': '',
                    },
                    'merchant': {
                        'merchant_code': '',
                    },
                },
            });
        }

        function testAPIKeyInvalid(res) {
            // if is in test mode and test api key is invalid
            res.status(400).send({
                'status': 'failed',
                'code': '400',
                'message': 'Test Mode API Key is invalid',
                'data': {
                    'tranx_id': '',
                    'amount': null,
                    'currency': '',
                    'country': '',
                    'status': '',
                    'customer': {
                        'customer_name': '',
                        'customer_username': '',
                        'customer_phone_number': '',
                    },
                    'merchant': {
                        'merchant_code': '',
                    },
                },
            });
        }

        async function runProcessTestModeQueryCall(res, accountID, transactionID) {
            const merchantTransactions = await db.collection("Merchants").doc(accountID).collection("Test Mode Transactions").where("TransactionID", "==", transactionID).get();

            // if transaction doesnt exist
            if (merchantTransactions.docs.length === 0) {
                res.status(400).send({
                    'status': 'failed',
                    'code': '400',
                    'message': 'Transaction not found. Try to use another tranx_id',
                    'data': {
                        'tranx_id': '',
                        'amount': null,
                        'currency': '',
                        'country': '',
                        'status': '',
                        'customer': {
                            'customer_name': '',
                            'customer_username': '',
                            'customer_phone_number': '',
                        },
                        'merchant': {
                            'merchant_code': '',
                        },
                    },
                });
            } else {
                res.status(200).send({
                    'status': 'success',
                    'code': '200',
                    'message': 'Test mode query successful',
                    'data': {
                        'tranx_id': merchantTransactions.docs[0].get("TransactionID"),
                        'amount': merchantTransactions.docs[0].get("Amount"),
                        'currency': merchantTransactions.docs[0].get("Currency"),
                        'country': merchantTransactions.docs[0].get("Country"),
                        'status': merchantTransactions.docs[0].get("Status"),
                        'customer': {
                            'customer_name': merchantTransactions.docs[0].get("Customer")['FullNames'],
                            'customer_username': merchantTransactions.docs[0].get("Customer")['Username'],
                            'customer_phone_number': merchantTransactions.docs[0].get("Customer")['PhoneNumber'],
                        },
                        'merchant': {
                            'merchant_code': merchantTransactions.docs[0].get("MerchantCode"),
                        },
                    },
                });
            }
        }

        function merchantAccountNotActive(res) {
            // if account is not active, send error
            res.status(400).send({
                'status': 'failed',
                'code': '400',
                'message': 'Account not active, please contact support',
                'data': {
                    'tranx_id': '',
                    'amount': null,
                    'currency': '',
                    'country': '',
                    'status': '',
                    'customer': {
                        'customer_name': '',
                        'customer_username': '',
                        'customer_phone_number': '',
                    },
                    'merchant': {
                        'merchant_code': '',
                    },
                },
            });
        }

        function merchantAccountNotFound(res) {
            // if the Account ID is non existent, send error
            res.status(400).send({
                'status': 'failed',
                'code': '400',
                'message': 'Invalid Account ID',
                'data': {
                    'tranx_id': '',
                    'amount': null,
                    'currency': '',
                    'country': '',
                    'status': '',
                    'customer': {
                        'customer_name': '',
                        'customer_username': '',
                        'customer_phone_number': '',
                    },
                    'merchant': {
                        'merchant_code': '',
                    },
                },
            });
        }
    });

    // allows merchants to query client details for confirmation
    app.post('/v1/query/customer', async (req, res) => {
        const requestDetails = req.body;
        const apiKey = requestDetails["auth"]["api_key"];
        const accountID = requestDetails["auth"]["account_id"];
        const customerUsername = requestDetails["customer_username"];
        const merchantDoc = await db.collection("Merchants").where("AccountID", "==", accountID).get();
        const customerDoc = await db.collection("Users").where("Username_searchable", "==", customerUsername.toString().toLowerCase()).get();
        const numOfAccs = merchantDoc.docs.length;
        // number of merchant docs with that account ID

        /*
        body preview:
            {
                'auth': {
                    'account_id': 'string',
                    'api_key': 'string',
                },
                'customer_username': 'string',
            }
        */

        const returnMerchantDetails = async () => {
            // if transaction doesnt exist
            if (customerDoc.docs.length === 0) {
                res.status(200).send({
                    'status': 'failed',
                    'code': '400',
                    'message': 'Customer account not found. Try to use another customer_username',
                    'data': {
                        'name': '',
                        'username': '',
                    },
                });
            } else {
                // send success response
                res.status(200).send({
                    'status': 'success',
                    'code': '200',
                    'message': 'Query successful',
                    'data': {
                        'name': `${customerDoc.docs[0].get("FirstName")} ${customerDoc.docs[0].get("LastName")}`,
                        'username': customerDoc.docs[0].get("Username"),
                    },
                });
            }
        };

        // checks if Account ID and API Key are valid, if account is active, and if balance
        const runPreQueryMerchantChecks = async () => {
            if (numOfAccs === 0) {
                merchantAccountNotFound(res, requestDetails);
            } else {
                const active = merchantDoc.docs[0].get("Active");
                const liveAK = merchantDoc.docs[0].get("LiveApiKey");
                const testAK = merchantDoc.docs[0].get("TestApiKey");
                const accMode = merchantDoc.docs[0].get("AccountMode");

                if (active === false) {
                    merchantAccountNotActive(res);
                } else {
                    if (accMode === "Test" && testAK != apiKey) {
                        testAPIKeyInvalid(res);
                    } else {
                        if (accMode === "Test" && testAK === apiKey) {
                            // adds a test transaction and sends a success res to user
                            // checks if the customer_username is valid
                            await runProcessTestModeQueryCall(res, customerUsername);
                        } else {
                            if (accMode === "Live" && liveAK != apiKey) {
                                liveAPIKeyInvalid(res);
                            } else {
                                // return the merchant details to the apiUser
                                await returnMerchantDetails();
                            }
                        }
                    }
                }
            }
        };

        try {
            if (customerDoc.docs.length != 0) {
                await runPreQueryMerchantChecks();
            } else {
                customerAccNotFound(res, requestDetails);
            }
        } catch (e) {
            console.log(e);

            const supportDoc = await db.collection("Admin").doc("Legal").collection("APIs").doc("PaymentAPI").get();

            res.status(400).send({
                'status': 'failed',
                'code': '400',
                'message': `An internal error occurred on our end. Please contact support ${supportDoc.get("TechSupportLine")} via call, text, or whatsapp to report issue.`,
                'data': {
                    'name': '',
                    'username': '',
                },
            });
        }

        // ================================== sub functions

        function liveAPIKeyInvalid(res) {
            res.status(400).send({
                'status': 'failed',
                'code': '400',
                'message': 'Invalid API Key',
                'data': {
                    'name': '',
                    'username': '',
                },
            });
        }

        function testAPIKeyInvalid(res) {
            // if is in test mode and test api key is invalid
            res.status(400).send({
                'status': 'failed',
                'code': '400',
                'message': 'Test Mode API Key is invalid',
                'data': {
                    'name': '',
                    'username': '',
                },
            });
        }

        async function runProcessTestModeQueryCall(res, customerUsername) {
            const customerDoc = await db.collection("Users").where("Username_searchable", "==", customerUsername).get();

            // if transaction doesnt exist
            if (customerDoc.docs.length === 0) {
                res.status(400).send({
                    'status': 'failed',
                    'code': '400',
                    'message': 'Customer account not found. Try to use another customer_username',
                    'data': {
                        'name': '',
                        'username': '',
                    },
                });
            } else {
                res.status(200).send({
                    'status': 'success',
                    'code': '200',
                    'message': 'Test mode query successful',
                    'data': {
                        'name': `${customerDoc.docs[0].get('FirstName')} ${customerDoc.docs[0].get('LastName')}`,
                        'username': customerDoc.docs[0].get('Username'),
                    },
                });
            }
        }

        async function merchantAccountNotActive(res) {
            const customerDoc = await db.collection("Merchants").where("AccountID", "==", accountID).get();

            // if account is not active, send error
            res.status(400).send({
                'status': 'failed',
                'code': '400',
                'message': `Your account is not active, please contact support ${customerDoc.get("TechSupportLine")} via call, text or whatsapp`,
                'data': {
                    'name': '',
                    'username': '',
                },
            });
        }

        function customerAccNotFound(res, requestDetails) {
            // if customer account is not found, send error
            res.status(400).send({
                'status': 'failed',
                'code': '400',
                'message': 'Customer account not found. Try using a different customer_username',
                'data': {
                    'name': '',
                    'username': '',
                },
            });
        }

        function merchantAccountNotFound(res) {
            // if the Account ID is non existent, send error
            res.status(400).send({
                'status': 'failed',
                'code': '400',
                'message': 'Invalid Account ID',
                'data': {
                    'name': '',
                    'username': '',
                },
            });
        }
    });

    // allows merchants to initiate payments in client's app
    app.post('/v1/payment/initiate', async (req, res) => {
        const requestDetails = req.body;
        const apiKey = requestDetails["auth"]["api_key"];
        const accountID = requestDetails["auth"]["account_id"];
        const customerUsername = requestDetails["customer"]["customer_username"];
        const merchantDoc = await db.collection("Merchants").where("AccountID", "==", accountID).get();
        const customerDoc = await db.collection("Users").where("Username_searchable", "==", customerUsername.toString().toLowerCase()).get();
        const numOfAccs = merchantDoc.docs.length;
        // number of merchant docs with that account ID

        /*
        body preview:
        {
            'amount': 20,
            'country': 'ZM',
            'currency': 'ZMW',
            'reference': 'CR2456205',
            'auth': {
                'account_id': 'string',
                'api_key': 'string',
            },
            'customer': {
                'customer_username': 'Just0',
            },
            'merchant': {
                'merchant_code': 'uwed15',
            },
        },
        */

        const initiate = async () => {
            // if transaction doesnt exist
            if (customerDoc.docs.length === 0) {
                res.status(200).send({
                    'status': 'failed',
                    'code': '400',
                    'message': 'Customer account not found. Try to use another customer_username',
                    'data': {
                        'name': '',
                        'amount': '',
                        'username': '',
                    },
                });
            } else {
                const paymentID = uuid.v4();

                // 1). Records the transactions on the merchant's side
                // 2). Records the transactions on the customer's side
                // 3). Sends payment request notification to the client app
                await Promise.all([
                    db.collection("Initiated Payments").doc(paymentID).set({
                        Comment: "",
                        Type: "Payment",
                        AttendedTo: false,
                        Status: "Pending",
                        SentReceived: "Sent",
                        TransactionID: paymentID,
                        TransactionType: "Payment",
                        Amount: requestDetails['amount'],
                        Country: requestDetails["country"],
                        Currency: requestDetails["currency"],
                        Reference: requestDetails['reference'],
                        Method: "Payment Request from Merchant",
                        UserID: customerDoc.docs[0].get("UserID"),
                        DateCreated: admin.firestore.FieldValue.serverTimestamp(),
                        PhoneNumber: `To ${merchantDoc.docs[0].get("CompanyName")}`,
                        Merchant: {
                            MerchantUID: merchantDoc.docs[0].get("AccountID"),
                            MerchantName: merchantDoc.docs[0].get("CompanyName"),
                            MerchantCode: merchantDoc.docs[0].get("MerchantCode"),
                            MerchantLogoUrl: merchantDoc.docs[0].get("MerchantCode"),
                        },
                        FullNames: `${customerDoc.docs[0].get("FirstName")} ${customerDoc.docs[0].get("LastName")}`,
                    }),
                    db.collection("Merchants").doc(accountID).collection("Transactions").doc(paymentID).set({
                        Comment: "",
                        Type: "Payment",
                        AttendedTo: false,
                        Status: "Pending",
                        SentReceived: "Received",
                        TransactionID: paymentID,
                        Method: "Initiate Payment",
                        TransactionType: "Payment",
                        Amount: requestDetails['amount'],
                        Country: requestDetails["country"],
                        Currency: requestDetails["currency"],
                        Reference: requestDetails['reference'],
                        AccountID: merchantDoc.docs[0].get("AccountID"),
                        MerchantCode: requestDetails["merchant"]["merchant_code"],
                        DateCreated: admin.firestore.FieldValue.serverTimestamp(),
                        Customer: {
                            Email: customerDoc.docs[0].get("Email"),
                            UserID: customerDoc.docs[0].get("UserID"),
                            Username: customerDoc.docs[0].get("Username"),
                            PhoneNumber: customerDoc.docs[0].get("PhoneNumber"),
                            FullNames: `${customerDoc.docs[0].get("FirstName")} ${customerDoc.docs[0].get("LastName")}`,
                        },
                    }),
                    db.collection("Initiated Payments").doc(paymentID).collection("Send Payment Notification").add({
                        Amount: requestDetails['amount'],
                        Currency: requestDetails['currency'],
                        MerchantName: merchantDoc.docs[0].get("CompanyName"),
                        NotificationToken: customerDoc.docs[0].get("NotificationToken"),
                    }),
                ]);

                // send success response
                res.status(200).send({
                    'status': 'success',
                    'code': '200',
                    'message': 'Payment initiation successful',
                    'data': {
                        'name': `${customerDoc.docs[0].get("FirstName")} ${customerDoc.docs[0].get("LastName")}`,
                        'amount': requestDetails['amount'],
                        'username': customerDoc.docs[0].get("Username"),
                    },
                });
            }
        };

        // checks if Account ID and API Key are valid, if account is active, and if balance
        const runPreInitiatePaymentChecks = async () => {
            if (numOfAccs === 0) {
                merchantAccountNotFound(res, requestDetails);
            } else {
                const active = merchantDoc.docs[0].get("Active");
                const liveAK = merchantDoc.docs[0].get("LiveApiKey");
                const testAK = merchantDoc.docs[0].get("TestApiKey");
                const accMode = merchantDoc.docs[0].get("AccountMode");

                if (active === false) {
                    merchantAccountNotActive(res);
                } else {
                    if (accMode === "Test" && testAK != apiKey) {
                        testAPIKeyInvalid(res);
                    } else {
                        if (accMode === "Test" && testAK === apiKey) {
                            // returns a test mode response resembling
                            // one for an actual initiate payment response
                            await runTestModeInitiatePaymentCall(res, customerUsername);
                        } else {
                            if (accMode === "Live" && liveAK != apiKey) {
                                liveAPIKeyInvalid(res);
                            } else {
                                // initiate the payment
                                await initiate();
                            }
                        }
                    }
                }
            }
        };

        try {
            if (customerDoc.docs.length != 0) {
                await runPreInitiatePaymentChecks();
            } else {
                customerAccNotFound(res, requestDetails);
            }
        } catch (e) {
            console.log(e);

            const supportDoc = await db.collection("Admin").doc("Legal").collection("APIs").doc("PaymentAPI").get();

            res.status(400).send({
                'status': 'failed',
                'code': '400',
                'message': `An internal error occurred on our end. Please contact support ${supportDoc.get("TechSupportLine")} via call, text, or whatsapp to report issue.`,
                'data': {
                    'name': '',
                    'amount': '',
                    'username': '',
                },
            });
        }

        // ================================== sub functions

        function liveAPIKeyInvalid(res) {
            res.status(400).send({
                'status': 'failed',
                'code': '400',
                'message': 'Invalid API Key',
                'data': {
                    'name': '',
                    'amount': '',
                    'username': '',
                },
            });
        }

        function testAPIKeyInvalid(res) {
            // if is in test mode and test api key is invalid
            res.status(400).send({
                'status': 'failed',
                'code': '400',
                'message': 'Test Mode API Key is invalid',
                'data': {
                    'name': '',
                    'amount': '',
                    'username': '',
                },
            });
        }

        async function runTestModeInitiatePaymentCall(res, customerUsername) {
            const customerDoc = await db.collection("Users").where("Username_searchable", "==", customerUsername).get();

            // if transaction doesnt exist
            if (customerDoc.docs.length === 0) {
                res.status(400).send({
                    'status': 'failed',
                    'code': '400',
                    'message': 'Customer account not found. Try to use another customer_username',
                    'data': {
                        'name': '',
                        'amount': '',
                        'username': '',
                    },
                });
            } else {
                res.status(200).send({
                    'status': 'success',
                    'code': '200',
                    'message': 'Test mode initiate payment successful',
                    'data': {
                        'name': `${customerDoc.docs[0].get('FirstName')} ${customerDoc.docs[0].get('LastName')}`,
                        'amount': requestDetails['amount'],
                        'username': customerDoc.docs[0].get('Username'),
                    },
                });
            }
        }

        function customerAccNotFound(res, requestDetails) {
            // if customer account is not found, send error
            res.status(400).send({
                'status': 'failed',
                'code': '400',
                'message': 'Customer account not found. Try using a different customer_username',
                'data': {
                    'name': '',
                    'amount': '',
                    'username': '',
                },
            });
        }

        async function merchantAccountNotActive(res) {
            const customerDoc = await db.collection("Merchants").where("AccountID", "==", accountID).get();

            // if account is not active, send error
            res.status(400).send({
                'status': 'failed',
                'code': '400',
                'message': `Your account is not active, please contact support ${customerDoc.get("TechSupportLine")} via call, text or whatsapp`,
                'data': {
                    'name': '',
                    'amount': '',
                    'username': '',
                },
            });
        }

        function merchantAccountNotFound(res) {
            // if the Account ID is non existent, send error
            res.status(400).send({
                'status': 'failed',
                'code': '400',
                'message': 'Invalid Account ID',
                'data': {
                    'name': '',
                    'amount': '',
                    'username': '',
                },
            });
        }
    });

    e.api = functions.https.onRequest(app);
};

