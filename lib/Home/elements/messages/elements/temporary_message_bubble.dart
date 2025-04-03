// ignore_for_file: non_constant_identifier_names
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../Utilities/provider_functions.dart';
import 'components/temporary_message_bubble_widgets.dart';

class TemporaryMessageBubble extends StatelessWidget {
  const TemporaryMessageBubble({Key? key, required this.message_info})
      : super(key: key);

  final Map message_info;

  @override
  Widget build(BuildContext context) {
    return Consumer<MessageProviderFunctions>(
      builder: (_, value, child) {
        return box("showTempMsg") == false
            ? nothing()
            : Container(
                width: width(context),
                alignment: Alignment.centerRight,
                child: Container(
                  color: Colors.transparent,
                  child: Align(
                    alignment: customAlignments(message_info),
                    child: ConstrainedBox(
                      constraints: customConstraints(context, message_info),
                      child: messageBody(context, message_info),
                    ),
                  ),
                ),
              );
      },
    );
  }
}
