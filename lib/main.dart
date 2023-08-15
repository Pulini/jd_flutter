import 'package:flutter/material.dart';
import 'package:get/get.dart';
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
  var userController = Get.put(UserController());
  var user = userInfo();
  if (user != null) {
    userController.init(user);
  }
  runApp(const MyApp());

  // FlutterHmsScanKit.scan.then(
  //       (result) => {
  //     logger
  //         .e("form:${result?.scanTypeForm} value:${result?.value}")
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

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  static final appRoutes = [
    GetPage(name: "/", page: () => const Home(), transition: Transition.fadeIn),
    GetPage(name: "/login", page: () => const Login()),
  ];
  var localeChinese = const Locale('zh', 'CN');
  var localeEnglish = const Locale('en', 'US');

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      onGenerateTitle: (context) => 'app_name'.tr,
      debugShowCheckedModeBanner: false,
      translations: Translation(),
      locale: View.of(context).platformDispatcher.locale,
      localeListResolutionCallback: (locales, supportedLocales) {
        logL("当前语音：$locales");
        language = locales?.first.languageCode ?? "zh";
        return null;
      },
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueAccent),
        useMaterial3: true,
      ),
      getPages: appRoutes,
      home: userController.user.value!.token != null
          ? const Home()
          : const Login(),
      // home:FutureBuilder<UserInfo>(
      //     future: userInfo(),
      //     builder: (context, AsyncSnapshot<UserInfo> snapshot) {
      //       if (snapshot.hasData) {
      //         userController.init(snapshot.requireData);
      //         logger.f("----------1-----------");
      //         return const Home();
      //       } else {
      //         logger.f("----------2-----------");
      //         return const Login();
      //       }
      //     }
      // ),
    );
  }
}
