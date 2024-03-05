import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../http/response/Visit_data_list_info.dart';
import '../../../route.dart';
import '../../../utils.dart';
import '../../../widget/custom_widget.dart';
import 'visit_register_logic.dart';

class VisitRegisterPage extends StatefulWidget {
  //界面
  const VisitRegisterPage({super.key});

  @override
  State<VisitRegisterPage> createState() => _VisitRegisterPageState();
}

class _VisitRegisterPageState extends State<VisitRegisterPage> {
  final logic = Get.put(VisitRegisterLogic());
  final state = Get.find<VisitRegisterLogic>().state;

  _item(VisitDataListInfo data) {
    return GestureDetector(
      onTap: () => {}, //获取详情点击事件
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
                  Expanded(flex:1,child: Row(
                    children: [
                      Text('visit_item_people_name'.tr),
                      Text(
                        data.name ?? "",
                        style: const TextStyle(color: Colors.green),
                      ),
                    ],
                  ))
                  
                  // Row(
                  //   children: [
                  //     Text(
                  //       'visit_item_interviewee_name'.tr,
                  //     ),
                  //     Text(
                  //       data.intervieweeName ?? "",
                  //       style: const TextStyle(
                  //         color: Colors.green,
                  //       ),
                  //     ),
                  //   ],
                  // ),
                ],
              )
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
    )) ;
  }

  @override
  Widget build(BuildContext context) {
    return pageBodyWithDrawer(
        title: getFunctionTitle(),
        children: [
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
              title: 'visit_button_add_record'.tr, click: () => {}),
        ],
        query: () {},
        body: listView());
  }

  @override
  void dispose() {
    Get.delete<VisitRegisterLogic>();
    super.dispose();
  }
}
