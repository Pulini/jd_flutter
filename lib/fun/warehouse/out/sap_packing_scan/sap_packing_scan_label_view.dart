import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jd_flutter/bean/http/response/sap_picing_scan_info.dart';
import 'package:jd_flutter/fun/warehouse/out/sap_packing_scan/sap_packing_scan_logic.dart';
import 'package:jd_flutter/fun/warehouse/out/sap_packing_scan/sap_packing_scan_state.dart';
import 'package:jd_flutter/widget/combination_button_widget.dart';
import 'package:jd_flutter/widget/custom_widget.dart';
import 'package:jd_flutter/widget/dialogs.dart';

class SapPackingScanLabelPage extends StatefulWidget {
  const SapPackingScanLabelPage({super.key});

  @override
  State<SapPackingScanLabelPage> createState() =>
      _SapPackingScanLabelPageState();
}

class _SapPackingScanLabelPageState extends State<SapPackingScanLabelPage> {
  final SapPackingScanLogic logic = Get.find<SapPackingScanLogic>();
  final SapPackingScanState state = Get.find<SapPackingScanLogic>().state;

  Widget _item(PieceMaterialInfo data) {
    return Container(
      padding: const EdgeInsets.all(5),
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              expandedTextSpan(
                hint: '件ID：',
                text: data.materials[0].labelList![0].pieceNumber ?? '',
                textColor: Colors.blue.shade900,
              ),
              expandedTextSpan(
                hint: '跟踪号：：',
                text: data.materials[0].trackNo ?? '',
                textColor: Colors.blue.shade900,
              ),
              Obx(() => Checkbox(
                    value: data.isSelected.value,
                    onChanged: (v) => data.isSelected.value = v!,
                  ))
            ],
          ),
          for (SapPackingScanMaterialInfo item in data.materials) ...{
            const Divider(),
            textSpan(
              hint: '物料：',
              hintColor: Colors.grey.shade700,
              text: '(${item.materialNumber})${item.materialName}',
              isBold: false,
              textColor: Colors.grey,
              maxLines: 2,
            ),
          }
        ],
      ),
    );
  }

  @override
  void initState() {
    state.pieceList.value = logic.pieceList('');
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return pageBody(
      title: '标签明细',
      actions: [
        Obx(() => CombinationButton(
              isEnabled: state.pieceList.any((v) => v.isSelected.value),
              text: '删除',
              click: () => askDialog(
                content: '确定要删除这些标签吗？',
                confirm: () => logic.deleteLabels(),
              ),
            )),
      ],
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 10),
            child: Row(
              children: [
                Expanded(
                  child: CupertinoSearchTextField(
                    decoration: BoxDecoration(
                      color: Colors.white54,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    placeholder: '请输入物料编号货物料描或跟踪号述进行过滤',
                    onChanged: (v) =>
                        state.pieceList.value = logic.pieceList(v),
                  ),
                ),
                Obx(() => Checkbox(
                      value: state.pieceList.isNotEmpty &&
                          state.pieceList.every((v) => v.isSelected.value),
                      onChanged: (v) {
                        for (var item in state.pieceList) {
                          item.isSelected.value = v!;
                        }
                      },
                    ))
              ],
            ),
          ),
          Expanded(
            child: Obx(() => ListView.builder(
                  padding: const EdgeInsets.all(10),
                  itemCount: state.pieceList.length,
                  itemBuilder: (c, i) => _item(state.pieceList[i]),
                )),
          ),
        ],
      ),
    );
  }
}
