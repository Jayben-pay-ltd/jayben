// ignore_for_file: non_constant_identifier_names

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../Utilities/general_widgets.dart';
import 'package:jayben/Utilities/provider_functions.dart';
import 'package:jayben/Home/elements/agent_deposits/components/agent_deposits_widget.dart';

class AgentDepositsPage extends StatefulWidget {
  const AgentDepositsPage({Key? key, required this.amount}) : super(key: key);

  final double amount;

  @override
  State<AgentDepositsPage> createState() => _MyContactsPageState();
}

class _MyContactsPageState extends State<AgentDepositsPage>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
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
    onPageLaunch();
    super.initState();
  }

  // gets phone contacts, uploads them & then gets contacts from server
  Future<void> onPageLaunch() async {
    var prov = context.read<AgentProviderFunctions>();

    await prov.getActiveAgents();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Consumer<AgentProviderFunctions>(
        builder: (_, value, child) {
          return value.returnActiveAgents() == null
              ? loadingScreenPlainNoBackButton(context)
              : Scaffold(
                  backgroundColor: Colors.white,
                  body: SafeArea(
                    bottom: false,
                    child: Stack(
                      children: [
                        value.returnAgentsCurrentIndex() == 0
                            ? AgentsBody(amount: widget.amount,)
                            : const ActiveOrders(),
                        agentsAppbar(context),
                      ],
                    ),
                  ),
                );
        },
      ),
    );
  }
}
