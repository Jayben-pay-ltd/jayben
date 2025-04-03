// ignore_for_file: prefer_final_fields

import 'dart:convert';

// import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'package:jayben/Home/elements/send_money/elements/send_money_to_merchant_receipt_page.dart';
import 'components/send_money_to_merchant_confirmation_page_widgets.dart';
import 'package:jayben/Utilities/provider_functions.dart';
import '../../../../Utilities/general_widgets.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive/hive.dart';

class SendMoneyToMerchantConfirmationPage extends StatefulWidget {
  const SendMoneyToMerchantConfirmationPage(
      {Key? key, required this.paymentInfo})
      : super(key: key);

  final Map<String, dynamic> paymentInfo;

  @override
  _SendMoneyToMerchantConfirmationPageState createState() =>
      _SendMoneyToMerchantConfirmationPageState();
}

class _SendMoneyToMerchantConfirmationPageState
    extends State<SendMoneyToMerchantConfirmationPage> {
  @override
  void initState() {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
        statusBarBrightness: Brightness.dark,
        statusBarIconBrightness: Brightness.dark,
        systemNavigationBarColor: Colors.black,
        systemNavigationBarIconBrightness: Brightness.light,
        statusBarColor: Colors.transparent));
    super.initState();
  }

  final referrenceController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    String currency = Hive.box("userInfo").get("Currency");
    double transactionFeePercentMerchants =
        Hive.box('userInfo').get("TransactionFeePercentToMerchants");
    double transactionFee =
        widget.paymentInfo['amount'] * (transactionFeePercentMerchants / 100);
    return Consumer<PaymentProviderFunctions>(
      builder: (context, value, child) {
        return AnnotatedRegion<SystemUiOverlayStyle>(
          value: SystemUiOverlayStyle.dark,
          child: Scaffold(
            floatingActionButton: FloatingActionButton.extended(
              onPressed: () async {
                if (referrenceController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      duration: const Duration(seconds: 10),
                      content: Text(
                        'Please enter a reference. It could be an account ID, invoice number, order number or a note to the merchant.',
                        style: GoogleFonts.ubuntu(
                            fontSize: 13, color: Colors.white),
                        textAlign: TextAlign.center,
                      ),
                      behavior: SnackBarBehavior.floating,
                      backgroundColor: Colors.grey[700]));

                  return;
                }

                Map<String, dynamic> newPaymentInfo = {
                  "transactionFeeInKwacha": transactionFee,
                  "transactionFeePercent": transactionFeePercentMerchants,
                  "amountPlusFee": widget.paymentInfo['amount'] + transactionFee
                };

                newPaymentInfo.addAll(widget.paymentInfo);

                changePage(
                    context,
                    SendMoneyToMerchantReceiptPage(
                      paymentInfo: newPaymentInfo,
                    ),
                    type: "pr");

                // plays cash sounds after sending money
                await playSound('cash.mp3');

                await payMerchant(
                  newPaymentInfo,
                  referrenceController.text,
                );
              },
              backgroundColor: Colors.green,
              label: Row(
                children: [
                  Image.asset('assets/send.png',
                      height: 20, width: 20, color: Colors.white),
                  const SizedBox(width: 10),
                  const Text("Pay now"),
                ],
              ),
            ),
            backgroundColor: Colors.white,
            body: WillPopScope(
              child: Stack(
                children: [
                  SingleChildScrollView(
                    physics: const ClampingScrollPhysics(),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          alignment: Alignment.center,
                          padding: const EdgeInsets.only(top: 30, bottom: 0),
                          color: Colors.white,
                          height: height(context),
                          width: width(context),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: const EdgeInsets.only(left: 20),
                                width: width(context),
                                child: Text.rich(
                                  TextSpan(
                                    children: [
                                      TextSpan(
                                        text:
                                            'Send \n${Hive.box('userInfo').get("Currency")} ${widget.paymentInfo['amount']} to',
                                        style: GoogleFonts.ubuntu(
                                          color: Colors.grey[600],
                                          fontWeight: FontWeight.bold,
                                          fontSize: 30,
                                        ),
                                      ),
                                      TextSpan(
                                        text:
                                            '\n${widget.paymentInfo['merchantName']}?',
                                        style: const TextStyle(
                                          color: Colors.green,
                                          fontSize: 28,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      )
                                    ],
                                  ),
                                  textAlign: TextAlign.start,
                                ),
                              ),
                              const SizedBox(height: 10),
                              Padding(
                                padding: const EdgeInsets.only(left: 20),
                                child: Text.rich(
                                  TextSpan(
                                    style: GoogleFonts.ubuntu(
                                        fontSize: 13, color: Colors.grey[600]),
                                    text:
                                        "+ $currency ${transactionFee.toStringAsFixed(2)} transaction fee",
                                  ),
                                  textAlign: TextAlign.left,
                                ),
                              ),
                              const SizedBox(height: 15),
                              referenceTextField(context, referrenceController),
                              const SizedBox(height: 10),
                              Padding(
                                padding: const EdgeInsets.only(left: 20),
                                child: Text(
                                  "Example: CR2456456",
                                  style: GoogleFonts.ubuntu(
                                    fontWeight: FontWeight.w400,
                                    color: Colors.orange[700],
                                    fontSize: 15,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  backButton(context)
                ],
              ),
              onWillPop: () async {
                Navigator.pop(context);
                return true;
              },
            ),
          ),
        );
      },
    );
  }

  // FirebaseFirestore _fire = FirebaseFirestore.instance;

  // sends money to the merchant
  Future<void> payMerchant(Map paymentInfo, String reference) async {
    String tranxID = id.v4();

    // DocumentSnapshot merchantDoc = await _fire
    //     .collection("Merchants")
    //     .doc(paymentInfo['merchantUID'])
    //     .get();

    // 1). Creates a transaction record for the user
    // 2). Created a transaction record for the merchant
    // 3). Credits the merchants balance
    // 4). Debits the user's balance
    // await Future.wait([
    //   _fire.collection("Transactions").doc(tranxID).set({
    //     "Comment": "",
    //     "AttendedTo": false,
    //     "Status": "Completed",
    //     "Reference": reference,
    //     "SentReceived": 'Sent',
    //     "UserID": box("user_id"),
    //     "TransactionType": "Payment",
    //     "DateCreated": Timestamp.now(),
    //     "Method": "Payment to merchant",
    //     "Amount": paymentInfo['amount'],
    //     "TransactionID": '$tranxID-sender',
    //     "Merchant": {
    //       "MerchantLogoUrl": "",
    //       "MerchantUID": paymentInfo['merchantUID'],
    //       "MerchantName": paymentInfo['merchantName'],
    //       "MerchantCode": paymentInfo['merchantCode'],
    //     },
    //     "AmountPlusFee": paymentInfo['amountPlusFee'],
    //     "Currency": Hive.box('userInfo').get("Currency"),
    //     "PhoneNumber": 'To ${paymentInfo['merchantName']}',
    //     "TransactionFeePercent": paymentInfo['transactionFeePercent'],
    //     "TransactionFeeInKwacha": paymentInfo['transactionFeeInKwacha'],
    //     "FullNames":
    //         "${Hive.box('userInfo').get("FirstName")} ${Hive.box('userInfo').get("LastName")}",
    //   }),
    //   _fire
    //       .collection("Merchants")
    //       .doc(paymentInfo['merchantUID'])
    //       .collection("Transactions")
    //       .doc(tranxID)
    //       .set({
    //     "Comment": "",
    //     "Method": "Wallet",
    //     "AttendedTo": false,
    //     "Status": "Completed",
    //     "Reference": reference,
    //     "TransactionID": tranxID,
    //     "SentReceived": 'Received',
    //     "TransactionType": "Payment",
    //     "DateCreated": Timestamp.now(),
    //     "Amount": paymentInfo['amount'],
    //     "AccountID": paymentInfo['merchantUID'],
    //     "MerchantCode": paymentInfo['merchantCode'],
    //     "Currency": Hive.box('userInfo').get("Currency"),
    //     "Customer": {
    //       "FullNames":
    //           "${Hive.box('userInfo').get("FirstName")} ${Hive.box('userInfo').get("LastName")}",
    //       "PhoneNumber": Hive.box('userInfo').get("PhoneNumber"),
    //       "Username": Hive.box('userInfo').get("Username"),
    //       "Country": Hive.box('userInfo').get("Country"),
    //       "City": Hive.box('userInfo').get("City"),
    //       "UserID": box("user_id"),
    //     },
    //   }),
    //   _fire.collection("Merchants").doc(paymentInfo['merchantUID']).update({
    //     "AmountReceivedTodaySoFar": FieldValue.increment(paymentInfo['amount']),
    //     "TotalAmountReceived": FieldValue.increment(paymentInfo['amount']),
    //     "NumberOfTransactionsThisMonthSoFar": FieldValue.increment(1),
    //     "Balance": FieldValue.increment(paymentInfo['amount']),
    //     "NumberOfTransactionsToday": FieldValue.increment(1),
    //     "BalanceAtLastDeposit": merchantDoc.get("Balance"),
    //     "NumberOfTransactions": FieldValue.increment(1),
    //     "AmountReceivedThisMonthSoFar":
    //         FieldValue.increment(paymentInfo['amount']),
    //   }),
    //   _fire.collection('Users').doc(box("user_id")).update({
    //     "Balance": FieldValue.increment(-paymentInfo['amountPlusFee']),
    //     "NumberOfTransactionsThisMonthSoFar": FieldValue.increment(1),
    //     "NumberOfTransactionsToday": FieldValue.increment(1),
    //     "NumberOfTransactions": FieldValue.increment(1),
    //   })
    // ]);

    // // if merchant doesn't have a webhook attached
    // if (merchantDoc.get("WebhookUrl") == "") return;

    // await callWebhook(
    //     paymentInfo['amount'], paymentInfo['merchantUID'], tranxID, reference);

    // calls the merchant's webhook to notify them a payment has been made
    Future callWebhook(
        double amount, merchantUID, transactionID, reference) async {
      var res = await http.post(
          Uri.parse(
              "https://us-central1-jayben-de41c.cloudfunctions.net/api/v1/internal/admin/merchant/webhook/call"),
          headers: {
            "Content-type": "application/json",
          },
          body: json.encode({
            "transactionID": transactionID,
            "merchantUID": merchantUID,
            "reference": reference,
            "amountToPay": amount,
            "userID": box("user_id"),
          }));

      return res.body == "sucess" ? true : false;
    }
  }
}
