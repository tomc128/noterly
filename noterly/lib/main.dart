import 'package:background_fetch/background_fetch.dart';
import 'package:dynamic_color/dynamic_color.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:noterly/build_info.dart';
import 'package:noterly/managers/app_manager.dart';
import 'package:noterly/managers/isolate_manager.dart';
import 'package:noterly/managers/log.dart';
import 'package:noterly/managers/notification_manager.dart';
import 'package:noterly/pages/main_page.dart';

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

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Ensure the app renders behind the system UI.
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    systemNavigationBarColor: Colors.transparent,
  ));

  IsolateManager.init();

  //* IF CHANGING THIS TO DART-ONLY, ALSO CHANGE THIS IN NOTIFICATION_MANAGER
  // await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform); // Previous method of initialising Firebase
  await Firebase.initializeApp(); // Remove options to use native manual installation of Firebase, as Dart-only isn't working yet for some reason
  await FirebaseAnalytics.instance.setDefaultEventParameters({'version': BuildInfo.appVersion});

  // Pass all uncaught "fatal" errors from the framework to Crashlytics
  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;
  // Pass all uncaught asynchronous errors that aren't handled by the Flutter framework to Crashlytics
  PlatformDispatcher.instance.onError = (error, stack) {
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    return true;
  };

  runApp(const MyApp());

  await BackgroundFetch.registerHeadlessTask(backgroundFetchHeadlessTask);

  // TODO: implement quick actions
  // const quickActions = QuickActions();
  // quickActions.initialize((shortcutType) {
  //   if (shortcutType == 'action_new') {
  //     print('New note shortcut pressed!');
  //     // show new note screen
  //     // get the current context and navigate to the new note screen
  //     BuildContextProvider().call(
  //       (context) => Navigator.of(context).push(MaterialPageRoute(builder: (context) => const CreateNotificationPage())),
  //     );
  //   }
  //   // More handling code...
  // });

  // quickActions.setShortcutItems(<ShortcutItem>[
  //   const ShortcutItem(type: 'action_new', localizedTitle: 'New note', icon: 'notification_icon_24'),
  // ]);
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    initPlatformState();
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

        BackgroundFetch.finish(taskId); // Signal the task is complete. IMPORTANT
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
    return DynamicColorBuilder(builder: (ColorScheme? lightDynamic, ColorScheme? darkDynamic) {
      ColorScheme lightColorScheme;
      ColorScheme darkColorScheme;

      if (lightDynamic != null && darkDynamic != null) {
        Log.logger.d('Using dynamic color scheme.');

        lightColorScheme = lightDynamic.harmonized();
        darkColorScheme = darkDynamic.harmonized();
      } else {
        Log.logger.d('No dynamic color scheme, using fallback.');

        lightColorScheme = ColorScheme.fromSeed(
          seedColor: Colors.red,
        );
        darkColorScheme = ColorScheme.fromSeed(
          seedColor: Colors.red,
          brightness: Brightness.dark,
        );
      }

      return MaterialApp(
        title: 'Noterly',
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: lightColorScheme,
          fontFamily: GoogleFonts.dmSans().fontFamily,
          textTheme: GoogleFonts.dmSansTextTheme().copyWith(
            labelLarge: TextStyle(color: Colors.black.withOpacity(0.5)),
          ),
        ),
        darkTheme: ThemeData(
          useMaterial3: true,
          colorScheme: darkColorScheme,
          fontFamily: GoogleFonts.dmSans().fontFamily,
          textTheme: GoogleFonts.dmSansTextTheme(ThemeData.dark().textTheme).copyWith(
            labelLarge: TextStyle(color: Colors.white.withOpacity(0.5)),
          ),
        ),
        themeMode: ThemeMode.system,
        home: const MainPage(),
        debugShowCheckedModeBanner: false,
      );
    });
  }
}
