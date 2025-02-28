import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jd_flutter/bean/http/response/carton_label_scan_info.dart';
import 'package:jd_flutter/fun/warehouse/manage/carton_label_scan/carton_label_scan_progress_view.dart';
import 'package:jd_flutter/widget/combination_button_widget.dart';
import 'package:jd_flutter/widget/custom_widget.dart';
import 'package:jd_flutter/widget/scanner.dart';

import 'carton_label_scan_logic.dart';
import 'carton_label_scan_state.dart';

class CartonLabelScanPage extends StatefulWidget {
  const CartonLabelScanPage({super.key});

  @override
  State<CartonLabelScanPage> createState() => _CartonLabelScanPageState();
}

class _CartonLabelScanPageState extends State<CartonLabelScanPage> {
  final CartonLabelScanLogic logic = Get.put(CartonLabelScanLogic());
  final CartonLabelScanState state = Get.find<CartonLabelScanLogic>().state;

  var controller = TextEditingController();
  late AudioPlayer player;
  var as1 = 'audios/audio_success1.mp3';
  var as2 = 'audios/audio_success2.mp3';
  var as3 = 'audios/audio_success3.mp3';
  var ae1 = 'audios/audio_error1.mp3';
  var ae2 = 'audios/audio_error2.mp3';

  _item(LinkDataSizeList data) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.blue.shade100, Colors.green.shade50],
        ),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey, width: 2),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              textSpan(
                hint: 'carton_label_scan_size'.tr,
                text: data.size ?? '',
              ),
              textSpan(
                hint: 'carton_label_scan_inside_label'.tr,
                text: data.priceBarCode ?? '',
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              textSpan(
                hint: 'carton_label_scan_label_qty'.tr,
                text: data.labelCount.toString(),
                textColor: Colors.black,
              ),
              textSpan(
                hint: 'carton_label_scan_scanned_qty'.tr,
                text: data.scanned.toString(),
                textColor: Colors.black,
              ),
            ],
          ),
        ],
      ),
    );
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
    player = AudioPlayer();
    pdaScanner(scan: (barCode) {
      logic.scan(
        code: barCode,
        outsideCode: (code) {
          controller.text = code;
          playAudio(as3);
        },
        insideCode: (i) => playAudio(as1),
        insideExpired: () => playAudio(ae1),
        notOutsideCode: () => playAudio(ae2),
        submitSuccess: () {
          controller.text = '';
          playAudio(as2);
        },
        submitError: () => playAudio(ae2),
      );
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return pageBody(
      actions: [
        IconButton(
          onPressed: () => Get.to(
            () => const CartonLabelScanProgressPage(),
            arguments: {
              'CustomerPO': state.cartonLabelInfo?.custOrderNumber ?? ''
            },
          ),
          icon: const Icon(
            Icons.menu_book,
            color: Colors.blue,
          ),
        )
      ],
      body: Obx(() => Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
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
                    hintText: 'carton_label_scan_scan_code_or_input_outside_code'.tr,
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
                          logic.queryCartonLabelInfo(controller.text),
                      icon: const Icon(
                        Icons.loupe_rounded,
                        color: Colors.green,
                      ),
                    ),
                  ),
                ),
              ),
              Container(
                margin: const EdgeInsets.all(8),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.green.shade100,
                      Colors.blue.shade200,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(10),
                  // border: Border.all(color: Colors.blue.shade200, width: 2),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    textSpan(
                      hint: 'carton_label_scan_outside_code'.tr,
                      text: state.cartonLabel.value,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(
                        top: 8,
                        left: 4,
                        right: 4,
                        bottom: 8,
                      ),
                      child: progressIndicator(
                        max: state.labelTotal.value.toDouble(),
                        value: state.scannedLabelTotal.value.toDouble(),
                      ),
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: CombinationButton(
                            text: 'carton_label_scan_rescan_code'.tr,
                            click: () =>
                                logic.cleanAll(() => controller.text = ''),
                            combination: Combination.left,
                          ),
                        ),
                        Expanded(
                          child: CombinationButton(
                            text: 'carton_label_scan_rescan_inside_code'.tr,
                            click: () => logic.cleanScanned(),
                            combination: Combination.right,
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(8),
                  itemCount: state.cartonInsideLabelList.length,
                  itemBuilder: (c, i) => _item(state.cartonInsideLabelList[i]),
                ),
              ),
              if (state.labelTotal.value != 0 &&
                  state.labelTotal.value == state.scannedLabelTotal.value)
                CombinationButton(
                  text: 'carton_label_scan_submit'.tr,
                  click: () => logic.submit(() => controller.text = ''),
                )
            ],
          )),
    );
  }

  @override
  void dispose() {
    Get.delete<CartonLabelScanLogic>();
    player.dispose();
    super.dispose();
  }
}
