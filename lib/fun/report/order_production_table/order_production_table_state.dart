import 'package:flutter/cupertino.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';
import 'package:jd_flutter/bean/http/response/carton_label_scan_clear_tail_info.dart';
import 'package:jd_flutter/bean/http/response/order_production_execution_info.dart';
import 'package:jd_flutter/fun/report/order_production_table/order_production_table_detail_view.dart';
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
  var tecCommand= TextEditingController();

  var factoryBody = ''.obs; //型体
  var groupName = ''.obs; //组别
  var salesOrder = ''.obs; //销售订单
  var customerOrderNumber = ''.obs; //客户订单
  CartonLabelScanClearTailInfo? cartonLabelScanClearTailInfo;
  var reportBoxList = <ClearTailListInfo>[].obs; //
  var tailNumberList = <OrderProductionExecutionInfo>[].obs; //外箱列表
  var type = true.obs;  //默认派工日期
  var list1 = ['全部', '已扫满', '部分扫描','未开始扫描'];

  void getTailNumberReportData({
    required String barCode,
    required String dispatchNumber,
  }) {
    httpGet(
      loading: 'carton_label_scan_order_get_last_detail'.tr,
      method: webApiGetTailNumberReportDataNew,
      params: {
        'CartonBarCode': barCode,
        'DispatchNumber': dispatchNumber,
      },
    ).then((response) {
      if (response.resultCode == resultSuccess) {
        cartonLabelScanClearTailInfo =
            CartonLabelScanClearTailInfo.fromJson(response.data);
        if(cartonLabelScanClearTailInfo!=null){
          reportBoxList.value = cartonLabelScanClearTailInfo!.sizeList!;
          setDataList();
          factoryBody.value = cartonLabelScanClearTailInfo!.factoryBody.toString();
          groupName.value = cartonLabelScanClearTailInfo!.groupName.toString();
          salesOrder.value = cartonLabelScanClearTailInfo!.salesOrder.toString();
          customerOrderNumber.value = cartonLabelScanClearTailInfo!.customerOrderNumber.toString();
          Get.to(() => const OrderProductionTableDetailPage());
        }
      } else {
        factoryBody.value = '';
        groupName.value = '';
        salesOrder.value = '';
        customerOrderNumber.value = '';
        errorDialog(content: response.message ?? 'query_default_error'.tr);
      }
    });
  }

  //为每一个工单添加合计行
  void setDataList() {
    reportBoxList.add(
      ClearTailListInfo(
        size: '合计',
        arrears:
        reportBoxList.map((v) => v.arrears ?? 0).reduce((a, b) => a + b),
        fullBoxQty: reportBoxList
            .map((v) => v.fullBoxQty ?? 0)
            .reduce((a, b) => a + b),
        unFullBoxQty: reportBoxList
            .map((v) => v.unFullBoxQty ?? 0)
            .reduce((a, b) => a + b),
        orderQty:
        reportBoxList.map((v) => v.orderQty ?? 0).reduce((a, b) => a + b),
        barCode: '',
      ),
    );
  }

  //查询不满箱
  void getTailNumberListData(String search) {
    var searchType = '0';
    if(search=='全部'){
      searchType='0';
    }else if(search=='已扫满'){
      searchType='1';
    }else if(search=='部分扫描'){
      searchType='2';
    }else if(search=='未开始扫描'){
      searchType='3';
    }
    httpGet(
      loading: 'carton_label_scan_order_detail'.tr,
      method: webApiGetTailNumberListDataNew,
      params: {
        'StartDate': startDate.getDateFormatYMD(),
        'EndDate': endDate.getDateFormatYMD(),
        'DateType': type.value ==true? 1 : 2,
        'SeOrderNo': tecCommand.text,
        'OrganizeID': getUserInfo()!.organizeID,
        'SearchType': searchType,
      },
    ).then((response) {
      if (response.resultCode == resultSuccess) {
        tailNumberList.value = [
          for (var i = 0; i < response.data.length; ++i)
            OrderProductionExecutionInfo.fromJson(response.data[i])
        ];
      } else {
        tailNumberList.value=[];
        errorDialog(content: response.message ?? 'query_default_error'.tr);
      }
    });
  }

}