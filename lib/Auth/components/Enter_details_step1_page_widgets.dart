import '../../Home/elements/drawer/elements/components/ProfileWidgets.dart';
import 'package:jayben/Utilities/provider_functions.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../Utilities/Constants.dart';
import '../../Utilities/general_widgets.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

Widget enterDetialsText() {
  return Text(
    "Enter your details",
    textAlign: TextAlign.center,
    style: GoogleFonts.ubuntu(
      fontWeight: FontWeight.w600,
      color: Colors.grey[800],
      fontSize: 25,
    ),
  );
}

Widget stepCounterWidget() {
  return Text(
    "Step 1 of 2",
    textAlign: TextAlign.center,
    style: GoogleFonts.ubuntu(
      fontWeight: FontWeight.w400,
      color: Colors.green[400],
      fontSize: 20,
    ),
  );
}

Widget requiredTextWidget() {
  return Text(
    "(all fields are required)",
    textAlign: TextAlign.center,
    style: GoogleFonts.ubuntu(
      fontWeight: FontWeight.w200,
      color: Colors.black,
      fontSize: 15,
    ),
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
            const TextSpan(text: "Create Account"),
            textAlign: TextAlign.left,
            style: GoogleFonts.ubuntu(
              color: const Color.fromARGB(255, 54, 54, 54),
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
          const Spacer(),
          wGap(50),
        ],
      ),
    ),
  );
}

Widget instructionText(text1, text2) {
  return Container(
    padding: const EdgeInsets.only(left: 20),
    child: Text.rich(
      TextSpan(
        children: [
          TextSpan(
            text: text1,
            style: GoogleFonts.ubuntu(
              fontWeight: FontWeight.bold,
              color: iconColor,
              fontSize: 26,
            ),
          ),
          TextSpan(
            text: '\n$text2',
            style: GoogleFonts.ubuntu(
              fontWeight: FontWeight.bold,
              color: Colors.green[400],
              fontSize: 26,
            ),
          ),
        ],
      ),
      textAlign: TextAlign.left,
    ),
  );
}

Widget floatingActionButtonWidget(onFinish) {
  return Consumer<AuthProviderFunctions>(
    builder: (context, value, child) {
      return FloatingActionButton.extended(
        onPressed: value.returnIsLoading() ? null : onFinish,
        backgroundColor: Colors.green,
        label: value.returnIsLoading()
            ? loadingIcon(context)
            : Text(
                "NEXT",
                style: GoogleFonts.ubuntu(
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                  fontSize: 20,
                ),
              ),
      );
    },
  );
}

Widget authBackButton(BuildContext context) {
  return Positioned(
    top: 62.5,
    left: 20,
    child: GestureDetector(
      onTap: () => goBack(context),
      child: CircleAvatar(
        radius: 30,
        backgroundColor: Colors.grey[200],
        child: SizedBox(
          child: Icon(
            color: Colors.grey[700],
            Icons.arrow_back,
            size: 40,
          ),
        ),
      ),
    ),
  );
}

Widget merchantHintText(BuildContext context) {
  return Padding(
    padding: const EdgeInsets.only(left: 20.0),
    child: Text(
      '*Merchant is only for businesses.',
      style: GoogleFonts.ubuntu(
        color: Colors.grey[600],
        fontSize: 14,
      ),
    ),
  );
}

Widget accountTypeWidget(context, String selectedType, onTypeSeleted) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Padding(
        padding: const EdgeInsets.only(left: 30, right: 30),
        child: Text(
          "Account Type*",
          style: GoogleFonts.ubuntu(
              color: Colors.black87, fontSize: 15, fontWeight: FontWeight.w300),
        ),
      ),
      hGap(10),
      Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: width(context),
            height: height(context) * 0.064,
            alignment: Alignment.centerLeft,
            margin: const EdgeInsets.only(left: 30, right: 30),
            padding: const EdgeInsets.only(left: 10, top: 10, bottom: 5),
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(20.0),
            ),
            child: Text(
              selectedType.isEmpty ? 'Account Type' : selectedType,
              textAlign: TextAlign.left,
              style: GoogleFonts.ubuntu(
                color:
                    selectedType.isNotEmpty ? Colors.black : Colors.grey[500],
                fontSize: 24,
              ),
            ),
          ), //height
          Positioned(
            right: 60,
            child: DropdownButton<String>(
              dropdownColor: Colors.white,
              underline: const SizedBox(),
              items: <String>[
                "Personal",
                // "Agent",
                // "Merchant",
              ].map(
                (String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value, style: const TextStyle(fontSize: 24)),
                  );
                },
              ).toList(),
              onChanged: onTypeSeleted,
            ),
          )
        ],
      ),
    ],
  );
}

Widget usernameTextfield(TextEditingController controller) {
  return Padding(
    padding: const EdgeInsets.only(left: 30, right: 30),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Username* (nickname)",
          style: GoogleFonts.ubuntu(
              color: Colors.black87, fontSize: 15, fontWeight: FontWeight.w300),
        ),
        hGap(10),
        TextField(
          cursorHeight: 24,
          cursorColor: Colors.grey[700],
          maxLines: 1,
          autocorrect: false,
          enableSuggestions: false,
          textCapitalization: TextCapitalization.none,
          controller: controller,
          keyboardType: TextInputType.text,
          inputFormatters: [
            LengthLimitingTextInputFormatter(20),
            FilteringTextInputFormatter.allow(RegExp("[0-9a-zA-Z]")),
            FilteringTextInputFormatter.deny(RegExp(r"\s\b|\b\s"))
          ],
          textAlign: TextAlign.left,
          style: GoogleFonts.ubuntu(
            fontSize: 24,
            color: Colors.black,
          ),
          decoration: InputDecoration(
            hintText: "Username",
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
              color: Colors.grey[500],
            ),
          ),
        ),
      ],
    ),
  );
}

Widget phoneNumberTextField(controller) {
  return Padding(
    padding: const EdgeInsets.only(left: 30, right: 30),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Phone Number* (must be 10 digits)",
          style: GoogleFonts.ubuntu(
              color: Colors.black87, fontSize: 15, fontWeight: FontWeight.w300),
        ),
        hGap(10),
        TextField(
          cursorHeight: 24,
          cursorColor: iconColor,
          maxLines: 1,
          textCapitalization: TextCapitalization.words,
          controller: controller,
          autocorrect: false,
          enableSuggestions: false,
          keyboardType: TextInputType.number,
          inputFormatters: [
            LengthLimitingTextInputFormatter(10),
          ],
          textAlign: TextAlign.left,
          style: const TextStyle(
            fontSize: 24,
            color: Colors.black,
          ),
          decoration: InputDecoration(
            hintText: 'Phone number',
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
              color: Colors.grey[500],
            ),
          ),
        ),
      ],
    ),
  );
}

Widget firstNameTextField(controller) {
  return Padding(
    padding: const EdgeInsets.only(left: 30, right: 30),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "First Name*",
          style: GoogleFonts.ubuntu(
              color: Colors.black87, fontSize: 15, fontWeight: FontWeight.w300),
        ),
        hGap(10),
        TextField(
          cursorHeight: 24,
          cursorColor: iconColor,
          maxLines: 1,
          textCapitalization: TextCapitalization.words,
          controller: controller,
          autocorrect: false,
          enableSuggestions: false,
          keyboardType: TextInputType.text,
          inputFormatters: [
            LengthLimitingTextInputFormatter(20),
            FilteringTextInputFormatter.allow(RegExp("[a-zA-Z]")),
            FilteringTextInputFormatter.deny(RegExp(r"\s\b|\b\s"))
          ],
          textAlign: TextAlign.left,
          style: const TextStyle(
            fontSize: 24,
            color: Colors.black,
          ),
          decoration: InputDecoration(
            hintText: 'First name',
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
              color: Colors.grey[500],
            ),
          ),
        ),
      ],
    ),
  );
}

Widget lastNameTextField(controller) {
  return Padding(
    padding: const EdgeInsets.only(left: 30, right: 30),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Last Name*",
          style: GoogleFonts.ubuntu(
              color: Colors.black87, fontSize: 15, fontWeight: FontWeight.w300),
        ),
        hGap(10),
        TextField(
          cursorHeight: 24,
          cursorColor: iconColor,
          maxLines: 1,
          autocorrect: false,
          enableSuggestions: false,
          textCapitalization: TextCapitalization.words,
          controller: controller,
          keyboardType: TextInputType.text,
          inputFormatters: [
            LengthLimitingTextInputFormatter(20),
            FilteringTextInputFormatter.allow(RegExp("[a-zA-Z]")),
            FilteringTextInputFormatter.deny(RegExp(r"\s\b|\b\s"))
          ],
          textAlign: TextAlign.left,
          style: const TextStyle(
            fontSize: 24,
            color: Colors.black,
          ),
          decoration: InputDecoration(
            hintText: 'Last name',
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
              color: Colors.grey[500],
            ),
          ),
        ),
      ],
    ),
  );
}

Widget addressTextField(controller) {
  return Padding(
    padding: const EdgeInsets.only(left: 30, right: 30),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Physical Address*",
          style: GoogleFonts.ubuntu(
              color: Colors.black87, fontSize: 15, fontWeight: FontWeight.w300),
        ),
        hGap(10),
        TextField(
          cursorHeight: 24,
          cursorColor: iconColor,
          maxLines: 1,
          autocorrect: false,
          enableSuggestions: false,
          textCapitalization: TextCapitalization.words,
          controller: controller,
          keyboardType: TextInputType.text,
          inputFormatters: [
            LengthLimitingTextInputFormatter(200),
          ],
          textAlign: TextAlign.left,
          style: const TextStyle(
            fontSize: 24,
            color: Colors.black,
          ),
          decoration: InputDecoration(
            hintText: 'Physical Address',
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
              color: Colors.grey[500],
            ),
          ),
        ),
      ],
    ),
  );
}

Widget cityTextField(controller) {
  return Padding(
    padding: const EdgeInsets.only(left: 30, right: 30),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "City*",
          style: GoogleFonts.ubuntu(
              color: Colors.black87, fontSize: 15, fontWeight: FontWeight.w300,),
        ),
        hGap(10),
        TextField(
          cursorHeight: 24,
          cursorColor: iconColor,
          maxLines: 1,
          autocorrect: false,
          enableSuggestions: false,
          textCapitalization: TextCapitalization.words,
          controller: controller,
          keyboardType: TextInputType.text,
          inputFormatters: [
            LengthLimitingTextInputFormatter(50),
            FilteringTextInputFormatter.allow(RegExp("[a-zA-Z]")),
            FilteringTextInputFormatter.deny(RegExp(r"\s\b|\b\s"))
          ],
          textAlign: TextAlign.left,
          style: const TextStyle(
            fontSize: 24,
            color: Colors.black,
          ),
          decoration: InputDecoration(
            hintText: 'City',
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
              color: Colors.grey[500],
            ),
          ),
        ),
      ],
    ),
  );
}

Widget countryWidget(String selectedCountry, selectCountry) {
  return Padding(
    padding: const EdgeInsets.only(left: 30, right: 30),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Country*",
          style: GoogleFonts.ubuntu(
              color: Colors.black87, fontSize: 15, fontWeight: FontWeight.w300),
        ),
        hGap(10),
        TextField(
          onTap: selectCountry,
          readOnly: true,
          maxLines: 1,
          autocorrect: false,
          enableSuggestions: false,
          textCapitalization: TextCapitalization.words,
          keyboardType: TextInputType.phone,
          inputFormatters: [
            LengthLimitingTextInputFormatter(10),
            FilteringTextInputFormatter.deny(RegExp(r"\s\b|\b\s"))
          ],
          textAlign: TextAlign.left,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.white,
          ),
          decoration: InputDecoration(
            hintText: selectedCountry.isNotEmpty ? selectedCountry : "Country",
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
              color:
                  selectedCountry.isNotEmpty ? Colors.black : Colors.grey[500],
              fontSize: 24,
            ),
          ),
        ),
      ],
    ),
  );
}

Widget birthDayWidget(String dob, selectDate) {
  return Padding(
    padding: const EdgeInsets.only(left: 30, right: 30),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Birthday* (confirm before proceeding)",
          style: GoogleFonts.ubuntu(
              color: Colors.black87, fontSize: 15, fontWeight: FontWeight.w300),
        ),
        hGap(10),
        TextField(
          onTap: selectDate,
          readOnly: true,
          maxLines: 1,
          autocorrect: false,
          enableSuggestions: false,
          textCapitalization: TextCapitalization.words,
          keyboardType: TextInputType.phone,
          inputFormatters: [
            LengthLimitingTextInputFormatter(10),
            FilteringTextInputFormatter.deny(RegExp(r"\s\b|\b\s"))
          ],
          textAlign: TextAlign.left,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.black,
          ),
          decoration: InputDecoration(
            isDense: true,
            filled: true,
            fillColor: Colors.grey[200],
            hintText: dob.isNotEmpty ? dob : "Birthday",
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
              color: dob.isNotEmpty ? Colors.black : Colors.grey[500],
              fontSize: 24,
            ),
          ),
        ),
      ],
    ),
  );
}

Widget genderSelector(context, String selectedSex, onGenderSeleted) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Padding(
        padding: const EdgeInsets.only(left: 30, right: 30),
        child: Text(
          "Gender*",
          style: GoogleFonts.ubuntu(
              color: Colors.black87, fontSize: 15, fontWeight: FontWeight.w300),
        ),
      ),
      hGap(10),
      Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: width(context),
            height: height(context) * 0.064,
            alignment: Alignment.centerLeft,
            margin: const EdgeInsets.only(left: 30, right: 30),
            padding: const EdgeInsets.only(left: 10, top: 10, bottom: 5),
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(20.0),
            ),
            child: Text(
              selectedSex.isEmpty ? 'Gender' : selectedSex,
              textAlign: TextAlign.left,
              style: GoogleFonts.ubuntu(
                color: selectedSex.isNotEmpty ? Colors.black : Colors.grey[500],
                fontSize: 24,
              ),
            ),
          ), //height
          Positioned(
            right: 60,
            child: DropdownButton<String>(
              dropdownColor: Colors.white,
              underline: const SizedBox(),
              items: <String>['Male', "Female"].map(
                (String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value, style: const TextStyle(fontSize: 24)),
                  );
                },
              ).toList(),
              onChanged: onGenderSeleted,
            ),
          )
        ],
      ),
    ],
  );
}
