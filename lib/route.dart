import 'package:get/get.dart';
import 'package:jd_flutter/production/report/daily_report/daily_report_view.dart';

import 'bean/home_button.dart';
import 'home/home_view.dart';
import 'http/web_api.dart';
import 'login/login_view.dart';

class RouteConfig {
  static const String main = '/';
  static const String login = '/login';
  static const String dailyReport = '/daily_report';

  static List<GetPage> appRoutes = [
    GetPage(
      name: main,
      page: () => const Home(),
      transition: Transition.fadeIn,
    ),
    GetPage(name: login, page: () => const Login()),
    GetPage(name: dailyReport, page: () => const DailyReport()),
  ];
}

HomeButton? getNowFunction() {
  var route = Get.currentRoute;
  logger.i('当前路由$route');
  if (route == RouteConfig.main) {
    return null;
  }
  HomeButton? reItem;
  for (var item1 in appButtonList) {
    if (item1 is HomeButton && item1.route == route) {
      reItem = item1;
      break;
    }
    if (item1 is HomeButtonGroup) {
      for (var item2 in item1.functionGroup) {
        if (item2.route == route) {
          reItem = item2;
          break;
        }
      }
    }
  }
  return reItem;
}
