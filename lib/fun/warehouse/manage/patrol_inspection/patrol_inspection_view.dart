import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jd_flutter/bean/http/response/patrol_inspection_info.dart';
import 'package:jd_flutter/fun/warehouse/manage/patrol_inspection/patrol_inspection_abnormal_list_view.dart';
import 'package:jd_flutter/fun/warehouse/manage/patrol_inspection/patrol_inspection_dialog.dart';
import 'package:jd_flutter/widget/combination_button_widget.dart';
import 'package:jd_flutter/widget/custom_widget.dart';
import 'package:jd_flutter/widget/picker/picker_controller.dart';
import 'package:jd_flutter/widget/picker/picker_view.dart';

import 'patrol_inspection_logic.dart';
import 'patrol_inspection_state.dart';

class PatrolInspectionPage extends StatefulWidget {
  const PatrolInspectionPage({super.key});

  @override
  State<PatrolInspectionPage> createState() => _PatrolInspectionPageState();
}

class _PatrolInspectionPageState extends State<PatrolInspectionPage> {
  final PatrolInspectionLogic logic = Get.put(PatrolInspectionLogic());
  final PatrolInspectionState state = Get.find<PatrolInspectionLogic>().state;

  var dpcDate = DatePickerController(PickerType.date,
      buttonName: 'product_patrol_inspection_inspection_date'.tr);

  Widget _qualifiedItem() => GestureDetector(
        onTap: () => logic.addPatrolInspectionAbnormalRecord(),
        child: Container(
          margin: const EdgeInsets.all(3),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.green, width: 2),
            borderRadius: BorderRadius.circular(10),
            color: Colors.green.shade300,
          ),
          alignment: Alignment.center,
          child: Text(
            'product_patrol_inspection_qualified'.tr,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 100,
              color: Colors.white,
            ),
          ),
        ),
      );

  Widget _item(PatrolInspectionAbnormalItemInfo data) {
    return Container(
      margin: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.blueAccent, width: 2),
        borderRadius: BorderRadius.circular(10),
        color: Colors.white,
      ),
      child: Column(
        children: [
          Expanded(
            child: Row(
              children: [
                const SizedBox(width: 5),
                GestureDetector(
                  onTap: () => modifyTagKeyDialog(data: data),
                  child: Obx(() => Text(
                        data.tag.value,
                        style: const TextStyle(
                          fontSize: 70,
                          height: 0,
                          fontWeight: FontWeight.bold,
                        ),
                      )),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      expandedTextSpan(
                        maxLines: 4,
                        hint: 'product_patrol_inspection_defective_projects'.tr,
                        text: data.abnormalDescription ?? '',
                        textColor: Colors.black54,
                      ),
                      textSpan(
                        hint:
                            'product_patrol_inspection_monthly_defect_rate'.tr,
                        text: data.getDefectRate(),
                        textColor: Colors.red,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => logic.addPatrolInspectionAbnormalRecord(
                      abnormalItem: data,
                    ),
                    child: Container(
                      alignment: Alignment.center,
                      decoration: const BoxDecoration(
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(8),
                          bottomRight: Radius.circular(8),
                        ),
                        color: Colors.orange,
                      ),
                      child: Obx(() {
                        var slight = state.abnormalRecordList
                            .where(
                                (v) => v.abnormalItemId == data.abnormalItemId)
                            .length;
                        return Text(
                          'product_patrol_inspection_record'.trArgs(
                            [slight > 0 ? ' ($slight)' : ''],
                          ),
                          style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              fontSize: 20),
                        );
                      }),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _typeBodyItem(int index) => Obx(() => GestureDetector(
        onTap: () => state.typeBodyIndex.value = index,
        child: Container(
          width: 200,
          alignment: Alignment.center,
          margin: const EdgeInsets.only(right: 5),
          padding: const EdgeInsets.all(5),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(5),
            color: state.typeBodyIndex.value == index
                ? Colors.green
                : Colors.blue.shade400,
          ),
          child: Text(
            state.typeBodyList[index].typeBody ?? '',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: Colors.white,
            ),
          ),
        ),
      ));

  List<Widget> _getQueryWidgets() {
    var widgets = <Widget>[];

    var line = Expanded(
      child: Text(
        logic.getSelectLine(),
        textAlign: TextAlign.center,
      ),
    );

    var refresh = CombinationButton(
      text: 'product_patrol_inspection_refresh'.tr,
      backgroundColor: Colors.red,
      combination: Combination.left,
      click: () => logic.getPatrolInspectionInfo(),
    );

    var change = CombinationButton(
      text: 'product_patrol_inspection_switching_lines'.tr,
      combination: Combination.left,
      click: () => changeLineDialog(
        lines: state.inspectionList,
        change: (index) => logic.changeLine(index),
      ),
    );

    var abnormalRecord = CombinationButton(
      text: 'product_patrol_inspection_abnormal_records'.tr,
      combination: state.inspectionList.length > 1
          ? Combination.right
          : Combination.intact,
      click: () => Get.to(() => const PatrolInspectionAbnormalListPage()),
    );
    if (state.inspectionList.isEmpty) {
      widgets = [
        Expanded(
          child: Text(
            state.errorMsg.value,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.red),
          ),
        ),
        refresh,
      ];
    } else if (state.inspectionList.length > 1) {
      widgets = [line, change, abnormalRecord];
    } else {
      widgets = [line, abnormalRecord];
    }
    return widgets;
  }

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      logic.getPatrolInspectionInfo();
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return pageBody(
      actions: [
        Container(
          width: 300,
          height: 45,
          margin: const EdgeInsets.only(right: 5),
          padding: const EdgeInsets.only(right: 5),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(50),
              bottomLeft: Radius.circular(50),
            ),
            border: Border.all(color: Colors.blue, width: 2),
          ),
          child: Obx(() => Row(children: _getQueryWidgets())),
        ),
        Container(
          width: 300,
          height: 45,
          margin: const EdgeInsets.only(right: 10),
          padding: const EdgeInsets.only(left: 5),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: const BorderRadius.only(
              topRight: Radius.circular(50),
              bottomRight: Radius.circular(50),
            ),
            border: Border.all(color: Colors.blue, width: 2),
          ),
          child: Row(
            children: [
              Expanded(
                child: DatePicker(
                  pickerController: dpcDate,
                  margin: 0,
                  height: 33,
                ),
              ),
              const SizedBox(width: 10),
              CombinationButton(
                text: 'product_patrol_inspection_view_inspection_summary'.tr,
                click: () =>
                    logic.getPatrolInspectionReport(dpcDate.getDateFormatYMD()),
              )
            ],
          ),
        ),
      ],
      body: Column(
        children: [
          Expanded(
            child: Obx(() => GridView.builder(
                  itemCount: state.abnormalItemList.length + 1,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 5,
                    childAspectRatio: 3 / 2.2,
                  ),
                  itemBuilder: (c, i) => i == 0
                      ? _qualifiedItem()
                      : state.abnormalItemList.isEmpty
                          ? Container()
                          : _item(state.abnormalItemList[i - 1]),
                )),
          ),
          Container(
            height: 50,
            margin: const EdgeInsets.all(5),
            padding: const EdgeInsets.all(5),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              border: Border.all(width: 2, color: Colors.blue),
              color: Colors.white,
            ),
            child: Obx(() => ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: state.typeBodyList.length,
                  itemBuilder: (c, i) => _typeBodyItem(i),
                )),
          )
        ],
      ),
    );
  }

  @override
  void dispose() {
    Get.delete<PatrolInspectionLogic>();
    super.dispose();
  }
}
