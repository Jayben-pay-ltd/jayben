import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'components/create_pin_bottom_card_widgets.dart';
import 'package:jayben/Utilities/provider_functions.dart';

class CreatePinBottomCard extends StatefulWidget {
  const CreatePinBottomCard({super.key});

  @override
  State<CreatePinBottomCard> createState() => _CreatePinBottomCardState();
}

class _CreatePinBottomCardState extends State<CreatePinBottomCard> {
  @override
  void initState() {
    context.read<NfcProviderFunctions>().clearStrings();
    super.initState();
  }

  double _currentY = 0.0;
  double _dragStartY = 0.0;
  final focusNode = FocusNode();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onVerticalDragEnd: _onDragEnd,
      onVerticalDragStart: _onDragStart,
      onVerticalDragUpdate: _onDragUpdate,
      child: AnimatedContainer(
        decoration: deco(),
        height: height(context) * 0.85,
        padding: const EdgeInsets.only(top: 30),
        duration: const Duration(milliseconds: 1),
        transform: Matrix4.translationValues(0.0, _currentY, 0.0),
        child: createPinBody(context, focusNode),
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
