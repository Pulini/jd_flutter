import 'package:get/get.dart';
import 'package:jd_flutter/fun/report/production_day_report/production_day_report_view.dart';

import 'bean/home_button.dart';
import 'fun/report/daily_report/daily_report_view.dart';
import 'fun/report/production_summary_report/production_summary_report_view.dart';
import 'home/home_view.dart';
import 'http/web_api.dart';
import 'login/login_view.dart';

class RouteConfig {
  static const String main = '/';
  static const String login = '/login';
  static const String dailyReport = '/daily_report';
  static const String productionSummaryTable = '/production_summary_table';
  static const String productionDayReport = '/production_day_report';

  static List<GetPage> appRoutes = [
    GetPage(
      name: main,
      page: () => const HomePage(),
      transition: Transition.fadeIn,
    ),
    GetPage(name: login, page: () => const LoginPage()),
    GetPage(name: dailyReport, page: () => const DailyReportPage()),
    GetPage(name: productionSummaryTable, page: () => const ProductionSummaryReportPage()),
    GetPage(name: productionDayReport, page: () => const ProductionDayReportPage()),
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
