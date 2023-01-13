import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class LifecycleEventHandler extends WidgetsBindingObserver {
  final AsyncCallback? resumeCallback;
  final AsyncCallback? suspendingCallback;

  LifecycleEventHandler({
    this.resumeCallback,
    this.suspendingCallback,
  });

  @override
  Future<void> didChangeAppLifecycleState(AppLifecycleState state) async {
    switch (state) {
      case AppLifecycleState.resumed:
        if (resumeCallback != null) {
          await resumeCallback!();
        }
        break;
      case AppLifecycleState.inactive:
      case AppLifecycleState.paused:
      case AppLifecycleState.detached:
        if (suspendingCallback != null) {
          await suspendingCallback!();
        }
        break;
    }
  }
}
