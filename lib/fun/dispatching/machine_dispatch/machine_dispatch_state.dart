import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:get/get.dart';
import 'package:jd_flutter/bean/http/response/base_data.dart';
import 'package:jd_flutter/bean/http/response/machine_dispatch_info.dart';
import 'package:jd_flutter/bean/http/response/sap_label_info.dart';
import 'package:jd_flutter/utils/utils.dart';
import 'package:jd_flutter/utils/web_api.dart';
class MachineDispatchState {
  var dataList = <String>[].obs;
  MachineDispatchDetailsInfo? detailsInfo;
  var sizeItemList = <Items>[].obs;
  var selectList = <RxBool>[];
  var nowDispatchNumber = ''.obs;
  var labelList = <Item>[].obs;
  var labelErrorMsg = '';
  var leaderVerify = false.obs;
  var surplusMaterialList = <Map<String, String>>[].obs;

  var processList = <DispatchProcessInfo>[].obs;
  var processSelect = 0.obs;



  createDispatchProcess() {
    var totalProduction = 0.0;
    detailsInfo?.items?.forEach((v) {
      totalProduction = totalProduction.add(v.getReportQty());
    });
    processList.value = [
      for (var i = 0; i < (detailsInfo!.processList ?? []).length; ++i)
        DispatchProcessInfo(
          detailsInfo!.processList![i].processNumber ?? '',
          detailsInfo!.processList![i].processName ?? '',
          totalProduction,
        )
    ];
  }

  getWorkCardList({
    required Function(List<MachineDispatchInfo> data) success,
    required Function(String msg) error,
  }) {
    httpGet(
      loading: 'machine_dispatch_getting_process_plan_list_tips'.tr,
      method: webApiGetWorkCardList,
      params: {
        // 'DispatchingMachine': userInfo?.number,
        'DispatchingMachine': 'JT23',
      },
    ).then((response) {
      if (response.resultCode == resultSuccess) {
        var list = <MachineDispatchInfo>[
          for (var i = 0; i < response.data.length; ++i)
            MachineDispatchInfo.fromJson(response.data[i])
        ];
        success.call(list);
      } else {
        error.call(response.message ?? 'query_default_error'.tr);
      }
    });
  }

  getWorkCardDetail({
    required String dispatchNumber,
    required Function() success,
    required Function(String msg) error,
  }) {
    nowDispatchNumber.value = dispatchNumber;
    formatWorkCardDetailData(
      doHttp: httpGet(
        loading: 'machine_dispatch_getting_process_plan_detail_tips'.tr,
        method: webApiGetWorkCardDetail,
        params: {
          'DispatchingMachine': '',
          'DispatchNumber': dispatchNumber,
        },
      ),
      success: success,
      error: error,
    );
  }

  refreshWorkCardDetail({
    required Function() success,
    required Function(String msg) error,
  }) {
    formatWorkCardDetailData(
      doHttp: httpGet(
        loading: 'machine_dispatch_getting_process_plan_detail_tips'.tr,
        method: webApiGetWorkCardDetail,
        params: {
          'DispatchingMachine': '',
          'DispatchNumber': nowDispatchNumber.value,
        },
      ),
      success: success,
      error: error,
    );
  }

  formatWorkCardDetailData({
    required Future<BaseData> doHttp,
    required Function() success,
    required Function(String msg) error,
  }) {
    doHttp.then((response) {
      leaderVerify.value = false;
      if (response.resultCode == resultSuccess) {
        detailsInfo = MachineDispatchDetailsInfo.fromJson(response.data);
        sizeItemList = <Items>[
          for (var i = 0; i < (detailsInfo?.items ?? []).length; ++i)
            detailsInfo!.items![i]
        ].obs;
        selectList = [
          for (var i = 0; i < (detailsInfo?.items ?? []).length; ++i) false.obs
        ];
        surplusMaterialList.value = [
          if ((detailsInfo?.stubBar1 ?? '').isNotEmpty)
            {
              'StuBarCode': detailsInfo?.stubBar1 ?? '',
              'StuBarName': detailsInfo?.stubBarName1 ?? '',
              'StuBarNumber': '1',
            },
          if ((detailsInfo?.stubBar2 ?? '').isNotEmpty)
            {
              'StuBarCode': detailsInfo?.stubBar2 ?? '',
              'StuBarName': detailsInfo?.stubBarName2 ?? '',
              'StuBarNumber': '2',
            },
          if ((detailsInfo?.stubBar3 ?? '').isNotEmpty)
            {
              'StuBarCode': detailsInfo?.stubBar3 ?? '',
              'StuBarName': detailsInfo?.stubBarName3 ?? '',
              'StuBarNumber': '3',
            }
        ];
        success.call();
      } else {
        detailsInfo = null;
        sizeItemList.clear();
        selectList = [];
        surplusMaterialList.value = [];
        error.call(response.message ?? 'query_default_error'.tr);
      }
    });
  }

  getSapLabelList({
    required Function() success,
    required Function() error,
  }) {
    sapPost(
      loading: 'machine_dispatch_getting_label_list_tips'.tr,
      method: webApiSapGetMaterialDispatchLabelList,
      body: [
        {
          'ZBQLX': '10', //10生产标签20销售标签（选填）
          'ZBQZT': '20', //10创建 20打印 30报工 40入库 50上架 60下架 70销售出库 80标签变更
          'DISPATCH_NO': detailsInfo?.dispatchNumber,
        }
      ],
    ).then((response) {
      if (response.resultCode == resultSuccess) {
        var list = <SapLabelInfo>[
          for (var i = 0; i < response.data.length; ++i)
            SapLabelInfo.fromJsonWithState(
              response.data[i],
              detailsInfo?.items ?? [],
              detailsInfo?.barCodeList ?? [],
            )
        ];
        labelList.value = [for (var v in list) ...v.item ?? []];
        detailsInfo?.items?.forEach((v1) {
          v1.labelQty = labelList.where((v2) => v2.size == v1.size).length;
        });
        labelErrorMsg = '';
        success.call();
      } else {
        labelList.clear();
        labelErrorMsg = response.message ?? '';
        error.call();
      }
    });
  }

  cleanOrRecoveryLastQty({
    required bool isClean,
    required Function(String msg) success,
    required Function(String msg) error,
  }) {
    var sizeList = <String>[
      for (var i = 0; i < selectList.length; ++i)
        if (selectList[i].value) detailsInfo!.items![i].size ?? ''
    ];

    httpPost(
      loading: isClean ? 'machine_dispatch_cleaning_last_tips'.tr : 'machine_dispatch_restoring_last_tips'.tr,
      method: webApiCleanOrRecoveryLastQty,
      body: {
        'InterID': detailsInfo?.interID,
        'SignSize': isClean ? sizeList : '',
        'ClearSize': isClean ? '' : sizeList,
      },
    ).then((response) {
      if (response.resultCode == resultSuccess) {
        success.call(response.message ?? '');
      } else {
        error.call(response.message ?? 'query_default_error'.tr);
      }
    });
  }

  modifyWorkCardItem({
    required Function(String msg) success,
    required Function(String msg) error,
  }) {
    httpPost(
      loading: 'machine_dispatch_modifying_dispatch_order_tips'.tr,
      method: webApiModifyWorkCardItem,
      body: {
        'InterID': detailsInfo?.interID,
        'Items': [
          for (var i = 0; i < (detailsInfo?.items ?? []).length; ++i)
            {
              'EntryID': detailsInfo?.items![i].entryID,
              'Mould': detailsInfo?.items![i].mould,
              'TodayDispatchQty': detailsInfo?.items![i].todayDispatchQty,
              'NotFullQty': detailsInfo?.items![i].notFullQty,
              'BoxesQty': detailsInfo?.items![i].boxesQty,
              'Capacity': detailsInfo?.items![i].capacity,
            }
        ]
      },
    ).then((response) {
      if (response.resultCode == resultSuccess) {
        leaderVerify.value = false;
        success.call(response.message ?? '');
      } else {
        error.call(response.message ?? 'query_default_error'.tr);
      }
    });
  }

  reportDispatch({
    required Function(String msg) success,
    required Function(String msg) error,
  }) {
    var di = <DispatchInfo>[];
    for (var i = 0; i < processList.length; ++i) {
      di.addAll(processList[i].dispatchList);
    }
    var workers = <DispatchInfo>[];
    groupBy(di, (v) => v.workerEmpID).forEach((k, v) {
      workers.add(v[0]);
    });

    httpPost(
      loading: 'machine_dispatch_generating_production_report_tips'.tr,
      method: webApiReportDispatch,
      body: {
        'InterID': detailsInfo?.interID, //派工单InterID
        'Shift': detailsInfo?.shift, //班次
        'DecrementNumber': detailsInfo?.decrementNumber, //ZEDJBH 递减编号
        'DispatchNumber': detailsInfo?.dispatchNumber, //ZDISPATCH_NO 派工单号
        'MaterialNumber': detailsInfo?.materialNumber, //MATNR 一般可配置物料
        'Date': detailsInfo?.startDate, //BUDAT 凭证中的过帐日期
        'WorkCenter': userInfo?.number, //ARBPL 工作中心
        'UserID': userInfo?.userID, //用户ID
        'Items': [
          for (var i = 0; i < (detailsInfo?.items ?? []).length; ++i)
            {
              'EntryID': detailsInfo!.items![i].entryID,
              //派工单分录ID
              'Size': detailsInfo!.items![i].size,
              //尺码
              'StandardTextCode': detailsInfo!.processflow,
              //KTSCH 制程
              'ConfirmedQty': detailsInfo!.items![i].getReportQty(),
              //GMNGA 确认的产量
              'LastNotFullQty': detailsInfo!.items![i].lastNotFullQty,
              //上一班未满箱数量
              'Mantissa': detailsInfo!.items![i].notFullQty,
              //未满箱数量 尾数
              'BoxesQty': detailsInfo!.items![i].boxesQty,
              //框数
              'Capacity': detailsInfo!.items![i].capacity,
              //箱容
              'BUoM': detailsInfo!.items![i].bUoM,
              //MEINS 基本计量单位
              'ConfirmCurrentWorkingHours':
                  detailsInfo!.items![i].confirmCurrentWorkingHours,
              //ISM01 确认当前工时
              'WorkingHoursUnit': detailsInfo!.items![i].workingHoursUnit,
              //工时单位
            }
        ],
        'EmpList': [
          for (var i = 0; i < processList.length; ++i)
            for (var j = 0; j < processList[i].dispatchList.length; ++j)
              {
                'EmpID': processList[i].dispatchList[j].workerEmpID, //员工ID
                'EmpName': processList[i].dispatchList[j].workerName, //员工名称
                'ProcessName': processList[i].processName, //工序
                'Qty': processList[i].dispatchList[j].dispatchQty, //记工数
              }
        ],
        'PictureList': [
          for (var i = 0; i < workers.length; ++i)
            {
              'Photo': base64Encode(workers[i].signature!.buffer.asUint8List()),
              //base64编码
              'EmpCode': workers[i].workerEmpID,
              //工号
            }
        ],
      },
    ).then((response) {
      if (response.resultCode == resultSuccess) {
        success.call(response.message ?? '');
      } else {
        error.call(response.message ?? 'query_default_error'.tr);
      }
    });
  }
}
