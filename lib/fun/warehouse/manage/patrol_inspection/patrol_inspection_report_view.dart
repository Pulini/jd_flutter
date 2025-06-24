import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jd_flutter/bean/http/response/patrol_inspection_info.dart';
import 'package:jd_flutter/fun/warehouse/manage/patrol_inspection/patrol_inspection_logic.dart';
import 'package:jd_flutter/fun/warehouse/manage/patrol_inspection/patrol_inspection_state.dart';
import 'package:jd_flutter/utils/utils.dart';
import 'package:jd_flutter/widget/custom_widget.dart';

class PatrolInspectionReportPage extends StatefulWidget {
  const PatrolInspectionReportPage({super.key});

  @override
  State<PatrolInspectionReportPage> createState() =>
      _PatrolInspectionReportPageState();
}

class _PatrolInspectionReportPageState
    extends State<PatrolInspectionReportPage> {
  final PatrolInspectionLogic logic = Get.find<PatrolInspectionLogic>();
  final PatrolInspectionState state = Get.find<PatrolInspectionLogic>().state;

  Widget _item(List<PatrolInspectionAbnormalRecordDetailInfo> group) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
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
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  flex: 3,
                  child: Text(
                    group[0].typeBody ?? '',
                    maxLines: 2,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ),
                expandedTextSpan(
                  hint: 'product_patrol_inspection_report_inspections_qty'.tr,
                  hintColor: Colors.black54,
                  text: group.length.toString(),
                  textColor: Colors.blue,
                ),
                expandedTextSpan(
                  hint: 'product_patrol_inspection_report_qualified_qty'.tr,
                  hintColor: Colors.black54,
                  text: group
                      .where((v) => v.abnormalDescription == '检验合格')
                      .length
                      .toString(),
                  textColor: Colors.green.shade700,
                ),
                expandedTextSpan(
                  hint: 'product_patrol_inspection_report_defects_qty'.tr,
                  hintColor: Colors.black54,
                  text: group
                      .where((v) => v.abnormalDescription != '检验合格')
                      .length
                      .toString(),
                  textColor: Colors.red,
                ),
              ],
            ),
          ),
          for (var i = 0; i < group.length; ++i) _subItem(group[i], i),
          const SizedBox(height: 5),
        ],
      ),
    );
  }

  Widget _subItem(PatrolInspectionAbnormalRecordDetailInfo data, int index) {
    return Container(
      color: index % 2 == 0 ? Colors.grey.shade200 : Colors.white,
      padding: const EdgeInsets.all(5),
      child: Row(children: [
        Expanded(
          child: Text(
            data.abnormalDescription ?? '',
            style: TextStyle(
              color: data.abnormalDescription == '检验合格'
                  ? Colors.green.shade700
                  : Colors.red,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Text(
          data.recordDate ?? '',
          style: TextStyle(
            color: data.abnormalDescription == '检验合格'
                ? Colors.green.shade700
                : Colors.red,
          ),
        )
      ]),
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
    var morningReport = logic.getMorningReport();
    var afternoonReport = logic.getAfternoonReport();
    return pageBody(
      actions: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            textSpan(
              hint: 'product_patrol_inspection_report_inspected_unit'.tr,
              text: state.reportUnit,
            ),
            const SizedBox(width: 20),
            textSpan(
              hint: 'product_patrol_inspection_report_total_inspections_qty'.tr,
              text: state.reportQuantity.toShowString(),
            ),
            const SizedBox(width: 20),
          ],
        ),
      ],
      title: 'product_patrol_inspection_report_inspection_summary'.tr,
      body: Padding(
        padding: const EdgeInsets.all(5),
        child: Row(
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: Colors.blue,
                    width: 2,
                  ),
                ),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(5),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'product_patrol_inspection_report_morning'.tr,
                            style: const TextStyle(
                              fontSize: 20,
                              color: Colors.blue,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          textSpan(
                            hint: 'product_patrol_inspection_report_inspections_qty'.tr,
                            hintColor: Colors.black54,
                            text: morningReport[1].toString(),
                            textColor: Colors.blue,
                          ),
                          textSpan(
                            hint: 'product_patrol_inspection_report_qualified_qty'.tr,
                            hintColor: Colors.black54,
                            text: morningReport[2].toString(),
                            textColor: Colors.green.shade700,
                          ),
                          textSpan(
                            hint: 'product_patrol_inspection_report_defects_qty'.tr,
                            hintColor: Colors.black54,
                            text: (morningReport[1] - morningReport[2])
                                .toString(),
                            textColor: Colors.red,
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: ListView.builder(
                        itemCount: morningReport[0].length,
                        itemBuilder: (c, i) => _item(morningReport[0][i]),
                      ),
                    )
                  ],
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: Colors.blue,
                    width: 2,
                  ),
                ),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(5),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'product_patrol_inspection_report_afternoon'.tr,
                            style: const TextStyle(
                              fontSize: 20,
                              color: Colors.blue,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          textSpan(
                            hint: 'product_patrol_inspection_report_inspections_qty'.tr,
                            hintColor: Colors.black54,
                            text: afternoonReport[1].toString(),
                            textColor: Colors.blue,
                          ),
                          textSpan(
                            hint: 'product_patrol_inspection_report_qualified_qty'.tr,
                            hintColor: Colors.black54,
                            text: afternoonReport[2].toString(),
                            textColor: Colors.green.shade700,
                          ),
                          textSpan(
                            hint: 'product_patrol_inspection_report_defects_qty'.tr,
                            hintColor: Colors.black54,
                            text: (afternoonReport[1] - afternoonReport[2])
                                .toString(),
                            textColor: Colors.red,
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: ListView.builder(
                        itemCount: afternoonReport[0].length,
                        itemBuilder: (c, i) => _item(afternoonReport[0][i]),
                      ),
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
