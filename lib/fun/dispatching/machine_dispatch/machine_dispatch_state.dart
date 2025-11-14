import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:get/get.dart';
import 'package:jd_flutter/bean/http/response/base_data.dart';
import 'package:jd_flutter/bean/http/response/machine_dispatch_info.dart';
import 'package:jd_flutter/bean/http/response/sap_label_info.dart';
import 'package:jd_flutter/utils/extension_util.dart';
import 'package:jd_flutter/utils/utils.dart';
import 'package:jd_flutter/utils/web_api.dart';
import 'package:jd_flutter/widget/custom_widget.dart' show showSnackBar;
import 'package:jd_flutter/widget/dialogs.dart';

class MachineDispatchState {
  var hasDetails = false.obs;
  MachineDispatchDetailsInfo? detailsInfo;
  var sizeItemList = <Items>[].obs;
  var selectList = <RxBool>[];
  var nowDispatchNumber = ''.obs;
  var labelList = <Item>[].obs;
  var leaderVerify = false.obs;
  var surplusMaterialList = <Map<String, dynamic>>[].obs;

  var processList = <DispatchProcessInfo>[].obs;
  var handoverList = <HandoverInfo>[].obs;
  var processSelect = 0.obs;

  var historyInfo = <MachineDispatchHistoryInfo>[].obs;
  var historyLabelInfo = <MachineDispatchReprintLabelInfo>[].obs;

  void createDispatchProcess() {
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

  void getWorkCardList({
    required Function(List<MachineDispatchInfo> data) success,
    required Function(String msg) error,
  }) {
    httpGet(
      loading: 'machine_dispatch_getting_process_plan_list_tips'.tr,
      method: webApiGetWorkCardList,
      params: {
        'DispatchingMachine': userInfo?.number,
      },
    ).then((response) {
      if (response.resultCode == resultSuccess) {
        success.call([
          for (var json in response.data) MachineDispatchInfo.fromJson(json)
        ]);
      } else {
        error.call(response.message ?? 'query_default_error'.tr);
      }
    });
  }

  void getWorkCardListByDate({
    required String startDate,
    required String endDate,
    required Function() success,
    required Function(String msg) error,
  }) {
    httpGet(
      loading: 'machine_dispatch_getting_process_plan_list_tips'.tr,
      method: webApiGetWorkCardListByDate,
      params: {
        'StartDate': startDate,
        'EndDate': endDate,
        'DispatchingMachine': userInfo?.number,
      },
    ).then((response) {
      if (response.resultCode == resultSuccess) {
        historyInfo.value = [
          for (var json in response.data)
            MachineDispatchHistoryInfo.fromJson(json)
        ];
        success.call();
      } else {
        error.call(response.message ?? 'query_default_error'.tr);
      }
    });
  }

  void refreshWorkCardDetail({
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

  void formatWorkCardDetailData({
    required Future<BaseData> doHttp,
    required Function() success,
    required Function(String msg) error,
  }) {
    doHttp.then((response) {
      leaderVerify.value = false;
      if (response.resultCode == resultSuccess) {
        detailsInfo = MachineDispatchDetailsInfo.fromJson(response.data);
        sizeItemList.value = <Items>[
          for (var i = 0; i < (detailsInfo?.items ?? []).length; ++i)
            detailsInfo!.items![i]
        ];
        selectList = [
          for (var i = 0; i < (detailsInfo?.items ?? []).length; ++i) false.obs
        ];

        surplusMaterialList.value = [
          if ((detailsInfo?.stubBar1 ?? '').isNotEmpty)
            {
              'StuBarCode': detailsInfo?.stubBar1 ?? '',
              'StuBarName': detailsInfo?.stubBarName1 ?? '',
              'StuBarNumber': '1',
              'InterID': detailsInfo!.interID,
            },
          if ((detailsInfo?.stubBar2 ?? '').isNotEmpty)
            {
              'StuBarCode': detailsInfo?.stubBar2 ?? '',
              'StuBarName': detailsInfo?.stubBarName2 ?? '',
              'StuBarNumber': '2',
              'InterID': detailsInfo!.interID,
            },
          if ((detailsInfo?.stubBar3 ?? '').isNotEmpty)
            {
              'StuBarCode': detailsInfo?.stubBar3 ?? '',
              'StuBarName': detailsInfo?.stubBarName3 ?? '',
              'StuBarNumber': '3',
              'InterID': detailsInfo!.interID,
            }
        ];
        hasDetails.value = true;
        success.call();
      } else {
        hasDetails.value = false;
        detailsInfo = null;
        sizeItemList.clear();
        selectList = [];
        surplusMaterialList.value = [];
        error.call(response.message ?? 'query_default_error'.tr);
      }
    });
  }

  Future<BaseData> _getSapMaterialDispatchLabels({
    required String labelType,
    required String labelStatus,
    required String dispatchNumber,
  }) =>
      sapPost(
        loading: 'machine_dispatch_getting_label_list_tips'.tr,
        method: webApiSapGetMaterialDispatchLabelList,
        body: [
          {
            'ZBQLX': labelType, //10生产标签20销售标签（选填）
            'ZBQZT': labelStatus, //10创建 20打印 30报工 40入库 50上架 60下架 70销售出库 80标签变更
            'DISPATCH_NO': dispatchNumber,
          }
        ],
      );

  void getSapLabelList({
    required Function() success,
    required Function(String) error,
  }) {
    _getSapMaterialDispatchLabels(
      labelType: '10',
      labelStatus: '20',
      dispatchNumber: detailsInfo?.dispatchNumber ?? '',
    ).then((response) {
      if (response.resultCode == resultSuccess) {
        var list = <SapLabelInfo>[
          for (var json in response.data)
            SapLabelInfo.fromJsonWithState(
              json,
              detailsInfo?.items ?? [],
              detailsInfo?.barCodeList ?? [],
            )
        ];
        labelList.value = [for (var v in list) ...v.item ?? []];
        detailsInfo?.items?.forEach((v1) {
          v1.labelQty = labelList
              .where((v2) => v2.size == v1.size)
              .length;
        });
        success.call();
      } else {
        logger.f('------失败---');
        labelList.clear();
        error.call(response.message ?? '');
      }
    });
  }

  void getHistoryLabelList({
    required int index,
    required Function() success,
    required Function(String) error,
  }) {
    _getSapMaterialDispatchLabels(
      labelType: '10',
      labelStatus: '',
      dispatchNumber: historyInfo[index].dispatchNumber ?? '',
    ).then((response) {
      if (response.resultCode == resultSuccess) {
        var list = [
          for (var json in response.data)
            SapLabelInfo.fromJson(json)
        ];
        var labelList = <MachineDispatchReprintLabelInfo>[];
        for (var v1 in list) {
          v1.item?.forEach((v2) {
            labelList.add(MachineDispatchReprintLabelInfo(
              number: v1.number ?? '',
              labelID: v2.subLabelID ?? '',
              processes: historyInfo[index].processFlow ?? '',
              qty: v2.qty ?? 0,
              size: v2.size ?? '',
              factoryType: historyInfo[index].factoryType ?? '',
              date: v1.date ?? '',
              materialName: historyInfo[index].materialName ?? '',
              unit: v2.unit ?? '',
              machine: historyInfo[index].machine ?? '',
              shift: historyInfo[index].shift ?? '',
              dispatchNumber: nowDispatchNumber.value,
              decrementNumber: historyInfo[index].decrementNumber ?? '',
              isLastLabel: v2.isLastLabel,
              isEnglish: v2.type == '01',
              specifications: v2.specifications,
              netWeight: v2.netWeight,
              grossWeight: v2.grossWeight,
              englishName: v2.englishName ?? '',
              englishUnit: v2.englishUnit ?? '',
            ));
          });
        }
        historyLabelInfo.value = labelList;
        success.call();
      } else {
        historyLabelInfo.clear();
        error.call(response.message ?? 'query_default_error'.tr);
      }
    });
  }

  void cleanOrRecoveryLastQty({
    required bool isClean,
    required Function(String msg) success,
    required Function(String msg) error,
  }) {
    var sizeList = <String>[
      for (var i = 0; i < selectList.length; ++i)
        if (selectList[i].value) detailsInfo!.items![i].size ?? ''
    ];

    httpPost(
      loading: isClean
          ? 'machine_dispatch_cleaning_last_tips'.tr
          : 'machine_dispatch_restoring_last_tips'.tr,
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

  void modifyWorkCardItem({
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

  void reportDispatch({
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

  void labelMaintain({
    required double printQty,
    required String sizeMaterialNumber,
    required String size,
    required bool isEnglish,
    required String specifications,
    required double weight,
    required Function(LabelMaintainInfo) success,
    required Function(String) error,
  }) {
    sapPost(
      loading: '正在创建标签...',
      method: webApiSapMaterialDispatchLabelMaintain,
      body: [
        {
          'optype': '0',
          'dispatch_no': detailsInfo?.dispatchNumber ?? '',
          'ZZZXFS': 'BULKS',
          'ZUSNAM': userInfo?.number,
          'AEDAT': getDateYMD(),
          'AEZET': getTimeHms(),
          'ZXR': printQty.toShowString(),
          'ZBQZT': '20',
          'ZZCJGG': specifications,
          'ZBARCODE_TYPE': isEnglish ? '01' : '',
          'item': [
            {
              'ZDHMNG': isEnglish ? weight : '',
              'MATNR': sizeMaterialNumber,
              'SIZE1_ATINN': size,
              'MENGE': printQty,
            }
          ]
        }
      ],
    ).then((response) {
      if (response.resultCode == resultSuccess) {
        success.call(LabelMaintainInfo.fromJson(response.data[0]));
      } else {
        error.call(response.message ?? 'query_default_error'.tr);
      }
    });
  }

  void productionReport({
    required Function(String msg) success,
    required Function(String msg) error,
  }) {
    httpPost(
      loading: '正在提交产量汇报...',
      method: webApiModifyWorkCardItem,
      body: {
        'InterID': detailsInfo?.interID,
        'Items': [
          for (Items item in (detailsInfo?.items ?? []))
            {
              'EntryID': item.entryID,
              'BoxesQty': item.boxesQty,
              'NotFullQty': item.notFullQty,
            }
        ],
        'Output': {
          'UserID': userInfo?.userID,
          'InterID': detailsInfo?.interID,
          'Shift': detailsInfo?.shift,
          'DecrementNumber': detailsInfo?.decrementNumber,
          'DispatchNumber': detailsInfo?.dispatchNumber,
          'MaterialNumber': detailsInfo?.materialNumber,
          'Date': detailsInfo?.startDate,
          'WorkCenter': detailsInfo?.machine,
          'Items': [
            for (Items item in (detailsInfo?.items ?? []))
              {
                'EntryID': item.entryID,
                'Size': item.size,
                'StandardTextCode': detailsInfo?.processflow,
                'ConfirmedQty': item.getReportQty(),
                'LastNotFullQty': item.lastNotFullQty,
                'Mantissa': item.notFullQty,
                'BoxesQty': item.boxesQty,
                'Capacity': item.capacity,
                'BUoM': item.bUoM,
                'ConfirmCurrentWorkingHours': item.confirmCurrentWorkingHours,
                'WorkingHoursUnit': item.workingHoursUnit,
              }
          ]
        }
      },
    ).then((response) {
      if (response.resultCode == resultSuccess) {
        success.call(response.message ?? '');
      } else {
        error.call(response.message ?? 'query_default_error'.tr);
      }
    });
  }

  void cancelConfirmation({
    required Function(String msg) success,
    required Function(String msg) error,
  }) {
    httpPost(
      loading: '正在取消工号确认...',
      method: webApiCancelConfirmation,
      params: {
        'InterID': detailsInfo?.interID,
      },
    ).then((response) {
      if (response.resultCode == resultSuccess) {
        success.call(response.message ?? '');
      } else {
        error.call(response.message ?? 'query_default_error'.tr);
      }
    });
  }

  void getEnglishLabel({
    required String code,
    required Function(EnglishLabelInfo) success,
    required Function(String msg) error,
  }) {
    sapPost(
      loading: '正在取消工号确认...',
      method: webApiSapGetMaterialDispatchEnglishLabel,
      body: {
        'MATNR': code,
      },
    ).then((response) {
      if (response.resultCode == resultSuccess) {
        success.call(EnglishLabelInfo.fromJson(response.data));
      } else {
        error.call(response.message ?? 'query_default_error'.tr);
      }
    });
  }

  //两班交接
  void handover({
    required Function(String msg) success,
  }) {
    if (handoverList
        .any((data) => data.handoverInfoDispatchList.isEmpty)) {
      showSnackBar(message: '交接人员为空！');
    } else if (handoverList.any((data)=> data.handoverInfoDispatchList[0].signature == null)) {
      showSnackBar(message: '含有未签字人员！');
    } else {
      httpPost(
        method: webApiUpdateScWorkCard,
        loading: '正在交接...',
        body: {
          'InterID': detailsInfo?.interID,
          'NextShiftEmpID': handoverList[0].handoverInfoDispatchList[0]
              .workerEmpID,
          'OnDutyEmpID': handoverList[1].handoverInfoDispatchList[0]
              .workerEmpID,
          'Items': [
            for (var item in sizeItemList
                .where((data) => data.size != '合计')
                .toList())
              {
                'Capacity': "NULL",
                'Mould': "NULL",
                'TodayDispatchQty': "NULL",
                'EntryID': item.entryID.toString(),
                'BoxesQty': item.boxesQty.toString(),
                'NotFullQty': 'NULL',
                'MantissaFlag': item.mantissaIdentification == true ? '1' : '0',
              }
          ],
          'PictureList': [
            for (var item in handoverList)
              {
                'EmpCode': item.handoverInfoDispatchList[0].workerEmpID,
                'Photo': base64Encode(
                    item.handoverInfoDispatchList[0].signature!.buffer
                        .asUint8List()),
              }
          ],
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
}
