import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:provider/provider.dart";
import "package:jayben/Home/home_page.dart";
import "package:google_fonts/google_fonts.dart";
import "../../../Utilities/General_widgets.dart";
import "../../../Utilities/provider_functions.dart";
import "package:jayben/Home/elements/drawer/elements/kyc_verification.dart";

class WithdrawMoneyConfirmationPage extends StatefulWidget {
  const WithdrawMoneyConfirmationPage({Key? key, required this.paymentInfo})
      : super(key: key);

  final Map paymentInfo;

  @override
  _WithdrawMoneyConfirmationPageState createState() =>
      _WithdrawMoneyConfirmationPageState();
}

class _WithdrawMoneyConfirmationPageState
    extends State<WithdrawMoneyConfirmationPage> {
  @override
  void initState() {
    if (box("lastEnteredReference") != null) {
      setState(() => referenceController.text = box("lastEnteredReference"));
    }
    super.initState();
  }

  final referenceController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Consumer<WithdrawProviderFunctions>(
      builder: (_, value, child) {
        return AnnotatedRegion<SystemUiOverlayStyle>(
          value: SystemUiOverlayStyle.light,
          child: Scaffold(
            floatingActionButton: FloatingActionButton.extended(
              onPressed: () async {
                if (value.returnIsLoading()) return;

                hideKeyboard();

                // if the user's account isn't KYC verified
                if (!box("isVerified")) {
                  showSnackBar(
                    context,
                    "Your account must be KYC Verified first",
                    align: TextAlign.left,
                    action: SnackBarAction(
                      label: "VERIFY",
                      textColor: Colors.green,
                      onPressed: () =>
                          changePage(context, const KycVerificationPage()),
                    ),
                    duration: 10,
                  );

                  return;
                }

                if (referenceController.text.isEmpty) {
                  showSnackBar(
                      context,
                      "Write the name the mobile money account brings."
                      "\n\nima leta zina bwanji?",
                      duration: 10);

                  return;
                }

                // stores the last entered mobile money names / reference
                boxPut("lastEnteredReference", referenceController.text.trim());

                value.toggleIsLoading();

                // submits the withdrawal request
                await value.submitWithdrawal({
                  "reference": referenceController.text,
                  ...widget.paymentInfo
                });

                value.toggleIsLoading();

                showSnackBar(context, "Withdrawal has been Submitted",
                    color: Colors.green);

                changePage(context, const HomePage(), type: "pr");
              },
              backgroundColor: Colors.grey[800],
              label: value.returnIsLoading()
                  ? loadingIcon(context)
                  : Row(
                      children: [
                        Image.asset(
                          'assets/send.png',
                          color: Colors.white,
                          height: 20,
                          width: 20,
                        ),
                        const SizedBox(width: 10),
                        const Text("Withdraw Now"),
                      ],
                    ),
            ),
            backgroundColor: Colors.grey[900],
            body: Stack(
              children: [
                SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      GestureDetector(
                        onTap: () => hideKeyboard(),
                        child: Container(
                          width: width(context),
                          height: height(context),
                          color: Colors.grey[900],
                          alignment: Alignment.center,
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
                                            'Withdraw \n${box("Currency")} ${widget.paymentInfo['amountBeforeFee']} to',
                                        style: GoogleFonts.ubuntu(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                          fontSize: 30,
                                        ),
                                      ),
                                      TextSpan(
                                        text:
                                            '\n${widget.paymentInfo['phoneNumber']}?',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.green,
                                          fontSize: 28,
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
                                      color: Colors.white70,
                                      fontSize: 13,
                                    ),
                                    text:
                                        "+ ${box("Currency")} ${widget.paymentInfo["feeAmount"].toStringAsFixed(2)} transaction fee",
                                  ),
                                  textAlign: TextAlign.left,
                                ),
                              ),
                              const SizedBox(height: 15),
                              referenceTextField(context, referenceController),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                customBackButton(context)
              ],
            ),
          ),
        );
      },
    );
  }
}

Widget customBackButton(BuildContext context) {
  return Positioned(
    top: 82.5,
    left: 20,
    child: GestureDetector(
      onTap: () => goBack(context),
      child: CircleAvatar(
        radius: 30,
        backgroundColor: Colors.grey[700],
        child: const Icon(
          Icons.arrow_back,
          color: Colors.white,
          size: 40,
        ),
      ),
    ),
  );
}

Widget referenceTextField(BuildContext context, controller) {
  return Padding(
    padding: const EdgeInsets.only(left: 0, right: 0),
    child: TextField(
      minLines: 1,
      maxLines: 5,
      cursorHeight: 24,
      controller: controller,
      textAlign: TextAlign.left,
      style: GoogleFonts.ubuntu(
        fontSize: 24,
        color: Colors.white,
        fontWeight: FontWeight.w300,
      ),
      cursorColor: Colors.white,
      keyboardType: TextInputType.text,
      inputFormatters: [
        LengthLimitingTextInputFormatter(200),
      ],
      decoration: InputDecoration(
        filled: true,
        isDense: false,
        hintStyle: GoogleFonts.ubuntu(
          color: Colors.white,
          fontSize: 18,
        ),
        border: InputBorder.none,
        focusColor: Colors.white,
        fillColor: Colors.grey[800],
        errorBorder: InputBorder.none,
        focusedBorder: InputBorder.none,
        enabledBorder: InputBorder.none,
        disabledBorder: InputBorder.none,
        hintText: "What name does it bring? (Type here)",
        floatingLabelBehavior: FloatingLabelBehavior.never,
        contentPadding: const EdgeInsets.fromLTRB(20, 5, 20, 5),
        labelStyle: const TextStyle(
            color: Colors.black87, fontSize: 18, fontFamily: 'AvenirLight'),
      ),
    ),
  );
}
