// ignore_for_file: non_constant_identifier_names
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:jayben/Utilities/general_widgets.dart';
import 'package:jayben/Utilities/provider_functions.dart';
import 'package:jayben/Home/elements/admin/components/admin_page_wdigets.dart';
import 'package:jayben/Home/elements/admin/elements/supabase_transaction_tile.dart';
import 'package:jayben/Home/elements/admin/elements/verification_request_tile.dart';

class AdminPage extends StatefulWidget {
  const AdminPage({Key? key}) : super(key: key);

  @override
  _AdminPageState createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> with TickerProviderStateMixin {
  @override
  void initState() {
    onPageLaunch();
    tab_controller = TabController(length: 3, vsync: this);
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        systemNavigationBarIconBrightness: Brightness.dark,
        statusBarIconBrightness: Brightness.dark,
        systemNavigationBarColor: Colors.white,
        statusBarBrightness: Brightness.light,
        statusBarColor: Colors.transparent,
      ),
    );
    super.initState();
  }

  TabController? tab_controller;

  Future<void> onPageLaunch() async {
    AdminProviderFunctions prov = context.read<AdminProviderFunctions>();

    prov.resetSettings();

    await Future.wait([
      prov.getPendingVerificationRequests(),
      prov.getPendingWithdrawalsFirebase(),
      prov.getAdminMetricsDocument(),
      prov.getPendingWithdrawals(),
      prov.getCountableMetrics(),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AdminProviderFunctions>(
      builder: (_, value, child) {
        return AnnotatedRegion<SystemUiOverlayStyle>(
          value: SystemUiOverlayStyle.dark,
          child: Scaffold(
            backgroundColor: Colors.white,
            body: 
            
            // value.returnAdminMetricsDocument() == null
            //     ? loadingScreenPlainNoBackButton(context)
            //     :
                 SafeArea(
                    bottom: false,
                    child: Stack(
                      children: [
                        Container(
                          color: Colors.white,
                          width: width(context),
                          height: height(context),
                          child: RepaintBoundary(
                            child: RefreshIndicator(
                              onRefresh: () async {
                                value.toggleIsLoading();

                                // plays refresh sound
                                await playSound('refresh.mp3');

                                await Future.wait([
                                  value.getAdminMetricsDocument(),
                                  value.getCountableMetrics(),
                                ]);

                                value.toggleIsLoading();
                              },
                              child: TabBarView(
                                controller: tab_controller,
                                children: [
                                  metricsBody(context),
                                  const AdminVerificationRequestTile(),
                                  const SupabaseAdminTransactionsListBuilder(),
                                ],
                              ),
                            ),
                          ),
                        ),
                        floatingWidget(context),
                        appBar(context, tab_controller),
                      ],
                    ),
                  ),
          ),
        );
      },
    );
  }
}
