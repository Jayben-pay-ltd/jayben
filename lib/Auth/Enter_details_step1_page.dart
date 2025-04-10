// ignore_for_file: non_constant_identifier_names

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
  final phone_number_controller = TextEditingController();
  final first_name_controller = TextEditingController();
  final last_name_controller = TextEditingController();
  final username_controller = TextEditingController();
  final address_controller = TextEditingController();
  final countryController = TextEditingController();
  final city_controller = TextEditingController();
  DateTime selected_date = DateTime(2004, 1);
  String selected_country_iso_code = "";
  String selected_country = "";
  String account_type = "";
  String country_code = "";
  String selected_sex = "";
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
                selected_sex.isEmpty ||
                account_type.isEmpty ||
                selected_country.isEmpty ||
                city_controller.text.isEmpty ||
                address_controller.text.isEmpty ||
                username_controller.text.isEmpty ||
                last_name_controller.text.isEmpty ||
                first_name_controller.text.isEmpty ||
                phone_number_controller.text.isEmpty) {
              showSnackBar(context, "Enter all the boxes");

              return;
            }

            if (phone_number_controller.text.length < 10) {
              showSnackBar(context, "Enter a valid Zambian Phone Number");

              return;
            }

            value.toggleIsLoading();

            // checks if the username entered by user exists
            bool? is_username_valid = await value.checkIfUsernameExists(
                username_controller.text.trim().toLowerCase());
            // returns a bool value

            // checks if the phone number entered by user exists
            bool is_phone_number_valid =
                await value.checkIfPhoneNumberAlreadyExists(
                    "+${country_code.replaceAll("0", "")}${phone_number_controller.text.trim()}");
            // returns a bool value

            value.toggleIsLoading();

            // if the username has been used already
            if (!is_username_valid!) {
              showSnackBar(context,
                  "Username has been taken. Please use another username");

              return;
            }

            // if the phone number has been used already
            if (!is_phone_number_valid) {
              showSnackBar(context,
                  "Phone number has been taken. Please use another number");

              return;
            }

            showDialogue(
              context,
              BirthDateConfirm(
                account_details_map: {
                  "dob": dob,
                  "gender": selected_sex,
                  "country_code": country_code,
                  "account_type": account_type,
                  "city": city_controller.text,
                  "address": address_controller.text,
                  "selected_country": selected_country,
                  "username": username_controller.text,
                  "last_name": last_name_controller.text,
                  "first_name": first_name_controller.text,
                  "date_of_birth": selected_date.toIso8601String(),
                  "selected_country_iso_code": selected_country_iso_code,
                  "phone_number": "+${country_code.replaceAll("0", "")}"
                      "${phone_number_controller.text.trim()}",
                  "on_date_confirm": () async {
                    showModalBottomSheet(
                      enableDrag: false,
                      context: context,
                      builder: (BuildContext _) {
                        return SizedBox(
                          height: height(context) * 0.3,
                          child: CupertinoDatePicker(
                            initialDateTime: DateTime.now(),
                            mode: CupertinoDatePickerMode.date,
                            backgroundColor: Colors.transparent,
                            use24hFormat: true,
                            onDateTimeChanged: (DateTime picked) {
                              if (picked != selected_date) {
                                setState(() {
                                  selected_date = picked;
                                  DateFormat format_show_user =
                                      DateFormat("d MMMM, yyyy");
                                  dob = format_show_user.format(selected_date);
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
                          accountTypeWidget(context, account_type,
                              (value) => setState(() => account_type = value!)),
                          hGap(30),
                          usernameTextfield(username_controller),
                          hGap(20),
                          firstNameTextField(first_name_controller),
                          hGap(30),
                          lastNameTextField(last_name_controller),
                          hGap(30),
                          phoneNumberTextField(phone_number_controller),
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
                                      if (picked != selected_date) {
                                        setState(() {
                                          selected_date = picked;
                                          DateFormat format_show_user =
                                              DateFormat("d MMMM, yyyy");
                                          dob = format_show_user
                                              .format(selected_date);
                                        });
                                      }
                                    },
                                  ),
                                );
                              },
                            );
                          }),
                          hGap(30),
                          genderSelector(context, selected_sex,
                              (value) => setState(() => selected_sex = value!)),
                          hGap(30),
                          addressTextField(address_controller),
                          hGap(30),
                          cityTextField(city_controller),
                          hGap(30),
                          countryWidget(
                            selected_country,
                            () {
                              showCupertinoModalPopup<void>(
                                context: context,
                                builder: (_) {
                                  return CountryPickerCupertino(
                                    pickerSheetHeight: 250.0,
                                    backgroundColor: Colors.white,
                                    onValuePicked: (Country country) {
                                      setState(() {
                                        selected_country = country.name;
                                        country_code = country.phoneCode;
                                        selected_country_iso_code =
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
