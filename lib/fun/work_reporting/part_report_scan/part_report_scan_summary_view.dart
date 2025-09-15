import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jd_flutter/bean/http/response/report_details_info.dart';
import 'package:jd_flutter/fun/work_reporting/part_report_scan/part_report_scan_logic.dart';
import 'package:jd_flutter/fun/work_reporting/part_report_scan/part_report_scan_state.dart';
import 'package:jd_flutter/utils/extension_util.dart';
import 'package:jd_flutter/widget/combination_button_widget.dart';
import 'package:jd_flutter/widget/custom_widget.dart';
import 'package:jd_flutter/widget/dialogs.dart';

class PartReportScanSummaryPage extends StatefulWidget {
  const PartReportScanSummaryPage({super.key});

  @override
  State<PartReportScanSummaryPage> createState() =>
      _PartReportScanSummaryPageState();
}

class _PartReportScanSummaryPageState extends State<PartReportScanSummaryPage> {
  final PartReportScanLogic logic = Get.find<PartReportScanLogic>();
  final PartReportScanState state = Get.find<PartReportScanLogic>().state;

  _text({
    required String mes,
    required Color textColor,
    required Color backColor,
  }) {
    return Container(
      height: 35,
      decoration: BoxDecoration(
        color: backColor, // 背景颜色
        border: Border.all(
          color: Colors.black, // 边框颜色
          width: 1.0, // 边框宽度
        ),
      ),
      child: InkWell(child: Padding(
        padding: const EdgeInsets.all(7),
        child: Center(
          child: Text(
            mes,
            maxLines: 1,
            style: TextStyle(
              color: textColor,
            ),
          ),
        ),
      ),onTap: ()=>{
        if(mes.isNotEmpty){
          showSnackBar(message: mes)
        }
      },)
    );
  }

  _title() {
    return Row(
      children: [
        Expanded(
            flex: 3,
            child: _text(
                backColor: Colors.blue.shade400,
                mes: 'part_report_summary_process'.tr,
                textColor: Colors.white,
               )),
        Expanded(
            flex: 3,
            child: _text(
                backColor: Colors.blue.shade400,
                mes: 'part_report_summary_instruction'.tr,
                textColor: Colors.white,
                )),
        Expanded(
            flex: 2,
            child: _text(
                backColor: Colors.blue.shade400,
                mes: 'part_report_summary_size'.tr,
                textColor: Colors.white,
               )),
        Expanded(
            flex: 2,
            child: _text(
                backColor: Colors.blue.shade400,
                mes: 'part_report_summary_instruction_qty'.tr,
                textColor: Colors.white,
               )),
        Expanded(
            flex: 2,
            child: _text(
                backColor: Colors.blue.shade400,
                mes: 'part_report_summary_qty'.tr,
                textColor: Colors.white,
                )),
        Expanded(
            flex: 3,
            child: _text(
                backColor: Colors.blue.shade400,
                mes: 'part_report_summary_personal'.tr,
                textColor: Colors.white,
               )),
      ],
    );
  }

  _item1(SummaryLists data) {
    var backColors = Colors.black;
    var textColors = Colors.black;
    var processColors = Colors.black;
    var instructionColors = Colors.black;
    var sizeColors = Colors.black;
    var qtyColors = Colors.black;
    var process = '';
    var instruction = '';

    switch (data.type) {
      case 0:
        {
          backColors = Colors.white;
          textColors = Colors.black;
          process = data.name ?? '';
          instruction = data.mtonoQty.toShowString();
          break;
        }
      case 1:
        {
          backColors = Colors.yellow.shade200;
          process = 'part_report_summary_total_instructions'.tr;
          processColors = Colors.black;
          instruction = data.name ?? '';
          break;
        }
      case 2:
        {

          backColors = Colors.blue.shade200;
          process = 'part_report_summary_total_components'.tr;
          processColors = Colors.black;
          instruction = data.name ?? '';
          break;
        }
    }

    return Row(
      children: [
        Expanded(
            flex: 3,
            child: _text(
              mes: data.mtono ?? '',
              textColor: textColors,
              backColor: backColors,
            )),
        Expanded(
            flex: 3,
            child: _text(
                mes: process,
                textColor: processColors,
                backColor: backColors,
             )),
        Expanded(
            flex: 2,
            child: _text(
                mes: data.size ?? '',
                textColor: sizeColors,
                backColor: backColors,
                )),
        Expanded(
            flex: 2,
            child: _text(
                mes: instruction,
                textColor: instructionColors,
                backColor: backColors,
                )),
        Expanded(
            flex: 2,
            child: _text(
                mes: data.qty.toShowString(),
                textColor: qtyColors,
                backColor: backColors,
                )),
        Expanded(
            flex: 3,
            child: _text(
                mes: data.empName ?? '',
                textColor: textColors,
                backColor: backColors,
                )),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return pageBody(
      title: 'part_report_summary_table'.tr,
        body: Column(
      children: [
        _title(),
        Expanded(
          child: Obx(() => ListView.builder(
                padding: const EdgeInsets.all(0),
                itemCount: state.reportInfo.length,
                itemBuilder: (context, index) =>
                    _item1(state.reportInfo[index]),
              )),
        ),
        SizedBox(
          width: double.maxFinite,
          child: CombinationButton(
            //提交
            text: 'part_report_submit'.tr,
            click: () {
              askDialog(
                content: 'part_report_summary_sure_submit'.tr,
                confirm: () {
                  logic.submitBarCodeReport(submitSuccess: (mes) {
                    successDialog(
                        content: mes, back: (){Get.back(result: true);});
                  });
                },
              );
            },
          ),
        )
      ],
    ));
  }
}
