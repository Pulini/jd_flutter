import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jd_flutter/bean/http/response/puma_box_code_info.dart';
import 'package:jd_flutter/fun/warehouse/manage/anti_Counterfeiting/puma_anti_counterfeiting_logic.dart';
import 'package:jd_flutter/fun/warehouse/manage/anti_Counterfeiting/puma_anti_counterfeiting_outbound_view.dart';
import 'package:jd_flutter/fun/warehouse/manage/anti_Counterfeiting/puma_anti_counterfeiting_store_view.dart';
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

  _title(String title) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
          color: Colors.blueAccent[100],
          border: Border.all(width: 1, color: Colors.black)),
      child: Text(title),
    );
  }

  _subTitle(String title) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
          color: Colors.greenAccent[100],
          border: Border.all(width: 1, color: Colors.black)),
      child: Text(title),
    );
  }

  _item(PumaBoxCodeInfo data) {
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
              '扫描'.tr,
              style: const TextStyle(color: Colors.grey),
            ),
          ),
        ],
        body: Column(
          children: [
            Row(
              children: [
                Expanded(flex: 1, child: _title('指令号')),
                Expanded(flex: 2, child: _title('工厂型体'))
              ],
            ),
            Expanded(
              child: Obx(
                () => ListView.builder(
                  padding: const EdgeInsets.all(8),
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
                    text: '入库',
                    click: () {
                      Get.to(() => const PumaAntiCounterfeitingStorePage());
                    },
                    combination: Combination.left,
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: CombinationButton(
                    text: '分拣',
                    click: () {
                      Get.to(() => const PumaAntiCounterfeitingOutboundPage());
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
      scan: (code) => {logic.getBarCodeListByBoxNumber(code)},
    );
    super.initState();
  }
}
