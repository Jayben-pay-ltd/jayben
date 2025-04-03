// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'components/send_money_widgets.dart';

class SendMoneyByUsername extends StatefulWidget {
  const SendMoneyByUsername({Key? key}) : super(key: key);

  @override
  _SendMoneyByUsernameState createState() => _SendMoneyByUsernameState();
}

class _SendMoneyByUsernameState extends State<SendMoneyByUsername> {
  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: Colors.grey[900],
        body: WillPopScope(
          child: sendMoneyUsernameBody(context),
          onWillPop: () async {
            Navigator.pop(context);
            return true;
          },
        ),
      ),
    );
  }
}
