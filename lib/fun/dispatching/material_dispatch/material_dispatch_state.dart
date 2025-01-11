import 'package:collection/collection.dart';
import 'package:get/get.dart';
import 'package:jd_flutter/bean/http/response/material_dispatch_info.dart';
import 'package:jd_flutter/bean/http/response/process_specification_info.dart';
import 'package:jd_flutter/utils/utils.dart';
import 'package:jd_flutter/utils/web_api.dart';



class MaterialDispatchState {
  final String spPalletDate = 'MaterialDispatchPickPalletDate';
  final String spMachine = 'MaterialDispatchPickMachine';
  final String spWarehouseLocation = 'MaterialDispatchPickWarehouseLocation';
  final String spPallet = 'MaterialDispatchPickPallet';

  var typeBody = '';
  var lastProcess = false.obs;
  var unStockIn = false.obs;
  var orderList = <MaterialDispatchInfo>[];
  var showOrderList = <MaterialDispatchInfo>[].obs;

  int date = 0;
  String machineId = '';
  String locationId = '';
  String palletNumber = '';

  MaterialDispatchState() {
    getSavePickData();
  }

  getSavePickData() {
    date = spGet(spPalletDate) ?? DateTime.now().millisecondsSinceEpoch;
    machineId = spGet(spMachine) ?? '';
    locationId = spGet(spWarehouseLocation) ?? '';
    palletNumber = spGet(spPallet) ?? '';
  }

  savePickData({
    required int date,
    required String machineId,
    required String locationId,
    required String palletNumber,
  }) {
    this.date = date;
    this.machineId = machineId;
    this.locationId = locationId;
    this.palletNumber = palletNumber;
    spSave(spPalletDate, date);
    spSave(spMachine, machineId);
    spSave(spWarehouseLocation, locationId);
    spSave(spPallet, palletNumber);
  }

  isNeedSetInitData() {
    return machineId.isEmpty ||
        locationId.isEmpty ||
        date == 0 ||
        palletNumber.isEmpty;
  }

  getScWorkCardProcess({
    required String startDate,
    required String endDate,
    required int status,
    required Function(String msg) error,
  }) {
    httpGet(
      method: webApiGetScWorkCardProcess,
      loading: '正在查询工单',
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
      loading: '正在提交报工...',
      params: {
        'Date': getDateYMD(time: DateTime.fromMillisecondsSinceEpoch(date)),
        'DrillingCrewID': machineId,
        'MovementType': '101',
        'DeptID': userInfo?.reportDeptmentID,
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
          'Location': locationId,
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

  queryProcessSpecification({
    required String typeBody,
    required Function(List<ProcessSpecificationInfo>) success,
    required Function(String msg) error,
  }) {
    httpGet(
      loading: '正在查询工艺说明书...',
      method: webApiGetProcessSpecificationList,
      params: {
        'Product': typeBody,
      },
    ).then((response) {
      if (response.resultCode == resultSuccess) {
        success.call([
          for (var item in response.data)
            ProcessSpecificationInfo.fromJson(item)
        ]);
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
      loading: '正在提交报工...',
      method: webApiCreateProcessOutPutStripDrawing,
      params: {
        'DrillingCrewID': machineId,
        'UserID': userInfo?.userID,
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
              'Location': locationId,
              'PalletNumber': palletNumber,
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
      loading: '正在取消报工...',
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
      loading: '正在提交入库...',
      method: webApiPickCodeProductionWarehousing,
      params: {
        'processWorkCardInterID': data.interID,
        'routeEntryFID': data.routeEntryFID,
        'RouteEntryFIDs': data.routeEntryFIDs,
        'sapDecideArea': sapDecideArea,
        'MovementType': '101',
        'Date': getDateYMD(),
        'Location': locationId,
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
    required Function(String msg) success,
    required Function(String msg) error,
  }) {
    httpPost(
      loading: '正在提交报工...',
      method: webApiCreateProcessOutPutStripDrawing,
      params: {
        'DrillingCrewID': machineId,
        'UserID': userInfo?.userID,
        'QrCodeList': [
          {
            'SAPColorBatch': subData.sapColorBatch,
            'Qty': data.qty,
            'InterID': subData.interID,
            'RouteEntryFID': subData.routeEntryFID,
            'SapDecideArea': data.sapDecideArea,
            'FactoryCode': userInfo?.sapFactory,
            'IssueWareHouse': userInfo?.defaultStockNumber,
            'Location': locationId,
            'PalletNumber': palletNumber,
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

  subItemCancelReport({
    required Children subData,
    required Function(String msg) success,
    required Function(String msg) error,
  }) {
    httpPost(
      loading: '正在取消报工...',
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
}
