import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jd_flutter/bean/http/response/device_maintenance_info.dart';
import 'package:jd_flutter/fun/other/device_maintenance_record/device_maintenance_record_logic.dart';
import 'package:jd_flutter/widget/combination_button_widget.dart';
import 'package:jd_flutter/widget/custom_widget.dart';



class DeviceMaintenanceRecordDetailPage extends StatefulWidget {
  const DeviceMaintenanceRecordDetailPage({super.key});

  @override
  State<DeviceMaintenanceRecordDetailPage> createState() =>
      _DeviceMaintenanceRecordDetailPageState();
}

class _DeviceMaintenanceRecordDetailPageState
    extends State<DeviceMaintenanceRecordDetailPage> {
  final logic = Get.find<DeviceMaintenanceRecordLogic>();
  final state = Get.find<DeviceMaintenanceRecordLogic>().state;

  Container _item(RepairEntryData data) {
    return Container(
      height: 140,
      margin: const EdgeInsets.only(right: 15, bottom: 10),
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
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
    );
  }

  @override
  Widget build(BuildContext context) {
    return pageBody(
      title: 'device_maintenance_title_device_information'.tr,
      actions: [CombinationButton(text: 'device_maintenance_repair'.tr, click: () {
         logic.goRepair();
      }),const SizedBox(width: 10,)],
      body: Obx(
        () => Container(
          margin: const EdgeInsets.only(left: 10),
          padding: const EdgeInsets.all(5),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              textSpan(
                hint: 'device_maintenance_equipment_name'.tr,
                text: state.deviceData.value.deviceMessage!.deviceName?? '',
              ),
              textSpan(
                hint: 'device_maintenance_equipment_number'.tr,
                text: state.deviceData.value.deviceMessage!.deviceNo?? '',
              ),
              textSpan(
                hint: 'device_maintenance_equipment_model'.tr,
                text: state.deviceData.value.deviceMessage!.model?? '',
              ),
              textSpan(
                hint: 'device_maintenance_custodian_unit'.tr,
                text: state.deviceData.value.deviceMessage!.custodianDept?? '',
              ),
              textSpan(
                hint: 'device_maintenance_custodian'.tr,
                text: state.deviceData.value.deviceMessage!.custodianName?? '',
              ),
              textSpan(
                hint: 'device_maintenance_custodian_phone'.tr,
                text: state.deviceData.value.deviceMessage!.custodianTel?? '',
              ),
              Center(
                child: Text(
                  state.deviceData.value.repairOrder == null
                      ? 'device_maintenance_no_records'.tr
                      : 'device_maintenance_last_records'.tr,
                  style: const TextStyle(color: Colors.red, fontSize: 18),
                ),
              ),
              Visibility(
                visible: state.isHave.value,
                child: textSpan(
                  hint: 'device_maintenance_document_number'.tr,
                  text: state.deviceData.value.repairOrder!.number?? '',
                ),
              ),
              Visibility(
                visible: state.isHave.value,
                child: textSpan(
                  hint: 'device_maintenance_title_fault_description'.tr,
                  text: state.deviceData.value.repairOrder!.faultDescription?? '',
                ),
              ),
              Visibility(
                visible: state.isHave.value,
                child: textSpan(
                  hint: 'device_maintenance_fault_cause_determination'.tr,
                  text: state.deviceData.value.repairOrder!.issueCause?? '',
                ),
              ),
              Visibility(
                visible: state.isHave.value,
                child: textSpan(
                  hint: 'device_maintenance_title_maintenance_organization'.tr,
                  text: state.deviceData.value.repairOrder!.maintenanceUnit?? '',
                ),
              ),
              Visibility(
                visible: state.isHave.value,
                child: textSpan(
                  hint: 'device_maintenance_title_prevention'.tr,
                  text: state.deviceData.value.repairOrder!.assessmentPrevention?? '',
                ),
              ),
              Visibility(
                visible: state.isHave.value,
                child: textSpan(
                  hint: 'device_maintenance_title_repair_time'.tr,
                  text: state.deviceData.value.repairOrder!.inspectionTime?? '',
                ),
              ),
              Visibility(
                visible: state.isHave.value,
                child: textSpan(
                  hint: 'device_maintenance_title_fixed_time'.tr,
                  text: state.deviceData.value.repairOrder!.repairTime?? '',
                ),
              ),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(5),
                  itemCount: state
                      .deviceData.value.repairOrder?.repairEntryData?.length,
                  itemBuilder: (_, i) => _item(
                      state.deviceData.value.repairOrder!.repairEntryData![i]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
