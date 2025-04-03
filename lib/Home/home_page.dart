// ignore_for_file: non_constant_identifier_names

import 'dart:io';

import 'package:jayben/Home/elements/savings/elements/make_donation_to_shared_nas_acc_card.dart';
import 'package:jayben/Home/elements/savings/elements/join_shared_nas_account_card.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
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

class HomePage extends StatefulWidget {
  const HomePage({Key? key, this.initialLink}) : super(key: key);

  final PendingDynamicLinkData? initialLink;

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with WidgetsBindingObserver, AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    FirebaseDynamicLinks.instance.onLink.listen((dynamicLinkData) {
      if (!mounted) return;

      List<String> split_id_list =
          dynamicLinkData.link.queryParameters["id"].toString().split("_");

      /// if the link has no type
      if (split_id_list.length == 1) {
        // show the join nas account card
        showBottomCard(
          context,
          JoinSharedNasAccountCard(
            account_id: split_id_list[0],
          ),
        );
      } else if (split_id_list.length != 1) {
        /// if the link has type donation
        if (split_id_list[1] == "donation") {
          // show make a donation to nas account card
          showBottomCard(
            context,
            DonateToSharedNasAccountCard(
              account_id: split_id_list[0],
            ),
          );
        }
      }
    }).onError((error) {
      showSnackBar(context, "An error ocurred trying to open link");
    });

    if (Platform.isAndroid) {
      NfcProviderFunctions nfc_prov = context.read<NfcProviderFunctions>();

      NfcManager.instance.startSession(onDiscovered: (NfcTag tag) async {
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
        }

        // NfcManager.instance.stopSession();
      });
    }

    super.initState();
    onPageLoad();
  }

  Future<void> onPageLoad() async {
    // if user's account is restricted
    if (box("OnHold") != null && box("OnHold") && mounted) {
      changePage(context, const PendingApprovalPage(), type: "pr");

      return;
    }

    if (widget.initialLink != null) {
      final Uri deepLink = widget.initialLink!.link;
      // Example of using the dynamic link to push the user to a different screen

      List<String> list = deepLink.queryParameters["id"].toString().split("_");

      if (list.length == 1) {
        showBottomCard(
          context,
          JoinSharedNasAccountCard(
            account_id: list[0],
          ),
        );
      } else if (list.length != 1) {
        if (list[1] == "donation") {
          showBottomCard(
            context,
            DonateToSharedNasAccountCard(
              account_id: list[0],
            ),
          );
        }
      }
    }

    HomeProviderFunctions prov = context.read<HomeProviderFunctions>();

    // 1). updates the user's notification tokens
    // 2). gets both the home & time limited transactions
    // 3). gets both the home savings accounts & total savings
    // 4). gets user's details & public admin settings
    await Future.wait([
      context.read<FeedProviderFunctions>().getUploadedContacts(),
      context.read<FeedProviderFunctions>().getFeedTransactions(),
      prov.updateNotificationToken(),
      prov.getHomeSavingsAccounts(),
      prov.getHomeTransactions(),
      prov.loadDetailsToHive(),
    ]);

    // if user's account is restricted
    if (box("OnHold") && mounted) {
      changePage(context, const PendingApprovalPage(), type: "pr");
    }

    _timer = Timer.periodic(const Duration(minutes: 1), (timer) async {
      await prov.updateDeviceIDAndIPAddress(context);
      await prov.updateTimeSpentInTimeline();
      await prov.updateUserLastSeen();
    });

    _scroll_controller.addListener(_onScroll);

    context.read<HomeProviderFunctions>().checkAppVersion(context);
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
            (timer) async => await prov.updateUserLastSeen());
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
