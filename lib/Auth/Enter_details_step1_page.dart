import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:country_pickers/country.dart';
import 'package:country_pickers/country_pickers.dart';
import 'package:jayben/Utilities/provider_functions.dart';
import 'package:jayben/Auth/elements/birth_date_confirm_dialogue.dart';

import 'components/enter_details_step1_page_widgets.dart';

class EnterDetailsStep1Page extends StatefulWidget {
  const EnterDetailsStep1Page({Key? key}) : super(key: key);

  @override
  State<EnterDetailsStep1Page> createState() => _EnterDetailsStep1PageState();
}

class _EnterDetailsStep1PageState extends State<EnterDetailsStep1Page> {
  final phoneNumberController = TextEditingController();
  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final usernameController = TextEditingController();
  final addressController = TextEditingController();
  final countryController = TextEditingController();
  final cityController = TextEditingController();
  DateTime selectedDate = DateTime(2004, 1);
  String selectedCountryISOCode = "";
  String selectedCountry = "";
  String accountType = "";
  String countryCode = "";
  String selectedSex = "";
  String dob = "";
  String yob = "";

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProviderFunctions>(
      builder: (_, value, child) {
        return Scaffold(
          backgroundColor: Colors.white,
          floatingActionButton: floatingActionButtonWidget(() async {
            if (value.returnIsLoading()) return;

            hideKeyboard();

            if (dob.isEmpty ||
                selectedSex.isEmpty ||
                accountType.isEmpty ||
                selectedCountry.isEmpty ||
                cityController.text.isEmpty ||
                addressController.text.isEmpty ||
                usernameController.text.isEmpty ||
                lastNameController.text.isEmpty ||
                firstNameController.text.isEmpty ||
                phoneNumberController.text.isEmpty) {
              showSnackBar(context, "Enter all the boxes");

              return;
            }

            if (phoneNumberController.text.length < 10) {
              showSnackBar(context, "Enter a valid Zambian Phone Number");

              return;
            }

            value.toggleIsLoading();

            // checks if the username entered by user exists
            bool isUsernameValid = await value
                .checkIfUsernameExists(usernameController.text.trim());
            // returns a bool value

            // checks if the phone number entered by user exists
            bool isPhoneNumberValid = await value.checkIfPhoneNumberAlreadyExists(
                "+${countryCode.replaceAll("0", "")}${phoneNumberController.text.trim()}");
            // returns a bool value

            value.toggleIsLoading();

            // if the username has been used already
            if (!isUsernameValid) {
              showSnackBar(context,
                  "Username has been taken. Please use another username");

              return;
            }

            // if the phone number has been used already
            if (!isPhoneNumberValid) {
              showSnackBar(context,
                  "Phone number has been taken. Please use another number");

              return;
            }

            showDialogue(
              context,
              BirthDateConfirm(
                account_details_map: {
                  "dob": dob,
                  "gender": selectedSex,
                  "countryCode": countryCode,
                  "accountType": accountType,
                  "dateOfBirth": selectedDate,
                  "city": cityController.text,
                  "address": addressController.text,
                  "selectedCountry": selectedCountry,
                  "username": usernameController.text,
                  "lastName": lastNameController.text,
                  "firstName": firstNameController.text,
                  "selectedCountryISOCode": selectedCountryISOCode,
                  "phoneNumber": "+${countryCode.replaceAll("0", "")}"
                      "${phoneNumberController.text.trim()}",
                  "onDateConfirm": () async {
                    showModalBottomSheet(
                      enableDrag: false,
                      context: context,
                      builder: (_) {
                        return SizedBox(
                          height: height(context) * 0.3,
                          child: CupertinoDatePicker(
                            backgroundColor: Colors.transparent,
                            initialDateTime: DateTime.now(),
                            mode: CupertinoDatePickerMode.date,
                            use24hFormat: true,
                            onDateTimeChanged: (DateTime picked) {
                              if (picked != selectedDate) {
                                setState(() {
                                  selectedDate = picked;
                                  DateFormat formatShowUser =
                                      DateFormat("d MMMM, yyyy");
                                  dob = formatShowUser.format(selectedDate);
                                });
                              }
                            },
                          ),
                        );
                      },
                    );
                  }
                },
              ),
            );
          }),
          body: SafeArea(
            bottom: false,
            child: Stack(
              children: [
                GestureDetector(
                  onTap: () => hideKeyboard(),
                  child: Container(
                    width: width(context),
                    height: height(context),
                    color: Colors.transparent,
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.only(top: 70, bottom: 120),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          stepCounterWidget(),
                          hGap(10),
                          enterDetialsText(),
                          hGap(10),
                          requiredTextWidget(),
                          hGap(30),
                          accountTypeWidget(context, accountType,
                              (value) => setState(() => accountType = value!)),
                          hGap(30),
                          usernameTextfield(usernameController),
                          hGap(20),
                          firstNameTextField(firstNameController),
                          hGap(30),
                          lastNameTextField(lastNameController),
                          hGap(30),
                          phoneNumberTextField(phoneNumberController),
                          hGap(30),
                          birthDayWidget(dob, () async {
                            showModalBottomSheet(
                              enableDrag: false,
                              context: context,
                              builder: (_) {
                                return SizedBox(
                                  height: height(context) * 0.3,
                                  child: CupertinoDatePicker(
                                    backgroundColor: Colors.transparent,
                                    initialDateTime: DateTime.now(),
                                    mode: CupertinoDatePickerMode.date,
                                    use24hFormat: true,
                                    onDateTimeChanged: (DateTime picked) {
                                      if (picked != selectedDate) {
                                        setState(() {
                                          selectedDate = picked;
                                          DateFormat formatShowUser =
                                              DateFormat("d MMMM, yyyy");
                                          dob = formatShowUser
                                              .format(selectedDate);
                                        });
                                      }
                                    },
                                  ),
                                );
                              },
                            );
                          }),
                          hGap(30),
                          genderSelector(context, selectedSex,
                              (value) => setState(() => selectedSex = value!)),
                          hGap(30),
                          addressTextField(addressController),
                          hGap(30),
                          cityTextField(cityController),
                          hGap(30),
                          countryWidget(
                            selectedCountry,
                            () {
                              showCupertinoModalPopup<void>(
                                context: context,
                                builder: (_) {
                                  return CountryPickerCupertino(
                                    pickerSheetHeight: 250.0,
                                    backgroundColor: Colors.white,
                                    onValuePicked: (Country country) {
                                      setState(() {
                                        selectedCountry = country.name;
                                        countryCode = country.phoneCode;
                                        selectedCountryISOCode =
                                            country.isoCode;
                                      });
                                    },
                                    priorityList: [
                                      CountryPickerUtils.getCountryByIsoCode(
                                          'ZA'),
                                      CountryPickerUtils.getCountryByIsoCode(
                                          'ZM'),
                                      CountryPickerUtils.getCountryByIsoCode(
                                          'NG'),
                                      CountryPickerUtils.getCountryByIsoCode(
                                          'KE'),
                                      CountryPickerUtils.getCountryByIsoCode(
                                          'US'),
                                      CountryPickerUtils.getCountryByIsoCode(
                                          'GB'),
                                    ],
                                  );
                                },
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                customAppBar(context)
              ],
            ),
          ),
        );
      },
    );
  }
}
