import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:jd_flutter/bean/http/response/base_data.dart';
import 'package:jd_flutter/bean/http/response/sap_picking_info.dart';
import 'package:jd_flutter/utils/web_api.dart';


class SapStockTransferState {
  var labelList = <PalletDetailItem1Info>[].obs;
  var palletNumber = ''.obs;
  var location = ''.obs;
  PalletDetailItem2Info? newPallet;
  PalletDetailItem2Info? targetPallet;



  void checkPallet({
    String? palletNo,
    String? labelNo,
    String? targetPalletNo,
    required String warehouse,
    required Function(String) error,
  }) {
    sapPost(
      loading: 'sap_stock_transfer_getting_wait_put_on_list_tips'.tr,
      method: webApiSapGetPalletList,
      body: {
        'WERKS':  isTestUrl()?'2000':'1500',
        'LGORT': warehouse,
        'ZTRAY_CFM': targetPalletNo?.isNotEmpty == true ? 'X' : '',
        'ITEM': [
          {
            'ZLOCAL': '',
            'ZFTRAYNO': targetPalletNo?.isNotEmpty == true
                ? targetPalletNo
                : palletNo ?? '',
            'BQID': labelNo ?? '',
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
        compute(
          parseJsonToData<PalletDetailInfo>,
          ParseJsonParams(response.data, PalletDetailInfo.fromJson),
        ).then((pallet) {
          if (targetPalletNo?.isNotEmpty == true) {
            if (pallet.item2?[0].palletExistence == 'X') {
              newPallet = null;
              targetPallet = null;
              location.value = pallet.item2?[0].location ?? '';
              switch (pallet.item2?[0].palletState) {
                case '':
                  newPallet = pallet.item2?[0];
                  break;
                case 'X':
                  targetPallet = pallet.item2?[0];
                  break;
                case 'Y':
                  error.call('sap_stock_transfer_pallet_already_occupied_tips'.tr);
                  break;
              }
            } else {
              error.call('sap_stock_transfer_pallet_not_exists_tips'.tr);
            }
          } else {
            labelList.value = pallet.item1 ?? [];
          }
        });
      } else {
        error.call(response.message ?? 'query_default_error'.tr);
      }
    });
  }

  void transferToLocation({
    required String warehouse,
    required String locationOrPalletNumber,
    required Function(String) success,
    required Function(String) error,
  }) {
    _submitTransfer(
      tLocation: locationOrPalletNumber,
      tPallet: labelList[0].palletNumber ?? '',
      warehouse: warehouse,
      list: labelList,
      success: success,
      error: error,
    );
  }

  void transferToTargetPallet({
    required String warehouse,
    required List<PalletDetailItem1Info> list,
    required Function(String) success,
    required Function(String) error,
  }) {
    _submitTransfer(
      tLocation: targetPallet?.location??'',
      tPallet: targetPallet?.palletNumber ?? '',
      warehouse: warehouse,
      list: list,
      success: success,
      error: error,
    );
  }
  void transferToNewPallet({
    required String warehouse,
    required String tLocation,
    required List<PalletDetailItem1Info> list,
    required Function(String) success,
    required Function(String) error,
  }) {
    _submitTransfer(
      tLocation: tLocation,
      tPallet: newPallet?.palletNumber ?? '',
      warehouse: warehouse,
      list: list,
      success: success,
      error: error,
    );
  }

  //移库模式
  // 1、托盘A移动全部货物到新库位      (有原托盘号 有原库位 扫描新库)
  // 2、托盘A移动部分货物至托盘B      (有原托盘号 有原库位 扫描目标托盘 获取目标托盘库位  获取目标托盘)
  // 3、托盘A移动部分货物至新托盘      (有原托盘号 有原库位 扫描目标托盘  获取托盘号 扫描目标库位  获取新库位)
  void _submitTransfer({
    required String tLocation,
    required String tPallet,
    required String warehouse,
    required List<PalletDetailItem1Info> list,
    required Function(String) success,
    required Function(String) error,
  }) {
    sapPost(
      loading: 'sap_stock_transfer_submitting_put_on_tips'.tr,
      method: webApiSapPuttingOnShelves,
      body: {
        'ZCZLX_WMS': 'WM03',
        'WERKS':  isTestUrl()?'2000':'1500',
        'LGORT': warehouse,
        'ITEM': [
          for (var item in list)
            {
              'ZSHKZG': '',
              'ZLOCAL_F': item.location,
              'ZLOCAL_T': tLocation,
              'ZFTRAYNO_F': item.palletNumber,
              'ZFTRAYNO_T': tPallet,
              'BQID': item.labelNumber,
              'MATNR': item.sizeMaterialNumber,
              'CHARG': item.batch,
              'SOBKZ': item.salesOrderNo?.isNotEmpty == true ? 'E' : '',
              'KDAUF': item.salesOrderNo,
              'KDPOS': item.salesOrderLineItem,
              'ZZVBELN': item.instructionNo,
              'ZZXTNO': item.typeBody,
              'SIZE1': item.size,
              'MENGE': item.quantity,
              'MEINS': item.unit,
            }
        ]
      },
    ).then((response) {
      if (response.resultCode == resultSuccess) {
        palletNumber.value = '';
        targetPallet = null;
        newPallet = null;
        labelList.value = [];
        success.call(response.message ?? '');
      } else {
        error.call(response.message ?? 'query_default_error'.tr);
      }
    });
  }
}
