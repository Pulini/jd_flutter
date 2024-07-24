import 'package:collection/collection.dart';
import 'package:get/get.dart';

import '../../../bean/http/response/material_dispatch_info.dart';
import '../../../bean/http/response/process_specification_info.dart';
import '../../../route.dart';
import '../../../utils.dart';
import '../../../web_api.dart';
import '../../../widget/custom_widget.dart';
import '../../../widget/dialogs.dart';
import '../../../widget/picker/picker_controller.dart';
import '../../../widget/web_page.dart';
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
    userInfo?.empID = 175122;
    userInfo?.factory = '1000';
    userInfo?.defaultStockNumber = '1104';
    super.onReady();
  }

  @override
  void onClose() {
    super.onClose();
  }

  query({Function()? refresh}) {
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
        'EmpID': userInfo?.empID,
      },
    ).then((response) {
      if (response.resultCode == resultSuccess) {
        state.orderList = [
          for (var i = 0; i < response.data.length; ++i)
            MaterialDispatchInfo.fromJson(response.data[i])
        ];
        state.showOrderList.value = state.orderList;
        if (refresh != null) {
          refresh.call();
        } else {
          if (state.orderList.isNotEmpty) Get.back();
        }
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

  reportToSAP() {
    httpPost(
      method: webApiCreateLastProcessReport,
      loading: '正在提交报工...',
      params: {
        'Date':
            getDateYMD(time: DateTime.fromMillisecondsSinceEpoch(state.date)),
        'DrillingCrewID': state.machineId,
        'MovementType': '101',
        'DeptID': userInfo?.reportDeptmentID,
        'UserID': userInfo?.userID,
      },
    ).then((response) {
      if (response.resultCode == resultSuccess) {
        successDialog(
            content: response.message, back: () => query(refresh: () {}));
      } else {
        errorDialog(content: response.message);
      }
    });
  }

  batchWarehousing() {
    var submitList = <Map<String, String>>[];
    for (var i = 0; i < state.orderList.length; ++i) {
      var sub = state.orderList[i].children!
          .where(
            (v) => v.partialWarehousing == '1',
          )
          .toList();
      for (var j = 0; j < sub.length; ++j) {
        submitList.add({
          'processWorkCardInterID': sub[j].interID ?? '',
          'routeEntryFID': sub[j].routeEntryFID ?? '',
          'sapDecideArea': sub[j].sapColorBatch ?? '',
          'MovementType': '101',
          'Date': getDateYMD(),
          'RouteEntryFIDs': sub[j].routeEntryFIDs ?? '',
          'Location': state.locationId,
          'UserID': (userInfo?.userID ?? 0).toString(),
        });
      }
    }
    if (submitList.isEmpty) {
      informationDialog(content: '没有需要入库的数据');
    } else {
      httpPost(
        method: webApiPickCodeBatchProductionWarehousing,
        loading: '正在批量入库...',
        body: submitList,
      ).then((response) {
        if (response.resultCode == resultSuccess) {
          successDialog(
              content: response.message, back: () => query(refresh: () {}));
        } else {
          errorDialog(content: response.message);
        }
      });
    }
  }

  queryProcessSpecification(
    String typeBody,
    Function(List<ProcessSpecificationInfo>) callback,
  ) {
    httpGet(
      loading: '正在查询工艺说明书...',
      method: webApiGetProcessSpecificationList,
      params: {
        'Product': typeBody,
      },
    ).then((response) {
      if (response.resultCode == resultSuccess) {
        var list = <ProcessSpecificationInfo>[];
        for (var item in response.data) {
          list.add(ProcessSpecificationInfo.fromJson(item));
        }
        if (list.length == 1) {
          Get.to(WebPage(
            title: list[0].fileName ?? '',
            url: list[0].fullName ?? '',
          ));
        } else {
          callback.call(list);
        }
      } else {
        errorDialog(content: response.message);
      }
    });
  }

  itemReport(MaterialDispatchInfo data) {
    httpPost(
      loading: '正在提交报工...',
      method: webApiCreateProcessOutPutStripDrawing,
      params: {
        'DrillingCrewID': state.machineId,
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
              'Location': state.locationId,
              'PalletNumber': state.palletNumber,
              'StorageLocation': '',
              'RouteEntryFIDs': data.routeEntryFIDs,
              'ProductName': data.productName,
            }
        ].toList(),
      },
    ).then((response) {
      if (response.resultCode == resultSuccess) {
        successDialog(
            content: response.message, back: () => query(refresh: () {}));
      } else {
        errorDialog(content: response.message);
      }
    });
  }

  itemCancelReport(MaterialDispatchInfo data) {
    var list = [];
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
      body: list.toList(),
    ).then((response) {
      if (response.resultCode == resultSuccess) {
        successDialog(
            content: response.message, back: () => query(refresh: () {}));
      } else {
        errorDialog(content: response.message);
      }
    });
  }

  subItemWarehousing(Children data, String sapDecideArea) {
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
          'Location': state.locationId,
          'UserID': userInfo?.userID,
        }).then((response) {
      if (response.resultCode == resultSuccess) {
        successDialog(
            content: response.message, back: () => query(refresh: () {}));
      } else {
        errorDialog(content: response.message);
      }
    });
  }

  subItemReport(
    MaterialDispatchInfo data,
    Children subData,
    bool isPrint,
  ) {
    httpPost(
      loading: '正在提交报工...',
      method: webApiCreateProcessOutPutStripDrawing,
      params: {
        'DrillingCrewID': state.machineId,
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
            'Location': state.locationId,
            'PalletNumber': state.palletNumber,
            'StorageLocation': '',
            'RouteEntryFIDs': data.routeEntryFIDs,
            'ProductName': data.productName,
          }
        ].toList(),
      },
    ).then((response) {
      if (response.resultCode == resultSuccess) {
        successDialog(
          content: response.message,
          back: () => query(refresh: () {
            if (isPrint) {
              List<String> guidList = response.data['GuidList'];
              List<String> pickUpCodeList = response.data['PickUpCodeList'];
            }
          }),
        );
      } else {
        errorDialog(content: response.message);
      }
    });
  }
}
