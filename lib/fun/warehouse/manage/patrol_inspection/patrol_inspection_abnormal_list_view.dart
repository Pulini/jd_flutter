import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jd_flutter/bean/http/response/patrol_inspection_info.dart';
import 'package:jd_flutter/fun/warehouse/manage/patrol_inspection/patrol_inspection_logic.dart';
import 'package:jd_flutter/fun/warehouse/manage/patrol_inspection/patrol_inspection_state.dart';
import 'package:jd_flutter/widget/custom_widget.dart';
import 'package:jd_flutter/widget/dialogs.dart';

class PatrolInspectionAbnormalListPage extends StatefulWidget {
  const PatrolInspectionAbnormalListPage({super.key});

  @override
  State<PatrolInspectionAbnormalListPage> createState() =>
      _PatrolInspectionAbnormalListPageState();
}

class _PatrolInspectionAbnormalListPageState
    extends State<PatrolInspectionAbnormalListPage> {
  final PatrolInspectionLogic logic = Get.find<PatrolInspectionLogic>();
  final PatrolInspectionState state = Get.find<PatrolInspectionLogic>().state;

  Widget _item(List<PatrolInspectionAbnormalRecordInfo> group) {
    return Container(
      width: 500,
      margin: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.blueAccent, width: 2),
        borderRadius: BorderRadius.circular(10),
        color: Colors.grey.shade200,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.all(5),
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(8),
                topRight: Radius.circular(8),
              ),
              color: Colors.blue.shade100,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  group[0].typeBody ?? '',
                  maxLines: 2,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    textSpan(
                      hint: '巡查数：',
                      hintColor: Colors.black54,
                      text: group.length.toString(),
                      textColor: Colors.blue,
                    ),
                    textSpan(
                      hint: '合格数：',
                      hintColor: Colors.black54,
                      text: group
                          .where((v) => v.abnormalItemId == 'QUALIFIED')
                          .length
                          .toString(),
                      textColor: Colors.green.shade700,
                    ),
                    textSpan(
                      hint: '不良数：',
                      hintColor: Colors.black54,
                      text: group
                          .where((v) => v.abnormalItemId != 'QUALIFIED')
                          .length
                          .toString(),
                      textColor: Colors.red,
                    ),
                  ],
                )
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: group.length,
              itemBuilder: (c, i) => _subItem(group, i),
            ),
          ),
          Obx(() => group.any((v) => v.isSelect.value)
              ? SizedBox(
                  height: 40,
                  child: Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () => askDialog(
                            content: '确定要删除该条异常记录吗？',
                            confirm: () => logic.deleteAbnormalRecord(
                              abnormalRecord: group.firstWhere(
                                (v) => v.isSelect.value,
                              ),
                            ),
                          ),
                          child: Container(
                            alignment: Alignment.center,
                            decoration: const BoxDecoration(
                              borderRadius: BorderRadius.only(
                                bottomLeft: Radius.circular(8),
                              ),
                              color: Colors.orange,
                            ),
                            child: Text(
                              '撤回',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              : Container()),
        ],
      ),
    );
  }

  Widget _subItem(List<PatrolInspectionAbnormalRecordInfo> group, int index) {
    var data = group[index];
    return GestureDetector(
      onTap: () {
        if (!data.isSelect.value) {
          group.where((v) => v.isSelect.value).forEach((v) {
            v.isSelect.value = false;
          });
          data.isSelect.value = true;
        } else {
          data.isSelect.value = false;
        }
      },
      child: Obx(() => Container(
            height: 40,
            padding: const EdgeInsets.all(5),
            margin: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              border: Border.all(
                color: data.isSelect.value ? Colors.blue : Colors.black87,
                width: 2,
              ),
              borderRadius: BorderRadius.circular(5),
              color: data.isSelect.value ? Colors.blue.shade100 : Colors.white,
            ),
            alignment: Alignment.center,
            child: Row(children: [
              Expanded(
                child: Text(
                  data.abnormalItemId == 'QUALIFIED'
                      ? '巡检合格'
                      : state.abnormalItemList
                              .firstWhere((v) =>
                                  v.abnormalItemId == data.abnormalItemId)
                              .abnormalDescription ??
                          '',
                  style: TextStyle(
                    color: data.isSelect.value
                        ? Colors.blue
                        : data.abnormalItemId == 'QUALIFIED'
                            ? Colors.green.shade700
                            : Colors.black87,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                data.recordDate ?? '',
                style: TextStyle(
                  color: data.isSelect.value
                      ? Colors.blue
                      : data.abnormalItemId == 'QUALIFIED'
                          ? Colors.green.shade700
                          : Colors.black87,
                ),
              )
            ]),
          )),
    );
  }

  @override
  void initState() {
    for (var v in state.abnormalRecordList) {
      v.isSelect.value = false;
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return pageBody(
      title: '巡检异常记录',
      body: Obx(() {
        var group = logic.getAbnormalGroup();
        return ListView.builder(
          itemCount: group.length,
          scrollDirection: Axis.horizontal,
          itemBuilder: (c, i) => _item(group[i]),
        );
      }),
    );
  }
}
