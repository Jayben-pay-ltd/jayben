import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'components/all_transactions_tile.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:jayben/Utilities/general_widgets.dart';
import 'components/time_limited_transaction_tile.dart';
import 'package:jayben/Utilities/provider_functions.dart';
import '../drawer/elements/components/ProfileWidgets.dart';

class AllTransactionsPage extends StatefulWidget {
  const AllTransactionsPage({Key? key}) : super(key: key);

  @override
  _AllTransactionsPageState createState() => _AllTransactionsPageState();
}

class _AllTransactionsPageState extends State<AllTransactionsPage> {
  @override
  void initState() {
    context.read<HomeProviderFunctions>().getAllTransactions();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<HomeProviderFunctions>(
      builder: (_, value, child) {
        return AnnotatedRegion<SystemUiOverlayStyle>(
          value: SystemUiOverlayStyle.dark,
          child: Scaffold(
            backgroundColor: Colors.white,
            body:
                value.returnAllTransactions() == null || value.returnIsLoading()
                    ? loadingScreenPlainNoBackButton(context)
                    : SafeArea(
                        bottom: false,
                        child: Stack(
                          children: [
                            Container(
                              width: width(context),
                              height: height(context),
                              color: Colors.white,
                              child: RepaintBoundary(
                                child: MediaQuery.removePadding(
                                  context: context,
                                  removeTop: true,
                                  child: RefreshIndicator(
                                    displacement: 60,
                                    onRefresh: () async {
                                      // plays refresh sound
                                      await playSound('refresh.mp3');

                                      await value.getAllTransactions();
                                    },
                                    child: ListView(
                                      shrinkWrap: true,
                                      addRepaintBoundaries: true,
                                      padding: const EdgeInsets.only(top: 45),
                                      physics: const BouncingScrollPhysics(),
                                      children: const [
                                        // TimeLtdTranxTile(),
                                        AllTransactionsTile(),
                                      ],
                                    ),
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
      },
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
