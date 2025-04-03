// ignore_for_file: use_build_context_synchronously, non_constant_identifier_names
import 'package:intl/intl.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:jayben/Utilities/constants.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:jayben/Utilities/general_widgets.dart';
import 'package:jayben/Utilities/provider_functions.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:jayben/Home/elements/admin/elements/view_verification_photo.dart';

class ViewVerificationRequestPage extends StatefulWidget {
  const ViewVerificationRequestPage({super.key, required this.request_map});

  final Map request_map;

  @override
  State<ViewVerificationRequestPage> createState() =>
      _ViewVerificationRequestPageState();
}

class _ViewVerificationRequestPageState
    extends State<ViewVerificationRequestPage> {
  @override
  void initState() {
    if (widget.request_map["status"] == "Pending") {
      setState(() => isPending = true);
    } else if (widget.request_map["status"] == "Completed") {
      setState(() => isCompleted = true);
    } else if (widget.request_map["status"] == "Rejected") {
      setState(() => isRejected = true);
    }

    getUsersRow();
    super.initState();
  }

  Future<void> getUsersRow() async {
    List<dynamic> results = await context
        .read<AdminProviderFunctions>()
        .getWithdrawOwnersRow(widget.request_map["user_id"]);

    if (!mounted) return;

    setState(() {
      selected_date_of_birth =
          DateTime.parse(results[0]["date_of_birth"]).toUtc().toLocal();
      first_name_controller.text = results[0]["first_name"];
      last_name_controller.text = results[0]["last_name"];
      customer_map = results[0];
    });
  }

  Map? customer_map;
  bool isPending = false;
  bool isRejected = false;
  bool isCompleted = false;
  bool isUpdatingInfo = false;
  DateTime? selected_date_of_birth;
  final comment_controller = TextEditingController();
  final last_name_controller = TextEditingController();
  final first_name_controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Consumer<AdminProviderFunctions>(builder: (_, value, child) {
      return Scaffold(
        backgroundColor: Colors.white,
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () async {
            if (selected_date_of_birth == null) return;

            setState(() => isUpdatingInfo = true);

            // updates the user's account document
            await value.updateRequestOwnerAccount({
              "first_name": first_name_controller.text,
              "date_of_birth": selected_date_of_birth,
              "last_name": last_name_controller.text,
              "user_id": customer_map!["user_id"]
            });

            // refreshes the details being displayed
            await getUsersRow();

            setState(() => isUpdatingInfo = false);

            showSnackBar(context, "Account info has been saved",
                color: Colors.green);

            goBack(context);
          },
          backgroundColor: Colors.green,
          label: isUpdatingInfo
              ? loadingIcon(context)
              : Text(
                  "Save Changes",
                  style: googleStyle(
                    weight: FontWeight.w400,
                    color: Colors.white,
                    size: 18,
                  ),
                ),
        ),
        body: value.returnIsLoading()
            ? loadingScreenPlainNoBackButton(context)
            : SafeArea(
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
                          padding: const EdgeInsets.only(
                              top: 70, bottom: 90, left: 20, right: 20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text(
                                    "Request ID",
                                    textAlign: TextAlign.center,
                                    style: googleStyle(
                                        color: Colors.green,
                                        weight: FontWeight.w700,
                                        size: 25),
                                  ),
                                  Text(
                                    "${widget.request_map["verification_id"]}",
                                    textAlign: TextAlign.center,
                                    style: googleStyle(
                                      color: Colors.black,
                                      weight: FontWeight.w400,
                                      size: 13,
                                    ),
                                  )
                                ],
                              ),
                              hGap(20),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "Mark as Approved",
                                    style: googleStyle(
                                      color: Colors.black,
                                      weight: FontWeight.w300,
                                    ),
                                  ),
                                  CupertinoSwitch(
                                    value: isCompleted,
                                    onChanged: isRejected || isCompleted
                                        ? null
                                        : (bool state) async {
                                            setState(() => isCompleted = state);

                                            value.toggleIsLoading();

                                            // updates the user's account document
                                            await value
                                                .updateRequestOwnerAccount({
                                              "first_name":
                                                  first_name_controller.text,
                                              "date_of_birth":
                                                  selected_date_of_birth,
                                              "last_name":
                                                  last_name_controller.text,
                                              "user_id":
                                                  customer_map!["user_id"]
                                            });

                                            await value
                                                .approveVerificationRequestStatus({
                                              "response": {
                                                "comment":
                                                    comment_controller.text
                                              },
                                              "customer_map": customer_map!,
                                              ...widget.request_map,
                                            });

                                            await value
                                                .getPendingVerificationRequests();

                                            value.toggleIsLoading();

                                            goBack(context);
                                          },
                                  )
                                ],
                              ),
                              hGap(20),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "Mark as Rejected",
                                    style: googleStyle(
                                      color: Colors.black,
                                      weight: FontWeight.w300,
                                    ),
                                  ),
                                  CupertinoSwitch(
                                    value: isCompleted,
                                    onChanged: isRejected || isCompleted
                                        ? null
                                        : (bool state) async {
                                            if (comment_controller
                                                .text.isEmpty) {
                                              showSnackBar(context,
                                                  "Enter a rejection comment");
                                              return;
                                            }

                                            setState(() => isRejected = state);

                                            value.toggleIsLoading();

                                            // updates the user's account document
                                            await value
                                                .updateRequestOwnerAccount({
                                              "first_name":
                                                  first_name_controller.text,
                                              "date_of_birth":
                                                  selected_date_of_birth,
                                              "last_name":
                                                  last_name_controller.text,
                                              "user_id":
                                                  customer_map!["user_id"]
                                            });

                                            await value
                                                .rejectVerificationRequestStatus({
                                              "response": {
                                                "comment":
                                                    comment_controller.text
                                              },
                                              "customer_map": customer_map!,
                                              ...widget.request_map,
                                            });

                                            await value
                                                .getPendingVerificationRequests();

                                            value.toggleIsLoading();

                                            goBack(context);
                                          },
                                  )
                                ],
                              ),
                              hGap(20),
                              commentTextField(),
                              const Padding(
                                padding: EdgeInsets.symmetric(vertical: 15),
                                child: Divider(
                                  color: Colors.black,
                                  thickness: 0.2,
                                ),
                              ),
                              Text(
                                "Verification Details",
                                textAlign: TextAlign.center,
                                style: googleStyle(
                                    color: Colors.green,
                                    weight: FontWeight.w700,
                                    size: 25),
                              ),
                              hGap(20),
                              imageWidgets(widget.request_map),
                              hGap(20),
                              customerDetailTile("Document Type",
                                  "${widget.request_map["identification_type"]}"),
                              hGap(10),
                              customerDetailTile(
                                "Date Submitted",
                                timeago.format(
                                  DateTime.parse(
                                          widget.request_map["created_at"])
                                      .toUtc()
                                      .toLocal(),
                                ),
                              ),
                              hGap(10),
                              const Padding(
                                padding: EdgeInsets.symmetric(vertical: 15),
                                child: Divider(
                                  color: Colors.black,
                                  thickness: 0.2,
                                ),
                              ),
                              Text(
                                "Customer Details",
                                textAlign: TextAlign.center,
                                style: googleStyle(
                                  color: Colors.green,
                                  weight: FontWeight.w700,
                                  size: 25,
                                ),
                              ),
                              hGap(10),
                              GestureDetector(
                                onTap: () =>
                                    showDialogue(context, editNamesWidget()),
                                child: customerDetailTile(
                                    "Full names",
                                    customer_map == null
                                        ? "loading..."
                                        : "${first_name_controller.text} ${last_name_controller.text}"),
                              ),
                              hGap(10),
                              GestureDetector(
                                onTap: () async {
                                  // copies link to clipboard
                                  await Clipboard.setData(ClipboardData(
                                      text: customer_map!["phone_number"]));

                                  showSnackBar(context, "Phone number Copied",
                                      color: Colors.green[600]!);
                                },
                                child: customerDetailTile(
                                    "Phone Number",
                                    customer_map == null
                                        ? "loading..."
                                        : "${customer_map!["phone_number"]}"),
                              ),
                              hGap(10),
                              GestureDetector(
                                onTap: () async => showModalBottomSheet(
                                  enableDrag: false,
                                  context: context,
                                  builder: (_) {
                                    return SizedBox(
                                      height: height(context) * 0.3,
                                      child: CupertinoDatePicker(
                                        backgroundColor: Colors.transparent,
                                        initialDateTime: selected_date_of_birth,
                                        mode: CupertinoDatePickerMode.date,
                                        use24hFormat: true,
                                        onDateTimeChanged: (DateTime picked) {
                                          if (picked !=
                                              selected_date_of_birth) {
                                            setState(() =>
                                                selected_date_of_birth =
                                                    picked);
                                          }
                                        },
                                      ),
                                    );
                                  },
                                ),
                                child: customerDetailTile(
                                    "Date Of Birth",
                                    customer_map == null
                                        ? "loading..."
                                        : DateFormat("d MMMM, yyyy").format(
                                            selected_date_of_birth!
                                                .toUtc()
                                                .toLocal())),
                              ),
                              hGap(10),
                              customerDetailTile(
                                  "Date Joined",
                                  customer_map == null
                                      ? "loading..."
                                      : timeago.format(DateTime.parse(
                                              customer_map!["created_at"])
                                          .toLocal())),
                              hGap(10),
                              customerDetailTile(
                                  "Gender",
                                  customer_map == null
                                      ? "loading..."
                                      : "${customer_map!["gender"]} (${customer_map!["gender"][0].toString().toUpperCase()})"),
                              hGap(10),
                              customerDetailTile(
                                  "Country",
                                  customer_map == null
                                      ? "loading..."
                                      : customer_map!["country"]),
                              hGap(10),
                              customerDetailTile(
                                  "City",
                                  customer_map == null
                                      ? "loading..."
                                      : customer_map!["city"] ?? ""),
                              hGap(10),
                              customerDetailTile(
                                  "Wallet Bal",
                                  customer_map == null
                                      ? "loading..."
                                      : "${customer_map!["currency_symbol"]}${double.parse(customer_map!["balance"].toString()).toStringAsFixed(2)}"),
                              hGap(10),
                              customerDetailTile(
                                  "Build Version",
                                  customer_map == null
                                      ? "loading..."
                                      : customer_map!["current_build_version"]),
                              hGap(10),
                              customerDetailTile(
                                  "Platform OS",
                                  customer_map == null
                                      ? "loading..."
                                      : customer_map!["current_os_platform"]),
                              hGap(30),
                            ],
                          ),
                        ),
                      ),
                    ),
                    customAppBarTitle(context),
                  ],
                ),
              ),
      );
    });
  }

  Widget editNamesWidget() {
    return AlertDialog(
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(40))),
      content: Stack(
        children: [
          SizedBox(
            width: width(context) * 0.8,
            child: ListView(
              physics: const BouncingScrollPhysics(),
              shrinkWrap: true,
              children: [
                Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Edit Their First & Last Names",
                      textAlign: TextAlign.center,
                      style: GoogleFonts.ubuntu(
                        color: Colors.grey[800],
                        fontSize: 15,
                      ),
                    ),
                    hGap(20),
                    SizedBox(
                      width: width(context) * 0.9,
                      child: TextField(
                        cursorColor: Colors.grey[700],
                        cursorHeight: 22,
                        minLines: 1,
                        maxLines: 2,
                        onChanged: (String? text) =>
                            setState(() => first_name_controller.text = text!),
                        controller: first_name_controller,
                        keyboardType: TextInputType.text,
                        inputFormatters: [
                          LengthLimitingTextInputFormatter(100),
                        ],
                        textAlign: TextAlign.center,
                        style: GoogleFonts.ubuntu(
                          fontWeight: FontWeight.w300,
                          color: Colors.black,
                          fontSize: 22,
                        ),
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.grey[200],
                          focusColor: Colors.white,
                          hintText: 'First Name',
                          isDense: true,
                          border: const OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.transparent),
                              borderRadius:
                                  BorderRadius.all(Radius.circular(20))),
                          enabledBorder: const OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.transparent),
                              borderRadius:
                                  BorderRadius.all(Radius.circular(20))),
                          focusedBorder: const OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.transparent),
                              borderRadius:
                                  BorderRadius.all(Radius.circular(20))),
                          disabledBorder: const OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.transparent),
                              borderRadius:
                                  BorderRadius.all(Radius.circular(20))),
                          hintStyle: GoogleFonts.ubuntu(
                            color: Colors.grey[500],
                            fontSize: 18,
                          ),
                        ),
                      ),
                    ),
                    hGap(20),
                    SizedBox(
                      width: width(context) * 0.9,
                      child: TextField(
                        cursorColor: Colors.grey[700],
                        cursorHeight: 22,
                        minLines: 1,
                        maxLines: 2,
                        controller: last_name_controller,
                        keyboardType: TextInputType.text,
                        onChanged: (String? text) =>
                            setState(() => last_name_controller.text = text!),
                        inputFormatters: [
                          LengthLimitingTextInputFormatter(100),
                        ],
                        textAlign: TextAlign.center,
                        style: GoogleFonts.ubuntu(
                          fontWeight: FontWeight.w300,
                          color: Colors.black,
                          fontSize: 22,
                        ),
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.grey[200],
                          focusColor: Colors.white,
                          hintText: 'Last Name',
                          isDense: true,
                          border: const OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.transparent),
                              borderRadius:
                                  BorderRadius.all(Radius.circular(20))),
                          enabledBorder: const OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.transparent),
                              borderRadius:
                                  BorderRadius.all(Radius.circular(20))),
                          focusedBorder: const OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.transparent),
                              borderRadius:
                                  BorderRadius.all(Radius.circular(20))),
                          disabledBorder: const OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.transparent),
                              borderRadius:
                                  BorderRadius.all(Radius.circular(20))),
                          hintStyle: GoogleFonts.ubuntu(
                            color: Colors.grey[500],
                            fontSize: 18,
                          ),
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
              onTap: () => goBack(context),
              child: CircleAvatar(
                radius: 16,
                backgroundColor: Colors.grey[100],
                child: Icon(
                  color: Colors.grey[600],
                  Icons.close,
                  size: 20,
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget imageWidgets(submission_map) {
    return Container(
      width: width(context),
      alignment: Alignment.center,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          GestureDetector(
            onTap: () => changePage(
              context,
              ViewVerificationPhotoPage(
                image: submission_map["selfie_image_url"],
              ),
            ),
            child: Container(
              height: 200,
              alignment: Alignment.center,
              width: width(context) * 0.95,
              decoration: requestTileSelfieDeco(),
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(30),
                    child: CachedNetworkImage(
                      imageUrl: submission_map["selfie_image_url"],
                      width: double.infinity,
                      fit: BoxFit.cover,
                      height: 200,
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
                  width: width(context) * 0.45,
                  decoration: requestTileSelfieDeco(),
                  child: Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(30),
                        child: CachedNetworkImage(
                          imageUrl: submission_map["document_photo_1_url"],
                          width: width(context) * 0.55,
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
                  width: width(context) * 0.45,
                  decoration: requestTileSelfieDeco(),
                  child: Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(30),
                        child: CachedNetworkImage(
                          imageUrl: submission_map["document_photo_2_url"],
                          width: width(context) * 0.55,
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
        ],
      ),
    );
  }

  Widget commentTextField() {
    return TextField(
      cursorHeight: 24,
      cursorColor: iconColor,
      maxLines: 5,
      minLines: 1,
      autocorrect: false,
      enableSuggestions: false,
      textCapitalization: TextCapitalization.sentences,
      controller: comment_controller,
      keyboardType: TextInputType.text,
      inputFormatters: [
        LengthLimitingTextInputFormatter(100),
      ],
      textAlign: TextAlign.left,
      style: const TextStyle(
        fontSize: 24,
        color: Colors.black,
      ),
      decoration: InputDecoration(
        hintText: 'Rejection Comment',
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
    );
  }

  Widget customAppBarTitle(BuildContext context) {
    return Consumer<AdminProviderFunctions>(
      builder: (_, value, child) {
        return Positioned(
          top: 0,
          child: Container(
            decoration: appBarDeco(),
            alignment: Alignment.centerLeft,
            width: MediaQuery.of(context).size.width,
            padding: const EdgeInsets.only(left: 10, right: 20, bottom: 15),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                InkWell(
                  onTap: () => Navigator.of(context).pop(),
                  child: SizedBox(
                    child: Icon(
                      Icons.arrow_back,
                      color: iconColor,
                      size: 40,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Text.rich(
                  const TextSpan(text: ""),
                  textAlign: TextAlign.left,
                  style: GoogleFonts.ubuntu(
                    textStyle: const TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.w600,
                      color: Color.fromARGB(255, 54, 54, 54),
                    ),
                  ),
                ),
                const Spacer(),
                Container(
                  decoration: BoxDecoration(
                      color: isCompleted
                          ? Colors.green
                          : (isRejected ? Colors.red : Colors.orange),
                      borderRadius: BorderRadius.circular(10)),
                  padding:
                      const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                  child: Text(
                    isCompleted
                        ? "Completed"
                        : isPending
                            ? "Pending"
                            : "Rejected",
                    style: googleStyle(
                      weight: FontWeight.w400,
                      color: Colors.white,
                      size: 20,
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

Widget customerDetailTile(String? tileName, String? tileDetail) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Text(
        tileName ?? "loading...",
        style: googleStyle(
          color: Colors.grey[700]!,
          weight: FontWeight.w400,
          size: 18,
        ),
      ),
      Container(
        width: 200,
        alignment: Alignment.centerRight,
        child: Text(
          tileDetail ?? "loading...",
          textAlign: TextAlign.end,
          style: googleStyle(
            color: Colors.grey[900]!,
            weight: FontWeight.w400,
            size: 18,
          ),
        ),
      ),
    ],
  );
}

// ======================= styling widgets

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

Decoration requestTileSelfieDeco() {
  return BoxDecoration(
    color: Colors.grey[200],
    borderRadius: BorderRadius.circular(30),
  );
}
