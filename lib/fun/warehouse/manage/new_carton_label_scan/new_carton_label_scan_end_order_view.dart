import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jd_flutter/widget/custom_widget.dart';
import 'package:jd_flutter/widget/scanner.dart';

import 'new_carton_label_scan_logic.dart';
import 'new_carton_label_scan_state.dart';

class NewCartonLabelScanEndOrderPage extends StatefulWidget {
  const NewCartonLabelScanEndOrderPage({super.key});

  @override
  State<NewCartonLabelScanEndOrderPage> createState() =>
      _NewCartonLabelScanEndOrderPageState();
}

class _NewCartonLabelScanEndOrderPageState
    extends State<NewCartonLabelScanEndOrderPage> {
  final NewCartonLabelScanLogic logic = Get.find<NewCartonLabelScanLogic>();
  final NewCartonLabelScanState state =
      Get.find<NewCartonLabelScanLogic>().state;

  Row titleLine() {
    return Row(
      children: [
        ExpandedFrameText(
          flex: 2,
          text: 'carton_label_scan_order_size'.tr,
          alignment: Alignment.center,
          backgroundColor: Colors.lightBlue,
          textColor: Colors.white,
          borderColor: Colors.grey,
        ),
        ExpandedFrameText(
          flex: 3,
          text: 'carton_label_scan_order_quality'.tr,
          alignment: Alignment.center,
          backgroundColor: Colors.lightBlue,
          textColor: Colors.white,
          borderColor: Colors.grey,
        ),
        ExpandedFrameText(
          flex: 3,
          text: 'carton_label_scan_order_full_box'.tr,
          alignment: Alignment.center,
          backgroundColor: Colors.lightBlue,
          textColor: Colors.white,
          borderColor: Colors.grey,
        ),
        ExpandedFrameText(
          flex: 4,
          text: 'carton_label_scan_order_not_full_box'.tr,
          alignment: Alignment.center,
          backgroundColor: Colors.lightBlue,
          textColor: Colors.white,
          borderColor: Colors.grey,
        ),
        ExpandedFrameText(
          flex: 3,
          text: 'carton_label_scan_order_completed_quantity'.tr,
          alignment: Alignment.center,
          backgroundColor: Colors.lightBlue,
          textColor: Colors.white,
          borderColor: Colors.grey,
        ),
        ExpandedFrameText(
          flex: 2,
          text: 'carton_label_scan_order_arrears'.tr,
          alignment: Alignment.center,
          backgroundColor: Colors.lightBlue,
          textColor: Colors.white,
          borderColor: Colors.grey,
        ),
      ],
    );
  }

  Row item() {
    return const Row(
      children: [
        ExpandedFrameText(
          flex: 2,
          text: '',
          alignment: Alignment.center,
          backgroundColor: Colors.lightBlue,
          textColor: Colors.white,
          borderColor: Colors.grey,
        ),
        ExpandedFrameText(
          flex: 3,
          text: '',
          alignment: Alignment.center,
          backgroundColor: Colors.lightBlue,
          textColor: Colors.white,
          borderColor: Colors.grey,
        ),
        ExpandedFrameText(
          flex: 3,
          text:'',
          alignment: Alignment.center,
          backgroundColor: Colors.lightBlue,
          textColor: Colors.white,
          borderColor: Colors.grey,
        ),
        ExpandedFrameText(
          flex: 4,
          text: '',
          alignment: Alignment.center,
          backgroundColor: Colors.lightBlue,
          textColor: Colors.white,
          borderColor: Colors.grey,
        ),
        ExpandedFrameText(
          flex: 3,
          text: '',
          alignment: Alignment.center,
          backgroundColor: Colors.lightBlue,
          textColor: Colors.white,
          borderColor: Colors.grey,
        ),
        ExpandedFrameText(
          flex: 2,
          text: '',
          alignment: Alignment.center,
          backgroundColor: Colors.lightBlue,
          textColor: Colors.white,
          borderColor: Colors.grey,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return pageBody(
      actions: [
        TextButton(
          onPressed: () {},
          child:  Text(
            'carton_label_scan_submit'.tr,
          ),
        ),
      ],
      title: 'carton_label_scan_clean_order_title'.tr,
      body: Padding(
          padding: const EdgeInsets.all(2),
          child: Column(
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
                          borderSide:
                              const BorderSide(color: Colors.transparent),
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
                            state.queryNotFullBox(
                                barCode: state.tailController.text);
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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  expandedTextSpan(hint: 'carton_label_scan_order_title_factory_body'.tr, text: ''),
                  expandedTextSpan(hint: 'carton_label_scan_ales_order'.tr, text: '')
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  expandedTextSpan(hint: 'carton_label_scan_current_group'.tr, text: ''),
                  expandedTextSpan(hint: 'carton_label_scan_customer_order_number'.tr, text: '')
                ],
              ),
              const SizedBox(height: 5),
              titleLine(),
              Obx(() => Expanded(
                    child: ListView.builder(
                      itemCount: state.outBoxList.length,
                      itemBuilder: (c, i) => item(),
                    ),
                  )),
              Obx(() => textSpan(
                    hint: 'carton_label_scan_dispatch_no'.tr,
                    text: state.dhmDispatchNumber.value,
                  ))
            ],
          )),
    );
  }

  void _scan() {
    pdaScanner(scan: (barCode) {
      if (barCode.isNotEmpty) {
        if (barCode.startsWith('P')) {
          state.dhmDispatchNumber.value = barCode;
          if(state.tailController.text.isNotEmpty){

          }
        } else {
          state.tailController.text = barCode;

        }
      }
    });
  }


  @override
  void dispose() {
    super.dispose();
  }

  @override
  void initState() {
    _scan();
    super.initState();
  }
}


