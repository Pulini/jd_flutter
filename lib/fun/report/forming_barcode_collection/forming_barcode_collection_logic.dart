import 'package:collection/collection.dart';
import 'package:get/get.dart';
import 'package:jd_flutter/bean/http/response/forming_barcode_by_mono_info.dart';
import 'package:jd_flutter/bean/http/response/forming_collection_info.dart';
import 'package:jd_flutter/bean/http/response/forming_mono_detail_info.dart';
import 'package:jd_flutter/bean/http/response/forming_scan_info.dart';
import 'package:jd_flutter/bean/http/response/work_card_priority_info.dart';
import 'package:jd_flutter/fun/report/forming_barcode_collection/forming_barcode_collection_history_view.dart';
import 'package:jd_flutter/utils/extension_util.dart';
import 'package:jd_flutter/utils/utils.dart';
import 'package:jd_flutter/utils/web_api.dart';
import 'package:jd_flutter/widget/custom_widget.dart';
import 'package:jd_flutter/widget/dialogs.dart';

import 'forming_barcode_collection_search_detail_view.dart';
import 'forming_barcode_collection_state.dart';

class FormingBarcodeCollectionLogic extends GetxController {
  final FormingBarcodeCollectionState state = FormingBarcodeCollectionState();

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
        setFirstData(first: first, entryFid: '-1', shoeBoxBill: shoeBoxBillNo);
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
            ?.map((v) => v.todayScannedQty ?? 0.0)
            .reduce((a, b) => a.add(b)),
      ));
    }
  }

  //设置显示的第一个工单
  setFirstData({
    required String first,
    required String entryFid,
    required String shoeBoxBill,
  }) {
    logger.f('first:$first');

    state.scanCode.value = '';
    for (var data in state.dataList) {
      data.isShow = false;
    }
    switch (first) {
      case '0':
        {
          if (state.dataList.isNotEmpty) {
            state.dataList[0].isShow = true;
            state.factoryType.value = state.dataList[0].productName ?? '';
            state.workCardInterID = state.dataList[0].workCardInterID ?? '';
            state.saleOrder.value = state.dataList[0].mtoNo ?? '';
            state.instruction = state.dataList[0].moID ?? '';
            state.customerOrder.value =
                state.dataList[0].clientOrderNumber ?? '';
            state.showDataList.value = state.dataList[0].scWorkCardSizeInfos!;
          }
        }
        break;
      case '1':
        {
          if (state.dataList.isNotEmpty) {
            for (var data in state.dataList) {
              if (data.entryFID == entryFid) {
                data.isShow = true;
                state.factoryType.value = data.productName ?? '';
                state.workCardInterID = data.workCardInterID ?? '';
                state.instruction = data.moID ?? '';
                state.saleOrder.value = data.mtoNo ?? '';
                state.customerOrder.value = data.clientOrderNumber ?? '';
                state.showDataList.value = data.scWorkCardSizeInfos!;
              }
            }
          }
        }

        break;
      case '2':
        {
          if (state.dataList.isNotEmpty) {
            for (var data in state.dataList) {
              if (data.mtoNo == shoeBoxBill) {
                data.isShow = true;
                state.factoryType.value = data.productName ?? '';
                state.workCardInterID = data.workCardInterID ?? '';
                state.instruction = data.moID ?? '';
                state.saleOrder.value = data.mtoNo ?? '';
                state.customerOrder.value = data.clientOrderNumber ?? '';
                state.showDataList.value = data.scWorkCardSizeInfos!.toList();
              }
            }
          }
        }
        break;
    }
  }

  //查询多少天内的派工单
  getWorkCardPriority({
    required String day,
  }) {
    httpGet(
      method: webApiGetWorkCardPriority,
      loading: 'forming_code_collection_get_data'.tr,
      params: {
        'Days': day,
        'DepartmentID': getUserInfo()!.departmentID,
      },
    ).then((response) {
      if (response.resultCode == resultSuccess) {
        state.prioriInfoList.value = [
          for (var i = 0; i < response.data.length; i++)
            WorkCardPriorityInfo.fromJson(response.data[i])..index = i
        ];
      } else {
        state.prioriInfoList.value = [];
        errorDialog(content: response.message ?? 'query_default_error'.tr);
      }
    });
  }

  //提交更改优先级
  prioritySubmit({
    required Function() success,
  }) {
    if (state.prioriInfoList.none((data) => data.isChange == true)) {
      showSnackBar(message: 'forming_code_collection_no_submit_data'.tr);
    } else {
      httpPost(
        method: webApiSubmitWorkCardPriority,
        loading: 'forming_code_collection_submitting'.tr,
        body:
          [

            for (var i = 0; i < state.prioriInfoList.length; ++i)
              for (var j = 0; j < state.prioriInfoList.length; ++j)
                if (state.prioriInfoList[i].sONo == state.prioriInfoList[j].sONo && i!= state.prioriInfoList[j].index)
                  {
                    'WorkCardInterID': state.prioriInfoList[i].workCardInterID.toString(),
                    'ClientOrderNumber': state.prioriInfoList[i].clientOrderNumber,
                    'Priority': i+1,
                  }
          ]
        ,
      ).then((response) {
        if (response.resultCode == resultSuccess) {
          success.call();
        } else {
          errorDialog(content: response.message);
        }
      });
    }
  }

  //更改优先级退出清理数据
  clearData() {
    state.prioriInfoList.clear();
  }

  //复制一份原本数据
  copyData() {
    var list = <FormingCollectionInfo>[];

    for (var data in state.dataList) {
      list.add(data);
    }

    state.copyDataList = list;
  }

  //寻找订单
  searchData(String search) {
    var list = <FormingCollectionInfo>[];

    state.dataList.clear();

    if (search.isEmpty) {
      state.dataList.addAll(state.copyDataList);
    } else {
      for (var data in state.copyDataList) {
        if (data.mtoNo!.contains(search) || data.clientOrderNumber!.contains(search)) {
          list.add(data);
        }
      }
      state.dataList.value = list;
    }
    state.dataList.refresh();
  }

  //设置扫码清尾数据
  setShowScanData(String entryId) {
    for (var data in state.dataList) {
      data.isScanShow = false;
      if (data.entryFID == entryId) {
        data.isScanShow = true;
        state.showScanDataList.clear();
        state.showScanDataList.addAll(data.scWorkCardSizeInfos!);

        state.factoryTypeClear.value = data.productName ?? '';
        state.saleOrderClear.value = data.mtoNo ?? '';
        state.customerOrderClear.value = data.clientOrderNumber ?? '';
        state.orderNumClear.value = data.scWorkCardSizeInfos!
            .where((data) => data.size != '合计')
            .toList()
            .map((v) => v.qty ?? 0)
            .reduce((a, b) => a.add(b))
            .toShowString();
        state.completionNumClear.value = data.scWorkCardSizeInfos!
            .where((data) => data.size != '合计')
            .toList()
            .map((v) => v.scannedQty ?? 0)
            .reduce((a, b) => a.add(b))
            .toShowString();
      }
    }
  }

  //切换订单选中
  selectSwitch(int position) {
    for (var data in state.dataList) {
      data.isSelect.value = false;
    }
    state.dataList[position].isSelect.value = true;
  }

  //返回选中的订单
  String getSelect() {
    var entryId = '';

    for (var data in state.dataList) {
      if (data.isSelect.value == true) {
        entryId = data.entryFID!;
        break;
      }
    }
    return entryId;
  }

  //验证是否含有条码
  checkCode({
    required String code,
    required Function(String, SizeRelations) success,
  }) {
    for (var data in state.dataList) {
      if (data.isShow == true) {
        if (data.sizeRelations!.none((v) => v.barCode == code)) {
          showSnackBar(message: '找不到该条码');
          break;
        } else {
          for (var data in data.sizeRelations!) {
            if (data.barCode == code) {
              success.call(code, data);
              break;
            }
          }
        }
      }
    }
    state.canScan = true;
  }

  //提交扫到的条码
  submitCode({
    required SizeRelations bean,
    required Function() success,
  }) {
    httpPost(
      method: webApiReceiveWorkCardDataST,
      loading: '',
      body: {
        'ScanTime': getCurrentTime(),
        'MoID': state.instruction,
        'WorkCardID': state.workCardInterID,
        'ClientOrderNumber': state.customerOrder.value,
        'Size': bean.size,
        'BarCode': bean.barCode,
        'ScanTypeID': '1',
        'DeptmentID': getUserInfo()!.departmentID,
        'UserID': getUserInfo()!.userID,
      },
    ).then((response) {
      if (response.resultCode == resultSuccess) {
        success.call();
        state.canScan = true;
        logger.f('走接口提交鞋码-------成功--');
      } else {
        state.canScan = true;
        logger.f('走接口提交鞋码-------失败--');
        showSnackBar(
          message: response.message!,
          isWarning: true,
        );
      }
    });
  }

  //扫码成功设置数据
  setShowData(SizeRelations bean) {
    for (var data in state.showDataList) {
      if (data.size == bean.size) {
        data.scannedQty = data.scannedQty! + 1;
        data.todayScannedQty = data.todayScannedQty! + 1;
      }
      if (data.size == '合计') {
        data.scannedQty = data.scannedQty! + 1;
        data.todayScannedQty = data.todayScannedQty! + 1;
      }
    }
    state.showDataList.refresh();
  }

  //线别分析报告
  getWorkLineReport({
    required Function(String) success,
  }) {
    httpGet(
      loading: 'forming_code_collection_getting'.tr,
      method: webApiGetWorkLineAnalysisReportNowNew,
      params: {
        'DeptmentID': getUserInfo()!.departmentID,
      },
    ).then((response) {
      if (response.resultCode == resultSuccess) {
        success.call(response.data);
      } else {
        errorDialog(content: response.message ?? 'query_default_error'.tr);
      }
    });
  }

  //线别分析报告
  getHistory() {
    httpGet(
      loading: 'forming_code_collection_getting'.tr,
      method: webApiGetDeptDistributeInfoNew,
      params: {
        'DeptmentID': getUserInfo()!.departmentID,
        'Date': '',
      },
    ).then((response) {
      if (response.resultCode == resultSuccess) {
        state.historyMes = response.data;
        getScanInfo();
      } else {
        showSnackBar(message: response.message ?? 'query_default_error'.tr);
      }
    });
  }

  //扫描信息
  getScanInfo() {
    httpGet(
      loading: 'forming_code_collection_getting'.tr,
      method: webApiGetDepartmentScanInfoNew,
      params: {
        'DeptmentID': getUserInfo()!.departmentID,
        'IsClosed': '-1',
      },
    ).then((response) {
      if (response.resultCode == resultSuccess) {
        state.scanInfoDataList.value = [
          for (var json in response.data) FormingScanInfo.fromJson(json)
        ];
        Get.to(() => const FormingBarcodeCollectionHistoryPage());
      } else {
        state.scanInfoDataList.value = [];
        showSnackBar(message: response.message ?? 'query_default_error'.tr);
      }
    });
  }

  //扫描信息
  getMoNoReport({required String commandNumber, required bool goPage}) {
    httpGet(
      loading: 'forming_code_collection_getting'.tr,
      method: webApiGetMoReportByMoNo,
      params: {
        'DeptmentID': getUserInfo()!.departmentID,
        'IsAutoGet': false,
        'billNO': commandNumber,
      },
    ).then((response) {
      if (response.resultCode == resultSuccess) {
        state.searchDetail.value = [
          for (var json in response.data) FormingMonoDetailInfo.fromJson(json)
        ];
        if (goPage) {
          Get.to(() => const FormingBarcodeCollectionSearchDetailPage());
        }
      } else {
        state.searchDetail.value = [];
        errorDialog(content: response.message ?? 'query_default_error'.tr);
      }
    });
  }

  //根据指令单号获得尺码数据
  getScMoSizeBarCodeByMONo({required String shoeBill}) {
    httpGet(
      loading: 'forming_code_collection_getting'.tr,
      method: webApiGetScMoSizeBarCodeByMONo,
      params: {
        'BillNO': shoeBill,
      },
    ).then((response) {
      if (response.resultCode == resultSuccess) {
        state.barCodeByMonoData.value = [
          for (var json in response.data)
            FormingBarcodeByMonoInfo.fromJson(json)
        ];
        if (state.barCodeByMonoData.isNotEmpty) {
          for (var data in state.barCodeByMonoData) {
            data.isSelect.value = false;
          }
          state.barCodeByMonoData[0].isSelect.value = true;
        }
      } else {
        state.barCodeByMonoData.value = [];
        errorDialog(content: response.message ?? 'query_default_error'.tr);
      }
    });
  }

  //验证是否存在条码
  bool haveCode(String code) {
    if (state.barCodeByMonoData.none((data) => data.barCode == code)) {
      return true;
    } else {
      showSnackBar(message: 'forming_code_collection_have_code'.tr);
      return false;
    }
  }

  //添加条码，然后选中下一条
  addCode({
    required String code,
    required bool click,
    required int position,
  }) {
    if (click) {
      state.barCodeByMonoData[position].barCode = code;
      for (var data in state.barCodeByMonoData) {
          data.isSelect.value = false;
      }
      state.barCodeByMonoData[position].isSelect.value = true;
    } else {
      var position = -1;
      state.barCodeByMonoData.forEachIndexed((i, data) {
        if (data.isSelect.value == true) {
          data.barCode = code;
          if ((i + 1) == state.barCodeByMonoData.length) {
            position = 0;
          } else {
            position = i + 1;
          }
        }
      });
      state.barCodeByMonoData.forEachIndexed((i, data) {
        if (i == position) {
          data.isSelect.value = true;
        } else {
          data.isSelect.value = false;
        }
      });
    }
    state.barCodeByMonoData.refresh();
  }

  //补零
  addZero() {
    if (state.btnName.value == '补零') {
      for (var data in state.barCodeByMonoData) {
        data.barCode = '0${data.barCode ?? ''}';
      }
      state.btnName.value = '清零';
    } else {
      for (var data in state.barCodeByMonoData) {
        data.barCode = data.barCode!.substring(1);
      }
      state.btnName.value = '补零';
    }
    state.barCodeByMonoData.refresh();
  }

  //清掉条形码
  clearCode() {
    for (var data in state.barCodeByMonoData) {
      data.barCode = '';
    }
    state.barCodeByMonoData.refresh();
  }

  //退出特殊条码匹配界面
  quitShoe() {
    state.barCodeByMonoData.clear();
    state.btnName.value = '补零';
  }

  //特殊条码匹配提交
  shoeSubmit({
    required Function(String) success,
  }) {
    httpPost(
      loading: 'forming_code_collection_submit_code'.tr,
      method: webApiSubmitScMoSizeBarCodeNew,
      body: {
        'DeptmentID': getUserInfo()!.departmentID,
        'List': [
          for (var i = 0; i < state.barCodeByMonoData.length; ++i)
            {
              'BarCode': state.barCodeByMonoData[i].barCode,
              'Size': state.barCodeByMonoData[i].size,
              'ColNo': state.barCodeByMonoData[i].colNo,
              'InterID': state.barCodeByMonoData[i].interID,
              'EntryID': state.barCodeByMonoData[i].entryID,
              'EntryType': state.barCodeByMonoData[i].entryType,
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
