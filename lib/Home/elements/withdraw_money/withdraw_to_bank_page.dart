import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../Utilities/general_widgets.dart';
import 'package:jayben/Utilities/provider_functions.dart';
import 'package:jayben/Home/elements/withdraw_money/withdraw_money_confirmation_page.dart';

class WithdrawalBankPage extends StatefulWidget {
  const WithdrawalBankPage({
    Key? key,
    required this.paymentInfo,
  }) : super(key: key);

  final Map paymentInfo;

  @override
  _WithdrawalBankPageState createState() => _WithdrawalBankPageState();
}

class _WithdrawalBankPageState extends State<WithdrawalBankPage> {
  final accountNumberController = TextEditingController();
  String bank = "";

  @override
  Widget build(BuildContext context) {
    return Consumer<WithdrawProviderFunctions>(
      builder: (_, value, child) {
        return Scaffold(
            resizeToAvoidBottomInset: true,
            floatingActionButton: FloatingActionButton.extended(
                backgroundColor: Colors.green,
                onPressed: () async {
                  if (accountNumberController.text.isEmpty || bank.isEmpty) {
                    showSnackBar(context,
                        "Enter an account number & select a bank name");

                    return;
                  }

                  changePage(
                      context,
                      WithdrawMoneyConfirmationPage(paymentInfo: {
                        'bankAccountNumber':
                            accountNumberController.text.trim(),
                        ...widget.paymentInfo,
                        'bankName': bank,
                      }),
                      type: "pr");
                },
                label: const Text("Next")),
            backgroundColor: Colors.white,
            body: Stack(
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
                          child: Text.rich(
                            TextSpan(
                              children: [
                                TextSpan(
                                  text: 'Enter an Account number',
                                  style: GoogleFonts.ubuntu(
                                      color: Colors.grey[700],
                                      fontWeight: FontWeight.bold,
                                      fontSize: 26),
                                ),
                                TextSpan(
                                  text: '\nto withdraw to',
                                  style: GoogleFonts.ubuntu(
                                      color: Colors.green[400],
                                      fontSize: 26,
                                      fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                            textAlign: TextAlign.left,
                          )),
                      const SizedBox(height: 40),
                      Padding(
                        padding: const EdgeInsets.only(left: 20, right: 100),
                        child: TextField(
                          cursorHeight: 24,
                          cursorColor: Colors.grey[700],
                          maxLines: 1,
                          controller: accountNumberController,
                          keyboardType: TextInputType.text,
                          inputFormatters: [
                            LengthLimitingTextInputFormatter(100),
                          ],
                          textAlign: TextAlign.left,
                          style: GoogleFonts.ubuntu(
                            fontSize: 24,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w300,
                          ),
                          decoration: InputDecoration(
                            hintText: 'Account Number',
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
                              fontSize: 24,
                              color: Colors.grey[700],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      const SizedBox(height: 40),
                      Container(
                          padding: const EdgeInsets.only(left: 20),
                          child: Text.rich(
                            TextSpan(
                              children: [
                                TextSpan(
                                  text: 'Choose a bank',
                                  style: GoogleFonts.ubuntu(
                                      color: Colors.green[400],
                                      fontWeight: FontWeight.bold,
                                      fontSize: 26),
                                ),
                              ],
                            ),
                            textAlign: TextAlign.left,
                          )),
                      const SizedBox(height: 20),
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          Container(
                              alignment: Alignment.centerLeft,
                              width: width(context),
                              height: height(context) * 0.05,
                              margin:
                                  const EdgeInsets.only(left: 20, right: 100),
                              padding: const EdgeInsets.only(right: 25),
                              decoration: BoxDecoration(
                                  border: Border(
                                bottom: BorderSide(
                                  color: Colors.grey[600]!,
                                  width: 1.3,
                                ),
                              )),
                              child: Text(
                                bank == "" ? 'Bank' : bank,
                                textAlign: TextAlign.left,
                                style: GoogleFonts.ubuntu(
                                    color: Colors.grey[700],
                                    fontWeight: FontWeight.w300,
                                    fontSize: 24),
                              )), //height
                          Positioned(
                            right: 100,
                            child: DropdownButton<String>(
                              underline: const SizedBox(),
                              items: <String>[
                                'Absa Bank',
                                'Access Bank',
                                "Atlas Mara",
                                "Citi Bank",
                                "EcoBank",
                                'FCB',
                                'FNB Zambia',
                                "Indo Bank",
                                "Investrust",
                                'Stanbic Bank',
                                'UBA Bank',
                                "ZICB",
                                "Zanaco",
                              ].map((String value) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(value,
                                      style: const TextStyle(fontSize: 24)),
                                );
                              }).toList(),
                              onChanged: (value) {
                                setState(() {
                                  bank = value!;
                                });
                              },
                            ),
                          )
                        ],
                      )
                    ],
                  ),
                ),
                backButton(context)
              ],
            ));
      },
    );
  }
}
