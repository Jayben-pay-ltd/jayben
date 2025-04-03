import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:jayben/Utilities/general_widgets.dart';
import 'package:jayben/Utilities/provider_functions.dart';
import 'package:jayben/Home/elements/feed/elements/components/my_posts_widgets.dart';

class MyPostsPage extends StatefulWidget {
  const MyPostsPage({Key? key}) : super(key: key);

  @override
  State<MyPostsPage> createState() => _MyPostsPageState();
}

class _MyPostsPageState extends State<MyPostsPage> {
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
    super.initState();
  }

  Future<void> onPageLaunch(FeedProviderFunctions prov) async {
    await Future.wait([
      prov.getOnlyMyFeedTransactions(),
      prov.getUploadedContacts(),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Consumer<FeedProviderFunctions>(
        builder: (_, value, child) {
          return value.returnIsLoading() ||
                  value.returnMyFeedPosts() == null ||
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
                            color: Colors.white,
                            width: width(context),
                            alignment: Alignment.center,
                            padding: const EdgeInsets.only(top: 50),
                            child: myPostsBody(context),
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
