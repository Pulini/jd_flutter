import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:jd_flutter/bean/http/response/device_maintenance_info.dart';
import 'package:jd_flutter/widget/combination_button_widget.dart';
import 'package:jd_flutter/widget/custom_widget.dart';
import 'package:jd_flutter/widget/dialogs.dart';
import 'package:jd_flutter/widget/edit_text_widget.dart';
import 'package:jd_flutter/widget/picker/picker_view.dart';
import 'package:jd_flutter/widget/spinner_widget.dart';

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
      onTap: () {
        addWorkerDialog(click: () {
          state.addRepairEntryData(success: () {
            Navigator.of(context).pop();
          });
        });
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
        onLongPress: () {
          state.deleteRepairEntry(data);
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            expandedTextSpan(
              hint: 'device_maintenance_manufacturer_brand'.tr,
              text: data.manufacturer.toString(),
              textColor: Colors.blue,
            ),
            expandedTextSpan(
              hint: 'device_maintenance_replace_accessory_name'.tr,
              text: data.accessoriesName.toString(),
              textColor: Colors.blue,
            ),
            expandedTextSpan(
              hint: 'device_maintenance_quantity'.tr,
              text: data.quantity.toString(),
              textColor: Colors.blue,
            ),
            expandedTextSpan(
              hint: 'device_maintenance_specifications'.tr,
              text: data.specification.toString(),
              textColor: Colors.blue,
            ),
            expandedTextSpan(
              hint: 'device_maintenance_unit'.tr,
              text: data.unit.toString(),
              textColor: Colors.blue,
            ),
            expandedTextSpan(
              hint: 'device_maintenance_remarks'.tr,
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
          title: Text('device_maintenance_add_components'.tr),
          content: Column(
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 15),
              _inputSearchText(
                hint: 'device_maintenance_manufacturer_brand'.tr,
                onChanged: (s) {
                  state.brand = s;
                },
              ),
              const SizedBox(height: 5),
              _inputSearchText(
                hint: 'device_maintenance_replace_accessory_name'.tr,
                onChanged: (s) {
                  state.partName = s;
                },
              ),
              const SizedBox(height: 5),
              _inputSearchText(
                hint: 'device_maintenance_quantity'.tr,
                inputType: inputNumber,
                onChanged: (s){
                  state.partNumber = s;
                },
              ),
              const SizedBox(height: 5),
              _inputSearchText(
                hint: 'device_maintenance_unit'.tr,
                onChanged: (s) {
                  state.partUnit = s;
                },
              ),
              const SizedBox(height: 5),
              _inputSearchText(
                hint: 'device_maintenance_specifications'.tr,
                onChanged: (s) {
                  state.partNorms = s;
                },
              ),
              const SizedBox(height: 5),
              _inputSearchText(
                hint: 'device_maintenance_remarks'.tr,
                onChanged: (s)  {
                  state.partRemark = s;
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
        title: 'device_maintenance_equipment_repair_report'.tr,
        body: Column(
          children: [
            Row(
              children: [
                Expanded(
                  flex: 3,
                  child: EditText(
                      hint: 'device_maintenance_holding_artificial_number'.tr,
                      onChanged: (s) {logic.searchPeople(s);}),
                ),
                Obx(() => Expanded(
                    child: Text(state.peoPleInfo.value.empName == null
                        ? ''
                        : state.peoPleInfo.value.empName.toString())))
              ],
            ),
            EditText(
                hint: 'device_maintenance_maintenance_organization'.tr,
                onChanged: (s){state.repairUnit = s;}),
            EditText(
                hint: 'device_maintenance_maintenance_location'.tr,
                onChanged: (s){state.repairPart = s;}),
            EditText(
                hint: 'device_maintenance_fault_description'.tr,
                onChanged: (s){state.repairReason = s;}),
            DatePicker(pickerController: logic.repairStartDate),
            DatePicker(pickerController: logic.repairEndDate),
            Spinner(controller: logic.spinnerControllerWorkShop),
            EditText(
                hint: 'device_maintenance_prevention'.tr,
                onChanged: (s){state.repairPrevent = s;}),
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
                text: 'device_maintenance_submit'.tr,
                click: ()  {
                  logic.submitRecordData(
                    success: (s) => {
                      successDialog(
                        content: s,
                        back: () => Get.back(),
                      ),
                    },
                  );
                },
              ),
            )
          ],
        ));
  }
}
