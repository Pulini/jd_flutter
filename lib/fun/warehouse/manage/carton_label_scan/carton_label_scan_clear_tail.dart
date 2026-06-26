import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jd_flutter/bean/http/response/out_box_labels_info.dart';
import 'package:jd_flutter/widget/custom_widget.dart';
import 'package:jd_flutter/widget/dialogs.dart';
import 'package:jd_flutter/widget/scanner.dart';
import 'package:jd_flutter/widget/switch_button_widget.dart';
import 'carton_label_scan_clear_tail_detail.dart';
import 'carton_label_scan_logic.dart';
import 'carton_label_scan_state.dart';

class CartonLabelScanClearTail extends StatefulWidget {
  const CartonLabelScanClearTail({super.key});

  @override
  State<CartonLabelScanClearTail> createState() =>
      _CartonLabelScanClearTailState();
}

class _CartonLabelScanClearTailState extends State<CartonLabelScanClearTail> {
  final CartonLabelScanLogic logic = Get.find<CartonLabelScanLogic>();
  final CartonLabelScanState state = Get.find<CartonLabelScanLogic>().state;

  Widget _item(OutBoxLabelsInfo data, int position) {
    var mes = '';
    data.mantissaDataSizeList?.forEach((a) {
      final labelCount = a.labelCount ?? 0;
      final shortQty = a.shortQty ?? 0;
      if(labelCount-shortQty!=0){
        mes += '${a.size}#: ${(labelCount - shortQty)},';
      }
    });
    return Container(
      height: 40,
      margin: const EdgeInsets.symmetric(horizontal: 2, vertical: 1),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.blue.shade200, width: 2),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: InkWell(
              onTap: () {
                logic.setTailDetail(
                    index: position,
                    goActivity: () {
                      Get.to(() => const CartonLabelScanClearTailDetailPage())
                          ?.then((v) {
                        _scan();
                      });
                    });
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 5),
                child: Text(
                  data.outBoxBarCode.toString(),
                  style: const TextStyle(
                    color: Colors.black87,
                    fontSize: 13,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
          VerticalDivider(
            width: 1,
            thickness: 1,
            color: Colors.blue.shade300,
          ),
          Expanded(
            flex: 1,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 5),
              child: Text(
                data.tailCartonCode.toString(),
                style: const TextStyle(
                  color: Colors.black87,
                  fontSize: 13,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          VerticalDivider(
            width: 1,
            thickness: 1,
            color: Colors.blue.shade300,
          ),
          Expanded(
            flex: 2,
            child: InkWell(
              onTap: () {
                msgDialog(content: mes);
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 5),
                child: Text(
                  mes,
                  style: const TextStyle(
                    color: Colors.black87,
                    fontSize: 13,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return pageBody(
        title: 'carton_label_scan_order_order_clearance'.tr,
        actions: [
          Obx(() => SwitchButton(
                onChanged: (s) {
                  state.add.value = s;
                  if(state.tailController.text.isNotEmpty){
                    state.queryNotFullBox(barCode:state.tailController.text);
                  }
                },
                name: state.add.value == true
                    ? 'carton_label_scan_order_clear_add'.tr
                    : 'carton_label_scan_order_clear_change'.tr,
                value: state.add.value,
              ))
        ],
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
                padding: const EdgeInsets.symmetric(horizontal: 5),
                child: SizedBox(
                  height: 40,
                  child: TextField(
                    controller: state.tailController,
                    decoration: InputDecoration(
                      contentPadding:
                          const EdgeInsets.only(left: 15, right: 10),
                      filled: true,
                      fillColor: Colors.white54,
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: const BorderSide(color: Colors.transparent),
                      ),
                      border: const OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(20)),
                      ),
                      hintText:
                          'carton_label_scan_scan_code_or_input_outside_code'
                              .tr,
                      hintStyle: const TextStyle(color: Colors.grey),
                      prefixIcon: IconButton(
                        onPressed: () => state.tailController.clear(),
                        icon: const Icon(
                          Icons.replay_circle_filled,
                          color: Colors.red,
                        ),
                      ),
                      suffixIcon: IconButton(
                        onPressed: () {
                          state.queryNotFullBox(barCode:state.tailController.text);
                        },
                        icon: const Icon(
                          Icons.loupe_rounded,
                          color: Colors.green,
                        ),
                      ),
                    ),
                  ),
                )),
            const SizedBox(height: 5),
            Container(
              height: 35,
              margin: const EdgeInsets.symmetric(horizontal: 2),
              padding: const EdgeInsets.all(5),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(3),
                border: Border(
                  top: BorderSide(color: Colors.blue.shade300, width: 2),
                  left: BorderSide(color: Colors.blue.shade300, width: 2),
                  right: BorderSide(color: Colors.blue.shade300, width: 2),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: Text(
                      'carton_label_scan_order_label'.tr,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.blue.shade700,
                        fontSize: 14,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  VerticalDivider(
                    width: 1,
                    thickness: 1,
                    color: Colors.blue.shade300,
                    indent: 5,
                    endIndent: 5,
                  ),
                  Expanded(
                    child: Text(
                      'carton_label_scan_order_last_number'.tr,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.blue.shade700,
                        fontSize: 14,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  VerticalDivider(
                    width: 1,
                    thickness: 1,
                    color: Colors.blue.shade300,
                    indent: 5,
                    endIndent: 5,
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(
                      'carton_label_scan_order_last_number_detail'.tr,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.blue.shade700,
                        fontSize: 14,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
            Obx(() => Expanded(
                  child: ListView.builder(
                    itemCount: state.outBoxList.length,
                    itemBuilder: (c, i) => _item(state.outBoxList[i], i),
                  ),
                )),
            Obx(() => textSpan(
                  hint: 'carton_label_scan_dispatch_no'.tr,
                  text: state.tailDispatchNumber.value,
                ))
          ],
        ));
  }

  void _scan() {
    pdaScanner(scan: (barCode) {
      if (barCode.isNotEmpty) {
        if (barCode.startsWith('P') && barCode.length > 5) {
          state.tailDispatchNumber.value = barCode;
          if(state.tailController.text.isNotEmpty){
            state.queryNotFullBox(barCode:state.tailController.text);
          }
        } else {
          state.tailController.text = barCode;
          state.queryNotFullBox(barCode: barCode);
        }
      }
    });
  }

  @override
  void initState() {
    _scan();
    super.initState();
  }

  @override
  void dispose() {
    state.tailController.clear();
    state.tailDispatchNumber.value='';
    state.outBoxList.clear();
    super.dispose();
  }
}
