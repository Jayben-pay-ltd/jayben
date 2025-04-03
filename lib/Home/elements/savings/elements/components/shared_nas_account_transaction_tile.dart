import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:jayben/Utilities/provider_functions.dart';
import '../../../../../../Utilities/general_widgets.dart';
import '../../../transactions/components/home_transaction_tile.dart';

class SharedNasAccountTransactionTile extends StatefulWidget {
  const SharedNasAccountTransactionTile(
      {Key? key, required this.myTransactions})
      : super(key: key);

  final List<dynamic>? myTransactions;

  @override
  _SharedNasAccountTransactionTileState createState() =>
      _SharedNasAccountTransactionTileState();
}

class _SharedNasAccountTransactionTileState
    extends State<SharedNasAccountTransactionTile> {
  @override
  Widget build(BuildContext context) {
    return widget.myTransactions != null
        ? MediaQuery.removePadding(
            context: context,
            removeTop: true,
            removeBottom: true,
            child: ListView.builder(
              padding: const EdgeInsets.only(bottom: 20, top: 10),
              shrinkWrap: true,
              scrollDirection: Axis.vertical,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: widget.myTransactions!.length,
              itemBuilder: (context, index) {
                Map ds = widget.myTransactions![index];
                double amount = double.parse(ds['amount'].toString());
                return GestureDetector(
                  onTap: () => showBottomCard(
                      context, transactionDetailsDialogue(context, ds)),
                  child: Container(
                    width: width(context),
                    color: Colors.transparent,
                    padding: const EdgeInsets.symmetric(
                        vertical: 5, horizontal: 20),
                    margin: const EdgeInsets.symmetric(vertical: 5),
                    child: Row(
                      children: [
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "${ds["full_names"]}",
                              style: GoogleFonts.ubuntu(
                                fontWeight: FontWeight.w600,
                                color: Colors.grey[900],
                                fontSize: 18,
                              ),
                            ),
                            hGap(5),
                            Text(
                              "${ds["transaction_type"]}",
                              style: GoogleFonts.ubuntu(
                                fontWeight: FontWeight.w400,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                        const Spacer(),
                        Text.rich(
                          TextSpan(
                            text: "+ ${ds["currency"]} ",
                            children: [
                              TextSpan(
                                text: amount < 100000.0
                                    ? amount.toStringAsFixed(2)
                                    : (amount >= 100000.0 && amount < 1000000.0
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
                                  color: Colors.black54,
                                  fontSize: 22,
                                ),
                              )
                            ],
                          ),
                          style: GoogleFonts.ubuntu(
                            fontWeight: FontWeight.w400,
                            color: Colors.black54,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          )
        : loadingScreenPlainNoBackButton(context);
  }
}
