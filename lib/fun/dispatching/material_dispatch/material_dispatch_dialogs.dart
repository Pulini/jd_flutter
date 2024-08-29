import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jd_flutter/bean/http/response/material_dispatch_info.dart';
import 'package:jd_flutter/utils.dart';
import 'package:jd_flutter/widget/custom_widget.dart';
import 'package:jd_flutter/widget/picker/picker_view.dart';

import '../../../bean/http/response/process_specification_info.dart';
import '../../../bean/http/response/sap_pallet_info.dart';
import '../../../web_api.dart';
import '../../../widget/dialogs.dart';
import '../../../widget/picker/picker_controller.dart';
import '../../../widget/web_page.dart';

subItemReportDialog(
  BuildContext context,
  MaterialDispatchInfo data,
  Children subData,
  Function(double) callback,
) {
  var qty = 0.0;
  var max = 0.0;
  if (subData.codeQty.toDoubleTry() == 0.0) {
    qty = subData.noCodeQty.toDoubleTry();
    max = subData.qty.toDoubleTry().sub(subData.finishQty.toDoubleTry());
  } else {
    max = subData.noCodeQty.toDoubleTry();
  }
  var controller = TextEditingController(
    text: qty.toShowString(),
  );
  controller.selection = TextSelection.fromPosition(
    TextPosition(offset: controller.text.length),
  );
  Get.dialog(
    PopScope(
      canPop: false,
      child: AlertDialog(
        title: Text('打标工序'),
        content: SizedBox(
          width: MediaQuery.of(context).size.width * 0.4 < 400
              ? 400
              : MediaQuery.of(context).size.width * 0.5,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                data.materialName ?? '',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: Colors.blue.shade900,
                ),
              ),
              textSpan(hint: '色系：', text: subData.sapColorBatch ?? ''),
              textSpan(hint: '应汇报数：', text: subData.noCodeQty ?? ''),
              NumberDecimalEditText(
                hint: '本次汇报数量',
                max: max,
                onChanged: (d) => qty = d,
                controller: controller,
              ),
              Row(
                children: [
                  Expanded(
                    child: CombinationButton(
                      text: '复制剩余数',
                      click: () {
                        controller.text =
                            subData.noCodeQty.toDoubleTry().toShowString();
                      },
                      combination: Combination.left,
                    ),
                  ),
                  Expanded(
                    child: CombinationButton(
                      text: '读取跑码器',
                      click: () {},
                      combination: Combination.middle,
                    ),
                  ),
                  Expanded(
                    child: CombinationButton(
                      text: '清空跑码器',
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
              if (qty == 0.0) {
                showSnackBar(title: 'snack_bar_default_wrong'.tr, message: '请填写报工数量');
              } else {
                callback.call(qty);
                Get.back();
              }
            },
            child: Text('提交报工'),
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
        title: Text('指令号'),
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
  MaterialDispatchInfo mdi,
) {
  var labelList = <LabelInfo>[].obs;
  Get.dialog(
    PopScope(
      canPop: false,
      child: AlertDialog(
        title: Text('贴标列表'),
        content: SizedBox(
          width: MediaQuery.of(context).size.width * 0.9,
          height: MediaQuery.of(context).size.height * 0.9,
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
                                  hint: '创建日期：',
                                  text: data.insertDateTime ?? '',
                                ),
                                expandedTextSpan(
                                  flex: 2,
                                  hint: '批次：',
                                  text: data.sapColorBatch ?? '',
                                ),
                                expandedTextSpan(
                                  hint: '状态：',
                                  text: data.status ?? '',
                                ),
                                expandedTextSpan(
                                  hint: '数量：',
                                  text: data.qty.toShowString(),
                                ),
                                CombinationButton(
                                  text: '重新打印',
                                  click: () {},
                                  combination: Combination.left,
                                ),
                                CombinationButton(
                                  text: '删除贴标',
                                  click: () {},
                                  combination: Combination.right,
                                ),
                              ],
                            ),
                          ),
                          SizedBox(
                            height: 40,
                            child: Row(
                              children: [
                                expandedTextSpan(
                                  hint: '托盘号：',
                                  text: data.palletNumber ?? '',
                                ),
                                expandedTextSpan(
                                  hint: '取件码：',
                                  text: data.pickUpCode ?? '',
                                ),
                                expandedTextSpan(
                                  hint: '机台：',
                                  text: data.drillingCrewName ?? '',
                                ),
                                CombinationButton(
                                  text: '更换托盘',
                                  click: () {},
                                  combination: Combination.left,
                                ),
                                CombinationButton(
                                  text: '报工SAP',
                                  click: () {},
                                  combination: Combination.right,
                                ),
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
    loading: '正在获取贴标列表...',
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
      errorDialog(content: response.message);
    }
  });
}

processSpecificationDialog(List<ProcessSpecificationInfo> files) {
  var selected = -1.obs;
  Get.dialog(
    PopScope(
        canPop: false,
        child: StatefulBuilder(
          builder: (context, dialogSetState) {
            return AlertDialog(
              title: Text('选择要查看的工艺指导书'),
              content: SizedBox(
                width: MediaQuery.of(context).size.width * 0.5,
                height: MediaQuery.of(context).size.height * 0.5,
                child: ListView.builder(
                  padding: const EdgeInsets.all(8),
                  itemCount: files.length,
                  itemBuilder: (context, index) => GestureDetector(
                    onTap: () => dialogSetState(() => selected = index),
                    child: Container(
                      height: 40,
                      margin: const EdgeInsets.all(5),
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: selected == index
                            ? Colors.blue.shade100
                            : Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: selected == index
                              ? Colors.green.shade200
                              : Colors.transparent,
                          width: 2,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          files[index].name ?? '',
                          style: const TextStyle(color: Colors.black),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    if (selected == -1) {
                      showSnackBar(title: '查看工艺指导书', message: '请选择要查看的文件');
                    } else {
                      Get.back();
                      Get.to(WebPage(
                        title: files[selected].fileName ?? '',
                        url: files[selected].fullName ?? '',
                      ));
                    }
                  },
                  child: Text('查看'),
                ),
                TextButton(
                  onPressed: () => Get.back(),
                  child: Text(
                    'dialog_default_cancel'.tr,
                    style: const TextStyle(color: Colors.grey),
                  ),
                ),
              ],
            );
          },
        )),
  );
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
          title: Text('用料清单列表'),
          content: SizedBox(
            width: MediaQuery.of(context).size.width * 0.6,
            height: MediaQuery.of(context).size.height * 0.6,
            child: Obx(
              () => ListView.builder(
                padding: const EdgeInsets.all(8),
                itemCount: materialList.length,
                itemBuilder: (context, index) {
                  var data = materialList[index];
                  var title = Expanded(
                    child: Text(
                      data.name ?? '',
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
                                  hint: '数量：',
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
                                        hint: '批次：', text: data.batch ?? ''),
                                    textSpan(
                                      hint: '数量：',
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
              child: const Text(
                '返回',
                style: TextStyle(color: Colors.grey),
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
    loading: '正在获取工单物料清单...',
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
    loading: '正在矫正大小米数量...',
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
          title: Text('贴合区域图'),
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

pickPallet({
  required int savePalletDate,
  required String saveMachine,
  required String saveWarehouseLocation,
  required String savePallet,
  bool isFirst = false,
  required BuildContext context,
  required Function(
    int date,
    String machineId,
    String locationId,
    String palletNumber,
  ) callback,
}) {
  var selectDate = 0;
  var selectMachineId = '';
  var selectLocationId = '';
  var selectPalletNumber = '';

  var dateNow = DateTime.now();
  var dpcDate = DatePickerController(
    PickerType.date,
    buttonName: '过账日期',
    firstDate: DateTime(dateNow.year, dateNow.month - 1, dateNow.day),
    lastDate: dateNow,
    initDate: savePalletDate,
    onSelected: (d) => selectDate = d.millisecondsSinceEpoch,
  );

  var ppcPallet = PickPalletController(
    initId: savePallet,
    onSelected: (spi) => selectPalletNumber = spi.palletNumber ?? '',
  );

  var opcMachine = OptionsPickerController(
    PickerType.sapMachine,
    initId: saveMachine,
    onSelected: (i) {
      selectMachineId = i.pickerId();
      ppcPallet.refresh(selectLocationId, selectMachineId);
    },
  );

  var opcWarehouseLocation = OptionsPickerController(
    PickerType.sapWarehouseStorageLocation,
    buttonName: '入库仓位',
    initId: saveWarehouseLocation,
    onSelected: (i) {
      selectLocationId = i.pickerId();
      ppcPallet.refresh(selectLocationId, selectMachineId);
    },
  );

  Get.dialog(
    PopScope(
      canPop: false,
      child: AlertDialog(
        title: Text('库位托盘选择'),
        content: SizedBox(
          width: MediaQuery.of(context).size.width * 0.35,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              textSpan(
                  hint: '工厂及存储地点：',
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
                showSnackBar(title: 'snack_bar_default_wrong'.tr, message: '请选择过账日期', isWarning: true);
                return;
              }
              if (selectMachineId.isEmpty) {
                showSnackBar(title: 'snack_bar_default_wrong'.tr, message: '请选择SAP机台', isWarning: true);
                return;
              }
              if (selectLocationId.isEmpty) {
                showSnackBar(title: 'snack_bar_default_wrong'.tr, message: '请选择入库仓位', isWarning: true);
                return;
              }
              if (selectPalletNumber.isEmpty) {
                showSnackBar(title: 'snack_bar_default_wrong'.tr, message: '请选择托盘', isWarning: true);
                return;
              }
              callback.call(
                selectDate,
                selectMachineId,
                selectLocationId,
                selectPalletNumber,
              );
              Get.back();
            },
            child: Text('dialog_default_confirm'.tr),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              if (isFirst) Get.back();
            },
            child: Text(
              isFirst ? 'dialog_default_back'.tr : 'dialog_default_cancel'.tr,
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
  final RxString msg = '请先选择机台和仓位'.obs;
  SapPalletInfo? select;

  refresh(String location, String machine) {
    if (location.isNotEmpty && machine.isNotEmpty) {
      this.location = location;
      this.machine = machine;
      _getPalletList();
    }
  }

  _getPalletList() {
    if (location.isEmpty || machine.isEmpty) {
      return;
    }
    msg.value = '正在读取托盘列表...';
    httpGet(
      method: webApiGetPallet,
      params: {
        'StartDate': '',
        'EndDate': '',
        'PalletNumber': '',
        'Factory': userInfo?.factory,
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

  _selectPalletNumber(String number) {
    if (number.isEmpty) return;
    var index = palletDataList.indexWhere((v) => v.palletNumber == number);
    if (index != -1) _selectIndex(index);
  }

  _selectIndex(int index) {
    select = palletDataList[index];
    msg.value = select?.palletNumber ?? '';
    onSelected.call(select!);
  }

  _showOptions() {
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
                palletDataList.map((data) {
                  return Center(
                    child: Text('${data.palletNumber} - 库存${data.usedNum}'),
                  );
                }).toList(),
                controller,
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
          Obx(() => controller.palletDataList.isEmpty
              ? Container()
              : ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.greenAccent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  onPressed: () => controller._showOptions(),
                  child: Text(
                    '选择托盘',
                    style: const TextStyle(color: Colors.white),
                  ),
                ))
        ],
      ),
    );
  }
}
