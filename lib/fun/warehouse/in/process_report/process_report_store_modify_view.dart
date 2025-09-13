import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jd_flutter/bean/http/response/process_modify_info.dart';
import 'package:jd_flutter/fun/warehouse/in/process_report/process_report_store_logic.dart';
import 'package:jd_flutter/fun/warehouse/in/process_report/process_report_store_state.dart';
import 'package:jd_flutter/widget/combination_button_widget.dart';
import 'package:jd_flutter/widget/custom_widget.dart';
import 'package:jd_flutter/widget/dialogs.dart';
import 'package:jd_flutter/widget/edit_text_widget.dart';
import 'package:jd_flutter/widget/scanner.dart';

class ProcessReportModifyPage extends StatefulWidget {
  const ProcessReportModifyPage({super.key});

  @override
  State<ProcessReportModifyPage> createState() =>
      _ProcessReportModifyPageState();
}

class _ProcessReportModifyPageState extends State<ProcessReportModifyPage> {
  final ProcessReportStoreLogic logic = Get.find<ProcessReportStoreLogic>();
  final ProcessReportStoreState state =
      Get.find<ProcessReportStoreLogic>().state;
  var tecModifyCode = TextEditingController();

  _itemTitle() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _titleText(title: 'process_report_store_modify_barCode'.tr),
        _titleText(title: 'process_report_store_modify_size'.tr),
        _titleText(title: 'process_report_store_modify_original_quantity'.tr),
        _titleText(title: 'process_report_store_modify_real_number'.tr),
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
      onTap: () {
        logic.showInputDialog(
            title: 'process_report_store_modify_input_real_number'.tr,
            confirm: (v) {logic.setModifyList(v, data);});
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
      title: 'process_report_store_modify_modify'.tr,
      actions: [
        TextButton(
          onPressed: () {
            logic.clearModifyList();
          },
          child: Text('process_report_store_modify_clear'.tr),
        )
      ],
      body: Column(
        children: [
          EditText(
            controller: tecModifyCode,
            hint: 'process_report_store_manual_input'.tr,
          ),
          _itemTitle(),
          Expanded(
            child: Obx(
              () => ListView.builder(
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
                  text: 'process_report_store_manually_add'.tr,
                  click: () {
                    logic.modifyAdd(tecModifyCode.text);
                  },
                  combination: Combination.left,
                ),
              ),
              Expanded(
                flex: 1,
                child: CombinationButton(
                  text: 'process_report_store_submit_barcode'.tr,
                  click: () {
                    askDialog(
                      content: 'process_report_store_modify_submit'.tr,
                      confirm: () {
                        logic.updateBarCodeInfo(
                            success: (s)  {
                                  successDialog(
                                    content: s,
                                    back: () => Get.back(),
                                  );
                                });
                      },
                    );
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
      scan: (code) {logic.modifyAdd(code);},
    );
    super.initState();
  }
}
