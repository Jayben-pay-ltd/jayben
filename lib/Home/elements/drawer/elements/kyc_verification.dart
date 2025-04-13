// ignore_for_file: non_constant_identifier_names
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:jayben/Utilities/provider_functions.dart';
import 'package:jayben/Home/elements/drawer/elements/components/kyc_verification_widgets.dart';

class KycVerificationPage extends StatefulWidget {
  const KycVerificationPage({super.key});

  @override
  State<KycVerificationPage> createState() => _KycVerificationPageState();
}

class _KycVerificationPageState extends State<KycVerificationPage> {
  @override
  void initState() {
    context.read<KycProviderFunctions>().getVerficationRequests();
    context.read<HomeProviderFunctions>().loadDetailsToHive(context);
    context.read<KycProviderFunctions>().nullifyPhotoFile(3);

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
          child: kcyVerificationBody(this.context),
        ),
      ),
    );
  }
}
