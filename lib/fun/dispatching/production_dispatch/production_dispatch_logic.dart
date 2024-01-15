import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:jd_flutter/http/web_api.dart';
import 'package:jd_flutter/utils.dart';

import '../../../http/response/production_dispatch_order_detail_info.dart';
import '../../../http/response/production_dispatch_order_info.dart';
import '../../../route.dart';
import '../../../widget/dialogs.dart';
import '../../../widget/picker/picker_controller.dart';
import 'production_dispatch_state.dart';

class ProductionDispatchLogic extends GetxController {
  final ProductionDispatchState state = ProductionDispatchState();
  var textControllerInstruction = TextEditingController();

  var switchControllerOutsourcing = SwitchButtonController(
      buttonName: 'production_dispatch_query_show_outsourcing'.tr,
      saveKey: '${RouteConfig.workerProductionReport.name}Outsourcing');

  var switchControllerClosed = SwitchButtonController(
      buttonName: 'production_dispatch_query_show_close'.tr,
      saveKey: '${RouteConfig.workerProductionReport.name}Closed');

  late SwitchButtonController switchControllerMany;

  var switchControllerMergeOrder = SwitchButtonController(
      buttonName: 'production_dispatch_query_merge_orders'.tr,
      saveKey: '${RouteConfig.workerProductionReport.name}MergeOrder');

  ///日期选择器的控制器
  var pickerControllerStartDate = DatePickerController(
    PickerType.date,
    saveKey: '${RouteConfig.workerProductionReport.name}StartDate',
  );

  ///日期选择器的控制器
  var pickerControllerEndDate = DatePickerController(
    PickerType.date,
    saveKey: '${RouteConfig.workerProductionReport.name}EndDate',
  );

  @override
  void onInit() {
    super.onInit();
    switchControllerMany = SwitchButtonController(
      buttonName: 'production_dispatch_query_many_select'.tr,
      saveKey: '${RouteConfig.workerProductionReport.name}Many',
      onSelected: (isChecked) {
        if (!isChecked && state.orderList.isNotEmpty) {
          for (var value in state.orderList) {
            value.select = false;
          }
          state.orderList.refresh();
        }
      },
    );
  }

  query() {
    httpGet(
      method: webApiGetWorkCardCombinedSizeList,
      loading: 'molding_scan_bulletin_report_submitting'.tr,
      query: {
        'startTime': pickerControllerStartDate.getDateFormatYMD(),
        'endTime': pickerControllerEndDate.getDateFormatYMD(),
        'moNo': textControllerInstruction.text,
        'isClose': switchControllerClosed.isChecked.value,
        'isOutsourcing': switchControllerOutsourcing.isChecked.value,
        'deptID': userInfo?.departmentID,
      },
    ).then((response) {
      if (response.resultCode == resultSuccess) {
        var jsonList = jsonDecode(response.data);
        var list = <ProductionDispatchOrderInfo>[];
        for (var i = 0; i < jsonList.length; ++i) {
          list.add(ProductionDispatchOrderInfo.fromJson(jsonList[i]));
        }
        state.orderList.value = list;
        state.orderGroupList.value =
            groupBy(list, (ProductionDispatchOrderInfo e) {
          return e.sapOrderBill ?? e.orderBill ?? '';
        });
        if (list.isNotEmpty) Get.back();
      } else {
        state.orderList.value = [];
        errorDialog(content: response.message);
      }
    });
  }

  void pushCheck(Function(ProductionDispatchOrderInfo) orderPush,
      Function(List<ProductionDispatchOrderInfo>) ordersPush) {
    if (checkUserPermission('1051102')) {
      var selectList = state.orderList.where((v) => v.select).toList();
      if (selectList.any((v) => v.isClosed!)) {
        errorDialog(content: selectList.length > 1 ? '所选工单包含已关闭工单' : '所选工单已关闭');
        return;
      }
      // if (selectList.any((v) => v.pastDay!)) {
      //   errorDialog(content: selectList.length > 1 ? '所选工单包含已超时工单' : '所选工单已超时');
      //   return;
      // }
      if (selectList.length > 1) {
        informationDialog(
            content: '确定要选择${selectList.length}张派工单进行下推吗？',
            back: () {
              ordersPush.call(selectList);
            });
      } else {
        orderPush.call(selectList[0]);
      }
    } else {
      errorDialog(content: '没有下推权限');
    }
  }

  void push() {
    pushCheck((order) {
      httpPost(
        method: webApiPushProductionOrder,
        loading: '正在下推...',
        query: {
          'interID': order.interID,
          'entryID': order.entryID,
          'organizeID': userInfo?.organizeID,
          'userID': userInfo?.userID,
          'departmentID': userInfo?.departmentID,
        },
      ).then((response) {
        if (response.resultCode == resultSuccess) {
          state.detailInfo = ProductionDispatchOrderDetailInfo.fromJson(
              jsonDecode(response.data));
          // Get.to(() => const MoldingPackAreaDetailReportPage());
        } else {
          errorDialog(content: response.message);
        }
      });
    }, (orders) {});
  }
}
