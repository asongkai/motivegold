import 'dart:io';

import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:motivegold/constants/colors.dart';
import 'package:motivegold/screen/landing_screen.dart';
import 'package:motivegold/utils/calculator/calc.dart';
import 'package:motivegold/utils/custom_theme.dart';
import 'package:motivegold/utils/drag/drag_area.dart';
import 'package:provider/provider.dart';

GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  // await Firebase.initializeApp();
  Intl.defaultLocale = 'th_TH';
  initializeDateFormatting('th_TH', null);
  await EasyLocalization.ensureInitialized();
  runApp(
    EasyLocalization(
      supportedLocales: const [
        Locale('en', 'US'),
        Locale('lo', 'LA'),
        Locale('zh', 'CN'),
        Locale('vi', 'VN')
      ],
      path: 'assets/locale', // <-- change the path of the translation files
      fallbackLocale: const Locale('en', 'US'),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Offset offset = const Offset(50, 100);
  bool showCal = false;

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (BuildContext context) {},
      child: LayoutBuilder(
        builder: (context, constraints) {
          final customTheme = CustomTheme(constraints);
          return MaterialApp(
            navigatorKey: navigatorKey,
            debugShowCheckedModeBanner: false,
            localizationsDelegates: context.localizationDelegates,
            supportedLocales: context.supportedLocales,
            locale: context.locale,
            title: 'GOLD',
            theme: ThemeData(
              useMaterial3: false,
              colorScheme: ColorScheme.fromSwatch().copyWith(
                primary: Colors.teal,
                secondary: bgColor,
              ),
              iconTheme: const IconThemeData(
                color: textColor2, //change your color here
              ),
              elevatedButtonTheme: customTheme.elevatedButtonTheme(),
              outlinedButtonTheme: customTheme.outlinedButtonTheme(),
              textButtonTheme: customTheme.textButtonTheme(),
              dividerTheme: customTheme.dividerTheme(),
              fontFamily: 'NotoSansLao',
            ),
            home: const LandingScreen(),
          );
        },
      ),
    );
  }

  void openCal() {
    setState(() {
      showCal = true;
    });
  }

  void closeCal() {
    setState(() {
      showCal = false;
    });
  }
}
