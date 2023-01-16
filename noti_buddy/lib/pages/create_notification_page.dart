import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:noti_buddy/extensions/date_time_extensions.dart';
import 'package:noti_buddy/managers/app_manager.dart';
import 'package:noti_buddy/models/notification_item.dart';
import 'package:noti_buddy/widgets/date_time_picker.dart';
import 'package:uuid/uuid.dart';

class CreateNotificationPage extends StatefulWidget {
  const CreateNotificationPage({super.key});

  @override
  State<CreateNotificationPage> createState() => _CreateNotificationPageState();
}

class _CreateNotificationPageState extends State<CreateNotificationPage> {
  final titleController = TextEditingController();
  final bodyController = TextEditingController();

  var _isScheduled = false;
  var _isPersistent = false;

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
              subtitle: Text(_dateTime.toDateTimeString()),
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
            value: _isPersistent,
            title: const Text('Persistent'),
            onChanged: (value) {
              setState(() {
                _isPersistent = value!;
              });
            },
          ),
          Text('Colour: ${Colors.red}'),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          AppManager.instance.addItem(
            NotificationItem(
              id: const Uuid().v4(),
              title: titleController.text,
              body: bodyController.text,
              dateTime: _isScheduled ? _dateTime : null,
              colour: _colour,
              persistent: _isPersistent,
            ),
          );

          if (mounted) {
            Navigator.of(context).pop();
          }
        },
        label: const Text('Add'),
        icon: const Icon(FluentIcons.add_16_filled),
      ),
    );
  }
}
