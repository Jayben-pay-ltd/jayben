import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:jayben/Home/elements/savings/elements/shared_nas_account_transactions.dart';
import 'package:jayben/Utilities/provider_functions.dart';
import 'package:jayben/Home/elements/savings/add_money_to_savings.dart';

class SavingsAccountMenuWidget extends StatefulWidget {
  const SavingsAccountMenuWidget(
      {Key? key,
      required this.accountName,
      required this.savingsAccountID,
      required this.accountType})
      : super(key: key);

  final String accountName;
  final String accountType;
  final String savingsAccountID;

  @override
  State<SavingsAccountMenuWidget> createState() =>
      _SavingsAccountMenuWidgetState();
}

class _SavingsAccountMenuWidgetState extends State<SavingsAccountMenuWidget> {
  String lockupPeriod = '';
  bool isCreatingSavings = false;
  final savingsAccountNameController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(20))),
      content: SizedBox(
        width: width(context) * 0.8,
        child: ListView(
          shrinkWrap: true,
          physics: const BouncingScrollPhysics(),
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  widget.accountName,
                  style: GoogleFonts.ubuntu(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: Colors.grey[900]),
                ),
                const SizedBox(height: 20),
                GestureDetector(
                  onTap: () async => changePage(
                    context,
                    TransferToSavingsPage(
                      accountID: widget.savingsAccountID,
                      accountName: widget.accountName,
                      accountType: widget.accountType,
                      backendType: "Supabase",
                    ),
                  ),
                  child: Container(
                    width: width(context) * 0.9,
                    height: height(context) * 0.06,
                    alignment: Alignment.centerLeft,
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: const BorderRadius.all(
                        Radius.circular(25),
                      ),
                    ),
                    child: Text(
                      "Add Money",
                      style: GoogleFonts.ubuntu(
                        color: Colors.grey[700],
                        fontSize: 15,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                GestureDetector(
                  onTap: () async => changePage(
                    context,
                    SharedNasAccountTransactionsPage(
                        savingsAccID: widget.savingsAccountID),
                  ),
                  child: Container(
                    alignment: Alignment.centerLeft,
                    width: width(context) * 0.9,
                    height: height(context) * 0.06,
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: const BorderRadius.all(
                        Radius.circular(25),
                      ),
                    ),
                    child: Text(
                      "See Transactions",
                      style: GoogleFonts.ubuntu(
                        color: Colors.grey[700],
                        fontSize: 15,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
