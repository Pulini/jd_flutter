import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jd_flutter/bean/http/response/group_dispatch_info.dart';
import 'package:jd_flutter/widget/combination_button_widget.dart';
import 'package:jd_flutter/widget/custom_widget.dart';
import 'package:jd_flutter/widget/scanner.dart';

import 'group_dispatch_logic.dart';
import 'group_dispatch_state.dart';

class GroupDispatchPage extends StatefulWidget {
  const GroupDispatchPage({super.key});

  @override
  State<GroupDispatchPage> createState() => _GroupDispatchPageState();
}

class _GroupDispatchPageState extends State<GroupDispatchPage> {
  final GroupDispatchLogic logic = Get.put(GroupDispatchLogic());
  final GroupDispatchState state = Get.find<GroupDispatchLogic>().state;

  var dispatchNoController = TextEditingController(text: 'GXPG250103497/1');

  var boxShadow = const [
    BoxShadow(
      color: Colors.black26,
      blurRadius: 6,
      offset: Offset(2, 2),
      spreadRadius: 1.5,
    )
  ];

  Widget boxTitle(String title) => IntrinsicHeight(
        child: Padding(
          padding: const EdgeInsets.all(5),
          child: Row(
            children: [
              const VerticalDivider(
                width: 5,
                thickness: 5,
                color: Colors.red,
                indent: 2,
              ),
              const SizedBox(width: 5),
              Text(title,
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      );

  Widget partItem(ComponentItem data) => Container(
        margin: const EdgeInsets.only(left: 10, right: 10, bottom: 10),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5),
          color: Colors.white,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            IntrinsicHeight(
              child: Row(
                children: [
                  Container(
                    width: 80,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.blueAccent, width: 2),
                      borderRadius: BorderRadius.circular(7),
                    ),
                    child: AspectRatio(
                      aspectRatio: 3 / 2,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(7),
                        child: cachedNetworkImage(
                          data.pictureUrl,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          data.componentName,
                          style: const TextStyle(
                            color: Colors.black54,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Spacer(),
                        Row(
                          children: [
                            Text('team_leader_process_flow'.tr),
                            Expanded(child: data.getProcessText()),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 10),
            for (var item in data.materialList)
              Text(
                item.materialText,
                style: const TextStyle(color: Colors.grey),
              )
          ],
        ),
      );

  Widget parts() {
    return Container(
      height: double.infinity,
      margin: const EdgeInsets.only(left: 10, bottom: 10, right: 5),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(10),
        boxShadow: boxShadow,
      ),
      child: Column(
        children: [
          boxTitle('team_leader_part_material_detail'.tr),
          Expanded(
            child: Obx(() => ListView.builder(
                  itemCount: state.partList.length,
                  itemBuilder: (c, i) => partItem(state.partList[i]),
                )),
          ),
        ],
      ),
    );
  }

  Widget personnelAllocation() {
    return Column(
      children: [
        title(),
        Expanded(
          child: Container(
            margin: const EdgeInsets.only(left: 10, bottom: 10, right: 5),
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(10),
              boxShadow: boxShadow,
            ),
            child: ListView(),
          ),
        ),
      ],
    );
  }

  Widget title() => Container(
      margin: const EdgeInsets.only(left: 10, bottom: 10, right: 5),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(10),
        boxShadow: boxShadow,
      ),
      child: Column(
        children: [
          boxTitle('team_leader_work_order_base_info'.tr),
          Container(
            margin: const EdgeInsets.only(left: 10, right: 10, bottom: 10),
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: Colors.white,
            ),
            child: Obx(() => Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: textSpan(
                            hint: 'team_leader_factory_name'.tr,
                            hintColor: Colors.black54,
                            text: state.titleInfo.value?.factoryName ?? '',
                          ),
                        ),
                        Expanded(
                          child: textSpan(
                            hint: 'team_leader_production_line_group'.tr,
                            hintColor: Colors.black54,
                            text: state.titleInfo.value?.departName ?? '',
                          ),
                        ),
                        Expanded(
                          child: textSpan(
                            hint: 'team_leader_doc_date'.tr,
                            hintColor: Colors.black54,
                            text: state.titleInfo.value?.date ?? '',
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: textSpan(
                            hint: 'team_leader_product_no'.tr,
                            hintColor: Colors.black54,
                            text: state.titleInfo.value?.productNumber ?? '',
                          ),
                        ),
                        Expanded(
                          child: textSpan(
                            hint: 'team_leader_process'.tr,
                            hintColor: Colors.black54,
                            text: state.titleInfo.value?.processName ?? '',
                          ),
                        ),
                        Expanded(
                          child: textSpan(
                            hint: 'team_leader_pack_info'.tr,
                            hintColor: Colors.black54,
                            text: state.titleInfo.value?.packag ?? '',
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: textSpan(
                            hint: 'team_leader_instruction'.tr,
                            hintColor: Colors.black54,
                            text: state.titleInfo.value?.mtono ?? '',
                          ),
                        ),
                        Expanded(
                          child: textSpan(
                            hint: 'team_leader_order_number'.tr,
                            hintColor: Colors.black54,
                            text: state.titleInfo.value?.cardNo ?? '',
                          ),
                        ),
                        Expanded(
                          child: textSpan(
                            hint: 'team_leader_doc_rd_no'.tr,
                            hintColor: Colors.black54,
                            text: state.titleInfo.value?.batchNo ?? '',
                          ),
                        ),
                      ],
                    ),
                  ],
                )),
          ),
        ],
      ));

  @override
  Widget build(BuildContext context) {
    return pageBody(
      actions: [
        Container(
          margin: const EdgeInsets.all(5),
          width: 400,
          height: 40,
          child: TextField(
            controller: dispatchNoController,
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.only(
                top: 0,
                bottom: 0,
                left: 10,
                right: 10,
              ),
              filled: true,
              fillColor: Colors.white,
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(50),
                borderSide: const BorderSide(
                  color: Colors.transparent,
                ),
              ),
              border: const OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(50)),
              ),
              labelText: 'team_leader_input_work_order_no'.tr,
              labelStyle: const TextStyle(
                  color: Colors.black54, fontWeight: FontWeight.w500),
              prefixIcon: IconButton(
                onPressed: () => dispatchNoController.text = 'GXPG',
                icon:
                    const Icon(Icons.replay_circle_filled, color: Colors.grey),
              ),
              suffixIcon: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CombinationButton(
                    icon: const Icon(Icons.search, color: Colors.white),
                    combination: Combination.left,
                    text: 'team_leader_search'.tr,
                    click: () => logic.queryOrder(dispatchNoController.text),
                  ),
                  CombinationButton(
                    icon:
                        const Icon(Icons.qr_code_scanner, color: Colors.white),
                    combination: Combination.right,
                    text: 'team_leader_scan_work_order'.tr,
                    click: () => scannerDialog(
                      detect: (code) => logic.queryOrder(code),
                    ),
                  )
                ],
              ),
            ),
          ),
        )
      ],
      body: Row(
        children: [
          Expanded(flex: 4, child: parts()),
          Expanded(flex: 6, child: personnelAllocation()),
        ],
      ),
    );
  }

  @override
  void dispose() {
    Get.delete<GroupDispatchLogic>();
    super.dispose();
  }
}
