// ignore_for_file: non_constant_identifier_names

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'components/ProfileWidgets.dart';
import '../../../../Utilities/constants.dart';
import 'package:google_fonts/google_fonts.dart';
import 'components/submit_feedback_dialogue.dart';
import 'package:jayben/Utilities/general_widgets.dart';
import 'package:jayben/Utilities/provider_functions.dart';
import 'package:flutter_expanded_tile/flutter_expanded_tile.dart';

class FeedbackPage extends StatefulWidget {
  const FeedbackPage({Key? key}) : super(key: key);

  @override
  _FeedbackPageState createState() => _FeedbackPageState();
}

class _FeedbackPageState extends State<FeedbackPage> {
  @override
  void initState() {
    context.read<UserProviderFunctions>().getFeedbackSubmissions();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<UserProviderFunctions>(
      builder: (_, value, child) {
        return AnnotatedRegion<SystemUiOverlayStyle>(
          value: SystemUiOverlayStyle.dark,
          child: Scaffold(
            backgroundColor: Colors.white,
            body: value.returnFeedbackSubmissions() == null ||
                    value.returnIsLoading()
                ? loadingScreenPlainNoBackButton(context)
                : SafeArea(
                    bottom: false,
                    child: Stack(
                      children: [
                        Container(
                          width: width(context),
                          height: height(context),
                          color: Colors.white,
                          child: value.returnFeedbackSubmissions()!.isEmpty
                              ? Center(
                                  child: Text(
                                    "No submissions yet",
                                    style: googleStyle(
                                        weight: FontWeight.w400,
                                        color: Colors.green,
                                        size: 18),
                                  ),
                                )
                              : RepaintBoundary(
                                  child: MediaQuery.removePadding(
                                    context: context,
                                    removeTop: true,
                                    child: RefreshIndicator(
                                      displacement: 60,
                                      onRefresh: () async {
                                        // plays refresh sound
                                        await playSound('refresh.mp3');

                                        await value.getFeedbackSubmissions();
                                      },
                                      child: ListView.builder(
                                        addRepaintBoundaries: true,
                                        itemCount: value
                                            .returnFeedbackSubmissions()!
                                            .length,
                                        padding: const EdgeInsets.only(top: 65),
                                        physics:
                                            const AlwaysScrollableScrollPhysics(),
                                        itemBuilder: (_, i) {
                                          Map map = value
                                              .returnFeedbackSubmissions()![i];
                                          return feedbackTile(context, map);
                                        },
                                      ),
                                    ),
                                  ),
                                ),
                        ),
                        feedbackAppBar(context),
                      ],
                    ),
                  ),
          ),
        );
      },
    );
  }

  Widget feedbackTile(BuildContext context, Map submission_map) {
    return Consumer<UserProviderFunctions>(builder: (_, value, child) {
      List<dynamic> upvotes = submission_map["users_who_upvoted"];
      upvotes.removeWhere((user) => user['user_id'] != box("user_id"));
      return RepaintBoundary(
        child: Padding(
          padding: const EdgeInsets.only(left: 25, right: 25, bottom: 0),
          child: ExpandedTile(
            theme: ExpandedTileThemeData(
              contentBackgroundColor: Colors.white,
              headerColor: Colors.grey[100]!,
            ),
            controller: ExpandedTileController(isExpanded: true),
            title: Text(
              submission_map["number_of_upvotes"] == 1
                  ? "${submission_map["submission_type"]} (1 upvote)"
                  : "${submission_map["submission_type"]} (${submission_map["number_of_upvotes"]} upvotes)",
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.ubuntu(
                fontWeight: FontWeight.w400,
                color: Colors.grey[700],
                fontSize: 18,
              ),
            ),
            leading: GestureDetector(
                onTap: () async {
                  if (upvotes.isNotEmpty) {
                    showSnackBar(context, "You can only upvote once");

                    return;
                  }

                  value.toggleIsLoading();

                  await value.upvoteFeedbackSubmission(
                      submission_map["submission_id"]);

                  await value.getFeedbackSubmissions();

                  value.toggleIsLoading();
                },
                child: Image.asset(
                  "assets/fire.png",
                  color:
                      upvotes.isNotEmpty ? Colors.orange[600] : Colors.grey[400]!,
                  height: 28,
                )
                // Icon(
                //   Icons.thumb_up_alt,
                //   color: upvotes.isEmpty ? Colors.black : Colors.green,
                // ),
                ),
            content: Container(
              width: width(context),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border(
                  bottom: BorderSide(
                    color: Colors.grey[700]!,
                    width: 0.2,
                  ),
                ),
              ),
              alignment: Alignment.topLeft,
              padding: const EdgeInsets.only(bottom: 20, left: 10),
              child: Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text:
                          "Submitted by ${submission_map["creator_details"]["first_name"]} ${submission_map["creator_details"]["last_name"][0]}",
                      style: GoogleFonts.ubuntu(
                        fontWeight: FontWeight.w500,
                        color: const Color.fromARGB(255, 162, 147, 61),
                        fontSize: 15,
                      ),
                    ),
                    TextSpan(
                      text: '\n\n${submission_map["submission_text"]}',
                      style: GoogleFonts.ubuntu(
                        fontWeight: FontWeight.w400,
                        color: Colors.grey[500],
                        fontSize: 18,
                      ),
                    ),
                  ],
                ),
                textAlign: TextAlign.left,
              ),
            ),
          ),
        ),
      );
    });
  }

  Widget feedbackAppBar(BuildContext context) {
    return Consumer<MessageProviderFunctions>(
      builder: (_, value, child) {
        return Positioned(
          top: 0,
          child: Container(
            width: width(context),
            decoration: appBarDeco(),
            padding: const EdgeInsets.only(bottom: 5, top: 7),
            child: Stack(
              children: [
                Container(
                  width: width(context),
                  alignment: Alignment.center,
                  padding: const EdgeInsets.only(
                    bottom: 7,
                    right: 10,
                    left: 10,
                    top: 2,
                  ),
                  child: Text(
                    "Feedback",
                    style: GoogleFonts.ubuntu(
                      color: const Color.fromARGB(255, 54, 54, 54),
                      fontWeight: FontWeight.bold,
                      fontSize: 24,
                    ),
                  ),
                ),
                Positioned(
                  left: 20,
                  bottom: 5,
                  child: InkWell(
                    onTap: () => goBack(context),
                    child: const SizedBox(
                      child: Icon(
                        Icons.arrow_back,
                        color: Colors.black,
                        size: 40,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  right: 20,
                  bottom: 5,
                  child: InkWell(
                    onTap: () =>
                        showDialogue(context, const SubmitFeedbackDialogue()),
                    child: const SizedBox(
                      child: Icon(
                        Icons.add,
                        color: Colors.black,
                        size: 40,
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
