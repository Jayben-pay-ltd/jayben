// ignore_for_file: non_constant_identifier_names

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../Utilities/general_widgets.dart';
import 'package:jayben/Utilities/provider_functions.dart';
import 'package:jayben/Home/elements/feed/componets/my_contacts_widgets.dart';

class MyContactsPage extends StatefulWidget {
  const MyContactsPage({Key? key}) : super(key: key);

  @override
  State<MyContactsPage> createState() => _MyContactsPageState();
}

class _MyContactsPageState extends State<MyContactsPage>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
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
    onPageLaunch();
    super.initState();
  }

  // gets phone contacts, uploads them & then gets contacts from server
  Future<void> onPageLaunch() async {
    var prov = context.read<FeedProviderFunctions>();

    prov.getContactsFromPhone().then((value) => prov.getUploadedContacts());
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Consumer<FeedProviderFunctions>(
        builder: (_, value, child) {
          return value.returnMyContactsWithJaybenAccs() == null
              ? loadingScreenPlainNoBackButton(context)
              : Scaffold(
                  backgroundColor: Colors.white,
                  body: SafeArea(
                    bottom: false,
                    child: Stack(
                      children: [
                        value.returnContactsCurrentIndex() == 0
                            ? const ContactsBody()
                            : const InviteBody(),
                        contactsCustomAppBar(context),
                      ],
                    ),
                  ),
                );
        },
      ),
    );
  }
}
