import 'firebase_options.dart';
import 'package:flutter/services.dart';
import 'Utilities/Initialization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'Utilities/hive_and_notification_functions.dart';
import 'package:jayben/Utilities/provider_functions.dart';
import 'package:responsive_framework/responsive_framework.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  await Future.wait([
    NotifFunctions().initLocalNotifications(),
    HiveFunctions().initializeHive(),
    NotifFunctions().mainNotif(),
    initSupabase(),
  ]);

  // Get any initial links
  // final PendingDynamicLinkData? initialLink =
  //     await FirebaseDynamicLinks.instance.getInitialLink();

  // debugRepaintRainbowEnabled = true;

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: KycProviderFunctions()),
        ChangeNotifierProvider.value(value: NfcProviderFunctions()),
        ChangeNotifierProvider.value(value: UssdProviderFunctions()),
        ChangeNotifierProvider.value(value: UserProviderFunctions()),
        ChangeNotifierProvider.value(value: AuthProviderFunctions()),
        ChangeNotifierProvider.value(value: HomeProviderFunctions()),
        ChangeNotifierProvider.value(value: FeedProviderFunctions()),
        ChangeNotifierProvider.value(value: GiftProviderFunctions()),
        ChangeNotifierProvider.value(value: AdminProviderFunctions()),
        ChangeNotifierProvider.value(value: AgentProviderFunctions()),
        ChangeNotifierProvider.value(value: VideoProviderFunctions()),
        ChangeNotifierProvider.value(value: AttachProviderFunctions()),
        ChangeNotifierProvider.value(value: SavingsProviderFunctions()),
        ChangeNotifierProvider.value(value: PaymentProviderFunctions()),
        ChangeNotifierProvider.value(value: AirtimeProviderFunctions()),
        ChangeNotifierProvider.value(value: DepositProviderFunctions()),
        ChangeNotifierProvider.value(value: MessageProviderFunctions()),
        ChangeNotifierProvider.value(value: ReferralProviderFunctions()),
        ChangeNotifierProvider.value(value: WithdrawProviderFunctions()),
        ChangeNotifierProvider.value(value: QRScannerProviderFunctions()),
      ],
      builder: (context, child) => Builder(
        builder: (_) {
          // gets app's current build version & stores it locally
          context.read<AuthProviderFunctions>().getBuildVersion();
          return MyApp();
        },
      ),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  // final PendingDynamicLinkData? initialLink;
  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      systemNavigationBarColor: Colors.transparent,
      statusBarColor: Colors.transparent,
    ));
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: MaterialApp(
        title: 'Jayben',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: false,
          primaryColor: Colors.transparent,
          scaffoldBackgroundColor: Colors.transparent,
        ),
        builder: (_, widget) => ResponsiveWrapper.builder(
          background: Container(color: Colors.transparent),
          backgroundColor: Colors.transparent,
          maxWidth: 3200,
          minWidth: 450,
          widget,
          breakpoints: [
            const ResponsiveBreakpoint.resize(450, name: MOBILE),
            const ResponsiveBreakpoint.resize(1200, name: DESKTOP),
            const ResponsiveBreakpoint.autoScale(2460, name: "4K"),
            const ResponsiveBreakpoint.autoScale(800, name: TABLET),
            const ResponsiveBreakpoint.autoScale(1000, name: TABLET),
          ],
        ),
        home: InitializerWidget(),
      ),
    );
  }
}
