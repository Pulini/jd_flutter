import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get/get.dart';
import 'package:jd_flutter/route.dart';
import 'package:jd_flutter/utils/app_init_service.dart';
import 'translation.dart';
import 'utils/web_api.dart';

main() async {
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
    super.initState();
    // //添加全局网络状态管理
    Get.put(AppInitService(), permanent: true);
  }

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      scrollBehavior: ScrollConfiguration.of(context).copyWith(
        //适配鼠标滚动
        dragDevices: {PointerDeviceKind.touch, PointerDeviceKind.mouse},
      ),
      onGenerateTitle: (context) => 'app_name'.tr,
      debugShowCheckedModeBanner: isTestUrl(),
      translations: Translation(),
      navigatorObservers: [GetObserver()],
      locale: View.of(context).platformDispatcher.locale,
      localeListResolutionCallback: (locales, supportedLocales) {
        language = locales?.first.languageCode == localeChinese.languageCode
            ? 'zh'
            : 'en';
        return null;
      },
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
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
