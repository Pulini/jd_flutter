import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jd_flutter/fun/warehouse/in/anti_counterfeiting/puma_anti_counterfeiting_logic.dart';
import 'package:jd_flutter/widget/combination_button_widget.dart';
import 'package:jd_flutter/widget/custom_widget.dart';
import 'package:jd_flutter/widget/dialogs.dart';
import 'package:jd_flutter/widget/scanner.dart';


class PumaAntiCounterfeitingOutboundPage extends StatefulWidget {
  const PumaAntiCounterfeitingOutboundPage({super.key});

  @override
  State<PumaAntiCounterfeitingOutboundPage> createState() =>
      _PumaAntiCounterfeitingOutboundPageState();
}

class _PumaAntiCounterfeitingOutboundPageState
    extends State<PumaAntiCounterfeitingOutboundPage> {
  final logic = Get.find<PumaAntiCounterfeitingLogic>();
  final state = Get.find<PumaAntiCounterfeitingLogic>().state;

  late AudioPlayer player;
  var as1 = 'audios/audio_scan_success.mp3';

  @override
  Widget build(BuildContext context) {
    return pageBody(
        title: 'code_list_report_outbound'.tr,
        body: Column(
          children: [
            Obx(() => Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(5),
                    itemCount: state.dataCodeList.length,
                    itemBuilder: (BuildContext context, int index) =>
                        Text(state.dataCodeList[index].code.toString()),
                  ),
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
                          state.clearSortingList();
                        },
                      );
                    },
                    combination: Combination.left,
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: CombinationButton(
                    text: 'code_list_report_obtain_barcode'.tr,
                    click: () {
                      askDialog(
                        content: 'code_list_report_getting_barcode'.tr,
                        confirm: () {
                          logic.getBarCodeListByEmp();
                        },
                      );
                    },
                    combination: Combination.right,
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: CombinationButton(
                    text: 'code_list_report_outbound'.tr,
                    click: () {
                      askDialog(
                        content: 'code_list_report_sure_outbound'.tr,
                        confirm: () {
                          logic.submitOutCode();
                        },
                      );
                    },
                    combination: Combination.right,
                  ),
                )
              ],
            )
          ],
        ));
  }

  playAudio(String as) {
    if (player.state != PlayerState.completed) {
      player.stop();
      player.setSource(AssetSource(as));
      player.resume();
    } else {
      player.play(AssetSource(as));
    }
  }

  @override
  void initState() {
    logic.getBarCodeListByEmp();
    pdaScanner(
      scan: (code) => {
        logic.haveCode(
          code: code,
          have: () {
            playAudio(as1);
          },
        ),
      },
    );
    super.initState();
  }
}
