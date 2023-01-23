import 'package:flutter/material.dart';
import 'package:noterly/extensions/date_time_extensions.dart';
import 'package:noterly/managers/app_manager.dart';
import 'package:noterly/models/notification_item.dart';
import 'package:noterly/widgets/colour_picker.dart';
import 'package:noterly/widgets/date_time_picker.dart';
import 'package:noterly/widgets/item_list_decoration.dart';
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
          padding: const EdgeInsets.only(bottom: 128),
          children: [
            _getHeader('Notification details'),
            _getCard([
              ListTile(
                title: TextFormField(
                  controller: _titleController,
                  autocorrect: true,
                  autofocus: true,
                  keyboardType: TextInputType.text,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: const InputDecoration(
                    labelText: 'Title',
                    border: InputBorder.none,
                  ),
                  validator: (value) => value!.isEmpty ? 'Please enter a title' : null,
                ),
                contentPadding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              ),
              ListTile(
                title: TextFormField(
                  controller: _bodyController,
                  autocorrect: true,
                  keyboardType: TextInputType.text,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: const InputDecoration(
                    labelText: 'Body',
                    border: InputBorder.none,
                  ),
                ),
                contentPadding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
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
                  minVerticalPadding: 12,
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

          AppManager.instance.addItem(
            NotificationItem(
              id: const Uuid().v4(),
              title: _titleController.text,
              body: _bodyController.text,
              dateTime: _isScheduled ? _dateTime : null,
              colour: _colour,
            ),
          );

          if (mounted) {
            Navigator.of(context).pop();
          }
        },
        label: const Text('Create'),
        icon: const Icon(Icons.add),
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
