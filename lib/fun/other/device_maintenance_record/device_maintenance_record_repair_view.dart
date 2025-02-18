import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../../bean/http/response/device_maintenance_info.dart';
import '../../../widget/combination_button_widget.dart';
import '../../../widget/custom_widget.dart';
import '../../../widget/dialogs.dart';
import '../../../widget/edit_text_widget.dart';
import '../../../widget/picker/picker_view.dart';
import '../../../widget/spinner_widget.dart';
import 'device_maintenance_record_logic.dart';

class DeviceMaintenanceRecordRepairPage extends StatefulWidget {
  const DeviceMaintenanceRecordRepairPage({super.key});

  @override
  State<DeviceMaintenanceRecordRepairPage> createState() =>
      _DeviceMaintenanceRecordRepairPageState();
}

class _DeviceMaintenanceRecordRepairPageState
    extends State<DeviceMaintenanceRecordRepairPage> {
  final logic = Get.find<DeviceMaintenanceRecordLogic>();
  final state = Get.find<DeviceMaintenanceRecordLogic>().state;

  addWorkerItem() {
    return InkWell(
      onTap: () => {
        addWorkerDialog(
            click: () => {
                  state.addRepairEntryData(
                      success: () => {Navigator.of(context).pop()})
                })
      },
      child: const Center(
        child: Icon(
          Icons.add,
          color: Colors.blueAccent,
          size: 150,
        ),
      ),
    );
  }

  _workerItem(RepairEntryData data) {
    return Container(
      height: 140,
      margin: const EdgeInsets.only(right: 15, bottom: 10),
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      child: InkWell(
        onLongPress: () => {state.deleteRepairEntry(data)},
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            expandedTextSpan(
              hint: '厂商/品牌:',
              text: data.manufacturer.toString(),
              textColor: Colors.blue,
            ),
            expandedTextSpan(
              hint: '更换配件名称:',
              text: data.accessoriesName.toString(),
              textColor: Colors.blue,
            ),
            expandedTextSpan(
              hint: '数量:',
              text: data.quantity.toString(),
              textColor: Colors.blue,
            ),
            expandedTextSpan(
              hint: '规格:',
              text: data.specification.toString(),
              textColor: Colors.blue,
            ),
            expandedTextSpan(
              hint: '单位:',
              text: data.unit.toString(),
              textColor: Colors.blue,
            ),
            expandedTextSpan(
              hint: '备注:',
              text: data.remarks.toString(),
              textColor: Colors.blue,
            ),
          ],
        ),
      ),
    );
  }

  var inputNumber = [
    FilteringTextInputFormatter.allow(RegExp('[0-9]')),
  ];

  _inputSearchText(
      {required String hint,
      Function(String v)? onChanged,
      List<TextInputFormatter>? inputType}) {
    return Row(
      children: [
        Container(
          width: 80,
          margin: const EdgeInsets.only(right: 10),
          alignment: Alignment.centerRight,
          child: Text(hint, style: const TextStyle(color: Colors.black)),
        ),
        Expanded(
            child: CupertinoTextField(
          inputFormatters: inputType,
          onChanged: (s) => {onChanged?.call(s)},
        )),
      ],
    );
  }

  addWorkerDialog({
    Function()? click,
  }) {
    Get.dialog(PopScope(
      canPop: false,
      child: StatefulBuilder(builder: (context, dialogSetState) {
        return AlertDialog(
          title: const Text('添加零部件'),
          content: Column(
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 15),
              _inputSearchText(
                hint: '厂商/品牌：',
                onChanged: (s) => {state.brand = s},
              ),
              const SizedBox(height: 5),
              _inputSearchText(
                hint: '更换配件名称：',
                onChanged: (s) => {state.partName = s},
              ),
              const SizedBox(height: 5),
              _inputSearchText(
                hint: '数量：',
                inputType: inputNumber,
                onChanged: (s) => {
                  state.partNumber = s,
                },
              ),
              const SizedBox(height: 5),
              _inputSearchText(
                hint: '单位：',
                onChanged: (s) => {
                  state.partUnit = s,
                },
              ),
              const SizedBox(height: 5),
              _inputSearchText(
                hint: '规格：',
                onChanged: (s) => {
                  state.partNorms = s,
                },
              ),
              const SizedBox(height: 5),
              _inputSearchText(
                hint: '备注：',
                onChanged: (s) => {
                  state.partRemark = s,
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                click?.call();
              },
              child: Text('dialog_default_confirm'.tr),
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
      }),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return pageBody(
        title: '设备报修',
        body: Column(
          children: [
            Row(
              children: [
                Expanded(
                  flex: 3,
                  child: EditText(
                      hint: '持有人工号', onChanged: (s) => {logic.searchPeople(s)}),
                ),
                Obx(() => Expanded(
                    child: Text(state.peoPleInfo.value.empName == null
                        ? ""
                        : state.peoPleInfo.value.empName.toString())))
              ],
            ),
            EditText(hint: '维修单位', onChanged: (s) => {state.repairUnit = s}),
            EditText(hint: '检修部位', onChanged: (s) => {state.repairPart = s}),
            EditText(hint: '故障说明', onChanged: (s) => {state.repairReason = s}),
            DatePicker(pickerController: logic.repairStartDate),
            DatePicker(pickerController: logic.repairEndDate),
            Spinner(controller: logic.spinnerControllerWorkShop),
            EditText(
                hint: '维修后评估及预防', onChanged: (s) => {state.repairPrevent = s}),
            Expanded(
              child: Obx(
                () => ListView.builder(
                  itemCount: state.repairEntryData.length + 1,
                  itemBuilder: (c, i) => i == state.repairEntryData.length
                      ? addWorkerItem()
                      : _workerItem(state.repairEntryData[i]),
                ),
              ),
            ),
            SizedBox(
              width: double.maxFinite,
              child: CombinationButton(
                text: '提交',
                click: () => {
                  logic.submitRecordData(
                    success: (s) => {
                      successDialog(
                        content: s,
                        back: () => Get.back(),
                      ),
                    },
                  )
                },
              ),
            )
          ],
        ));
  }
}
