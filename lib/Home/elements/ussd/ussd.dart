// ignore_for_file: non_constant_identifier_names
import 'package:jayben/Home/elements/ussd/components/ussd_widgets.dart';
import 'package:jayben/Utilities/provider_functions.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class USSDPage extends StatefulWidget {
  const USSDPage({super.key});

  @override
  State<USSDPage> createState() => _USSDPageState();
}

class _USSDPageState extends State<USSDPage> {
  @override
  void initState() {
    context.read<UssdProviderFunctions>().getUSSDShortcuts();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          bottom: false,
          child: ussdBody(context),
        ),
      ),
    );
  }
}
