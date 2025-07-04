import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jd_flutter/bean/http/response/sap_picking_scan_info.dart';
import 'package:jd_flutter/constant.dart';
import 'package:jd_flutter/fun/warehouse/out/sap_packing_scan/sap_packing_scan_label_view.dart';
import 'package:jd_flutter/fun/warehouse/out/sap_packing_scan/sap_packing_scan_reverse_view.dart';
import 'package:jd_flutter/route.dart';
import 'package:jd_flutter/utils/utils.dart';
import 'package:jd_flutter/widget/combination_button_widget.dart';
import 'package:jd_flutter/widget/custom_widget.dart';
import 'package:jd_flutter/widget/dialogs.dart';
import 'package:jd_flutter/widget/edit_text_widget.dart';
import 'package:jd_flutter/widget/picker/picker_controller.dart';
import 'package:jd_flutter/widget/picker/picker_view.dart';
import 'package:jd_flutter/widget/scanner.dart';

import 'sap_packing_scan_logic.dart';
import 'sap_packing_scan_state.dart';

class SapPackingScanPage extends StatefulWidget {
  const SapPackingScanPage({super.key});

  @override
  State<SapPackingScanPage> createState() => _SapPackingScanPageState();
}

class _SapPackingScanPageState extends State<SapPackingScanPage> {
  final SapPackingScanLogic logic = Get.put(SapPackingScanLogic());
  final SapPackingScanState state = Get.find<SapPackingScanLogic>().state;

  var dpcDate = DatePickerController(
    PickerType.date,
    buttonName: '计划船期',
    saveKey: '${RouteConfig.sapPackingScan.name}${PickerType.date}',
  );
  var opcDestination = OptionsPickerController(
    PickerType.sapDestination,
    saveKey: '${RouteConfig.sapPackingScan.name}${PickerType.sapDestination}',
  );
  var lopcFactoryAndWarehouse = LinkOptionsPickerController(
    PickerType.sapFactoryWarehouse,
    saveKey:
        '${RouteConfig.pickingMaterialOrder.name}${PickerType.sapFactoryWarehouse}',
  );

  _muneSheet() {
    showSheet(
      context: context,
      body: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          CombinationButton(
            text: '查看扫码件',
            click: () {
              Get.back();
              Get.to(() => const SapPackingScanLabelPage());
            },
          ),
          const SizedBox(height: 5),
          CombinationButton(
            text: '封柜',
            backgroundColor: Colors.green,
            click: () {
              Get.back();
              logic.sealingCabinet();
            },
          ),
          const SizedBox(height: 5),
          CombinationButton(
            text: '冲销',
            backgroundColor: Colors.red,
            click: () {
              Get.back();
              Get.to(() => const SapPackingScanReversePage())
                  ?.then((_) => _initScan());
            },
          ),
          const SizedBox(height: 5),
          const Divider(),
          CombinationButton(
            text: '取消',
            backgroundColor: Colors.grey.shade300,
            foregroundColor: Colors.grey,
            click: () => Get.back(),
          ),
        ],
      ),
    );
  }

  _operationSheet() {
    var tecNumber = TextEditingController(
        text: spGet(spSavePackingScanActualCabinet) ?? '');

    var number = EditText(
      hint: '实际柜号',
      controller: tecNumber,
    );

    var cancel = CombinationButton(
      combination: Combination.left,
      backgroundColor: Colors.red,
      text: '退出',
      click: () => exitDialog(
        content: '确定要退出装柜扫码吗？',
        confirm: () => Get.until((v) => v.isFirst),
      ),
    );

    var viewError = Obx(() => CombinationButton(
          combination: Combination.middle,
          backgroundColor:
              state.isAbnormal.value ? Colors.green : Colors.orange,
          text: state.isAbnormal.value ? '扫码装柜' : '查看出库报错',
          click: () {
            if (tecNumber.text.isEmpty) {
              errorDialog(content: '请输入实际柜号!');
              return;
            }
            if (!opcDestination.isReady()) {
              errorDialog(content: '请选择目的地!');
              return;
            }
            if (!lopcFactoryAndWarehouse.isReady()) {
              errorDialog(content: '请选择工厂和仓库!');
              return;
            }
            state.isAbnormal.value = !state.isAbnormal.value;
          },
        ));

    var confirm = CombinationButton(
      combination: Combination.right,
      text: '确定',
      click: () {
        var actualCabinet = tecNumber.text;
        if (actualCabinet.isEmpty) {
          errorDialog(content: '请输入实际柜号!');
          return;
        }
        if (!opcDestination.isReady()) {
          errorDialog(content: '请选择目的地!');
          return;
        }
        if (!lopcFactoryAndWarehouse.isReady()) {
          errorDialog(content: '请选择工厂和仓库!');
          return;
        }
        state.plannedDate = dpcDate.getDate();
        state.destination = opcDestination.getPickItem();
        state.factory = lopcFactoryAndWarehouse.getPickItem1();
        state.warehouse = lopcFactoryAndWarehouse.getPickItem2();
        state.actualCabinet = actualCabinet;
        spSave(spSavePackingScanActualCabinet, actualCabinet);
        if (state.isAbnormal.value) {
          state.abnormalSearchText.value = '';
          logic.getAbnormalOrders(() => Get.back());
        } else {
          state.abnormalList.clear();
          state.materialSearchText.value = '';
          Get.back();
        }
      },
    );

    var widgets = <Widget>[];
    if (state.plannedDate != null &&
        state.destination != null &&
        state.factory != null &&
        state.warehouse != null) {
      widgets = [
        const SizedBox(height: 20),
        number,
        Padding(
          padding: const EdgeInsets.only(left: 10, right: 10, top: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              expandedTextSpan(
                hint: '计划船期：',
                text: getDateYMD(time: state.plannedDate),
              ),
              textSpan(
                hint: '目的地：',
                text: state.destination?.toShow() ?? '',
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 10, right: 10),
          child: textSpan(
            hint: '工厂：',
            text: state.factory?.toShow() ?? '',
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 10, right: 10, bottom: 20),
          child: textSpan(
            hint: '仓库：',
            text: state.warehouse?.toShow() ?? '',
          ),
        ),
        Row(
          children: [
            Expanded(child: cancel),
            Expanded(child: viewError),
            Expanded(child: confirm),
          ],
        ),
      ];
    } else {
      widgets = [
        const SizedBox(height: 20),
        number,
        DatePicker(pickerController: dpcDate),
        OptionsPicker(pickerController: opcDestination),
        LinkOptionsPicker(pickerController: lopcFactoryAndWarehouse),
        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(child: cancel),
            Expanded(child: viewError),
            Expanded(child: confirm),
          ],
        ),
      ];
    }
    showModalBottomSheet(
      isDismissible: false,
      context: context,
      elevation: 0,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
      ),
      barrierColor: Colors.black.withValues(alpha: 0.25),
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height -
            MediaQuery.of(context).viewInsets.top,
      ),
      isScrollControlled: true,
      builder: (ctx) => PopScope(
        canPop: false,
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.only(
              left: 10,
              top: 10,
              right: 10,
              bottom: 10 + MediaQuery.of(ctx).viewInsets.bottom,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: widgets,
            ),
          ),
        ),
      ),
    );
  }

  Widget _item(SapPackingScanMaterialInfo data) => Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.black),
          color: Colors.white,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  flex: 3,
                  child: Text(data.trackNo ?? '', textAlign: TextAlign.center),
                ),
                Expanded(
                  flex: 2,
                  child: Text(data.quality.toShowString(),
                      textAlign: TextAlign.center),
                ),
                Expanded(
                  flex: 1,
                  child: Text(data.unit ?? '', textAlign: TextAlign.center),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    data.scannedCount().toShowString(),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(left: 5, right: 5),
              child: textSpan(
                hint: '物料：',
                text: '(${data.materialNumber}) ${data.materialName}',
                maxLines: 3,
              ),
            ),
          ],
        ),
      );

  _pickDate({DateTime? date, required Function(String) callback}) {
    var pickDate = date ?? DateTime.now();
    showDatePicker(
      locale: View.of(Get.overlayContext!).platformDispatcher.locale,
      context: Get.overlayContext!,
      initialDate: pickDate,
      firstDate: DateTime(pickDate.year, pickDate.month - 1, pickDate.day),
      lastDate: DateTime(pickDate.year, pickDate.month + 1, pickDate.day),
    ).then((date) {
      if (date != null) {
        callback.call(getDateYMD(time: date));
      }
    });
  }

  _abnormalItem(List<List<SapPackingScanAbnormalInfo>> data, int index) {
    var list = data[index];
    var qty = list.map((v) => v.quality ?? 0).reduce((a, b) => a.add(b));
    return Container(
      padding: const EdgeInsets.only(left: 10, top: 5, bottom: 5),
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(5),
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.blue.shade100, Colors.white],
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              expandedTextSpan(
                hint: '物料：',
                text: '(${list[0].materialNumber})${list[0].materialName}',
                maxLines: 2,
              ),
              textSpan(
                hint: '数量：',
                text: '${qty.toShowString()}${list[0].unit}',
              ),
              Obx(() => Checkbox(
                    value: list.every((v) => v.isSelected.value),
                    onChanged: (v) => logic.selectAbnormalItems(
                      list: data,
                      index: index,
                      isSelected: v!,
                    ),
                  ))
            ],
          ),
          for (var p in list) ...[
            const Divider(height: 1, indent: 10, endIndent: 15),
            Padding(
              padding: const EdgeInsets.only(left: 10),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      '件ID：${p.pieceNumber}',
                      style: const TextStyle(color: Colors.black54),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      '日期：${p.date}',
                      style: const TextStyle(color: Colors.black54),
                    ),
                  ),
                  Obx(() => Checkbox(
                        value: p.isSelected.value,
                        onChanged: (v) => logic.selectAbnormalItem(
                          list: data,
                          item: p,
                          isSelected: v!,
                        ),
                      )),
                ],
              ),
            ),
          ]
        ],
      ),
    );
  }

  _bodyWidgets(bool isAbnormal) {
    return isAbnormal
        ? [
            Row(
              children: [
                Expanded(
                  child: CupertinoSearchTextField(
                    decoration: BoxDecoration(
                      color: Colors.white54,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    placeholder: '请输入物料编号货物料描或跟踪号述进行过滤',
                    onChanged: (v) => state.abnormalSearchText.value = v,
                  ),
                ),
                Obx(() {
                  var list = logic.showAbnormalList();
                  return Checkbox(
                    value: list.isNotEmpty &&
                        list.every((v) => v.every((v3) => v3.isSelected.value)),
                    onChanged: (v) {
                      for (var p in list) {
                        for (var p2 in p) {
                          p2.isSelected.value = v!;
                        }
                      }
                    },
                  );
                })
              ],
            ),
            Expanded(
              child: Obx(() {
                var list = logic.showAbnormalList();
                return ListView.builder(
                  itemCount: list.length,
                  itemBuilder: (c, i) => _abnormalItem(list, i),
                );
              }),
            ),
            Row(
              children: [
                Expanded(
                  child: Obx(() => CombinationButton(
                        combination: Combination.left,
                        backgroundColor: Colors.red,
                        isEnabled: logic
                            .selectedAbnormalItem()
                            .any((v) => v.isSelected.value),
                        text: '删除',
                        click: () => askDialog(
                          content: '确定要删除所选标签吗？',
                          confirm: () => logic.deleteAbnormal(),
                        ),
                      )),
                ),
                Expanded(
                  child: Obx(() => CombinationButton(
                        combination: Combination.right,
                        backgroundColor: Colors.orange,
                        isEnabled: logic
                            .selectedAbnormalItem()
                            .any((v) => v.isSelected.value),
                        text: '重处理',
                        click: () => logic.checkAbnormalSubmitData(
                          (list, maxDate) => _pickDate(
                            date: maxDate,
                            callback: (date) => logic.reSubmit(
                              postingDate: date,
                              submitList: list,
                            ),
                          ),
                        ),
                      )),
                ),
              ],
            )
          ]
        : [
            Row(
              children: [
                Obx(() => textSpan(
                      hint: '件数：',
                      text: logic.getScanned().toString(),
                    )),
                const SizedBox(width: 10),
                Expanded(
                  child: CupertinoSearchTextField(
                    decoration: BoxDecoration(
                      color: Colors.white54,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    placeholder: '请输入物料编号货物料描或跟踪号述进行过滤',
                    onChanged: (v) => state.materialSearchText.value = v,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                expandedFrameText(
                  text: '跟踪号',
                  borderColor: Colors.black,
                  flex: 3,
                  backgroundColor: Colors.green.shade100,
                  alignment: Alignment.center,
                ),
                expandedFrameText(
                  text: '待装柜数',
                  borderColor: Colors.black,
                  flex: 2,
                  backgroundColor: Colors.green.shade100,
                  alignment: Alignment.center,
                ),
                expandedFrameText(
                  text: '单位',
                  borderColor: Colors.black,
                  flex: 1,
                  backgroundColor: Colors.green.shade100,
                  alignment: Alignment.center,
                ),
                expandedFrameText(
                  text: '扫码数量',
                  borderColor: Colors.black,
                  flex: 2,
                  backgroundColor: Colors.green.shade100,
                  alignment: Alignment.center,
                ),
              ],
            ),
            Expanded(
              child: Obx(() {
                var list = logic.showMaterialList();
                return ListView.builder(
                  itemCount: list.length,
                  itemBuilder: (c, i) => _item(list[i]),
                );
              }),
            ),
            SizedBox(
              width: double.infinity,
              child: CombinationButton(
                text: '提交',
                click: () {
                  logic.checkMaterialSubmitData(
                    (list) => _pickDate(
                      callback: (date) => logic.submit(
                        postingDate: date,
                        submitList: list,
                      ),
                    ),
                  );
                },
              ),
            )
          ];
  }

  _initScan() {
    pdaScanner(scan: (code) => logic.scanCode(code));
  }

  @override
  void initState() {
    _initScan();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _operationSheet();
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return pageBody(
      popTitle: '确定要退出装柜扫码吗？',
      actions: [
        IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () => _muneSheet(),
        ),
        IconButton(
          icon: const Icon(Icons.settings_outlined),
          onPressed: () => _operationSheet(),
        )
      ],
      body: Padding(
        padding: const EdgeInsets.only(left: 10, right: 10, bottom: 10),
        child: Obx(() => Column(
              children: _bodyWidgets(state.isAbnormal.value),
            )),
      ),
    );
  }

  @override
  void dispose() {
    Get.delete<SapPackingScanLogic>();
    super.dispose();
  }
}
