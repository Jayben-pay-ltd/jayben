// ignore_for_file: non_constant_identifier_names

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'components/message_bubble_widgets.dart';
import 'package:jayben/Utilities/provider_functions.dart';

class MessageBubble extends StatelessWidget {
  const MessageBubble({Key? key, required this.message_info}) : super(key: key);

  final Map message_info;

  @override
  Widget build(BuildContext context) {
    return Consumer<MessageProviderFunctions>(builder: (_, value, child) {
      final isHighlighted = value
          .returnMessagesToHighlight()
          .contains(message_info["message_id"]);
      return GestureDetector(
        onLongPress: () =>
            value.addRemoveToMessagesToHighlight(message_info["message_id"]),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 500),
          curve: Curves.fastOutSlowIn,
          color: isHighlighted
              ? Colors.teal[300]!.withOpacity(0.3)
              : Colors.transparent,
          child: Align(
            alignment: customAlignments(message_info),
            child: ConstrainedBox(
              constraints: customConstraints(context, message_info),
              child: messageBody(context, message_info),
            ),
          ),
        ),
      );
    });
  }
}
