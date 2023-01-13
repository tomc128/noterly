import 'package:flutter/material.dart';
import 'package:noti_buddy/models/app_data.dart';
import 'package:noti_buddy/models/notification_item.dart';

class CreateNotificationPage extends StatefulWidget {
  const CreateNotificationPage({super.key});

  @override
  State<CreateNotificationPage> createState() => _CreateNotificationPageState();
}

class _CreateNotificationPageState extends State<CreateNotificationPage> {
  final titleController = TextEditingController();
  final bodyController = TextEditingController();

  @override
  void dispose() {
    titleController.dispose();
    bodyController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Notification'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(
            controller: titleController,
            decoration: const InputDecoration(
              labelText: 'Title',
            ),
          ),
          TextField(
            controller: bodyController,
            decoration: const InputDecoration(
              labelText: 'Body',
            ),
          ),
          Text('Date: ${DateTime.now().add(const Duration(days: 7))}'),
          Text('Colour: ${Colors.red}'),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          var appData = await AppData.instance;

          appData.notificationItems.add(
            NotificationItem(
              title: titleController.text,
              body: bodyController.text,
              dateTime: DateTime.now().add(const Duration(days: 7)),
              colour: Colors.red,
            ),
          );

          await appData.save();

          if (mounted) {
            Navigator.of(context).pop();
          }
        },
        label: const Text('Add'),
        icon: const Icon(Icons.add),
      ),
    );
  }
}
