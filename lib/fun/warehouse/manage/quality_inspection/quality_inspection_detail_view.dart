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
                        hint:
                            'product_quality_inspection_detail_defective_projects'
                                .tr,
                        text: data.abnormalDescription ?? '',
                        textColor: Colors.black54,
                      ),
                      textSpan(
                        hint:
                            'product_quality_inspection_detail_monthly_defect_rate'
                                .tr,
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
                    onTap: () => logic.addAbnormalRecord(abnormalItem: data),
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
                            .where(
                                (v) => v.abnormalItemId == data.abnormalItemId)
                            .length;
                        return Text(
                          'product_quality_inspection_detail_record'
                              .trArgs([slight > 0 ? ' ($slight)' : '']),
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
        ]));
  }

  @override
  Widget build(BuildContext context) {
    return pageBody(
      title: 'product_quality_inspection_detail_quality_inspection'.tr,
      actions: [
        Obx(() => CombinationButton(
              combination: Combination.left,
              isEnabled: logic.allRecordsRechecked(),
              text: 'product_quality_inspection_detail_inspection_completed'.tr,
              click: () => askDialog(
                  content:
                      'product_quality_inspection_detail_inspection_completed_tips'
                          .tr,
                  confirm: () => logic.inspectionCompleted()),
            )),
        Obx(() => CombinationButton(
              combination: Combination.right,
              isEnabled: logic.hasInspectionAbnormalRecords(),
              text: 'product_quality_inspection_detail_inspection_records'.tr,
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
                  hint: 'product_quality_inspection_inspection_unit'.tr,
                  text: state.qiDetailInspectionUnit.value,
                ),
                textSpan(
                  hint: 'product_quality_inspection_instruction_no_tips'.tr,
                  text: state.qiDetailInstructionNo.value,
                ),
                textSpan(
                  hint: 'product_quality_inspection_type_body_tips'.tr,
                  text: state.qiDetailTypeBody.value,
                ),
                textSpan(
                  hint: 'product_quality_inspection_customer_po_tips'.tr,
                  text: state.qiDetailCustomerPo.value,
                ),
                textSpan(
                  hint: 'product_quality_inspection_detail_total'.tr,
                  text: state.qiDetailTotalQuantity.value.toShowString(),
                ),
                textSpan(
                  hint: 'product_quality_inspection_detail_inspector'.tr,
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
                    childAspectRatio: 3 / 2.2,
                  ),
                  itemBuilder: (c, i) => _item(state.qiDetailAbnormalItems[i]),
                )),
          ),
        ],
      ),
    );
  }
}
