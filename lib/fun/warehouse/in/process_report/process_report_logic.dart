import 'package:get/get.dart';
import 'package:jd_flutter/fun/warehouse/in/process_report/process_report_state.dart';
import 'package:jd_flutter/utils/utils.dart';
import '../../../../bean/http/response/bar_code.dart';
import '../../../../bean/http/response/sap_picking_info.dart';
import '../../../../utils/web_api.dart';
import '../../../../widget/custom_widget.dart';
import '../../../../widget/dialogs.dart';

class ProcessReportLogic extends GetxController {
  final ProcessReportState state = ProcessReportState();


  //添加条码
  scanCode(String code) {
    if (state.barCodeList.any((v) => v.code == code)) {
      showSnackBar( message: 'production_scan_hava_barcode'.tr, isWarning: true);
    } else {
      if (code.isPallet()) {
        checkPallet(
          pallets: [code],
          success: (data) {
            if (data.item2![0].palletExistence == 'X') {
              switch (data.item2![0].palletState) {
                case '':
                  state.pallet = data.item2![0];
                  state.palletNumber.value = code;
                  break;
                case 'X':
                  showSnackBar(
                      message: 'production_scan_use_empty_pallets'.tr, isWarning: true);
                  break;
                case 'Y':
                  showSnackBar(
                      message: 'production_scan_used_pallets'.tr, isWarning: true);
                  break;
              }
            } else {
              showSnackBar( message: 'production_scan_not_exist'.tr, isWarning: true);
            }
          },
          error: (msg) => errorDialog(content: msg),
        );
        return;
      }
      // BarCodeInfo(
      //   code: code,
      //   type: barCodeTypes[4],
      //   palletNo: state.palletNumber.value,
      // )
      //   ..isUsed = state.usedList.contains(code)
      // ..save(callback: (newBarCode) => state.barCodeList.add(newBarCode));
      //   ..save(callback: (newBarCode) {
      //     state.barCodeList.add(newBarCode);
      //   });
    }
  }


  //删除对应条码
  deleteCode(BarCodeInfo barCodeList) {
    barCodeList.deleteByCode(callback: () {
      state.barCodeList.remove(barCodeList);
    });
  }


  //验证托盘
  checkPallet({
    required List<String> pallets,
    required Function(PalletDetailInfo) success,
    required Function(String) error,
  }) {
    sapPost(
      loading: 'production_scan_obtaining_tray_information'.tr,
      method: webApiSapGetPalletList,
      body: {
        'WERKS': '1500',
        'LGORT': userInfo?.defaultStockNumber,
        'ZTRAY_CFM': 'X',
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

}