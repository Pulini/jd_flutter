import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jd_flutter/bean/http/response/scan_code.dart';
import 'package:jd_flutter/fun/management/anti_Counterfeiting/puma_anti_counterfeiting_logic.dart';
import 'package:jd_flutter/utils/utils.dart';
import 'package:jd_flutter/widget/combination_button_widget.dart';
import 'package:jd_flutter/widget/custom_widget.dart';
import 'package:jd_flutter/widget/dialogs.dart';

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
        title: '入库',
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
                    Expanded(child: Text('${state.scanNum.value}条')),
                    Expanded(child: Text(state.palletNumber.value)),
                    const SizedBox(width: 10),
                  ],
                )),
            Row(
              children: [
                Expanded(
                  flex: 1,
                  child: CombinationButton(
                    text: '清空',
                    click: () {
                      askDialog(
                        content: '确定要清空条码吗？',
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
                    text: '入库',
                    click: () {
                      if(state.dataCodeList.isNotEmpty){
                        askDialog(
                          content: '确定要入库吗？',
                          confirm: () {
                            logic.submitCode();
                          },
                        );
                      }else{
                        showSnackBar(title: '警告', message: '无条码可提交');
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
      scan: (code) => {state.addCode(code)},
    );
    super.initState();
  }
}
