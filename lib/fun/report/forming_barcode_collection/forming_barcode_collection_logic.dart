import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jd_flutter/bean/http/response/forming_collection_info.dart';
import 'package:jd_flutter/utils/utils.dart';
import 'package:jd_flutter/utils/web_api.dart';
import 'package:jd_flutter/widget/dialogs.dart';

import 'forming_barcode_collection_state.dart';

class FormingBarcodeCollectionLogic extends GetxController
    with GetSingleTickerProviderStateMixin {
  final FormingBarcodeCollectionState state = FormingBarcodeCollectionState();

  //tab控制器
  late TabController tabController = TabController(length: 2, vsync: this);

  getProductionOrderST({
    required String first,
    required String shoeBoxBillNo,
  }) {
    httpGet(
        method: webApiGetProductionOrderST,
        loading: 'forming_code_collection_get_data'.tr,
        params: {'DepartmentID': userInfo?.departmentID}).then((response) {
      if (response.resultCode == resultSuccess) {
        state.dataList.value = [
          for (var json in response.data) FormingCollectionInfo.fromJson(json)
        ];
        setDataList();
        setFirstData(first: first, entryFid: -1, shoeBoxBill: shoeBoxBillNo);
      } else {
        state.dataList.value = [];
        errorDialog(content: response.message ?? 'query_default_error'.tr);
      }
    });
  }

  //为每一个工单添加合计行
  setDataList() {
    for (var data in state.dataList) {
      data.scWorkCardSizeInfos?.add(ScWorkCardSizeInfos(
        size: '合计',
        qty: data.scWorkCardSizeInfos
            ?.map((v) => v.qty ?? 0.0)
            .reduce((a, b) => a.add(b)),
        scannedQty: data.scWorkCardSizeInfos
            ?.map((v) => v.scannedQty ?? 0.0)
            .reduce((a, b) => a.add(b)),
        todayScannedQty: data.scWorkCardSizeInfos
            ?.map((v) => v.scannedQty ?? 0.0)
            .reduce((a, b) => a.add(b)),
      ));
    }
  }

  //设置显示的第一个工单
  setFirstData({
    required String first,
    required int entryFid,
    required String shoeBoxBill,
  }) {
    state.scanCode.value='';

    switch (first) {
      case '0':

        break;
      case '1':

        break;
      case '2':

        break;
    }
  }

  changePriority(){

  }
}
