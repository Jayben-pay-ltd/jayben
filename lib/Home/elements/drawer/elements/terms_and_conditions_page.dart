// ignore_for_file: file_names, non_constant_identifier_names

// import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'components/ProfileWidgets.dart';
import 'package:expandable/expandable.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:jayben/Utilities/constants.dart';
import 'package:jayben/Utilities/provider_functions.dart';

class TermsAndConditionsPage extends StatefulWidget {
  const TermsAndConditionsPage({Key? key}) : super(key: key);

  @override
  State<TermsAndConditionsPage> createState() => _TermsAndConditionsPageState();
}

class _TermsAndConditionsPageState extends State<TermsAndConditionsPage> {
  @override
  void initState() {
    context.read<AuthProviderFunctions>().getTOS();
    super.initState();
  }

  final expandableController = ExpandableController(initialExpanded: true);

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          bottom: false,
          child: SizedBox(
            width: width(context),
            height: height(context),
            child: Stack(
              children: [
                tcsBody(context),
                customAppBar(context),
              ],
            ),
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
              const TextSpan(text: "Terms & Conditions"),
              textAlign: TextAlign.left,
              style: GoogleFonts.ubuntu(
                color: const Color.fromARGB(255, 54, 54, 54),
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
            const Spacer(),
            wGap(50),
          ],
        ),
      ),
    );
  }

  Widget tcsBody(BuildContext context) {
    return Consumer<AuthProviderFunctions>(builder: (_, value, child) {
      return Container(
        color: Colors.white,
        width: width(context),
        height: height(context),
        alignment: Alignment.center,
        padding: const EdgeInsets.only(top: 50),
        child: ListView(
          shrinkWrap: true,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: width(context),
                  padding: const EdgeInsets.only(top: 20),
                  child: Text(
                    value.returnJaybenEmail().isEmpty
                        ? "Includes Our Privacy Policies\n(Email Contact: loading...)"
                        : "Includes Our Privacy Policies\n(Email Contact: ${value.returnJaybenEmail()})",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.ubuntu(
                      fontWeight: FontWeight.w400,
                      color: Colors.green[400],
                      fontSize: 15,
                    ),
                  ),
                ),
                hGap(20),
                Container(
                  color: Colors.grey[100],
                  padding: const EdgeInsets.only(
                    bottom: 20,
                    right: 20,
                    left: 20,
                    top: 20,
                  ),
                  child: ExpandableNotifier(
                    controller: expandableController,
                    child: ScrollOnExpand(
                      scrollOnExpand: false,
                      scrollOnCollapse: true,
                      child: ExpandablePanel(
                        theme: ExpandableThemeData(
                            iconColor: iconColor, iconSize: 30),
                        header: const Text(
                          "Jayben Pay Limited Zambia @ 2025",
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 15,
                          ),
                        ),
                        collapsed: Text(
                          "Click here to view more terms & conditions",
                          softWrap: true,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.ubuntu(
                            color: Colors.green[500],
                            fontSize: 16,
                          ),
                        ),
                        expanded: Text(
                          value.tos.isEmpty ? "loading..." : value.tos,
                          textAlign: TextAlign.justify,
                          style: TextStyle(
                            color: iconColor,
                            fontSize: 15,
                          ),
                          softWrap: true,
                        ),
                      ),
                    ),
                  ),
                )
              ],
            ),
          ],
        ),
      );
    });
  }
}
