import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jd_flutter/bean/http/response/scan_code.dart';
import 'package:jd_flutter/fun/warehouse/in/anti_counterfeiting/puma_anti_counterfeiting_logic.dart';
import 'package:jd_flutter/widget/combination_button_widget.dart';
import 'package:jd_flutter/widget/custom_widget.dart';
import 'package:jd_flutter/widget/dialogs.dart';
import 'package:jd_flutter/widget/scanner.dart';

class PumaAntiCounterfeitingStorePage extends StatefulWidget {
  const PumaAntiCounterfeitingStorePage({super.key});

  @override
  State<PumaAntiCounterfeitingStorePage> createState() =>
      _PumaAntiCounterfeitingStorePageState();
}

class _PumaAntiCounterfeitingStorePageState
    extends State<PumaAntiCounterfeitingStorePage> {
  final logic = Get.find<PumaAntiCounterfeitingLogic>();
  final state = Get.find<PumaAntiCounterfeitingLogic>().state;

  _item(ScanCode data) {
    return GestureDetector(
      onLongPress: () {
        state.deleteCode(data);
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 5),
        padding: const EdgeInsets.all(3),
        decoration: BoxDecoration(
            color: Colors.blue.shade100,
            border: Border.all(color: Colors.black, width: 1.0)),
        child: Text(data.code.toString()),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return pageBody(
        title: 'code_list_report_store'.tr,
        body: Column(
          children: [
            Obx(() => Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(8),
                    itemCount: state.dataCodeList.length,
                    itemBuilder: (BuildContext context, int index) =>
                        _item(state.dataCodeList[index]),
                  ),
                )),
            Obx(() => Row(
                  children: [
                    const SizedBox(width: 10),
                    Expanded(child: Text(state.scanNum.value+'code_list_report_strip'.tr)),
                    Expanded(child: Text(state.palletNumber.value)),
                    const SizedBox(width: 10),
                  ],
                )),
            Row(
              children: [
                Expanded(
                  flex: 1,
                  child: CombinationButton(
                    text: 'code_list_report_clean'.tr,
                    click: () {
                      askDialog(
                        content: 'code_list_report_sure_clean'.tr,
                        confirm: () {
                          state.clearData();
                        },
                      );
                    },
                    combination: Combination.left,
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: CombinationButton(
                    text: 'code_list_report_store'.tr,
                    click: () {
                      if(state.dataCodeList.isNotEmpty){
                        askDialog(
                          content: 'code_list_report_sure_store'.tr,
                          confirm: () {
                            logic.submitCode();
                          },
                        );
                      }else{
                        showSnackBar(title: 'shack_bar_warm'.tr, message: 'code_list_report_no_barcode'.tr);
                      }
                    },
                    combination: Combination.right,
                  ),
                )
              ],
            )
          ],
        ));
  }

  @override
  void initState() {
    pdaScanner(
      scan: (code) => state.addCode(code),
    );
    super.initState();
  }
}
