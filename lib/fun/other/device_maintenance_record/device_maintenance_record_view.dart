import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jd_flutter/bean/http/response/device_maintenance_list_info.dart';
import 'package:jd_flutter/fun/other/device_maintenance_record/device_maintenance_record_logic.dart';
import 'package:jd_flutter/utils/utils.dart';
import 'package:jd_flutter/widget/combination_button_widget.dart';
import 'package:jd_flutter/widget/custom_widget.dart';
import 'package:jd_flutter/widget/dialogs.dart';
import 'package:jd_flutter/widget/edit_text_widget.dart';
import 'package:jd_flutter/widget/picker/picker_view.dart';
import 'package:jd_flutter/widget/scanner.dart';

class DeviceMaintenanceRecordPage extends StatefulWidget {
  const DeviceMaintenanceRecordPage({super.key});

  @override
  State<DeviceMaintenanceRecordPage> createState() =>
      _DeviceMaintenanceRecordViewState();
}

class _DeviceMaintenanceRecordViewState
    extends State<DeviceMaintenanceRecordPage> {
  final logic = Get.put(DeviceMaintenanceRecordLogic());
  final state = Get.find<DeviceMaintenanceRecordLogic>().state;

  _item(DeviceMaintenanceListInfo data) {
    return InkWell(
      onTap: () {logic.searchDeviceInfo(data.deviceNo.toString());},
      onLongPress: (){
        if (checkUserPermission('705080113'))
          {
            reasonInputPopup(
              title: [
                 Center(
                  child: Text(
                    'device_maintenance_nullify'.tr,
                    style: const TextStyle(fontSize: 20, color: Colors.white),
                  ),
                )
              ],
              hintText: 'device_maintenance_reason_for_invalidation'.tr,
              isCanCancel: true,
              confirm: (s){
                Get.back();
                logic.repairOrderVoid(
                    interId: data.interID.toString(),
                    reason: s,
                    success: (msg) {
                          successDialog(content: msg, back: () => Get.back());
                        });
              },
            );
          }
        else {
          showSnackBar(title: 'shack_bar_warm'.tr, message: 'device_maintenance_no_invalidation_permission'.tr);
        }
      },
      child: Container(
        height: 75,
        margin: const EdgeInsets.only(left: 5, right: 5, bottom: 5),
        padding: const EdgeInsets.all(5),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                expandedTextSpan(
                  hint: 'device_maintenance_equipment_name'.tr,
                  text: data.deviceName.toString(),
                  textColor: Colors.blue,
                ),
                expandedTextSpan(
                  hint: 'device_maintenance_equipment_number'.tr,
                  text: data.deviceNo.toString(),
                  textColor: Colors.blue,
                ),
                expandedTextSpan(
                  hint: 'device_maintenance_creator'.tr,
                  text: data.biller.toString(),
                  textColor: Colors.blue,
                ),
              ],
            ),
            Row(
              children: [
                expandedTextSpan(
                  hint: 'device_maintenance_reason_invalidation'.tr,
                  text: data.voidReason.toString(),
                  textColor: Colors.blue,
                ),
                expandedTextSpan(
                  hint: 'device_maintenance_cancel_time'.tr,
                  text: data.voidDate.toString(),
                  textColor: Colors.blue,
                ),
                expandedTextSpan(
                  hint: 'device_maintenance_invalid_person'.tr,
                  text: data.voider.toString(),
                  textColor: Colors.blue,
                ),
              ],
            ),
            Row(
              children: [
                expandedTextSpan(
                  flex: 3,
                  hint: 'device_maintenance_keeper'.tr,
                  text: data.custodian.toString(),
                  textColor: Colors.blue,
                ),
                expandedTextSpan(
                  flex: 3,
                  hint: 'device_maintenance_long_press_to_void'.tr,
                  text: '',
                  hintColor: Colors.red,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return pageBodyWithBottomSheet(
      title: 'device_maintenance_equipment_maintenance_records'.tr,
      bottomSheet: [
        Row(
          children: [
            Expanded(
              flex: 3,
              child: EditText(
                onChanged: (v) => state.deviceNumber = v,
                hint: 'device_maintenance_equipment_numbers'.tr,
              ),
            ),
            Expanded(
              flex: 1,
              child: CombinationButton(
                text: 'device_maintenance_scan_device_qr_code'.tr,
                click: () => Get.to(() => const Scanner())?.then((v) {
                  if (v != null) {
                    logic.searchDeviceInfo(
                        v?.substring(v?.lastIndexOf('=') + 1));
                  }
                }),
              ),
            )
          ],
        ),
        DatePicker(pickerController: logic.startDate),
        DatePicker(pickerController: logic.endDate),
      ],
      query: () => logic.searchDeviceList(),
      body: Obx(
        () => ListView.builder(
          padding: const EdgeInsets.only(left: 5, right: 5),
          itemCount: state.dataList.length,
          itemBuilder: (context, index) => _item(state.dataList[index]),
        ),
      ),
    );
  }
}
