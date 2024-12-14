import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jd_flutter/bean/http/response/sap_picking_info.dart';
import 'package:jd_flutter/fun/warehouse/out/sap_print_picking/sap_print_picking_logic.dart';
import 'package:jd_flutter/fun/warehouse/out/sap_print_picking/sap_print_picking_state.dart';
import 'package:jd_flutter/utils/utils.dart';
import 'package:jd_flutter/widget/custom_widget.dart';
import 'package:jd_flutter/widget/dialogs.dart';



class SapPrintPickingBarCodeListPage extends StatefulWidget {
  const SapPrintPickingBarCodeListPage({super.key});

  @override
  State<SapPrintPickingBarCodeListPage> createState() =>
      _SapPrintPickingBarCodeListPageState();
}

class _SapPrintPickingBarCodeListPageState
    extends State<SapPrintPickingBarCodeListPage> {
  final SapPrintPickingLogic logic = Get.find<SapPrintPickingLogic>();
  final SapPrintPickingState state = Get.find<SapPrintPickingLogic>().state;
  int dataID = Get.arguments['id'];
  var palletNumber = <String>[];

  @override
  void initState() {
    pdaScanner(scan: (code) {
      logic.scanCode(code);
    });
    super.initState();
  }

  _item(SapPickingDetailLabelInfo label) {
    return Container(
      margin: const EdgeInsets.only(left: 4, right: 4, bottom: 10),
      padding: const EdgeInsets.only(left: 4, right: 4),
      decoration: BoxDecoration(
        color: label.distribution.isNotEmpty
            ? Colors.blue.shade100
            : Colors.grey.shade300,
        borderRadius: BorderRadius.circular(10),
        border: label.distribution.isNotEmpty
            ? Border.all(color: Colors.green, width: 2)
            : Border.all(color: Colors.grey.shade300, width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          textSpan(hint: '标签号：', text: label.labelCode ?? ''),
          Row(
            children: [
              Expanded(
                child: Column(
                  children: [
                    Row(
                      children: [
                        expandedTextSpan(
                            hint: '托盘号：',
                            isBold: false,
                            text: label.palletNumber ?? '',
                            textColor: Colors.green),
                        textSpan(
                          hint: '领取/箱容：',
                          isBold: false,
                          text:
                              '${label.getPickQty().toShowString()} / ${label.quantity.toShowString()}',
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        expandedTextSpan(
                          hint: '型体：',
                          isBold: false,
                          text: label.typeBody ?? '',
                          textColor: Colors.red,
                        ),
                        textSpan(
                          hint: '尺码：',
                          isBold: false,
                          text: label.size ?? '',
                          textColor: Colors.red,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              if (label.distribution.isNotEmpty)
                IconButton(
                  onPressed: () => askDialog(
                    content: '确定要删除已扫条码吗？',
                    confirm: () => logic.scannedLabelDelete(label),
                  ),
                  icon: const Icon(
                    Icons.delete_forever,
                    color: Colors.red,
                  ),
                )
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return pageBody(
      title: '已扫描条码列表',
      body: Obx(() => ListView.builder(
            itemCount: logic.getLabelListWhereId(dataID).length,
            itemBuilder: (c, i) => _item(logic.getLabelListWhereId(dataID)[i]),
          )),
    );
  }
}
