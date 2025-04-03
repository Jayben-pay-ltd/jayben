// ignore_for_file: non_constant_identifier_names

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:jayben/Home/home_page.dart';
import 'package:jayben/Utilities/constants.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:jayben/Utilities/provider_functions.dart';

class DepositWebviewPage extends StatefulWidget {
  const DepositWebviewPage(
      {Key? key, required this.deposit_link, required this.deposit_id})
      : super(key: key);

  final String deposit_link;
  final String deposit_id;

  @override
  State<DepositWebviewPage> createState() => _DepositWebviewPageState();
}

class _DepositWebviewPageState extends State<DepositWebviewPage> {
  @override
  void initState() {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarBrightness: Brightness.dark,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.black,
      systemNavigationBarIconBrightness: Brightness.light,
      statusBarColor: Colors.black,
    ));

    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {},
          onPageStarted: (String url) {},
          onPageFinished: (String url) => setState(() => isLoading = false),
          onWebResourceError: (WebResourceError error) {},
          onNavigationRequest: (NavigationRequest request) {
            if (request.url.startsWith('https://www.youtube.com/')) {
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.deposit_link));

    // checks if payment is successful every 5 seconds
    timer = Timer.periodic(const Duration(seconds: 10), (timer) async {
      if (!timer.isActive) return;

      if (!mounted) return;

      // checks if the transaction is complete and successful
      bool isSuccessful = await context
          .read<DepositProviderFunctions>()
          .checkIfPaymentComplete(widget.deposit_id);

      if (isSuccessful) {
        // stops loop
        timer.cancel;

        // tells user deposit was complete and successful
        showSnackBar(context, "Deposit was successful", color: Colors.green);

        // routes the user back to the home page
        changePage(context, const HomePage(), type: "pushReplacement");
      }
    });

    super.initState();
  }

  Timer? timer;
  bool isLoading = true;
  WebViewController? controller;
  bool showSelectMethodText = false;

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          leading: InkWell(
            onTap: () => goBack(context),
            child: Icon(
              color: iconColor,
              Icons.close,
            ),
          ),
          systemOverlayStyle: const SystemUiOverlayStyle(
            statusBarIconBrightness: Brightness.light,
            statusBarColor: Colors.transparent,
          ),
          backgroundColor: Colors.white,
          title: Text(
              isLoading ? "Loading, please wait..." : "Choose a deposit method",
              style: TextStyle(color: iconColor)),
          centerTitle: true,
          actions: [
            InkWell(
              onTap: () {
                goBack(context);

                changePage(
                    context,
                    DepositWebviewPage(
                        deposit_id: widget.deposit_id,
                        deposit_link: widget.deposit_link));
              },
              child: Icon(
                color: iconColor,
                Icons.refresh,
              ),
            ),
            const SizedBox(width: 20)
          ],
        ),
        body: Stack(
          children: [
            WebViewWidget(controller: controller!),
            Positioned(
              top: 0,
              child: isLoading
                  ? Container(
                      width: MediaQuery.of(context).size.width,
                      height: 4,
                      color: Colors.transparent,
                      child: const LinearProgressIndicator(
                        backgroundColor: Colors.transparent,
                        color: Colors.green,
                      ),
                    )
                  : nothing(),
            )
          ],
        ),
      ),
    );
  }
}
