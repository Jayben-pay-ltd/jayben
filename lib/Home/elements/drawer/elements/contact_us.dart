// ignore_for_file: file_names
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:jayben/Utilities/General_widgets.dart';
import 'package:jayben/Utilities/provider_functions.dart';
import 'package:jayben/Home/elements/drawer/elements/components/contact_us_widgets.dart';

class ContactUsPage extends StatelessWidget {
  const ContactUsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<HomeProviderFunctions>(
      builder: (_, value, child) {
        return AnnotatedRegion<SystemUiOverlayStyle>(
          value: SystemUiOverlayStyle.dark,
          child: Scaffold(
            backgroundColor: Colors.white,
            body: value.returnIsLoading()
                ? loadingScreenPlainNoBackButton(context)
                : SafeArea(
                    bottom: false,
                    child: Stack(
                      children: [
                        Container(
                          width: width(context),
                          color: Colors.white,
                          height: height(context),
                          margin: const EdgeInsets.only(top: 50),
                          child: SingleChildScrollView(
                            physics: const BouncingScrollPhysics(),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                contactUsWidget(context),
                                hGap(20),
                                Divider(
                                  color: Colors.grey[300]!,
                                ),
                                hGap(10),
                                faqBody(context)
                              ],
                            ),
                          ),
                        ),
                        aboutUsAppBar(context)
                      ],
                    ),
                  ),
          ),
        );
      },
    );
  }
}
