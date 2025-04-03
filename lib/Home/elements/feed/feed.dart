// ignore_for_file: non_constant_identifier_names

import 'dart:async';

import 'componets/feed_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:flutter/rendering.dart';
import '../../../Utilities/general_widgets.dart';
import 'package:jayben/Utilities/provider_functions.dart';

class FeedPage extends StatefulWidget {
  const FeedPage({Key? key}) : super(key: key);

  @override
  State<FeedPage> createState() => _FeedPageState();
}

class _FeedPageState extends State<FeedPage>
    with WidgetsBindingObserver, AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    FeedProviderFunctions prov = context.read<FeedProviderFunctions>();
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        systemNavigationBarIconBrightness: Brightness.light,
        statusBarIconBrightness: Brightness.dark,
        systemNavigationBarColor: Colors.black,
        systemStatusBarContrastEnforced: true,
        statusBarBrightness: Brightness.dark,
        statusBarColor: Colors.transparent,
      ),
    );

    onPageLaunch(prov).whenComplete(() => setState(() {}));

    _timer = Timer.periodic(const Duration(minutes: 1),
        (timer) async => await prov.updateTimeSpentInTimeline());

    _scrollController.addListener(_onScroll);

    super.initState();
  }

  Future<void> onPageLaunch(FeedProviderFunctions prov) async {
    await Future.wait([
      prov.getUploadedContacts(),
      prov.getFeedTransactions(),
    ]);
  }

  void _onScroll() {
    var prov = context.read<FeedProviderFunctions>();

    if (_scrollController.position.userScrollDirection ==
        ScrollDirection.reverse) {
      // Scrolling down, hide the widget
      if (!prov.returnHideStoryWidget() && _scrollController.position.pixels >= _hideThreshold) {
        prov.toggleHideStoryWidget(true);
      }
    } else if (_scrollController.position.userScrollDirection ==
        ScrollDirection.forward) {
      // Scrolling up, show the widget
      if (prov.returnHideStoryWidget() && _scrollController.position.pixels <= _hideThreshold) {
        prov.toggleHideStoryWidget(false);
      }
    }
  }

  Timer? _timer;
  final double _hideThreshold = 150.0;
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _timer!.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    FeedProviderFunctions prov = context.read<FeedProviderFunctions>();
    switch (state) {
      case AppLifecycleState.resumed:
        // this resumes the user's time spent in timeline update loop
        _timer = Timer.periodic(const Duration(minutes: 1),
            (timer) async => await prov.updateTimeSpentInTimeline());
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
      child: Consumer<FeedProviderFunctions>(
        builder: (_, value, child) {
          return value.returnIsLoading() ||
                  value.returnFeedTransactions() == null ||
                  value.returnMyContactsWithJaybenAccs() == null
              ? loadingScreenPlainNoBackButton(context)
              : Scaffold(
                  backgroundColor: Colors.white,
                  body: SafeArea(
                    bottom: false,
                    child: Stack(
                      children: [
                        RepaintBoundary(
                          child: Container(
                            alignment: Alignment.center,
                            color: Colors.white,
                            width: width(context),
                            padding: const EdgeInsets.only(top: 50),
                            child: feedBody(context, _scrollController),
                          ),
                        ),
                        customAppBar(context),
                      ],
                    ),
                  ),
                );
        },
      ),
    );
  }
}
