import 'package:get/get.dart';
import 'package:jd_flutter/bean/http/response/bar_code.dart';
import 'package:jd_flutter/bean/http/response/check_code_info.dart';
import 'package:jd_flutter/bean/http/response/sap_picking_info.dart';
import 'package:jd_flutter/fun/warehouse/code_list_report/code_list_report_view.dart';
import 'package:jd_flutter/fun/warehouse/in/production_scan_warehouse/production_scan_warehouse_state.dart';
import 'package:jd_flutter/utils/extension_util.dart';
import 'package:jd_flutter/utils/utils.dart';
import 'package:jd_flutter/utils/web_api.dart';
import 'package:jd_flutter/widget/custom_widget.dart';
import 'package:jd_flutter/widget/dialogs.dart';

class ProductionScanWarehouseLogic extends GetxController {
  final ProductionScanWarehouseState state = ProductionScanWarehouseState();

  //添加条码
  void scanCode(String code) {
    if (state.barCodeList.any((v) => v.code == code)) {
      showSnackBar(message: 'production_scan_hava_barcode'.tr, isWarning: true);
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
                      message: 'production_scan_use_empty_pallets'.tr,
                      isWarning: true);
                  break;
                case 'Y':
                  showSnackBar(
                      message: 'production_scan_used_pallets'.tr,
                      isWarning: true);
                  break;
              }
            } else {
              showSnackBar(
                  message: 'production_scan_not_exist'.tr, isWarning: true);
            }
          },
          error: (msg) => errorDialog(content: msg),
        );
        return;
      }
      BarCodeInfo(
        code: code,
        type: BarCodeReportType.productionScanInStock.text,
      )
        ..palletNo = state.palletNumber.value
        ..isUsed = state.usedList.contains(code)
        ..save(callback: (newBarCode) {
          state.barCodeList.add(newBarCode);
        });
    }
  }

  //获得已入库条形码数据
  void getBarCodeStatusByDepartmentID({
    required Function() refresh,
  }) {
    httpGet(method: webApiGetBarCodeStatusByDepartmentID, params: {
      'Type': BarCodeReportType.productionScanInStock.text,
      'DepartmentID': userInfo?.departmentID,
    }).then((response) {
      if (response.resultCode == resultSuccess) {
        state.usedList.cast();
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
        refresh.call();
        showSnackBar(
            title: 'dialog_default_title_information'.tr,
            message: response.message ?? '');
      }
    });
  }

  //验证托盘
  void checkPallet({
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

  //检查工号是否合法
  void checkOrderInfo({
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

  //删除对应条码
  void deleteCode(BarCodeInfo barCodeList) {
    barCodeList.deleteByCode(callback: () {
      state.barCodeList.remove(barCodeList);
    });
  }

  //清空生产扫码入库的条码
  void clearBarCodeList() {
    BarCodeInfo.clear(
      type: BarCodeReportType.productionScanInStock.text,
      callback: (v) {
        if (v == state.barCodeList.length) {
          state.barCodeList.clear();
        } else {
          showSnackBar(
              message: 'production_scan_delete_failed'.tr, isWarning: true);
        }
      },
    );
  }

  //获取汇总表
  void goReport() {
    if (state.barCodeList.isNotEmpty) {
      httpPost(
        method: webApiNewGetSubmitBarCodeReport,
        loading: 'warehouse_allocation_summary_information'.tr,
        body: {
          'BarCodeList': [
            for (var i = 0; i < state.barCodeList.length; ++i)
              {
                'BarCode': state.barCodeList[i].code,
                'PalletNo': state.barCodeList[i].palletNo,
              }
          ],
          'BillTypeID': BarCodeReportType.productionScanInStock.value,
          'Red': state.red.value ? 1 : -1,
          'ProcessFlowID': 0,
          'OrganizeID': userInfo?.organizeID,
          'DefaultStockID': userInfo?.defaultStockID,
          'UserID': userInfo?.userID,
          'EmpID': userInfo?.empID,
        },
      ).then((response) {
        if (response.resultCode == resultSuccess) {
          Get.to(() => const CodeListReportPage(),
              arguments: {'reportData': response.data})?.then((v) {
            if (v == null) {
              state.peopleNumber.text = '';
              state.peopleName.value = '';
              showSnackBar(
                  title: 'dialog_default_title_information'.tr,
                  message: '检查未完成');
            } else if (v == true) {
              submitCode();
            }
          });
        } else {
          errorDialog(content: response.message);
        }
      });
    } else {
      showSnackBar(
          title: 'shack_bar_warm'.tr,
          message: 'production_scan_not_barcode'.tr);
    }
  }

  //验证是否有条码
  bool haveCodeData() {
    if (state.barCodeList.isNotEmpty) {
      return true;
    } else {
      return false;
    }
  }

  //验证生产扫码入库的数据
  void checkCodeList({
    required Function(String) checkBack,
    required Function(String) success,
  }) {
    if (state.barCodeList.isNotEmpty) {
      httpPost(
        method: webApiGetUnReportedBarCode,
        loading: 'production_scan_verification_barcode'.tr,
        body: [
          for (var i = 0; i < state.barCodeList.length; ++i)
            {
              'BarCode': state.barCodeList[i].code,
              'PalletNo': state.barCodeList[i].palletNo,
            }
        ],
      ).then((response) {
        if (response.resultCode == resultSuccess) {
          var message = '';
          var codeList = <String>[];
          var checkCodeInfo = CheckCodeInfo.fromJson(response.data);
          checkCodeInfo.items?.forEach((v) {
            codeList.add(v.barCode.toString()); //添加大标
            v.normalBarCodeList?.forEach((a) {
              codeList.add(a); //添加小标
            });
          });

          for (var barCode in state.barCodeList) {
            for (var used in codeList) {
              if (barCode.code == used) {
                barCode.isHave = true;
                message += '$used,\n';
              }
            }
          }
          state.barCodeList.refresh();
          if (message.isNotEmpty) {
            checkBack.call(message);
          } else {
            success.call(response.message!);
          }
        } else {
          success.call(response.message!);
        }
      });
    } else {
      showSnackBar(
          title: 'shack_bar_warm'.tr,
          message: 'production_scan_not_barcode'.tr);
    }
  }

  //生产扫码入库的提交
  void submitCode() {
    httpPost(method: webApiUploadProductionScanning, loading: '正在提交...', body: {
      'BarCodeList': [
        for (var i = 0; i < state.barCodeList.length; ++i)
          if (!state.barCodeList[i].isUsed == true)
            {
              'BarCode': state.barCodeList[i].code,
              'PalletNo': state.barCodeList[i].palletNo,
            }
      ],
      'Red': state.red.value ? -1 : 1,
      'EmpCode': state.peopleNumber.text.toString(),
      'DefaultStockID': userInfo?.defaultStockID,
      'TranTypeID': '106',
      'OrganizeID': userInfo?.organizeID,
      'UserID': userInfo?.userID,
    }).then((response) {
      if (response.resultCode == resultSuccess) {
        clearBarCodeList();
        successDialog(
            content: response.message,
            back: () => getBarCodeStatusByDepartmentID(refresh: () {}));
      } else {
        showSnackBar(
            title: 'dialog_default_title_information'.tr,
            message: response.message ?? '');
      }
    });
  }
}
