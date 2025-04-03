// ignore_for_file: use_build_context_synchronously, non_constant_identifier_names
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:jayben/Utilities/general_widgets.dart';
import 'package:jayben/Utilities/provider_functions.dart';

class BlockConfirmDialogue extends StatefulWidget {
  const BlockConfirmDialogue({Key? key, required this.user_map})
      : super(key: key);

  final Map user_map;

  @override
  State<BlockConfirmDialogue> createState() => _BlockConfirmDialogueState();
}

class _BlockConfirmDialogueState extends State<BlockConfirmDialogue> {
  bool isBlocking = false;

  @override
  Widget build(BuildContext context) {
    return Consumer<FeedProviderFunctions>(
      builder: (_, value, child) {
        return AlertDialog(
          shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(40))),
          content: SizedBox(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Block ${widget.user_map["first_name"]} ${widget.user_map["last_name"]}?",
                      style: GoogleFonts.ubuntu(
                        color: Colors.grey[600],
                        fontSize: 20,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Text(
                  "you will no longer view their posts",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.ubuntu(
                    fontWeight: FontWeight.w300,
                    color: Colors.grey[600],
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 20),
                InkWell(
                  onTap: () async {
                    setState(() {
                      isBlocking = true;
                    });

                    await value.blockPerson(widget.user_map["user_id"]);

                    setState(() {
                      isBlocking = true;
                    });

                    showSnackBar(
                        context,
                        "${widget.user_map["first_name"]} "
                        "${widget.user_map["last_name"]} has been blocked",
                        color: Colors.grey[700]!);

                    goBack(context);
                  },
                  child: Container(
                    alignment: Alignment.center,
                    width: width(context) * 0.40,
                    height: height(context) * 0.06,
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.all(
                        Radius.circular(30),
                      ),
                    ),
                    child: isBlocking
                        ? loadingIcon(this.context)
                        : Text(
                            "Block",
                            textAlign: TextAlign.center,
                            style: GoogleFonts.ubuntu(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              fontSize: 18,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
