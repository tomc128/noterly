import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:noterly/build_info.dart';
import 'package:noterly/managers/app_manager.dart';
import 'package:noterly/managers/notification_manager.dart';
import 'package:noterly/models/notification_item.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:uuid/uuid.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        children: [
          if (kDebugMode) ..._getDebugOptions(context),
          _getHeader('About'),
          _getCard(context, [
            const ListTile(
              title: Text('Version'),
              subtitle: Text(BuildInfo.appVersion),
              leading: Icon(Icons.info),
              minVerticalPadding: 12,
            ),
            const ListTile(
              title: Text('Copyright'),
              subtitle: Text('2023 Tom Chapman, TDS Studios.'),
              leading: Icon(Icons.copyright),
              minVerticalPadding: 12,
            ),
            ListTile(
              title: const Text('Privacy policy'),
              leading: const Icon(Icons.privacy_tip),
              trailing: const Icon(Icons.chevron_right),
              minVerticalPadding: 12,
              onTap: () async {
                var uri = Uri.parse('https://tdsstudios.co.uk/privacy');
                await _launchUrl(uri);
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
        _getHeader('Debug options'),
        _getCard(
          context,
          [
            ListTile(
              title: const Text('Generate random items'),
              subtitle: const Text('Generate 10 random items for testing purposes.'),
              trailing: const Icon(Icons.chevron_right),
              minVerticalPadding: 12,
              onTap: () {
                String randomString() {
                  const chars = 'abcdefghijklmnopqrstuvwxyz';
                  return List.generate(10, (index) => chars[Random().nextInt(chars.length)]).join();
                }

                for (var i = 0; i < 10; i++) {
                  bool shouldHaveBody = Random().nextBool();
                  bool shouldBeScheduled = Random().nextBool();

                  DateTime? scheduledTime = shouldBeScheduled ? DateTime.now().add(Duration(days: Random().nextInt(10) + 1)) : null;
                  Color colour = Colors.primaries[Random().nextInt(Colors.primaries.length)];

                  var item = NotificationItem(
                    id: const Uuid().v4(),
                    title: randomString(),
                    body: shouldHaveBody ? randomString() : null,
                    dateTime: shouldBeScheduled ? scheduledTime : null,
                    colour: colour,
                  );
                  AppManager.instance.addItem(item);
                }
              },
            ),
            ListTile(
              title: const Text('Resend notifications'),
              subtitle: const Text('Force all notifications to be reset.'),
              trailing: const Icon(Icons.chevron_right),
              minVerticalPadding: 12,
              onTap: () {
                NotificationManager.instance.forceUpdateAllNotifications();
              },
            ),
          ],
        )
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

  Widget _getHeader(String title) => ListTile(title: Text(title));

  Widget _getSpacer() => const SizedBox(height: 16);

  Widget _getDivider(BuildContext context) => Divider(
        thickness: 2,
        height: 2,
        color: Theme.of(context).colorScheme.background,
      );
}
