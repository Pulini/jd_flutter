import 'package:flutter/cupertino.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';
import 'package:jd_flutter/bean/http/response/carton_label_scan_clear_tail_info.dart';
import 'package:jd_flutter/bean/http/response/order_production_execution_info.dart';
import 'package:jd_flutter/bean/http/response/out_box_labels_info.dart';
import 'package:jd_flutter/route.dart';
import 'package:jd_flutter/utils/utils.dart';
import 'package:jd_flutter/utils/web_api.dart';
import 'package:jd_flutter/widget/dialogs.dart';
import 'package:jd_flutter/widget/picker/picker_controller.dart';

class OrderProductionTableState {
  //日期选择器的控制器
  var startDate = DatePickerController(
    PickerType.startDate,
    saveKey: '${RouteConfig.orderProductionTable.name}${PickerType.startDate}',
  );

  //日期选择器的控制器
  var endDate = DatePickerController(
    PickerType.endDate,
    saveKey: '${RouteConfig.orderProductionTable.name}${PickerType.endDate}',
  );
  var tecCommand = TextEditingController(); // 指令
  var tecWorkOrder = TextEditingController(); //派工单
  var tailBarCode = TextEditingController(); //外箱条码

  var searchTec = TextEditingController(); //模糊搜索控制器
  var searchKey = ''.obs; //搜索关键词（指令号）

  var factoryBody = ''.obs; //型体
  var groupName = ''.obs; //组别
  var salesOrder = ''.obs; //销售订单
  var customerOrderNumber = ''.obs; //客户订单
  var showDispatchNumber = ''.obs; //派工单号
  CartonLabelScanClearTailInfo? cartonLabelScanClearTailInfo;
  OrderProductionExecutionInfo? searcherData;
  var reportBoxList = <ClearTailListInfo>[].obs; //
  var tailNumberList = <OrderProductionExecutionInfo>[].obs; //外箱列表
  var copyTailNumberList = <OrderProductionExecutionInfo>[].obs; //外箱列表
  var type = true.obs; //默认派工日期
  var lineList = <String>['carton_label_scan_order_all_lines'.tr]; //所有工厂
  var list1 = [
    'carton_label_scan_order_detail_all'.tr,
    'carton_label_scan_order_detail_all_scan'.tr,
    'carton_label_scan_order_detail_all_some_scan'.tr,
    'carton_label_scan_order_detail_all_no_scan'.tr
  ];
  var notProduced = ''.obs; //正单未生产
  var inProduction = ''.obs; // 正在生产
  var waitingClearTail = ''.obs; // 待清尾
  var completed = ''.obs; // 已完成

  // 当前选中的 Tab（1:正单未生产 2:正在生产 3:待清尾 4:已完成）
  var selectedTabIndex = 1.obs;
  var selectIndex = 0; //线别
  var message = ''.obs; //显示内容

  //外箱清尾
  var showIndex = 0;
  var tailDispatchNumber = ''.obs;
  var add = true.obs; // 新增
  var outBoxList = <OutBoxLabelsInfo>[].obs; //外箱数据
  var tailController = TextEditingController();
  var tailLabelTotal = 0.obs; //清尾用的到统计
  var tailScannedLabelTotal = 0.obs; //清尾用的到扫了的统计

  void getTailNumberReportData({
    required OrderProductionExecutionInfo needData,
    required String barCode,
    required bool isGetTo,
    required Function() getTo,
  }) {
    httpGet(
      loading: 'carton_label_scan_order_get_last_detail'.tr,
      method: webApiGetTailNumberReportDataNew,
      params: {
        'CartonBarCode': barCode.trim(),
        'DispatchNumber': needData.workCardNo,
      },
    ).then((response) {
      if (response.resultCode == resultSuccess) {
        cartonLabelScanClearTailInfo =
            CartonLabelScanClearTailInfo.fromJson(response.data);
        if (cartonLabelScanClearTailInfo != null) {
          // 防止接口未返回 SizeList 时 sizeList 为 null，避免 ! 抛异常导致无法跳转
          reportBoxList.value = cartonLabelScanClearTailInfo!.sizeList ?? [];
          // 调试：确认数据是否解析出来（控制台搜索 [Detail] 查看）
          setDataList();
          factoryBody.value =
              cartonLabelScanClearTailInfo!.factoryBody.toString();
          groupName.value = cartonLabelScanClearTailInfo!.groupName.toString();
          salesOrder.value =
              cartonLabelScanClearTailInfo!.salesOrder.toString();
          customerOrderNumber.value =
              cartonLabelScanClearTailInfo!.customerOrderNumber.toString();
          showDispatchNumber.value = needData.workCardNo ?? '';
          if (isGetTo) {
            searcherData = needData;
            getTo.call();
          }
        }
      } else {
        factoryBody.value = '';
        groupName.value = '';
        salesOrder.value = '';
        customerOrderNumber.value = '';
        showDispatchNumber.value = '';
        errorDialog(content: response.message ?? 'query_default_error'.tr);
      }
    });
  }

  //为每一个工单添加合计行
  void setDataList() {
    // 列表为空时直接返回，避免 reduce 在空列表上抛 "Bad state: No element"
    if (reportBoxList.isEmpty) return;
    reportBoxList.add(
      ClearTailListInfo(
        size: 'carton_label_scan_order_total'.tr,
        arrears:
            reportBoxList.map((v) => v.arrears ?? 0).reduce((a, b) => a + b),
        fullBoxQty:
            reportBoxList.map((v) => v.fullBoxQty ?? 0).reduce((a, b) => a + b),
        unFullBoxQty: reportBoxList
            .map((v) => v.unFullBoxQty ?? 0)
            .reduce((a, b) => a + b),
        orderQty:
            reportBoxList.map((v) => v.orderQty ?? 0).reduce((a, b) => a + b),
        barCode: '',
      ),
    );
  }

  // 重置所有不满箱数量为 0（保留并重新计算合计行）
  void resetUnFullBoxQty() {
    reportBoxList
        .removeWhere((v) => v.size == 'carton_label_scan_order_total'.tr);
    for (var v in reportBoxList) {
      v.thisScanQty = v.unFullBoxQty; // 重置扫描数量
    }
    reportBoxList.refresh();
    setDataList();
  }

  //查询不满箱
  void getTailNumberListData({
    required Function() success,
  }) {
    httpGet(
      loading: 'carton_label_scan_order_detail'.tr,
      method: webApiGetTailNumberListDataNew,
      params: {
        'StartDate': startDate.getDateFormatYMD(),
        'EndDate': endDate.getDateFormatYMD(),
        'DateType': type.value == true ? 1 : 2,
        'SeOrderNo': tecCommand.text,
        'OrganizeID': getUserInfo()!.organizeID,
        'CartonBarCode': tailBarCode.text.replaceAll(RegExp(r'[\r\n]'), '').trim(),
        'DispatchNumber': tecWorkOrder.text.replaceAll(RegExp(r'[\r\n]'), '').trim(),
      },
    ).then((response) {
      if (response.resultCode == resultSuccess) {
        tailNumberList.value = [
          for (var i = 0; i < response.data.length; ++i)
            OrderProductionExecutionInfo.fromJson(response.data[i])
        ];
        copyTailNumberList.clear();
        copyTailNumberList.addAll(tailNumberList);
        arrangeFactory(success: () {
          countByStatus();
          success.call();
        });
      } else {
        tailNumberList.value = [];
        copyTailNumberList.value = [];
        lineList = ['carton_label_scan_order_all_lines'.tr];
        notProduced.value = '';
        inProduction.value = '';
        waitingClearTail.value = '';
        completed.value = '';
        errorDialog(content: response.message ?? 'query_default_error'.tr);
      }
    });
  }

  // 按工单 searchType 统计 4 个数量（与 selectShow 过滤字段保持一致）
  // [list] 不传时默认统计 tailNumberList；selectShow 会传入"已按线别+搜索过滤、但不含状态过滤"的 base 列表，
  // 这样 4 个 Tab 的数量角标各自恒等于真实值，无需切换 Tab 才更新。
  void countByStatus([List<OrderProductionExecutionInfo>? list]) {
    final items = list ?? tailNumberList;
    int n0 = 0, n1 = 0, n2 = 0, n3 = 0;
    for (var item in items) {
      switch (item.status) {
        case 1:
          n0++;
          break;
        case 2:
          n1++;
          break;
        case 3:
          n2++;
          break;
        case 4:
          n3++;
          break;
      }
    }
    notProduced.value = n0 == 0 ? '' : '$n0';
    inProduction.value = n1 == 0 ? '' : '$n1';
    waitingClearTail.value = n2 == 0 ? '' : '$n2';
    completed.value = n3 == 0 ? '' : '$n3';

    updateMessage();
  }

  // 根据当前 Tab 拼接统计文案，赋值给 message
  void updateMessage() {
    final tab = selectedTabIndex.value;
    // 基于全量 copyTailNumberList 按 status 分组
    final list0 = tailNumberList.where((e) => e.status == 1).toList();
    final list1 = tailNumberList.where((e) => e.status == 2).toList();
    final list2 = tailNumberList.where((e) => e.status == 3).toList();
    final list3 = tailNumberList.where((e) => e.status == 4).toList();

    String msg;
    switch (tab) {
      case 0:
        // 逾期：DaysDifference < 0 算一条（只统计当前 tab 数据）
        int ov = list0.where((e) => (e.daysDifference ?? 0) < 0).length;
        msg = '共 ${list0.length} 个工单，其中 $ov 个已逾期';
        break;
      case 1:
        int done = list1.fold<int>(0, (s, e) => s + (e.scanQty ?? 0));
        int total =
            list1.fold<int>(0, (s, e) => s + (e.seOrderQty ?? 0).toInt());
        // 临期：剩余天数在 0~3 天（只统计当前 tab 数据，没数据自然为 0）
        int nd = list1
            .where((e) =>
                (e.daysDifference ?? 0) >= 0 && (e.daysDifference ?? 0) < 3)
            .length;
        msg = '共 ${list1.length} 个工单，其中 $nd 个临期，$total / $done 双';
        break;
      case 2:
        // 逾期：DaysDifference < 0 算一条（只统计当前 tab 数据）
        int ov = list2.where((e) => (e.daysDifference ?? 0) < 0).length;
        // 待清尾数量 = 未完工数量之和（只统计当前 tab 数据，没数据自然为 0）
        int remain =
            list2.fold<int>(0, (s, e) => s + (e.unFinishQty ?? 0).toInt());
        msg = '共 ${list2.length} 个工单，其中 $ov 个已逾期，待清尾共 $remain 双';
        break;
      case 3:
      default:
        int finished = list3.fold<int>(0, (s, e) => s + (e.scanQty ?? 0));
        msg = '共 ${list3.length} 个工单，已结案 $finished 双';
        break;
    }
    message.value = msg;
  }

  void arrangeFactory({
    required Function() success,
  }) {
    var list = <String>[];
    list.add('carton_label_scan_order_all_lines'.tr);
    for (var data in tailNumberList) {
      if (data.departmentName != '' && !list.contains(data.departmentName)) {
        list.add(data.departmentName!);
      }
    }
    lineList = list;
    success.call();
  }

  // 清尾确认
  void confirmTailCartonRecords({
    required OrderProductionExecutionInfo item,
    required bool isSubmit,
    required Function(String) success,
  }) {
    httpPost(
      loading: 'carton_label_scan_confirm_clean_tail'.tr,
      method: webApiConfirmTailCartonRecords,
      body: {
        'UserID': userInfo?.userID,
        'items': [
          {
            "WorkCardInterID": item.workCardInterID,
            "IsConfirm": isSubmit ? 1 : 0
          },
        ],
      },
    ).then((response) {
      if (response.resultCode == resultSuccess) {
        success.call(response.message ?? 'process_report_success_submit'.tr);
      } else {
        errorDialog(
            content: response.message ?? 'process_report_error_submit'.tr);
      }
    });
  }

  // 尾数提交
  void tailCartonRecordsTotal({
    required Function(String) success,
  }) {
    final hasScanQty = reportBoxList.any((data) => (data.thisScanQty ?? 0) > 0);
    if (!hasScanQty) {
      errorDialog(content: '请先扫描尾数箱后再提交');
      return;
    }
    httpPost(
      loading: 'carton_label_scan_order_submit_last_detail'.tr,
      method: webApiUPSERTTailCartonRecordsTotal,
      body: {
        'UserID': userInfo?.userID,
        'WorkCardInterID': searcherData!.workCardInterID,
        'CustOrderNumber':
            cartonLabelScanClearTailInfo!.customerOrderNumber ?? '',
        'MoID': searcherData!.moID,
        'SizeItems': [
          for (var data in reportBoxList)
            if (data.size != '合计' && data.thisScanQty! > 0)
              {
                "Size": data.size,
                "ShortQty": ((data.thisScanQty ?? 0) + (data.unFullBoxQty ?? 0))
                    .toString(),
              }
        ],
      },
    ).then((response) {
      if (response.resultCode == resultSuccess) {
        success.call(response.message ?? 'process_report_success_submit'.tr);
      } else {
        errorDialog(
            content: response.message ?? 'process_report_error_submit'.tr);
      }
    });
  }

  //查询不满箱
  void queryNotFullBox({
    required String barCode,
  }) {
    httpGet(
      loading: 'carton_label_scan_order_get_last_detail'.tr,
      method: webApiGetMantissaDataNew,
      params: {
        'CartonBarCode': barCode.trim(),
        'DispatchNumber': tailDispatchNumber.value,
        'IsAddData': add.value,
      },
    ).then((response) {
      if (response.resultCode == resultSuccess) {
        outBoxList.value = [
          for (var i = 0; i < response.data.length; ++i)
            OutBoxLabelsInfo.fromJson(response.data[i])
        ];
      } else {
        outBoxList.value = [];
        errorDialog(content: response.message ?? 'query_default_error'.tr);
      }
    });
  }

  //不满箱提交
  void subMantissaData({
    required Function(String) success,
    required Function(String) error,
  }) {
    httpPost(
      loading: 'carton_label_scan_order_submit_last_detail'.tr,
      method: webApiSubMantissaDataNew,
      body: {
        'GUID': outBoxList[showIndex].guid,
        'InterID': outBoxList[showIndex].interID,
        'CustOrderNumber': outBoxList[showIndex].custOrderNumber,
        'CartonBarCode': outBoxList[showIndex].outBoxBarCode,
        'Mix': outBoxList[showIndex].mix,
        'UserID': getUserInfo()!.userID,
        'DispatchNumber': outBoxList[showIndex].dispatchNumber,
        'TailCartonCode': outBoxList[showIndex].tailCartonCode,
        'InnerBoxSizeList': [
          for (var list in outBoxList[showIndex].mantissaDataSizeList!)
            {
              'PriceBarCode': list.priceBarCode,
              'Size': list.size,
              'LabelCount': list.labelCount,
              'ShortQty': outBoxList[showIndex].guid!.isNotEmpty
                  ? list.thisShortQty! - list.shortQty!
                  : list.thisShortQty,
            }
        ]
      },
    ).then((response) {
      if (response.resultCode == resultSuccess) {
        success.call(response.message ?? 'process_report_success_submit'.tr);
      } else {
        error.call(response.message ?? 'process_report_error_submit'.tr);
      }
    });
  }
}
