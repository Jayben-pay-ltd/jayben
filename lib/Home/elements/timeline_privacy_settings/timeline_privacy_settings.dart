import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../Utilities/general_widgets.dart';
import 'package:jayben/Utilities/provider_functions.dart';
import 'package:jayben/Home/elements/timeline_privacy_settings/components/timeline_privacy_settings_widgets.dart';

class TimelinePrivacySettingsPage extends StatefulWidget {
  const TimelinePrivacySettingsPage({Key? key}) : super(key: key);

  @override
  State<TimelinePrivacySettingsPage> createState() =>
      _TimelinePrivacySettingsPageState();
}

class _TimelinePrivacySettingsPageState
    extends State<TimelinePrivacySettingsPage> {
  @override
  void initState() {
    var prov = context.read<FeedProviderFunctions>();
    prov.clearCurrentTimelimePrivacySettings();
    prov.getCurrentTimelinePrivacySetting();
    prov.getUploadedContacts();
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        systemNavigationBarIconBrightness: Brightness.light,
        statusBarIconBrightness: Brightness.dark,
        systemNavigationBarColor: Colors.black,
        systemStatusBarContrastEnforced: true,
        statusBarBrightness: Brightness.dark,
        statusBarColor: Colors.transparent,
      ),
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Consumer<FeedProviderFunctions>(
        builder: (_, value, child) {
          return value.returnCurrentTimelinePrivacySetting() == null
              ? loadingScreenPlainNoBackButton(context)
              : Scaffold(
                  backgroundColor: Colors.white,
                  body: SafeArea(
                    bottom: false,
                    child: Stack(
                      children: [
                        const TimelinePrivacySettingsBody(),
                        timelinePrivacySettingAppbar(context),
                      ],
                    ),
                  ),
                );
        },
      ),
    );
  }
}
