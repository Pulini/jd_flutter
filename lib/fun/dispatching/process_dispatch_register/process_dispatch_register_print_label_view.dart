import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jd_flutter/bean/http/response/process_dispatch_register_info.dart';
import 'package:jd_flutter/fun/dispatching/process_dispatch_register/process_dispatch_register_logic.dart';
import 'package:jd_flutter/fun/dispatching/process_dispatch_register/process_dispatch_register_state.dart';
import 'package:jd_flutter/utils/extension_util.dart';
import 'package:jd_flutter/utils/printer/print_util.dart';
import 'package:jd_flutter/widget/combination_button_widget.dart';
import 'package:jd_flutter/widget/custom_widget.dart';
import 'package:jd_flutter/widget/dialogs.dart';
import 'package:jd_flutter/widget/preview_label_list_widget.dart';
import 'package:jd_flutter/widget/preview_label_widget.dart';

class PrintLabelPage extends StatefulWidget {
  const PrintLabelPage({super.key});

  @override
  State<PrintLabelPage> createState() => _PrintLabelPageState();
}

class _PrintLabelPageState extends State<PrintLabelPage> {
  final ProcessDispatchRegisterLogic logic =
      Get.find<ProcessDispatchRegisterLogic>();
  final ProcessDispatchRegisterState state =
      Get.find<ProcessDispatchRegisterLogic>().state;

  PrintUtil pu = PrintUtil()..setChannelListener();

  void _previewLabel(Barcode data) {
    Get.to(() => PreviewLabel(labelWidget: logic.createLabelView(data)));
  }

  Future<void> _printLabel(Barcode data) async {
    pu.printLabel(
      label: await logic.createLabel(data),
      success: () => successDialog(content: '标签下发成功'),
      failed: () => errorDialog(content: '标签下发失败'),
    );
  }

  void _previewLabelList() {
    Get.to(() => PreviewLabelList(labelWidgets: [
          for (var data in state.labelList.where((v) => v.isSelected).toList())
            logic.createLabelView(data)
        ]));
  }

  Future<void> _printLabelList() async {
    pu.printLabelList(
      labelList: [
        for (var data in state.labelList.where((v) => v.isSelected).toList())
          await logic.createLabel(data)
      ],
      finished: (success, fail) {
        successDialog(
          title: '标签下发结束',
          content: '完成${success.length}张, 失败${fail.length}张',
        );
      },
    );
  }

  Widget _item(Barcode data) {
    return GestureDetector(
      onTap: () {
        setState(() {
          data.isSelected = !data.isSelected;
        });
      },
      child: Card(
        color: data.isSelected ? Colors.greenAccent.shade100 : Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(5),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  expandedTextSpan(
                      hint: 'process_dispatch_register_print_number'.tr,
                      text: data.rowID.toString(),
                      textColor: Colors.red),
                  textSpan(
                    hint: 'process_dispatch_register_print_size'.tr,
                    isBold: false,
                    text: data.size ?? '',
                  ),
                ],
              ),
              Row(
                children: [
                  expandedTextSpan(
                    isBold: false,
                    hint: 'process_dispatch_register_print_report_date'.tr,
                    text: data.reportTime ?? '',
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  expandedTextSpan(
                    hint: 'process_dispatch_register_print_quantity'.tr,
                    isBold: false,
                    text: data.qty.toShowString(),
                  ),
                  expandedTextSpan(
                    hint: 'process_dispatch_register_print_box_capacity'.tr,
                    isBold: false,
                    text: data.mustQty.toShowString(),
                  ),
                  GestureDetector(
                    onTap: () => _printLabel(data),
                    child: Container(
                      padding: const EdgeInsets.only(left: 5, right: 5),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.blue, width: 2),
                      ),
                      child: Text(
                        'process_dispatch_register_print_print'.tr,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  GestureDetector(
                    onTap: () => _previewLabel(data),
                    child: Container(
                      padding: const EdgeInsets.only(left: 5, right: 5),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.green, width: 2),
                      ),
                      child: Text(
                        'process_dispatch_register_print_view'.tr,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  GestureDetector(
                    onTap: () => logic.deleteLabel(data),
                    child: Container(
                      padding: const EdgeInsets.only(left: 5, right: 5),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.red, width: 2),
                      ),
                      child: Text(
                        'process_dispatch_register_print_delete'.tr,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.red,
                        ),
                      ),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return pageBody(
      title: 'process_dispatch_register_print_label_list'.tr,
      body: Obx(() => Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(5),
                  itemCount: state.labelList.length,
                  itemBuilder: (context, index) =>
                      _item(state.labelList[index]),
                ),
              ),
              if (state.labelList.any((v) => v.isSelected))
                Row(
                  children: [
                    Expanded(
                      child: CombinationButton(
                        text: 'process_dispatch_register_print_print'.tr,
                        combination: Combination.left,
                        click: () => _printLabelList(),
                      ),
                    ),
                    Expanded(
                      child: CombinationButton(
                        text: 'process_dispatch_register_print_view_print'.tr,
                        combination: Combination.right,
                        click: () => _previewLabelList(),
                      ),
                    ),
                  ],
                )
            ],
          )),
    );
  }
}
