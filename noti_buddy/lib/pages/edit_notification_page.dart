import 'package:flutter/material.dart';
import 'package:noti_buddy/extensions/date_time_extensions.dart';
import 'package:noti_buddy/managers/app_manager.dart';
import 'package:noti_buddy/models/notification_item.dart';
import 'package:noti_buddy/widgets/date_time_picker.dart';

class EditNotificationPage extends StatefulWidget {
  final NotificationItem item;

  const EditNotificationPage({
    required this.item,
    super.key,
  });

  @override
  State<EditNotificationPage> createState() => _EditNotificationPageState();
}

class _EditNotificationPageState extends State<EditNotificationPage> {
  final titleController = TextEditingController();
  final bodyController = TextEditingController();

  late NotificationItem _item;
  late bool _isScheduled;

  late DateTime _dateTime;

  @override
  void initState() {
    _item = widget.item;

    var now = DateTime.now();
    _dateTime = DateTime(now.year, now.month, now.day, now.hour + 1, 0, 0);

    _isScheduled = _item.dateTime != null;

    titleController.text = _item.title;
    bodyController.text = _item.body ?? '';

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
        title: const Text('Edit Notification'),
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
            value: _item.persistant,
            title: const Text('Persistant'),
            onChanged: (value) {
              setState(() {
                _item.persistant = value!;
              });
            },
          ),
          Text('Colour: ${Colors.red}'),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          _item.title = titleController.text;
          _item.body = bodyController.text;
          _item.dateTime = _isScheduled ? _dateTime : null;

          AppManager.instance.editItem(_item);

          if (mounted) {
            Navigator.of(context).pop();
          }
        },
        label: const Text('Save'),
        icon: const Icon(Icons.save),
      ),
    );
  }
}
