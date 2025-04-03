// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:jayben/Home/elements/send_money/components/send_money_widgets.dart';

class SendGiftPage extends StatefulWidget {
  const SendGiftPage({Key? key}) : super(key: key);

  @override
  _SendGiftPageState createState() => _SendGiftPageState();
}

class _SendGiftPageState extends State<SendGiftPage> {
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
