import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../Utilities/general_widgets.dart';
import 'package:jayben/Utilities/provider_functions.dart';
import 'package:jayben/Home/elements/timeline_privacy_settings/components/only_share_with_widgets.dart';

class OnlyShareWithPage extends StatefulWidget {
  const OnlyShareWithPage({Key? key}) : super(key: key);

  @override
  State<OnlyShareWithPage> createState() => _OnlyShareWithPageState();
}

class _OnlyShareWithPageState extends State<OnlyShareWithPage> {
  @override
  void initState() {
    var prov = context.read<FeedProviderFunctions>();
    prov.getUploadedContacts();
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
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Consumer<FeedProviderFunctions>(
        builder: (_, value, child) {
          return value.returnSelectedOnlyShareWith() == null
              ? loadingScreenPlainNoBackButton(context)
              : Scaffold(
                  backgroundColor: Colors.white,
                  body: SafeArea(
                    bottom: false,
                    child: Stack(
                      children: [
                        const ContactsBody(),
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
