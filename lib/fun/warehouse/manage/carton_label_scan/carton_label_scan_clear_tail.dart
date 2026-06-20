import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jd_flutter/bean/http/response/out_box_labels_info.dart';
import 'package:jd_flutter/utils/click_debounce.dart';
import 'package:jd_flutter/widget/custom_widget.dart';
import 'package:jd_flutter/widget/scanner.dart';
import 'package:jd_flutter/widget/switch_button_widget.dart';

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
  final CartonLabelScanState state = Get
      .find<CartonLabelScanLogic>()
      .state;
  final debouncer = ClickDebouncer();

  var controller = TextEditingController();

  Row _item(OutBoxLabelsInfo data, int index) {
    var mes = '';
    data.linkDataSizeList?.forEach((a) {
      '$mes${a.size}#:${(a.labelCount! - a.shotQty!).toString()}';
    });
    return Row(
      children: [
        Expanded(
            flex: 3,
            child: InkWell(
              child: _text(
                  mes: data.outBoxBarCode.toString(),
                  backColor: Colors.white,
                  head: false,
                  paddingNumber: 5),
              onTap: () {
                logic.setTailDetail(index);
              },
            )),
        Expanded(
            child: _text(
                mes: data.mix.toString(),
                backColor: Colors.white,
                head: false,
                paddingNumber: 5)),
        Expanded(
            child: InkWell(
              child: _text(
                  mes: mes,
                  backColor: Colors.white,
                  head: false,
                  paddingNumber: 5),
              onTap: () {
                showSnackBar(message: mes);
              },
            )),
      ],
    );
  }

  Container _text({
    required String mes,
    required Color backColor,
    required bool head,
    required double paddingNumber,
  }) {
    var textColor = Colors.white;
    if (head) {
      textColor = Colors.white;
    } else {
      textColor = Colors.black;
    }
    return Container(
      height: 35,
      decoration: BoxDecoration(
        color: backColor, // 背景颜色
        border: Border.all(
          color: Colors.grey, // 边框颜色
          width: 1.0, // 边框宽度
        ),
      ),
      child: Padding(
        padding: EdgeInsets.only(top: paddingNumber, bottom: paddingNumber),
        child: Center(
          child: Text(
            mes,
            style: TextStyle(color: textColor),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return pageBody(
        title: 'carton_label_scan_order_order_clearance'.tr,
        body: Column(
          children: [
            Obx(() =>
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SwitchButton(
                      onChanged: (s) {
                        if (s == true) {
                          state.add.value = s;
                          state.change.value = false;
                        } else {
                          state.add.value = s;
                          state.change.value = true;
                        }
                      },
                      name: 'carton_label_scan_order_clear_add'.tr,
                      value: state.add.value,
                    ),
                    SwitchButton(
                      onChanged: (s) {
                        if (s == true) {
                          state.change.value = s;
                          state.add.value = false;
                        } else {
                          state.change.value = s;
                          state.add.value = true;
                        }
                      },
                      name: 'carton_label_scan_order_clear_change'.tr,
                      value: state.change.value,
                    )
                  ],
                )),
            Container(
              margin: const EdgeInsets.all(5),
              height: 40,
              child: TextField(
                controller: controller,
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.only(left: 15, right: 10),
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
                  'carton_label_scan_scan_code_or_input_outside_code'.tr,
                  hintStyle: const TextStyle(color: Colors.grey),
                  prefixIcon: IconButton(
                    onPressed: () => controller.clear(),
                    icon: const Icon(
                      Icons.replay_circle_filled,
                      color: Colors.red,
                    ),
                  ),
                  suffixIcon: IconButton(
                    onPressed: () =>
                        debouncer
                            .run(() =>
                            logic.queryCartonLabelInfo(controller.text)),
                    icon: const Icon(
                      Icons.loupe_rounded,
                      color: Colors.green,
                    ),
                  ),
                ),
              ),
            ),
            Row(
              children: [
                Expanded(
                    flex: 2,
                    child: _text(
                        mes: 'carton_label_scan_order_label'.tr,
                        backColor: Colors.blueAccent,
                        head: true,
                        paddingNumber: 5)),
                Expanded(
                    child: _text(
                        mes: 'carton_label_scan_order_last_number'.tr,
                        backColor: Colors.blueAccent,
                        head: true,
                        paddingNumber: 5)),
                Expanded(
                    child: _text(
                        mes: 'carton_label_scan_order_last_number_detail'.tr,
                        backColor: Colors.blueAccent,
                        head: true,
                        paddingNumber: 5)),
              ],
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(8),
                itemCount: state.outBoxList.length,
                itemBuilder: (c, i) => _item(state.outBoxList[i], i),
              ),
            ),
          ],
        ));
  }



  void _scan() {
    pdaScanner(scan: (barCode) {
      if (barCode.isNotEmpty) {
        if(barCode.startsWith('P')){
          state.queryNotFullBox(barCode:'', dispatchNumber:barCode);
        }else{
          state.queryNotFullBox(barCode:barCode, dispatchNumber:'');
        }
      }
    });
  }

  @override
  void initState() {
    _scan();
    super.initState();
  }
}
