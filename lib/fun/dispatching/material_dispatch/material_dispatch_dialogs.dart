import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jd_flutter/bean/http/response/material_dispatch_info.dart';
import 'package:jd_flutter/bean/http/response/sap_pallet_info.dart';
import 'package:jd_flutter/fun/dispatching/material_dispatch/material_dispatch_state.dart';
import 'package:jd_flutter/utils/extension_util.dart';
import 'package:jd_flutter/utils/utils.dart';
import 'package:jd_flutter/utils/web_api.dart';
import 'package:jd_flutter/widget/combination_button_widget.dart';
import 'package:jd_flutter/widget/custom_widget.dart';
import 'package:jd_flutter/widget/dialogs.dart';
import 'package:jd_flutter/widget/edit_text_widget.dart';
import 'package:jd_flutter/widget/picker/picker_controller.dart';
import 'package:jd_flutter/widget/picker/picker_item.dart';
import 'package:jd_flutter/widget/picker/picker_view.dart';

subItemReportDialog(
  BuildContext context,
  MaterialDispatchInfo data,
  Children subData,
  Function(double, double, double, double, double, double) callback,
) {
  var qty = 0.0;
  var longQty = 0.0;
  var wideQty = 0.0;
  var heightQty = 0.0;
  var grossWeightQty = 0.0;
  var netWeightQty = 0.0;
  var max = 0.0;
  if (subData.codeQty.toDoubleTry() == 0.0) {
    qty = subData.noCodeQty.toDoubleTry();
    max = subData.qty.toDoubleTry().sub(subData.finishQty.toDoubleTry());
  } else {
    qty = subData.qty.toDoubleTry().sub(subData.codeQty.toDoubleTry());
    max = subData.noCodeQty.toDoubleTry();
  }
  var controller = TextEditingController(
    text: qty.toShowString(),
  );
  controller.selection = TextSelection.fromPosition(
    TextPosition(offset: controller.text.length),
  );
  Get.dialog(
    useSafeArea: true,
    PopScope(
      canPop: false,
      child: AlertDialog(
        scrollable: true,
        title: data.mustEnter == '1'
            ? Text('material_dispatch_dialog_label_progress'.tr)
            : Text('material_dispatch_dialog_label_progress_must'.tr),
        content: SizedBox(
          height: 230,
          width: getScreenSize().width * 0.4 < 400
              ? 400
              : getScreenSize().width * 0.5,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                data.materialName ?? '',
                maxLines: 2,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: Colors.blue.shade900,
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  textSpan(
                    hint: 'material_dispatch_dialog_need_report_qty'.tr,
                    text: subData.noCodeQty ?? '',
                  ),
                  textSpan(
                    hint: 'material_dispatch_dialog_color_batch'.tr,
                    text: subData.sapColorBatch ?? '',
                  ),
                ],
              ),
              Row(
                children: [
                  Expanded(
                    child: NumberDecimalEditText(
                      hint: 'material_dispatch_dialog_report_qty'.tr,
                      max: max,
                      onChanged: (d) => qty = d,
                      controller: controller,
                    ),
                  ),
                  Expanded(
                    child: NumberDecimalEditText(
                      hint: 'material_dispatch_dialog_gross_weight_qty'.tr,
                      onChanged: (d) => grossWeightQty = d,
                    ),
                  ),
                  Expanded(
                    child: NumberDecimalEditText(
                      hint: 'material_dispatch_dialog_net_weight_qty'.tr,
                      onChanged: (d) => netWeightQty = d,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Expanded(
                    child: NumberDecimalEditText(
                      hint: 'material_dispatch_dialog_long'.tr,
                      onChanged: (d) => longQty = d,
                    ),
                  ),
                  Expanded(
                    child: NumberDecimalEditText(
                      hint: 'material_dispatch_dialog_wide'.tr,
                      onChanged: (d) => wideQty = d,
                    ),
                  ),
                  Expanded(
                    child: NumberDecimalEditText(
                      hint: 'material_dispatch_dialog_height'.tr,
                      onChanged: (d) => heightQty = d,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Expanded(
                    child: CombinationButton(
                      text: 'material_dispatch_dialog_copy_surplus'.tr,
                      click: () {
                        controller.text =
                            subData.noCodeQty.toDoubleTry().toShowString();
                      },
                      combination: Combination.left,
                    ),
                  ),
                  Expanded(
                    child: CombinationButton(
                      text: 'material_dispatch_dialog_read_device'.tr,
                      click: () {},
                      combination: Combination.middle,
                    ),
                  ),
                  Expanded(
                    child: CombinationButton(
                      text: 'material_dispatch_dialog_clear_device'.tr,
                      click: () {},
                      combination: Combination.right,
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(
              'dialog_default_back'.tr,
              style: const TextStyle(color: Colors.grey),
            ),
          ),
          TextButton(
            onPressed: () {
              qty = controller.text.toDoubleTry();
              if (qty == 0.0) {
                showSnackBar(
                  message: 'material_dispatch_dialog_enter_report_qty_tips'.tr,
                  isWarning: true,
                );
              } else {
                if (data.mustEnter == '1') {
                  if (longQty == 0 ||
                      wideQty == 0 ||
                      heightQty == 0 ||
                      grossWeightQty == 0 ||
                      netWeightQty == 0) {
                    showSnackBar(
                      message: 'material_dispatch_dialog_need_qty_tips'.tr,
                      isWarning: true,
                    );
                  } else {
                    Get.back();
                    callback.call(qty, longQty, wideQty, heightQty,
                        grossWeightQty, netWeightQty);
                  }
                } else {
                  Get.back();
                  callback.call(qty, longQty, wideQty, heightQty,
                      grossWeightQty, netWeightQty);
                }
              }
            },
            child: Text('material_dispatch_dialog_submit_report'.tr),
          ),
        ],
      ),
    ),
  );
}

showBillNoList(String data) {
  Get.dialog(
    PopScope(
      canPop: false,
      child: AlertDialog(
        title: Text('material_dispatch_dialog_ins_number'.tr),
        content: Text(data),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(
              'dialog_default_back'.tr,
              style: const TextStyle(color: Colors.grey),
            ),
          ),
        ],
      ),
    ),
  );
}

labelListDialog(
  BuildContext context,
  MaterialDispatchInfo mdi, {
  required Function(MaterialDispatchInfo, LabelInfo) printCallback,
  required Function() refreshCallBack,
}) {
  var labelList = <LabelInfo>[].obs;

  Get.dialog(
    PopScope(
      canPop: false,
      child: AlertDialog(
        title: Text('material_dispatch_dialog_label_list'.tr),
        content: SizedBox(
          width: getScreenSize().width * 0.9,
          height: getScreenSize().height * 0.9,
          child: Obx(() => ListView.builder(
                padding: const EdgeInsets.all(8),
                itemCount: labelList.length,
                itemBuilder: (context, index) {
                  var data = labelList[index];
                  return Card(
                    color: Colors.blue.shade50,
                    child: Padding(
                      padding: const EdgeInsets.all(10),
                      child: Column(
                        children: [
                          SizedBox(
                            height: 40,
                            child: Row(
                              children: [
                                expandedTextSpan(
                                  flex: 2,
                                  hint:
                                      'material_dispatch_dialog_create_date'.tr,
                                  text: data.insertDateTime ?? '',
                                ),
                                expandedTextSpan(
                                  flex: 2,
                                  hint: 'material_dispatch_dialog_batch'.tr,
                                  text: data.sapColorBatch ?? '',
                                ),
                                expandedTextSpan(
                                  hint: 'material_dispatch_dialog_state'.tr,
                                  text: data.status ?? '',
                                ),
                                expandedTextSpan(
                                  hint: 'material_dispatch_dialog_qty'.tr,
                                  text: data.qty.toShowString(),
                                ),
                                SizedBox(
                                  width: 110,
                                  child: CombinationButton(
                                    text: 'material_dispatch_dialog_reprint'.tr,
                                    click: () =>printCallback.call(mdi, data),
                                    combination: Combination.left,
                                  ),
                                ),
                                SizedBox(
                                  width: 110,
                                  child: CombinationButton(
                                    text:
                                        'material_dispatch_dialog_delete_label'
                                            .tr,
                                    click: () {
                                      askDialog(
                                          content: 'material_dispatch_dialog_sure_delete_label'.tr,
                                          confirm: () {
                                            _deleteLabel(
                                              guid: data.guid!,
                                              callback: () {
                                                _getLabelList(
                                                  mdi.children?[0].interID ??
                                                      '',
                                                  mdi.children?[0]
                                                          .routeEntryFIDs ??
                                                      '',
                                                  mdi.routeEntryFIDs ?? '',
                                                  mdi.sapDecideArea ?? '',
                                                  mdi.productName ?? '',
                                                  (list) =>
                                                      labelList.value = list,
                                                );
                                                refreshCallBack.call();
                                              },
                                            );
                                          });
                                    },
                                    combination: Combination.right,
                                  ),
                                )
                              ],
                            ),
                          ),
                          SizedBox(
                            height: 40,
                            child: Row(
                              children: [
                                expandedTextSpan(
                                  hint: 'material_dispatch_dialog_pallet_number'
                                      .tr,
                                  text: data.palletNumber ?? '',
                                ),
                                expandedTextSpan(
                                  hint: 'material_dispatch_dialog_pick_code'.tr,
                                  text: data.pickUpCode ?? '',
                                ),
                                expandedTextSpan(
                                  hint: 'material_dispatch_dialog_machine'.tr,
                                  text: data.drillingCrewName ?? '',
                                ),
                                SizedBox(
                                  width: 110,
                                  child: CombinationButton(
                                    text:
                                        'material_dispatch_dialog_change_pallet'
                                            .tr,
                                    click: () {},
                                    combination: Combination.left,
                                  ),
                                ),
                                SizedBox(
                                  width: 110,
                                  child: CombinationButton(
                                    isEnabled:
                                        (mdi.children![0].lastProcessNode ==
                                                    '1' &&
                                                data.billInterID! > 0)
                                            ? true
                                            : false,
                                    text: data.reportStatus == '0'
                                        ? 'material_dispatch_dialog_report_sap'
                                            .tr
                                        : 'material_dispatch_dialog_cancel_report_sap'
                                            .tr,
                                    click: () {
                                      askDialog(
                                          content: data.reportStatus == '0'
                                              ? 'material_dispatch_dialog_sure_report_sap'
                                                  .tr
                                              : 'material_dispatch_dialog_sure_cancel_report_sap'
                                                  .tr,
                                          confirm: () {
                                            _reportSapOrCancelReportSap(
                                                billInterID: data.billInterID!,
                                                outPutNumber:
                                                    data.outPutNumber!,
                                                isReport:
                                                    data.reportStatus == '0',
                                                guid: data.guid!,
                                                upDate: getDateYMD(
                                                  time: DateTime
                                                      .fromMillisecondsSinceEpoch(
                                                    getMaterialDispatchDate(),
                                                  ),
                                                ),
                                                callback: () {
                                                  refreshCallBack.call();
                                                });
                                          });
                                    },
                                    combination: Combination.right,
                                  ),
                                )
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              )),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(
              'dialog_default_cancel'.tr,
              style: const TextStyle(color: Colors.grey),
            ),
          ),
        ],
      ),
    ),
    barrierDismissible: false,
  );
  _getLabelList(
    mdi.children?[0].interID ?? '',
    mdi.children?[0].routeEntryFIDs ?? '',
    mdi.routeEntryFIDs ?? '',
    mdi.sapDecideArea ?? '',
    mdi.productName ?? '',
    (list) => labelList.value = list,
  );
}

_deleteLabel({
  required String guid,
  required Function() callback,
}) {
  httpPost(
    method: webApiDelQRCode,
    loading: 'material_dispatch_dialog_getting_label_list'.tr,
    params: {
      'Guid': guid,
      'UserID': getUserInfo()!.userID.toString(),
    },
  ).then((response) {
    if (response.resultCode == resultSuccess) {
      callback.call();
    } else {
      errorDialog(content: response.message);
    }
  });
}

_reportSapOrCancelReportSap({
  required int billInterID,
  required String outPutNumber,
  required bool isReport,
  required String guid,
  required String upDate,
  required Function() callback,
}) {
  httpPost(
    method: webApiProcessOutPutReportByBillInterIDStripDrawing,
    loading: 'material_dispatch_dialog_submit_sap'.tr,
    params: {
      'BillInterID': billInterID,
      'OutPutNumber': outPutNumber,
      'Report': isReport ? 'X' : '',
      'Guid': guid,
      'Date': upDate,
      'UserID': getUserInfo()!.userID.toString(),
      'MovementType': '101',
    },
  ).then((response) {
    if (response.resultCode == resultSuccess) {
      callback.call();
    } else {
      errorDialog(content: response.message);
    }
  });
}

_getLabelList(
  String interId,
  String routeEntryFID,
  String routeEntryFIDs,
  String sapDecideArea,
  String productName,
  Function(List<LabelInfo>) callback,
) {
  httpGet(
    method: webApiGetQRCodeList,
    loading: 'material_dispatch_dialog_getting_label_list'.tr,
    params: {
      'processWorkCardInterID': interId,
      'routeEntryFID': routeEntryFID,
      'routeEntryFIDs': routeEntryFIDs,
      'sapDecideArea': sapDecideArea,
      'ProductName': productName,
    },
  ).then((response) {
    if (response.resultCode == resultSuccess) {
      callback.call([
        for (var i = 0; i < response.data.length; ++i)
          LabelInfo.fromJson(response.data[i])
      ]);
    } else {
      callback.call([]);
      Get.back();
      errorDialog(content: response.message);
    }
  });
}

materialListDialog(
  BuildContext context,
  MaterialDispatchInfo mdi,
) {
  var materialList = <MaterialInfo>[].obs;
  Get.dialog(
    PopScope(
        canPop: false,
        child: AlertDialog(
          title: Text('material_dispatch_dialog_material_list'.tr),
          content: SizedBox(
            width: getScreenSize().width * 0.6,
            height: getScreenSize().height * 0.6,
            child: Obx(
              () => ListView.builder(
                padding: const EdgeInsets.all(8),
                itemCount: materialList.length,
                itemBuilder: (context, index) {
                  var data = materialList[index];
                  var title = Expanded(
                    child: Text(
                      '<${data.number}>${data.name}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.blue.shade900,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  );
                  return GestureDetector(
                    onTap: () => _materialMetersConvert(
                      mdi.children?[0].interID ?? '',
                      data.name ?? '',
                      () =>
                          _getMaterialList(mdi, (v) => materialList.value = v),
                    ),
                    // onTap: ()=>materialList.value=[],
                    child: Container(
                      height: data.batch?.isEmpty == true ? 35 : 55,
                      margin: const EdgeInsets.all(5),
                      padding: const EdgeInsets.only(
                          left: 10, top: 5, right: 10, bottom: 5),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: data.batch?.isEmpty == true
                          ? Row(
                              children: [
                                title,
                                textSpan(
                                  hint: 'material_dispatch_dialog_qty'.tr,
                                  text: '${data.needQty}${data.unitName}',
                                )
                              ],
                            )
                          : Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                title,
                                Row(
                                  children: [
                                    expandedTextSpan(
                                        hint:
                                            'material_dispatch_dialog_batch'.tr,
                                        text: data.batch ?? ''),
                                    textSpan(
                                      hint: 'material_dispatch_dialog_qty'.tr,
                                      text: '${data.needQty}${data.unitName}',
                                    )
                                  ],
                                )
                              ],
                            ),
                    ),
                  );
                },
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Get.back(),
              child: Text(
                'material_dispatch_dialog_back'.tr,
                style: const TextStyle(color: Colors.grey),
              ),
            ),
          ],
        )),
  );
  _getMaterialList(mdi, (list) => materialList.value = list);
}

_getMaterialList(
  MaterialDispatchInfo data,
  Function(List<MaterialInfo>) callback,
) {
  httpGet(
    method: webApiGetSubItemBatchMaterialInformation,
    loading: 'material_dispatch_dialog_getting_order_material_list'.tr,
    params: {
      'ScProcessWorkCardInterIDList': data.children?[0].interID,
      'MaterialNumber': data.materialNumber,
      'PartName': data.partName,
      'UserID': userInfo?.userID,
    },
  ).then((response) {
    if (response.resultCode == resultSuccess) {
      callback.call([
        for (var i = 0; i < response.data.length; ++i)
          MaterialInfo.fromJson(response.data[i])
      ]);
    } else {
      errorDialog(content: response.message);
    }
  });
}

_materialMetersConvert(
  String interId,
  String materialName,
  Function() callback,
) {
  httpPost(
    method: webApiMetersConvert,
    loading: 'material_dispatch_dialog_correcting_meters_qry'.tr,
    params: {
      'ScProcessWorkCardInterIDList': interId,
      'MaterialNumber': materialName,
    },
  ).then((response) {
    if (response.resultCode == resultSuccess) {
      callback.call();
    } else {
      errorDialog(content: response.message);
    }
  });
}

showAreaPhoto(BuildContext context) => Get.dialog(
      PopScope(
        canPop: false,
        child: AlertDialog(
          title: Text('material_dispatch_dialog_map'.tr),
          content: Image.network(
            'https://geapp.goldemperor.com:8084/PDF/贴合区域规划图.png',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Get.back();
              },
              child: Text(
                'dialog_default_back'.tr,
                style: const TextStyle(color: Colors.grey),
              ),
            ),
          ],
        ),
      ),
      barrierDismissible: false,
    );

Future pickPallet() {
  var selectDate = getMaterialDispatchDate();
  var selectMachineId = getMaterialDispatchMachineId();
  var selectLocationId = getMaterialDispatchLocationId();
  var selectPalletNumber = getMaterialDispatchPalletNumber();
  var selectDepart = getMaterialDispatchDepart();

  var dateNow = DateTime.now();
  var dpcDate = DatePickerController(
    PickerType.date,
    buttonName: 'material_dispatch_dialog_posting_date'.tr,
    firstDate: DateTime(dateNow.year, dateNow.month - 1, dateNow.day),
    lastDate: dateNow,
    initDate: selectDate,
    onSelected: (d) => selectDate = d.millisecondsSinceEpoch,
  );

  var ppcPallet = PickPalletController(
    initId: selectPalletNumber,
    onSelected: (spi) => selectPalletNumber = spi.palletNumber ?? '',
  );

  var opcMachine = OptionsPickerController(
    PickerType.sapMachine,
    initId: selectMachineId,
    onSelected: (i) {
      selectMachineId = i.pickerId();
      selectDepart = (i as PickerSapMachine).deptID!.toString();
      ppcPallet.refresh(selectLocationId, selectMachineId);
    },
  );

  var opcWarehouseLocation = OptionsPickerController(
    PickerType.sapWarehouseStorageLocation,
    buttonName: 'material_dispatch_dialog_stock_in_warehouse_position'.tr,
    initId: selectLocationId,
    onSelected: (i) {
      selectLocationId = i.pickerId();
      ppcPallet.refresh(selectLocationId, selectMachineId);
    },
  );

  return Get.dialog(
    PopScope(
      canPop: false,
      child: AlertDialog(
        title: Text('material_dispatch_dialog_pallet_select'.tr),
        content: SizedBox(
          width: 400,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              textSpan(
                  hint: 'material_dispatch_dialog_factory_and_storage_location'
                      .tr,
                  text: '${userInfo?.factory} / ${userInfo?.defaultStockName}',
                  textColor: Colors.blue.shade900),
              DatePicker(pickerController: dpcDate),
              OptionsPicker(pickerController: opcMachine),
              OptionsPicker(pickerController: opcWarehouseLocation),
              PickPallet(controller: ppcPallet),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              if (selectDate == 0) {
                showSnackBar(
                  message:
                      'material_dispatch_dialog_select_posting_date_tips'.tr,
                  isWarning: true,
                );
                return;
              }
              if (selectMachineId.isEmpty) {
                showSnackBar(
                  message: 'material_dispatch_dialog_select_machine_tips'.tr,
                  isWarning: true,
                );
                return;
              }
              if (getUserInfo()!.useStorageLocation == 1) {
                if (selectLocationId.isEmpty) {
                  showSnackBar(
                    message:
                        'material_dispatch_dialog_select_storage_location_tops'
                            .tr,
                    isWarning: true,
                  );
                  return;
                }
              }
              saveMaterialDispatchDate(selectDate);
              saveMaterialDispatchDepart(selectDepart);
              saveMaterialDispatchMachineId(selectMachineId);
              saveMaterialDispatchLocationId(selectLocationId);
              saveMaterialDispatchPalletNumber(selectPalletNumber);
              Get.back();
            },
            child: Text('dialog_default_confirm'.tr),
          ),
          TextButton(
            onPressed: () {
              Get.back(result: selectPalletNumber.isEmpty);
            },
            child: Text(
              selectPalletNumber.isEmpty
                  ? 'dialog_default_back'.tr
                  : 'dialog_default_cancel'.tr,
              style: const TextStyle(color: Colors.grey),
            ),
          ),
        ],
      ),
    ),
    barrierDismissible: false, //拦截dialog外部点击
  );
  // dpcDate.pickDate.value = DateTime.fromMillisecondsSinceEpoch(savePalletDate);
  // ppcPallet._selectPalletNumber(selectPalletNumber);
  // opcMachine.selectPickerId(selectMachineId);
  // opcWarehouseLocation.selectPickerId(selectLocationId);
}

class PickPalletController {
  PickPalletController({
    required this.onSelected,
    this.initId = '',
  });

  String location = '';
  String machine = '';
  String initId;
  final Function(SapPalletInfo) onSelected;

  final RxList<SapPalletInfo> palletDataList = <SapPalletInfo>[].obs;
  final RxString msg =
      'material_dispatch_dialog_select_machine_and_storage_location_tops'
          .tr
          .obs;
  SapPalletInfo? select;

  refresh(String location, String machine) {
    if (location.isNotEmpty && machine.isNotEmpty) {
      this.location = location;
      this.machine = machine;
      _getPalletList();
    }
  }

  void _getPalletList() {
    if (location.isEmpty || machine.isEmpty) {
      return;
    }
    msg.value = 'material_dispatch_dialog_reading_pallet_list'.tr;
    httpGet(
      method: webApiGetPallet,
      params: {
        'StartDate': '',
        'EndDate': '',
        'PalletNumber': '',
        'Factory': userInfo?.sapFactory,
        'StorageLocation': userInfo?.defaultStockNumber,
        'Location': location,
        'ProductionMachine': machine,
      },
    ).then((response) {
      if (response.resultCode == resultSuccess) {
        palletDataList.value = [
          for (var i = 0; i < response.data.length; ++i)
            SapPalletInfo.fromJson(response.data[i])
        ];
        _selectPalletNumber(initId);
        if (select == null) _selectIndex(0);
      } else {
        select = null;
        msg.value = response.message ?? '';
        palletDataList.value = [];
      }
    });
  }

  void _selectPalletNumber(String number) {
    if (number.isEmpty) return;
    var index = palletDataList.indexWhere((v) => v.palletNumber == number);
    if (index != -1) _selectIndex(index);
  }

  void _selectIndex(int index) {
    select = palletDataList[index];
    msg.value = select?.palletNumber ?? '';
    onSelected.call(select!);
  }

  void _showOptions() {
    if (palletDataList.isNotEmpty) {
      //创建选择器控制器
      var controller = FixedExtentScrollController(
        initialItem: initId.isNotEmpty
            ? palletDataList.indexWhere((v) => v.palletNumber == initId)
            : 0,
      );

      var titleButtonCancel = TextButton(
        onPressed: () => Get.back(),
        child: Text(
          'dialog_default_cancel'.tr,
          style: const TextStyle(
            color: Colors.grey,
            fontSize: 20,
          ),
        ),
      );
      var titleButtonConfirm = TextButton(
        onPressed: () {
          _selectIndex(controller.selectedItem);
          Get.back();
        },
        child: Text(
          'dialog_default_confirm'.tr,
          style: const TextStyle(
            color: Colors.blueAccent,
            fontSize: 20,
          ),
        ),
      );

      showPopup(
        Column(
          children: [
            Container(
              height: 80,
              color: Colors.grey[200],
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  titleButtonConfirm,
                  Expanded(child: Container()),
                  titleButtonCancel,
                ],
              ),
            ),
            Expanded(
              child: getCupertinoPicker(
                items: palletDataList.map((data) {
                  return Center(
                    child: Text(
                      'material_dispatch_dialog_inventory'.trArgs([
                        data.palletNumber ?? '',
                        data.usedNum.toShowString(),
                      ]),
                    ),
                  );
                }).toList(),
                controller: controller,
              ),
            ),
          ],
        ),
      );
    } else {
      _getPalletList();
    }
  }
}

class PickPallet extends StatelessWidget {
  const PickPallet({super.key, required this.controller});

  final PickPalletController controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      margin: const EdgeInsets.fromLTRB(10, 5, 10, 5),
      padding: const EdgeInsets.only(left: 15, right: 5),
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(25),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Obx(() => Expanded(
                child: AutoSizeText(
                  controller.msg.value,
                  style: TextStyle(
                    color: controller.palletDataList.isEmpty
                        ? Colors.red
                        : Colors.black,
                  ),
                  maxLines: 2,
                  minFontSize: 8,
                  maxFontSize: 16,
                ),
              )),
          Obx(
            () => controller.palletDataList.isEmpty
                ? Container()
                : CombinationButton(
                    text: 'material_dispatch_dialog_select_pallet'.tr,
                    click: () => controller._showOptions(),
                  ),
          )
        ],
      ),
    );
  }
}
