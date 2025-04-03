import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../Utilities/general_widgets.dart';
import 'package:jayben/Utilities/provider_functions.dart';
import 'package:jayben/Home/elements/timeline_privacy_settings/components/all_contacts_except_widgets.dart';


class AllContactsExceptPage extends StatefulWidget {
  const AllContactsExceptPage({Key? key}) : super(key: key);

  @override
  State<AllContactsExceptPage> createState() => _AllContactsExceptPageState();
}

class _AllContactsExceptPageState extends State<AllContactsExceptPage> {

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
          return value.returnSelectedAllContactsExcept() == null
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
