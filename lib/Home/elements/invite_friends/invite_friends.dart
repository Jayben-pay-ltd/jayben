// ignore_for_file: non_constant_identifier_names
import 'package:jayben/Home/elements/drawer/elements/components/ProfileWidgets.dart';
import 'package:jayben/Home/elements/invite_friends/components/contact_tile.dart';
import 'package:jayben/Utilities/provider_functions.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class InviteFriendsPage extends StatefulWidget {
  const InviteFriendsPage({Key? key}) : super(key: key);

  @override
  _InviteFriendsPageState createState() => _InviteFriendsPageState();
}

class _InviteFriendsPageState extends State<InviteFriendsPage> {
  @override
  void initState() {
    // context.read<ReferralProviderFunctions>().getContacts();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<FeedProviderFunctions>(
      builder: (_, value, child) {
        return AnnotatedRegion<SystemUiOverlayStyle>(
          value: SystemUiOverlayStyle.dark,
          child: Scaffold(
            backgroundColor: Colors.white,
            body: SafeArea(
              child: Stack(
                children: [
                  Container(
                    width: width(context),
                    height: height(context),
                    padding:
                        const EdgeInsets.only(top: 60, left: 10, right: 10),
                    child: value.returnMyContacts().isEmpty
                        ? const Center(child: Text("No contacts found"))
                        : ListView.builder(
                            itemBuilder: (_, i) => InviteContactTile(
                              contact: value.returnMyContacts()[i],
                            ),
                            itemCount: value.returnMyContacts().length,
                          ),
                  ),
                  customAppBar(context)
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget customAppBar(BuildContext context) {
    return Positioned(
      top: 0,
      child: Container(
        width: width(context),
        decoration: appBarDeco(),
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.only(bottom: 10, left: 10, right: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            wGap(10),
            InkWell(
              onTap: () => goBack(context),
              child: const SizedBox(
                child: Icon(
                  color: Colors.black,
                  Icons.arrow_back,
                  size: 40,
                ),
              ),
            ),
            const Spacer(),
            Text.rich(
              const TextSpan(text: "Add Friends"),
              textAlign: TextAlign.left,
              style: GoogleFonts.ubuntu(
                color: const Color.fromARGB(255, 54, 54, 54),
                fontWeight: FontWeight.bold,
                fontSize: 30,
              ),
            ),
            const Spacer(),
            wGap(50),
          ],
        ),
      ),
    );
  }
}
