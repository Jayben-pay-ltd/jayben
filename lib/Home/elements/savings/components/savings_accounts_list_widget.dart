import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:jayben/Utilities/constants.dart';
import 'package:jayben/Utilities/provider_functions.dart';
import 'package:jayben/Home/elements/savings/elements/components/top_20_shared_nas_account_tile.dart';
import 'package:jayben/Home/elements/savings/elements/components/shared_no_access_account_supabase_tile.dart';
import 'package:jayben/Home/elements/savings/elements/components/create_shared_no_access_account_dialogue.dart';

class SavingsAccountsListWidget extends StatefulWidget {
  const SavingsAccountsListWidget({Key? key}) : super(key: key);

  @override
  State<SavingsAccountsListWidget> createState() =>
      _SavingsAccountsListWidgetState();
}

class _SavingsAccountsListWidgetState extends State<SavingsAccountsListWidget> {
  @override
  Widget build(BuildContext context) {
    return Consumer2<HomeProviderFunctions, SavingsProviderFunctions>(
      builder: (_, value, value1, child) {
        bool state2 = value.returnMySharedNasAccounts() == null;
        return state2 || box("show_app_wide_top_20_nas_accounts") == null
            ? SizedBox(
                width: width(context),
                height: height(context) * 0.55,
                child: const Center(
                  child: CircularProgressIndicator(
                    color: Colors.black,
                    strokeWidth: 3,
                  ),
                ),
              )
            : MediaQuery.removePadding(
                removeTop: true,
                context: context,
                removeBottom: true,
                child: !box("show_app_wide_top_20_nas_accounts")
                    ? allActiveSavingsAccountsWidget(context)
                    : value1.returnCurrentSavingsFilterIndex() == 0
                        ? allActiveSavingsAccountsWidget(context)
                        : top20SharedNasAccountsWidget(context),
              );
      },
    );
  }

  Widget allActiveSavingsAccountsWidget(BuildContext context) {
    return Consumer<HomeProviderFunctions>(builder: (_, value, child) {
      return value.returnMySharedNasAccounts()!.isEmpty
          ? Container(
              alignment: Alignment.center,
              height: height(context) * 0.5,
              padding: const EdgeInsets.symmetric(horizontal: 45),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Image.asset("assets/piggy-bank.png", height: 90),
                  hGap(20),
                  Text(
                    "Create A No Access Account",
                    style: GoogleFonts.ubuntu(
                      fontWeight: FontWeight.w700,
                      color: Colors.black,
                      fontSize: 15,
                    ),
                  ),
                  hGap(8),
                  Text(
                    "🔒 Lock up your money for a chosen number of days."
                    "\nWhen the timer is up, its released to your wallet.",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.ubuntu(
                      fontWeight: FontWeight.w500,
                      color: Colors.grey[700],
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    "Stop yourself from spending recklessly"
                    "\nwith this account.",
                    textAlign: TextAlign.center,
                    style: googleStyle(
                      color: Colors.black54,
                      size: 15,
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    style: ButtonStyle(
                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25.0),
                        ),
                      ),
                      backgroundColor: MaterialStateProperty.all(
                        !box("nas_deposits_are_allowed")
                            ? Colors.grey
                            : Colors.green,
                      ),
                    ),
                    onPressed: () async {
                      if (!box("nas_deposits_are_allowed")) {
                        showSnackBar(context,
                            'You\'re not allowed to create savings accounts. Contact support.');

                        return;
                      }

                      showDialogue(
                          context, const CreateSharedNoAccessAccountDialogue());
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 15.0, vertical: 8),
                      child: Text(
                        "Create No Access Account",
                        style: GoogleFonts.ubuntu(
                          color: Colors.white,
                          fontSize: 18,
                        ),
                      ),
                    ),
                  )
                ],
              ),
            )
          : ListView(
              shrinkWrap: true,
              scrollDirection: Axis.vertical,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.only(left: 20, right: 20, bottom: 20),
              children: [
                for (Map doc in value.returnMySharedNasAccounts()!)
                  SharedNoAccessSavAccTileSupabase(account_info: doc),
              ],
            );
    });
  }

  Widget top20SharedNasAccountsWidget(BuildContext context) {
    return !box("show_app_wide_top_20_nas_accounts")
        ? nothing()
        : Consumer<HomeProviderFunctions>(
            builder: (_, value, child) {
              return ListView(
                shrinkWrap: true,
                scrollDirection: Axis.vertical,
                physics: const NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.only(left: 20, right: 20, bottom: 20),
                children: [
                  for (var i = 0;
                      i < value.returnTop20SharedNasAccounts()!.length;
                      i++)
                    Top20SharedNoAccessSavAccTileSupabase(
                      account_info: value.returnTop20SharedNasAccounts()![i],
                      number_in_top_20_list: i + 1,
                    )
                ],
              );
            },
          );
  }
}

// value.returnMySharedNasAccounts()!.isEmpty
//           ? Container(
//               alignment: Alignment.center,
//               height: height(context) * 0.5,
//               child: Column(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   Image.asset("assets/group_of_people.png", height: 90),
//                   hGap(20),
//                   Text(
//                     "Create A Group No Access Account",
//                     style: GoogleFonts.ubuntu(
//                       fontWeight: FontWeight.w700,
//                       color: Colors.black,
//                       fontSize: 15,
//                     ),
//                   ),
//                   hGap(8),
//                   Text(
//                     "Save For Vacations 🏖, Birthdays 🎁 or December 🎄",
//                     textAlign: TextAlign.center,
//                     style: GoogleFonts.ubuntu(
//                       fontWeight: FontWeight.w500,
//                       color: Colors.grey[700],
//                       fontSize: 12,
//                     ),
//                   ),
//                   hGap(10),
//                   Text(
//                     "When the timer is up, the money saved up"
//                     "\nis given back according to how much"
//                     "\neach person put in...",
//                     textAlign: TextAlign.center,
//                     style: googleStyle(
//                       color: Colors.black54,
//                       size: 15,
//                     ),
//                   ),
//                   hGap(20),
//                   ElevatedButton(
//                     style: ButtonStyle(
//                       shape: MaterialStateProperty.all<RoundedRectangleBorder>(
//                         RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(25.0),
//                         ),
//                       ),
//                       backgroundColor: MaterialStateProperty.all(
//                         !box("nas_deposits_are_allowed") ? Colors.grey : Colors.green,
//                       ),
//                     ),
//                     onPressed: () async {
//                       if (!box("nas_deposits_are_allowed")) {
//                         showSnackBar(context,
//                             'You\'re not allowed to create savings accounts. Contact support.');

//                         return;
//                       }

//                       showDialogue(
//                           context, const CreateSharedNoAccessAccountDialogue());
//                     },
//                     child: Padding(
//                       padding: const EdgeInsets.symmetric(
//                           horizontal: 15.0, vertical: 8),
//                       child: Text(
//                         "Create Group NAS Account",
//                         style: GoogleFonts.ubuntu(
//                           color: Colors.white,
//                           fontSize: 18,
//                         ),
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             )
//           :
