import 'dart:isolate';
import 'dart:ui';

import 'package:flutter_translate/flutter_translate.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:noterly/extensions/duration_extensions.dart';
import 'package:noterly/managers/log.dart';

import 'app_manager.dart';

class IsolateManager {
  static final mainRecievePort = ReceivePort();
  static const String mainPortName = 'main_isolate_port';

  static void init() {
    // Register the port with the main isolate
    var registerResult = IsolateNameServer.registerPortWithName(mainRecievePort.sendPort, mainPortName);
    if (!registerResult) {
      IsolateNameServer.removePortNameMapping(mainPortName);
      registerResult = IsolateNameServer.registerPortWithName(mainRecievePort.sendPort, mainPortName);

      if (!registerResult) {
        throw Exception('Failed to register port with main isolate (x2)');
      }
    }

    // Listen for messages from the background isolate
    mainRecievePort.listen((message) {
      switch (message) {
        case 'update':
          Log.logger.d('Forcing a full update...');
          AppManager.instance.fullUpdate();
          break;
        case 'show_snooze_toast':
          Fluttertoast.showToast(
            msg: translate('toast.notification_snoozed', args: {'duration': AppManager.instance.data.snoozeDuration.toRelativeDurationString()}),
            toastLength: Toast.LENGTH_SHORT,
          );
          break;
        default:
          Log.logger.w('Unknown message from background isolate: "$message"');
      }
    });
  }
}
