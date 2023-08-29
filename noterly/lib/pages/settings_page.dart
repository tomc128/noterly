import 'dart:math';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:noterly/build_info.dart';
import 'package:noterly/extensions/duration_extensions.dart';
import 'package:noterly/l10n/localisations_util.dart';
import 'package:noterly/managers/app_manager.dart';
import 'package:noterly/managers/file_manager.dart';
import 'package:noterly/managers/notification_manager.dart';
import 'package:noterly/models/notification_item.dart';
import 'package:noterly/models/repetition_data.dart';
import 'package:noterly/widgets/duration_picker.dart';
import 'package:noterly/widgets/first_launch_dialog.dart';
import 'package:system_settings/system_settings.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:uuid/uuid.dart';

import '../managers/log.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({
    super.key,
  });

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  static const String _copyrightText = '''
• Tom Chapman (en_GB, en_US)
• FBI (es)
• Sascha Grebe (de)
• Bluefy (de)
• DindinYT37 (de)
• Mr.Spok (ru, ua)
• SPLESHER (pl)
• GaetanoEsse (it)
• Nader Ghr (fr)''';

  final int _millisBeforeReset = 1000;
  int _easterEggCount = 0;
  int _lastTapTime = 0;

  bool _debugOptions = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(Strings.of(context).page_settings_title),
      ),
      body: ListView(
        children: [
          _getHeader(Strings.of(context).page_settings_header_notifications),
          _getCard(context, [
            ListTile(
              title: Text(Strings.of(context).page_settings_notifications_snoozeDuration),
              subtitle: Text(AppManager.instance.data.snoozeDuration.toRelativeDurationString()),
              leading: const Icon(Icons.snooze),
              trailing: const Icon(Icons.chevron_right),
              minVerticalPadding: 12,
              onTap: () {
                showDurationPicker(
                  context: context,
                  initialDuration: AppManager.instance.data.snoozeDuration,
                ).then((value) {
                  if (value == null) return;
                  setState(() {
                    AppManager.instance.data.snoozeDuration = value;
                    AppManager.instance.data.snoozeToastText = Strings.of(context).toast_notificationSnoozed(value.toRelativeDurationString());
                  });
                  AppManager.instance.saveSettings();
                });
              },
            ),
          ]),
          _getSpacer(),
          _getHeader(Strings.of(context).page_settings_header_system),
          _getCard(context, [
            ListTile(
              title: Text(Strings.of(context).page_settings_system_notificationSettings),
              leading: const Icon(Icons.notifications),
              trailing: const Icon(Icons.open_in_new),
              minVerticalPadding: 12,
              onTap: () async {
                try {
                  SystemSettings.appNotifications();
                } catch (_) {
                  try {
                    SystemSettings.app();
                  } catch (_) {
                    Log.logger.e('Failed to open system settings');
                    await FirebaseCrashlytics.instance.recordError(e, StackTrace.current, reason: 'Failed to open system settings');
                  }
                }

                await FirebaseAnalytics.instance.logEvent(
                  name: 'open_notification_settings',
                );
              },
            )
          ]),
          _getSpacer(),
          _getHeader(Strings.of(context).page_settings_header_about),
          _getCard(context, [
            ListTile(
              title: Text(Strings.of(context).page_settings_about_donation_title),
              leading: const Icon(Icons.coffee),
              trailing: const Icon(Icons.open_in_new),
              minVerticalPadding: 12,
              onTap: () async {
                var uri = Uri.parse('https://ko-fi.com/tomchapman128');
                await _launchUrl(uri);

                await FirebaseAnalytics.instance.logEvent(
                  name: 'open_donation_link',
                );
              },
            ),
          ]),
          _getSpacer(),
          _getCard(context, [
            ListTile(
              title: Text(Strings.of(context).page_settings_about_version_title),
              subtitle: Builder(
                builder: (BuildContext context) {
                  if (BuildInfo.releaseType == ReleaseType.stable) return const Text(BuildInfo.appVersion);

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('${BuildInfo.releaseType.name} release', style: const TextStyle(color: Colors.amber)),
                      const Text('${BuildInfo.appVersion} (${BuildInfo.branch})'),
                    ],
                  );
                },
              ),
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
                      title: Text(Strings.of(context).dialog_easterEgg_title),
                      content: Text(Strings.of(context).dialog_easterEgg_text),
                      actions: [
                        TextButton(
                          onPressed: () {
                            setState(() => _debugOptions = true);
                            Navigator.of(context).pop();
                          },
                          child: Text(Strings.of(context).dialog_easterEgg_action_showDebugOptions),
                        ),
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: Text(Strings.of(context).general_close),
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
              title: Text(Strings.of(context).page_settings_about_copyright_title),
              subtitle: Text(Strings.of(context).page_settings_about_copyright_text),
              leading: const Icon(Icons.copyright),
              trailing: const Icon(Icons.chevron_right),
              minVerticalPadding: 12,
              onTap: () {
                showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      title: Column(
                        children: [
                          Text('Noterly', style: Theme.of(context).textTheme.titleLarge),
                          if (BuildInfo.releaseType != ReleaseType.stable)
                            Text('${BuildInfo.releaseType.name} release',
                                style: Theme.of(context).textTheme.titleSmall!.copyWith(
                                      color: Colors.amber,
                                    )),
                          Text(
                            BuildInfo.releaseType == ReleaseType.stable ? BuildInfo.appVersion : '${BuildInfo.appVersion} (${BuildInfo.branch})',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                        ],
                      ),
                      content: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(Strings.of(context).page_settings_about_licenses_page_legalese),
                            const SizedBox(height: 8),
                            Text(Strings.of(context).page_settings_about_licenses_page_openSourceSoftware),
                            const SizedBox(height: 16),
                            Text(Strings.of(context).dialog_about_translations_title, style: Theme.of(context).textTheme.titleMedium),
                            const Text(_copyrightText),
                            const SizedBox(height: 16),
                            ButtonBar(
                              children: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                    showLicensePage(
                                      context: context,
                                      applicationLegalese: Strings.of(context).page_settings_about_licenses_page_legalese,
                                      applicationVersion: BuildInfo.appVersion,
                                    );

                                    FirebaseAnalytics.instance.logEvent(
                                      name: 'open_licenses',
                                    );
                                  },
                                  child: Text(Strings.of(context).dialog_about_action_showLicenses),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.of(context).pop(),
                                  child: Text(Strings.of(context).general_close),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );

                FirebaseAnalytics.instance.logEvent(
                  name: 'open_about_dialog',
                );
              },
            ),
            ListTile(
              title: Text(Strings.of(context).page_settings_about_tutorial_title),
              leading: const Icon(Icons.school),
              trailing: const Icon(Icons.chevron_right),
              minVerticalPadding: 12,
              onTap: () async {
                showDialog(
                  context: context,
                  builder: (context) => FirstLaunchDialog(
                    onComplete: () {},
                  ),
                  barrierDismissible: false,
                );
              },
            ),
          ]),
          _getSpacer(),
          _getCard(context, [
            ListTile(
              title: Text(Strings.of(context).page_settings_about_github_title),
              leading: const Icon(Icons.favorite),
              trailing: const Icon(Icons.open_in_new),
              minVerticalPadding: 12,
              onTap: () async {
                var uri = Uri.parse('https://github.com/tomc128/noterly');
                await _launchUrl(uri);

                await FirebaseAnalytics.instance.logEvent(
                  name: 'open_github_link',
                );
              },
            ),
            ListTile(
              title: Text(Strings.of(context).page_settings_about_privacyPolicy_title),
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
              title: Text(Strings.of(context).page_settings_about_feedback_title),
              leading: const Icon(Icons.comment),
              trailing: const Icon(Icons.open_in_new),
              minVerticalPadding: 12,
              onTap: () async {
                var uri = Uri.parse('https://forms.gle/5HZNjmr5wF1t4r8q6');
                await _launchUrl(uri);

                await FirebaseAnalytics.instance.logEvent(
                  name: 'open_feedback_form',
                );
              },
            ),
            ListTile(
              title: Text(Strings.of(context).page_settings_about_translate_title),
              leading: const Icon(Icons.translate),
              trailing: const Icon(Icons.open_in_new),
              minVerticalPadding: 12,
              onTap: () async {
                var uri = Uri.parse('https://crowdin.com/project/noterly/invite?h=5831212784abb6a4b04739214cb7a1a91820487');
                await _launchUrl(uri);

                await FirebaseAnalytics.instance.logEvent(
                  name: 'open_translate_link',
                );
              },
            ),
          ]),
          if (kDebugMode || _debugOptions) ..._getDebugOptions(context),
        ],
      ),
    );
  }

  Future<void> _launchUrl(Uri uri) async {
    try {
      if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
        throw Exception('Failed to launch URL: $uri');
      }
    } on Exception catch (e) {
      Log.logger.e('Failed to launch URL: $uri [$e]');
      await FirebaseCrashlytics.instance.recordError(e, StackTrace.current, reason: 'Failed to launch URL: $uri');
    }
  }

  List<Widget> _getDebugOptions(BuildContext context) => [
        _getSpacer(),
        _getHeader(
          Strings.of(context).page_settings_header_debug,
          subtitle: Strings.of(context).page_settings_header_debug_disclaimer,
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
              title: const Text('Force update notifications'),
              trailing: const Icon(Icons.chevron_right),
              leading: const Icon(Icons.notification_important),
              minVerticalPadding: 12,
              onTap: () {
                NotificationManager.instance.forceUpdateAllNotifications();
              },
            ),
            ListTile(
              title: const Text('Log items to console'),
              trailing: const Icon(Icons.chevron_right),
              leading: const Icon(Icons.document_scanner),
              minVerticalPadding: 12,
              onTap: () {
                AppManager.instance.printItems();
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
            ListTile(
              title: const Text('Delete all app data'),
              trailing: const Icon(Icons.chevron_right),
              leading: const Icon(Icons.delete_forever),
              minVerticalPadding: 12,
              onTap: () {
                FileManager.delete().then((value) => AppManager.instance.fullUpdate());
              },
            ),
          ],
        ),
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
