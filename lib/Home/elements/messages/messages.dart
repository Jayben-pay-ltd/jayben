import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:jayben/Utilities/provider_functions.dart';
import 'package:jayben/Home/elements/messages/components/messages_widgets.dart';

class ChatsPage extends StatefulWidget {
  const ChatsPage({Key? key}) : super(key: key);

  @override
  State<ChatsPage> createState() => _ChatsPageState();
}

class _ChatsPageState extends State<ChatsPage>
    with WidgetsBindingObserver, AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    var prov = context.read<MessageProviderFunctions>();

    prov.getChatrooms();

    _timer = Timer.periodic(const Duration(seconds: 15),
        (timer) async => await prov.getChatrooms());
  }

  Timer? _timer;

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _timer!.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: WillPopScope(
            child: RepaintBoundary(
              child: Stack(
                children: [
                  Container(
                    color: Colors.white,
                    width: width(context),
                    height: height(context),
                    alignment: Alignment.center,
                    child: messagesBody(context),
                  ),
                  chatsroomsAppBar(context)
                ],
              ),
            ),
            onWillPop: () async {
              goBack(context);
              return false;
            },
          ),
        ),
      ),
    );
  }
}
