import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../http/response/Visit_data_list_info.dart';
import '../../../http/web_api.dart';
import '../../../route.dart';
import '../../../utils.dart';
import '../../../widget/custom_widget.dart';
import '../../../widget/picker/picker_view.dart';
import 'visit_register_logic.dart';

class VisitRegisterPage extends StatefulWidget {
  //界面
  const VisitRegisterPage({super.key});

  @override
  State<VisitRegisterPage> createState() => _VisitRegisterPageState();
}

enum SingingCharacter { lafayette, jefferson }

SingingCharacter? _character = SingingCharacter.lafayette;

class _VisitRegisterPageState extends State<VisitRegisterPage> {
  final logic = Get.put(VisitRegisterLogic());
  final state = Get.find<VisitRegisterLogic>().state;

  _item(VisitDataListInfo data) {
    return GestureDetector(
      onTap: () => {logger.f("点击事件-------")}, //获取详情点击事件
      child: Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(5),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.all(Radius.circular(10)),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                      //来访人
                      flex: 1,
                      child: Row(
                        children: [
                          Text('visit_item_people_name'.tr),
                          Text(data.name ?? "",
                              style: const TextStyle(color: Colors.green)),
                        ],
                      )),
                  Expanded(
                      //被访人
                      flex: 1,
                      child: Row(
                        children: [
                          Text('visit_item_interviewee_name'.tr),
                          Text(data.securityStaff ?? "",
                              style: const TextStyle(color: Colors.green))
                        ],
                      ))
                ],
              ),
              Row(
                children: [
                  Expanded(
                      //来访电话
                      flex: 1,
                      child: Row(
                        children: [
                          Text('visit_item_people_phone'.tr),
                          Text(data.phone ?? "",
                              style: const TextStyle(color: Colors.green)),
                        ],
                      )),
                  Expanded(
                      //被访部门
                      flex: 1,
                      child: Row(
                        children: [
                          Text('visit_item_interviewed_department'.tr),
                          Text(data.visitedDept ?? "",
                              style: const TextStyle(color: Colors.green))
                        ],
                      ))
                ],
              ),
              Row(
                children: [
                  Expanded(
                      //来访单位
                      flex: 1,
                      child: Row(
                        children: [
                          Text('visit_item_unit'.tr),
                          Text(data.unit ?? "",
                              style: const TextStyle(color: Colors.green)),
                        ],
                      )),
                  Expanded(
                      //来访人数
                      flex: 1,
                      child: Row(
                        children: [
                          Text('visit_item_number_of_visitors'.tr),
                          Text(data.unit ?? "",
                              style: const TextStyle(color: Colors.green))
                        ],
                      ))
                ],
              ),
              Row(
                children: [
                  Expanded(
                      //值班保安
                      flex: 1,
                      child: Row(
                        children: [
                          Text('visit_item_on_duty_security_guard'.tr),
                          Text(data.securityStaff ?? "",
                              style: const TextStyle(color: Colors.green)),
                        ],
                      )),
                  Expanded(
                      //车牌号码
                      flex: 1,
                      child: Row(
                        children: [
                          Text('visit_item_license_plate_number'.tr),
                          Text(data.carNo ?? "",
                              style: const TextStyle(color: Colors.green))
                        ],
                      ))
                ],
              ),
              Row(
                children: [
                  Expanded(
                      //值班保安
                      flex: 1,
                      child: Row(
                        children: [
                          Text('visit_item_visiting_time'.tr),
                          Text(data.dateTime ?? "",
                              style: const TextStyle(color: Colors.green)),
                        ],
                      )),
                  Expanded(
                      //车牌号码
                      flex: 1,
                      child: Row(
                        children: [
                          Text('visit_item_departure'.tr),
                          Text(data.leaveTime ?? "",
                              style: const TextStyle(color: Colors.green))
                        ],
                      ))
                ],
              ),
            ],
          )),
    );
  }

  listView() {
    return Obx(() => ListView.builder(
          padding: const EdgeInsets.all(8),
          itemCount: state.dataList.length,
          itemBuilder: (BuildContext context, int index) =>
              _item(state.dataList.toList()[index]),
        ));
  }

  @override
  Widget build(BuildContext context) {
    return pageBodyWithBottomSheet(
      title: getFunctionTitle(),
      bottomSheet: [
        visitButtonWidget(
            title: 'visit_button_scan_invitation_code'.tr,
            click: () => {
                  // Get.to(() => const DailyReportPage()),   //跳转界面
                }),
        visitButtonWidget(
            title: 'visit_button_search_recent_records'.tr,
            click: () => {
                  // searchDialog("123")
                }),
        visitButtonWidget(
            title: 'visit_button_add_record'.tr,
            click: () => {
                  //新增记录
                }),
        DatePicker(pickerController: logic.pickerControllerStartDate),
        DatePicker(pickerController: logic.pickerControllerEndDate),
        Row(children: [
          Expanded(child: ListTile(
            title: const Text('全部'),
            leading: Radio<SingingCharacter>(
              value: SingingCharacter.lafayette,
              groupValue: _character,
              onChanged: (SingingCharacter? value) {
                setState(() {
                  _character = value;
                });
              },
            ),
          )),

          Expanded(child: ListTile(
            title: const Text('未离场'),
            leading: Radio<SingingCharacter>(
              value: SingingCharacter.jefferson,
              groupValue: _character,
              onChanged: (SingingCharacter? value) {
                setState(() {
                  _character = value;
                });
              },
            ),
          ), )

        ])
      ],
      query: () => {},
      body: null,
    );
  }

  // @override
  // Widget build(BuildContext context) {
  //   return pageBodyWithDrawer(
  //       title: getFunctionTitle(),
  //       children: [
  //         visitButtonWidget(
  //             title: 'visit_button_scan_invitation_code'.tr,
  //             click: () => {
  //                   // Get.to(() => const DailyReportPage()),   //跳转界面
  //                 }),
  //         visitButtonWidget(
  //             title: 'visit_button_search_recent_records'.tr,
  //             click: () => {
  //                   // searchDialog("123")
  //                 }),
  //         visitButtonWidget(
  //             title: 'visit_button_add_record'.tr, click: () => {}),
  //       ],
  //       query: () {
  //         logic.getVisitList();
  //       },
  //       body: listView());
  // }

  @override
  void dispose() {
    Get.delete<VisitRegisterLogic>();
    super.dispose();
  }
}
