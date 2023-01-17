import 'package:fluentui_system_icons/fluentui_system_icons.dart';
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
  final _formKey = GlobalKey<FormState>();

  final _titleController = TextEditingController();
  final _bodyController = TextEditingController();

  late NotificationItem _item;
  late bool _isScheduled;

  late DateTime _dateTime;

  @override
  void initState() {
    _item = widget.item;

    var now = DateTime.now();
    _dateTime = DateTime(now.year, now.month, now.day, now.hour + 1, 0, 0);

    _isScheduled = _item.dateTime != null;

    _titleController.text = _item.title;
    _bodyController.text = _item.body ?? '';

    super.initState();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _bodyController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Notification'),
        actions: [
          IconButton(
            icon: const Icon(FluentIcons.delete_16_filled),
            onPressed: () {
              AppManager.instance.deleteItem(_item.id);
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Title',
              ),
              validator: (value) => value!.isEmpty ? 'Please enter a title' : null,
            ),
            TextFormField(
              controller: _bodyController,
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
                title: const Text('Send'),
                subtitle: Text(_dateTime.toRelativeDateTimeString(alwaysShowDay: true)),
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
              value: _item.persistent,
              title: const Text('Persistent'),
              onChanged: (value) {
                setState(() {
                  _item.persistent = value!;
                });
              },
            ),
            Text('Colour: ${Colors.red}'),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          if (!_formKey.currentState!.validate()) return;

          _item.title = _titleController.text;
          _item.body = _bodyController.text;
          _item.dateTime = _isScheduled ? _dateTime : null;
          _item.archived = false; // Unarchive if we edit an archived item

          AppManager.instance.editItem(_item);

          if (mounted) {
            Navigator.of(context).pop();
          }
        },
        label: const Text('Save'),
        icon: const Icon(FluentIcons.save_16_filled),
      ),
    );
  }
}
