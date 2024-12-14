import 'package:get/get.dart';

import 'bean/home_button.dart';
import 'bean/routes.dart';
import 'fun/dispatching/machine_dispatch/machine_dispatch_report_view.dart';
import 'fun/dispatching/machine_dispatch/machine_dispatch_view.dart';
import 'fun/dispatching/material_dispatch/material_dispatch_view.dart';
import 'fun/dispatching/part_process_scan/part_process_scan_view.dart';
import 'fun/dispatching/process_dispatch_register/process_dispatch_register_view.dart';
import 'fun/dispatching/production_dispatch/production_dispatch_detail_view.dart';
import 'fun/dispatching/production_dispatch/production_dispatch_view.dart';
import 'fun/dispatching/work_order_list/work_order_list_view.dart';
import 'fun/management/property/property_view.dart';
import 'fun/management/quality_management/quality_management_view.dart';
import 'fun/management/visit_register/visit_register_view.dart';
import 'fun/other/forming_packing_scan/packing_scan_view.dart';
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
import 'fun/warehouse/in/sap_injection_molding_stock_in/sap_injection_molding_stock_in_view.dart';
import 'fun/warehouse/in/sap_no_label_stock_in/sap_no_label_stock_in_view.dart';
import 'fun/warehouse/in/sap_purchase_stock_in/sap_purchase_stock_in_view.dart';
import 'fun/warehouse/in/sap_surplus_material_stock_in/sap_surplus_material_stock_in_view.dart';
import 'fun/warehouse/manage/carton_label_scan/carton_label_scan_view.dart';
import 'fun/warehouse/manage/carton_label_scan_progress/carton_label_scan_progress_view.dart';
import 'fun/warehouse/manage/smart_delivery/smart_delivery_view.dart';
import 'fun/warehouse/out/sap_print_picking/sap_print_picking_view.dart';
import 'fun/warehouse/out/sap_production_picking/sap_production_picking_view.dart';
import 'fun/warehouse/out/sap_relocation_picking/sap_relocation_picking_view.dart';
import 'home/home_view.dart';
import 'login/login_view.dart';
import 'utils/web_api.dart';

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
  static Routes moldingScanBulletinReport = Routes(
    '/molding_scan_bulletin_report',
    99,
    const MoldingScanBulletinReportPage(),
  );

  ///来访登记
  static Routes visitRegister = Routes(
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
  static Routes productionDispatch = Routes(
    '/production_dispatch',
    99,
    const ProductionDispatchPage(),
  );

  ///生产派工-派工明细
  static Routes productionDispatchDetail = Routes(
    '/production_dispatch',
    99,
    const ProductionDispatchDetailPage(),
  );

  ///财产管理
  static Routes property = Routes(
    '/property',
    99,
    const PropertyPage(),
  );

  ///生产订单用料表
  static Routes productionMaterialsReport = Routes(
    '/production_materials_report',
    99,
    const ProductionMaterialsReportPage(),
  );

  ///工单列表
  static Routes workOrderList = Routes(
    '/work_order_list',
    99,
    const WorkOrderListPage(),
  );

  ///部件工序扫码
  static Routes partProcessScan = Routes(
    '/part_process_scan',
    99,
    const PartProcessScanPage(),
  );

  ///材料车间派工
  static Routes materialDispatch = Routes(
    '/material_dispatch_page',
    99,
    const MaterialDispatchPage(),
  );

  ///机台派工单
  static Routes machineDispatch = Routes(
    '/machine_dispatch_page',
    99,
    const MachineDispatchPage(),
  );

  ///机台派工单汇报
  static Routes machineDispatchReport = Routes(
    '/machine_dispatch_report_page',
    99,
    const MachineDispatchReportPage(),
  );

  ///成型装箱扫码
  static Routes packingScan = Routes(
    '/scan_packing_page',
    99,
    const PackingScanPage(),
  );

  ///品质检验
  static Routes qualityRestriction = Routes(
    '/quality_restriction',
    99,
    const QualityRestrictionPage(),
  );

  ///湿印工序派工
  static Routes processDispatchRegister = Routes(
    '/process_dispatch_register_page',
    99,
    const ProcessDispatchRegisterPage(),
  );

  ///智能仓库配送
  static Routes smartDelivery = Routes(
    '/smart_delivery_page',
    99,
    const SmartDeliveryPage(),
  );

  ///外箱标扫码
  static Routes cartonLabelScan = Routes(
    '/carton_label_scan_page',
    99,
    const CartonLabelScanPage(),
  );

  ///外箱标扫码进度
  static Routes cartonLabelScanProgress = Routes(
    '/carton_label_scan_progress_page',
    99,
    const CartonLabelScanProgressPage(),
  );

  ///sap采购入库
  static Routes sapPurchaseStockIn = Routes(
    '/sap_purchase_stock_in',
    99,
    const SapPurchaseStockInPage(),
  );

  ///sap生产领料
  static Routes sapProductionPicking = Routes(
    '/sap_production_picking',
    99,
    const SapProductionPickingPage(),
  );

  ///sap喷漆领料
  static Routes sapPrintPicking = Routes(
    '/sap_print_picking',
    99,
    const SapPrintPickingPage(),
  );

  ///sap移库领料
  static Routes sapRelocationPicking = Routes(
    '/sap_relocation_picking',
    99,
    const SapRelocationPickingPage(),
  );

  ///sap移库领料
  static Routes sapNoLabelStockIn = Routes(
    '/sap_no_label_stock_in',
    99,
    const SapNoLabelStockInPage(),
  );

  ///sap注塑入库
  static Routes sapInjectionMoldingStockIn = Routes(
    '/sap_injection_molding_stock_in',
    99,
    const SapInjectionMoldingStockInPage(),
  );

  ///sap料头入库
  static Routes sapSurplusMaterialStockIn = Routes(
    '/sap_surplus_material_stock_in',
    99,
    const SapSurplusMaterialStockInPage(),
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
    moldingScanBulletinReport,
    visitRegister,
    productionDispatch,
    productionDispatchDetail,
    property,
    productionMaterialsReport,
    workOrderList,
    partProcessScan,
    materialDispatch,
    machineDispatch,
    machineDispatchReport,
    packingScan,
    qualityRestriction,
    processDispatchRegister,
    smartDelivery,
    cartonLabelScan,
    cartonLabelScanProgress,
    sapPurchaseStockIn,
    sapProductionPicking,
    sapPrintPicking,
    sapRelocationPicking,
    sapNoLabelStockIn,
    sapInjectionMoldingStockIn,
    sapSurplusMaterialStockIn
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
      name: moldingScanBulletinReport.name,
      page: () => moldingScanBulletinReport.page,
    ),
    GetPage(
      name: moldingScanBulletinReportMaximize.name,
      page: () => moldingScanBulletinReportMaximize.page,
    ),
    GetPage(
      name: productionDispatch.name,
      page: () => productionDispatch.page,
    ),
    GetPage(
      name: productionDispatchDetail.name,
      page: () => productionDispatchDetail.page,
    ),
    GetPage(
      name: property.name,
      page: () => property.page,
    ),
    GetPage(
      name: productionMaterialsReport.name,
      page: () => productionMaterialsReport.page,
    ),
    GetPage(
      name: visitRegister.name,
      page: () => visitRegister.page,
    ),
    GetPage(
      name: workOrderList.name,
      page: () => workOrderList.page,
    ),
    GetPage(
      name: partProcessScan.name,
      page: () => partProcessScan.page,
    ),
    GetPage(
      name: materialDispatch.name,
      page: () => materialDispatch.page,
    ),
    GetPage(
      name: machineDispatch.name,
      page: () => machineDispatch.page,
    ),
    GetPage(
      name: machineDispatchReport.name,
      page: () => machineDispatchReport.page,
    ),
    GetPage(
      name: packingScan.name,
      page: () => packingScan.page,
    ),
    GetPage(
      name: qualityRestriction.name,
      page: () => qualityRestriction.page,
    ),
    GetPage(
      name: processDispatchRegister.name,
      page: () => processDispatchRegister.page,
    ),
    GetPage(
      name: smartDelivery.name,
      page: () => smartDelivery.page,
    ),
    GetPage(
      name: cartonLabelScan.name,
      page: () => cartonLabelScan.page,
    ),
    GetPage(
      name: cartonLabelScanProgress.name,
      page: () => cartonLabelScanProgress.page,
    ),
    GetPage(
      name: sapPurchaseStockIn.name,
      page: () => sapPurchaseStockIn.page,
    ),
    GetPage(
      name: sapProductionPicking.name,
      page: () => sapProductionPicking.page,
    ),
    GetPage(
      name: sapPrintPicking.name,
      page: () => sapPrintPicking.page,
    ),
    GetPage(
      name: sapRelocationPicking.name,
      page: () => sapRelocationPicking.page,
    ),
    GetPage(
      name: sapNoLabelStockIn.name,
      page: () => sapNoLabelStockIn.page,
    ),
    GetPage(
      name: sapInjectionMoldingStockIn.name,
      page: () => sapInjectionMoldingStockIn.page,
    ),
    GetPage(
      name: sapSurplusMaterialStockIn.name,
      page: () => sapSurplusMaterialStockIn.page,
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
