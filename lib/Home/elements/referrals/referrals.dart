// ignore_for_file: non_constant_identifier_names
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:jayben/Utilities/provider_functions.dart';
import 'package:jayben/Home/elements/referrals/components/referrals_widgets.dart';

class ReferralsPage extends StatefulWidget {
  const ReferralsPage({super.key});

  @override
  State<ReferralsPage> createState() => _ReferralsPageState();
}

class _ReferralsPageState extends State<ReferralsPage> {
  @override
  void initState() {
    context.read<ReferralProviderFunctions>().getMyReferralCommissions();
    context.read<FeedProviderFunctions>().getContactsFromPhone();
    context.read<FeedProviderFunctions>().getUploadedContacts();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          bottom: false,
          child: referralsBody(this.context),
        ),
      ),
    );
  }
}
