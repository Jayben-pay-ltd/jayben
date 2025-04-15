// ignore_for_file: non_constant_identifier_names
import 'dart:io';
import 'package:intl/intl.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:jayben/Utilities/constants.dart';
import 'package:jayben/Utilities/provider_functions.dart';

class NfcTransactionTile extends StatelessWidget {
  const NfcTransactionTile({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<NfcProviderFunctions>(
      builder: (_, value, child) {
        int current_card_index = value.returnCurrentCardIndex();
        return value.returnListOfTagTransactions() == null
            ? nothing()
            : value.returnListOfTagTransactions()!.isEmpty
                ? nothing()
                : value.returnListOfTagTransactions()![current_card_index] !=
                        null
                    ? MediaQuery.removePadding(
                        removeTop: true,
                        context: context,
                        removeBottom: true,
                        child: ListView.builder(
                          shrinkWrap: true,
                          addRepaintBoundaries: true,
                          scrollDirection: Axis.vertical,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: value
                              .returnListOfTagTransactions()![
                                  current_card_index]!
                              .length,
                          padding: const EdgeInsets.only(bottom: 20, top: 10),
                          itemBuilder: (_, index) {
                            Map ds = value.returnListOfTagTransactions()![
                                current_card_index]![index];
                            var amount = double.parse(ds['amount'].toString());
                            return GestureDetector(
                              onTap: () async => showBottomCard(context,
                                  transactionDetailsDialogue(context, ds)),
                              child: Container(
                                width: width(context),
                                color: Colors.grey[100]!,
                                padding: const EdgeInsets.symmetric(
                                    vertical: 15, horizontal: 20),
                                margin:
                                    const EdgeInsets.symmetric(vertical: 0.5),
                                child: Row(
                                  children: [
                                    Column(
                                      mainAxisSize: MainAxisSize.min,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          "${ds["transaction_type"]}",
                                          style: GoogleFonts.ubuntu(
                                            fontWeight: FontWeight.w500,
                                            color: Colors.black,
                                            fontSize: 19,
                                          ),
                                        ),
                                        hGap(5),
                                        Text(
                                          timeago.format(
                                              DateTime.parse(ds["created_at"])
                                                  .toUtc()
                                                  .toLocal()),
                                          textAlign: TextAlign.left,
                                          maxLines: 1,
                                          style: GoogleFonts.ubuntu(
                                            fontWeight: FontWeight.w300,
                                            color: Colors.grey[800],
                                            fontSize: 14,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const Spacer(),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      children: [
                                        Text.rich(
                                          TextSpan(
                                            text: ds["sent_received"] == "Sent"
                                                ? "- ${ds["currency"]} "
                                                : "+ ${ds["currency"]} ",
                                            children: [
                                              TextSpan(
                                                text: amount < 100000.0
                                                    ? amount.toStringAsFixed(2)
                                                    : (amount >= 100000.0 &&
                                                            amount < 1000000.0
                                                        ? "${amount.toStringAsFixed(2)[0]}${amount.toStringAsFixed(2)[1]}${amount.toStringAsFixed(2)[2]}k"
                                                        : (amount > 1000000.0 &&
                                                                amount <
                                                                    10000000.0
                                                            ? "${amount.toStringAsFixed(2)[0]}.${amount.toStringAsFixed(2)[1]}${amount.toStringAsFixed(2)[2]} M"
                                                            : (amount > 10000000.0 &&
                                                                    amount <
                                                                        100000000.0
                                                                ? "${amount.toStringAsFixed(2)[0]}${amount.toStringAsFixed(2)[1]}.${amount.toStringAsFixed(2)[2]}${amount.toStringAsFixed(2)[3]} M"
                                                                : "${amount.toStringAsFixed(2)[0]}${amount.toStringAsFixed(2)[1]}${amount.toStringAsFixed(2)[2]}.${amount.toStringAsFixed(2)[3]}${amount.toStringAsFixed(2)[4]} M"))),
                                                style: GoogleFonts.ubuntu(
                                                  fontWeight: FontWeight.w500,
                                                  color: Colors.black,
                                                  fontSize: 23,
                                                ),
                                              )
                                            ],
                                          ),
                                          style: GoogleFonts.ubuntu(
                                            fontWeight: FontWeight.w400,
                                            color: Colors.black54,
                                            fontSize: 15,
                                          ),
                                        ),
                                        ds["transaction_type"] != "Withdrawal"
                                            ? nothing()
                                            : ds["status"] == "Completed"
                                                ? nothing()
                                                : Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            top: 5.0),
                                                    child: Text(
                                                      "${ds["status"]}",
                                                      style: GoogleFonts.ubuntu(
                                                        fontWeight:
                                                            FontWeight.w400,
                                                        color: ds["status"] ==
                                                                "Pending"
                                                            ? Colors.orange[700]
                                                            : ds["status"] ==
                                                                    "Completed"
                                                                ? Colors.green
                                                                : Colors
                                                                    .red[300],
                                                        fontSize: 13,
                                                      ),
                                                    ),
                                                  ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      )
                    : nothing();
      },
    );
  }
}

Widget loadingWidget(BuildContext context) {
  return SizedBox(
    width: width(context),
    height: height(context) * 0.15,
    child: Center(
      child: CircularProgressIndicator(
        color: Colors.grey[700],
        strokeWidth: 2,
      ),
    ),
  );
}

Widget transactionDetailsDialogue(context, Map ds) {
  double amount = double.parse(ds['amount'].toString());
  return Container(
    decoration: cardDeco(),
    width: width(context) * 0.95,
    alignment: Alignment.center,
    height: height(context) * 0.470,
    padding: EdgeInsets.only(
      bottom: Platform.isIOS ? 30 : 25,
      right: 20,
      left: 20,
      top: 20,
    ),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          "Transaction Details",
          textAlign: TextAlign.center,
          style: googleStyle(
            color: Colors.grey[900]!,
            weight: FontWeight.w500,
            size: 23,
          ),
        ),
        hGap(20),
        Container(
          alignment: Alignment.center,
          width: width(context) * 0.9,
          decoration: detailsPreviewDeco(),
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Text("Date",
                      style: GoogleFonts.ubuntu(fontWeight: FontWeight.w300)),
                  const Spacer(),
                  Row(
                    children: [
                      Text(
                        DateFormat.yMMMd().format(
                            DateTime.parse(ds["created_at"]).toUtc().toLocal()),
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                        ),
                      ),
                      // const SizedBox(width: 4),
                      Text(
                        " - ${DateFormat.Hm().format(DateTime.parse(ds["created_at"]).toUtc().toLocal())}",
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                        ),
                      )
                    ],
                  )
                ],
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Divider(color: Colors.grey[500]),
              ),
              Row(
                children: [
                  Text("Type",
                      style: GoogleFonts.ubuntu(fontWeight: FontWeight.w300)),
                  const Spacer(),
                  Text(
                    ds["transaction_type"],
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  )
                ],
              ),
              hGap(15),
              Row(
                children: [
                  Text("Status",
                      style: GoogleFonts.ubuntu(fontWeight: FontWeight.w300)),
                  const Spacer(),
                  Text(
                    "${ds["status"]}",
                    style: GoogleFonts.ubuntu(
                      fontWeight: FontWeight.w600,
                      color: ds["status"] == "Pending"
                          ? Colors.orange[800]
                          : ds["status"] == "Completed"
                              ? Colors.green
                              : Colors.red,
                    ),
                  ),
                ],
              ),
              hGap(15),
              Row(
                children: [
                  Text(
                    "Names",
                    style: GoogleFonts.ubuntu(
                      fontWeight: FontWeight.w300,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    "${ds["full_names"]}",
                    style: GoogleFonts.ubuntu(
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
              hGap(15),
              Row(
                children: [
                  Text(
                    "Description",
                    style: GoogleFonts.ubuntu(
                      fontWeight: FontWeight.w300,
                    ),
                  ),
                  const Spacer(),
                  SizedBox(
                    width: width(context) * 0.55,
                    child: Text(
                      "${ds["description"]}",
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.end,
                      maxLines: 1,
                      style: GoogleFonts.ubuntu(
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ],
              ),
              hGap(15),
              Row(
                children: [
                  Text(
                    "Method",
                    style: GoogleFonts.ubuntu(
                      fontWeight: FontWeight.w300,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    "${ds["method"]}",
                    style: GoogleFonts.ubuntu(
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
              hGap(15),
              Row(
                children: [
                  Text("Amount",
                      style: GoogleFonts.ubuntu(fontWeight: FontWeight.w300)),
                  const Spacer(),
                  Text(
                    (ds["currency"] == "ZMW"
                        ? (ds["sent_received"] == "Received"
                            ? "+ ZMW ${amount.toStringAsFixed(2)}"
                            : "- ZMW ${amount.toStringAsFixed(2)}")
                        : (ds["sent_received"] == "Received"
                            ? "+ ${amount.toStringAsFixed(2)}, ${ds["currency"]}"
                            : "- ${amount.toStringAsFixed(2)}, ${ds["currency"]}")),
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  )
                ],
              ),
            ],
          ),
        ),
        hGap(20),
        GestureDetector(
          onTap: () async {
            await Clipboard.setData(ClipboardData(text: ds["transaction_id"]));

            showSnackBar(context, "Transaction ID Copied", color: Colors.green);

            goBack(context);
          },
          child: SizedBox(
            child: Text(
              "${ds["transaction_id"]}",
              textAlign: TextAlign.center,
              style: GoogleFonts.ubuntu(
                fontWeight: FontWeight.w300,
                color: Colors.black,
                fontSize: 15,
              ),
            ),
          ),
        ),
        hGap(10),
        GestureDetector(
          onTap: () async {
            await Clipboard.setData(ClipboardData(text: ds["transaction_id"]));

            showSnackBar(context, "Transaction ID Copied",
                color: Colors.grey[700]!);

            goBack(context);
          },
          child: SizedBox(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.copy,
                  color: Colors.green[700],
                  size: 13,
                ),
                const SizedBox(width: 10),
                Text(
                  "Copy Transaction ID",
                  style: GoogleFonts.ubuntu(
                    fontWeight: FontWeight.w300,
                    color: Colors.green[700],
                    fontSize: 15,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    ),
  );
}

// ================ styling widgets

Decoration detailsPreviewDeco() {
  return BoxDecoration(
      color: Colors.grey[200], borderRadius: BorderRadius.circular(30));
}

Decoration cardDeco() {
  return const BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.only(
      topRight: Radius.circular(30),
      topLeft: Radius.circular(30),
    ),
  );
}
