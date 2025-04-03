import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'components/login_page_widgets.dart';
import 'elements/components/forgot_password_widgets.dart';
import 'package:jayben/Utilities/provider_functions.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  @override
  void initState() {
    context.read<AuthProviderFunctions>().clearAllVariables();
    super.initState();
  }

  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Stack(
            children: [
              GestureDetector(
                onTap: () => hideKeyboard(),
                child: Container(
                  width: width(context),
                  height: height(context),
                  color: Colors.transparent,
                  alignment: Alignment.center,
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        logo(),
                        hGap(height(context) * 0.035),
                        enterdetailsDescriptionText(),
                        hGap(height(context) * 0.03),
                        emailTextfield(context, emailController),
                        hGap(height(context) * 0.03),
                        passwordTextfield(context, passwordController),
                        hGap(5),
                        passwordExample(context),
                        hGap(40),
                        actionButton(
                            context, passwordController, emailController),
                        hGap(10),
                        forgotPasswordButton(context)
                      ],
                    ),
                  ),
                ),
              ),
              customLoginAppBar(context)
            ],
          ),
        ),
      ),
    );
  }
}
