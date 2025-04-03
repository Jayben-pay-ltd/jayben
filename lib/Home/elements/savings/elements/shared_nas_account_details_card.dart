// ignore_for_file: non_constant_identifier_names

import 'package:flutter/cupertino.dart';
import 'package:jayben/Utilities/provider_functions.dart';
import 'package:jayben/Home/elements/savings/elements/components/shared_nas_account_details_card_widgets.dart';

class SharedNasAccDetailsCard extends StatefulWidget {
  const SharedNasAccDetailsCard({super.key, required this.account_map});

  final Map account_map;

  @override
  State<SharedNasAccDetailsCard> createState() =>
      _SharedNasAccDetailsCardState();
}

class _SharedNasAccDetailsCardState extends State<SharedNasAccDetailsCard> {
  double _dragStartY = 0.0;
  double _currentY = 0.0;

  @override
  Widget build(BuildContext context) {
    // gets all the acc bal share maps for all members
    List<dynamic> members_list = widget.account_map["account_balance_shares"];

    // gets the user's existing acc bal share map's index
    int index =
        members_list.indexWhere((map) => map["user_id"] == box("user_id"));

    // gets the user's acc bal share map
    Map user_map = members_list[index];
    return GestureDetector(
      onVerticalDragEnd: _onDragEnd,
      onVerticalDragStart: _onDragStart,
      onVerticalDragUpdate: _onDragUpdate,
      child: AnimatedContainer(
        decoration: deco(),
        height: height(context) * 0.7,
        padding: const EdgeInsets.only(top: 30),
        duration: const Duration(milliseconds: 1),
        transform: Matrix4.translationValues(0.0, _currentY, 0.0),
        child: accountDetailsBody(context, {
          "acc_map": widget.account_map,
          "user_map": user_map,
        }),
      ),
    );
  }

  Decoration deco() {
    return const BoxDecoration(
      color: CupertinoColors.white,
      borderRadius: BorderRadius.only(
        topRight: Radius.circular(30),
        topLeft: Radius.circular(30),
      ),
    );
  }

  void _onDragStart(DragStartDetails details) {
    _dragStartY = details.globalPosition.dy;
  }

  void _onDragUpdate(DragUpdateDetails details) {
    var value = details.globalPosition.dy - _dragStartY;

    if (value < 0) return;

    setState(() {
      _currentY = value;
    });
  }

  void _onDragEnd(DragEndDetails details) {
    if (_currentY > 150) {
      Navigator.pop(context);
    } else {
      setState(() {
        _currentY = 0.0;
      });
    }
  }
}
