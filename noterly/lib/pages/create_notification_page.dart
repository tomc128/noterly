import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:noterly/extensions/date_time_extensions.dart';
import 'package:noterly/l10n/localisations_util.dart';
import 'package:noterly/managers/app_manager.dart';
import 'package:noterly/models/notification_item.dart';
import 'package:noterly/models/repetition_data.dart';
import 'package:noterly/widgets/colour_picker.dart';
import 'package:noterly/widgets/date_time_picker.dart';
import 'package:noterly/widgets/item_list_decoration.dart';
import 'package:noterly/widgets/repetition_picker.dart';
import 'package:uuid/uuid.dart';

class CreateNotificationPage extends StatefulWidget {
  final String initialTitle;

  const CreateNotificationPage({
    super.key,
    this.initialTitle = '',
  });

  @override
  State<CreateNotificationPage> createState() => _CreateNotificationPageState();
}

class _CreateNotificationPageState extends State<CreateNotificationPage> {
  final _formKey = GlobalKey<FormState>();

  final _titleController = TextEditingController();
  final _bodyController = TextEditingController();

  var _isScheduled = false;
  var _isRepeating = false;

  late DateTime _dateTime;

  // Duration _duration = const Duration(days: 1);
  RepetitionData _repetitionData = RepetitionData(number: 1, type: Repetition.daily);

  late Color _colour;

  @override
  void initState() {
    _titleController.text = widget.initialTitle;

    var now = DateTime.now();
    _dateTime = DateTime(now.year, now.month, now.day, now.hour + 1, 0, 0);

    _colour = ColourPicker.colours.values.elementAt(DateTime.now().second % ColourPicker.colours.length);

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
        title: Text(Strings.of(context).page_createNotification_title, overflow: TextOverflow.fade),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.only(bottom: 128),
          children: [
            _getHeader(Strings.of(context).page_createNotification_header_details),
            _getCard([
              ListTile(
                title: TextFormField(
                  controller: _titleController,
                  autocorrect: true,
                  autofocus: true,
                  keyboardType: TextInputType.text,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: InputDecoration(
                    labelText: Strings.of(context).page_createNotification_details_field_title_label,
                    border: InputBorder.none,
                  ),
                  validator: (value) => value!.isEmpty ? Strings.of(context).page_createNotification_details_field_title_error : null,
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
                    labelText: Strings.of(context).page_createNotification_details_field_body_label,
                    border: InputBorder.none,
                  ),
                ),
                contentPadding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              ),
              ListTile(
                title: Text(Strings.of(context).page_createNotification_details_field_colour_label),
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
            _getHeader(Strings.of(context).page_createNotification_header_timing),
            _getCard([
              SwitchListTile(
                value: _isScheduled,
                title: Text(Strings.of(context).page_createNotification_timing_schedule_title),
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
                  title: Text(Strings.of(context).page_createNotification_timing_schedule_subtitle),
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
                title: Text(Strings.of(context).page_createNotification_timing_repeat_title),
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
                  title: Text(Strings.of(context).page_createNotification_timing_repeat_subtitle),
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
                subtitle: Text(Strings.of(context).page_createNotification_timing_repeat_info),
              ),
            ],
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          if (!_formKey.currentState!.validate()) return;

          await AppManager.instance.addItem(
            NotificationItem(
              id: const Uuid().v4(),
              title: _titleController.text,
              body: _bodyController.text,
              dateTime: _isScheduled ? _dateTime : null,
              repetitionData: _isRepeating ? _repetitionData : null,
              colour: _colour,
            ),
          );

          await FirebaseAnalytics.instance.logEvent(
            name: 'create_item',
            parameters: {
              'is_scheduled': _isScheduled ? 'yes' : 'no',
              'is_repeating': _isRepeating ? 'yes' : 'no',
            },
          );

          if (mounted) {
            Navigator.of(context).pop();
          }
        },
        label: Text(Strings.of(context).main_action_create),
        icon: const Icon(Icons.check),
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
