import 'package:jayben/Home/elements/drawer/elements/contact_us.dart';
import 'package:jayben/Utilities/provider_functions.dart';
import 'package:jayben/Utilities/constants.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import '../../home_page.dart';

class PendingApprovalPage extends StatefulWidget {
  const PendingApprovalPage({Key? key}) : super(key: key);

  @override
  State<PendingApprovalPage> createState() => _PendingApprovalPageState();
}

class _PendingApprovalPageState extends State<PendingApprovalPage> {
  bool isChecking = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Colors.green,
        onPressed: () => changePage(context, const ContactUsPage()),
        label: const Text("CONTACT US"),
      ),
      body: SizedBox(
        width: width(context),
        height: height(context),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              "assets/logo.png",
              color: Colors.green,
              height: 210,
            ),
            hGap(70),
            Center(
              child: Text(
                ["Agent", "Merchant"].contains(box("account_type"))
                    ? "Account is under review"
                    : "Account is on hold!",
                style: googleStyle(
                  color: Colors.black,
                ),
              ),
            ),
            hGap(20),
            GestureDetector(
              onTap: () async {
                setState(() {
                  isChecking = true;
                });

                await context.read<HomeProviderFunctions>().loadDetailsToHive();

                if (!box("account_is_on_hold")) {
                  changePage(context, const HomePage(), type: "pr");
                } else if (box("account_is_on_hold")) {
                  showSnackBar(
                      context,
                      ["Agent", "Merchant"].contains(box("account_type"))
                          ? "Account is under review, please contact customer support on ${box("jayben_primary_customer_support_hotline")} for more information"
                          : 'Your account is still restricted. If you think we made a mistake, '
                              'please contact customer support on ${box("jayben_primary_customer_support_hotline")}');
                }

                setState(() {
                  isChecking = false;
                });
              },
              child: isChecking
                  ? const SizedBox(
                      height: 45,
                      width: 45,
                      child: CircularProgressIndicator(
                        color: Colors.black,
                        strokeWidth: 2.5,
                      ),
                    )
                  : const Icon(
                      Icons.refresh,
                      size: 60,
                    ),
            )
          ],
        ),
      ),
    );
  }
}
