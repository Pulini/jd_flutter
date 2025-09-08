import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jd_flutter/bean/http/response/report_info.dart';
import 'package:jd_flutter/fun/warehouse/code_list_report/code_list_report_logic.dart';
import 'package:jd_flutter/fun/warehouse/code_list_report/code_list_report_state.dart';
import 'package:jd_flutter/utils/extension_util.dart';
import 'package:jd_flutter/widget/combination_button_widget.dart';
import 'package:jd_flutter/widget/custom_widget.dart';
import 'package:jd_flutter/widget/dialogs.dart';

class CodeListReportPage extends StatefulWidget {
  const CodeListReportPage({super.key});

  @override
  State<CodeListReportPage> createState() => _CodeListReportPageState();
}

class _CodeListReportPageState extends State<CodeListReportPage> {
  final CodeListReportLogic logic = Get.put(CodeListReportLogic());
  final CodeListReportState state = Get.find<CodeListReportLogic>().state;

  @override
  Widget build(BuildContext context) {
    return pageBody(
        title: 'code_list_report'.tr,
        body: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Obx(
                    () => SizedBox(
                      width: state.tableWeight.value.toDouble(),
                      child: ListView.builder(
                        itemCount: state.reportDataList.length,
                        itemBuilder: (c, i) => _item2(
                            state.reportDataList[i].dataList ?? [],
                            state.reportDataList[i].getBkg()),
                      ),
                    ),
                  )),
            ),
            SizedBox(
              width: double.infinity,
              child: CombinationButton(
                text: 'code_list_report_submit'.tr,
                click: () => {
                  askDialog(
                    title: 'code_list_report_tips'.tr,
                    content: 'code_list_report_submit_code'.tr,
                    confirm: () => Get.back(result: true),
                  )
                },
              ),
            )
          ],
        ));
  }

  Widget _item2(List<DataList> list, Color bkg) {
    return Row(
      children: [
        for (var i in list)
          Container(
            width: i.width?.add(12),
            height: 45,
            padding: const EdgeInsets.only(left: 5, right: 5),
            decoration: BoxDecoration(
                border: Border.all(color: Colors.grey), color: bkg),
            alignment: i.content?.isNum == true
                ? Alignment.centerRight
                : Alignment.center,
            child: Text(
              maxLines: 2,
              i.content ?? '',
              style: TextStyle(
                height: 1,
                color: i.getTextColor(),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
      ],
    );
  }

  @override
  void initState() {
    if (Get.arguments != null) {
      state.getData(Get.arguments['reportData']);
    }
    super.initState();
  }
}
