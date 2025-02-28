import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jd_flutter/fun/warehouse/manage/anti_Counterfeiting/puma_anti_counterfeiting_logic.dart';
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
        title: '出库',
        body: Column(
          children: [
            Obx(() => Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(8),
                    itemCount: state.dataCodeList.length,
                    itemBuilder: (BuildContext context, int index) =>
                        Text('123'),
                  ),
                )),
            Row(
              children: [
                Expanded(
                  flex: 1,
                  child: CombinationButton(
                    text: '清空',
                    click: () {
                      askDialog(
                        content: '确定要清空吗？',
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
                    text: '获取条码',
                    click: () {
                      askDialog(
                        content: '确定要获取条码吗？',
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
                    text: '出库',
                    click: () {
                      askDialog(
                        content: '确定要出库吗？',
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
