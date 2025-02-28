import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jd_flutter/bean/http/response/device_list_info.dart';
import 'package:jd_flutter/fun/other/hydroelectric_excess/hydroelectric_excess_logic.dart';
import 'package:jd_flutter/utils/web_api.dart';
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

  _item(DeviceListInfo data) {
    return InkWell(
      onTap: () => {state.searchRoom(data,true)},
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
              hint: '组织名称：',
              text: data.organizeName.toString(),
              textColor: Colors.blue,
            ),
            Row(
              children: [
                expandedTextSpan(
                  hint: '户号：',
                  text: data.number.toString(),
                  textColor: Colors.blue,
                ),
                expandedTextSpan(
                  hint: '设备名称：',
                  text: data.organizeName.toString(),
                  textColor: Colors.blue,
                ),
              ],
            ),
            Row(
              children: [
                expandedTextSpan(
                  hint: '类型：',
                  text: data.typeName.toString(),
                  textColor: Colors.blue,
                ),
                expandedTextSpan(
                  hint: '楼号：',
                  text: data.dormitoriesName.toString(),
                  textColor: Colors.blue,
                ),
              ],
            ),
            expandedTextSpan(
              hint: '房间号：',
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
        title: '水电抄度',
        bottomSheet: [
          EditText(
            onChanged: (v) => state.deviceNumber = v,
            hint: '设备编号',
          ),
          EditText(
            onChanged: (v) => state.bedNumber = v,
            hint: '床铺编号',
          ),
          Obx(() => Row(children: [
                Expanded(
                  flex: 1,
                  child: ListTile(
                    title: const Text('全部'),
                    leading: Radio(
                      value: '0',
                      groupValue: state.select.value,
                      onChanged: (v) {
                        state.select.value = v!;
                        state.stateToSearch.value = '1';
                        logger.d(v);
                      },
                    ),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: ListTile(
                    title: const Text('待抄'),
                    leading: Radio(
                      value: '1',
                      groupValue: state.select.value,
                      onChanged: (v) {
                        state.select.value = v!;
                        state.stateToSearch.value = '0';
                        logger.d(v);
                      },
                    ),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: ListTile(
                    title: const Text('已抄'),
                    leading: Radio(
                      value: '2',
                      groupValue: state.select.value,
                      onChanged: (v) {
                        state.select.value = v!;
                        state.stateToSearch.value = '1';
                        logger.d(v);
                      },
                    ),
                  ),
                )
              ]))
        ],
        query: () => {logic.searchData()},
        body: Obx(
          () => ListView.builder(
            padding: const EdgeInsets.only(left: 5, right: 5),
            itemCount: state.dataList.length,
            itemBuilder: (context, index) => _item(state.dataList[index]),
          ),
        ));
  }
}
