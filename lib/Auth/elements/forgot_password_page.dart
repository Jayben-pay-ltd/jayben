import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../Utilities/General_widgets.dart';
import '../components/login_page_widgets.dart';
import 'components/forgot_password_widgets.dart';
import 'package:jayben/Utilities/provider_functions.dart';

class ForgotPassword extends StatefulWidget {
  const ForgotPassword({Key? key}) : super(key: key);

  @override
  State<ForgotPassword> createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPassword> {
  final passwordController = TextEditingController();
  final emailController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProviderFunctions>(builder: (_, value, child) {
      return AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.dark,
        child: Scaffold(
          backgroundColor: Colors.white,
          body: SafeArea(
            child: Stack(
              children: [
                Container(
                  width: width(context),
                  height: height(context),
                  alignment: Alignment.center,
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        logo(),
                        SizedBox(height: height(context) * 0.035),
                        forgotPasswordDetailsDescriptionText(),
                        SizedBox(height: height(context) * 0.03),
                        emailTextfield(context, emailController),
                        const SizedBox(height: 40),
                        sendForgotPasswordLink(
                          () async {
                            if (emailController.text.isEmpty) {
                              showSnackBar(context, "Enter an Email");

                              return;
                            }

                            value.toggleIsLoading();

                            SystemChannels.textInput
                                .invokeMethod('TextInput.hide');

                            var response = await value
                                .forgotPassword(emailController.text.trim());

                            value.toggleIsLoading();

                            if (response == null) {
                              showSnackBar(context,
                                  "Reset password link has been sent to email");

                              Navigator.pop(context);
                              return;
                            }

                            showSnackBar(
                                context, response.replaceAll("-", " "));
                          },
                        ),
                        SizedBox(height: height(context) * 0.02),
                      ],
                    ),
                  ),
                ),
                customAppBar(context)
              ],
            ),
          ),
        ),
      );
    });
  }
}
