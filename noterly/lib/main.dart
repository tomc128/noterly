import 'dart:async';

import 'package:background_fetch/background_fetch.dart';
import 'package:dynamic_color/dynamic_color.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:logger/logger.dart';
import 'package:noterly/build_info.dart';
import 'package:noterly/managers/app_manager.dart';
import 'package:noterly/managers/isolate_manager.dart';
import 'package:noterly/managers/log.dart';
import 'package:noterly/managers/notification_manager.dart';
import 'package:noterly/pages/create_notification_page.dart';
import 'package:noterly/pages/main_page.dart';
import 'package:quick_actions/quick_actions.dart';
import 'package:receive_intent/receive_intent.dart';
import 'package:receive_intent/receive_intent.dart' as receive_intent;
import 'package:receive_sharing_intent/receive_sharing_intent.dart';

@pragma('vm:entry-point')
void backgroundFetchHeadlessTask(HeadlessTask task) async {
  String taskId = task.taskId;
  bool isTimeout = task.timeout;

  if (isTimeout) {
    // Immediately finish the task if it's timed-out.
    Log.logger.w('[BackgroundFetch] Headless task timed-out: $taskId');
    BackgroundFetch.finish(taskId);
    return;
  }

  Log.logger.d('[BackgroundFetch] Headless event received.');

  await AppManager.instance.ensureInitialised();
  await AppManager.instance.fullUpdate();
  await NotificationManager.instance.updateAllNotifications();

  BackgroundFetch.finish(taskId);
}

Future<void> main(List<String> args) async {
  WidgetsFlutterBinding.ensureInitialized();

  Log.logger.log(Level.debug, "Starting app with args: $args");

  // Ensure the app renders behind the system UI.
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    systemNavigationBarColor: Colors.transparent,
  ));

  IsolateManager.init();

  //* IF CHANGING THIS TO DART-ONLY, ALSO CHANGE THIS IN NOTIFICATION_MANAGER
  // await Firebase.initializeApp(
  //     options: DefaultFirebaseOptions
  //         .currentPlatform); // Previous method of initialising Firebase
  await Firebase
      .initializeApp(); // Remove options to use native manual installation of Firebase, as Dart-only isn't working yet for some reason
  await FirebaseAnalytics.instance
      .setDefaultEventParameters({'version': BuildInfo.appVersion});

  // Pass all uncaught "fatal" errors from the framework to Crashlytics
  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;
  // Pass all uncaught asynchronous errors that aren't handled by the Flutter framework to Crashlytics
  PlatformDispatcher.instance.onError = (error, stack) {
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    return true;
  };

  var delegate = await LocalizationDelegate.create(
    fallbackLocale: 'en_GB',
    supportedLocales: ['en_GB', 'en_US', 'fr', 'es', 'de'],
  );
  runApp(LocalizedApp(
      delegate, MyApp(launchMessage: args.isNotEmpty ? args[0] : null)));

  await BackgroundFetch.registerHeadlessTask(backgroundFetchHeadlessTask);

  const quickActions = QuickActions();
  quickActions.initialize((shortcutType) {
    if (shortcutType == 'action_new') {
      MyApp.navigatorKey.currentState!.pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const CreateNotificationPage()),
            (route) => route.isFirst,
      );
    }
  });

  quickActions.setShortcutItems(<ShortcutItem>[
    const ShortcutItem(
        type: 'action_new',
        localizedTitle: 'New note',
        icon: 'ic_shortcut_add'),
  ]);
}

class MyApp extends StatefulWidget {
  final String? launchMessage;
  static final GlobalKey<NavigatorState> navigatorKey =
  GlobalKey(debugLabel: "Main Navigator");

  const MyApp({
    super.key,
    this.launchMessage,
  });

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  StreamSubscription? _shareIntentDataStreamSubscription;
  StreamSubscription? _intentDataStreamSubscription;

  @override
  void initState() {
    super.initState();
    initPlatformState();

    if (widget.launchMessage == 'launchFromQuickTile') {
      SchedulerBinding.instance.addPostFrameCallback((_) {
        MyApp.navigatorKey.currentState!.pushAndRemoveUntil(
          MaterialPageRoute(
              builder: (context) => const CreateNotificationPage()),
              (route) => route.isFirst,
        );
      });
    }

    // SHARING INTENT
    handleSharedText(String? text) {
      if (text == null) return;

      // Show create notification page with the shared text as the title
      MyApp.navigatorKey.currentState!.pushAndRemoveUntil(
        MaterialPageRoute(
            builder: (context) => CreateNotificationPage(initialTitle: text)),
            (route) => route.isFirst,
      );

      // Analytics event
      FirebaseAnalytics.instance.logEvent(name: 'share_to_app');
    }

    handleShareError(Object error) {
      Log.logger.log(Level.error, "getLinkStream error: $error");
    }

    // Share sheet listener, while app is open
    _shareIntentDataStreamSubscription = ReceiveSharingIntent.getTextStream()
        .listen(handleSharedText, onError: handleShareError);

    // Share sheet listener, when app is closed
    ReceiveSharingIntent.getInitialText()
        .then(handleSharedText, onError: handleShareError);

    // GENERAL INTENT
    handleIntent(receive_intent.Intent? intent) {
      if (intent == null) return;
      Log.logger.log(Level.debug, "Received intent: $intent");

      if (intent.action == 'uk.co.tdsstudios.noterly.ACTION_CREATE_NOTE') {
        // Show create notification page
        MyApp.navigatorKey.currentState!.pushAndRemoveUntil(
          MaterialPageRoute(
              builder: (context) => const CreateNotificationPage()),
              (route) => route.isFirst,
        );

        // Analytics event
        FirebaseAnalytics.instance.logEvent(name: 'from_quick_tile');
      }
    }

    handleIntentError(Object error) {
      Log.logger.log(Level.error, "getLinkStream error: $error");
    }

    // Intent listener, while app is open
    _intentDataStreamSubscription = ReceiveIntent.receivedIntentStream
        .listen(handleIntent, onError: handleIntentError);

    // Intent listener, when app is closed
    ReceiveIntent.getInitialIntent()
        .then(handleIntent, onError: handleIntentError);
  }

  @override
  void dispose() {
    _shareIntentDataStreamSubscription?.cancel();
    _intentDataStreamSubscription?.cancel();
    super.dispose();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    int status = await BackgroundFetch.configure(
      BackgroundFetchConfig(
          minimumFetchInterval: 15,
          stopOnTerminate: false,
          enableHeadless: true,
          requiresBatteryNotLow: false,
          requiresCharging: false,
          requiresStorageNotLow: false,
          requiresDeviceIdle: false,
          startOnBoot: true,
          forceAlarmManager: false,
          requiredNetworkType: NetworkType.NONE),
          (String taskId) async {
        // <-- Event handler
        Log.logger.d('[BackgroundFetch] Event received $taskId');

        await AppManager.instance.ensureInitialised();
        await AppManager.instance.fullUpdate();
        await NotificationManager.instance.updateAllNotifications();

        BackgroundFetch.finish(
            taskId); // Signal the task is complete. IMPORTANT
      },
          (String taskId) async {
        // <-- Task timeout handler.
        Log.logger.w('[BackgroundFetch] Task timeout: $taskId');
        BackgroundFetch.finish(taskId);
      },
    );
    Log.logger.d('[BackgroundFetch] configure success: $status');

    await NotificationManager.instance.updateAllNotifications();

    if (!mounted) return;
  }

  @override
  Widget build(BuildContext context) {
    var localizationDelegate = LocalizedApp
        .of(context)
        .delegate;

    return LocalizationProvider(
      state: LocalizationProvider
          .of(context)
          .state,
      child: DynamicColorBuilder(
          builder: (ColorScheme? lightDynamic, ColorScheme? darkDynamic) {
            ColorScheme lightColorScheme;
            ColorScheme darkColorScheme;

            if (lightDynamic != null && darkDynamic != null) {
              Log.logger.d('Using dynamic color scheme.');

              lightColorScheme = lightDynamic.harmonized();
              darkColorScheme = darkDynamic.harmonized();
            } else {
              Log.logger.d('No dynamic color scheme, using fallback.');

              lightColorScheme = ColorScheme.fromSeed(
                seedColor: const Color.fromRGBO(153, 0, 228, 1),
              );
              darkColorScheme = ColorScheme.fromSeed(
                seedColor: const Color.fromRGBO(153, 0, 228, 1),
                brightness: Brightness.dark,
              );
            }

            return MaterialApp(
              navigatorKey: MyApp.navigatorKey,
              title: 'Noterly',
              localizationsDelegates: [
                ...GlobalMaterialLocalizations.delegates,
                GlobalWidgetsLocalizations.delegate,
                localizationDelegate,
              ],
              supportedLocales: localizationDelegate.supportedLocales,
              locale: localizationDelegate.currentLocale,
              theme: ThemeData(
                useMaterial3: true,
                colorScheme: lightColorScheme,
                fontFamily: GoogleFonts
                    .dmSans()
                    .fontFamily,
                textTheme: GoogleFonts.dmSansTextTheme().copyWith(
                  labelLarge: TextStyle(color: Colors.black.withOpacity(0.5)),
                ),
              ),
              darkTheme: ThemeData(
                useMaterial3: true,
                colorScheme: darkColorScheme,
                fontFamily: GoogleFonts
                    .dmSans()
                    .fontFamily,
                textTheme: GoogleFonts.dmSansTextTheme(ThemeData
                    .dark()
                    .textTheme)
                    .copyWith(
                  labelLarge: TextStyle(color: Colors.white.withOpacity(0.5)),
                ),
              ),
              themeMode: ThemeMode.system,
              home: const MainPage(),
              debugShowCheckedModeBanner: false,
            );
          }),
    );
  }
}
