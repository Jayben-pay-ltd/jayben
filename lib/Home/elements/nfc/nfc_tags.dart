// ignore_for_file: non_constant_identifier_names
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'components/nfc_tags_widgets.dart';
import 'package:jayben/Utilities/provider_functions.dart';

class NfcTagsPage extends StatefulWidget {
  const NfcTagsPage({super.key});

  @override
  State<NfcTagsPage> createState() => _NfcTagsPageState();
}

class _NfcTagsPageState extends State<NfcTagsPage> {
  @override
  void initState() {
    context.read<NfcProviderFunctions>().clearStrings();
    context.read<NfcProviderFunctions>().getTags();
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
          child: tagsBody(this.context),
        ),
      ),
    );
  }
}
