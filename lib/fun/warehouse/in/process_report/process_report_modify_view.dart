import 'dart:math';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jd_flutter/fun/warehouse/in/process_report/process_report_logic.dart';
import 'package:jd_flutter/fun/warehouse/in/process_report/process_report_state.dart';
import 'package:jd_flutter/utils/web_api.dart';
import 'package:jd_flutter/widget/custom_widget.dart';
import '../../../../bean/http/response/process_modify_info.dart';
import '../../../../widget/combination_button_widget.dart';
import '../../../../widget/dialogs.dart';
import '../../../../widget/edit_text_widget.dart';
import '../../../../widget/scanner.dart';

class ProcessReportModifyPage extends StatefulWidget {
  const ProcessReportModifyPage({super.key});

  @override
  State<ProcessReportModifyPage> createState() =>
      _ProcessReportModifyPageState();
}

class _ProcessReportModifyPageState extends State<ProcessReportModifyPage> {
  final ProcessReportLogic logic = Get.find<ProcessReportLogic>();
  final ProcessReportState state = Get
      .find<ProcessReportLogic>()
      .state;

  _itemTitle() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _titleText(title: 'process_report_modify_barCode'.tr),
        _titleText(title: 'process_report_modify_size'.tr),
        _titleText(title: 'process_report_modify_original_quantity'.tr),
        _titleText(title: 'process_report_modify_real_number'.tr),
      ],
    );
  }

  _itemSubTitle(ProcessModifyInfo data) {
    return InkWell(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _titleText(
              title: data.barCode.toString(),
              backgroundColor: Colors.white,
              textColor: Colors.white),
          _titleText(
              title: data.size.toString(),
              backgroundColor: Colors.white,
              textColor: Colors.white),
          _titleText(
              title: data.mustQty.toString(),
              backgroundColor: Colors.white,
              textColor: Colors.white),
          _titleText(
              title: data.qty.toString(),
              backgroundColor: Colors.white,
              textColor: Colors.white),
        ],
      ),
      onTap: () =>
      {
        logic.showInputDialog(
            title: 'process_report_modify_input_real_number'.tr, confirm: (v) =>
        {
          logic.setModifyList(v, data)
        })
      },
    );
  }

  _titleText({
    required String title,
    Color? backgroundColor,
    Color? textColor,
  }) {
    return expandedFrameText(
      text: title,
      textColor: Colors.white,
      borderColor: Colors.black,
      backgroundColor: Colors.blue,
      alignment: Alignment.center,
      flex: 1,
    );
  }

  @override
  Widget build(BuildContext context) {
    return pageBody(
      title: 'process_report_modify_modify'.tr,
      actions: [
        TextButton(
          onPressed: () =>
          {
            logic.clearModifyList(),
          },
          child: Text('process_report_modify_clear'.tr),
        )
      ],
      body: Column(
        children: [
          EditText(
            hint: 'process_report_manual_input'.tr,
            onChanged: (v) => state.modifyCode = v,
          ),
          _itemTitle(),
          Expanded(
            child: Obx(
                  () =>
                  ListView.builder(
                    padding: const EdgeInsets.all(8),
                    itemCount: state.modifyList.length,
                    itemBuilder: (BuildContext context, int index) =>
                        _itemSubTitle(state.modifyList[index]),
                  ),
            ),
          ),
          Row(
            children: [
              Expanded(
                flex: 1,
                child: CombinationButton(
                  text: 'process_report_manually_add'.tr,
                  click: () {
                    logic.modifyAdd(state.code);
                  },
                  combination: Combination.left,
                ),
              ),
              Expanded(
                flex: 1,
                child: CombinationButton(
                  text: 'process_report_submit_barcode'.tr,
                  click: () =>
                  {
                    askDialog(
                      content: 'process_report_modify_submit'.tr,
                      confirm: () {
                        logic.updateBarCodeInfo(success: (s) =>
                        {
                          successDialog(
                            content: s,
                            back: () => Get.back(),
                          )
                        });
                      },
                    ),
                  },
                  combination: Combination.right,
                ),
              )
            ],
          )
        ],
      ),
    );
  }

  @override
  void initState() {
    pdaScanner(
      scan: (code) => {logic.modifyAdd(code)},
    );
    super.initState();
  }
}
