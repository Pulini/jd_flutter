import 'dart:convert';

import 'package:get/get.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';
import 'package:jd_flutter/bean/http/response/timely_inventory_info.dart';
import 'package:jd_flutter/bean/http/response/timely_inventory_show_info.dart';
import 'package:jd_flutter/fun/warehouse/manage/timely_inventory/timely_inventory_state.dart';
import 'package:jd_flutter/utils/utils.dart';
import 'package:jd_flutter/utils/web_api.dart';
import 'package:jd_flutter/widget/dialogs.dart';


class TimelyInventoryLogic extends GetxController {
  final TimelyInventoryState state = TimelyInventoryState();


  //获取及时库存
  getImmediateStockList({
    required String factoryNumber,
    required String stockId,
  }) {
    httpGet(
        method: webApiGetImmediateStockList,
        loading: 'timely_inventory_get_inventory_data'.tr,
        params: {
          'MtoNo': state.instructionNumber,
          'MaterialNumber': state.materialCode,
          'StockID': stockId,
          'FactoryNumber': factoryNumber,
          'Batch': state.batch,
        }
    ).then((response) {
      if (response.resultCode == resultSuccess) {
        var list = <TimelyInventoryInfo>[
          for (var i = 0; i < response.data.length; ++i)
            TimelyInventoryInfo.fromJson(response.data[i])
        ];

        state.dataList.value = list;

      } else {
        errorDialog(content: response.message);
      }
    });
  }


  //修改库位
  modifyStorageLocation({
    required TimelyInventoryInfo data,
    required TimeItems item,
    required String newLocation,
    required Function(String s) success,
  }) {
    httpPost(
      method: webApiModifyStorageLocation,
      loading: 'timely_inventory_submitting_modifications'.tr,
      body: {
        'BatchNumber':item.batch,
        'StockID':data.stockID,
        'MaterialCode':data.materialNumber,
        'Factory':data.factoryNumber,
        'Location':newLocation,
        'Operator':userInfo?.userID,
      },
    ).then((response) {
      if (response.resultCode == resultSuccess) {
        success.call(response.message ?? '');
      } else {
        errorDialog(content: response.message);
      }
    });
  }
}