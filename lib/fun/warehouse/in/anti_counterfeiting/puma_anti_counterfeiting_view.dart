import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jd_flutter/bean/http/response/puma_box_code_info.dart';
import 'package:jd_flutter/fun/warehouse/in/anti_counterfeiting/puma_anti_counterfeiting_logic.dart';
import 'package:jd_flutter/fun/warehouse/in/anti_counterfeiting/puma_anti_counterfeiting_outbound_view.dart';
import 'package:jd_flutter/fun/warehouse/in/anti_counterfeiting/puma_anti_counterfeiting_store_view.dart';
import 'package:jd_flutter/widget/combination_button_widget.dart';
import 'package:jd_flutter/widget/custom_widget.dart';
import 'package:jd_flutter/widget/scanner.dart';

class PumaAntiCounterfeitingPage extends StatefulWidget {
  const PumaAntiCounterfeitingPage({super.key});

  @override
  State<PumaAntiCounterfeitingPage> createState() =>
      _PumaAntiCounterfeitingPageState();
}

class _PumaAntiCounterfeitingPageState
    extends State<PumaAntiCounterfeitingPage> {
  final logic = Get.put(PumaAntiCounterfeitingLogic());
  final state = Get.find<PumaAntiCounterfeitingLogic>().state;

  Container _title(String title) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
          color: Colors.blueAccent[100],
          border: Border.all(width: 1, color: Colors.black)),
      child: Text(title),
    );
  }

  Container _subTitle(String title) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
          color: Colors.greenAccent[100],
          border: Border.all(width: 1, color: Colors.black)),
      child: Text(title),
    );
  }

  Row _item(PumaBoxCodeInfo data) {
    return Row(
      children: [
        Expanded(child: _subTitle(data.fCommandNumber.toString())),
        Expanded(child: _subTitle(data.fPO.toString())),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return pageBody(
        actions: [
          TextButton(
            onPressed: () => Get.to(() => const Scanner())?.then((v) {
              if (v != null) {
                logic.getBarCodeListByBoxNumber(v);
              }
            }),
            child: Text(
              'code_list_report_scan'.tr,
              style: const TextStyle(color: Colors.grey),
            ),
          ),
        ],
        body: Column(
          children: [
            Row(
              children: [
                Expanded(
                    flex: 1,
                    child: _title('code_list_report_instruction_number'.tr)),
                Expanded(
                    flex: 2,
                    child: _title('code_list_report_factory_type_body'.tr))
              ],
            ),
            Expanded(
              child: Obx(
                    () => ListView.builder(
                  padding: const EdgeInsets.all(5),
                  itemCount: state.dataList.length,
                  itemBuilder: (BuildContext context, int index) =>
                      _item(state.dataList[index]),
                ),
              ),
            ),
            Row(
              children: [
                Expanded(
                  flex: 1,
                  child: CombinationButton(
                    text: 'code_list_report_store'.tr,
                    click: () {
                      Get.to(() => const PumaAntiCounterfeitingStorePage())
                          ?.then((v) => _scan());
                    },
                    combination: Combination.left,
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: CombinationButton(
                    text: 'code_list_report_sorting'.tr,
                    click: () {
                      Get.to(() => const PumaAntiCounterfeitingOutboundPage())
                          ?.then((v) => _scan());
                    },
                    combination: Combination.right,
                  ),
                )
              ],
            )
          ],
        ));
  }

  void _scan() {
    pdaScanner(
      scan: (code) => logic.getBarCodeListByBoxNumber(code),
    );
  }

  @override
  void initState() {
    pdaScanner(
      scan: (code) => logic.getBarCodeListByBoxNumber(code),
    );
    super.initState();
  }
}
