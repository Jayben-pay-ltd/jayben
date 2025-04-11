import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive/hive.dart';
import 'package:jayben/Utilities/provider_functions.dart';

class CacheMomoPINDialogue extends StatefulWidget {
  const CacheMomoPINDialogue({Key? key}) : super(key: key);

  @override
  State<CacheMomoPINDialogue> createState() => _CacheMomoPINDialogueState();
}

class _CacheMomoPINDialogueState extends State<CacheMomoPINDialogue> {
  bool isCaching = false;
  String typeOfGroup = "";
  final pinController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return AlertDialog(
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(40))),
      content: Stack(
        children: [
          SizedBox(
            width: MediaQuery.of(context).size.width * 0.8,
            child: ListView(
              physics: const BouncingScrollPhysics(),
              shrinkWrap: true,
              children: [
                Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Save Your Mobile Money PIN",
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: Colors.grey[900]),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      "Save your mobile money PIN to memory so that you don't\nhave to re-enter it over and over for transactions",
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      "Stored Locally with 256 Bit AES Encryption",
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 15, color: Colors.black),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: width * 0.9,
                      child: TextField(
                        cursorColor: Colors.grey[700],
                        cursorHeight: 15,
                        minLines: 1,
                        maxLines: 2,
                        controller: pinController,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          LengthLimitingTextInputFormatter(4),
                          FilteringTextInputFormatter.deny(RegExp(r"\s\b|\b\s"))
                        ],
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 15,
                          color: Colors.grey[700],
                          fontWeight: FontWeight.w300,
                        ),
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.grey[200],
                          focusColor: Colors.white,
                          hintText: 'Enter PIN',
                          isDense: true,
                          border: const OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.transparent),
                              borderRadius:
                                  BorderRadius.all(Radius.circular(10))),
                          enabledBorder: const OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.transparent),
                              borderRadius:
                                  BorderRadius.all(Radius.circular(10))),
                          focusedBorder: const OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.transparent),
                              borderRadius:
                                  BorderRadius.all(Radius.circular(10))),
                          disabledBorder: const OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.transparent),
                              borderRadius:
                                  BorderRadius.all(Radius.circular(10))),
                          hintStyle: TextStyle(
                            fontSize: 15,
                            color: Colors.grey[800],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text("Avoid repeating your PIN for transactions...",
                        textAlign: TextAlign.center),
                    const SizedBox(height: 20),
                    InkWell(
                      onTap: () async {
                        if (pinController.text.isNotEmpty) {
                          boxPut(
                              "mobile_money_pin",
                              pinController.text
                                  .replaceAll(" ", "")
                                  .replaceAll("-", "")
                                  .replaceAll(".", "")
                                  .replaceAll(",", ""));

                          ScaffoldMessenger.of(this.context)
                              .showSnackBar(const SnackBar(
                                  duration: Duration(seconds: 3),
                                  content: Text(
                                    'Mobile money pin was saved successfully.',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15,
                                        color: Colors.white),
                                  ),
                                  backgroundColor: Colors.green));

                          Navigator.pop(this.context);
                        } else {
                          Navigator.pop(context);

                          ScaffoldMessenger.of(this.context)
                              .showSnackBar(const SnackBar(
                                  duration: Duration(seconds: 3),
                                  content: Text(
                                    'Enter a PIN',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15,
                                        color: Colors.white),
                                  ),
                                  backgroundColor: Colors.red));
                        }
                      },
                      child: Container(
                        alignment: Alignment.center,
                        height: height * 0.06,
                        width: width * 0.25,
                        decoration: const BoxDecoration(
                            color: Colors.green,
                            borderRadius:
                                BorderRadius.all(Radius.circular(30))),
                        child: const Text(
                          "Save",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Positioned(
            right: 0,
            top: 0,
            child: GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                  setState(() {
                    isCaching = false;
                  });
                },
                child: Icon(Icons.close, size: 20, color: Colors.grey[600])),
          )
        ],
      ),
    );
  }
}
