import 'dart:convert';

import 'package:get/get.dart';

import '../../../bean/http/response/material_dispatch_info.dart';
import '../../../route.dart';
import '../../../web_api.dart';
import '../../../widget/custom_widget.dart';
import '../../../widget/dialogs.dart';
import '../../../widget/picker/picker_controller.dart';
import 'material_dispatch_state.dart';

class MaterialDispatchLogic extends GetxController {
  final MaterialDispatchState state = MaterialDispatchState();
  var scReportState = SpinnerController(
    saveKey: RouteConfig.materialDispatchPage.name,
    dataList: [
      '全部',
      '未报工',
      '已报工',
      '已生成贴标未报工',
    ],
  );

  ///日期选择器的控制器
  var dpcStartDate = DatePickerController(
    PickerType.date,
    saveKey: '${RouteConfig.materialDispatchPage.name}StartDate',
  )..firstDate = DateTime(
      DateTime.now().year - 5, DateTime.now().month, DateTime.now().day);

  ///日期选择器的控制器
  var dpcEndDate = DatePickerController(
    PickerType.date,
    saveKey: '${RouteConfig.materialDispatchPage.name}EndDate',
  );

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {
    super.onClose();
  }

  query() {
    httpGet(
      method: webApiGetScWorkCardProcess,
      loading: '正在查询工单',
      params: {
        'StartDate': dpcStartDate.getDateFormatYMD(),
        'EndDate': dpcEndDate.getDateFormatYMD(),
        'Status': scReportState.selectIndex - 1,
        'LastProcessNode': state.lastProcess.value ? 1 : 0,
        'ProductName': state.typeBody,
        'PartialWarehousing': state.unStockIn.value ? 1 : 0,
        // 'EmpID':userInfo?.empID,
        'EmpID': '136081',
      },
    ).then((response) {
      if (response.resultCode == resultSuccess) {
        var list = <MaterialDispatchInfo>[];
        var jsonList = jsonDecode(response.data);
        for (var i = 0; i < jsonList.length; ++i) {
          list.add(MaterialDispatchInfo.fromJson(jsonList[i]));
        }
        state.orderList = list;
        state.showOrderList.value =list;
        if (list.isNotEmpty) Get.back();
      } else {
        state.orderList = [];
        errorDialog(content: response.message);
      }
    });
  }

  search(String s) {
    if (s.isEmpty) {
      state.showOrderList.value = state.orderList;
    } else {
      state.showOrderList.value = state.orderList
          .where((v) => v.materialNumber?.contains(s) ?? false)
          .toList();
    }
  }
}
