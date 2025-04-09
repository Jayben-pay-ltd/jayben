import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../Auth/Splash_page.dart';

class InitializerWidget extends StatefulWidget {
  const InitializerWidget({super.key});

  // final PendingDynamicLinkData? initialLink;

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
  Widget build(BuildContext _) => SplashScreen();
}
