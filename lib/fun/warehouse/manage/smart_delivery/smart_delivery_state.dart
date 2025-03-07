import 'package:get/get.dart';
import 'package:jd_flutter/bean/http/response/smart_delivery_info.dart';
import 'package:jd_flutter/utils/utils.dart';
import 'package:jd_flutter/utils/web_api.dart';

class SmartDeliveryState {
  var searchText = '';
  var pageIndex = 1.obs;
  var maxPageSize = 20;
  var orderShowList = <SmartDeliveryOrderInfo>[].obs;
  var materialList = <SmartDeliveryMaterialInfo>[];
  var materialShowList = <SmartDeliveryMaterialInfo>[].obs;
  DeliveryDetailInfo? deliveryDetail;
  DeliveryDetailInfo? saveDeliveryDetail;
  var deliveryList = <WorkData>[];
  var deliveryQty = 0;



  querySmartDeliveryOrder({
    required bool showLoading,
    required String instructions,
    required String startTime,
    required String endTime,
    required String deptIDs,
    required Function(int) success,
    required Function(String) error,
  }) {
    httpGet(
      loading: showLoading ? 'smart_delivery_getting_dispatch_data'.tr : '',
      method: webApiSmartDeliveryGetWorkCardList,
      params: {
        'PageIndex': pageIndex.value,
        'PageSize': maxPageSize,
        'StartTime': startTime,
        'EndTime': endTime,
        'DeptIDs': deptIDs,
        'MtoNo': instructions,
      },
    ).then((response) {
      if (response.resultCode == resultSuccess) {
        var list = <SmartDeliveryOrderInfo>[
          for (var json in response.data) SmartDeliveryOrderInfo.fromJson(json)
        ];
        if (pageIndex.value == 1) {
          orderShowList.value = list;
        } else {
          orderShowList.addAll(list);
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
      loading: 'smart_delivery_getting_dispatch_order_material_list'.tr,
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

  getDeliveryDetail({
    required SmartDeliveryMaterialInfo sdmi,
    required int departmentID,
    required Function() success,
    required Function(String) error,
  }) {
    httpGet(
      loading: 'smart_delivery_getting_material_issuance_details'.tr,
      method: webApiSmartDeliveryDetail,
      params: {
        'NewWorkCardInterID': sdmi.scWorkCardInterID,
        'PartsID': sdmi.partsID,
        'MaterialID': sdmi.materialID,
        'StockID': userInfo?.defaultStockID,
        'DepartmentID': departmentID,
      },
    ).then((response) {
      if (response.resultCode == resultSuccess) {
        deliveryDetail = DeliveryDetailInfo.fromJson(response.data);
        success.call();
      } else {
        error.call(response.message ?? 'query_default_error'.tr);
      }
    });
  }

  addPartsStock({
    required String date,
    required Function(String) success,
    required Function(String) error,
  }) {
    httpPost(
      loading: 'smart_delivery_saving_pre_sort_info'.tr,
      method: webApiSmartDeliveryAddPartsStock,
      body: [
        for (var i = 0; i < deliveryList.length; ++i)
          {
            'NewWorkCardInterID': deliveryDetail!.newWorkCardInterID,
            'Date': date,
            'Round': i + 1,
            'PartsID': deliveryDetail!.partsID,
            'MaterialID': deliveryDetail!.materialID,
            'SrcICMOInterID': deliveryDetail!.srcICMOInterID,
            'BillerID': userInfo?.userID,
            'RSizelist': [
              for (var size in deliveryList[i].sendSizeList!)
                {'Size': size.size, 'Qty': size.qty}
            ]
          }
      ],
    ).then((response) {
      if (response.resultCode == resultSuccess) {
        deliveryDetail!.workData = [for (var v in deliveryList) v];
        success.call(response.message ?? '');
      } else {
        error.call(response.message ?? 'query_default_error'.tr);
      }
    });
  }

  deletePartsStock({
    required Function(String) success,
    required Function(String) error,
  }) {
    httpPost(
      loading: 'smart_delivery_clearing_ingredient_info'.tr,
      method: webApiSmartDeliveryDeletePartsStock,
      params: {
        'NewWorkCardInterID': deliveryDetail!.newWorkCardInterID,
        'PartsID': deliveryDetail!.partsID,
      },
    ).then((response) {
      if (response.resultCode == resultSuccess) {
        deliveryDetail!.workData = [];
        for (var v in deliveryList) {
          v.isSelected = false;
        }
        success.call(response.message ?? '');
      } else {
        error.call(response.message ?? 'query_default_error'.tr);
      }
    });
  }

  cacheDelivery({
    required bool isCache,
    required Function(String) success,
    required Function(String) error,
  }) {
    var order = <WorkData>[];
    if (isCache) {
      order.addAll(deliveryList
          .where((v) => v.isSelected)
          .where((v) => v.sendType != 2));
    } else {
      order.addAll(deliveryList
          .where((v) => v.isSelected)
          .where((v) => v.sendType == 2));
    }
    var saveOrder = <WorkData>[];
    if (saveDeliveryDetail != null) {
      if (isCache) {
        saveOrder.addAll(saveDeliveryDetail!.workData!
            .where((v) => v.isSelected)
            .where((v) => v.sendType != 2));
      } else {
        saveOrder.addAll(saveDeliveryDetail!.workData!
            .where((v) => v.isSelected)
            .where((v) => v.sendType == 2));
      }
    }

    httpPost(
      loading: isCache
          ? 'smart_delivery_saving_temporary_iteration'.tr
          : 'smart_delivery_cancelling_temporary_iteration'.tr,
      method: webApiSmartDeliveryEditSendType,
      body: [
        {
          'NewWorkCardInterID': deliveryDetail!.newWorkCardInterID,
          'PartsID': deliveryDetail!.partsID,
          'Rounds': [for (var o in order) o.round],
          'IsEdit': isCache,
        },
        if (saveOrder.isNotEmpty)
          {
            'NewWorkCardInterID': saveDeliveryDetail!.newWorkCardInterID,
            'PartsID': saveDeliveryDetail!.partsID,
            'Rounds': [for (var o in saveOrder) o.round],
            'IsEdit': isCache,
          }
      ],
    ).then((response) {
      if (response.resultCode == resultSuccess) {
        deliveryList.where((v) => v.isSelected).forEach((v) {
          v.isSelected = false;
          v.sendType = isCache ? 2 : 0;
        });
        saveDeliveryDetail?.workData!.where((v) => v.isSelected).forEach((v) {
          v.isSelected = false;
          v.sendType = isCache ? 2 : 0;
        });
        success.call(response.message ?? '');
      } else {
        error.call(response.message ?? 'query_default_error'.tr);
      }
    });
  }

  DeliveryDetailInfo copyOrder() => DeliveryDetailInfo(
        newWorkCardInterID: deliveryDetail!.newWorkCardInterID,
        partsID: deliveryDetail!.partsID,
        typeBody: deliveryDetail!.typeBody,
        seOrders: deliveryDetail!.seOrders,
        mapNumber: deliveryDetail!.mapNumber,
        srcICMOInterID: deliveryDetail!.srcICMOInterID,
        clientOrderNumber: deliveryDetail!.clientOrderNumber,
        partName: deliveryDetail!.partName,
        materialID: deliveryDetail!.materialID,
        materialName: deliveryDetail!.materialName,
        materialNumber: deliveryDetail!.materialNumber,
        partsSizeList: deliveryDetail!.partsSizeList,
        workData: deliveryList.where((v) => v.isSelected).toList(),
      );
}
