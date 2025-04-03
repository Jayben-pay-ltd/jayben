import 'package:jayben/Home/elements/savings/elements/components/create_shared_no_access_account_dialogue.dart';
import 'package:jayben/Home/elements/savings/elements/components/create_personal_no_access_account_dialogue.dart';
import 'package:jayben/Utilities/provider_functions.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/material.dart';
import 'dart:io';

class SelectNasAccountCard extends StatelessWidget {
  const SelectNasAccountCard({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width(context),
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topRight: Radius.circular(40),
            topLeft: Radius.circular(40),
          ),
        ),
        child: Padding(
          padding: EdgeInsets.only(
              left: 30, right: 30, top: 30, bottom: Platform.isIOS ? 40 : 25),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                alignment: Alignment.center,
                width: width(context) * 0.8,
                child: Text(
                  "What type of savings account?",
                  style: GoogleFonts.ubuntu(
                    fontWeight: FontWeight.w700,
                    color: Colors.green,
                    fontSize: 18,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              GestureDetector(
                onTap: () => showDialogue(
                    context, const CreatePersonalNoAccessAccountDialogue()),
                child: Container(
                  color: Colors.white,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      CircleAvatar(
                        radius: 23,
                        backgroundColor: Colors.grey[200],
                        child: Image.asset(
                          'assets/individual.png',
                          height: 45,
                          width: 45,
                        ),
                      ),
                      const SizedBox(width: 15),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Personal No Access Account",
                            style: GoogleFonts.ubuntu(
                              color: const Color(0xFF616161),
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            "Save money on your own",
                            style: GoogleFonts.ubuntu(
                              color: Colors.grey[600],
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              GestureDetector(
                onTap: () => showDialogue(
                    context, const CreateSharedNoAccessAccountDialogue()),
                child: Container(
                  color: Colors.white,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      CircleAvatar(
                        radius: 23,
                        backgroundColor: Colors.grey[200],
                        child: Image.asset(
                          'assets/group_of_people.png',
                          height: 45,
                          width: 45,
                        ),
                      ),
                      const SizedBox(width: 15),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Group No Access Account",
                            style: GoogleFonts.ubuntu(
                              color: const Color(0xFF616161),
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            "Save money with friends & family",
                            style: GoogleFonts.ubuntu(
                              color: Colors.grey[600],
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
