// ignore_for_file: non_constant_identifier_names
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:jayben/Utilities/provider_functions.dart';
import 'package:jayben/Home/elements/send_money/elements/components/select_receiver_widgets.dart';

class SeelctReceiverPage extends StatefulWidget {
  const SeelctReceiverPage({super.key});

  @override
  State<SeelctReceiverPage> createState() => _SeelctReceiverPageState();
}

class _SeelctReceiverPageState extends State<SeelctReceiverPage> {
  @override
  void initState() {
    onPageLaunch();
    super.initState();
  }

  // gets phone contacts, uploads them & then gets contacts from server
  Future<void> onPageLaunch() async {
    context.read<PaymentProviderFunctions>().resetUsernameSearchResults();
    var prov = context.read<FeedProviderFunctions>();

    prov.getContactsFromPhone().then((value) => prov.getUploadedContacts());
  }

  final username_controller = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          bottom: false,
          child: Stack(
            children: [
              selectReceiversBody(context),
              selectReceiversAppBar(context, username_controller)
            ],
          ),
        ),
      ),
    );
  }
}
