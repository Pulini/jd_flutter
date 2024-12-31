import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jd_flutter/bean/http/response/process_dispatch_register_info.dart';
import 'package:jd_flutter/fun/dispatching/process_dispatch_register/process_dispatch_register_logic.dart';
import 'package:jd_flutter/fun/dispatching/process_dispatch_register/process_dispatch_register_state.dart';
import 'package:jd_flutter/utils/printer/print_util.dart';
import 'package:jd_flutter/utils/utils.dart';
import 'package:jd_flutter/widget/combination_button_widget.dart';
import 'package:jd_flutter/widget/custom_widget.dart';
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

  PrintUtil pu = PrintUtil();

  _labelTitle() {
    return Padding(
      padding: const EdgeInsets.only(
        left: 3,
        right: 3,
      ),
      child: Text(
        state.typeBody.value,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 24,
        ),
      ),
    );
  }

  _subTitle(Barcode data) {
    return Padding(
      padding: const EdgeInsets.only(
        left: 3,
        right: 3,
      ),
      child: AutoSizeText(
        data.processName ?? '',
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 36,
        ),
        maxLines: 2,
        minFontSize: 12,
        maxFontSize: 36,
      ),
    );
  }

  _content(Barcode data) {
    return data.instructionsText().isNotEmpty
        ? Padding(
            padding: const EdgeInsets.only(
              left: 3,
              right: 3,
            ),
            child: Text(
              data.instructionsText(),
              style: const TextStyle(
                overflow: TextOverflow.ellipsis,
                fontWeight: FontWeight.bold,
                fontSize: 16.5,
              ),
              maxLines: 4,
            ),
          )
        : null;
  }

  _bottomLeft(Barcode data) {
    return Column(
      children: [
        Expanded(
          child: Text(
            data.empNumber ?? '',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Expanded(
          child: Text(
            data.empName ?? '',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  _bottomMiddle(Barcode data) {
    return Center(
      child: Text(
        '${data.size}# ${data.mustQty.toShowString()}',
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 20,
        ),
      ),
    );
  }

  bottomRight(Barcode data) {
    return Center(
      child: Text(
        '序号: ${data.rowID}',
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
      ),
    );
  }

  _previewLabel(Barcode data) {
    Get.to(
      () => PreviewLabel(
        labelWidget: fixedLabelTemplate(
          qrCode: data.barCode ?? '',
          title: _labelTitle(),
          subTitle: _subTitle(data),
          content: _content(data),
          bottomLeft: _bottomLeft(data),
          bottomMiddle: _bottomMiddle(data),
          bottomRight: bottomRight(data),
        ),
      ),
    )?.then((v) {
      pu.setChannelListener();
    });
  }

  _item(Barcode data) {
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
                      hint: '序号：',
                      text: data.rowID.toString(),
                      textColor: Colors.red),
                  textSpan(
                    hint: '尺码：',
                    isBold: false,
                    text: data.size ?? '',
                  ),
                ],
              ),
              Row(
                children: [
                  expandedTextSpan(
                    isBold: false,
                    hint: '报工日期：',
                    text: data.reportTime ?? '',
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  expandedTextSpan(
                    hint: '数量：',
                    isBold: false,
                    text: data.qty.toShowString(),
                  ),
                  expandedTextSpan(
                    hint: '箱容：',
                    isBold: false,
                    text: data.mustQty.toShowString(),
                  ),
                  GestureDetector(
                    onTap: () => _previewLabel(data),
                    child: Container(
                      padding: const EdgeInsets.only(left: 5, right: 5),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.green, width: 2),
                      ),
                      child: Text(
                        '预览',
                        style: TextStyle(
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
                        '删除',
                        style: TextStyle(
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

  _previewLabelList() {
    var selected = state.labelList.where((v) => v.isSelected).toList();
    Get.to(
      () => PreviewLabelList(
        labelWidgets: [
          for (var i = 0; i < selected.length; ++i)
            fixedLabelTemplate(
              qrCode: selected[i].barCode ?? '',
              title: _labelTitle(),
              subTitle: _subTitle(selected[i]),
              content: _content(selected[i]),
              bottomLeft: _bottomLeft(selected[i]),
              bottomMiddle: _bottomMiddle(selected[i]),
              bottomRight: bottomRight(selected[i]),
            )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return pageBody(
      title: '贴标列表',
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
                CombinationButton(
                  text: '打印',
                  click: () => _previewLabelList(),
                )
            ],
          )),
    );
  }
}
