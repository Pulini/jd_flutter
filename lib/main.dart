import 'dart:ui';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get/get.dart';
import 'package:get/get_navigation/src/router_report.dart';
import 'package:jd_flutter/route.dart';
import 'package:jd_flutter/utils/utils.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path/path.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';

import 'bean/http/response/production_dispatch_order_detail_info.dart';
import 'constant.dart';
import 'home/home_view.dart';
import 'login/login_view.dart';
import 'translation.dart';
import 'utils/web_api.dart';
 main() async {
  ///确保初始化完成才能加载耗时插件
  WidgetsFlutterBinding.ensureInitialized();
  if (GetPlatform.isMobile){
    getDatabasesPath().then((path) => openDatabase(
      join(path, jdDatabase),
      version: 1,
      onCreate:(db,v){
        db.execute(SaveDispatch.dbCreate);
        db.execute(SaveWorkProcedure.dbCreate);
        db.close();
      },
    ));
  }
  sharedPreferences = await SharedPreferences.getInstance();
  packageInfo = await PackageInfo.fromPlatform();
  deviceInfo = await DeviceInfoPlugin().deviceInfo;

  runApp(const MyApp());

  // FlutterHmsScanKit.scan.then(
  //       (result) => {
  //     logger
  //         .e('form:${result?.scanTypeForm} value:${result?.value}')
  //   },
  // );
}



///路由感知 用于释放GetXController
class GetXRouterObserver extends NavigatorObserver {
  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    RouterReportManager.reportCurrentRoute(route);
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) async {
    RouterReportManager.reportRouteDispose(route);
  }
}

///适配鼠标滚动
class AppScrollBehavior extends MaterialScrollBehavior {
  @override
  Set<PointerDeviceKind> get dragDevices => {
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
      };
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    userInfo = getUserInfo();
    return GetMaterialApp(
      scrollBehavior: AppScrollBehavior(),
      onGenerateTitle: (context) => 'app_name'.tr,
      debugShowCheckedModeBanner: false,
      translations: Translation(),
      navigatorObservers: [GetXRouterObserver()],
      locale: View.of(context).platformDispatcher.locale,
      localeListResolutionCallback: (locales, supportedLocales) {
        language = locales?.first.languageCode == localeChinese.languageCode
            ? 'zh'
            : 'en';
        log('当前语音：$locales');
        return null;
      },
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueAccent),
        useMaterial3: true,
      ),
      getPages: RouteConfig.appRoutes,
      home: userInfo?.token==null ? const LoginPage() : const HomePage(),
      // home:FutureBuilder<UserInfo>(
      //     future: userInfo(),
      //     builder: (context, AsyncSnapshot<UserInfo> snapshot) {
      //       if (snapshot.hasData) {
      //         userController.init(snapshot.requireData);
      //         logger.f('----------1-----------');
      //         return const Home();
      //       } else {
      //         logger.f('----------2-----------');
      //         return const Login();
      //       }
      //     }
      // ),
    );
  }
}
