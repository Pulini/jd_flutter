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
        loading: '正在获取及时库存数据...',
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

        var lists = <TimelyInventoryShowInfo>[];
        for (var i = 0; i < list.length; ++i) {
          for (var x = 0; x < list[x].items!.length; ++x) {
            lists.add(TimelyInventoryShowInfo(
              materialNumber: list[i].materialNumber,
              materialName: list[i].materialName,
              stockID: list[i].stockID,
              factoryNumber: list[i].factoryNumber,
              batch: list[i].items?[x].batch,
              factoryDescribe: list[i].items?[x].factoryDescribe,
              lgobe: list[i].items?[x].lgobe,
              materialCode: list[i].items?[x].materialCode,
              mtono: list[i].items?[x].mtono,
              productName: list[i].items?[x].productName,
              stockQty: list[i].items?[x].stockQty,
              stockQty1: list[i].items?[x].stockQty1,
              unit: list[i].items?[x].unit,
              unit1: list[i].items?[x].unit1,
              zcoefficient: list[i].items?[x].zcoefficient,
              zlocal: list[i].items?[x].zlocal,
            ));
          }
        }

        state.dataList.value = lists;
      } else {
        errorDialog(content: response.message);
      }
    });
  }


  //修改库位
  modifyStorageLocation({
    required TimelyInventoryShowInfo data,
    required String newLocation,
    required Function(String s) success,
  }) {
    httpPost(
      method: webApiModifyStorageLocation,
      loading: '正在提交修改...',
      body: {
        'BatchNumber':data.batch,
        'StockID':data.stockID,
        'MaterialCode':data.materialNumber,
        'Factory':data.factoryNumber,
        'Location':newLocation,
        'Operator':getUserInfo()!.userID,
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