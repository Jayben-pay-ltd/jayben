import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:jayben/Utilities/provider_functions.dart';
import 'package:jayben/Home/elements/savings/components/add_money_to_savings_widgets.dart';

class TransferToSavingsPage extends StatefulWidget {
  const TransferToSavingsPage(
      {Key? key,
      required this.accountID,
      required this.backendType,
      required this.accountName,
      required this.accountType})
      : super(key: key);

  final String accountID;
  final String accountName;
  final String backendType;
  final String accountType;

  @override
  _TransferToSavingsPageState createState() => _TransferToSavingsPageState();
}

class _TransferToSavingsPageState extends State<TransferToSavingsPage> {
  @override
  void initState() {
    context.read<SavingsProviderFunctions>().clearStrings();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: Colors.grey[900],
        body: addMoneyToSavingsBody(context, {
          "accountName": widget.accountName,
          "backendType": widget.backendType,
          "accountType": widget.accountType,
          "accountID": widget.accountID,
        }),
      ),
    );
  }
}
