// ignore_for_file: non_constant_identifier_names, constant_identifier_names
import 'package:jayben/Home/elements/timeline_privacy_settings/all_contacts_except.dart';
import 'package:jayben/Home/elements/timeline_privacy_settings/only_share_with.dart';
import '../../drawer/elements/components/ProfileWidgets.dart';
import 'package:jayben/Utilities/provider_functions.dart';
import 'package:jayben/Utilities/constants.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';

Widget timelinePrivacySettingAppbar(BuildContext context) {
  return Consumer<FeedProviderFunctions>(builder: (_, value, child) {
    return Positioned(
      top: 0,
      child: Stack(
        children: [
          Container(
            width: width(context),
            decoration: appBarDeco(),
            alignment: Alignment.center,
            padding: const EdgeInsets.only(bottom: 10, left: 10, right: 10),
            child: Text(
              "Privacy",
              textAlign: TextAlign.center,
              style: GoogleFonts.ubuntu(
                color: const Color.fromARGB(255, 54, 54, 54),
                fontWeight: FontWeight.bold,
                fontSize: 30,
              ),
            ),
          ),
          Positioned(
            left: 20,
            bottom: 5,
            child: InkWell(
              onTap: () => goBack(context),
              child: const SizedBox(
                child: Icon(
                  color: Colors.black,
                  Icons.arrow_back,
                  size: 40,
                ),
              ),
            ),
          ),
          Positioned(
            right: 20,
            top: 5,
            child: GestureDetector(
              onTap: () async {
                value.toggleIsLoading();
                value.clearCurrentTimelimePrivacySettings();
                await value.getCurrentTimelinePrivacySetting();
                await value.getUploadedContacts();
                value.toggleIsLoading();
              },
              child: SizedBox(
                child: Text(
                  "Refresh",
                  style: googleStyle(
                    color: Colors.green,
                    size: 20,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  });
}

enum TimelineSetting {
  all_contacts,
  all_contacts_except,
  only_share_with,
  none
}

class TimelinePrivacySettingsBody extends StatefulWidget {
  const TimelinePrivacySettingsBody({super.key});

  @override
  State<TimelinePrivacySettingsBody> createState() =>
      _TimelinePrivacySettingsBodyState();
}

class _TimelinePrivacySettingsBodyState
    extends State<TimelinePrivacySettingsBody> {
  @override
  void initState() {
    String? current_settting = context
        .read<FeedProviderFunctions>()
        .returnCurrentTimelinePrivacySetting();

    if (current_settting == "All contacts") {
      setState(() => _setting = TimelineSetting.all_contacts);
    } else if (current_settting == "All contacts except") {
      setState(() => _setting = TimelineSetting.all_contacts_except);
    } else if (current_settting == "Only share with") {
      setState(() => _setting = TimelineSetting.only_share_with);
    } else if (current_settting == "Nobody") {
      setState(() => _setting = TimelineSetting.none);
    }
    super.initState();
  }

  TimelineSetting? _setting;

  @override
  Widget build(BuildContext context) {
    return Consumer<FeedProviderFunctions>(
      builder: (_, prov, child) {
        return RepaintBoundary(
          child: Container(
            color: Colors.white,
            width: width(context),
            height: height(context),
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.only(top: 60),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.only(left: 25.0),
                  child: Text(
                    "Control who can see my timeline posts",
                    style: TextStyle(
                      fontWeight: FontWeight.w400,
                      color: Colors.black54,
                      fontSize: 15,
                    ),
                  ),
                ),
                // hGap(10),
                RadioListTile<TimelineSetting>(
                  activeColor: Colors.green,
                  title: const Text('All contacts'),
                  value: TimelineSetting.all_contacts,
                  subtitle: Text(prov.returnMyContactsWithJaybenAccs() == null
                      ? ""
                      : "${prov.returnMyContactsWithJaybenAccs()!.length} people"),
                  groupValue: _setting,
                  onChanged: (TimelineSetting? value) async {
                    setState(() {
                      _setting = value;
                    });

                    await prov
                        .updateCurrentTimelinePrivacySetting("All contacts");

                    showSnackBar(context, "Privacy settings saved");
                  },
                ),
                RadioListTile<TimelineSetting>(
                  activeColor: Colors.green,
                  title: titleWidget('All contacts except...'),
                  subtitle: Text(prov.returnSelectedAllContactsExcept() == null
                      ? "0 excluded"
                      : "${prov.returnSelectedAllContactsExcept()!.length} excluded"),
                  value: TimelineSetting.all_contacts_except,
                  groupValue: _setting,
                  onChanged: (TimelineSetting? value) async {
                    setState(() => _setting = value);

                    await prov.updateCurrentTimelinePrivacySetting(
                        "All contacts except");

                    showSnackBar(context, "Privacy settings saved");
                  },
                ),
                RadioListTile<TimelineSetting>(
                  activeColor: Colors.green,
                  title: titleWidget('Only share with...'),
                  subtitle: Text(prov.returnSelectedOnlyShareWith() == null
                      ? "0 included"
                      : "${prov.returnSelectedOnlyShareWith()!.length} included"),
                  value: TimelineSetting.only_share_with,
                  groupValue: _setting,
                  onChanged: (TimelineSetting? value) async {
                    setState(() => _setting = value);

                    await prov
                        .updateCurrentTimelinePrivacySetting("Only share with");

                    showSnackBar(context, "Privacy settings saved");
                  },
                ),
                RadioListTile<TimelineSetting>(
                  activeColor: Colors.green,
                  title: const Text('Nobody...'),
                  subtitle: const Text("Everybody excluded"),
                  value: TimelineSetting.none,
                  groupValue: _setting,
                  onChanged: (TimelineSetting? value) async {
                    setState(() => _setting = value);

                    await prov.updateCurrentTimelinePrivacySetting("Nobody");

                    showSnackBar(context, "Privacy settings saved");
                  },
                ),
                hGap(10),
                const Padding(
                  padding: EdgeInsets.only(left: 25.0, right: 20),
                  child: Text(
                    "*Changes to your privacy settings won't affect existing posts. Please note transaction amounts are NOT included in timeline posts.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontWeight: FontWeight.w300,
                      color: Colors.black54,
                      fontSize: 12,
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

  Widget titleWidget(String privacy_setting_name) {
    return Padding(
      padding: const EdgeInsets.only(right: 10.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            privacy_setting_name,
            overflow: TextOverflow.ellipsis,
            maxLines: 3,
            style: const TextStyle(color: Colors.black, fontSize: 16.0),
          ),
          InkWell(
            onTap: () {
              switch (privacy_setting_name) {
                case "All contacts except...":
                  changePage(context, const AllContactsExceptPage());
                  break;
                case "Only share with...":
                  changePage(context, const OnlyShareWithPage());
                  break;
              }
            },
            child: const SizedBox(
              child: Text(
                "EDIT",
                style: TextStyle(color: Colors.green),
              ),
            ),
          )
        ],
      ),
    );
  }
}
