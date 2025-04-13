// ignore_for_file: non_constant_identifier_names
import 'package:jayben/Home/elements/admin/elements/view_verification_photo.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:jayben/Utilities/provider_functions.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:jayben/Utilities/General_widgets.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:jayben/Utilities/constants.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:jayben/Home/home_page.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'dart:io';

Widget customAppBar(BuildContext context) {
  return Consumer<KycProviderFunctions>(
    builder: (_, value, child) {
      return Positioned(
        top: 0,
        child: Container(
          width: width(context),
          decoration: appBarDeco(),
          alignment: Alignment.centerLeft,
          padding: const EdgeInsets.only(bottom: 0, left: 10, right: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
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
                    const TextSpan(text: "Verification"),
                    textAlign: TextAlign.left,
                    style: GoogleFonts.ubuntu(
                      color: const Color.fromARGB(255, 54, 54, 54),
                      fontWeight: FontWeight.bold,
                      fontSize: 30,
                    ),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: () async {
                      value.toggleIsLoading();

                      await Future.wait([
                        value.getVerficationRequests(),
                        context
                            .read<HomeProviderFunctions>()
                            .loadDetailsToHive(context)
                      ]);

                      value.toggleIsLoading();
                    },
                    child: const Icon(
                      color: Colors.black,
                      Icons.refresh,
                      size: 30,
                    ),
                  ),
                  wGap(10),
                ],
              ),
              hGap(20),
              Container(
                width: width(context),
                alignment: Alignment.center,
                child: Container(
                  height: 50,
                  width: width(context) * 0.9,
                  decoration: tabWidgetDeco(),
                  alignment: Alignment.center,
                  padding: const EdgeInsets.all(5),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      GestureDetector(
                        onTap: () => value.changeCurrentPageIndex(0),
                        child: Container(
                          width: width(context) * 0.43,
                          color: value.returnCurrentPageIndex() == 1
                              ? Colors.transparent
                              : Colors.white,
                          alignment: Alignment.center,
                          child: Text(
                            "Upload Files",
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                              color: value.returnCurrentPageIndex() == 1
                                  ? Colors.grey[600]!
                                  : Colors.black,
                            ),
                          ),
                        ),
                      ),
                      wGap(5),
                      GestureDetector(
                        onTap: () => value.changeCurrentPageIndex(1),
                        child: Container(
                          width: width(context) * 0.43,
                          color: value.returnCurrentPageIndex() == 0
                              ? Colors.transparent
                              : Colors.white,
                          alignment: Alignment.center,
                          child: Text(
                            "Submissions",
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                              color: value.returnCurrentPageIndex() == 0
                                  ? Colors.grey[600]!
                                  : Colors.black,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      );
    },
  );
}

Widget kcyVerificationBody(BuildContext context) {
  return SizedBox(
    width: width(context),
    height: height(context),
    child: Stack(
      children: [
        body(context),
        customAppBar(context),
        floatingStatusBar(context),
      ],
    ),
  );
}

Widget body(BuildContext context) {
  return Consumer<KycProviderFunctions>(
    builder: (_, value, child) {
      return value.returnIsSubmittingFiles()
          ? uploadProgressLoadingPage(context)
          : value.returnVerificationRequests() == null ||
                  value.returnIsLoading()
              ? loadingScreenPlainNoBackButton(context)
              : value.returnCurrentPageIndex() == 0
                  ? value.returnCurrentVerificationStatus() == "Pending" ||
                          value.returnCurrentVerificationStatus() == "Approved"
                      ? verificationStatusWidget(context)
                      : uploadFilePage(context)
                  : submissionsListBuilder(context);
    },
  );
}

Widget uploadFilePage(BuildContext context) {
  return Container(
    width: width(context),
    height: height(context),
    alignment: Alignment.center,
    child: SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.only(top: 60, bottom: 40),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            "KYC Identity Verfication is required \nby Bank of Zambia for all Financial \nInstitutions.",
            textAlign: TextAlign.center,
            style: googleStyle(
              weight: FontWeight.w400,
              color: Colors.black,
              size: 15,
            ),
          ),
          hGap(20),
          selfieImageWidget(context),
          hGap(5),
          Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              documentImageWidget(context, 1),
              wGap(5),
              documentImageWidget(context, 2),
            ],
          ),
          hGap(20),
          documentTypeSelector(context),
          hGap(20),
          submitButtonWidget(context)
        ],
      ),
    ),
  );
}

Widget selfieImageWidget(BuildContext context) {
  return Consumer<KycProviderFunctions>(
    builder: (_, prov, child) {
      return GestureDetector(
        onTap: () async {
          if (Platform.isAndroid) {
            final androidInfo = await DeviceInfoPlugin().androidInfo;
            if (androidInfo.version.sdkInt <= 32) {
              await Permission.storage.request();

              if (await Permission.storage.request().isGranted) {
                prov.pickPhotoFromGallery(0);
              }
            } else {
              await Permission.photos.request();

              if (await Permission.photos.request().isGranted) {
                prov.pickPhotoFromGallery(0);
              }
            }

            return;
          }

          bool isGranted = await Permission.photos.request().isGranted ||
              await Permission.photos.request().isLimited;

          if (isGranted) {
            await Permission.photos.request();
          }

          // if running on iOS
          if (await Permission.photos.request().isGranted ||
              await Permission.photos.request().isLimited) {
            prov.pickPhotoFromGallery(0);
          }
        },
        child: Container(
          height: 120,
          width: width(context) * 0.86,
          decoration: selfieDeco(),
          alignment: Alignment.center,
          child: prov.returnSelfiePhoto() != null
              ? Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(30),
                      child: Image.file(
                        File(prov.returnSelfiePhoto()!.path),
                        width: double.infinity,
                        fit: BoxFit.cover,
                        height: 150,
                      ),
                    ),
                    Positioned(
                      top: 10,
                      right: 10,
                      child: GestureDetector(
                        onTap: () => prov.nullifyPhotoFile(0),
                        child: CircleAvatar(
                          radius: 15,
                          backgroundColor: Colors.red[400]!,
                          child: const Icon(
                            color: Colors.white,
                            Icons.remove,
                          ),
                        ),
                      ),
                    )
                  ],
                )
              : Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const CircleAvatar(
                        radius: 12,
                        backgroundColor: Colors.blue,
                        child: Icon(Icons.add, color: Colors.white),
                      ),
                      hGap(15),
                      Text(
                        "Upload a recent photo of you",
                        textAlign: TextAlign.center,
                        style: GoogleFonts.ubuntu(
                          fontWeight: FontWeight.w300,
                          color: Colors.black,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
        ),
      );
    },
  );
}

Widget documentImageWidget(BuildContext context, int image_index) {
  return Consumer<KycProviderFunctions>(
    builder: (_, prov, child) {
      return GestureDetector(
        onTap: () async {
          if (Platform.isAndroid) {
            final androidInfo = await DeviceInfoPlugin().androidInfo;
            if (androidInfo.version.sdkInt <= 32) {
              await Permission.storage.request();

              if (await Permission.storage.request().isGranted) {
                prov.pickPhotoFromGallery(image_index);
              }
            } else {
              await Permission.photos.request();

              if (await Permission.photos.request().isGranted) {
                prov.pickPhotoFromGallery(image_index);
              }
            }

            return;
          }

          bool isGranted = await Permission.photos.request().isGranted ||
              await Permission.photos.request().isLimited;

          if (isGranted) {
            await Permission.photos.request();
          }

          // if running on iOS
          if (await Permission.photos.request().isGranted ||
              await Permission.photos.request().isLimited) {
            prov.pickPhotoFromGallery(image_index);
          }
        },
        child: Container(
          height: 120,
          decoration: selfieDeco(),
          alignment: Alignment.center,
          width: width(context) * 0.425,
          child: prov.returnDocumentPhotos()[image_index - 1] != null
              ? Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(30),
                      child: Image.file(
                        File(
                            prov.returnDocumentPhotos()[image_index - 1]!.path),
                        width: width(context) * 0.425,
                        fit: BoxFit.cover,
                        height: 150,
                      ),
                    ),
                    Positioned(
                      top: 10,
                      right: 10,
                      child: GestureDetector(
                        onTap: () => prov.nullifyPhotoFile(image_index),
                        child: CircleAvatar(
                          radius: 15,
                          backgroundColor: Colors.red[400]!,
                          child: const Icon(
                            color: Colors.white,
                            Icons.remove,
                          ),
                        ),
                      ),
                    )
                  ],
                )
              : Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const CircleAvatar(
                        radius: 12,
                        backgroundColor: Colors.blue,
                        child: Icon(
                          Icons.add,
                          color: Colors.white,
                        ),
                      ),
                      hGap(15),
                      Text(
                        image_index == 1
                            ? "Upload the front side of the ID or NRC"
                            : "Upload the back side of the ID or NRC",
                        textAlign: TextAlign.center,
                        style: GoogleFonts.ubuntu(
                          fontWeight: FontWeight.w300,
                          color: Colors.black,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
        ),
      );
    },
  );
}

Widget verificationStatusWidget(BuildContext context) {
  return Consumer<KycProviderFunctions>(builder: (_, value, child) {
    return Container(
      width: width(context),
      height: height(context),
      alignment: Alignment.center,
      child: Container(
        alignment: Alignment.center,
        width: height(context) * 0.8,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.asset(
              value.returnCurrentVerificationStatus() == "Pending"
                  ? "assets/investigation.png"
                  : "assets/customer.png",
              height: 70,
            ),
            hGap(20),
            Text(
              value.returnCurrentVerificationStatus() == "Pending"
                  ? "KYC files are being reviewed.\nMay take upto 2 hours."
                  : "Your KYC files are approved",
              textAlign: TextAlign.center,
              style: googleStyle(
                weight: FontWeight.w400,
                color: Colors.black,
                size: 16,
              ),
            ),
          ],
        ),
      ),
    );
  });
}

Widget submitButtonWidget(BuildContext context) {
  return Consumer<KycProviderFunctions>(builder: (_, value, child) {
    return ElevatedButton(
      style: ButtonStyle(
        shape: MaterialStateProperty.all<RoundedRectangleBorder>(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25.0),
          ),
        ),
        backgroundColor: MaterialStateProperty.all(Colors.green),
      ),
      onPressed: () async {
        if (value.returnSelfiePhoto() == null) {
          showSnackBar(context, "Upload a recent selfie of you");
          return;
        }

        if (value.returnDocumentPhotos()[0] == null ||
            value.returnDocumentPhotos()[1] == null) {
          showSnackBar(context, "Upload a front & back side of the ID or NRC");
          return;
        }

        if (value.returnSelectedDocumentType().isEmpty) {
          showSnackBar(context, "Select a document ID type");
          return;
        }

        value.toggleIsSubmittingFile();

        // uploads & submits the files
        await value.submitKycFiles();

        await Future.wait([
          value.getVerficationRequests(),
          context.read<HomeProviderFunctions>().loadDetailsToHive(context)
        ]);

        value.toggleIsSubmittingFile();

        showSnackBar(context, "Files have been submitted for review",
            color: Colors.grey[600]!);

        changePage(context, const HomePage(), type: "pr");
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 9),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.upload, size: 18),
            wGap(5),
            Text(
              "Submit Files",
              style: GoogleFonts.ubuntu(
                color: Colors.white,
                fontSize: 15,
              ),
            ),
          ],
        ),
      ),
    );
  });
}

Widget floatingStatusBar(BuildContext context) {
  return Consumer<KycProviderFunctions>(builder: (_, value, child) {
    return value.returnIsLoading()
        ? nothing()
        : Positioned(
            bottom: 40,
            child: Container(
              width: width(context),
              alignment: Alignment.center,
              child: Container(
                height: 50,
                decoration: customDecor(),
                alignment: Alignment.center,
                width: width(context) * 0.8,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Verification Status:",
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 15,
                      ),
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          box("account_kyc_is_verified")
                              ? "Verified"
                              : "Not Verified",
                          style: TextStyle(
                            fontWeight: FontWeight.w400,
                            color: Colors.grey[800]!,
                            fontSize: 17,
                          ),
                        ),
                        const SizedBox(width: 5),
                        box("account_kyc_is_verified")
                            ? const Icon(
                                Icons.verified,
                                color: Colors.blue,
                                size: 17,
                              )
                            : const Icon(
                                Icons.verified,
                                color: Colors.red,
                                size: 17,
                              ),
                      ],
                    )
                  ],
                ),
              ),
            ),
          );
  });
}

Widget submissionsListBuilder(BuildContext context) {
  return Consumer<KycProviderFunctions>(
    builder: (_, value, child) {
      return value.returnVerificationRequests()!.isEmpty
          ? Center(
              child: Text(
                "No submissions made yet",
                style: googleStyle(color: Colors.black),
              ),
            )
          : SizedBox(
              width: width(context),
              height: height(context),
              child: RefreshIndicator(
                onRefresh: () async {
                  // plays refresh sound
                  await playSound('refresh.mp3');

                  await value.getVerficationRequests();
                },
                displacement: 140,
                child: MediaQuery.removePadding(
                  removeTop: true,
                  context: context,
                  removeBottom: true,
                  child: ListView.builder(
                    scrollDirection: Axis.vertical,
                    physics: const BouncingScrollPhysics(),
                    itemCount: value.returnVerificationRequests()!.length,
                    padding: const EdgeInsets.only(top: 130, bottom: 100),
                    itemBuilder: (_, index) {
                      Map ds = value.returnVerificationRequests()![index];
                      return submmissionTile(context, ds);
                    },
                  ),
                ),
              ),
            );
    },
  );
}

Widget submmissionTile(BuildContext context, Map submission_map) {
  return Container(
    width: width(context),
    alignment: Alignment.center,
    margin: const EdgeInsets.only(bottom: 20),
    child: Container(
      width: width(context) * 0.9,
      alignment: Alignment.center,
      decoration: submissionTileDeco(),
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text.rich(
            TextSpan(
              text: "",
              children: [
                TextSpan(
                  text: submission_map["status"] == 'Pending'
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
                image: submission_map["selfie_image_url"],
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
                    borderRadius: BorderRadius.circular(30),
                    child: CachedNetworkImage(
                      imageUrl: submission_map["selfie_image_url"],
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
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: () => changePage(
                  context,
                  ViewVerificationPhotoPage(
                    image: submission_map["document_photo_1_url"],
                  ),
                ),
                child: Container(
                  height: 150,
                  alignment: Alignment.center,
                  width: width(context) * 0.39,
                  decoration: submissionTileSelfieDeco(),
                  child: Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(30),
                        child: CachedNetworkImage(
                          imageUrl: submission_map["document_photo_1_url"],
                          width: width(context) * 0.425,
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
                    image: submission_map["document_photo_2_url"],
                  ),
                ),
                child: Container(
                  height: 150,
                  alignment: Alignment.center,
                  width: width(context) * 0.39,
                  decoration: submissionTileSelfieDeco(),
                  child: Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(30),
                        child: CachedNetworkImage(
                          imageUrl: submission_map["document_photo_2_url"],
                          width: width(context) * 0.425,
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
              borderRadius: BorderRadius.circular(20.0),
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
                          text: submission_map["comment"],
                          style: GoogleFonts.ubuntu(
                            fontWeight: FontWeight.w400,
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
  );
}

Widget documentTypeSelector(BuildContext context) {
  return Consumer<KycProviderFunctions>(builder: (_, value, child) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 40, right: 30),
          child: Text(
            "Select a document type",
            style: GoogleFonts.ubuntu(
                color: Colors.black87,
                fontSize: 15,
                fontWeight: FontWeight.w300),
          ),
        ),
        hGap(10),
        Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: width(context) * 0.84,
              height: height(context) * 0.054,
              alignment: Alignment.centerLeft,
              margin: const EdgeInsets.only(left: 30, right: 30),
              padding: const EdgeInsets.only(left: 20, top: 10, bottom: 10),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(20.0),
              ),
              child: Text(
                value.returnSelectedDocumentType(),
                textAlign: TextAlign.left,
                style: GoogleFonts.ubuntu(
                  color: Colors.black54,
                  fontSize: 18,
                ),
              ),
            ), //height
            Positioned(
              right: 60,
              child: DropdownButton<String>(
                dropdownColor: Colors.white,
                underline: const SizedBox(),
                items: <String>[
                  'National ID (NRC)',
                  "Drivers License",
                  "School ID",
                  "Passport"
                ].map(
                  (String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value, style: const TextStyle(fontSize: 15)),
                    );
                  },
                ).toList(),
                onChanged: (String? text) => value.changeDocumentType(text!),
              ),
            )
          ],
        ),
      ],
    );
  });
}

Widget uploadProgressLoadingPage(BuildContext context) {
  return Consumer<KycProviderFunctions>(builder: (_, value, child) {
    return Scaffold(
      body: Container(
        width: width(context),
        color: Colors.white,
        height: height(context),
        alignment: Alignment.center,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              height: 40,
              width: 40,
              child: CircularProgressIndicator(
                value: value.returnUploadProgress() / 100,
                backgroundColor: Colors.grey[200],
                color: Colors.green[600],
                strokeWidth: 3,
              ),
            ),
            hGap(20),
            Text(
              value.returnNumberOfFileUploaded() == 1
                  ? "(1 file uploaded - ${value.returnUploadProgress().toStringAsFixed(1)}%)"
                  : "(${value.returnNumberOfFileUploaded()} files uploaded - ${value.returnUploadProgress().toStringAsFixed(1)}%)",
              textAlign: TextAlign.center,
              style: googleStyle(color: Colors.grey[500]!, size: 18),
            ),
            hGap(10),
            Text(
              "KYC files are uploading.\nPlease wait...",
              textAlign: TextAlign.center,
              style: googleStyle(color: Colors.grey[900]!, size: 15),
            )
          ],
        ),
      ),
    );
  });
}

// =============== Styling widgets

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

Decoration selfieDeco() {
  return BoxDecoration(
    color: Colors.grey[200],
    borderRadius: BorderRadius.circular(30),
  );
}

Decoration tabWidgetDeco() {
  return BoxDecoration(
    color: Colors.grey[200],
    borderRadius: const BorderRadius.all(
      Radius.circular(5),
    ),
  );
}

Decoration customDecor() {
  return BoxDecoration(
    color: Colors.white,
    boxShadow: [
      BoxShadow(
        color: Colors.grey.withOpacity(0.5),
        spreadRadius: 1,
        blurRadius: 7,
        offset: const Offset(0, 3),
      ),
    ],
    borderRadius: const BorderRadius.all(
      Radius.circular(50),
    ),
  );
}

Decoration appBarDeco() {
  return const BoxDecoration(
    color: Colors.white,
  );
}
