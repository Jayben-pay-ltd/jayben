// ignore_for_file: non_constant_identifier_names
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:jayben/Utilities/provider_functions.dart';
import 'package:jayben/Home/elements/savings/elements/components/add_friends_to_shared_nas_account_widgets.dart';

class AddFriendPage extends StatefulWidget {
  const AddFriendPage({super.key, required this.account_map});

  final Map account_map;

  @override
  State<AddFriendPage> createState() => _AddFriendPageState();
}

class _AddFriendPageState extends State<AddFriendPage> {
  @override
  void initState() {
    onPageLaunch();
    super.initState();
  }

  // gets phone contacts, uploads them & then gets contacts from server
  Future<void> onPageLaunch() async {
    context.read<SavingsProviderFunctions>().resetUsernameSearchResults();
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
              addFriendsBody(context, widget.account_map),
              addFriendsAppBar(context, username_controller)
            ],
          ),
        ),
      ),
    );
  }
}
