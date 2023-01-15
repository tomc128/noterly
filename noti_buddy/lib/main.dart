import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:noti_buddy/managers/isolate_manager.dart';
import 'package:noti_buddy/pages/main_page.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  IsolateManager.init();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return DynamicColorBuilder(builder: (ColorScheme? lightDynamic, ColorScheme? darkDynamic) {
      ColorScheme lightColorScheme;
      ColorScheme darkColorScheme;

      if (lightDynamic != null && darkDynamic != null) {
        // On Android S+ devices, use the provided dynamic color scheme.
        // (Recommended) Harmonize the dynamic color scheme' built-in semantic colors.
        lightColorScheme = lightDynamic.harmonized();
        // (Optional) Customize the scheme as desired. For example, one might
        // want to use a brand color to override the dynamic [ColorScheme.secondary].
        // lightColorScheme = lightColorScheme.copyWith(secondary: _brandBlue);

        // Repeat for the dark color scheme.
        darkColorScheme = darkDynamic.harmonized();
      } else {
        print('No dynamic color scheme, using fallback.');
        // Otherwise, use fallback schemes.
        lightColorScheme = ColorScheme.fromSeed(
          seedColor: Colors.red,
        );
        darkColorScheme = ColorScheme.fromSeed(
          seedColor: Colors.red,
          brightness: Brightness.dark,
        );
      }

      return MaterialApp(
        title: 'Noti Buddy',
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: lightColorScheme,
          fontFamily: GoogleFonts.dmSans().fontFamily,

          // scaffoldBackgroundColor: lightColorScheme.background,
        ),
        darkTheme: ThemeData(
          useMaterial3: true,
          colorScheme: darkColorScheme,
          fontFamily: GoogleFonts.dmSans().fontFamily,
          // scaffoldBackgroundColor: darkColorScheme.surface.harmonizeWith(darkColorScheme.background),
        ),
        themeMode: ThemeMode.system,
        home: const MainPage(),

        // Theme.of(context).textTheme.
      );
    });
  }
}
