import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:jd_flutter/bean/http/response/bar_code.dart';
import 'package:jd_flutter/bean/http/response/sap_picking_info.dart';
import 'package:jd_flutter/utils/utils.dart';
import 'package:jd_flutter/utils/web_api.dart';

class SuppliersScanStoreState {
  var barCodeList = <BarCodeInfo>[].obs; //条码数据
  var usedBarCodeList = <UsedBarCodeInfo>[].obs; //入库过的条码数据
  PalletDetailItem2Info? pallet;
  var palletNumber = ''.obs; //托盘号
  var peopleName = ''.obs; //员工名字
  var usedList = <String>[];
  var red = false.obs;

  var peopleNumber = TextEditingController(); //员工工号

  //从数据库读取条码信息
  SuppliersScanStoreState() {
    BarCodeInfo.getSave(
      type: BarCodeReportType.supplierScanInStock.text,
      callback: (list) => barCodeList.value = list,
    );
  }

  void goReport({
    required Function(dynamic) success,
    required Function(String) error,
  }) {
    httpPost(
      method: webApiNewGetSubmitBarCodeReport,
      loading: 'suppliers_scan_get_summary'.tr,
      body: {
        'BarCodeList': [
          for (var i = 0; i < barCodeList.length; ++i)
            {
              'BarCode': barCodeList[i].code,
              'PalletNo': barCodeList[i].palletNo,
            }
        ],
        'BillTypeID': BarCodeReportType.supplierScanInStock.value,
        'Red': red.value ? 1 : -1,
        'ProcessFlowID': 0,
        'ProcessNodeName': '',
        'OrganizeID': userInfo?.organizeID,
        'DefaultStockID': userInfo?.defaultStockID,
        'UserID': userInfo?.userID,
      },
    ).then((response) {
      if (response.resultCode == resultSuccess) {
        success.call(response.data);
      } else {
        error.call(response.message ?? '');
      }
    });
  }

  //验证托盘
  void checkPallet({
    required String pallet,
    required Function(PalletDetailInfo) success,
    required Function(String) error,
  }) {
    sapPost(
      loading: 'suppliers_scan_obtaining_tray_information'.tr,
      method: webApiSapGetPalletList,
      body: {
        'WERKS': '2000',
        'LGORT': userInfo?.defaultStockNumber,
        'ZTRAY_CFM': 'X',
        'ITEM': [
          {
            'ZLOCAL': '',
            'ZFTRAYNO': pallet,
            'BQID': '',
            'SATNR': '',
            'MATNR': '',
            'SIZE1': '',
            'ZVBELN_ORI': '',
            'KDAUF': '',
          }
        ]
      },
    ).then((response) {
      if (response.resultCode == resultSuccess) {
        success.call(PalletDetailInfo.fromJson(response.data));
      } else {
        error.call(response.message ?? 'query_default_error'.tr);
      }
    });
  }

  //检查工号是否合法
  void checkWorker(String number) {
    httpGet(
      method: webApiJudgeEmpNumber,
      params: {'EmpNumber': number},
    ).then((response) {
      if (response.resultCode == resultSuccess) {
        peopleNumber.text = number.toString();
        peopleName.value = response.data;
      } else {
        peopleName.value = '';
      }
    });
  }

  //获得已入库条形码数据
  void getUsedBarCode({
    required Function(List<UsedBarCodeInfo>) success,
    required Function(String) error,
  }) {
    httpGet(method: webApiGetBarCodeStatusByDepartmentID, params: {
      'Type': BarCodeReportType.supplierScanInStock.text,
      'DepartmentID': userInfo?.departmentID,
    }).then((response) {
      if (response.resultCode == resultSuccess) {
        success.call([
          for (var i = 0; i < response.data.length; ++i)
            UsedBarCodeInfo.fromJson(response.data[i])
        ]);
      } else {
        error.call(response.message ?? '');
      }
    });
  }

  //提交条形码数据,自动生成外购入库单
  void submitCode({
    required String postingDate,
    required String stockID,
    required Function(String) success,
    required Function(String) error,
}) {
    httpPost(
        loading: 'suppliers_scan_submitting'.tr,
        method: webApiUploadSupplierBarCode,
        body: {
          'BarCodeList': [
            for (var i = 0; i < barCodeList.length; ++i)
              {
                'BarCode': barCodeList[i].code,
                'PalletNo': barCodeList[i].palletNo,
              }
          ],
          'PostingDate': postingDate,
          'Red': red.value ? -1 : 1,
          'EmpCode': peopleNumber.text.toString(),
          'DefaultStockID': stockID,
          'TranTypeID': BarCodeReportType.supplierScanInStock.value,
          'OrganizeID': userInfo?.organizeID,
          'UserID': userInfo?.userID,
        }).then((response) {
      if (response.resultCode == resultSuccess) {
        success.call(response.message??'');
      } else {
        error.call(response.message??'');
      }
    });
  }
}
