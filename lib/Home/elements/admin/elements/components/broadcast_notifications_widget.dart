// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:jayben/Home/home_page.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:jayben/Utilities/general_widgets.dart';
import 'package:jayben/Utilities/provider_functions.dart';

Widget floatingButton(BuildContext context, Map notificationBody) {
  return Consumer<AdminProviderFunctions>(
    builder: (_, value, child) {
      return FloatingActionButton.extended(
        onPressed: () async {
          if (value.returnIsLoading()) return;

          hideKeyboard();

          // if some boxes are empty
          if (notificationBody['descController'].text.isEmpty ||
              notificationBody['titleController'].text.isEmpty) {
            showSnackBar(context, "Enter a title & body");
            return;
          }

          // tells user notification has sent
          showSnackBar(context, 'Notification is being sent',
              color: Colors.green);

          // routes user back to home page
          changePage(context, const HomePage(), type: "pr");

          await sendNotificationsAllUsers({
            "title": notificationBody["titleController"].text,
            "body": notificationBody["descController"].text,
          });
        },
        backgroundColor: Colors.green,
        label: value.returnIsLoading()
            ? loadingIcon(context)
            : Text(
                "SEND",
                style: GoogleFonts.ubuntu(
                  fontWeight: FontWeight.w400,
                  fontSize: 17,
                ),
              ),
      );
    },
  );
}

Widget createNotificationBody(BuildContext context, Map notificationBody) {
  return Stack(
    children: [
      GestureDetector(
        onTap: () => hideKeyboard(),
        child: Container(
          width: width(context),
          height: height(context),
          alignment: Alignment.center,
          child: ListView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.only(top: 150, bottom: 50),
            children: [
              Text(
                "Send Notification",
                textAlign: TextAlign.center,
                style: GoogleFonts.ubuntu(
                  fontWeight: FontWeight.w500,
                  color: Colors.black,
                  fontSize: 30,
                ),
              ),
              const SizedBox(height: 15),
              Text(
                "Will be sent all Jayben users",
                textAlign: TextAlign.center,
                style: GoogleFonts.ubuntu(
                  fontWeight: FontWeight.w300,
                  color: Colors.orange[600],
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 40),
              textField({
                "hintText": "Title",
                "context": context,
                "labelText": "Notification Title",
                "controller": notificationBody['titleController'],
              }),
              const SizedBox(height: 20),
              textField({
                "context": context,
                "hintText": "Body",
                "labelText": "Notification Body",
                "controller": notificationBody['descController'],
              }),
            ],
          ),
        ),
      ),
      backButton(context)
    ],
  );
}

Widget textField(Map textfieldInfo) {
  return Container(
    alignment: Alignment.center,
    width: width(textfieldInfo['context']),
    padding: const EdgeInsets.symmetric(horizontal: 30),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          textfieldInfo['labelText'],
          style: GoogleFonts.ubuntu(
              color: Colors.black, fontSize: 15, fontWeight: FontWeight.w300),
        ),
        const SizedBox(height: 10),
        TextField(
          minLines: 1,
          cursorHeight: 24,
          textAlign: TextAlign.left,
          style: GoogleFonts.ubuntu(
            color: Colors.black,
            fontSize: 24,
          ),
          cursorColor: Colors.grey[400],
          keyboardType: TextInputType.text,
          controller: textfieldInfo['controller'],
          inputFormatters: [
            LengthLimitingTextInputFormatter(
                textfieldInfo['labelText'] == "Title" ? 30 : 200),
          ],
          maxLines: textfieldInfo['labelText'] == "Title" ? 2 : 10,
          decoration: InputDecoration(
            hintText: textfieldInfo['hintText'],
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
              color: Colors.black38,
              fontSize: 24,
            ),
          ),
        ),
      ],
    ),
  );
}

// ================ styling widgets

Decoration newsletterTileDeco() {
  return BoxDecoration(
      color: Colors.grey[200], borderRadius: BorderRadius.circular(30));
}
