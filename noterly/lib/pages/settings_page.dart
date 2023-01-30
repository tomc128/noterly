import 'dart:math';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:noterly/build_info.dart';
import 'package:noterly/managers/app_manager.dart';
import 'package:noterly/managers/file_manager.dart';
import 'package:noterly/managers/notification_manager.dart';
import 'package:noterly/models/notification_item.dart';
import 'package:noterly/models/repetition_data.dart';
import 'package:system_settings/system_settings.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:uuid/uuid.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({
    super.key,
  });

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final int _millisBeforeReset = 1000;
  int _easterEggCount = 0;
  int _lastTapTime = 0;

  bool _debugOptions = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        children: [
          if (kDebugMode || _debugOptions) ..._getDebugOptions(context),
          _getHeader('System'),
          _getCard(context, [
            ListTile(
              title: const Text('Notification settings'),
              leading: const Icon(Icons.notifications),
              trailing: const Icon(Icons.open_in_new),
              minVerticalPadding: 12,
              onTap: () async {
                SystemSettings.appNotifications();

                await FirebaseAnalytics.instance.logEvent(
                  name: 'open_notification_settings',
                );
              },
            )
          ]),
          _getSpacer(),
          _getHeader('About'),
          _getCard(context, [
            ListTile(
              title: const Text('Version'),
              subtitle: const Text(BuildInfo.appVersion),
              leading: const Icon(Icons.info),
              minVerticalPadding: 12,
              onTap: () async {
                _easterEggCount++;

                var newTime = DateTime.now().millisecondsSinceEpoch;
                if (newTime - _lastTapTime > _millisBeforeReset) {
                  _easterEggCount = 0;
                }
                _lastTapTime = newTime;

                if (_easterEggCount == 7) {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Easter egg!'),
                      content: const Text("Congratulations, you've found the easter egg! You can now enable debug options. Please note that these options are not supported and may cause issues."),
                      actions: [
                        TextButton(
                          onPressed: () {
                            setState(() => _debugOptions = true);
                            Navigator.of(context).pop();
                          },
                          child: const Text('Show debug options'),
                        ),
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: const Text('Close'),
                        ),
                      ],
                    ),
                    barrierDismissible: false,
                  );

                  await FirebaseAnalytics.instance.logEvent(
                    name: 'easter_egg',
                  );
                }
              },
            ),
            ListTile(
              title: const Text('Copyright'),
              subtitle: const Text('2023 Tom Chapman, TDS Studios.'),
              leading: const Icon(Icons.copyright),
              minVerticalPadding: 12,
              onTap: () {}, // allow for ripple effect
            ),
            ListTile(
              title: const Text('Privacy policy'),
              leading: const Icon(Icons.privacy_tip),
              trailing: const Icon(Icons.open_in_new),
              minVerticalPadding: 12,
              onTap: () async {
                var uri = Uri.parse('https://tdsstudios.co.uk/privacy');
                await _launchUrl(uri);

                await FirebaseAnalytics.instance.logEvent(
                  name: 'open_privacy_policy',
                );
              },
            ),
            ListTile(
              title: const Text('Licenses'),
              leading: const Icon(Icons.article),
              trailing: const Icon(Icons.chevron_right),
              minVerticalPadding: 12,
              onTap: () {
                showLicensePage(
                  context: context,
                  applicationLegalese: 'Copyright © 2023 Tom Chapman, TDS Studios.',
                  applicationVersion: BuildInfo.appVersion,
                );

                FirebaseAnalytics.instance.logEvent(
                  name: 'open_licenses',
                );
              },
            ),
          ]),
        ],
      ),
    );
  }

  Future<void> _launchUrl(Uri uri) async {
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      throw Exception('Could not launch $uri');
    }
  }

  List<Widget> _getDebugOptions(BuildContext context) => [
        _getHeader(
          'Debug options',
          subtitle: 'These options are not supported and may cause issues. Use at your own risk.',
        ),
        _getCard(
          context,
          [
            ListTile(
              title: const Text('Generate 10 random items'),
              trailing: const Icon(Icons.chevron_right),
              minVerticalPadding: 12,
              leading: const Icon(Icons.generating_tokens),
              onTap: () {
                String randomString() {
                  const chars = 'abcdefghijklmnopqrstuvwxyz';
                  return List.generate(10, (index) => chars[Random().nextInt(chars.length)]).join();
                }

                for (var i = 0; i < 10; i++) {
                  bool shouldHaveBody = Random().nextBool();
                  bool shouldBeScheduled = Random().nextBool();
                  bool shouldBeRepeating = Random().nextBool();

                  DateTime? scheduledTime;
                  RepetitionData? repetitionData;

                  if (shouldBeRepeating) {
                    scheduledTime = DateTime.now().add(Duration(days: Random().nextInt(10) + 1));
                    repetitionData = RepetitionData(
                      number: Random().nextInt(5) + 1,
                      type: Repetition.values[Random().nextInt(Repetition.values.length)],
                    );
                  } else if (shouldBeScheduled) {
                    scheduledTime = DateTime.now().add(Duration(days: Random().nextInt(10) + 1));
                    repetitionData = null;
                  } else {
                    scheduledTime = null;
                    repetitionData = null;
                  }

                  Color colour = Colors.primaries[Random().nextInt(Colors.primaries.length)];

                  var item = NotificationItem(
                    id: const Uuid().v4(),
                    title: randomString(),
                    body: shouldHaveBody ? randomString() : '',
                    dateTime: scheduledTime,
                    repetitionData: repetitionData,
                    colour: colour,
                  );
                  AppManager.instance.addItem(item);
                }
              },
            ),
            ListTile(
              title: const Text('Force update all notifications'),
              trailing: const Icon(Icons.chevron_right),
              leading: const Icon(Icons.notification_important),
              minVerticalPadding: 12,
              onTap: () {
                NotificationManager.instance.forceUpdateAllNotifications();
              },
            ),
            ListTile(
              title: const Text('Log notification items'),
              trailing: const Icon(Icons.chevron_right),
              leading: const Icon(Icons.document_scanner),
              minVerticalPadding: 12,
              onTap: () {
                AppManager.instance.printItems();
              },
            ),
            ListTile(
              title: const Text('Delete app data'),
              trailing: const Icon(Icons.chevron_right),
              leading: const Icon(Icons.delete_forever),
              minVerticalPadding: 12,
              onTap: () {
                FileManager.delete().then((value) => AppManager.instance.fullUpdate());
              },
            ),
            ListTile(
              title: const Text('Send test analytics event'),
              trailing: const Icon(Icons.chevron_right),
              leading: const Icon(Icons.analytics),
              minVerticalPadding: 12,
              onTap: () {
                FirebaseAnalytics.instance.logEvent(name: 'test');
              },
            ),
          ],
        ),
        _getSpacer(),
      ];

  Widget _getCard(BuildContext context, List<Widget> children) => Card(
        clipBehavior: Clip.antiAlias,
        margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 0.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.0),
        ),
        shadowColor: Colors.transparent,
        child: Column(
          children: children.expand((child) => [child, _getDivider(context)]).take(children.length * 2 - 1).toList(),
        ),
      );

  Widget _getHeader(String title, {String? subtitle}) => ListTile(
        title: Text(title),
        subtitle: subtitle != null ? Text(subtitle) : null,
        minVerticalPadding: 16,
      );

  Widget _getSpacer() => const SizedBox(height: 16);

  Widget _getDivider(BuildContext context) => Divider(
        thickness: 2,
        height: 2,
        color: Theme.of(context).colorScheme.background,
      );
}
