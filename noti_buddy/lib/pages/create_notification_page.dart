import 'package:flutter/material.dart';
import 'package:noti_buddy/models/app_data.dart';
import 'package:noti_buddy/models/notification_item.dart';
import 'package:noti_buddy/widgets/date_time_picker.dart';

class CreateNotificationPage extends StatefulWidget {
  const CreateNotificationPage({super.key});

  @override
  State<CreateNotificationPage> createState() => _CreateNotificationPageState();
}

class _CreateNotificationPageState extends State<CreateNotificationPage> {
  final titleController = TextEditingController();
  final bodyController = TextEditingController();

  var _isScheduled = false;
  var _isPersistant = false;

  late DateTime _dateTime;
  late Color _colour;

  @override
  void initState() {
    var now = DateTime.now();
    _dateTime = DateTime(now.year, now.month, now.day, now.hour + 1, 0, 0);

    _colour = Colors.blue;

    super.initState();
  }

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
          CheckboxListTile(
            value: _isScheduled,
            title: const Text('Schedule'),
            onChanged: (value) {
              setState(() {
                _isScheduled = value!;
              });
            },
          ),
          if (_isScheduled)
            ListTile(
              title: const Text('Send at'),
              subtitle: Text('$_dateTime'),
              onTap: () {
                showDateTimePicker(
                  context: context,
                  initialDateTime: _dateTime,
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(
                    const Duration(days: 365),
                  ),
                ).then((value) {
                  if (value != null) {
                    setState(() {
                      _dateTime = value;
                    });
                  }
                });
              },
            ),
          CheckboxListTile(
            value: _isPersistant,
            title: const Text('Persistant'),
            onChanged: (value) {
              setState(() {
                _isPersistant = value!;
              });
            },
          ),
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
