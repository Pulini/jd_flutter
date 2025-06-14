import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jd_flutter/bean/http/response/quality_inspection_info.dart';
import 'package:jd_flutter/fun/warehouse/manage/quality_inspection/quality_inspection_logic.dart';
import 'package:jd_flutter/fun/warehouse/manage/quality_inspection/quality_inspection_state.dart';
import 'package:jd_flutter/widget/custom_widget.dart';

class QualityInspectionReportPage extends StatefulWidget {
  const QualityInspectionReportPage({super.key});

  @override
  State<QualityInspectionReportPage> createState() =>
      _QualityInspectionReportPageState();
}

class _QualityInspectionReportPageState
    extends State<QualityInspectionReportPage> {
  final QualityInspectionLogic logic = Get.find<QualityInspectionLogic>();
  final QualityInspectionState state = Get.find<QualityInspectionLogic>().state;

  Widget _item(QualityInspectionReportInfo data) {
    return Container(
      margin: const EdgeInsets.only(left: 5, right: 5, bottom: 10),
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        gradient: LinearGradient(
          colors: [Colors.blue.shade100, Colors.green.shade100],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              expandedTextSpan(
                hint: 'product_quality_inspection_inspection_unit'.tr,
                text: data.inspectionUnit ?? '',
                textColor: Colors.green.shade700,
              ),
              textSpan(
                hint: 'product_quality_inspection_report_total_inspections_qty'
                    .tr,
                text: data.getAbnormalTotalQty().toString(),
                textColor: Colors.red,
              ),
              const SizedBox(width: 20),
              textSpan(
                hint:
                    'product_quality_inspection_report_total_reinspections_qty'
                        .tr,
                text: data.getReInspectionTotalQty().toString(),
                textColor: Colors.purple,
              ),
              const SizedBox(width: 20),
            ],
          ),
          const Divider(indent: 10, endIndent: 10),
          for (var order in data.abnormalRecords!)
            Container(
              width: double.infinity,
              margin: const EdgeInsets.only(left: 10, right: 10, bottom: 10),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300, width: 2),
                borderRadius: const BorderRadius.all(Radius.circular(10)),
                color: Colors.white,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      textSpan(
                        hint:
                            'product_quality_inspection_report_order_number'.tr,
                        text: order.workOrderNo ?? '',
                      ),
                      Text(
                        'product_quality_inspection_report_last_modify_date'
                            .trArgs([order.lastModifyDate ?? '']),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      expandedFrameText(
                        flex: 5,
                        text: 'product_quality_inspection_report_abnormal_description'.tr,
                        borderColor: Colors.black87,
                        backgroundColor: Colors.green.shade100,
                      ),
                      expandedFrameText(
                        text: 'product_quality_inspection_report_inspector'.tr,
                        alignment: Alignment.center,
                        borderColor: Colors.black87,
                        backgroundColor: Colors.green.shade100,
                      ),
                      expandedFrameText(
                        flex: 2,
                        text: 'product_quality_inspection_report_inspection_time'.tr,
                        alignment: Alignment.center,
                        borderColor: Colors.black87,
                        backgroundColor: Colors.green.shade100,
                      ),
                      expandedFrameText(
                        text: 'product_quality_inspection_report_reinspector'.tr,
                        alignment: Alignment.center,
                        borderColor: Colors.black87,
                        backgroundColor: Colors.green.shade100,
                      ),
                      expandedFrameText(
                        flex: 2,
                        text: 'product_quality_inspection_report_reinspection_time'.tr,
                        alignment: Alignment.center,
                        borderColor: Colors.black87,
                        backgroundColor: Colors.green.shade100,
                      ),
                      expandedFrameText(
                        text: 'product_quality_inspection_report_state'.tr,
                        alignment: Alignment.center,
                        borderColor: Colors.black87,
                        backgroundColor: Colors.green.shade100,
                      ),
                    ],
                  ),
                  for (var i = 0; i < order.abnormalRecordsDetail!.length; ++i)
                    _tableLine(order.abnormalRecordsDetail!, i)
                ],
              ),
            )
        ],
      ),
    );
  }

  _tableLine(List<ReportAbnormalRecordsDetailInfo> list, int index) {
    var records = list[index];
    return Row(
      children: [
        expandedFrameText(
          flex: 5,
          text: '${records.abnormalDescription}',
          borderColor: Colors.black87,
          backgroundColor: index % 2 == 0 ? Colors.grey.shade200 : Colors.white,
        ),
        expandedFrameText(
          alignment: Alignment.center,
          text: '${records.firstInspector}',
          borderColor: Colors.black87,
          backgroundColor: index % 2 == 0 ? Colors.grey.shade200 : Colors.white,
        ),
        expandedFrameText(
          flex: 2,
          alignment: Alignment.center,
          text: '${records.firstInspectionDate}',
          borderColor: Colors.black87,
          backgroundColor: index % 2 == 0 ? Colors.grey.shade200 : Colors.white,
        ),
        expandedFrameText(
          alignment: Alignment.center,
          text: '${records.lastInspector}',
          borderColor: Colors.black87,
          backgroundColor: index % 2 == 0 ? Colors.grey.shade200 : Colors.white,
        ),
        expandedFrameText(
          flex: 2,
          alignment: Alignment.center,
          text: '${records.lastInspectionDate}',
          borderColor: Colors.black87,
          backgroundColor: index % 2 == 0 ? Colors.grey.shade200 : Colors.white,
        ),
        expandedFrameText(
          text: records.getAbnormalStatusText(),
          alignment: Alignment.center,
          borderColor: Colors.black87,
          backgroundColor: index % 2 == 0 ? Colors.grey.shade200 : Colors.white,
          textColor: records.getAbnormalStatusColor(),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return pageBody(
      title: 'product_quality_inspection_report_inspection_summary'.tr,
      body: ListView.builder(
        itemCount: state.report.length,
        itemBuilder: (c, i) => _item(state.report[i]),
      ),
    );
  }
}
