import 'package:get/get.dart';

import 'bean/home_button.dart';
import 'bean/routes.dart';
import 'fun/dispatching/machine_dispatch/machine_dispatch_report_view.dart';
import 'fun/dispatching/machine_dispatch/machine_dispatch_view.dart';
import 'fun/dispatching/material_dispatch/material_dispatch_view.dart';
import 'fun/dispatching/process_dispatch_register/process_dispatch_register_view.dart';
import 'fun/dispatching/production_dispatch/production_dispatch_detail_view.dart';
import 'fun/dispatching/work_order_list/work_order_list_view.dart';
import 'fun/dispatching/production_dispatch/production_dispatch_view.dart';
import 'fun/management/property/property_view.dart';
import 'fun/management/quality_management/quality_management_view.dart';
import 'fun/management/visit_register/visit_register_view.dart';
import 'fun/other/scan/forming_packing_scan/packing_scan_view.dart';
import 'fun/other/scan/part_process_scan/part_process_scan_view.dart';
import 'fun/report/daily_report/daily_report_view.dart';
import 'fun/report/molding_pack_area_report/molding_pack_area_report_view.dart';
import 'fun/report/molding_scan_bulletin_report/molding_scan_bulletin_report_maximize_view.dart';
import 'fun/report/molding_scan_bulletin_report/molding_scan_bulletin_report_view.dart';
import 'fun/report/production_day_report/production_day_report_view.dart';
import 'fun/report/production_materials_report/production_materials_report_view.dart';
import 'fun/report/production_summary_report/production_summary_report_view.dart';
import 'fun/report/view_instruction_details/view_instruction_details_view.dart';
import 'fun/report/view_process_specification/view_process_specification_view.dart';
import 'fun/report/worker_production_detail/worker_production_detail_view.dart';
import 'fun/report/worker_production_report/worker_production_report_view.dart';
import 'fun/warehouse/smart_delivery/smart_delivery_view.dart';
import 'home/home_view.dart';
import 'utils/web_api.dart';
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

  ///成型后段扫描看板
  static Routes moldingScanBulletinReportPage = Routes(
    '/molding_scan_bulletin_report',
    99,
    const MoldingScanBulletinReportPage(),
  );

  ///来访登记
  static Routes visitRegisterPage = Routes(
    '/visitor_registration',
    99,
    const VisitRegisterPage(),
  );

  ///成型后段扫描看板最大化
  static Routes moldingScanBulletinReportMaximize = Routes(
    '/molding_scan_bulletin_report_maximize',
    99,
    const MoldingScanBulletinReportMaximize(),
  );

  ///生产派工
  static Routes productionDispatchPage = Routes(
    '/production_dispatch',
    99,
    const ProductionDispatchPage(),
  );

  ///生产派工-派工明细
  static Routes productionDispatchDetailPage = Routes(
    '/production_dispatch',
    99,
    const ProductionDispatchDetailPage(),
  );

  ///财产管理
  static Routes propertyPage = Routes(
    '/property',
    99,
    const PropertyPage(),
  );

  ///生产订单用料表
  static Routes productionMaterialsReportPage = Routes(
    '/production_materials_report',
    99,
    const ProductionMaterialsReportPage(),
  );

  ///工单列表
  static Routes workOrderListPage = Routes(
    '/work_order_list',
    99,
    const WorkOrderListPage(),
  );

  ///部件工序扫码
  static Routes partProcessScanPage = Routes(
    '/part_process_scan',
    99,
    const PartProcessScanPage(),
  );

  ///材料车间派工
  static Routes materialDispatchPage = Routes(
    '/material_dispatch_page',
    99,
    const MaterialDispatchPage(),
  );

  ///机台派工单
  static Routes machineDispatchPage = Routes(
    '/machine_dispatch_page',
    99,
    const MachineDispatchPage(),
  );

  ///机台派工单汇报
  static Routes machineDispatchReportPage = Routes(
    '/machine_dispatch_report_page',
    99,
    const MachineDispatchReportPage(),
  );

  ///成型装箱扫码
  static Routes packingScanPage = Routes(
    '/scan_packing_page',
    99,
    const PackingScanPage(),
  );

  ///品质检验
  static Routes qualityRestrictionPage = Routes(
    '/quality_restriction',
    99,
    const QualityRestrictionPage(),
  );

  ///湿印工序派工
  static Routes processDispatchRegisterPage = Routes(
    '/process_dispatch_register_page',
    99,
    const ProcessDispatchRegisterPage(),
  );

  ///智能仓库配送
  static Routes smartDeliveryPage = Routes(
    '/smart_delivery_page',
    99,
    const SmartDeliveryPage(),
  );

  ///本地功能入口列表
  static List<Routes> routeList = [
    dailyReport,
    productionSummaryTable,
    productionDayReport,
    viewInstructionDetails,
    workerProductionReport,
    workerProductionDetail,
    viewProcessSpecification,
    moldingPackAreaReport,
    moldingScanBulletinReportPage,
    visitRegisterPage,
    productionDispatchPage,
    productionDispatchDetailPage,
    propertyPage,
    productionMaterialsReportPage,
    workOrderListPage,
    partProcessScanPage,
    materialDispatchPage,
    machineDispatchPage,
    machineDispatchReportPage,
    packingScanPage,
    qualityRestrictionPage
    processDispatchRegisterPage,
    smartDeliveryPage,
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
    GetPage(
      name: moldingScanBulletinReportPage.name,
      page: () => moldingScanBulletinReportPage.page,
    ),
    GetPage(
      name: moldingScanBulletinReportMaximize.name,
      page: () => moldingScanBulletinReportMaximize.page,
    ),
    GetPage(
      name: productionDispatchPage.name,
      page: () => productionDispatchPage.page,
    ),
    GetPage(
      name: productionDispatchDetailPage.name,
      page: () => productionDispatchDetailPage.page,
    ),
    GetPage(
      name: propertyPage.name,
      page: () => propertyPage.page,
    ),
    GetPage(
      name: productionMaterialsReportPage.name,
      page: () => productionMaterialsReportPage.page,
    ),
    GetPage(
      name: visitRegisterPage.name,
      page: () => visitRegisterPage.page,
    ),
    GetPage(
      name: workOrderListPage.name,
      page: () => workOrderListPage.page,
    ),
    GetPage(
      name: partProcessScanPage.name,
      page: () => partProcessScanPage.page,
    ),
    GetPage(
      name: materialDispatchPage.name,
      page: () => materialDispatchPage.page,
    ),
    GetPage(
      name: machineDispatchPage.name,
      page: () => machineDispatchPage.page,
    ),
    GetPage(
      name: machineDispatchReportPage.name,
      page: () => machineDispatchReportPage.page,
    ),
    GetPage(
      name: packingScanPage.name,
      page: () => packingScanPage.page,
    ),
    GetPage(
      name: qualityRestrictionPage.name,
      page: () => qualityRestrictionPage.page,
    ),
    GetPage(
      name: processDispatchRegisterPage.name,
      page: () => processDispatchRegisterPage.page,
    ),
    GetPage(
      name: smartDeliveryPage.name,
      page: () => smartDeliveryPage.page,
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
