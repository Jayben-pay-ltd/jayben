// ignore_for_file: non_constant_identifier_names

import 'package:jayben/Auth/components/pre_login_widgets.dart';
import 'package:jayben/Utilities/provider_functions.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';

class PreLoginPage extends StatefulWidget {
  const PreLoginPage({Key? key}) : super(key: key);

  @override
  _PreLoginPageState createState() => _PreLoginPageState();
}

class _PreLoginPageState extends State<PreLoginPage> {
  @override
  void initState() {
    // context.read<AuthProviderFunctions>().getContactUsDetails();
    // context.read<AuthProviderFunctions>().getTOS();
    super.initState();
    hideKeyboard();
  }

  final username_controller = TextEditingController();
  final email_controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        backgroundColor: Colors.white,
        body: preLoginBody(context, {
          "username_controller": username_controller,
          "email_controller": email_controller,
        }),
      ),
    );
  }
}
