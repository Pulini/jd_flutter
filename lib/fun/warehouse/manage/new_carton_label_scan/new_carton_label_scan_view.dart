import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jd_flutter/bean/http/response/carton_label_scan_info.dart';
import 'package:jd_flutter/fun/warehouse/manage/new_carton_label_scan/new_carton_label_scan_dialog.dart';
import 'package:jd_flutter/fun/warehouse/manage/new_carton_label_scan/new_carton_label_scan_priority_view.dart';
import 'package:jd_flutter/fun/warehouse/manage/new_carton_label_scan/new_carton_label_scan_progress_view.dart';
import 'package:jd_flutter/widget/custom_widget.dart';
import 'package:jd_flutter/widget/combination_button_widget.dart';
import 'package:jd_flutter/widget/scanner.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:jd_flutter/utils/app_init.dart';
import 'package:jd_flutter/utils/extension_util.dart';

import 'new_carton_label_scan_clear_tail.dart';
import 'new_carton_label_scan_logic.dart';
import 'new_carton_label_scan_state.dart';

class NewCartonLabelScanPage extends StatefulWidget {
  const NewCartonLabelScanPage({super.key});

  @override
  State<NewCartonLabelScanPage> createState() => _NewCartonLabelScanPageState();
}

class _NewCartonLabelScanPageState extends State<NewCartonLabelScanPage> {
  final NewCartonLabelScanLogic logic = Get.put(NewCartonLabelScanLogic());
  final NewCartonLabelScanState state =
      Get.find<NewCartonLabelScanLogic>().state;

  var controller = TextEditingController();

  late AudioPlayer player;
  var as1 = 'audios/audio_success1.mp3';
  var as2 = 'audios/audio_success2.mp3';
  var as3 = 'audios/audio_success3.mp3';
  var ae1 = 'audios/audio_error1.mp3';
  var ae2 = 'audios/audio_error2.mp3';

  void playAudio(String as) {
    if ((deviceInfo() as AndroidDeviceInfo).version.release.toDoubleTry() >=
        8) {
      if (player.state != PlayerState.completed) {
        player.stop();
        player.setSource(AssetSource(as));
        player.resume();
      } else {
        player.play(AssetSource(as));
      }
    }
  }

  void _scan() {
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
  }

  @override
  void initState() {
    if ((deviceInfo() as AndroidDeviceInfo).version.release.toDoubleTry() >=
        8) {
      player = AudioPlayer();
    }
    _scan();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return pageBody(
      actions: [
        IconButton(
          onPressed: () {
            Get.to(() => const NewCartonLabelScanClearTail())?.then((v) {
              _scan();
            });
          },
          icon: const Icon(
            Icons.published_with_changes_sharp,
            color: Colors.blue,
          ),
        ),
        IconButton(
          onPressed: () => Get.to(
            () => const NewCartonLabelScanProgressPage(),
            arguments: {
              'CustomerPO': state.cartonLabelInfo?.custOrderNumber ?? ''
            },
          ),
          icon: const Icon(
            Icons.menu_book,
            color: Colors.blue,
          ),
        ),
        IconButton(
          onPressed: () => Get.to(
            () => const NewCartonLabelScanPriorityPage(),
          )?.then((v) => _scan()),
          icon: const Icon(
            Icons.low_priority,
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
                      child: CustomProgressIndicator(
                        max: state.labelTotal.value.toDouble(),
                        value: state.scannedLabelTotal.value.toDouble(),
                      ),
                    ),
                    state.isAutoSubmit.value
                        ? Container()
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              textSpan(
                                isBold: false,
                                textColor: Colors.green.shade800,
                                hint: 'carton_label_scan_out_box_this_time_scan'
                                    .tr,
                                text:
                                    '${state.cartonLabelInfo?.scanned.value ?? 0}',
                              ),
                              textSpan(
                                isBold: false,
                                textColor: Colors.green.shade800,
                                hint: 'carton_label_scan_out_box_scanned'.tr,
                                text:
                                    '${state.cartonLabelInfo?.scannedCount ?? 0}',
                              ),
                              textSpan(
                                isBold: false,
                                textColor: Colors.green.shade800,
                                hint: 'carton_label_scan_out_box_total'.tr,
                                text: '${state.cartonLabelInfo?.piece ?? 0}',
                              ),
                            ],
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
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(8),
                  itemCount: state.cartonInsideLabelList.length,
                  itemBuilder: (c, i) => _CartonInsideLabelItem(
                      data: state.cartonInsideLabelList[i]),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 10, right: 10),
                child: textSpan(
                  hint: 'carton_label_scan_dispatch_no'.tr,
                  text: state.dispatchNumber.value,
                ),
              ),
              state.isAutoSubmit.value
                  ? state.labelTotal.value != 0 &&
                          state.labelTotal.value ==
                              state.scannedLabelTotal.value
                      ? CombinationButton(
                          text: 'carton_label_scan_submit'.tr,
                          click: () => logic.submit(() => controller.text = ''),
                        )
                      : Container()
                  : Row(
                      children: [
                        Expanded(
                          child: CombinationButton(
                            isEnabled: state.labelTotal.value > 0,
                            combination: Combination.left,
                            text: 'carton_label_scan_submit'.tr,
                            click: () =>
                                logic.submit(() => controller.text = ''),
                          ),
                        ),
                        Expanded(
                          child: CombinationButton(
                            combination: Combination.right,
                            text: 'carton_label_scan_modify_out_box_scanned'.tr,
                            click: () => modifyOutBoxScannedDialog(
                              scannedQty:
                                  state.cartonLabelInfo?.scanned.value ?? 0,
                              max: state.cartonLabelInfo?.maxScanned() ?? 0,
                              modify: (int scannedQty) {
                                state.cartonLabelInfo?.scanned.value =
                                    scannedQty;
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
            ],
          )),
    );
  }

  @override
  void dispose() {
    Get.delete<NewCartonLabelScanLogic>();
    player.dispose();
    super.dispose();
  }
}

class _CartonInsideLabelItem extends StatelessWidget {
  final LinkDataSizeNewList data;

  const _CartonInsideLabelItem({required this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.blue.shade50, Colors.white],
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
}
