import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../../../../../../Utilities/general_widgets.dart';
import 'package:jayben/Utilities/provider_functions.dart';
import 'package:jayben/Home/elements/transactions/components/home_transaction_tile.dart';

class AllTransactionsTile extends StatelessWidget {
  const AllTransactionsTile({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<HomeProviderFunctions>(builder: (_, value, child) {
      return value.returnAllTransactions() != null
          ? MediaQuery.removePadding(
              removeTop: true,
              context: context,
              removeBottom: true,
              child: ListView.builder(
                shrinkWrap: true,
                scrollDirection: Axis.vertical,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: value.returnAllTransactions()!.length,
                padding: const EdgeInsets.only(bottom: 20, top: 0),
                itemBuilder: (_, index) {
                  Map ds = value.returnAllTransactions()![index];
                  var amount = double.parse(ds['amount'].toString());
                  return GestureDetector(
                    onTap: () async => showBottomCard(
                        context, transactionDetailsDialogue(context, ds)),
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
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "${ds["transaction_type"]}",
                                style: GoogleFonts.ubuntu(
                                  fontWeight: FontWeight.w500,
                                  color: Colors.black,
                                  fontSize: 17,
                                ),
                              ),
                              hGap(5),
                              Text(
                                timeago.format(
                                    DateTime.parse(ds["created_at"]).toUtc().toLocal()),
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
                            crossAxisAlignment: CrossAxisAlignment.end,
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
                                                      amount < 10000000.0
                                                  ? "${amount.toStringAsFixed(2)[0]}.${amount.toStringAsFixed(2)[1]}${amount.toStringAsFixed(2)[2]} M"
                                                  : (amount > 10000000.0 &&
                                                          amount < 100000000.0
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
                              ds["transaction_type"] != "Withdrawal" ||
                                      ds["status"] == "Completed"
                                  ? nothing()
                                  : ds["status"] == "Completed"
                                      ? nothing()
                                      : Padding(
                                          padding:
                                              const EdgeInsets.only(top: 5.0),
                                          child: Text(
                                            "${ds["status"]}",
                                            style: GoogleFonts.ubuntu(
                                              fontWeight: FontWeight.w400,
                                              color: ds["status"] == "Pending"
                                                  ? Colors.orange[700]
                                                  : ds["status"] == "Completed"
                                                      ? Colors.green
                                                      : Colors.red[300],
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
          : Center(child: loadingIcon(context));
    });
  }
}
