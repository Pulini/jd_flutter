import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get/get.dart';
import 'package:jd_flutter/route.dart';
import 'package:jd_flutter/utils/app_init.dart';
import 'translation.dart';
import 'utils/web_api.dart';

main() async {
  // 确保Flutter框架正确初始化
  WidgetsFlutterBinding.ensureInitialized();
  // 启用性能叠加层
  debugProfileBuildsEnabled = true;

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    Get.put(AppInitService(), permanent: true);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      scrollBehavior: ScrollConfiguration.of(context).copyWith(
        //适配鼠标滚动
        dragDevices: {PointerDeviceKind.touch, PointerDeviceKind.mouse},
      ),
      onGenerateTitle: (context) => 'app_name'.tr,
      debugShowCheckedModeBanner: false,
      translations: Translation(),
      navigatorObservers: [GetObserver()],
      locale: View.of(context).platformDispatcher.locale,
      localeListResolutionCallback: (locales, supportedLocales) {
        language = locales!.first.languageCode ;
        debugPrint('当前语言: $language');
        return null;
      },
      supportedLocales: [
        localeChinese,//中文
        localeEnglish,//英文
        localeIndonesian,//印度尼西亚
      ],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueAccent),
        useMaterial3: true,
        appBarTheme: const AppBarTheme(scrolledUnderElevation: 0.0),
      ),
      getPages: RouteConfig.appRoutes,
      home: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isTestUrl()
                ? [Colors.lightBlueAccent, Colors.greenAccent]
                : [Colors.lightBlueAccent, Colors.blueAccent],
            begin: Alignment.bottomLeft,
            end: Alignment.topRight,
          ),
        ),
      ),
    );
  }
}
