import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:jd_flutter/http/web_api.dart';
import 'package:jd_flutter/utils.dart';
import 'login/login.dart';
import 'generated/l10n.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  static _MyAppState of(BuildContext context) =>
      context.findAncestorStateOfType<_MyAppState>()!;

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Locale? _locale;

  set locale(Locale? value) {
    setState(() {
      _locale = value;
      saveLanguage(_locale!.languageCode);
      logger.e("setState: ${value?.languageCode}");
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    getLanguage().then((languageCode) {
      locale = languageCode;
      logger.i("languageCode: $languageCode");
    });
  }

  @override
  Widget build(BuildContext context) {

    return MaterialApp(
      onGenerateTitle: (context) => S.of(context).app_name,
      debugShowCheckedModeBanner: false,
      locale: _locale,
      supportedLocales: S.delegate.supportedLocales,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        S.delegate
      ],
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueAccent),
        useMaterial3: true,
      ),
      home:const Login(),
    );
  }
}
