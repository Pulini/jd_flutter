import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jd_flutter/bean/http/response/patrol_inspection_info.dart';
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

  var dpcDate = DatePickerController(PickerType.date, buttonName: '巡检日期');

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
            '合格',
            style: TextStyle(
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
                        hint: '不良项目：',
                        text: data.abnormalDescription ?? '',
                        textColor: Colors.black54,
                      ),
                      textSpan(
                        hint: '月不良率：',
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
                        ),
                        color: Colors.orange,
                      ),
                      child: Obx(() {
                        var slight = state.abnormalRecordList
                            .where(
                                (v) => v.abnormalItemId == data.abnormalItemId)
                            .length;
                        return Text(
                          '记录${slight > 0 ? ' ($slight)' : ''}',
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

  List<Widget> _getQueryWidgets() {
    var widgets = <Widget>[];

    var line = Expanded(
      child: Text(
        logic.getSelectLine(),
        textAlign: TextAlign.center,
      ),
    );

    var refresh = CombinationButton(
      text: '刷新',
      backgroundColor: Colors.red,
      combination: Combination.left,
      click: () => logic.getPatrolInspectionInfo(),
    );

    var change = CombinationButton(
      text: '切换线别',
      combination: Combination.left,
      click: () => changeLineDialog(
        lines: state.inspectionList,
        change: (index) => logic.changeLine(index),
      ),
    );

    var abnormalRecord = CombinationButton(
      text: '异常记录',
      combination: state.inspectionList.length > 1
          ? Combination.right
          : Combination.intact,
      click: () {},
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
              CombinationButton(text: '查看巡检汇总', click: () {})
            ],
          ),
        ),
      ],
      body: Expanded(
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
    );
  }

  @override
  void dispose() {
    Get.delete<PatrolInspectionLogic>();
    super.dispose();
  }
}
