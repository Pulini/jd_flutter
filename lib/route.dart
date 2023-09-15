import 'package:get/get.dart';

import 'bean/home_button.dart';
import 'bean/routes.dart';
import 'fun/report/daily_report/daily_report_view.dart';
import 'fun/report/production_day_report/production_day_report_view.dart';
import 'fun/report/production_summary_report/production_summary_report_view.dart';
import 'home/home_view.dart';
import 'http/web_api.dart';
import 'login/login_view.dart';

class RouteConfig {
  static const String main = '/';
  static const login = '/login';

  static Routes dailyReport = Routes(
    '/daily_report',
    1,
    const DailyReportPage(),
  );
  static Routes productionSummaryTable = Routes(
    '/production_summary_table',
    1,
    const ProductionSummaryReportPage(),
  );
  static Routes productionDayReport = Routes(
    '/production_day_report',
    1,
    const ProductionDayReportPage(),
  );

  static List<Routes> routeList = [
    dailyReport,
    productionSummaryTable,
    productionDayReport,
  ];

  static List<GetPage> appRoutes = [
    GetPage(
      name: main,
      page: () => const HomePage(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: login,
      page: () => const LoginPage(),
    ),
    GetPage(
      name: dailyReport.name,
      page: () => dailyReport.page,
    ),
    GetPage(
      name: productionSummaryTable.name,
      page: () => productionSummaryTable.page,
    ),
    GetPage(
      name: productionDayReport.name,
      page: () => productionDayReport.page,
    ),
  ];
}

var functions = <ButtonItem>[];

HomeButton? getNowFunction() {
  var route = Get.currentRoute;
  logger.i('当前路由$route');
  if (route == RouteConfig.main) {
    return null;
  }
  HomeButton? reItem;
  for (var item1 in functions) {
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
