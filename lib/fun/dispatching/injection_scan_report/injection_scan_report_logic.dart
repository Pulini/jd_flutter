import 'package:collection/collection.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:jd_flutter/bean/http/response/process_plan_detail_info.dart';
import 'package:jd_flutter/bean/http/response/process_plan_info.dart';
import 'package:jd_flutter/bean/http/response/show_process_barcode_info.dart';
import 'package:jd_flutter/bean/http/response/show_process_plan_detail_info.dart';
import 'package:jd_flutter/bean/http/response/stock_in_barcode_info.dart';
import 'package:jd_flutter/utils/utils.dart';

import '../../../utils/web_api.dart';
import '../../../widget/custom_widget.dart';
import '../../../widget/dialogs.dart';
import 'injection_scan_report_state.dart';

class InjectionScanReportLogic extends GetxController {
  final InjectionScanReportState state = InjectionScanReportState();

  var textNumber = TextEditingController(); //当班尾数

  var inputNumber = [
    FilteringTextInputFormatter.allow(RegExp('[0-9]')),
  ];

  getScWorkCardList() {
    httpGet(
      method: webApiGetScWorkCardList,
      loading: 'injection_scan_getting_process_plan'.tr,
      params: {"DispatchingMachine": getUserInfo()!.number},
    ).then((response) {
      if (response.resultCode == resultSuccess) {
        var list = <ProcessPlanInfo>[
          for (var i = 0; i < response.data.length; ++i)
            ProcessPlanInfo.fromJson(response.data[i])
        ];
        if (list.isNotEmpty) {
          if (list.length == 1) {
            state.dispatchNumber.value = list[0].dispatchNumber.toString();
            getScWorkCardDetail(
                dispatchNumber: list[0].dispatchNumber.toString());
          } else {
            //创建选择器控制器
            var controller = FixedExtentScrollController(
              initialItem: 0,
            );
            //创建取消按钮
            var cancel = TextButton(
              onPressed: () {
                Get.back();
              },
              child: Text(
                'dialog_default_cancel'.tr,
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 20,
                ),
              ),
            );
            //创建确认按钮
            var confirm = TextButton(
              onPressed: () {
                Get.back();
                getScWorkCardDetail(
                    dispatchNumber: list[controller.selectedItem]
                        .dispatchNumber
                        .toString());
                // list[controller.selectedItem]
              },
              child: Text(
                'dialog_default_confirm'.tr,
                style: const TextStyle(
                  color: Colors.blueAccent,
                  fontSize: 20,
                ),
              ),
            );
            //创建底部弹窗
            showPopup(Column(
              children: <Widget>[
                //选择器顶部按钮
                Container(
                  height: 45,
                  color: Colors.grey[200],
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [cancel, confirm],
                  ),
                ),
                //选择器主体
                Expanded(
                  child: getCupertinoPicker(
                    list.map((data) {
                      return Center(
                          child: Text("${data.shift}/${data.materialName}"));
                    }).toList(),
                    controller,
                  ),
                )
              ],
            ));
          }
        }
      } else {
        errorDialog(content: response.message);
      }
    });
  }

  getScWorkCardDetail({required String dispatchNumber}) {
      if(state.dispatchNumber.value.isEmpty){
        getScWorkCardList();
      }else{
        httpGet(
            method: webApiGetScWorkCardDetailJinZhen,
            loading: 'injection_scan_getting_process_plan_detail'.tr,
            params: {
              'DispatchingMachine': '',
              'DispatchNumber': dispatchNumber,
            }).then((response) {
          if (response.resultCode == resultSuccess) {
            state.dataBean = ProcessPlanDetailInfo.fromJson(response.data);
            arrangeData(ProcessPlanDetailInfo.fromJson(response.data));
          } else {
            state.dataBean = ProcessPlanDetailInfo();
            errorDialog(content: response.message);
          }
        });
      }
  }

  arrangeData(ProcessPlanDetailInfo data) {
    state.machine.value = data.machine!;
    state.factoryType.value = data.factoryType!;

    var list = <ShowProcessPlanDetailInfo>[];
    var allLastMantissa = 0.0;
    var allMantissa = 0.0;
    var allQtyNumber = 0.0;
    var allBox = 0.0;
    var allCapacity = 0.0;

    if (data.items!.isNotEmpty) {
      for (var i = 0; i < data.items!.length; ++i) {
        allLastMantissa += data.items![i].lastNotFullQty!;
        allMantissa += data.items![i].notFullQty!;
        allQtyNumber += data.items![i].boxesQty
            .toString()
            .toDoubleTry()
            .mul(data.items![i].capacity.toString().toDoubleTry())
            .add(data.items![i].notFullQty.toString().toDoubleTry())
            .sub(data.items![i].lastNotFullQty.toString().toDoubleTry());
        allBox += data.items![i].boxesQty!;
        allCapacity += data.items![i].capacity!;

        list.add(ShowProcessPlanDetailInfo(
          interID: data.interID,
          entryID: data.items?[i].entryID,
          dispatchNumber: data.dispatchNumber,
          machine: data.machine,
          factoryType: data.factoryType,
          size: data.items?[i].size,
          lastMantissa: data.items?[i].lastNotFullQty,
          mantissa: data.items?[i].notFullQty,
          allQty: data.items![i].boxesQty
              .toString()
              .toDoubleTry()
              .mul(data.items![i].capacity.toString().toDoubleTry())
              .add(data.items![i].notFullQty.toString().toDoubleTry())
              .sub(data.items![i].lastNotFullQty.toString().toDoubleTry()),
          box: data.items?[i].boxesQty.toString().toIntTry(),
          maxBox: 0,
          capacity: data.items?[i].capacity,
          processFlow: data.processflow,
          bUoM: data.items?[i].bUoM,
          confirmCurrentWorkingHours: data.items?[i].confirmCurrentWorkingHours,
          workingHoursUnit: data.items?[i].workingHoursUnit,
        ));
      }
    }

    list.add(
      ShowProcessPlanDetailInfo(
        interID: data.interID,
        dispatchNumber: data.dispatchNumber,
        machine: data.machine,
        factoryType: data.factoryType,
        size: '合计',
        lastMantissa: allLastMantissa,
        mantissa: allMantissa,
        allQty: allQtyNumber,
        box: allBox.toString().toIntTry(),
        capacity: allCapacity,
      ),
    );

    state.showDataList.value = list;
    getBarCodeStatus();
  }

  getBarCodeStatus() {
    if (state.dispatchNumber.value.isEmpty) {
      showSnackBar(message: 'injection_scan_first_query_detail'.tr);
    } else {
      sapPost(
        method: webApiForSAPGetStockInBarCodeList,
        loading: 'injection_scan_reading_label_data'.tr,
        body: [
          {
            'ZBQLX': 10,
            'ZBQZT': 20,
            'DISPATCH_NO': state.dispatchNumber.value,
          }
        ],
      ).then((response) {
        if (response.resultCode == resultSuccess) {
          var list = <StockInBarcodeInfo>[
            for (var i = 0; i < response.data.length; ++i)
              StockInBarcodeInfo.fromJson(response.data[i])
          ];

          var barCodeList = <ShowProcessBarcodeInfo>[]; //已入库的贴标列表

          for (var v in list) {
            v.item?.forEach((c) {
              barCodeList.add(
                ShowProcessBarcodeInfo(
                  barCode: c.subBarcode,
                  size: c.size,
                  dispatchNo: v.dispatchNo,
                  qty: c.qty,
                  num: v.num,
                  unit: c.unit,
                ),
              );
            });
          }

          state.showBarCodeList.value = barCodeList;
          setShowDataList(barCodeList);
        } else {
          state.showBarCodeList.value = [];
          errorDialog(content: response.message);
        }
      });
    }
  }

  //设置显示数据
  setShowDataList(List<ShowProcessBarcodeInfo> data) {
    for (var showData in state.showDataList) {
      showData.maxBox = 0;
    }

    for (var v in data) {
      for (var c in state.showDataList) {
        if (v.size == c.size) {
          c.maxBox = c.maxBox + 1;
        }
      }
    }

    for (var c in state.showBarCodeList) {
      state.dataBean.barCodeList?.forEach((v) {
        if (c.barCode == v) {
          //用派工单扫过的标跟SAP的标进行对比，打上扫描标识
          c.use = true;
        }
      });
    }
    state.showBarCodeList.refresh();
  }

  //  当班尾数
  showInputDialog({
    required ShowProcessPlanDetailInfo clickData,
    required String title,
    Function(String, ShowProcessPlanDetailInfo)? confirm,
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
                  showSnackBar(message: 'injection_scan_input_number'.tr);
                } else {
                  Get.back();
                  confirm?.call(textNumber.text.toString(), clickData);
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

  setSizeNumber(String lastNum, ShowProcessPlanDetailInfo data) {
    for (var i = 0; i < state.showDataList.length; ++i) {
      if (data.size == state.showDataList[i].size) {
        state.showDataList[i].mantissa = lastNum.toDoubleTry();
      }
      if (state.showDataList[i].size == '合计') {
        state.showDataList[i].mantissa =
            state.showDataList[i].mantissa! + lastNum.toDoubleTry();
      }
    }

    state.showDataList.refresh();
  }

  //根据派工单ID删除贴标和框数
  clearBarCodeAndBoxQty({
    required Function(String msg) success,
  }) {
    if (state.dispatchNumber.value != '') {
      httpPost(
        method: webApiClearBarCodeAndBoxQtyJinZhen,
        loading: 'injection_scan_clean_box_and_label'.tr,
        params: {
          'InterID': state.dataBean.interID,
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

  //扫码刷新界面
  findSizeData(String code) {
    if (state.showBarCodeList.isNotEmpty) {
      if (code.length == 32) {
        if (state.showBarCodeList.every((list) => list.barCode != code)) {
          //找不到条码
          showSnackBar(message: 'injection_scan_unable_find_barcode'.tr);
        } else {
          for (var v in state.showBarCodeList) {
            if (v.barCode == code && v.use == false) {
              for (var c in state.showDataList) {
                if (c.dispatchNumber == v.dispatchNo && c.size == v.size) {
                  if (c.capacity == v.qty.toDoubleTry()) {
                    if ((c.box! + (1.0)) <= c.maxBox) {
                      c.box = c.box! + 1;
                      v.use = true;
                      showScanTips();
                    } else {
                      showSnackBar(message: 'injection_scan_up'.tr);
                    }
                  } else {
                    c.mantissa = v.qty.toDoubleTry();
                    v.use = true;
                    showScanTips();
                  }
                }
              }
            }
          }
          state.showDataList.refresh();
        }
      } else {
        showSnackBar(message: 'injection_scan_scan_real_label'.tr);
      }
    } else {
      showSnackBar(message: 'injection_scan_no_label_data'.tr);
    }
  }

  //判断是否有尾箱标
  bool lastNum(String size, double capacity) {
    if (state.showBarCodeList
        .any((v) => v.size == size && v.qty!.toDoubleTry() != capacity)) {
      return true;
    } else {
      return false;
    }
  }

  //产量汇报
  productionReport({
    required Function(String msg) success,
}) {
    if (state.dispatchNumber.value.isEmpty) {
      showSnackBar(message: 'injection_scan_first_query_detail'.tr);
    } else {
      if (state.dataBean.items!.any((v) =>
          v.confirmCurrentWorkingHours == '0.0' && v.itemReportQty() > 0.0)) {
        var size = '';
        state.dataBean.items!
            .where((v) =>
                v.confirmCurrentWorkingHours == '0.0' &&
                v.itemReportQty() > 0.0)
            .forEach((c) {
          size = '$size${c.size}码,';
        });
        '$size无工时';
        showSnackBar(message: size);
      } else {
        httpPost(
          method: webApiUpdateScWorkCardJinZhen,
          loading: 'injection_scan_modifying_dispatch_data'.tr,
          body: {
            'InterID': state.dataBean.interID,
            'Items': [
              for (var item in state.showDataList)
                {
                  'EntryID': item.entryID,
                  'BoxesQty': item.box,
                  'NotFullQty': item.mantissa
                }
            ],
            'BarCodeList': [
              for (var item
                  in state.showBarCodeList.where((v) => v.use == true))
                item.barCode
            ],
            'Output': {
              'EntryID': state.dataBean.interID,
              'Shift': state.dataBean.shift,
              'DecrementNumber': state.dataBean.decrementNumber,
              'DispatchNumber': state.dataBean.dispatchNumber,
              'MaterialNumber': state.dataBean.materialNumber,
              'Date': state.dataBean.startDate,
              'WorkCenter': state.dataBean.machine,
              'Items': [
                for (var items in state.showDataList)
                  {
                    'EntryID':items.entryID,
                    'Size':items.size,
                    'StandardTextCode': state.dataBean.processflow,
                    'ConfirmedQty':items.subtotal(),
                    'LastNotFullQty':items.lastMantissa,
                    'Mantissa':items.mantissa,
                    'BoxesQty':items.box,
                    'Capacity':items.capacity,
                    'BUoM':items.bUoM,
                    'ConfirmCurrentWorkingHours':items.confirmCurrentWorkingHours,
                    'WorkingHoursUnit':items.workingHoursUnit
                  }
              ],
            }
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
}
