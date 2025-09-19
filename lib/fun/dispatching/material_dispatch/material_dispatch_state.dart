import 'package:collection/collection.dart';
import 'package:get/get.dart';
import 'package:jd_flutter/bean/http/response/material_dispatch_info.dart';
import 'package:jd_flutter/bean/http/response/material_dispatch_label_detail.dart';
import 'package:jd_flutter/bean/http/response/material_dispatch_report_success_info.dart';
import 'package:jd_flutter/utils/extension_util.dart';
import 'package:jd_flutter/utils/utils.dart';
import 'package:jd_flutter/utils/web_api.dart';

const String spPalletDate = 'MaterialDispatchPickPalletDate';
const String spMachine = 'MaterialDispatchPickMachine';
const String spWarehouseLocation = 'MaterialDispatchPickWarehouseLocation';
const String spPallet = 'MaterialDispatchPickPallet';
const String spDepart = 'MaterialDispatchDepart';
const String spBigLabel = 'MaterialDispatchDepartIsBigLabel';

int getMaterialDispatchDate() =>
    spGet(spPalletDate) ?? DateTime.now().millisecondsSinceEpoch;

saveMaterialDispatchDate(int date) => spSave(spPalletDate, date);

 getMaterialDispatchMachineId() => spGet(spMachine) ?? '';

saveMaterialDispatchMachineId(String id) => spSave(spMachine, id);

String getMaterialDispatchLocationId() => spGet(spWarehouseLocation) ?? '';

saveMaterialDispatchLocationId(String id) => spSave(spWarehouseLocation, id);

String getMaterialDispatchPalletNumber() => spGet(spPallet) ?? '';

saveMaterialDispatchPalletNumber(String number) => spSave(spPallet, number);

String getMaterialDispatchDepart() => spGet(spDepart) ?? '';

saveMaterialDispatchDepart(String departId) => spSave(spDepart, departId);

saveMaterialIsBigLabel(bool label) => spSave(spBigLabel, label);

bool getMaterialIsBigLabel() => spGet(spBigLabel) ?? false;

class MaterialDispatchState {
  var lastProcess = false.obs;
  var unStockIn = false.obs;
  var allInstruction = false.obs;
  var isBigLabel = getMaterialIsBigLabel().obs;
  var orderList = <MaterialDispatchInfo>[];
  var showOrderList = <MaterialDispatchInfo>[].obs;

  getScWorkCardProcess({
    required String startDate,
    required String endDate,
    required int status,
    required String typeBody,
    required Function(String msg) error,
  }) {
    httpGet(
      method: webApiGetScWorkCardProcess,
      loading: 'material_dispatch_querying_order'.tr,
      params: {
        'StartDate': startDate,
        'EndDate': endDate,
        'Status': status,
        'LastProcessNode': lastProcess.value ? 1 : 0,
        'ProductName': typeBody,
        'PartialWarehousing': unStockIn.value ? 1 : 0,
        'EmpID': userInfo?.empID,
      },
    ).then((response) {
      if (response.resultCode == resultSuccess) {
        orderList = [
          for (var json in response.data) MaterialDispatchInfo.fromJson(json)
        ];
        showOrderList.value = orderList;
      } else {
        orderList = [];
        showOrderList.value=[];
        error.call(response.message ?? '');
      }
    });
  }

  reportToSAP({
    required Function(String msg) success,
    required Function(String msg) error,
  }) {
    httpPost(
      method: webApiCreateLastProcessReport,
      loading: 'material_dispatch_reporting'.tr,
      params: {
        'Date': getDateYMD(
            time:
                DateTime.fromMillisecondsSinceEpoch(getMaterialDispatchDate())),
        'DrillingCrewID': getMaterialDispatchMachineId(),
        'MovementType': '101',
        'DeptID': getMaterialDispatchDepart(),
        'UserID': userInfo?.userID.toString(),
      },
    ).then((response) {
      if (response.resultCode == resultSuccess) {
        success.call(response.message ?? '');
      } else {
        error.call(response.message ?? '');
      }
    });
  }

  List<Map<String, String>> createSubmitData() {
    var submitList = <Map<String, String>>[];
    for (var i = 0; i < orderList.length; ++i) {
      var sub = orderList[i]
          .children!
          .where((v) => v.partialWarehousing == '1')
          .toList();
      for (var j = 0; j < sub.length; ++j) {
        submitList.add({
          'processWorkCardInterID': sub[j].interID ?? '',
          'routeEntryFID': sub[j].routeEntryFID ?? '',
          'sapDecideArea': sub[j].sapColorBatch ?? '',
          'MovementType': '101',
          'Date': getDateYMD(),
          'RouteEntryFIDs': sub[j].routeEntryFIDs ?? '',
          'Location': getMaterialDispatchLocationId(),
          'UserID': (userInfo?.userID ?? 0).toString(),
        });
      }
    }
    return submitList;
  }

  batchWarehousing({
    required List<Map<String, String>> submitList,
    required Function(String msg) success,
    required Function(String msg) error,
  }) {
    httpPost(
      method: webApiPickCodeBatchProductionWarehousing,
      loading: '正在批量入库...',
      body: submitList,
    ).then((response) {
      if (response.resultCode == resultSuccess) {
        success.call(response.message ?? '');
      } else {
        error.call(response.message ?? '');
      }
    });
  }

  itemReport({
    required MaterialDispatchInfo data,
    required Function(String msg) success,
    required Function(String msg) error,
  }) {
    httpPost(
      loading: 'material_dispatch_reporting'.tr,
      method: webApiCreateProcessOutPutStripDrawing,
      body: {
        'DrillingCrewID': data.drillingCrewID,
        'UserID': userInfo?.userID,
        'UseStorageLocation': userInfo?.useStorageLocation,
        'QrCodeList': [
          for (var i = 0; i < data.children!.length; ++i)
            {
              'SAPColorBatch': data.children![i].sapColorBatch,
              'Qty': data.children![i].noCodeQty,
              'InterID': data.children![i].interID,
              'RouteEntryFID': data.children![i].routeEntryFID,
              'SapDecideArea': data.sapDecideArea,
              'FactoryCode': userInfo?.sapFactory,
              'IssueWareHouse': userInfo?.defaultStockNumber,
              'Location': getMaterialDispatchLocationId(),
              'PalletNumber': getMaterialDispatchPalletNumber(),
              'StorageLocation': '',
              'RouteEntryFIDs': data.routeEntryFIDs,
              'ProductName': data.productName,
            }
        ].toList(),
      },
    ).then((response) {
      if (response.resultCode == resultSuccess) {
        success.call(response.message ?? '');
      } else {
        error.call(response.message ?? '');
      }
    });
  }

  itemCancelReport({
    required MaterialDispatchInfo data,
    required Function(String msg) success,
    required Function(String msg) error,
  }) {
    var list = <Map>[];
    groupBy(
      data.children!,
      (v) => '${v.routeEntryFID}${v.routeEntryFIDs}',
    ).forEach((k, v) {
      list.add({
        'ScProcessWorkCardInterID': v[0].interID,
        'RouteEntryFID': v[0].routeEntryFID,
        'RouteEntryFIDs': v[0].routeEntryFIDs,
        'UserID': userInfo?.userID,
      });
    });
    httpPost(
      loading: 'material_dispatch_cancel_reporting'.tr,
      method: webApiProcessOutPutReport,
      body: list,
    ).then((response) {
      if (response.resultCode == resultSuccess) {
        success.call(response.message ?? '');
      } else {
        error.call(response.message ?? '');
      }
    });
  }

  subItemWarehousing({
    required Children data,
    required String sapDecideArea,
    required Function(String msg) success,
    required Function(String msg) error,
  }) {
    httpPost(
      loading: 'material_dispatch_in_storage'.tr,
      method: webApiPickCodeProductionWarehousing,
      params: {
        'processWorkCardInterID': data.interID,
        'routeEntryFID': data.routeEntryFID,
        'RouteEntryFIDs': data.routeEntryFIDs,
        'sapDecideArea': sapDecideArea,
        'MovementType': '101',
        'Date': getDateYMD(),
        'Location': getMaterialDispatchLocationId(),
        'UserID': userInfo?.userID,
      },
    ).then((response) {
      if (response.resultCode == resultSuccess) {
        success.call(response.message ?? '');
      } else {
        error.call(response.message ?? '');
      }
    });
  }

  subItemReport({
    required MaterialDispatchInfo data,
    required Children subData,
    required String reportQty,
    required String longQty,
    required String wideQty,
    required String heightQty,
    required String gwQty,
    required String nwQty,
    required int titlePosition,
    required int clickPosition,
    required Function(String guid, String pick) success,
    required Function(String msg) error,
  }) {
    httpPost(
      loading: 'material_dispatch_reporting'.tr,
      method: webApiCreateProcessOutPutStripDrawing,
      body: {
        'DrillingCrewID': data.drillingCrewID,
        'UserID': userInfo?.userID,
        'UseStorageLocation': userInfo?.useStorageLocation,
        'QrCodeList': [
          {
            'Length': longQty.toDoubleTry(),
            'Width': wideQty.toDoubleTry(),
            'Height': heightQty.toDoubleTry(),
            'GW': gwQty.toDoubleTry(),
            'NW': nwQty.toDoubleTry(),
            'SAPColorBatch': subData.sapColorBatch,
            'Qty': reportQty,
            'InterID': subData.interID,
            'RouteEntryFID': subData.routeEntryFID,
            'SapDecideArea': data.sapDecideArea,
            'FactoryCode': userInfo?.sapFactory,
            'IssueWareHouse': userInfo?.defaultStockNumber,
            'Location': getMaterialDispatchLocationId(),
            'PalletNumber': getMaterialDispatchPalletNumber(),
            'StorageLocation': '',
            'RouteEntryFIDs': data.routeEntryFIDs,
            'ProductName': data.productName,
          }
        ].toList(),
      },
    ).then((response) {
      if (response.resultCode == resultSuccess) {
        if (clickPosition != -1) {
          showOrderList[titlePosition].children![clickPosition].codeQty =
              (orderList[titlePosition]
                      .children![clickPosition]
                      .codeQty
                      .toDoubleTry()
                      .add(reportQty.toDoubleTry()))
                  .toShowString();
          showOrderList[titlePosition].children![clickPosition].noCodeQty =
              (orderList[titlePosition]
                  .children![clickPosition]
                  .noCodeQty
                  .toDoubleTry()
                  .sub(reportQty.toDoubleTry())
                  .toShowString());

          showOrderList[titlePosition].codeQty =(orderList[titlePosition].codeQty
              .toDoubleTry()
              .add(reportQty.toDoubleTry()))
              .toShowString();
          showOrderList.refresh();
        }
        var guid = '';
        var pick = '';
        if (MaterialDispatchReportSuccessInfo.fromJson(response.data)
            .guidList!
            .isNotEmpty) {
          guid = MaterialDispatchReportSuccessInfo.fromJson(response.data)
              .guidList![0];
        }
        if (MaterialDispatchReportSuccessInfo.fromJson(response.data)
            .pickUpCodeList!
            .isNotEmpty) {
          pick = MaterialDispatchReportSuccessInfo.fromJson(response.data)
              .pickUpCodeList![0];
        }
        success.call(guid, pick);
      } else {
        error.call(response.message ?? '');
      }
    });
  }

  subItemCancelReport({
    required Children subData,
    required Function(String msg) success,
    required Function(String msg) error,
  }) {
    httpPost(
      loading: 'material_dispatch_cancel_reporting'.tr,
      method: webApiProcessOutPutReport,
      body: [
        {
          'ScProcessWorkCardInterID': subData.interID,
          'RouteEntryFID': subData.routeEntryFID,
          'RouteEntryFIDs': subData.routeEntryFIDs,
          'UserID': userInfo?.userID,
        }
      ].toList(),
    ).then((response) {
      if (response.resultCode == resultSuccess) {
        success.call(response.message ?? '');
      } else {
        error.call(response.message ?? '');
      }
    });
  }

  getLabelDetail({
    required String guid,
    required Function(List<MaterialDispatchLabelDetail> msg) success,
  }) {
    httpGet(
      loading: 'material_dispatch_get_label_detail'.tr,
      method: webApiGetMtoNoQty,
      params: {'GUID': guid},
    ).then((response) {
      if (response.resultCode == resultSuccess) {
        var list = <MaterialDispatchLabelDetail>[
          for (var i = 0; i < response.data.length; ++i)
            MaterialDispatchLabelDetail.fromJson(response.data[i])
        ];
        success.call(list);
      } else {
        var list = <MaterialDispatchLabelDetail>[];
        success.call(list);
      }
    });
  }
}
