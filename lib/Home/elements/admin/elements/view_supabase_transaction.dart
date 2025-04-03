// ignore_for_file: use_build_context_synchronously, non_constant_identifier_names
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:jayben/Utilities/constants.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:jayben/Utilities/general_widgets.dart';
import 'package:jayben/Utilities/provider_functions.dart';

class ViewSupabaseTransactionPage extends StatefulWidget {
  const ViewSupabaseTransactionPage({super.key, required this.transaction_map});

  final Map transaction_map;

  @override
  State<ViewSupabaseTransactionPage> createState() =>
      _ViewSupabaseTransactionPageState();
}

class _ViewSupabaseTransactionPageState
    extends State<ViewSupabaseTransactionPage> {
  @override
  void initState() {
    if (widget.transaction_map["status"] == "Cancelled") {
      setState(() => isRejected = true);
    } else if (widget.transaction_map["status"] == "Completed") {
      setState(() => isCompleted = true);
    } else if (widget.transaction_map["status"] == "Refunded") {
      setState(() => isReversed = true);
    }

    getUsersRow();
    super.initState();
  }

  Future<void> getUsersRow() async {
    var prov = context.read<AdminProviderFunctions>();

    List<dynamic> results =
        await prov.getWithdrawOwnersRow(widget.transaction_map["user_id"]);

    // gets the number of withdraws to same number in last 24 hours
    int num_of_withdraws_to_number = await prov.getWithdrawalsWithSameLine(
        widget.transaction_map["user_id"],
        widget.transaction_map["withdrawal_details"]["phone_number"]);

    if (!mounted) return;

    setState(() {
      number_of_withdraws_to_same_number_in_24_hrs = num_of_withdraws_to_number;
      customer_map = results[0];
    });
  }

  Map? customer_map;
  bool isReversed = false;
  bool isRejected = false;
  bool isCompleted = false;
  final amountController = TextEditingController();
  int number_of_withdraws_to_same_number_in_24_hrs = 0;

  @override
  Widget build(BuildContext context) {
    return Consumer<AdminProviderFunctions>(
      builder: (_, value, child) {
        return Scaffold(
          backgroundColor: Colors.white,
          body: value.returnIsLoading() || customer_map == null
              ? loadingScreenPlainNoBackButton(context)
              : SafeArea(
                  bottom: false,
                  child: Stack(
                    children: [
                      Container(
                        width: width(context),
                        height: height(context),
                        child: SingleChildScrollView(
                          physics: const BouncingScrollPhysics(),
                          padding: const EdgeInsets.only(
                              top: 70, bottom: 30, left: 20, right: 20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text(
                                    "Tranx ID",
                                    textAlign: TextAlign.center,
                                    style: googleStyle(
                                        color: Colors.green,
                                        weight: FontWeight.w700,
                                        size: 25),
                                  ),
                                  Text(
                                    "${widget.transaction_map["transaction_id"]}",
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
                                    "Mark as Completed",
                                    style: googleStyle(
                                      color: Colors.black,
                                      weight: FontWeight.w300,
                                    ),
                                  ),
                                  CupertinoSwitch(
                                    value: isCompleted,
                                    onChanged: isRejected ||
                                            isReversed ||
                                            isCompleted
                                        ? null
                                        : (bool state) async {
                                            setState(() => isCompleted = state);

                                            value.toggleIsLoading();

                                            await value.updateStatus({
                                              "customer_map": customer_map!,
                                              ...widget.transaction_map,
                                              "status": "Completed",
                                            });

                                            await value.getPendingWithdrawals();

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
                                    "Mark as Cancelled",
                                    style: googleStyle(
                                      color: Colors.black,
                                      weight: FontWeight.w300,
                                    ),
                                  ),
                                  CupertinoSwitch(
                                    value: isCompleted,
                                    onChanged: isRejected ||
                                            isReversed ||
                                            isCompleted
                                        ? null
                                        : (bool state) async {
                                            setState(() => isCompleted = state);

                                            value.toggleIsLoading();

                                            await value.updateStatus({
                                              "customer_map": customer_map!,
                                              ...widget.transaction_map,
                                              "status": "Cancelled",
                                            });

                                            await value.getPendingWithdrawals();

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
                                    onChanged: isRejected ||
                                            isReversed ||
                                            isCompleted
                                        ? null
                                        : (bool state) async {
                                            setState(() => isCompleted = state);

                                            value.toggleIsLoading();

                                            await value.updateStatus({
                                              "customer_map": customer_map!,
                                              ...widget.transaction_map,
                                              "status": "Rejected",
                                            });

                                            await value.getPendingWithdrawals();

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
                                    "Mark as Reversed",
                                    style: googleStyle(
                                      color: Colors.black,
                                      weight: FontWeight.w300,
                                    ),
                                  ),
                                  CupertinoSwitch(
                                    value: isCompleted,
                                    onChanged: isRejected ||
                                            isReversed ||
                                            isCompleted
                                        ? null
                                        : (bool state) async {
                                            setState(() => isCompleted = state);

                                            value.toggleIsLoading();

                                            await value.updateStatus({
                                              "customer_map": customer_map!,
                                              ...widget.transaction_map,
                                              "status": "Reversed",
                                            });

                                            await value.getPendingWithdrawals();

                                            value.toggleIsLoading();

                                            goBack(context);
                                          },
                                  )
                                ],
                              ),
                              hGap(20),
                              const Padding(
                                padding: EdgeInsets.symmetric(vertical: 15),
                                child: Divider(
                                  color: Colors.black,
                                  thickness: 0.2,
                                ),
                              ),
                              Text(
                                "Withdraw Details",
                                textAlign: TextAlign.center,
                                style: googleStyle(
                                    color: Colors.green,
                                    weight: FontWeight.w700,
                                    size: 25),
                              ),
                              hGap(20),
                              customerDetailTile(
                                  "Date Submitted",
                                  timeago.format(DateTime.parse(
                                          widget.transaction_map["created_at"])
                                      .toUtc()
                                      .toLocal())),
                              hGap(10),
                              customerDetailTile("Amount",
                                  "${widget.transaction_map["currency"]} ${widget.transaction_map["amount"]}"),
                              hGap(10),
                              customerDetailTile(
                                  "Withdraw Names",
                                  widget.transaction_map["withdrawal_details"]
                                          ["reference"] ??
                                      "${customer_map!["first_name"]} ${customer_map!["last_name"]}"),
                              hGap(10),
                              GestureDetector(
                                onTap: () async {
                                  // copies link to clipboard
                                  await Clipboard.setData(ClipboardData(
                                      text:
                                          "${widget.transaction_map["description"][3]}${widget.transaction_map["description"][4]}${widget.transaction_map["description"][5]}${widget.transaction_map["description"][6]}"
                                          "${widget.transaction_map["description"][7]}${widget.transaction_map["description"][8]}${widget.transaction_map["description"][9]}"
                                          "${widget.transaction_map["description"][10]}${widget.transaction_map["description"][11]}${widget.transaction_map["description"][12]}"));

                                  showSnackBar(context, "Phone number Copied",
                                      color: Colors.green[600]!);
                                },
                                child: customerDetailTile(
                                    "Withdraw Number",
                                    "${widget.transaction_map["description"][3]}${widget.transaction_map["description"][4]}${widget.transaction_map["description"][5]}${widget.transaction_map["description"][6]}"
                                        " - ${widget.transaction_map["description"][7]}${widget.transaction_map["description"][8]}${widget.transaction_map["description"][9]}"
                                        " - ${widget.transaction_map["description"][10]}${widget.transaction_map["description"][11]}${widget.transaction_map["description"][12]}"),
                              ),
                              hGap(10),
                              customerDetailTile(
                                  "Method", widget.transaction_map["method"]),
                              hGap(10),
                              customerDetailTile(
                                  "Repeats In 24 Hrs",
                                  number_of_withdraws_to_same_number_in_24_hrs
                                      .toString()),
                              number_of_withdraws_to_same_number_in_24_hrs < 2
                                  ? nothing()
                                  : Container(
                                      width: width(context),
                                      padding: const EdgeInsets.only(
                                        bottom: 10,
                                        top: 20,
                                      ),
                                      child: const Text(
                                        "DO NOT FULFILL WITH KAZANG MACHINE\nTO PREVENT GETTING BLOCKED",
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontWeight: FontWeight.w500,
                                          color: Colors.red,
                                        ),
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
                              hGap(20),
                              customerDetailTile("Full names",
                                  "${customer_map!["first_name"]} ${customer_map!["last_name"]}"),
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
                                    "${customer_map!["phone_number"][3]}${customer_map!["phone_number"][4]}${customer_map!["phone_number"][5]}${customer_map!["phone_number"][6]}"
                                        " - ${customer_map!["phone_number"][7]}${customer_map!["phone_number"][8]}${customer_map!["phone_number"][9]}"
                                        " - ${customer_map!["phone_number"][10]}${customer_map!["phone_number"][11]}${customer_map!["phone_number"][12]}"),
                              ),
                              hGap(10),
                              customerDetailTile(
                                  "Date Joined",
                                  timeago.format(DateTime.parse(
                                          customer_map!["created_at"])
                                      .toUtc()
                                      .toLocal())),
                              hGap(10),
                              customerDetailTile("Wallet Bal",
                                  "${widget.transaction_map["currency_symbol"]}${double.parse(customer_map!["balance"].toString()).toStringAsFixed(2)}"),
                              hGap(10),
                              customerDetailTile(
                                  "Country", customer_map!["country"]),
                              hGap(10),
                              customerDetailTile(
                                  "City", customer_map!["city"] ?? ""),
                              hGap(10),
                              customerDetailTile("Build Version",
                                  customer_map!["current_build_version"]),
                              hGap(10),
                              customerDetailTile(
                                  "KYC Verfied",
                                  customer_map!["account_kyc_is_verified"]
                                      .toString()),
                              hGap(10),
                              customerDetailTile("Platform OS",
                                  customer_map!["current_os_platform"]),
                              hGap(30),
                            ],
                          ),
                        ),
                      ),
                      tranxAppBarTitle(context),
                    ],
                  ),
                ),
        );
      },
    );
  }

  Widget tranxAppBarTitle(BuildContext context) {
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
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding:
                      const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                  child: Text(
                    isCompleted
                        ? "Completed"
                        : (isRejected ? "Rejected" : "Pending"),
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

Widget customerDetailTile(String tileName, String tileDetail) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Text(
        tileName,
        style: googleStyle(
          color: Colors.grey[700]!,
          weight: FontWeight.w400,
          size: 18,
        ),
      ),
      SizedBox(
        width: 200,
        child: Text(
          tileDetail,
          maxLines: 2,
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
