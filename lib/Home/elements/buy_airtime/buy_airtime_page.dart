import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'components/buy_airtime_page_widgets.dart';
import 'package:jayben/Utilities/provider_functions.dart';

class AirtimePage extends StatefulWidget {
  const AirtimePage({Key? key}) : super(key: key);

  @override
  State<AirtimePage> createState() => _AirtimePageState();
}

class _AirtimePageState extends State<AirtimePage> {
  @override
  void initState() {
    context.read<AirtimeProviderFunctions>().clearStrings();
    super.initState();
  }

  bool? isBalanceEnough;

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        backgroundColor: Colors.grey[900],
        body: airtimeBody(context),
      ),
    );
  }
}
