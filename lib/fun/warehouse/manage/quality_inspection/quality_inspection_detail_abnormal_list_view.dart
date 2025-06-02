import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jd_flutter/bean/http/response/quality_inspection_info.dart';
import 'package:jd_flutter/fun/warehouse/manage/quality_inspection/quality_inspection_logic.dart';
import 'package:jd_flutter/fun/warehouse/manage/quality_inspection/quality_inspection_state.dart';
import 'package:jd_flutter/utils/web_api.dart';
import 'package:jd_flutter/widget/custom_widget.dart';
import 'package:jd_flutter/widget/dialogs.dart';

class QualityInspectionDetailAbnormalListPage extends StatefulWidget {
  const QualityInspectionDetailAbnormalListPage({super.key});

  @override
  State<QualityInspectionDetailAbnormalListPage> createState() =>
      _QualityInspectionDetailAbnormalListPageState();
}

class _QualityInspectionDetailAbnormalListPageState
    extends State<QualityInspectionDetailAbnormalListPage> {
  final QualityInspectionLogic logic = Get.find<QualityInspectionLogic>();
  final QualityInspectionState state = Get.find<QualityInspectionLogic>().state;

  Widget _item(List<QualityInspectionAbnormalRecordInfo> group) {
    var abnormalItem = state.qiDetailAbnormalItems.firstWhere(
      (v) => v.abnormalItemId == group[0].abnormalItemId,
    );
    return Container(
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
              color: Colors.blue.shade200,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  abnormalItem.abnormalDescription ?? '',
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
                      hint: '不良数：',
                      hintColor: Colors.black54,
                      text: group.length.toString(),
                      textColor: Colors.red,
                    ),
                  ],
                )
              ],
            ),
          ),
          Expanded(
            child: GridView.builder(
              itemCount: group.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 5 / 1,
              ),
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
                      Expanded(
                        child: GestureDetector(
                          onTap: () => askDialog(
                            content: '确定复检结果为报废吗？',
                            confirm: () => logic.modifyAbnormalRecordStatus(
                              abnormalRecord: group.firstWhere(
                                (v) => v.isSelect.value,
                              ),
                              status: 3,
                            ),
                          ),
                          child: Container(
                            color: Colors.red,
                            alignment: Alignment.center,
                            child: Text(
                              '复检报废',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: GestureDetector(
                          onTap: () => askDialog(
                            content: '确定复检结果为合格吗？',
                            confirm: () => logic.modifyAbnormalRecordStatus(
                              abnormalRecord: group.firstWhere(
                                (v) => v.isSelect.value,
                              ),
                              status: 2,
                            ),
                          ),
                          child: Container(
                            alignment: Alignment.center,
                            decoration: const BoxDecoration(
                              borderRadius: BorderRadius.only(
                                bottomRight: Radius.circular(8),
                              ),
                              color: Colors.green,
                            ),
                            child: Text(
                              '复检合格',
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

  Widget _subItem(List<QualityInspectionAbnormalRecordInfo> group, int index) {
    var data = group[index];
    return GestureDetector(
      onTap: () {
        if (data.abnormalStatus != 2&&
            data.abnormalStatus != 3) {
          if (!data.isSelect.value) {
            group.where((v) => v.isSelect.value).forEach((v) {
              v.isSelect.value = false;
            });
            data.isSelect.value = true;
          } else {
            data.isSelect.value = false;
          }
        }
      },
      child: Obx(() => Container(
            margin: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              border: Border.all(
                color: data.isSelect.value
                    ? Colors.blue
                    : data.abnormalStatus == 2
                        ? Colors.green
                        : data.abnormalStatus == 3
                            ? Colors.red
                            : Colors.black87,
                width: 2,
              ),
              borderRadius: BorderRadius.circular(5),
              color: data.isSelect.value
                  ? Colors.blue.shade100
                  : data.abnormalStatus == 2
                      ? Colors.green.shade200
                      : data.abnormalStatus == 3
                          ? Colors.red.shade200
                          : Colors.white,
            ),
            alignment: Alignment.center,
            child: Text(
              data.modifyDate ?? '',
              style: TextStyle(
                color: data.isSelect.value
                    ? Colors.blue
                    : data.abnormalStatus == 2 || data.abnormalStatus == 3
                        ? Colors.white
                        : Colors.black87,
              ),
            ),
          )),
    );
  }

  @override
  void initState() {
    for (var v in state.qiDetailAbnormalRecords) {
      v.isSelect.value = false;
      logger.f(v.toJson());
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return pageBody(
      title: '质检异常记录',
      body: Obx(() {
        var group = groupBy(
          state.qiDetailAbnormalRecords,
          (v) => '${v.abnormalItemId}',
        ).values.toList();
        return GridView.builder(
          itemCount: group.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            childAspectRatio: 3 / 2,
          ),
          itemBuilder: (c, i) => _item(group[i]),
        );
      }),
    );
  }
}
