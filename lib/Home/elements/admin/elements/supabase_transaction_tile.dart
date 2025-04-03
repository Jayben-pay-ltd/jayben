import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:jayben/Utilities/constants.dart';
import '../../../../../../Utilities/general_widgets.dart';
import 'package:jayben/Utilities/provider_functions.dart';
import 'package:jayben/Home/elements/admin/elements/view_supabase_transaction.dart';

class SupabaseAdminTransactionsListBuilder extends StatelessWidget {
  const SupabaseAdminTransactionsListBuilder({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<AdminProviderFunctions>(builder: (_, value, child) {
      return value.returnPendingTransactions() != null
          ? value.returnPendingTransactions()!.isEmpty
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        "No withdrawals",
                        style: googleStyle(
                          weight: FontWeight.w500,
                          color: Colors.green,
                          size: 18,
                        ),
                      ),
                      hGap(20),
                      GestureDetector(
                        onTap: () async {
                          if (value.returnIsLoading()) return;

                          value.toggleIsLoading();

                          await value.getPendingWithdrawals();

                          value.toggleIsLoading();
                        },
                        child: value.returnIsLoading()
                            ? loadingIcon(
                                context,
                                color: Colors.green,
                                size: 30,
                              )
                            : const Icon(
                                color: Colors.green,
                                Icons.refresh,
                                size: 40,
                              ),
                      )
                    ],
                  ),
                )
              : RefreshIndicator(
                  displacement: 150,
                  onRefresh: () async {
                    if (value.returnIsLoading()) return;

                    value.toggleIsLoading();

                    // plays refresh sound
                    await playSound('refresh.mp3');

                    await value.getPendingWithdrawals();

                    value.toggleIsLoading();
                  },
                  child: MediaQuery.removePadding(
                    removeTop: true,
                    context: context,
                    removeBottom: true,
                    child: ListView.builder(
                        scrollDirection: Axis.vertical,
                        physics: const AlwaysScrollableScrollPhysics(),
                        itemCount: value.returnPendingTransactions()!.length,
                        padding: const EdgeInsets.only(bottom: 20, top: 90),
                        itemBuilder: (_, index) {
                          Map ds = value.returnPendingTransactions()![index];
                          var amount = double.parse(ds['amount'].toString());
                          return GestureDetector(
                            onTap: () async => changePage(
                                context,
                                ViewSupabaseTransactionPage(
                                    transaction_map: ds)),
                            child: Container(
                                margin: const EdgeInsets.symmetric(vertical: 5),
                                color: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                    vertical: 10, horizontal: 20),
                                width: width(context),
                                child: Row(
                                  children: [
                                    Column(
                                      mainAxisSize: MainAxisSize.min,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(ds["method"]),
                                        const SizedBox(height: 5),
                                        SizedBox(
                                          width: width(context) * 0.5,
                                          child: Text("${ds["description"]}",
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                              style: const TextStyle(
                                                  color: Colors.black,
                                                  fontWeight: FontWeight.bold)),
                                        ),
                                        const SizedBox(height: 5),
                                        Text(
                                          ds["status"],
                                          style: GoogleFonts.ubuntu(
                                            color: ds["status"] == "Pending"
                                                ? Colors.orange[700]
                                                : (ds["status"] == "Completed"
                                                    ? Colors.green
                                                    : Colors.red),
                                            fontWeight: FontWeight.w400,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const Spacer(),
                                    Column(
                                      mainAxisSize: MainAxisSize.min,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      children: [
                                        Text(
                                            ds["method"] == "Points"
                                                ? (ds["sent_received"] == "Sent"
                                                    ? (amount > 1
                                                        ? "- ${amount.toStringAsFixed(0)} Points"
                                                        : "- ${amount.toStringAsFixed(0)} Point")
                                                    : (amount > 1
                                                        ? "+ ${amount.toStringAsFixed(0)} Points"
                                                        : "+ ${amount.toStringAsFixed(0)} Point"))
                                                : (ds["currency"] == "ZMW"
                                                    ? (ds['sent_received'] ==
                                                            "Received"
                                                        ? "+ ZMW ${amount.toStringAsFixed(2)}"
                                                        : "- ZMW ${amount.toStringAsFixed(2)}")
                                                    : (ds['sent_received'] ==
                                                            "Received"
                                                        ? "+ ${amount.toStringAsFixed(2)}, ${ds["currency"]}"
                                                        : "- ${amount.toStringAsFixed(2)}, ${ds["currency"]}")),
                                            style: const TextStyle(
                                                color: Colors.black,
                                                fontWeight: FontWeight.bold)),
                                        const SizedBox(height: 5),
                                        Row(
                                          children: [
                                            Text(
                                              DateFormat.yMMMd().format(
                                                  DateTime.parse(
                                                          ds["created_at"])
                                                      .toUtc()
                                                      .toLocal()),
                                            ),
                                            Text(
                                                " - ${DateFormat.Hm().format(DateTime.parse(ds["created_at"]).toUtc().toLocal())}")
                                          ],
                                        ),
                                        const SizedBox(height: 5),
                                        Text(
                                          ds['transaction_type'],
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black,
                                          ),
                                        )
                                      ],
                                    ),
                                  ],
                                )),
                          );
                        }),
                  ),
                )
          : Center(child: loadingIcon(context));
    });
  }
}
