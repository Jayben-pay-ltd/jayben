// ignore_for_file: non_constant_identifier_names

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:jayben/Utilities/constants.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../../../../../../Utilities/general_widgets.dart';
import 'package:jayben/Utilities/provider_functions.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:jayben/Home/elements/admin/elements/view_verification_photo.dart';
import 'package:jayben/Home/elements/admin/elements/view_verification_request.dart';

class AdminVerificationRequestTile extends StatelessWidget {
  const AdminVerificationRequestTile({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<AdminProviderFunctions>(
      builder: (_, value, child) {
        return value.returnVerificationRequests() != null
            ? value.returnVerificationRequests()!.isEmpty
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          "No verifications",
                          style: googleStyle(
                            weight: FontWeight.w500,
                            color: Colors.green,
                            size: 18,
                          ),
                        ),
                        hGap(20),
                        GestureDetector(
                          onTap: () async {
                            if (value.returnIsLoading()) return;

                            value.toggleIsLoading();

                            await value.getPendingVerificationRequests();

                            value.toggleIsLoading();
                          },
                          child: value.returnIsLoading()
                              ? loadingIcon(
                                  context,
                                  color: Colors.green,
                                  size: 30,
                                )
                              : const Icon(
                                  color: Colors.green,
                                  Icons.refresh,
                                  size: 40,
                                ),
                        )
                      ],
                    ),
                  )
                : RefreshIndicator(
                    displacement: 150,
                    onRefresh: () async {
                      if (value.returnIsLoading()) return;

                      // plays refresh sound
                      await playSound('refresh.mp3');

                      value.toggleIsLoading();

                      await value.getPendingVerificationRequests();

                      value.toggleIsLoading();
                    },
                    child: MediaQuery.removePadding(
                      removeTop: true,
                      context: context,
                      removeBottom: true,
                      child: ListView.builder(
                        scrollDirection: Axis.vertical,
                        physics: const AlwaysScrollableScrollPhysics(),
                        itemCount: value.returnVerificationRequests()!.length,
                        padding: const EdgeInsets.only(bottom: 20, top: 100),
                        itemBuilder: (_, index) {
                          Map submission_map =
                              value.returnVerificationRequests()![index];
                          return GestureDetector(
                            onTap: () async => changePage(
                              context,
                              ViewVerificationRequestPage(
                                request_map: submission_map,
                              ),
                            ),
                            child: Container(
                              width: width(context),
                              alignment: Alignment.center,
                              margin: const EdgeInsets.only(bottom: 20),
                              child: Container(
                                width: width(context) * 0.9,
                                alignment: Alignment.center,
                                decoration: submissionTileDeco(),
                                padding:
                                    const EdgeInsets.symmetric(vertical: 20),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Text.rich(
                                      TextSpan(
                                        text: "",
                                        children: [
                                          TextSpan(
                                            text: submission_map["status"] ==
                                                    'Pending'
                                                ? "Waiting for review"
                                                : submission_map["status"],
                                            style: GoogleFonts.ubuntu(
                                              fontWeight: FontWeight.w700,
                                              color: Colors.black87,
                                              fontSize: 18,
                                            ),
                                          )
                                        ],
                                      ),
                                      style: GoogleFonts.ubuntu(
                                        fontWeight: FontWeight.w300,
                                        color: Colors.black54,
                                        fontSize: 18,
                                      ),
                                    ),
                                    hGap(10),
                                    Text(
                                      "Submitted ${timeago.format(DateTime.parse(submission_map["created_at"]).toUtc().toLocal())}",
                                      textAlign: TextAlign.left,
                                      maxLines: 1,
                                      style: GoogleFonts.ubuntu(
                                        fontWeight: FontWeight.w400,
                                        color: Colors.orange[700],
                                        fontSize: 15,
                                      ),
                                    ),
                                    hGap(20),
                                    GestureDetector(
                                      onTap: () => changePage(
                                        context,
                                        ViewVerificationPhotoPage(
                                          image: submission_map[
                                              "selfie_image_url"],
                                        ),
                                      ),
                                      child: Container(
                                        height: 150,
                                        alignment: Alignment.center,
                                        width: width(context) * 0.8,
                                        decoration: submissionTileSelfieDeco(),
                                        child: Stack(
                                          children: [
                                            ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(30),
                                              child: CachedNetworkImage(
                                                imageUrl: submission_map[
                                                    "selfie_image_url"],
                                                width: double.infinity,
                                                fit: BoxFit.cover,
                                                height: 150,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    hGap(5),
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        GestureDetector(
                                          onTap: () => changePage(
                                            context,
                                            ViewVerificationPhotoPage(
                                              image: submission_map[
                                                  "document_photo_1_url"],
                                            ),
                                          ),
                                          child: Container(
                                            height: 150,
                                            alignment: Alignment.center,
                                            width: width(context) * 0.39,
                                            decoration:
                                                submissionTileSelfieDeco(),
                                            child: Stack(
                                              children: [
                                                ClipRRect(
                                                  borderRadius:
                                                      BorderRadius.circular(30),
                                                  child: CachedNetworkImage(
                                                    imageUrl: submission_map[
                                                        "document_photo_1_url"],
                                                    width:
                                                        width(context) * 0.425,
                                                    fit: BoxFit.cover,
                                                    height: 150,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                        wGap(5),
                                        GestureDetector(
                                          onTap: () => changePage(
                                            context,
                                            ViewVerificationPhotoPage(
                                              image: submission_map[
                                                  "document_photo_2_url"],
                                            ),
                                          ),
                                          child: Container(
                                            height: 150,
                                            alignment: Alignment.center,
                                            width: width(context) * 0.39,
                                            decoration:
                                                submissionTileSelfieDeco(),
                                            child: Stack(
                                              children: [
                                                ClipRRect(
                                                  borderRadius:
                                                      BorderRadius.circular(30),
                                                  child: CachedNetworkImage(
                                                    imageUrl: submission_map[
                                                        "document_photo_2_url"],
                                                    width:
                                                        width(context) * 0.425,
                                                    fit: BoxFit.cover,
                                                    height: 150,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    hGap(20),
                                    Container(
                                      width: width(context),
                                      height: height(context) * 0.064,
                                      alignment: Alignment.centerLeft,
                                      margin: const EdgeInsets.only(
                                        right: 30,
                                        left: 30,
                                      ),
                                      padding: const EdgeInsets.only(
                                        bottom: 10,
                                        left: 20,
                                        top: 10,
                                      ),
                                      decoration: BoxDecoration(
                                        borderRadius:
                                            BorderRadius.circular(20.0),
                                        color: Colors.white,
                                      ),
                                      child: Text(
                                        submission_map["identification_type"],
                                        textAlign: TextAlign.left,
                                        style: GoogleFonts.ubuntu(
                                          color: Colors.black54,
                                          fontSize: 22,
                                        ),
                                      ),
                                    ),
                                    hGap(20),
                                    submission_map["comment"].isEmpty
                                        ? nothing()
                                        : Container(
                                            width: width(context) * 0.9,
                                            alignment: Alignment.center,
                                            padding: const EdgeInsets.only(
                                              bottom: 10,
                                              right: 30,
                                              left: 30,
                                            ),
                                            child: Text.rich(
                                              TextSpan(
                                                text: "Rejection Comment: ",
                                                children: [
                                                  TextSpan(
                                                    text: submission_map[
                                                        "comment"],
                                                    style: GoogleFonts.ubuntu(
                                                      fontWeight:
                                                          FontWeight.w400,
                                                      color: Colors.black87,
                                                      fontSize: 15,
                                                    ),
                                                  )
                                                ],
                                              ),
                                              maxLines: 2,
                                              textAlign: TextAlign.center,
                                              style: GoogleFonts.ubuntu(
                                                fontWeight: FontWeight.w300,
                                                color: Colors.black54,
                                                fontSize: 15,
                                              ),
                                            ),
                                          )
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  )
            : Center(child: loadingIcon(context));
      },
    );
  }
}

// =============== styling widgets

Decoration submissionTileDeco() {
  return BoxDecoration(
    color: Colors.grey[200],
    borderRadius: BorderRadius.circular(30),
  );
}

Decoration submissionTileSelfieDeco() {
  return BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(30),
  );
}
