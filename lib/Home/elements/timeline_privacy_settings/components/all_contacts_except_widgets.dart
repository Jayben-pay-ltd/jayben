// ignore_for_file: non_constant_identifier_names
import 'package:cached_network_image/cached_network_image.dart';
import '../../drawer/elements/components/ProfileWidgets.dart';
import 'package:jayben/Utilities/provider_functions.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';

Widget customAppBar(BuildContext context) {
  return Consumer<FeedProviderFunctions>(
    builder: (_, value, child) {
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
                const TextSpan(text: "Hide posts from..."),
                textAlign: TextAlign.left,
                style: GoogleFonts.ubuntu(
                  color: const Color.fromARGB(255, 54, 54, 54),
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
              wGap(130),
            ],
          ),
        ),
      );
    },
  );
}

Widget noPostPlaceHolder(BuildContext context) {
  return Container(
    alignment: Alignment.center,
    height: height(context) * 0.8,
    padding: const EdgeInsets.symmetric(vertical: 30),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Image.asset(
          "assets/newsfeed.png",
          color: Colors.white70,
          height: 40,
        ),
        const SizedBox(height: 10),
        Text(
          "No Friend Posts",
          style: GoogleFonts.ubuntu(
            color: Colors.white,
          ),
        ),
      ],
    ),
  );
}

class ContactsBody extends StatelessWidget {
  const ContactsBody({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<FeedProviderFunctions>(
      builder: (_, value, child) {
        return RepaintBoundary(
          child: Container(
            color: Colors.white,
            width: width(context),
            alignment: Alignment.center,
            child: ListView.builder(
              addRepaintBoundaries: true,
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.only(top: 65, bottom: 20),
              itemCount: value.returnMyContactsWithJaybenAccs()!.length,
              itemBuilder: (__, i) {
                Map current_contact_map =
                    value.returnMyContactsWithJaybenAccs()![i];
                return listTile(context, current_contact_map);
              },
            ),
          ),
        );
      },
    );
  }

  Widget listTile(BuildContext context, Map contact_map) {
    return Consumer<FeedProviderFunctions>(
      builder: (_, value, child) {
        return GestureDetector(
          onTap: () async => value.toggleSelectedAllContactsExcept(contact_map),
          child: Container(
            width: width(context),
            margin: const EdgeInsets.only(bottom: 15),
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                contact_map["contacts_jayben_account_details"]
                            ["profile_image_url"] ==
                        ""
                    ? CircleAvatar(
                        radius: 27,
                        backgroundColor: Colors.grey[100],
                        backgroundImage: const AssetImage(
                          "assets/ProfileAvatar.png",
                        ),
                      )
                    : CircleAvatar(
                        radius: 27,
                        backgroundColor: Colors.grey[300],
                        backgroundImage: CachedNetworkImageProvider(
                          contact_map["contacts_jayben_account_details"]
                              ["profile_image_url"],
                        ),
                      ),
                wGap(15),
                SizedBox(
                  width: width(context) * 0.65,
                  child: Text(
                    contact_map["contacts_display_name"],
                    style: GoogleFonts.ubuntu(
                      fontWeight: FontWeight.w600,
                      fontSize: 17,
                    ),
                  ),
                ),
                const Spacer(),
                Container(
                  decoration: BoxDecoration(
                    color: value
                            .returnSelectedAllContactsExcept()!
                            .contains(contact_map)
                        ? Colors.green[300]
                        : Colors.white,
                    border: Border.all(
                      color: value
                              .returnSelectedAllContactsExcept()!
                              .contains(contact_map)
                          ? Colors.green[300]!
                          : Colors.grey[300]!,
                    ),
                    shape: BoxShape.circle,
                  ),
                  height: 25.0,
                  width: 25.0,
                  child: value
                          .returnSelectedAllContactsExcept()!
                          .contains(contact_map)
                      ? const Center(
                          child: Icon(
                            color: Colors.white,
                            Icons.check,
                            size: 15,
                          ),
                        )
                      : nothing(),
                ),
                wGap(5),
              ],
            ),
          ),
        );
      },
    );
  }
}
