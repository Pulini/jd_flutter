import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jd_flutter/bean/http/response/quality_inspection_info.dart';
import 'package:jd_flutter/fun/warehouse/manage/quality_inspection/quality_inspection_detail_abnormal_list_view.dart';
import 'package:jd_flutter/fun/warehouse/manage/quality_inspection/quality_inspection_dialog.dart';
import 'package:jd_flutter/fun/warehouse/manage/quality_inspection/quality_inspection_logic.dart';
import 'package:jd_flutter/fun/warehouse/manage/quality_inspection/quality_inspection_state.dart';
import 'package:jd_flutter/utils/utils.dart';
import 'package:jd_flutter/widget/combination_button_widget.dart';
import 'package:jd_flutter/widget/custom_widget.dart';
import 'package:jd_flutter/widget/dialogs.dart';

class QualityInspectionDetailPage extends StatefulWidget {
  const QualityInspectionDetailPage({super.key});

  @override
  State<QualityInspectionDetailPage> createState() =>
      _QualityInspectionDetailPageState();
}

class _QualityInspectionDetailPageState
    extends State<QualityInspectionDetailPage> {
  final QualityInspectionLogic logic = Get.find<QualityInspectionLogic>();
  final QualityInspectionState state = Get.find<QualityInspectionLogic>().state;

  Widget _item(QualityInspectionAbnormalItemInfo data) {
    return Container(
        margin: const EdgeInsets.all(3),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.blueAccent, width: 2),
          borderRadius: BorderRadius.circular(10),
          color: Colors.white,
        ),
        child: Column(children: [
          Expanded(
            flex: 4,
            child: Row(
              children: [
                const SizedBox(width: 5),
                GestureDetector(
                  onTap: () {
                    debugPrint('data.tag.value=${data.tag.value}');
                    modifyTagKeyDialog(data: data);
                  },
                  child: Obx(() => Text(
                        data.tag.value,
                        style: const TextStyle(
                          fontSize: 80,
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
                      const SizedBox(height: 5),
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
                      const SizedBox(height: 5),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 3,
            child: Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => logic.addAbnormalRecord(
                      abnormalItem: data,
                      degree: AbnormalDegree.slight,
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
                        var slight = state.qiDetailAbnormalRecords
                            .where((v) =>
                                v.abnormalItemId == data.abnormalItemId &&
                                v.abnormalSeverity ==
                                    AbnormalDegree.slight.value)
                            .length;
                        return Text(
                          '轻微${slight > 0 ? ' ($slight)' : ''}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        );
                      }),
                    ),
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () => logic.addAbnormalRecord(
                      abnormalItem: data,
                      degree: AbnormalDegree.serious,
                    ),
                    child: Container(
                      alignment: Alignment.center,
                      decoration: const BoxDecoration(
                        borderRadius: BorderRadius.only(
                          bottomRight: Radius.circular(8),
                        ),
                        color: Colors.red,
                      ),
                      child: Obx(() {
                        var serious = state.qiDetailAbnormalRecords
                            .where((v) =>
                                v.abnormalItemId == data.abnormalItemId &&
                                v.abnormalSeverity ==
                                    AbnormalDegree.serious.value)
                            .length;
                        return Text(
                          '严重${serious > 0 ? ' ($serious)' : ''}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        );
                      }),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ]));
  }

  @override
  Widget build(BuildContext context) {
    return pageBody(
      title: '品质检验',
      actions: [
        Obx(() => CombinationButton(
              combination: Combination.left,
              isEnabled: logic.allRecordsRechecked(),
              text: '质检完成',
              click: () => askDialog(
                  content: '确定质检完成了吗？',
                  confirm: () => logic.inspectionCompleted()),
            )),
        Obx(() => CombinationButton(
              combination: Combination.right,
              isEnabled: logic.hasInspectionAbnormalRecords(),
              text: '质检记录',
              click: () =>
                  Get.to(() => const QualityInspectionDetailAbnormalListPage()),
            )),
      ],
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 10, right: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                textSpan(
                  hint: '生产单位：',
                  text: state.qiDetailInspectionUnit.value,
                ),
                textSpan(
                  hint: '指令：',
                  text: state.qiDetailInstructionNo.value,
                ),
                textSpan(
                  hint: '型体：',
                  text: state.qiDetailTypeBody.value,
                ),
                textSpan(
                  hint: 'PO号：',
                  text: state.qiDetailCustomerPo.value,
                ),
                textSpan(
                  hint: '总参量：',
                  text: state.qiDetailTotalQuantity.value.toShowString(),
                ),
                textSpan(
                  hint: '质检员：',
                  text: userInfo?.name ?? '',
                ),
              ],
            ),
          ),
          Expanded(
            child: Obx(() => GridView.builder(
                  itemCount: state.qiDetailAbnormalItems.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 5,
                    childAspectRatio: 3 / 2,
                  ),
                  itemBuilder: (c, i) => _item(state.qiDetailAbnormalItems[i]),
                )),
          ),
        ],
      ),
    );
  }
}
