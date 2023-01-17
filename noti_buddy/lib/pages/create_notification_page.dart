import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:noti_buddy/extensions/date_time_extensions.dart';
import 'package:noti_buddy/managers/app_manager.dart';
import 'package:noti_buddy/models/notification_item.dart';
import 'package:noti_buddy/widgets/colour_picker.dart';
import 'package:noti_buddy/widgets/date_time_picker.dart';
import 'package:noti_buddy/widgets/item_list_decoration.dart';
import 'package:uuid/uuid.dart';

class CreateNotificationPage extends StatefulWidget {
  const CreateNotificationPage({super.key});

  @override
  State<CreateNotificationPage> createState() => _CreateNotificationPageState();
}

class _CreateNotificationPageState extends State<CreateNotificationPage> {
  final _formKey = GlobalKey<FormState>();

  final _titleController = TextEditingController();
  final _bodyController = TextEditingController();

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
    _titleController.dispose();
    _bodyController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Notification'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          children: [
            ListTile(
              title: TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Title',
                ),
                validator: (value) => value!.isEmpty ? 'Please enter a title' : null,
              ),
            ),
            ListTile(
              title: TextFormField(
                controller: _bodyController,
                decoration: const InputDecoration(
                  labelText: 'Body',
                ),
              ),
            ),
            SwitchListTile(
              value: _isScheduled,
              title: const Text('Schedule'),
              onChanged: (value) {
                setState(() {
                  _isScheduled = value;
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
            SwitchListTile(
              value: _isPersistent,
              title: const Text('Persistent'),
              onChanged: (value) {
                setState(() {
                  _isPersistent = value;
                });
              },
            ),
            ListTile(
              title: const Text('Colour'),
              leading: ItemListDecoration(colour: _colour),
              onTap: () {
                showColourPicker(context: context, initialColour: _colour).then((value) {
                  if (value != null) {
                    setState(() {
                      _colour = value;
                    });
                  }
                });
              },
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          if (!_formKey.currentState!.validate()) return;

          AppManager.instance.addItem(
            NotificationItem(
              id: const Uuid().v4(),
              title: _titleController.text,
              body: _bodyController.text,
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
