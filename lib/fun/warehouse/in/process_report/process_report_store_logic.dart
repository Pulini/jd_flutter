import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:jd_flutter/bean/http/response/scan_process_info.dart';
import 'package:jd_flutter/fun/warehouse/in/process_report/process_report_store_state.dart';
import 'package:jd_flutter/utils/utils.dart';
import '../../../../bean/http/response/bar_code.dart';
import '../../../../bean/http/response/process_modify_info.dart';
import '../../../../bean/http/response/sap_picking_info.dart';
import '../../../../bean/http/response/worker_info.dart';
import '../../../../utils/web_api.dart';
import '../../../../widget/custom_widget.dart';
import '../../../../widget/dialogs.dart';
import '../../code_list_report/code_list_report_view.dart';

class ProcessReportStoreLogic extends GetxController {
  final ProcessReportStoreState state = ProcessReportStoreState();

  var textNumber = TextEditingController(); //实际数量

  var inputNumber = [
    FilteringTextInputFormatter.allow(RegExp('[0-9]')),
  ];

  //添加条码
  scanCode(String code) {
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
        type: BarCodeReportType.processReportInStock.text,
      )
        ..palletNo = state.palletNumber.value
        ..isUsed = state.usedList.contains(code)
        ..save(callback: (newBarCode) {
          state.barCodeList.add(newBarCode);
        });
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

  //获得已入库条形码数据
  getBarCodeStatusByDepartmentID({
    required Function() refresh,
  }) {
    httpGet(method: webApiGetBarCodeStatusByDepartmentID, params: {
      'Type': BarCodeReportType.processReportInStock.text,
      'DepartmentID': getUserInfo()!.departmentID,
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
        refresh.call;
      }
    });
  }

  //提交工序汇报入库
  submit({
    required WorkerInfo worker,
    required BarCodeProcessInfo process,
  }) {
    state.getBarCodeStatus(
      processFlowID: process.processFlowID ?? 0,
      processName: process.processFlowName ?? '',
      success: (data) {
        for (var v in state.barCodeList) {
          if ((data.list2 ?? []).any((v2) => v2.barCode == v.code)) {
            v.isUsed = true;
          }
          ScanProcessReportSub1Info? item =
              data.list1?.firstWhereOrNull((v2) => v2.barCode == v.code);
          if (item != null) {
            v.department = item.name;
          }
        }
        if (state.barCodeList.every((v) => v.isUsed)) {
          errorDialog(content: 'process_report_store_no_barcode'.tr);
        } else {
          state.getBarCodeReport(
            processFlowID: process.processFlowID ?? 0,
            success: (report) {
              Get.to(
                () => const CodeListReportPage(),
                arguments: {'reportData': report},
              )?.then((v) {
                if (v != null) {
                  state.submitBarCode(
                    worker: worker,
                    process: process,
                    success: (msg) {
                      clearBarCodeList();
                      successDialog(content: msg);
                    },
                    error: (msg) => errorDialog(content: msg),
                  );
                }
              });
            },
            error: (msg) => errorDialog(content: msg),
          );
        }
      },
      error: (msg) => errorDialog(content: msg),
    );
  }

  //清空条码
  clearBarCodeList() {
    BarCodeInfo.clear(
      type: BarCodeReportType.processReportInStock.text,
      callback: (v) {
        if (v == state.barCodeList.length) {
          state.barCodeList.clear();
        } else {
          showSnackBar(
            message: 'process_report_store_delete_failed'.tr,
            isWarning: true,
          );
        }
      },
    );
  }

  //清理展示的内容
  clearModifyList() {
    state.modifyList.clear();
  }

  //  输入数量
  showInputDialog({
    required String title,
    Function(String)? confirm,
    Function()? cancel,
  }) {
    Get.dialog(
      PopScope(
        //拦截返回键
        canPop: false,
        child: AlertDialog(
          title: Text(title,
              style: const TextStyle(
                  color: Colors.black, fontWeight: FontWeight.bold)),
          content: CupertinoTextField(
            inputFormatters: inputNumber,
            controller: textNumber,
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                if (textNumber.text.toString().isEmpty) {
                  showSnackBar(
                      message: 'process_report_store_modify_input_real_number'.tr);
                } else {
                  Get.back();
                  confirm?.call(textNumber.text.toString());
                }
              },
              child: Text('dialog_default_confirm'.tr),
            ),
            TextButton(
              onPressed: () {
                Get.back();
                cancel?.call();
              },
              child: Text(
                'dialog_default_cancel'.tr,
                style: const TextStyle(color: Colors.grey),
              ),
            ),
          ],
        ),
      ),
      barrierDismissible: false, //拦截dialog外部点击
    );
  }

  //获取工序汇报入库的条码信息
  modifyAdd(String code) {
    if(code.isNotEmpty){
      httpPost(
        method: webApiGetBarCodeInfo,
        loading: 'process_report_store_modify_reading_database'.tr,
        body: {
          'BarCodeList': [code],
        },
      ).then((response) {
        if (response.resultCode == resultSuccess) {
          var list = <ProcessModifyInfo>[
            for (var i = 0; i < response.data.length; ++i)
              ProcessModifyInfo.fromJson(response.data[i])
          ];

          state.modifyList.value = list;
        } else {
          errorDialog(content: response.message);
        }
      });
    }else{
      showSnackBar(message: 'process_report_store_modify_scan_real_barcode'.tr);
    }
  }

  //工序汇报入库，提交贴标数据
  updateBarCodeInfo({
    String? code,
    required Function(String) success,
  }) {
    httpPost(
      method: webApiUpdateBarCodeInfo,
      loading: 'process_report_store_modify_reading_database'.tr,
      body: {
        [
          for (var i = 0; i < state.modifyList.length; ++i)
            {
              'BarCode': state.modifyList[i].barCode,
              'Size': state.modifyList[i].size,
              'MustQty': state.modifyList[i].mustQty,
              'Qty': state.modifyList[i].qty,
            }
        ]
      },
    ).then((response) {
      if (response.resultCode == resultSuccess) {
        success.call(response.message ?? '');
      } else {
        errorDialog(content: response.message);
      }
    });
  }

  setModifyList(String realQty, ProcessModifyInfo data) {
    for (var i = 0; i < state.modifyList.length; ++i) {
      if (state.modifyList[i].barCode == data.barCode) {
        state.modifyList[i].qty = realQty;
      }
    }
  }
}
