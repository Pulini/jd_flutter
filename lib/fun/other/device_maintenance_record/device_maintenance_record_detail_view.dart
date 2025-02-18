import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jd_flutter/fun/other/device_maintenance_record/device_maintenance_record_logic.dart';

import '../../../bean/http/response/device_maintenance_info.dart';
import '../../../widget/combination_button_widget.dart';
import '../../../widget/custom_widget.dart';

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

  _item(RepairEntryData data) {
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
    );
  }

  @override
  Widget build(BuildContext context) {
    return pageBody(
      title: '设备信息',
      actions: [CombinationButton(text: '报修', click: () => {
         logic.goRepair()
      }),const SizedBox(width: 10,)],
      body: Obx(
        () => Container(
          margin: const EdgeInsets.only(left: 10),
          padding: const EdgeInsets.all(5),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              textSpan(
                hint: '设备名称：'.tr,
                text: state.deviceData.value.deviceMessage!.deviceName ?? '',
              ),
              textSpan(
                hint: '设备编号：'.tr,
                text: state.deviceData.value.deviceMessage!.deviceNo ?? '',
              ),
              textSpan(
                hint: '设备型号：'.tr,
                text: state.deviceData.value.deviceMessage!.model??'' ,
              ),
              textSpan(
                hint: '保管单位：'.tr,
                text: state.deviceData.value.deviceMessage!.custodianDept ?? '',
              ),
              textSpan(
                hint: '保管人：'.tr,
                text: state.deviceData.value.deviceMessage!.custodianName ?? '',
              ),
              textSpan(
                hint: '保管人电话：'.tr,
                text: state.deviceData.value.deviceMessage!.custodianTel ?? '',
              ),
              Center(
                child: Text(
                  state.deviceData.value.repairOrder == null
                      ? '最近无维修记录'
                      : '最近一次维修记录',
                  style: const TextStyle(color: Colors.red, fontSize: 18),
                ),
              ),
              Visibility(
                child: textSpan(
                  hint: '单据编号：'.tr,
                  text: state.deviceData.value.repairOrder!.number ?? '',
                ),
                visible: state.isHave.value,
              ),
              Visibility(
                child: textSpan(
                  hint: '故障说明：'.tr,
                  text: state.deviceData.value.repairOrder!.faultDescription ?? '',
                ),
                visible: state.isHave.value,
              ),
              Visibility(
                child: textSpan(
                  hint: '故障原因判断：'.tr,
                  text: state.deviceData.value.repairOrder!.issueCause ?? '',
                ),
                visible: state.isHave.value,
              ),
              Visibility(
                child: textSpan(
                  hint: '报修时间：'.tr,
                  text: state.deviceData.value.repairOrder!.repairTime ?? '',
                ),
                visible: state.isHave.value,
              ),
              Visibility(
                child: textSpan(
                  hint: '维修单位：'.tr,
                  text: state.deviceData.value.repairOrder!.maintenanceUnit ?? '',
                ),
                visible: state.isHave.value,
              ),
              Visibility(
                child: textSpan(
                  hint: '维修后评估及预防：'.tr,
                  text: state.deviceData.value.repairOrder!.assessmentPrevention ?? '',
                ),
                visible: state.isHave.value,
              ),
              Visibility(
                child: textSpan(
                  hint: '报修时间：'.tr,
                  text: state.deviceData.value.repairOrder!.inspectionTime ?? '',
                ),
                visible: state.isHave.value,
              ),
              Visibility(
                child: textSpan(
                  hint: '修复时间：'.tr,
                  text: state.deviceData.value.repairOrder!.repairTime ?? '',
                ),
                visible: state.isHave.value,
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
