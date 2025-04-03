import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../components/login_page_widgets.dart';
import 'components/change_account_email_widgets.dart';
import 'package:jayben/Utilities/provider_functions.dart';

class ChangeAccountEmail extends StatefulWidget {
  const ChangeAccountEmail({Key? key}) : super(key: key);

  @override
  State<ChangeAccountEmail> createState() => _ChangeAccountEmailState();
}

class _ChangeAccountEmailState extends State<ChangeAccountEmail> {
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
                        hGap(height(context) * 0.035),
                        forgotPasswordDetailsDescriptionText(),
                        hGap(height(context) * 0.03),
                        emailTextfield(context, emailController),
                        hGap(20),
                        passwordTextfield(context, passwordController),
                        hGap(40),
                        updateAccountEmailAddress(
                          () async {
                            if (emailController.text.isEmpty) {
                              showSnackBar(
                                  context, "Enter an Email & Password");

                              return;
                            }

                            value.toggleIsLoading();

                            hideKeyboard();

                            String response = await value.changeAccountEmail(
                                context,
                                emailController.text.trim(),
                                passwordController.text);

                            value.toggleIsLoading();

                            showSnackBar(context, response.replaceAll("-", " "),
                                duration: 10);
                          },
                        ),
                        hGap(height(context) * 0.02),
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
