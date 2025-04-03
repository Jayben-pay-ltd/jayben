// ignore_for_file: file_names
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:jayben/Utilities/constants.dart';
import 'package:jayben/Utilities/general_widgets.dart';
import 'package:jayben/Utilities/provider_functions.dart';
import '../../drawer/elements/components/ProfileWidgets.dart';
import 'package:jayben/Home/elements/savings/elements/components/shared_nas_account_transaction_tile.dart';

class SharedNasAccountTransactionsPage extends StatefulWidget {
  const SharedNasAccountTransactionsPage({Key? key, required this.savingsAccID})
      : super(key: key);

  final String savingsAccID;

  @override
  _SharedNasAccountTransactionsPageState createState() =>
      _SharedNasAccountTransactionsPageState();
}

class _SharedNasAccountTransactionsPageState
    extends State<SharedNasAccountTransactionsPage>
    with WidgetsBindingObserver {
  @override
  void initState() {
    onPagelaunch().whenComplete(() {
      setState(() {});
    });
    super.initState();
  }

  List<dynamic>? myTransactions;
  bool isLoading = false;
  bool? hasTransactions;
  bool? isEmpty;

  Future<void> onPagelaunch() async {
    var snapshot = await context
        .read<SavingsProviderFunctions>()
        .getSharedNasAccTranxs(widget.savingsAccID);

    if (!mounted) return;
    if (mounted) {
      setState(() {
        myTransactions = snapshot;
      });
    }

    if (myTransactions == null) {
      setState(() {
        isEmpty = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Stack(
            children: [
              Container(
                height: height(context),
                width: width(context),
                color: Colors.white,
                child: myTransactions == null || isLoading
                    ? loadingScreenPlainNoBackButton(context)
                    : myTransactions!.isEmpty
                        ? Center(
                            child: Text(
                              "No transactions yet",
                              style: googleStyle(
                                weight: FontWeight.w400,
                                color: Colors.green,
                              ),
                            ),
                          )
                        : RepaintBoundary(
                            child: RefreshIndicator(
                              onRefresh: () async {
                                // plays refresh sound
                                await playSound('refresh.mp3');

                                await onPagelaunch();
                              },
                              displacement: 60,
                              child: ListView(
                                padding: const EdgeInsets.only(top: 40),
                                physics: const BouncingScrollPhysics(),
                                children: [
                                  Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Flexible(
                                        child: SharedNasAccountTransactionTile(
                                          myTransactions: myTransactions,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
              ),
              customAppBar(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget customAppBar(BuildContext context) {
    return Positioned(
      top: 0,
      child: Container(
        width: width(context),
        decoration: appBarDeco(),
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.only(bottom: 10, left: 10, right: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            wGap(10),
            InkWell(
              onTap: () => goBack(context),
              child: const SizedBox(
                child: Icon(
                  color: Colors.black,
                  Icons.arrow_back,
                  size: 40,
                ),
              ),
            ),
            const Spacer(),
            Text.rich(
              const TextSpan(text: "Transactions"),
              textAlign: TextAlign.left,
              style: GoogleFonts.ubuntu(
                color: const Color.fromARGB(255, 54, 54, 54),
                fontWeight: FontWeight.bold,
                fontSize: 24,
              ),
            ),
            const Spacer(),
            wGap(50),
          ],
        ),
      ),
    );
  }
}
