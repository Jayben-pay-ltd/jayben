import 'package:cached_network_image/cached_network_image.dart';
import 'package:jayben/Utilities/constants.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:jayben/Utilities/provider_functions.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:io';

Widget customAppBar(BuildContext context, Function() onSaveChanges) {
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
            const TextSpan(text: "Profile"),
            textAlign: TextAlign.left,
            style: GoogleFonts.ubuntu(
              color: const Color.fromARGB(255, 54, 54, 54),
              fontWeight: FontWeight.bold,
              fontSize: 30,
            ),
          ),
          const Spacer(),
          GestureDetector(
            onTap: onSaveChanges,
            child: const SizedBox(
              child: Text(
                "SAVE",
                style: TextStyle(
                  color: Colors.green,
                  fontSize: 17,
                ),
              ),
            ),
          ),
          wGap(10),
        ],
      ),
    ),
  );
}

Widget profileBody(BuildContext context, File? image, Function() getImage,
    Function() onSaveChanges) {
  return SizedBox(
    width: width(context),
    height: height(context),
    child: Stack(
      children: [
        ListView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.only(top: 70, bottom: 130),
          shrinkWrap: true,
          children: [
            profileImageWidget(image, getImage),
            const SizedBox(height: 10),
            Divider(color: Colors.grey[300], thickness: 0.5),
            const SizedBox(height: 15),
            textField(context, "@${box('Username_searchable')}",
                'Username (also your referral code)', true),
            const SizedBox(height: 30),
            textField(context, box('PhoneNumber'), 'Phone Number', true),
            const SizedBox(height: 30),
            textField(context, box('FirstName'), 'First Name', true),
            const SizedBox(height: 30),
            textField(context, box('LastName'), 'Last Name', true),
            const SizedBox(height: 30),
            textField(context, box('Email'), 'Email', true),
            const SizedBox(height: 30),
            textField(context, box('Address'), 'Address', true),
            const SizedBox(height: 30),
            textField(context, box('Gender'), 'Gender', true),
            const SizedBox(height: 30),
            textField(context, box('Country'), 'Country', true),
            const SizedBox(height: 30),
            textField(context, box('City'), 'City', true),
          ],
        ),
        customAppBar(context, onSaveChanges)
      ],
    ),
  );
}

Widget profileImageWidget(File? image, Function() getImage) {
  return GestureDetector(
    onTap: () async {
      if (Platform.isAndroid) {
        final androidInfo = await DeviceInfoPlugin().androidInfo;
        if (androidInfo.version.sdkInt <= 32) {
          await Permission.storage.request();

          if (await Permission.storage.request().isGranted) {
            getImage();
          }
        } else {
          await Permission.photos.request();

          if (await Permission.photos.request().isGranted) {
            getImage();
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
        getImage();
      }
    },
    child: Container(
      padding: const EdgeInsets.only(left: 20, bottom: 0, right: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Stack(
            children: [
              image != null
                  ? CircleAvatar(
                      radius: 40,
                      backgroundColor: Colors.grey[200],
                      backgroundImage: FileImage(
                        File(image.path),
                      ),
                    )
                  : box("profile_image_url") == ""
                      ? const CircleAvatar(
                          radius: 40,
                          backgroundColor: Colors.transparent,
                          backgroundImage: AssetImage(
                            "assets/ProfileAvatar.png",
                          ),
                        )
                      : CircleAvatar(
                          radius: 40,
                          backgroundColor: Colors.grey[200],
                          backgroundImage: CachedNetworkImageProvider(
                            box(
                              "profile_image_url",
                            ),
                          ),
                        ),
              const Positioned(
                bottom: 0,
                left: 0,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    CircleAvatar(
                      radius: 15,
                      backgroundColor: Colors.white,
                    ),
                    CircleAvatar(
                      radius: 13,
                      backgroundColor: Colors.blue,
                      child: Icon(
                        Icons.add,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(width: 30),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Tap here to change profile photo",
                style: GoogleFonts.ubuntu(
                  fontWeight: FontWeight.w300,
                  color: Colors.black54,
                  fontSize: 17,
                ),
              )
            ],
          )
        ],
      ),
    ),
  );
}

Widget uploadProgressLoadingPage(BuildContext context) {
  return Consumer<UserProviderFunctions>(builder: (_, value, child) {
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
              "(Image uploading - ${value.returnUploadProgress().toStringAsFixed(1)}%)",
              textAlign: TextAlign.center,
              style: googleStyle(color: Colors.grey[500]!, size: 18),
            ),
            hGap(10),
            const Text(
              "Please wait patiently...",
              textAlign: TextAlign.center,
            )
          ],
        ),
      ),
    );
  });
}

Widget textField(BuildContext context, hintText, labelText, readOnly) {
  return Container(
    width: width(context),
    alignment: Alignment.center,
    padding: const EdgeInsets.symmetric(horizontal: 30),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          labelText,
          style: GoogleFonts.ubuntu(
              color: Colors.black87, fontSize: 15, fontWeight: FontWeight.w300),
        ),
        hGap(10),
        Stack(
          children: [
            TextField(
              cursorHeight: 24,
              readOnly: readOnly,
              cursorColor: Colors.grey[400],
              maxLines: 1,
              onTap: () async {
                if (labelText == "Username (also your referral code)") {
                  await Clipboard.setData(
                      ClipboardData(text: box('Username_searchable')));

                  showSnackBar(context, "Username has been copied!",
                      color: Colors.green[600]!);
                  return;
                }

                showSnackBar(context, "can't be edited");
              },
              keyboardType: TextInputType.text,
              inputFormatters: [
                LengthLimitingTextInputFormatter(50),
                FilteringTextInputFormatter.allow(RegExp("[a-zA-Z]")),
                FilteringTextInputFormatter.deny(RegExp(r"\s\b|\b\s"))
              ],
              textAlign: TextAlign.left,
              style: GoogleFonts.ubuntu(
                fontSize: 24,
                color: Colors.grey[600],
                fontWeight: FontWeight.w300,
              ),
              decoration: InputDecoration(
                hintText: hintText.isEmpty ? "Empty" : hintText,
                isDense: true,
                filled: true,
                fillColor: Colors.grey[200],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20.0),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20.0),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20.0),
                  borderSide: BorderSide.none,
                ),
                disabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20.0),
                  borderSide: BorderSide.none,
                ),
                hintStyle: GoogleFonts.ubuntu(
                  fontSize: 24,
                  color: readOnly == false ? Colors.black : Colors.grey[500],
                ),
              ),
            ),
            labelText == "Username (also your referral code)"
                ? Positioned(
                    right: 17,
                    top: 16,
                    child: GestureDetector(
                      onTap: () async {
                        await Clipboard.setData(
                            ClipboardData(text: box('Username_searchable')));

                        showSnackBar(context, "Username has been copied!",
                            color: Colors.green[600]!);
                      },
                      child: Icon(
                        Icons.copy,
                        color: Colors.grey[500],
                      ),
                    ),
                  )
                : nothing()
          ],
        ),
      ],
    ),
  );
}

// ================ styling widgets

Decoration appBarDeco() {
  return BoxDecoration(
    color: Colors.white,
    border: Border(
      bottom: BorderSide(
        color: Colors.grey[200]!,
        width: 0.5,
      ),
    ),
  );
}
