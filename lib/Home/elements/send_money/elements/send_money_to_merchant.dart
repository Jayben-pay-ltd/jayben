import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../../Utilities/general_widgets.dart';
import 'package:jayben/Utilities/provider_functions.dart';
import 'package:jayben/Home/elements/send_money/elements/components/send_money_to_merchant_widgets.dart';

class SendMoneyToMerchant extends StatefulWidget {
  const SendMoneyToMerchant({Key? key}) : super(key: key);

  @override
  _SendMoneyToMerchantState createState() => _SendMoneyToMerchantState();
}

class _SendMoneyToMerchantState extends State<SendMoneyToMerchant> {
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

  double amountInDollars = 0.00;
  final amountToSendController = TextEditingController();
  final merchantCodeController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    double dollarRate = double.parse(box("DollarRate").toString());
    return Consumer<PaymentProviderFunctions>(
      builder: (context, value, child) {
        return AnnotatedRegion<SystemUiOverlayStyle>(
          value: SystemUiOverlayStyle.dark,
          child: value.returnIsLoading()
              ? loadingScreenPlainNoBackButton(context)
              : Scaffold(
                  floatingActionButton: sendMoneyFloatingButton(
                      this.context,
                      amountInDollars,
                      amountToSendController,
                      merchantCodeController),
                  backgroundColor: Colors.white,
                  body: WillPopScope(
                    child: sendMoneyToMerchantBody(
                        context,
                        amountInDollars,
                        amountToSendController,
                        merchantCodeController, (String? text) {
                      if (text!.isEmpty) {
                        setState(() {
                          amountInDollars = 0.00;
                        });

                        return;
                      }

                      setState(() {
                        amountInDollars = double.parse(text) * dollarRate;
                      });
                    }),
                    onWillPop: () async {
                      Navigator.pop(this.context);
                      return true;
                    },
                  ),
                ),
        );
      },
    );
  }
}
