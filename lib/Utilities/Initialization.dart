import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:jayben/Auth/splash_page.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';

class InitializerWidget extends StatefulWidget {
  const InitializerWidget({Key? key, this.initialLink}) : super(key: key);

  final PendingDynamicLinkData? initialLink;

  @override
  State<InitializerWidget> createState() => _InitializerWidgetState();
}

class _InitializerWidgetState extends State<InitializerWidget>
    with WidgetsBindingObserver {
  @override
  initState() {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
        statusBarBrightness: Brightness.dark,
        statusBarIconBrightness: Brightness.dark,
        systemNavigationBarColor: Colors.black,
        systemNavigationBarIconBrightness: Brightness.light,
        statusBarColor: Colors.transparent));
    super.initState();
  }

  @override
  Widget build(BuildContext _) => SplashScreen(initialLink: widget.initialLink);
}
