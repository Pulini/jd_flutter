import 'package:get/get.dart';
import 'package:jd_flutter/bean/home_button.dart';
import 'package:jd_flutter/bean/routes.dart';
import 'package:jd_flutter/fun/dispatching/injection_scan_report/injection_scan_report_view.dart';
import 'package:jd_flutter/fun/dispatching/machine_dispatch/machine_dispatch_report_view.dart';
import 'package:jd_flutter/fun/dispatching/machine_dispatch/machine_dispatch_view.dart';
import 'package:jd_flutter/fun/dispatching/material_dispatch/material_dispatch_view.dart';
import 'package:jd_flutter/fun/dispatching/process_dispatch_register/process_dispatch_register_view.dart';
import 'package:jd_flutter/fun/dispatching/production_dispatch/production_dispatch_detail_view.dart';
import 'package:jd_flutter/fun/dispatching/production_dispatch/production_dispatch_view.dart';
import 'package:jd_flutter/fun/dispatching/work_order_list/work_order_list_view.dart';
import 'package:jd_flutter/fun/maintenance/sap_ink_color_matching/sap_ink_color_matching_view.dart';
import 'package:jd_flutter/fun/management/property/property_view.dart';
import 'package:jd_flutter/fun/management/visit_register/visit_register_view.dart';
import 'package:jd_flutter/fun/other/device_maintenance_record/device_maintenance_record_view.dart';
import 'package:jd_flutter/fun/other/hydroelectric_excess/hydroelectric_excess_view.dart';
import 'package:jd_flutter/fun/report/daily_report/daily_report_view.dart';
import 'package:jd_flutter/fun/report/forming_barcode_collection/forming_barcode_collection_view.dart';
import 'package:jd_flutter/fun/report/molding_pack_area_report/molding_pack_area_report_view.dart';
import 'package:jd_flutter/fun/report/molding_scan_bulletin_report/molding_scan_bulletin_report_maximize_view.dart';
import 'package:jd_flutter/fun/report/molding_scan_bulletin_report/molding_scan_bulletin_report_view.dart';
import 'package:jd_flutter/fun/report/production_day_report/production_day_report_view.dart';
import 'package:jd_flutter/fun/report/production_materials_report/production_materials_report_view.dart';
import 'package:jd_flutter/fun/report/production_summary_report/production_summary_report_view.dart';
import 'package:jd_flutter/fun/report/view_instruction_details/view_instruction_details_view.dart';
import 'package:jd_flutter/fun/report/view_process_specification/view_process_specification_view.dart';
import 'package:jd_flutter/fun/report/worker_production_detail/worker_production_detail_view.dart';
import 'package:jd_flutter/fun/report/worker_production_report/worker_production_report_view.dart';
import 'package:jd_flutter/fun/warehouse/in/delivery_order/delivery_order_view.dart';
import 'package:jd_flutter/fun/warehouse/in/incoming_inspection/incoming_inspection_view.dart';
import 'package:jd_flutter/fun/warehouse/in/process_report/process_report_store_view.dart';
import 'package:jd_flutter/fun/warehouse/in/production_scan_warehouse/production_scan_warehouse_view.dart';
import 'package:jd_flutter/fun/warehouse/in/purchase_order_reversal/purchase_order_reversal_view.dart';
import 'package:jd_flutter/fun/warehouse/in/purchase_order_warehousing/purchase_order_warehousing_view.dart';
import 'package:jd_flutter/fun/warehouse/in/quality_inspection_list/quality_inspection_list_view.dart';
import 'package:jd_flutter/fun/warehouse/in/sap_injection_molding_stock_in/sap_injection_molding_stock_in_view.dart';
import 'package:jd_flutter/fun/warehouse/in/sap_no_label_stock_in/sap_no_label_stock_in_view.dart';
import 'package:jd_flutter/fun/warehouse/in/sap_picking_receipt_reversal/sap_picking_receipt_reversal_view.dart';
import 'package:jd_flutter/fun/warehouse/in/sap_produce_stock_in/sap_produce_stock_in_view.dart';
import 'package:jd_flutter/fun/warehouse/in/sap_purchase_stock_in/sap_purchase_stock_in_view.dart';
import 'package:jd_flutter/fun/warehouse/in/sap_put_on_shelves/sap_put_on_shelves_view.dart';
import 'package:jd_flutter/fun/warehouse/in/sap_surplus_material_stock_in/sap_surplus_material_stock_in_view.dart';
import 'package:jd_flutter/fun/warehouse/in/suppliers_scan_store/suppliers_scan_store_view.dart';
import 'package:jd_flutter/fun/warehouse/in/temporary_order/temporary_order_view.dart';
import 'package:jd_flutter/fun/warehouse/manage/carton_label_scan/carton_label_scan_progress_view.dart';
import 'package:jd_flutter/fun/warehouse/manage/carton_label_scan/carton_label_scan_view.dart';
import 'package:jd_flutter/fun/warehouse/manage/part_dispatch_label_manage/pack_order_list/pack_order_list_view.dart';
import 'package:jd_flutter/fun/warehouse/manage/part_dispatch_label_manage/part_dispatch_order_list/part_dispatch_order_list_view.dart';
import 'package:jd_flutter/fun/warehouse/manage/patrol_inspection/patrol_inspection_view.dart';
import 'package:jd_flutter/fun/warehouse/manage/print_pallet/print_pallet_view.dart';
import 'package:jd_flutter/fun/warehouse/manage/quality_inspection/quality_inspection_view.dart';
import 'package:jd_flutter/fun/warehouse/manage/sap_carton_label_binding/sap_carton_label_binding_view.dart';
import 'package:jd_flutter/fun/warehouse/manage/sap_factory_inventory/sap_counting_inventory_view.dart';
import 'package:jd_flutter/fun/warehouse/manage/sap_factory_inventory/sap_scan_code_inventory_view.dart';
import 'package:jd_flutter/fun/warehouse/manage/sap_inner_box_label_split/sap_inner_box_label_split_view.dart';
import 'package:jd_flutter/fun/warehouse/manage/sap_label_reprint/sap_label_reprint_view.dart';
import 'package:jd_flutter/fun/warehouse/manage/sap_stock_transfer/sap_stock_transfer_view.dart';
import 'package:jd_flutter/fun/warehouse/manage/sap_wms_reprint_labels/sap_wms_reprint_labels_view.dart';
import 'package:jd_flutter/fun/warehouse/manage/sap_wms_split_label/sap_wms_split_label_view.dart';
import 'package:jd_flutter/fun/warehouse/manage/smart_delivery/smart_delivery_view.dart';
import 'package:jd_flutter/fun/warehouse/manage/timely_inventory/timely_inventory_view.dart';
import 'package:jd_flutter/fun/warehouse/manage/warehouse_allocation/warehouse_allocation_view.dart';
import 'package:jd_flutter/fun/warehouse/out/material_label_scan/material_label_scan_view.dart';
import 'package:jd_flutter/fun/warehouse/out/picking_material_order/picking_material_order_view.dart';
import 'package:jd_flutter/fun/warehouse/out/production_scan_picking_material/production_scan_picking_material_view.dart';
import 'package:jd_flutter/fun/warehouse/out/sale_scan_out_warehouse/sale_scan_out_warehouse_view.dart';
import 'package:jd_flutter/fun/warehouse/out/sap_packing_scan/sap_packing_scan_view.dart';
import 'package:jd_flutter/fun/warehouse/out/sap_packing_scan_cache_list/sap_packing_scan_cache_list_view.dart';
import 'package:jd_flutter/fun/warehouse/out/sap_packing_scan_reverse/sap_packing_scan_reverse_view.dart';
import 'package:jd_flutter/fun/warehouse/out/sap_print_picking/sap_print_picking_view.dart';
import 'package:jd_flutter/fun/warehouse/out/sap_production_picking/sap_production_picking_view.dart';
import 'package:jd_flutter/fun/warehouse/out/sap_relocation_picking/sap_relocation_picking_view.dart';
import 'package:jd_flutter/fun/warehouse/out/sap_sales_shipment/sap_sales_shipment_view.dart';
import 'package:jd_flutter/fun/warehouse/out/scan_picking_material/scan_picking_material_view.dart';
import 'package:jd_flutter/fun/warehouse/out/wait_picking_material/wait_picking_material_view.dart';
import 'package:jd_flutter/fun/work_reporting/component_handover/component_handover_view.dart';
import 'package:jd_flutter/fun/work_reporting/handover_report_list/handover_report_list_view.dart';
import 'package:jd_flutter/fun/work_reporting/part_process_scan/part_process_scan_view.dart';
import 'package:jd_flutter/fun/work_reporting/part_report_cancel/part_report_cancel_view.dart';
import 'package:jd_flutter/fun/work_reporting/part_report_scan/part_report_scan_view.dart';
import 'package:jd_flutter/fun/work_reporting/process_dispatch_list/process_dispatch_view.dart';
import 'package:jd_flutter/fun/work_reporting/process_report/process_report_view.dart';
import 'package:jd_flutter/fun/work_reporting/production_tasks/production_tasks_view.dart';
import 'package:jd_flutter/fun/work_reporting/workshop_planning/workshop_planning_view.dart';
import 'package:jd_flutter/home/home_view.dart';
import 'package:jd_flutter/login/login_view.dart';

import 'fun/warehouse/in/anti_counterfeiting/puma_anti_counterfeiting_view.dart';
import 'fun/warehouse/out/forming_packing_scan/packing_scan_view.dart';

class RouteConfig {
  static const String home = '/home';
  static const String login = '/login';

  //扫码日产量报表
  static Routes dailyReport = Routes(
    '/daily_report',
    200,
    const DailyReportPage(),
  );

  //产量汇总表
  static Routes productionSummaryTable = Routes(
    '/production_summary_table',
    200,
    const ProductionSummaryReportPage(),
  );

  //生产日报表
  static Routes productionDayReport = Routes(
    '/production_day_report',
    201,
    const ProductionDayReportPage(),
  );

  //查看指令明细
  static Routes viewInstructionDetails = Routes(
    '/view_instruction_details',
    201,
    const ViewInstructionDetailsPage(),
  );

  //员工计件产量查询
  static Routes workerProductionReport = Routes(
    '/worker_production_report',
    200,
    const WorkerProductionReportPage(),
  );

  //员工计件明细
  static Routes workerProductionDetail = Routes(
    '/worker_production_detail',
    200,
    const WorkerProductionDetailPage(),
  );

  //查看工艺说明书
  static Routes viewProcessSpecification = Routes(
    '/view_process_specification',
    200,
    const ViewProcessSpecificationPage(),
  );

  //打包区报表
  static Routes moldingPackAreaReport = Routes(
    '/molding_pack_area_report',
    200,
    const MoldingPackAreaReportPage(),
  );

  //成型后段扫描看板
  static Routes moldingScanBulletinReport = Routes(
    '/molding_scan_bulletin_report',
    200,
    const MoldingScanBulletinReportPage(),
  );

  //来访登记
  static Routes visitRegister = Routes(
    '/visitor_registration',
    204,
    const VisitRegisterPage(),
  );

  //成型后段扫描看板最大化
  static Routes moldingScanBulletinReportMaximize = Routes(
    '/molding_scan_bulletin_report_maximize',
    200,
    const MoldingScanBulletinReportMaximize(),
  );

  //生产派工
  static Routes productionDispatch = Routes(
    '/production_dispatch',
    221,
    const ProductionDispatchPage(),
  );

  //生产派工-派工明细
  static Routes productionDispatchDetail = Routes(
    '/production_dispatch',
    200,
    const ProductionDispatchDetailPage(),
  );

  //财产管理
  static Routes property = Routes(
    '/property',
    202,
    const PropertyPage(),
  );

  //生产订单用料表
  static Routes productionMaterialsReport = Routes(
    '/production_materials_report',
    200,
    const ProductionMaterialsReportPage(),
  );

  //工单列表
  static Routes workOrderList = Routes(
    '/work_order_list',
    204,
    const WorkOrderListPage(),
  );

  //部件工序扫码
  static Routes partProcessScan = Routes(
    '/part_process_scan',
    200,
    const PartProcessScanPage(),
  );

  //材料车间派工
  static Routes materialDispatch = Routes(
    '/material_dispatch_page',
    213,
    const MaterialDispatchPage(),
  );

  //机台派工单
  static Routes machineDispatch = Routes(
    '/machine_dispatch_page',
    214,
    const MachineDispatchPage(),
  );

  //机台派工单汇报
  static Routes machineDispatchReport = Routes(
    '/machine_dispatch_report_page',
    200,
    const MachineDispatchReportPage(),
  );

  //成型装箱扫码
  static Routes packingScan = Routes(
    '/scan_packing_page',
    200,
    const PackingScanPage(),
  );

  //湿印工序派工
  static Routes processDispatchRegister = Routes(
    '/process_dispatch_register_page',
    203,
    const ProcessDispatchRegisterPage(),
  );

  //智能仓库配送
  static Routes smartDelivery = Routes(
    '/smart_delivery_page',
    200,
    const SmartDeliveryPage(),
  );

  //外箱标扫码
  static Routes cartonLabelScan = Routes(
    '/carton_label_scan_page',
    201,
    const CartonLabelScanPage(),
  );

  //外箱标扫码进度
  static Routes cartonLabelScanProgress = Routes(
    '/carton_label_scan_progress_page',
    200,
    const CartonLabelScanProgressPage(),
  );

  //水电抄度
  static Routes hydroelectricExcess = Routes(
    '/hydroelectric_excess_page',
    202,
    const HydroelectricExcessPage(),
  );

  //设备维修记录
  static Routes deviceMaintenance = Routes(
    '/device_maintenance_record',
    200,
    const DeviceMaintenanceRecordPage(),
  );

  //仓库调拨
  static Routes warehouseAllocation = Routes(
    '/warehouse_allocation_page',
    200,
    const WarehouseAllocationPage(),
  );

  //即时库存查询
  static Routes timelyInventory = Routes(
    '/timely_inventory_page',
    200,
    const TimelyInventoryPage(),
  );

  //PUMA防伪标管理
  static Routes antiCounterfeiting = Routes(
    '/anti_counterfeiting',
    201,
    const PumaAntiCounterfeitingPage(),
  );

  //sap采购入库
  static Routes sapPurchaseStockIn = Routes(
    '/sap_purchase_stock_in',
    204,
    const SapPurchaseStockInPage(),
  );

  //sap生产领料
  static Routes sapProductionPicking = Routes(
    '/sap_production_picking',
    203,
    const SapProductionPickingPage(),
  );

  //sap喷漆领料
  static Routes sapPrintPicking = Routes(
    '/sap_print_picking',
    201,
    const SapPrintPickingPage(),
  );

  //sap移库领料
  static Routes sapRelocationPicking = Routes(
    '/sap_relocation_picking',
    200,
    const SapRelocationPickingPage(),
  );

  //sap无标入库
  static Routes sapNoLabelStockIn = Routes(
    '/sap_no_label_stock_in',
    202,
    const SapNoLabelStockInPage(),
  );

  //sap注塑入库
  static Routes sapInjectionMoldingStockIn = Routes(
    '/sap_injection_molding_stock_in',
    203,
    const SapInjectionMoldingStockInPage(),
  );

  //sap料头入库
  static Routes sapSurplusMaterialStockIn = Routes(
    '/sap_surplus_material_stock_in',
    206,
    const SapSurplusMaterialStockInPage(),
  );

  //sap生产入库
  static Routes sapProduceStockIn = Routes(
    '/sap_produce_stock_in',
    200,
    const SapProduceStockInPage(),
  );

  //sap销售出库
  static Routes sapSalesShipment = Routes(
    '/sap_sales_shipment',
    201,
    const SapSalesShipmentPage(),
  );

  //sap领料入库冲销
  static Routes sapPickingReceiptReversal = Routes(
    '/sap_picking_receipt_reversal',
    201,
    const SapPickingReceiptReversalPage(),
  );

  //sap贴标上架
  static Routes sapPutOnShelves = Routes(
    '/sap_put_on_shelves',
    201,
    const SapPutOnShelvesPage(),
  );

  //sap移库
  static Routes sapStockTransfer = Routes(
    '/sap_stock_transfer',
    200,
    const SapStockTransferPage(),
  );

  //sap贴标重打
  static Routes sapWmsReprintLabels = Routes(
    '/sap_wms_reprint_labels',
    200,
    const SapWmsReprintLabelsPage(),
  );

  //sap贴标拆分
  static Routes sapWmsSplitLabel = Routes(
    '/sap_wms_split_label',
    200,
    const SapWmsSplitLabelPage(),
  );

  //sap油墨调色
  static Routes sapInkColorMatching = Routes(
    '/sap_ink_color_matching',
    200,
    const SapInkColorMatchingPage(),
  );

  //成型生产任务
  static Routes productionTasks = Routes(
    '/production_tasks',
    200,
    const ProductionTasksPage(),
  );

  //供应商扫码入库
  static Routes suppliersScanStore = Routes(
    '/suppliers_scan_store',
    202,
    const SuppliersScanStorePage(),
  );

  //生产扫码入库
  static Routes productionScanWarehouse = Routes(
    '/production_scan_warehouse',
    201,
    const ProductionScanWarehousePage(),
  );

  //来料稽查
  static Routes incomingInspection = Routes(
    '/incoming_inspection',
    204,
    const IncomingInspectionPage(),
  );

  //扫码领料出库
  static Routes scanPickingMaterial = Routes(
    '/scan_picking_material',
    201,
    const ScanPickingMaterialPage(),
  );

  //工序汇报入库
  static Routes processReportWarehouse = Routes(
    '/process_report_warehouse',
    208,
    const ProcessReportStorePage(),
  );

  //注塑车间扫码报工
  static Routes injectionScanReport = Routes(
    '/injection_scan_report',
    202,
    const InjectionScanReportPage(),
  );

  //销售扫码出库
  static Routes saleScanOutWarehouse = Routes(
    '/sale_scan_out_warehouse',
    200,
    const SaleScanOutWarehousePage(),
  );

  //生产扫码领料
  static Routes productionScanPickingMaterial = Routes(
    '/production_scan_picking_material',
    200,
    const ProductionScanPickingMaterialPage(),
  );

  //待领料列表
  static Routes waitPickingMaterial = Routes(
    '/wait_picking_material',
    201,
    const WaitPickingMaterialPage(),
  );

  //已配料列表
  static Routes pickingMaterialOrder = Routes(
    '/picking_material_order',
    200,
    const PickingMaterialOrderPage(),
  );

  //sap扫码盘点
  static Routes sapScanCodeInventory = Routes(
    '/sap_scan_code_inventory',
    200,
    const SapScanCodeInventoryPage(),
  );

  //sap计数盘点
  static Routes sapCountingInventory = Routes(
    '/sap_counting_inventory',
    200,
    const SapCountingInventoryPage(),
  );

  //报工交接确认列表
  static Routes handoverReportList = Routes(
    '/handover_report_list',
    201,
    const HandoverReportListPage(),
  );

  //工序汇报
  static Routes processReport = Routes(
    '/process_report',
    201,
    const ProcessReportPage(),
  );

  //部件报工扫描
  static Routes partReportScan = Routes(
    '/part_report_scan',
    202,
    const PartReportScanPage(),
  );

  //送货单列表
  static Routes deliveryOrder = Routes(
    '/delivery_order',
    205,
    const DeliveryOrderPage(),
  );

  //暂收单
  static Routes temporaryOrder = Routes(
    '/temporary_order',
    204,
    const TemporaryOrderPage(),
  );

  //生产部件交接单
  static Routes componentHandover = Routes(
    '/component_handover_order',
    200,
    const ComponentHandoverPage(),
  );

  //部件报工或取消
  static Routes partReportOrCancel = Routes(
    '/part_report_cancel',
    200,
    const PartReportCancelPage(),
  );

  //采购订单入库
  static Routes purchaseOrderWarehousing = Routes(
    '/purchase_order_warehousing',
    201,
    const PurchaseOrderWarehousingPage(),
  );

  //采购订单凭证列表
  static Routes purchaseOrderReversal = Routes(
    '/purchase_order_reversal',
    201,
    const PurchaseOrderReversalPage(),
  );

  //工序派工单列表
  static Routes processDispatchList = Routes(
    '/process_dispatch_list',
    201,
    const ProcessDispatchPage(),
  );

  //品检单列表
  static Routes qualityInspectionList = Routes(
    '/quality_inspection_list',
    207,
    const QualityInspectionListPage(),
  );

  //生产车间质检
  static Routes qualityInspection = Routes(
    '/quality_inspection',
    200,
    const QualityInspectionPage(),
  );

  //生产车间巡检
  static Routes patrolInspection = Routes(
    '/patrol_inspection',
    200,
    const PatrolInspectionPage(),
  );

  //SAP装柜出库
  static Routes sapPackingScan = Routes(
    '/sap_packing_scan',
    202,
    const SapPackingScanPage(),
  );

  //SAP装柜出库暂存单列表
  static Routes sapPackingScanCacheList = Routes(
    '/sap_packing_scan_cache_list',
    200,
    const SapPackingScanCacheListPage(),
  );

  //SAP装柜出库冲销
  static Routes sapPackingScanReverse = Routes(
    '/sap_packing_scan_reverse',
    200,
    const SapPackingScanReversePage(),
  );

  //SAP外箱标绑定
  static Routes sapCartonLabelBinding = Routes(
    '/sap_carton_label_binding',
    202,
    const SapCartonLabelBindingPage(),
  );

  //SAP内箱标拆分
  static Routes sapInnerBoxLabelSplit = Routes(
    '/sap_inner_box_label_split',
    200,
    const SapInnerBoxLabelSplitPage(),
  );

  //成型条码采集
  static Routes formingBarcodeCollection = Routes(
    '/forming_barcode_collection',
    204,
    const FormingBarcodeCollectionPage(),
  );

  //品质管理
  // static Routes formingBarcodeCollection = Routes(
  //   '/forming_barcode_collection',
  //   200,
  //   const FormingBarcodeCollectionPage(),
  // );

  //车间计工
  static Routes workshopPlanning = Routes(
    '/workshop_planning',
    204,
    const WorkshopPlanningPage(),
  );

  //SAP标签重打
  static Routes sapLabelReprint = Routes(
    '/sap_label_reprint',
    202,
    const SapLabelReprintPage(),
  );

  //打印托盘清单
  static Routes printPallet = Routes(
    '/print_pallet',
    205,
    const PrintPalletPage(),
  );

  //物料标签扫码出库
  static Routes materialLabelScan = Routes(
    '/material_label_scan',
    200,
    const MaterialLabelScanPage(),
  );

  //部件派工标签管理
  static Routes partDispatchLabelManage = Routes(
    '/part_dispatch_label_manage',
    200,
    const PartDispatchLabelManagePage(),
  );

  //包装清单列表
  static Routes packOrderList = Routes(
    '/pack_order_list',
    200,
    const PackOrderListPage(),
  );

  //本地功能入口列表
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
    moldingScanBulletinReportMaximize,
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
    processDispatchRegister,
    smartDelivery,
    cartonLabelScan,
    cartonLabelScanProgress,
    hydroelectricExcess,
    warehouseAllocation,
    sapPurchaseStockIn,
    sapProductionPicking,
    sapPrintPicking,
    sapRelocationPicking,
    sapNoLabelStockIn,
    sapInjectionMoldingStockIn,
    sapSurplusMaterialStockIn,
    sapProduceStockIn,
    sapSalesShipment,
    sapPickingReceiptReversal,
    sapPutOnShelves,
    sapStockTransfer,
    sapWmsReprintLabels,
    sapWmsSplitLabel,
    deviceMaintenance,
    timelyInventory,
    antiCounterfeiting,
    sapInkColorMatching,
    productionTasks,
    suppliersScanStore,
    productionScanWarehouse,
    processReportWarehouse,
    incomingInspection,
    scanPickingMaterial,
    saleScanOutWarehouse,
    productionScanPickingMaterial,
    waitPickingMaterial,
    pickingMaterialOrder,
    sapScanCodeInventory,
    sapCountingInventory,
    injectionScanReport,
    handoverReportList,
    processReport,
    partReportScan,
    deliveryOrder,
    temporaryOrder,
    componentHandover,
    partReportOrCancel,
    purchaseOrderWarehousing,
    purchaseOrderReversal,
    qualityInspection,
    patrolInspection,
    sapPackingScan,
    sapPackingScanCacheList,
    sapPackingScanReverse,
    sapCartonLabelBinding,
    processDispatchList,
    qualityInspectionList,
    sapInnerBoxLabelSplit,
    formingBarcodeCollection,
    workshopPlanning,
    sapLabelReprint,
    printPallet,
    materialLabelScan,
    partDispatchLabelManage,
    packOrderList,
  ];

  static List<GetPage> appRoutes = [
    GetPage(
      name: home,
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
      name: visitRegister.name,
      page: () => visitRegister.page,
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
      name: hydroelectricExcess.name,
      page: () => hydroelectricExcess.page,
    ),
    GetPage(
      name: warehouseAllocation.name,
      page: () => warehouseAllocation.page,
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
    GetPage(
      name: sapProduceStockIn.name,
      page: () => sapProduceStockIn.page,
    ),
    GetPage(
      name: sapSalesShipment.name,
      page: () => sapSalesShipment.page,
    ),
    GetPage(
      name: sapPickingReceiptReversal.name,
      page: () => sapPickingReceiptReversal.page,
    ),
    GetPage(
      name: sapPutOnShelves.name,
      page: () => sapPutOnShelves.page,
    ),
    GetPage(
      name: sapStockTransfer.name,
      page: () => sapStockTransfer.page,
    ),
    GetPage(
      name: sapWmsReprintLabels.name,
      page: () => sapWmsReprintLabels.page,
    ),
    GetPage(
      name: hydroelectricExcess.name,
      page: () => hydroelectricExcess.page,
    ),
    GetPage(
      name: sapWmsSplitLabel.name,
      page: () => sapWmsSplitLabel.page,
    ),
    GetPage(
      name: deviceMaintenance.name,
      page: () => deviceMaintenance.page,
    ),
    GetPage(
      name: timelyInventory.name,
      page: () => timelyInventory.page,
    ),
    GetPage(
      name: antiCounterfeiting.name,
      page: () => antiCounterfeiting.page,
    ),
    GetPage(
      name: sapInkColorMatching.name,
      page: () => sapInkColorMatching.page,
    ),
    GetPage(
      name: productionTasks.name,
      page: () => productionTasks.page,
    ),
    GetPage(
      name: suppliersScanStore.name,
      page: () => suppliersScanStore.page,
    ),
    GetPage(
      name: productionScanWarehouse.name,
      page: () => productionScanWarehouse.page,
    ),
    GetPage(
      name: incomingInspection.name,
      page: () => incomingInspection.page,
    ),
    GetPage(
      name: scanPickingMaterial.name,
      page: () => scanPickingMaterial.page,
    ),
    GetPage(
      name: saleScanOutWarehouse.name,
      page: () => saleScanOutWarehouse.page,
    ),
    GetPage(
      name: productionScanPickingMaterial.name,
      page: () => productionScanPickingMaterial.page,
    ),
    GetPage(
      name: waitPickingMaterial.name,
      page: () => waitPickingMaterial.page,
    ),
    GetPage(
      name: pickingMaterialOrder.name,
      page: () => pickingMaterialOrder.page,
    ),
    GetPage(
      name: sapScanCodeInventory.name,
      page: () => sapScanCodeInventory.page,
    ),
    GetPage(
      name: sapCountingInventory.name,
      page: () => sapCountingInventory.page,
    ),
    GetPage(
      name: processReportWarehouse.name,
      page: () => processReportWarehouse.page,
    ),
    GetPage(
      name: injectionScanReport.name,
      page: () => injectionScanReport.page,
    ),
    GetPage(
      name: handoverReportList.name,
      page: () => handoverReportList.page,
    ),
    GetPage(
      name: processReport.name,
      page: () => processReport.page,
    ),
    GetPage(
      name: partReportScan.name,
      page: () => partReportScan.page,
    ),
    GetPage(
      name: deliveryOrder.name,
      page: () => deliveryOrder.page,
    ),
    GetPage(
      name: temporaryOrder.name,
      page: () => temporaryOrder.page,
    ),
    GetPage(
      name: componentHandover.name,
      page: () => componentHandover.page,
    ),
    GetPage(
      name: partReportOrCancel.name,
      page: () => partReportOrCancel.page,
    ),
    GetPage(
      name: purchaseOrderWarehousing.name,
      page: () => purchaseOrderWarehousing.page,
    ),
    GetPage(
      name: purchaseOrderReversal.name,
      page: () => purchaseOrderReversal.page,
    ),
    GetPage(
      name: processDispatchList.name,
      page: () => processDispatchList.page,
    ),
    GetPage(
      name: qualityInspectionList.name,
      page: () => qualityInspectionList.page,
    ),
    GetPage(
      name: qualityInspection.name,
      page: () => qualityInspection.page,
    ),
    GetPage(
      name: patrolInspection.name,
      page: () => patrolInspection.page,
    ),
    GetPage(
      name: sapPackingScan.name,
      page: () => sapPackingScan.page,
    ),
    GetPage(
      name: sapPackingScanCacheList.name,
      page: () => sapPackingScanCacheList.page,
    ),
    GetPage(
      name: sapPackingScanReverse.name,
      page: () => sapPackingScanReverse.page,
    ),
    GetPage(
      name: sapCartonLabelBinding.name,
      page: () => sapCartonLabelBinding.page,
    ),
    GetPage(
      name: sapInnerBoxLabelSplit.name,
      page: () => sapInnerBoxLabelSplit.page,
    ),
    GetPage(
      name: formingBarcodeCollection.name,
      page: () => formingBarcodeCollection.page,
    ),
    GetPage(
      name: workshopPlanning.name,
      page: () => workshopPlanning.page,
    ),
    GetPage(
      name: sapLabelReprint.name,
      page: () => sapLabelReprint.page,
    ),
    GetPage(
      name: printPallet.name,
      page: () => printPallet.page,
    ),
    GetPage(
      name: materialLabelScan.name,
      page: () => materialLabelScan.page,
    ),
    GetPage(
      name: partDispatchLabelManage.name,
      page: () => partDispatchLabelManage.page,
    ),
    GetPage(
      name: packOrderList.name,
      page: () => packOrderList.page,
    ),
  ];
}

var functions = <ButtonItem>[];

HomeButton? getNowFunction() {
  var route = Get.currentRoute;
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
