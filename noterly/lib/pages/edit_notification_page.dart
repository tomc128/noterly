import 'package:auto_size_text/auto_size_text.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:noterly/extensions/date_time_extensions.dart';
import 'package:noterly/managers/app_manager.dart';
import 'package:noterly/models/notification_item.dart';
import 'package:noterly/models/repetition_data.dart';
import 'package:noterly/widgets/colour_picker.dart';
import 'package:noterly/widgets/date_time_picker.dart';
import 'package:noterly/widgets/item_list_decoration.dart';
import 'package:noterly/widgets/repetition_picker.dart';

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
  late bool _isRepeating;

  late DateTime _dateTime;

  // late Duration _duration;
  late RepetitionData _repetitionData;

  @override
  void initState() {
    _item = widget.item;

    var now = DateTime.now();
    _dateTime = _item.dateTime ?? DateTime(now.year, now.month, now.day, now.hour + 1, 0, 0);
    _isScheduled = _item.dateTime != null;

    _repetitionData = _item.repetitionData ?? RepetitionData(number: 1, type: Repetition.daily);
    _isRepeating = _item.isRepeating;

    _titleController.text = _item.title;
    _bodyController.text = _item.body;

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
        title: AutoSizeText(
          translate('page.edit_notification.title'),
          maxLines: 2,
          minFontSize: 18,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () {
              AppManager.instance.deleteItem(_item.id);
              ScaffoldMessenger.of(context).clearSnackBars(); // Clear any existing snackbars, as only one item can be restored.
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(translate('snackbar.notification_deleted', args: {'title': _item.title})),
                  action: SnackBarAction(
                    label: translate('general.undo'),
                    onPressed: () {
                      AppManager.instance.restoreLastDeletedItems();
                      FirebaseAnalytics.instance.logEvent(name: 'restore_deleted_item');
                    },
                  ),
                ),
              );
              Navigator.of(context).pop();
              FirebaseAnalytics.instance.logEvent(
                name: 'delete_item',
                parameters: {'from': 'edit_notification_page'},
              );
            },
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.only(bottom: 128),
          children: [
            _getHeader(translate('page.edit_notification.header.details')),
            _getCard([
              ListTile(
                title: TextFormField(
                  controller: _titleController,
                  autocorrect: true,
                  keyboardType: TextInputType.text,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: InputDecoration(
                    labelText: translate('page.edit_notification.details.field.title.label'),
                    border: InputBorder.none,
                  ),
                  validator: (value) => value!.isEmpty ? translate('page.edit_notification.details.field.title.error') : null,
                ),
                contentPadding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              ),
              ListTile(
                title: TextFormField(
                  controller: _bodyController,
                  autocorrect: true,
                  keyboardType: TextInputType.text,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: InputDecoration(
                    labelText: translate('page.edit_notification.details.field.body.label'),
                    border: InputBorder.none,
                  ),
                ),
                contentPadding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              ),
              ListTile(
                title: Text(translate('page.edit_notification.details.field.colour.label')),
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
            _getHeader(translate('page.edit_notification.header.timing')),
            _getCard([
              SwitchListTile(
                value: _isScheduled,
                title: Text(translate('page.edit_notification.timing.schedule.title')),
                secondary: const Icon(Icons.calendar_today),
                onChanged: _isRepeating
                    ? null
                    : (value) {
                        setState(() {
                          _isScheduled = value;
                        });
                      },
              ),
              if (_isScheduled)
                ListTile(
                  title: Text(translate('page.edit_notification.timing.schedule.subtitle')),
                  subtitle: Text(_dateTime.toRelativeDateTimeString(alwaysShowDay: true)),
                  minVerticalPadding: 12,
                  onTap: () {
                    showDateTimePicker(
                      context: context,
                      initialDateTime: _dateTime,
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(
                        const Duration(days: 365 * 10),
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
                value: _isRepeating,
                title: Text(translate('page.edit_notification.timing.repeat.title')),
                secondary: const Icon(Icons.repeat),
                onChanged: (value) {
                  setState(() {
                    _isRepeating = value;
                    // if we are repeating, we must also be scheduled
                    if (_isRepeating) {
                      _isScheduled = true;
                    }
                  });
                },
              ),
              if (_isRepeating)
                ListTile(
                  title: Text(translate('page.edit_notification.timing.repeat.subtitle')),
                  subtitle: Text(_repetitionData.toReadableString()),
                  minVerticalPadding: 12,
                  onTap: () {
                    showRepetitionPicker(
                      initialRepetitionData: _repetitionData,
                      context: context,
                    ).then((value) {
                      if (value != null) {
                        setState(() {
                          _repetitionData = value;
                        });
                      }
                    });
                  },
                ),
            ]),
            if (_isRepeating) ...[
              _getSpacer(),
              ListTile(
                leading: const Icon(Icons.info),
                subtitle: Text(translate('page.edit_notification.timing.repeat.info')),
              ),
            ],
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          if (!_formKey.currentState!.validate()) return;

          var itemWasArchived = _item.archived;

          _item.title = _titleController.text;
          _item.body = _bodyController.text;
          _item.dateTime = _isScheduled ? _dateTime : null;
          _item.archived = false; // Unarchive if we edit an archived item
          _item.repetitionData = _isRepeating ? _repetitionData : null;
          _item.snoozeDateTime = null; // Un-snooze if we edit a snoozed item

          await AppManager.instance.editItem(_item);

          await FirebaseAnalytics.instance.logEvent(
            name: itemWasArchived ? 'reactivate_item' : 'edit_item',
            parameters: {
              'is_scheduled': _isScheduled ? 'yes' : 'no',
              'is_repeating': _isRepeating ? 'yes' : 'no',
            },
          );

          if (mounted) {
            Navigator.of(context).pop();
          }
        },
        label: _item.archived ? Text(translate('main.action.reactivate')) : Text(translate('main.action.save')),
        icon: _item.archived ? const Icon(Icons.restore) : const Icon(Icons.save),
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
