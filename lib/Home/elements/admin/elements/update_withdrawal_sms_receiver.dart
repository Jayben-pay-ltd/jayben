// ignore_for_file: non_constant_identifier_names

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:jayben/Utilities/provider_functions.dart';
import 'package:jayben/Home/elements/admin/elements/components/update_withdrawal_receiver_widgets.dart';

class UpdateWithdrawalSmsReceiverPage extends StatefulWidget {
  const UpdateWithdrawalSmsReceiverPage({super.key});

  @override
  State<UpdateWithdrawalSmsReceiverPage> createState() =>
      _UpdateWithdrawalSmsReceiverPageState();
}

class _UpdateWithdrawalSmsReceiverPageState
    extends State<UpdateWithdrawalSmsReceiverPage> {
  @override
  void initState() {
    super.initState();
    onPageLaunch();
  }

  Future onPageLaunch() async {
    String? number = await context
        .read<AdminProviderFunctions>()
        .getCurrentWithdrawalReceiverNumber();

    setState(() => number_controller.text = number);
  }

  final number_controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      floatingActionButton: floatingButton(context, {
        "number_controller": number_controller,
      }),
      body: updateWithdrawalSMSReceiverBody(context, {
        "number_controller": number_controller,
      }),
    );
  }
}
