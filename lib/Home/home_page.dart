// ignore_for_file: non_constant_identifier_names

import 'package:jayben/Home/components/home_page_widgets.dart';
import 'package:jayben/Utilities/provider_functions.dart';
import 'package:jayben/Home/elements/drawer/drawer.dart';
import 'elements/legal/account_restricted_page.dart';
import 'package:nfc_manager/nfc_manager.dart';
import 'package:flutter/rendering.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'dart:io';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with WidgetsBindingObserver, AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    initNfcReader();
    onPageLoad();
  }

  Future<void> initNfcReader() async {
    if (Platform.isAndroid) {
      NfcProviderFunctions nfc_prov = context.read<NfcProviderFunctions>();

      bool isAvailable = await NfcManager.instance.isAvailable();

      if (!isAvailable) return;

      NfcManager.instance.startSession(onDiscovered: (NfcTag? tag) async {
        if (tag == null) return;

        try {
          // if the app is in "read nfc tag" mode
          if (nfc_prov.returnCurrentNfcListenerState() == "read") {
            // reads the NFC tag
            await nfc_prov.onNFCTagRead(context, tag);
          } else {
            // write the NFC tag
            await nfc_prov.onNFCTagWrite(context, tag);
          }
        } on Exception catch (e) {
          showSnackBar(context, e.toString());
          print(e.toString());
        }

        // NfcManager.instance.stopSession();
      });
    }
  }

  Future<void> onPageLoad() async {
    // if user's account is restricted
    if (box("account_is_on_hold") != null &&
        box("account_is_on_hold") &&
        mounted) {
      changePage(context, const PendingApprovalPage(), type: "pr");

      return;
    }

    HomeProviderFunctions prov = context.read<HomeProviderFunctions>();

    // 1). updates the user's notification tokens
    // 2). gets both the home & time limited transactions
    // 3). gets both the home savings accounts & total savings
    // 4). gets user's details & public admin settings
    await Future.wait([
      context.read<FeedProviderFunctions>().getUploadedContacts(),
      context.read<FeedProviderFunctions>().getFeedTransactions(),
      prov.loadDetailsToHive(context),
      prov.updateNotificationToken(),
      prov.getHomeSavingsAccounts(),
      prov.getHomeTransactions(),
    ]);

    // if user's account is restricted
    if (box("account_is_on_hold") && mounted) {
      changePage(context, const PendingApprovalPage(), type: "pr");
    }

    _timer = Timer.periodic(const Duration(minutes: 1), (timer) async {
      await prov.updateDeviceIDAndIPAddress(context, null);
      await prov.updateTimeSpentInTimeline();
      await prov.updateUserLastSeen();
    });

    _scroll_controller.addListener(_onScroll);
  }

  void _onScroll() {
    var prov = context.read<HomeProviderFunctions>();

    if (_scroll_controller.position.userScrollDirection ==
        ScrollDirection.reverse) {
      // Scrolling down, show the widget
      if (!prov.returnShowBackToTopButton() &&
          _scroll_controller.position.pixels >= 150) {
        prov.toggleShowBackToTopButton(true);
      }
    } else if (_scroll_controller.position.userScrollDirection ==
        ScrollDirection.forward) {
      // Scrolling up, hide the widget
      if (prov.returnShowBackToTopButton() &&
          _scroll_controller.position.pixels <= 150) {
        prov.toggleShowBackToTopButton(false);
      }
    }
  }

  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final _scroll_controller = ScrollController();
  Timer? _timer;

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _timer!.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    HomeProviderFunctions prov = context.read<HomeProviderFunctions>();
    switch (state) {
      case AppLifecycleState.resumed:
        // this resumes the user's last seen update loop
        _timer = Timer.periodic(const Duration(minutes: 1),
            (_) async => await prov.updateUserLastSeen());
        break;
      case AppLifecycleState.inactive:
        break;
      case AppLifecycleState.paused:
        _timer!.cancel();
        break;
      case AppLifecycleState.detached:
        _timer!.cancel();
        break;
      case AppLifecycleState.hidden:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: PopScope(
        child: Scaffold(
          key: _scaffoldKey,
          drawer: const AppDrawer(),
          resizeToAvoidBottomInset: true,
          backgroundColor: Colors.white,
          body: homeBodyWidget(context, _scaffoldKey, _scroll_controller),
        ),
        onPopInvoked: (bool value) {
          // resets home state back to wallet
          context.read<HomeProviderFunctions>().changeHomeState("Wallet");
        },
      ),
    );
  }
}
