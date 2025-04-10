// import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hive/hive.dart';
import 'package:flutter/material.dart';
import 'package:jayben/Utilities/provider_functions.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:jayben/Utilities/general_widgets.dart';
import '../send_money_to_merchant_confirmation_page.dart';
import 'package:jayben/Utilities/provider_functions.dart';

// FirebaseFirestore _fire = FirebaseFirestore.instance;

// checks validity of the merchant code
// returns a boolean and a document snapshot
Future<List<dynamic>> checkMerchantCodeValidity(String merchantCode) async {
  // if the identifier is a username
  // var qs = await _fire
  //     .collection("Merchants")
  //     .where('MerchantCode', isEqualTo: merchantCode)
  //     .get();

  // return qs.docs.isEmpty ? [false, null] : [true, qs.docs[0]];

  return [];
}

Widget sendMoneyFloatingButton(
    BuildContext context,
    double amountInDollars,
    TextEditingController amountToSendController,
    TextEditingController merchantCodeController) {
  String currency = Hive.box("userInfo").get("Currency");

  return Consumer<PaymentProviderFunctions>(builder: (_, value, child) {
    return FloatingActionButton.extended(
      onPressed: () async {
        if (amountToSendController.text.isEmpty ||
            merchantCodeController.text.isEmpty) {
          showSnackBar(context, 'Fill in all fields');

          return;
        }

        double transactionFeePercentMerchants =
            box("transaction_fee_percentage_to_merchants");

        double amount = double.parse(
            amountToSendController.text.trim().replaceAll("-", ""));

        double transactionFee = amount * (transactionFeePercentMerchants / 100);

        double amountPlusFee = amount + transactionFee;

        value.toggleIsLoading();

        // gets the user's current balance
        double walletBal = await getUserBalance();

        value.toggleIsLoading();

        if (amountPlusFee > walletBal) {
          showSnackBar(
              context,
              "Your wallet balance isn't anough. Please account for the "
              "$currency ${transactionFee.toStringAsFixed(2)} transaction fee");

          return;
        }

        value.toggleIsLoading();

        // checks if the merchant code is valid
        // returns a boolean value and a document snapshot
        // List<dynamic> validityResult = await value.checkMerchantCodeValidity(
        //     merchantCodeController.text.toLowerCase().replaceAll("-", ""));
        // element 0 is the bool
        // element 1 is the document snapshot

        value.toggleIsLoading();

        // if merchant code is invalid
        // if (!validityResult[0]) {
        //   showSnackBar(context, 'Invalid Username or Phone Number');

        //   return;
        // }

        // routes user to the payment confirmation page
        // changePage(
        //   context,
        //   SendMoneyToMerchantConfirmationPage(
        //     paymentInfo: {
        //       "amount": amount,
        //       "merchantUID": validityResult[1].get("MerchantUID"),
        //       "merchantName": validityResult[1].get("MerchantName"),
        //       "merchantCode": validityResult[1].get("MerchantCode"),
        //       "merchantLogoUrl": validityResult[1].get("ProfileLogoUrl"),
        //     },
        //   ),
        // );
      },
      backgroundColor: Colors.green,
      label: Row(
        children: [
          Image.asset('assets/send.png',
              height: 20, width: 20, color: Colors.white),
          const SizedBox(width: 10),
          const Text("Send Money"),
        ],
      ),
    );
  });
}

Widget sendMoneyToMerchantBody(
    BuildContext context,
    double amountInDollars,
    TextEditingController amountController,
    TextEditingController merchantCodeController,
    void Function(String)? onChanged) {
  return Stack(
    children: [
      SingleChildScrollView(
        padding: const EdgeInsets.only(top: 30, bottom: 50),
        physics: const ClampingScrollPhysics(),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              alignment: Alignment.center,
              color: Colors.white,
              height: height(context),
              width: width(context),
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.only(left: 20),
                      child: Text.rich(
                        TextSpan(
                          children: [
                            TextSpan(
                              text: 'Enter a',
                              style: GoogleFonts.ubuntu(
                                  color: Colors.grey[600],
                                  // fontWeight: FontWeight.bold,
                                  fontSize: 26),
                            ),
                            TextSpan(
                              text: '\nmerchant code',
                              style: GoogleFonts.ubuntu(
                                  color: Colors.green,
                                  fontSize: 26,
                                  fontWeight: FontWeight.bold),
                            )
                          ],
                        ),
                        textAlign: TextAlign.left,
                      ),
                    ),
                    const SizedBox(height: 30),
                    Padding(
                      padding: const EdgeInsets.only(left: 20, right: 100),
                      child: TextField(
                        cursorHeight: 24,
                        cursorColor: Colors.grey[700],
                        maxLines: 1,
                        textCapitalization: TextCapitalization.words,
                        controller: merchantCodeController,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          LengthLimitingTextInputFormatter(7),
                          FilteringTextInputFormatter.deny(RegExp(r"\s\b|\b\s"))
                        ],
                        textAlign: TextAlign.left,
                        style: GoogleFonts.ubuntu(
                          fontSize: 24,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w300,
                        ),
                        decoration: InputDecoration(
                          floatingLabelBehavior: FloatingLabelBehavior.always,
                          labelText: "Merchant Code",
                          labelStyle: const TextStyle(
                              color: Colors.black87,
                              fontSize: 18,
                              fontFamily: 'AvenirLight'),
                          hintText: 'Example: 888 1234',
                          isDense: true,
                          border: UnderlineInputBorder(
                            borderSide: BorderSide(
                              color: Colors.grey[800]!,
                            ),
                          ),
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(
                              color: Colors.grey[800]!,
                            ),
                          ),
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(
                              color: Colors.grey[800]!,
                            ),
                          ),
                          disabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(
                              color: Colors.grey[800]!,
                            ),
                          ),
                          hintStyle: GoogleFonts.ubuntu(
                            fontSize: 18,
                            color: Colors.grey[400],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.only(left: 20),
                      child: Text(
                        '*Must be 7 digits long',
                        style: GoogleFonts.ubuntu(
                          color: Colors.grey[500],
                          fontSize: 15,
                        ),
                      ),
                    ),
                    const SizedBox(height: 50),
                    Container(
                      padding: const EdgeInsets.only(left: 20),
                      child: Text.rich(
                        TextSpan(
                          children: [
                            TextSpan(
                              text: 'Enter amount',
                              style: GoogleFonts.ubuntu(
                                  color: Colors.grey[600],
                                  // fontWeight: FontWeight.bold,
                                  fontSize: 26),
                            ),
                            TextSpan(
                              text: '\nto Send',
                              style: GoogleFonts.ubuntu(
                                fontWeight: FontWeight.bold,
                                color: Colors.green,
                                fontSize: 26,
                              ),
                            )
                          ],
                        ),
                        textAlign: TextAlign.left,
                      ),
                    ),
                    const SizedBox(height: 30),
                    amountTextField(
                        context, amountController, amountInDollars, onChanged),
                    const SizedBox(height: 10),
                    Padding(
                      padding: const EdgeInsets.only(left: 20, right: 100),
                      child: Text(
                        amountInDollars == 0
                            ? "Conversion to US Dollars: (0 USD)"
                            : "Conversion to US Dollars: (${amountInDollars.toStringAsFixed(2)} USD)",
                        textAlign: TextAlign.center,
                        style: GoogleFonts.ubuntu(
                          color: Colors.grey[500],
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ]),
            ),
          ],
        ),
      ),
      backButton(context)
    ],
  );
}

Widget amountTextField(BuildContext context, TextEditingController controller,
    double amountInDollars, void Function(String)? onChanged) {
  return Padding(
    padding: const EdgeInsets.only(left: 20, right: 100),
    child: TextField(
      cursorHeight: 24,
      cursorColor: Colors.grey[700],
      maxLines: 1,
      controller: controller,
      onChanged: onChanged,
      keyboardType: TextInputType.number,
      inputFormatters: [
        LengthLimitingTextInputFormatter(100),
        FilteringTextInputFormatter.deny(RegExp(r"\s\b|\b\s"))
      ],
      textAlign: TextAlign.left,
      style: GoogleFonts.ubuntu(
        fontSize: 24,
        color: Colors.grey[600],
        fontWeight: FontWeight.w300,
      ),
      decoration: InputDecoration(
        floatingLabelBehavior: FloatingLabelBehavior.always,
        labelText: Hive.box("userInfo").get('Currency').toLowerCase(),
        labelStyle: const TextStyle(
            color: Colors.black87, fontSize: 20, fontFamily: 'AvenirLight'),
        hintText: 'Amount',
        isDense: true,
        border: UnderlineInputBorder(
          borderSide: BorderSide(
            color: Colors.grey[800]!,
          ),
        ),
        enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(
            color: Colors.grey[800]!,
          ),
        ),
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(
            color: Colors.grey[800]!,
          ),
        ),
        disabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(
            color: Colors.grey[800]!,
          ),
        ),
        hintStyle: GoogleFonts.ubuntu(
          fontSize: 18,
          color: Colors.grey[600],
        ),
      ),
    ),
  );
}
