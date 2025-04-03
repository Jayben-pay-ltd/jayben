import 'package:flutter/material.dart';
import 'package:jayben/Home/elements/admin/elements/components/broadcast_notifications_widget.dart';

class SendNotificationPage extends StatefulWidget {
  const SendNotificationPage({super.key});

  @override
  State<SendNotificationPage> createState() => _SendNotificationPageState();
}

class _SendNotificationPageState extends State<SendNotificationPage> {
  final descriptionController = TextEditingController();
  final titleController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      floatingActionButton: floatingButton(context, {
        "descController": descriptionController,
        "titleController": titleController,
      }),
      body: createNotificationBody(context, {
        "descController": descriptionController,
        "titleController": titleController,
      }),
    );
  }
}
