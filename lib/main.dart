import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get/get.dart';
import 'package:get/get_navigation/src/router_report.dart';
import 'package:jd_flutter/route.dart';
import 'package:jd_flutter/utils.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'home/home_view.dart';
import 'http/response/user_info.dart';
import 'http/web_api.dart';
import 'login/login_view.dart';
import 'translation.dart';

main() async {
  WidgetsFlutterBinding.ensureInitialized();
  sharedPreferences = await SharedPreferences.getInstance();
  packageInfo = await PackageInfo.fromPlatform();
  deviceInfo = await DeviceInfoPlugin().deviceInfo;
  var userController = Get.put(UserController());
  var user = userInfo();
  if (user != null) {
    userController.init(user);
  }
  runApp(const MyApp());

  // FlutterHmsScanKit.scan.then(
  //       (result) => {
  //     logger
  //         .e('form:${result?.scanTypeForm} value:${result?.value}')
  //   },
  // );
}

class UserController extends GetxController {
  Rx<UserInfo?> user = UserInfo().obs;

  init(UserInfo userInfo) {
    user = userInfo.obs;
    update();
  }
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

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {


  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      onGenerateTitle: (context) => 'app_name'.tr,
      debugShowCheckedModeBanner: false,
      translations: Translation(),
      navigatorObservers: [GetXRouterObserver()],
      locale: View.of(context).platformDispatcher.locale,
      localeListResolutionCallback: (locales, supportedLocales) {
        language = locales?.first.languageCode==localeChinese.languageCode?'zh':'en';
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
      home: userController.user.value!.token != null
          ? const HomePage()
          : const LoginPage(),
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
