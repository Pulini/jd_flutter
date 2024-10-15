import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jd_flutter/fun/dispatching/process_dispatch_register/process_dispatch_register_logic.dart';
import 'package:jd_flutter/fun/dispatching/process_dispatch_register/process_dispatch_register_state.dart';
import 'package:jd_flutter/utils/utils.dart';
import 'package:jd_flutter/widget/custom_widget.dart';

import '../../../bean/http/response/process_dispatch_register_info.dart';
import '../../../utils/printer/print_util.dart';
import '../../../widget/combination_button_widget.dart';
import '../../../widget/preview_label_widget.dart';

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

  _previewLabel(Barcode data) {
    var title = Padding(
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

    var subTitle = Padding(
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

    var content = data.instructionsText().isNotEmpty
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
    var bottomLeft = Column(
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
    var bottomMiddle = Center(
      child: Text(
        '${data.size}# ${data.mustQty.toShowString()}',
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 20,
        ),
      ),
    );
    var bottomRight = Center(
      child: Text(
        '序号: ${data.rowID}',
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
      ),
    );

    Get.to(
      () => PreviewLabel(
        labelWidget: labelTemplate(
          qrCode: data.barCode ?? '',
          title: title,
          subTitle: subTitle,
          content: content,
          bottomLeft: bottomLeft,
          bottomMiddle: bottomMiddle,
          bottomRight: bottomRight,
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

  @override
  Widget build(BuildContext context) {
    return pageBody(
      title: '贴标列表',
      body: Column(
        children: [
          Expanded(
            child: Obx(
              () => ListView.builder(
                padding: const EdgeInsets.all(5),
                itemCount: state.labelList.length,
                itemBuilder: (context, index) => _item(state.labelList[index]),
              ),
            ),
          ),
          Row(
            children: [
              Expanded(
                child: CombinationButton(
                    text: '打印',
                    click: () {
                      // pu.goPrintlabels();
                    }),
              ),
            ],
          )
        ],
      ),
    );
  }
}
