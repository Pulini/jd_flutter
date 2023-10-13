import 'package:get/get.dart';

import 'bean/home_button.dart';
import 'bean/routes.dart';
import 'fun/report/daily_report/daily_report_view.dart';
import 'fun/report/molding_pack_area_report/molding_pack_area_report_view.dart';
import 'fun/report/production_day_report/production_day_report_view.dart';
import 'fun/report/production_summary_report/production_summary_report_view.dart';
import 'fun/report/view_instruction_details/view_instruction_details_view.dart';
import 'fun/report/view_process_specification/view_process_specification_view.dart';
import 'fun/report/worker_production_detail/worker_production_detail_view.dart';
import 'fun/report/worker_production_report/worker_production_report_view.dart';
import 'fun/report/workshop_production_daily_report/workshop_production_daily_report_view.dart';
import 'home/home_view.dart';
import 'http/web_api.dart';
import 'login/login_view.dart';

class RouteConfig {
  static const String main = '/';
  static const login = '/login';

  ///扫码日产量报表
  static Routes dailyReport = Routes(
    '/daily_report',
    99,
    const DailyReportPage(),
  );

  ///产量汇总表
  static Routes productionSummaryTable = Routes(
    '/production_summary_table',
    99,
    const ProductionSummaryReportPage(),
  );

  ///日生产报表
  static Routes productionDayReport = Routes(
    '/production_day_report',
    99,
    const ProductionDayReportPage(),
  );

  ///车间生产日报表
  static Routes workshopProductionDailyReport = Routes(
    '/workshop_production_daily_report',
    99,
    const WorkshopProductionDailyReportPage(),
  );

  ///查看指令明细
  static Routes viewInstructionDetails = Routes(
    '/view_instruction_details',
    99,
    const ViewInstructionDetailsPage(),
  );

  ///员工计件产量查询
  static Routes workerProductionReport = Routes(
    '/worker_production_report',
    99,
    const WorkerProductionReportPage(),
  );

  ///员工计件明细
  static Routes workerProductionDetail = Routes(
    '/worker_production_detail',
    99,
    const WorkerProductionDetailPage(),
  );

  ///查看工艺说明书
  static Routes viewProcessSpecification = Routes(
    '/view_process_specification',
    99,
    const ViewProcessSpecificationPage(),
  );

  ///打包区报表
  static Routes moldingPackAreaReport = Routes(
    '/molding_pack_area_report',
    99,
    const MoldingPackAreaReportPage(),
  );

  ///本地功能入口列表
  static List<Routes> routeList = [
    dailyReport,
    productionSummaryTable,
    productionDayReport,
    workshopProductionDailyReport,
    viewInstructionDetails,
    workerProductionReport,
    workerProductionDetail,
    viewProcessSpecification,
    moldingPackAreaReport,
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
    GetPage(
      name: workshopProductionDailyReport.name,
      page: () => workshopProductionDailyReport.page,
    ),
    GetPage(
      name: viewInstructionDetails.name,
      page: () => viewInstructionDetails.page,
    ),
    GetPage(
      name: workerProductionReport.name,
      page: () => workerProductionReport.page,
    ),
    GetPage(
      name: workerProductionDetail.name,
      page: () => workerProductionDetail.page,
    ),
    GetPage(
      name: viewProcessSpecification.name,
      page: () => viewProcessSpecification.page,
    ),
    GetPage(
      name: moldingPackAreaReport.name,
      page: () => moldingPackAreaReport.page,
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

String getFunctionTitle() {
  var route = Get.currentRoute;
  if (route == RouteConfig.main) return '';
  for (var item1 in functions) {
    if (item1 is HomeButton && item1.route == route) {
      return item1.name;
    }
    if (item1 is HomeButtonGroup) {
      for (var item2 in item1.functionGroup) {
        if (item2.route == route) {
          return item2.name;
        }
      }
    }
  }
  return '';
}
