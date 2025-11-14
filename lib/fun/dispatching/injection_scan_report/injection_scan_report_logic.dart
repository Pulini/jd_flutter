
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:jd_flutter/bean/http/response/process_plan_detail_info.dart';
import 'package:jd_flutter/bean/http/response/process_plan_info.dart';
import 'package:jd_flutter/bean/http/response/show_process_barcode_info.dart';
import 'package:jd_flutter/bean/http/response/show_process_plan_detail_info.dart';
import 'package:jd_flutter/bean/http/response/stock_in_barcode_info.dart';
import 'package:jd_flutter/utils/extension_util.dart';
import 'package:jd_flutter/utils/utils.dart';

import 'package:jd_flutter/utils/web_api.dart';
import 'package:jd_flutter/widget/custom_widget.dart';
import 'package:jd_flutter/widget/dialogs.dart';
import 'package:jd_flutter/widget/edit_text_widget.dart';
import 'injection_scan_report_state.dart';

class InjectionScanReportLogic extends GetxController {
  final InjectionScanReportState state = InjectionScanReportState();

  var textNumber = TextEditingController(); //当班尾数

  var inputNumber = [
    FilteringTextInputFormatter.allow(RegExp('[0-9]')),
  ];

  void getScWorkCardList() {
    httpGet(
      method: webApiGetScWorkCardList,
      loading: 'injection_scan_getting_process_plan'.tr,
      params: {'DispatchingMachine': userInfo?.number},
    ).then((response) {
      if (response.resultCode == resultSuccess) {
        var list = <ProcessPlanInfo>[
          for (var i = 0; i < response.data.length; ++i)
            ProcessPlanInfo.fromJson(response.data[i])
        ];
        if (list.isNotEmpty) {
          if (list.length == 1) {
            state.dispatchNumber.value = list[0].dispatchNumber.toString();
            getScWorkCardDetail();
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
                state.dispatchNumber.value = list[controller.selectedItem]
                    .dispatchNumber
                    .toString();
                getScWorkCardDetail();
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
                    items: list.map((data) {
                      return Center(
                          child: Text("${data.shift}/${data.materialName}"));
                    }).toList(),
                    controller: controller,
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

  void getScWorkCardDetail() {
    if (state.dispatchNumber.isEmpty) {
      getScWorkCardList();
    } else {
      httpGet(
          method: webApiGetScWorkCardDetail,
          loading: 'injection_scan_getting_process_plan_detail'.tr,
          params: {
            'DispatchingMachine': '',
            'DispatchNumber': state.dispatchNumber.value,
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

  //整理合计数
  void arrangeDataAll() {
    var list = state.showDataList.where((data) => data.size != '合计');
    for (var data in state.showDataList) {
      if (data.size == '合计') {
        data.capacity = list.map((v) => v.capacity ?? 0.0).reduce((a, b) => a.add(b));
        data.box = list.map((v) => v.box ?? 0).reduce((a, b) => a + b);
        data.lastMantissa = list.map((v) => v.lastMantissa ?? 0.0).reduce((a, b) => a + b);
        data.mantissa = list.map((v) => v.mantissa ?? 0.0).reduce((a, b) => a + b);
        data.allQty = list.map((v) => v.subtotal()).reduce((a, b) => a + b);
      }
    }
  }

  void arrangeData(ProcessPlanDetailInfo data) {
    state.machine.value = data.machine!;
    state.factoryType.value = data.factoryType!;

    var list = <ShowProcessPlanDetailInfo>[];
    var allLastMantissa = 0.0;
    var allMantissa = 0.0;
    var allBox = 0.0;
    var allCapacity = 0.0;

    if (data.items!.isNotEmpty) {
      for (var i = 0; i < data.items!.length; ++i) {
        allLastMantissa += data.items![i].lastNotFullQty!;
        allMantissa += data.items![i].notFullQty!;
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
          box: data.items?[i].boxesQty,
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
        allQty: list.map((v) => v.subtotal())
            .reduce((a, b) => a.add(b)),
        box: allBox,
        capacity: allCapacity,
      ),
    );

    state.showDataList.value = list;
    getBarCodeStatus();
  }

  void getBarCodeStatus() {
    if (state.dispatchNumber.value.isEmpty) {
      showSnackBar(message: 'injection_scan_first_query_detail'.tr);
    } else {
      sapPost(
        method: webApiSapGetMaterialDispatchLabelList,
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
          state.showBarCodeList.clear();
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
                  qty: c.qty.toString(),
                  num: v.num,
                  unit: c.unit,
                  use: false,
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
  void setShowDataList(List<ShowProcessBarcodeInfo> data) {
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
  void showInputDialog({
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
          content: NumberDecimalEditText(
            controller: textNumber,
            onChanged: (d) {
              if(d>clickData.capacity!){
                textNumber.text = clickData.capacity.toShowString();
              }
            },
            initQty: 0,
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                if (textNumber.text.toString().isEmpty) {
                  showSnackBar(message: '内容为空');
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

  void setSizeNumber(String lastNum, ShowProcessPlanDetailInfo data) {

    for (var list in state.showDataList) {
      if(list.size == data.size){
        list.mantissa = lastNum.toDoubleTry();
      }
    }
    arrangeDataAll();
    state.showDataList.refresh();
  }

  //根据派工单ID删除贴标和框数
  void clearBarCodeAndBoxQty({
    required Function(String msg) success,
  }) {
    if (state.dispatchNumber.value != '') {
      httpPost(
        method: webApiClearBarCodeAndBoxQty,
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
  void findSizeData(String code) {
    logger.f('扫到的贴标：$code');
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
                      arrangeDataAll();
                      state.showDataList.refresh();
                    } else {
                      showSnackBar(message: 'injection_scan_up'.tr);
                    }
                  } else {
                    c.mantissa = v.qty.toDoubleTry();
                    v.use = true;
                    showScanTips();
                    arrangeDataAll();
                    state.showDataList.refresh();
                  }
                }
              }
            } else if (v.barCode == code && v.use == true) {
              showSnackBar(message: '该贴标已扫描');
            }
          }
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
  void productionReport({
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
          method: webApiUpdateScWorkCard,
          loading: 'injection_scan_modifying_dispatch_data'.tr,
          body: {
            'InterID': state.dataBean.interID,
            'NextShiftEmpID': '',
            'OnDutyEmpID': '',
            'Items': [
              for (var item in state.showDataList
                  .where((data) => data.size != '合计')
                  .toList())
                {
                  'Capacity': "NULL",
                  'Mould': "NULL",
                  'TodayDispatchQty': "NULL",
                  'EntryID': item.entryID.toString(),
                  'BoxesQty': item.box.toString(),
                  'NotFullQty': item.mantissa.toString(),
                  'MantissaFlag': '0'
                }
            ],
            'BarCodeList': [
              for (var item
                  in state.showBarCodeList.where((v) => v.use == true))
                item.barCode
            ],
            'Output': {
              'InterID': state.dataBean.interID,
              'Shift': state.dataBean.shift,
              'DecrementNumber': state.dataBean.decrementNumber,
              'DispatchNumber': state.dataBean.dispatchNumber,
              'MaterialNumber': state.dataBean.materialNumber,
              'Date': state.dataBean.startDate,
              'UserID': getUserInfo()!.userID,
              'WorkCenter': state.dataBean.machine,
              'EmpList': [],
              'Items': [
                for (var items in state.showDataList
                    .where((data) => data.size != '合计')
                    .toList())
                  {
                    'EntryID': items.entryID,
                    'Size': items.size,
                    'StandardTextCode': state.dataBean.processflow,
                    'ConfirmedQty': items.subtotal(),
                    'LastNotFullQty': items.lastMantissa,
                    'Mantissa': items.mantissa.toString(),
                    'BoxesQty': items.box.toString(),
                    'Capacity': items.capacity,
                    'BUoM': items.bUoM,
                    'ConfirmCurrentWorkingHours':
                        items.confirmCurrentWorkingHours,
                    'WorkingHoursUnit': items.workingHoursUnit
                  }
              ],
            },
            'PictureList': [],
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
