// ignore_for_file: non_constant_identifier_names

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:jayben/Utilities/provider_functions.dart';
import 'package:jayben/Home/elements/savings/elements/components/donate_to_shared_nas_account_widgets.dart';

class DonateToSharedNasAccountPage extends StatefulWidget {
  const DonateToSharedNasAccountPage({Key? key, required this.account_map})
      : super(key: key);

  final Map account_map;

  @override
  _DonateToSharedNasAccountPageState createState() =>
      _DonateToSharedNasAccountPageState();
}

class _DonateToSharedNasAccountPageState
    extends State<DonateToSharedNasAccountPage> {
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
        body: donateToSharedNasAccBody(context, widget.account_map),
      ),
    );
  }
}
