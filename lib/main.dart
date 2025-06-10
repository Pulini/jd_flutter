import 'dart:ui';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get/get.dart';
import 'package:get/get_navigation/src/router_report.dart';
import 'package:jd_flutter/route.dart';
import 'package:jd_flutter/utils/network_manager.dart';
import 'package:jd_flutter/utils/utils.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path/path.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';
import 'bean/http/response/bar_code.dart';
import 'bean/http/response/production_dispatch_order_detail_info.dart';
import 'bean/http/response/sap_surplus_material_info.dart';
import 'constant.dart';
import 'home/home_view.dart';
import 'login/login_view.dart';
import 'translation.dart';
import 'utils/web_api.dart';

main() async {
  //确保初始化完成才能加载耗时插件
  WidgetsFlutterBinding.ensureInitialized();

  sharedPreferences = await SharedPreferences.getInstance();
  packageInfo = await PackageInfo.fromPlatform();
  deviceInfo = await DeviceInfoPlugin().deviceInfo;

  // //添加全局网络状态管理
  Get.put(NetworkManager());

  if (GetPlatform.isMobile) {
    getDatabasesPath().then(
      (path) => openDatabase(
        join(path, jdDatabase),
        version: 3,
        onCreate: (db, v) {
          debugPrint('onCreate -----------v=$v');
          db.execute(SaveDispatch.dbCreate);
          db.execute(SaveWorkProcedure.dbCreate);
          db.execute(BarCodeInfo.dbCreate);
          db.execute(SurplusMaterialLabelInfo.dbCreate);
          db.close();
        },
        onUpgrade: (db, ov, nv) {
          debugPrint('onUpgrade-----------ov=$ov nv=$nv');
          // 从版本1开始，逐步处理到最新版本的升级操作
          for (int cv = ov + 1; cv <= nv; cv++) {
            switch (cv) {
              case 2: // 版本1升级到版本2
                debugPrint('版本1升级到版本2');
                db.execute(BarCodeInfo.dbCreate);
                break;
              case 3: // 版本2升级到版本3
                debugPrint('版本2升级到版本3');
                db.execute(SurplusMaterialLabelInfo.dbCreate);
                break;
              default:
                break;
            }
          }
          db.close();
        },
        onOpen: (db) {
          debugPrint('onOpen-------');
        },
      ),
    );
  }

  runApp(const MyApp());
  // 启用性能叠加层
  debugProfileBuildsEnabled = true;
  // FlutterHmsScanKit.scan.then(
  //       (result) => {
  //     logger
  //         .e('form:${result?.scanTypeForm} value:${result?.value}')
  //   },
  // );
}

//路由感知 用于释放GetXController
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

//适配鼠标滚动
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
    return Obx(()=>GetMaterialApp(
      scrollBehavior: AppScrollBehavior(),
      onGenerateTitle: (context) => 'app_name'.tr,
      debugShowCheckedModeBanner: Get.find<NetworkManager>().isTestUrl.value,
      translations: Translation(),
      navigatorObservers: [GetXRouterObserver()],
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
      home: userInfo?.token == null ? const LoginPage() : const HomePage(),
    ));
  }
}
