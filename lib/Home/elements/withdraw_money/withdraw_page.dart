import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:jayben/Utilities/provider_functions.dart';
import 'package:jayben/Home/elements/withdraw_money/components/withdraw_widgets.dart';

class WithdrawalPage extends StatefulWidget {
  const WithdrawalPage({Key? key}) : super(key: key);

  @override
  _WithdrawalPageState createState() => _WithdrawalPageState();
}

class _WithdrawalPageState extends State<WithdrawalPage>
    with WidgetsBindingObserver {
  @override
  void initState() {
    context.read<WithdrawProviderFunctions>().clearStrings();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: Colors.grey[900],
        body: withdrawBody(context),
      ),
    );
  }
}
