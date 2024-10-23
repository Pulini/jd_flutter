import 'package:get/get.dart';
import 'package:jd_flutter/utils/utils.dart';

import '../../../bean/http/response/smart_delivery_info.dart';
import '../../../utils/web_api.dart';

class SmartDeliveryState {
  var pageIndex = 1.obs;
  var maxPageSize = 10;
  var orderList = <SmartDeliveryOrderInfo>[].obs;
  var materialList = <SmartDeliveryMaterialInfo>[];
  var materialShowList = <SmartDeliveryMaterialInfo>[].obs;
  DeliveryDetailInfo? deliveryDetail ;
  var deliveryDetailList = <WorkData>[].obs;

  SmartDeliveryState() {
    ///Initialize variables
  }

  querySmartDeliveryOrder({
    required bool showLoading,
    required String startTime,
    required String endTime,
    required String deptIDs,
    required Function(int) success,
    required Function(String) error,
  }) {
    httpGet(
      loading: showLoading ? '正在获取派工单数据...' : '',
      method: webApiSmartDeliveryGetWorkCardList,
      params: {
        'PageIndex': pageIndex.value,
        'PageSize': maxPageSize,
        'StartTime': startTime,
        'EndTime': endTime,
        // 'DeptIDs': deptIDs,
        'DeptIDs': '554697',
      },
    ).then((response) {
      if (response.resultCode == resultSuccess) {
        var list = <SmartDeliveryOrderInfo>[
          for (var json in response.data) SmartDeliveryOrderInfo.fromJson(json)
        ];
        if (pageIndex.value == 1) {
          orderList.value = list;
        } else {
          orderList.addAll(list);
        }
        success.call(list.length);
      } else {
        error.call(response.message ?? 'query_default_error'.tr);
      }
    });
  }

  getOrderMaterialList({
    required int workCardInterID,
    required Function() success,
    required Function(String) error,
  }) {
    httpGet(
      loading: '正在获取派工单物料列表...',
      method: webApiSmartDeliveryGetWorkCardMaterial,
      params: {'ScWorkCardInterID': workCardInterID},
    ).then((response) {
      if (response.resultCode == resultSuccess) {
        materialList = <SmartDeliveryMaterialInfo>[
          for (var json in response.data)
            SmartDeliveryMaterialInfo.fromJson(json)
        ];
        searchMaterial('');
        success.call();
      } else {
        error.call(response.message ?? 'query_default_error'.tr);
      }
    });
  }

  searchMaterial(String searchText) {
    if (searchText.isEmpty) {
      materialShowList.value = materialList;
    } else {
      materialShowList.value = materialList
          .where((v) => v.materialNumber!.contains(searchText))
          .toList();
    }
  }

  getShoeTreeList({
    required String typeBody,
    required Function(SmartDeliveryShorTreeInfo) success,
    required Function(String) error,
  }) {
    httpGet(
      loading: '正在检查楦头库存...',
      method: webApiSmartDeliveryGetShorTreeList,
      params: {
        'TypeBody': typeBody,
        'StockID': userInfo?.defaultStockID,
      },
    ).then((response) {
      if (response.resultCode == resultSuccess) {
        success.call(SmartDeliveryShorTreeInfo.fromJson(response.data));
      } else {
        error.call(response.message ?? 'query_default_error'.tr);
      }
    });
  }

  saveShoeTree({
    required SmartDeliveryShorTreeInfo sti,
    required String typeBody,
    required Function(String) success,
    required Function(String) error,
  }) {
    httpPost(
      loading: '正在保存楦头库存信息...',
      method: webApiSmartDeliverySaveShorTree,
      body: {
        'ShoeTreeNo': typeBody,
        'StockID': userInfo?.defaultStockID,
        'SizeList': [
          for (var size in sti.sizeList!)
            {
              'Size': size.size,
              'Qty': size.qty,
            }
        ]
      },
    ).then((response) {
      if (response.resultCode == resultSuccess) {
        success.call(response.message ?? '');
      } else {
        error.call(response.message ?? 'query_default_error'.tr);
      }
    });
  }

  getDeliveryDetail({
    required SmartDeliveryMaterialInfo sdmi,
    required Function() success,
    required Function(String) error,
  }) {
    httpGet(
      loading: '正在获取发料明细信息...',
      method: webApiSmartDeliveryDetail,
      params: {
        'NewWorkCardInterID': sdmi.scWorkCardInterID,
        'PartsID': sdmi.partsID,
        'MaterialID': sdmi.materialID,
        'StockID': userInfo?.defaultStockID,
      },
    ).then((response) {
      if (response.resultCode == resultSuccess) {
        deliveryDetail=DeliveryDetailInfo.fromJson(response.data);
        success.call();
      } else {
        error.call(response.message ?? 'query_default_error'.tr);
      }
    });
  }
}
