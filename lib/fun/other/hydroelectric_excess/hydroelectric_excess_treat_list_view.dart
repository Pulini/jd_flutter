import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jd_flutter/bean/http/response/device_list_info.dart';
import 'package:jd_flutter/fun/other/hydroelectric_excess/hydroelectric_excess_logic.dart';
import 'package:jd_flutter/widget/custom_widget.dart';
import 'package:jd_flutter/widget/edit_text_widget.dart';

class HydroelectricExcessTreatListPage extends StatefulWidget {
  const HydroelectricExcessTreatListPage({super.key});

  @override
  State<HydroelectricExcessTreatListPage> createState() =>
      _HydroelectricExcessTreatListPageState();
}

class _HydroelectricExcessTreatListPageState
    extends State<HydroelectricExcessTreatListPage> {
  final logic = Get.find<HydroelectricExcessLogic>();
  final state = Get.find<HydroelectricExcessLogic>().state;
  var tecDeviceNumber = TextEditingController();
  var tecBedNumber = TextEditingController();

  _item(DeviceListInfo data) {
    return InkWell(
      onTap: () {
        logic.searchRoom(data: data, isBack: true);
      },
      child: Container(
        height: 100,
        margin: const EdgeInsets.only(left: 5, right: 5, bottom: 10),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            expandedTextSpan(
              hint: 'hydroelectric_organization_name'.tr,
              text: data.organizeName.toString(),
              textColor: Colors.blue,
            ),
            Row(
              children: [
                expandedTextSpan(
                  hint: 'hydroelectric_account_number'.tr,
                  text: data.number.toString(),
                  textColor: Colors.blue,
                ),
                expandedTextSpan(
                  hint: 'hydroelectric_device_name'.tr,
                  text: data.organizeName.toString(),
                  textColor: Colors.blue,
                ),
              ],
            ),
            Row(
              children: [
                expandedTextSpan(
                  hint: 'hydroelectric_type'.tr,
                  text: data.typeName.toString(),
                  textColor: Colors.blue,
                ),
                expandedTextSpan(
                  hint: 'hydroelectric_building_number'.tr,
                  text: data.dormitoriesName.toString(),
                  textColor: Colors.blue,
                ),
              ],
            ),
            expandedTextSpan(
              hint: 'hydroelectric_room_numbers'.tr,
              text: data.roomNumber.toString(),
              textColor: Colors.blue,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return pageBodyWithBottomSheet(
        title: 'hydroelectric_water_reading'.tr,
        bottomSheet: [
          EditText(
            controller: tecDeviceNumber,
            hint: 'hydroelectric_equipment_number'.tr,
          ),
          EditText(
            controller: tecBedNumber,
            hint: 'hydroelectric_bed_number'.tr,
          ),
          Obx(() => RadioGroup(
                groupValue: state.select.value,
                onChanged: (v) => state.select.value = v!,
                child: Row(
                  children: [
                    Expanded(
                      child: ListTile(
                        title: Text('hydroelectric_all'.tr),
                        leading: const Radio(value: '0'),
                      ),
                    ),
                    Expanded(
                      child: ListTile(
                        title: Text('hydroelectric_to_be_copied'.tr),
                        leading: const Radio(value: '1'),
                      ),
                    ),
                    Expanded(
                      child: ListTile(
                        title: Text('hydroelectric_dorP'.tr),
                        leading: const Radio(value: '2'),
                      ),
                    )
                  ],
                ),
              )),
        ],
        query: () {
          logic.searchData(
            deviceNumber: tecDeviceNumber.text,
            bedNumber: tecBedNumber.text,
          );
        },
        body: Obx(
          () => ListView.builder(
            padding: const EdgeInsets.only(left: 5, right: 5),
            itemCount: state.dataList.length,
            itemBuilder: (context, index) => _item(state.dataList[index]),
          ),
        ));
  }
}
