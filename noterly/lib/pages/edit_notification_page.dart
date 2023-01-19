import 'package:flutter/material.dart';
import 'package:noterly/extensions/date_time_extensions.dart';
import 'package:noterly/managers/app_manager.dart';
import 'package:noterly/models/notification_item.dart';
import 'package:noterly/widgets/colour_picker.dart';
import 'package:noterly/widgets/date_time_picker.dart';
import 'package:noterly/widgets/item_list_decoration.dart';

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
    _dateTime = _item.dateTime ?? DateTime(now.year, now.month, now.day, now.hour + 1, 0, 0);

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
            icon: const Icon(Icons.delete),
            onPressed: () {
              AppManager.instance.deleteItem(_item.id);
              ScaffoldMessenger.of(context).clearSnackBars(); // Clear any existing snackbars, as only one item can be restored.
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Notification deleted.'),
                  action: SnackBarAction(
                    label: 'Undo',
                    onPressed: () => AppManager.instance.restoreLastDeletedItem(),
                  ),
                ),
              );
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.only(bottom: 128),
          children: [
            _getHeader('Notification details'),
            _getCard([
              ListTile(
                title: TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                    labelText: 'Title',
                  ),
                  validator: (value) => value!.isEmpty ? 'Please enter a title' : null,
                ),
                contentPadding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              ),
              ListTile(
                title: TextFormField(
                  controller: _bodyController,
                  decoration: const InputDecoration(
                    labelText: 'Body',
                  ),
                ),
                contentPadding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              ),
              ListTile(
                title: const Text('Colour'),
                leading: ItemListDecoration(colour: _item.colour),
                onTap: () {
                  showColourPicker(context: context, initialColour: _item.colour).then((value) {
                    if (value != null) {
                      setState(() {
                        _item.colour = value;
                      });
                    }
                  });
                },
              ),
            ]),
            _getSpacer(),
            _getHeader('Schedule'),
            _getCard([
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
            ]),
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
        icon: const Icon(Icons.save),
      ),
    );
  }

  Widget _getCard(List<Widget> children) => Card(
        clipBehavior: Clip.antiAlias,
        margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 0.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.0),
        ),
        shadowColor: Colors.transparent,
        child: Column(
          children: children.expand((child) => [child, _getDivider()]).take(children.length * 2 - 1).toList(),
        ),
      );

  Widget _getHeader(String title) => ListTile(title: Text(title));

  Widget _getSpacer() => const SizedBox(height: 16);

  Widget _getDivider() => Divider(
        thickness: 2,
        height: 2,
        color: Theme.of(context).colorScheme.background,
      );
}
