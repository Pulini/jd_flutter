import 'package:get/get.dart';
import 'package:jd_flutter/bean/http/response/bar_code.dart';
import 'package:jd_flutter/bean/http/response/sap_picking_info.dart';
import 'package:jd_flutter/fun/warehouse/code_list_report/code_list_report_view.dart';
import 'package:jd_flutter/fun/warehouse/in/suppliers_scan_store/suppliers_scan_store_state.dart';
import 'package:jd_flutter/route.dart';
import 'package:jd_flutter/utils/utils.dart';
import 'package:jd_flutter/utils/web_api.dart';
import 'package:jd_flutter/widget/custom_widget.dart';
import 'package:jd_flutter/widget/dialogs.dart';
import 'package:jd_flutter/widget/picker/picker_controller.dart';

class SuppliersScanStoreLogic extends GetxController {
  final SuppliersScanStoreState state = SuppliersScanStoreState();

  //仓库选择器
  var billStockListController = OptionsPickerController(
    PickerType.mesBillStockList,
    saveKey:
        '${RouteConfig.suppliersScanStore.name}${PickerType.mesBillStockList}',
  );

  //日期选择器的控制器
  var orderDate = DatePickerController(
    buttonName: 'suppliers_scan_select_posting_date'.tr,
    PickerType.endDate,
    saveKey: '${RouteConfig.suppliersScanStore.name}${PickerType.endDate}',
  );

  //清空供应商扫码入库的条码
  clearBarCodeList() {
    BarCodeInfo.clear(
      type: BarCodeReportType.supplierScanInStock.text,
      callback: (v) {
        if (v == state.barCodeList.length) {
          state.barCodeList.clear();
        } else {
          showSnackBar(message: 'suppliers_scan_delete_error'.tr, isWarning: true);
        }
      },
    );
  }

  //添加条码
  scanCode(String code) {
    if (state.barCodeList.any((v) => v.code == code)) {
      showSnackBar(message: 'suppliers_scan_have_code'.tr, isWarning: true);
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
                  showSnackBar(message: 'suppliers_scan_use_empty_pallets'.tr, isWarning: true);
                  break;
                case 'Y':
                  showSnackBar(message: 'suppliers_scan_use_other'.tr, isWarning: true);
                  break;
              }
            } else {
              showSnackBar(message: 'suppliers_scan_does_not_exist'.tr, isWarning: true);
            }
          },
          error: (msg) => errorDialog(content: msg),
        );
        return;
      }
      BarCodeInfo(
        code: code,
        type: BarCodeReportType.supplierScanInStock.text,
      )
        ..palletNo = state.palletNumber.value
        ..isUsed = state.usedList.contains(code)
        ..save(callback: (newBarCode) => state.barCodeList.add(newBarCode));
    }
  }

  bool haveCodeData() {
    if (state.barCodeList.isNotEmpty) {
      return true;
    } else {
      return false;
    }
  }

  //删除对应条码
  deleteCode(BarCodeInfo barCodeList) {
    barCodeList.deleteByCode(callback: () {
      state.barCodeList.remove(barCodeList);
    });
  }

  goReport() {
    if (state.barCodeList.isNotEmpty) {
      httpPost(
        method: webApiNewGetSubmitBarCodeReport,
        loading: 'suppliers_scan_get_summary'.tr,
        body: {
          'BarCodeList': [
            for (var i = 0; i < state.barCodeList.length; ++i)
              {
                'BarCode': state.barCodeList[i].code,
                'PalletNo': state.barCodeList[i].palletNo,
              }
          ],
          'BillTypeID': BarCodeReportType.supplierScanInStock.value,
          'Red': state.red.value ? 1 : -1,
          'ProcessFlowID': 0,
          'OrganizeID': userInfo?.organizeID,
          'DefaultStockID': userInfo?.defaultStockID,
          'UserID': userInfo?.userID,
        },
      ).then((response) {
        if (response.resultCode == resultSuccess) {
          Get.to(() => const CodeListReportPage(),
              arguments: {'reportData': response.data})?.then((v) {
            if (v == null) {
              state.peopleNumber.text = '';
              state.peopleName.value = '';
              showSnackBar(title: 'dialog_default_title_information'.tr, message: 'suppliers_scan_not_completed'.tr);
            } else if (v == true) {
              submitCode();
            }
          });
        } else {
          errorDialog(content: response.message);
        }
      });
    } else {
      showSnackBar(title: 'shack_bar_warm'.tr, message: 'suppliers_scan_no_barcode_to_submit'.tr);
    }
  }

  //验证托盘
  checkPallet({
    required List<String> pallets,
    required Function(PalletDetailInfo) success,
    required Function(String) error,
  }) {
    sapPost(
      loading: 'suppliers_scan_obtaining_tray_information'.tr,
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

  //检查工号是否合法
  checkOrderInfo({
    String? number,
  }) {
    httpGet(method: webApiJudgeEmpNumber, params: {
      'EmpNumber': number,
    }).then((response) {
      if (response.resultCode == resultSuccess) {
        state.peopleNumber.text = number.toString();
        state.peopleName.value = response.data;
      } else {
        state.peopleName.value = '';
      }
    });
  }

  //获得已入库条形码数据
  getBarCodeStatusByDepartmentID({
    required Function() refresh,
  }) {
    httpGet(method: webApiGetBarCodeStatusByDepartmentID, params: {
      'Type': "SupplierScanInStock",
      'DepartmentID': userInfo?.departmentID,
    }).then((response) {
      if (response.resultCode == resultSuccess) {
        state.usedList.clear();
        var list = <UsedBarCodeInfo>[
          for (var i = 0; i < response.data.length; ++i)
            UsedBarCodeInfo.fromJson(response.data[i])
        ];

        for (var i = 0; i < list.length; ++i) {
          state.usedList.add(list[i].barCode.toString());
        }

        for (var data in state.barCodeList) {
          data.isUsed = state.usedList.contains(data.code);
        }
        refresh.call();
      } else {
        showSnackBar(title: 'dialog_default_title_information'.tr, message: response.message ?? '');
        refresh.call();
      }
    });
  }

  //提交条形码数据,自动生成外购入库单
  submitCode() {
    httpPost(method: webApiUploadSupplierBarCode, body: {
      'BarCodeList': [
        for (var i = 0; i < state.barCodeList.length; ++i)
          {
            'BarCode': state.barCodeList[i].code,
            'PalletNo': state.barCodeList[i].palletNo,
          }
      ],
      'PostingDate': orderDate.getDateFormatSapYMD(),
      'Red': state.red.value ? -1 : 1,
      'EmpCode': state.peopleNumber.text.toString(),
      'DefaultStockID': billStockListController.selectedId.value,
      'TranTypeID': BarCodeReportType.supplierScanInStock.value,
      'OrganizeID': userInfo?.organizeID,
      'UserID': userInfo?.userID,
    }).then((response) {
      if (response.resultCode == resultSuccess) {
        clearBarCodeList();
        successDialog(
            content: response.message,
            back: () => getBarCodeStatusByDepartmentID(refresh: () {}));
      } else {
        showSnackBar(title: 'dialog_default_title_information'.tr, message: response.message ?? '');
      }
    });
  }
}
