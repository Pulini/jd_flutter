
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
      onTap: () => {
          logic.searchDeviceInfo(data.deviceNo.toString())
      },
      onLongPress: () => {
        if (checkUserPermission('705080113'))
          {
            reasonInputPopup(
              title: [
                const Center(
                  child: Text(
                    '作废',
                    style: TextStyle(fontSize: 20, color: Colors.white),
                  ),
                )
              ],
              hintText: '请输入作废原因',
              isCanCancel: true,
              confirm: (s) => {
                Get.back(),
                logic.repairOrderVoid(
                    interId: data.interID.toString(),
                    reason: s,
                    success: (msg) => {
                          successDialog(content: msg, back: () => Get.back()),
                        })
              },
            )
          }
        else
          {showSnackBar(title: '警告', message: '没有作废权限')}
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
                  hint: '设备名称：',
                  text: data.deviceName.toString(),
                  textColor: Colors.blue,
                ),
                expandedTextSpan(
                  hint: '设备编号：',
                  text: data.deviceNo.toString(),
                  textColor: Colors.blue,
                ),
                expandedTextSpan(
                  hint: '制单人：',
                  text: data.biller.toString(),
                  textColor: Colors.blue,
                ),
              ],
            ),
            Row(
              children: [
                expandedTextSpan(
                  hint: '作废原因：',
                  text: data.voidReason.toString(),
                  textColor: Colors.blue,
                ),
                expandedTextSpan(
                  hint: '作废时间：',
                  text: data.voidDate.toString(),
                  textColor: Colors.blue,
                ),
                expandedTextSpan(
                  hint: '作废人：',
                  text: data.voider.toString(),
                  textColor: Colors.blue,
                ),
              ],
            ),
            Row(
              children: [
                expandedTextSpan(
                  flex: 3,
                  hint: '保管人：',
                  text: data.custodian.toString(),
                  textColor: Colors.blue,
                ),
                expandedTextSpan(
                  flex: 3,
                  hint: '长按作废！',
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
      title: '设备维修记录',
      bottomSheet: [
        Row(
          children: [
            Expanded(
              flex: 3,
              child: EditText(
                onChanged: (v) => state.deviceNumber = v,
                hint: '设备编号',
              ),
            ),
            Expanded(
              flex: 1,
              child: CombinationButton(
                text: '扫描设备二维码',
                click: () {
                  Get.to(() => const Scanner())?.then((v) {
                    logic.searchDeviceInfo(v.toString().substring(v.toString().lastIndexOf("=") + 1));
                  });
                },
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
