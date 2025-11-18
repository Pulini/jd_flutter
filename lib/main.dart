import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get/get.dart';
import 'package:jd_flutter/route.dart';
import 'package:jd_flutter/translation.dart';
import 'package:jd_flutter/utils/app_init.dart';
import 'package:jd_flutter/utils/web_api.dart';

void main() {
  // 确保Flutter框架正确初始化
  WidgetsFlutterBinding.ensureInitialized();
  // 启用性能叠加层
  debugProfileBuildsEnabled = true;
  Get.lazyPut(() => AppInitService(),fenix: true);
  runApp(
    GetMaterialApp(
      onGenerateTitle: (context) => 'app_name'.tr,
      debugShowCheckedModeBanner: false,
      translations: Translation(),
      navigatorObservers: [GetObserver()],
      locale: localeChinese,
      localeListResolutionCallback: (locales, supportedLocales) {
        language = locales!.first.languageCode;
        debugPrint('当前语言: $language');
        return null;
      },
      supportedLocales: [
        localeChinese, //中文
        localeEnglish, //英文
        localeIndonesian, //印度尼西亚
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
      home:  App(),
    ),
  );
}

class App extends StatelessWidget {
  const App({super.key});
  @override
  Widget build(BuildContext context) {
    Get.find<AppInitService>();
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isTestUrl()
              ? [Colors.lightBlueAccent, Colors.greenAccent]
              : [Colors.lightBlueAccent, Colors.blueAccent],
          begin: Alignment.bottomLeft,
          end: Alignment.topRight,
        ),
      ),
    );
  }
}
