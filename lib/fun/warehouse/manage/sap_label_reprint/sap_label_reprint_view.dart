import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jd_flutter/bean/http/response/sap_carton_label_binding_info.dart';
import 'package:jd_flutter/utils/extension_util.dart';
import 'package:jd_flutter/widget/custom_widget.dart';
import 'package:jd_flutter/widget/scanner.dart';
import 'package:jd_flutter/widget/switch_button_widget.dart';

import 'sap_label_reprint_logic.dart';
import 'sap_label_reprint_state.dart';

class SapLabelReprintPage extends StatefulWidget {
  const SapLabelReprintPage({super.key});

  @override
  State<SapLabelReprintPage> createState() => _SapLabelReprintPageState();
}

class _SapLabelReprintPageState extends State<SapLabelReprintPage> {
  final SapLabelReprintLogic logic = Get.put(SapLabelReprintLogic());
  final SapLabelReprintState state = Get.find<SapLabelReprintLogic>().state;

  var tecPiece = TextEditingController();

  Widget _item(SapPrintLabelInfo label) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        gradient: LinearGradient(
          colors: [Colors.blue.shade100, Colors.white],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Column(
        children: label.isBoxLabel
            ? [
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          textSpan(
                            hint: '外箱件号：',
                            text: label.pieceID ?? '',
                            textColor: Colors.green,
                          ),
                          Row(
                            children: [
                              expandedTextSpan(
                                hint: '规格：',
                                text: label.getLongWidthHeight(),
                              ),
                              textSpan(
                                hint: '总数：',
                                text: state.labelList
                                    .map((v) => v.getInBoxQty())
                                    .reduce((a, b) => a.add(b))
                                    .toShowString(),
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
                    Obx(() => Checkbox(
                          value: label.isSelected.value,
                          onChanged: (v) => label.isSelected.value = v!,
                        )),
                  ],
                ),
                Row(
                  children: [
                    expandedTextSpan(
                      flex: 2,
                      hint: '供应商：',
                      text: label.supplierNumber ?? '',
                    ),
                    expandedTextSpan(
                      flex: 3,
                      hint: '收货方：',
                      text: label.shipToParty ?? '',
                    ),
                  ],
                ),
              ]
            : [
                SizedBox(
                  height: 30,
                  child: Row(
                    children: [
                      Expanded(
                        child: textSpan(
                          hint: '件号：',
                          text: label.pieceID ?? '',
                          textColor: Colors.green,
                        ),
                      ),
                      Obx(() => Checkbox(
                            value: label.isSelected.value,
                            onChanged: (v) => label.isSelected.value = v!,
                          ))
                    ],
                  ),
                ),
                for (var sub in label.subLabel!) ...[
                  const Divider(),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          '(${sub.materialNumber})${sub.materialName}',
                          maxLines: 2,
                        ),
                      ),
                      textSpan(
                          hint: '数量：',
                          text: '${sub.inBoxQty.toShowString()}${sub.unit}')
                    ],
                  )
                ]
              ],
      ),
    );
  }

  @override
  void initState() {
    pdaScanner(scan: (code) => logic.scanLabel(code));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return pageBody(
      actions: [
        IconButton(
          onPressed: () => logic.cleanLabels(),
          icon: Container(
            padding: const EdgeInsets.all(5),
            decoration: BoxDecoration(
              color: Colors.orange, // 背景色
              borderRadius: BorderRadius.circular(25), // 圆角（可选）
            ),
            child: const Icon(
              Icons.cleaning_services,
              color: Colors.white,
            ),
          ),
        ),
        Transform.scale(
            scale: 1.8,
            child: Obx(
              () => Checkbox(
                value: logic.isSelectedAll(),
                shape: const CircleBorder(),
                onChanged: (v) => logic.selectAll(v!),
              ),
            )),
        IconButton(
          onPressed: () => logic.printLabel(),
          icon: Container(
            padding: const EdgeInsets.all(5),
            decoration: BoxDecoration(
              color: Colors.blue, // 背景色
              borderRadius: BorderRadius.circular(25), // 圆角（可选）
            ),
            child: const Icon(
              Icons.print,
              color: Colors.white,
            ),
          ),
        )
      ],
      body: Column(
        children: [
          Container(
            margin: const EdgeInsets.only(left: 10, right: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(25),
            ),
            child:TextField(
              onSubmitted: (value) => logic.searchPiece(tecPiece.text),
              textAlign: TextAlign.center,
              keyboardType: TextInputType.number,
              controller: tecPiece,
              decoration: InputDecoration(
                contentPadding: const EdgeInsets.all(0),
                filled: true,
                fillColor: Colors.grey.shade300,
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(50),
                  borderSide: const BorderSide(
                    color: Colors.transparent,
                  ),
                ),
                border: const OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(50)),
                ),
                hintStyle: const TextStyle(color: Colors.white),
                suffixIcon: IconButton(
                  onPressed: () => logic.searchPiece(tecPiece.text),
                  icon: Container(
                    padding: const EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      color: Colors.green, // 背景色
                      borderRadius: BorderRadius.circular(25), // 圆角（可选）
                    ),
                    child: const Icon(Icons.search, color: Colors.white),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Container(
            margin: const EdgeInsets.only(left: 10, right: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(25),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Expanded(
                  child: SwitchButton(
                    onChanged: (s) => state.isMaterialLabel.value = s,
                    name: '打印物料表',
                    value: state.isMaterialLabel.value,
                  ),
                ),
                Expanded(
                    child: SwitchButton(
                  onChanged: (s) => state.isMaterialLabel.value = s,
                  name: '打印备注行',
                  value: state.isMaterialLabel.value,
                )),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: Obx(() => ListView.builder(
                  padding:
                      const EdgeInsets.only(left: 10, right: 10, bottom: 10),
                  itemCount: state.labelList.length,
                  itemBuilder: (c, i) => _item(state.labelList[i]),
                )),
          )
        ],
      ),
    );
  }

  @override
  void dispose() {
    Get.delete<SapLabelReprintLogic>();
    super.dispose();
  }
}
