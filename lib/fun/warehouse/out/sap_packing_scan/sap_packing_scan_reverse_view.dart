import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jd_flutter/bean/http/response/sap_picking_scan_info.dart';
import 'package:jd_flutter/fun/warehouse/out/sap_packing_scan/sap_packing_scan_logic.dart';
import 'package:jd_flutter/fun/warehouse/out/sap_packing_scan/sap_packing_scan_state.dart';
import 'package:jd_flutter/utils/utils.dart';
import 'package:jd_flutter/widget/combination_button_widget.dart';
import 'package:jd_flutter/widget/custom_widget.dart';
import 'package:jd_flutter/widget/dialogs.dart';
import 'package:jd_flutter/widget/scanner.dart';

class SapPackingScanReversePage extends StatefulWidget {
  const SapPackingScanReversePage({super.key});

  @override
  State<SapPackingScanReversePage> createState() =>
      _SapPackingScanReversePageState();
}

class _SapPackingScanReversePageState extends State<SapPackingScanReversePage> {
  final SapPackingScanLogic logic = Get.find<SapPackingScanLogic>();
  final SapPackingScanState state = Get.find<SapPackingScanLogic>().state;

  Widget _item(SapPackingScanReverseLabelInfo data) => Container(
        padding: const EdgeInsets.all(7),
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              height: 40,
              child: Row(
                children: [
                  expandedTextSpan(
                    hint: '件ID：',
                    text: data.pieceId ?? '',
                    textColor: Colors.blue.shade900,
                  ),
                  IconButton(
                    onPressed: () => askDialog(
                      content: '确定要删除该标签吗？',
                      confirm: () => logic.deleteReverseLabel(data),
                    ),
                    icon: const Icon(Icons.delete_forever, color: Colors.red),
                  )
                ],
              ),
            ),
            for (SapPackingScanReverseLabelMaterialInfo item
                in data.materialList!) ...{
              const Divider(),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  expandedTextSpan(
                    hint: '物料：',
                    text: '(${item.materialNumber})${item.materialName}'
                        .allowWordTruncation(),
                    maxLines: 3,
                  ),
                  const SizedBox(width: 10),
                  textSpan(
                    hint: '数量：',
                    text: '${item.commonQty.toShowString()} ${item.commonUnit}',
                  )
                ],
              )
            }
          ],
        ),
      );

  _reverse() {
    var pickDate = DateTime.now();
    showDatePicker(
      locale: View.of(Get.overlayContext!).platformDispatcher.locale,
      context: Get.overlayContext!,
      initialDate: pickDate,
      firstDate: DateTime(pickDate.year, pickDate.month - 1, pickDate.day),
      lastDate: DateTime(pickDate.year, pickDate.month + 1, pickDate.day),
    ).then((date) {
      if (date != null) logic.reverseLabel(getDateYMD(time: date));
    });
  }

  @override
  void initState() {
    pdaScanner(scan: (code) => logic.reverseScan(code));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return pageBody(
      title: '扫码冲销',
      actions: [
        Obx(() => state.reverseLabelList.isNotEmpty
            ? CombinationButton(
                text: '冲销',
                click: () => _reverse(),
              )
            : Container()),
      ],
      body: Obx(() => ListView.builder(
            padding: const EdgeInsets.only(left: 7, right: 7),
            itemCount: state.reverseLabelList.length,
            itemBuilder: (c, i) => _item(state.reverseLabelList[i]),
          )),
    );
  }
}
