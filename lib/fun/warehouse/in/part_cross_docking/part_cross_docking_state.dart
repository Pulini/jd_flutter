import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';
import 'package:jd_flutter/bean/http/response/bar_code.dart';
import 'package:jd_flutter/bean/http/response/check_code_info.dart';
import 'package:jd_flutter/bean/http/response/sap_picking_info.dart';
import 'package:jd_flutter/utils/utils.dart';
import 'package:jd_flutter/utils/web_api.dart';

class PartCrossDockingState {
  var barCodeList = <BarCodeInfo>[].obs; //条码数据
  var usedList = <String>[]; //入库过的条码数据
  var palletNumber = ''.obs; //托盘号
  PalletDetailItem2Info? pallet; //托盘信息

  PartCrossDockingState() {
    BarCodeInfo.getSave(
      type: BarCodeReportType.productionScanInStock.text,
      callback: (list) => barCodeList.value = list,
    );
  }

  void checkBarCodeReportState({
    required void Function(CheckCodeInfo, String) success,
    required void Function(String) error,
  }) {
    httpPost(
      method: webApiGetUnReportedBarCode,
      loading: 'part_cross_docking_checking_barcode'.tr,
      body: barCodeList
          .map((v) => {'BarCode': v.code, 'PalletNo': v.palletNo})
          .toList(),
    ).then((response) {
      if (response.resultCode == resultSuccess) {
        success.call(
            CheckCodeInfo.fromJson(response.data), response.message ?? '');
      } else {
        error.call(response.message ?? 'query_default_error'.tr);
      }
    });
  }

  void checkPallet({
    required List<String> pallets,
    required Function(PalletDetailInfo) success,
    required Function(String) error,
  }) {
    sapPost(
      loading: 'part_cross_docking_getting_pallet_info'.tr,
      method: webApiSapGetPalletList,
      body: {
        'WERKS': '2000',
        'LGORT':  userInfo?.defaultStockNumber,
        'ZTRAY_CFM': '',
        'ITEM': [
          for (var pallet in pallets)
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

  void submitBarCode({
    required String worker,
    required Function(String) success,
    required Function(String) error,
  }) {
    httpPost(
      loading: 'part_cross_docking_submitting'.tr,
      method: webApiSubmitBarCode2CrossDockingBill,
      body: {
        'BarCodeList': [
          for (var item in barCodeList.where((v) => !v.isUsed))
            {'BarCode': item.code, 'PalletNo': item.palletNo}
        ],
        'Red': 1,
        'EmpCode': worker,
        'DefaultStockID': userInfo?.defaultStockID,
        'TranTypeID': BarCodeReportType.productionScanInStock.value,
        'OrganizeID': userInfo?.organizeID,
        'UserID': userInfo?.userID,
      },
    ).then((response) {
      if (response.resultCode == resultSuccess) {
        success.call(response.data);
      } else {
        error.call(response.message ?? 'query_default_error'.tr);
      }
    });
  }
}
