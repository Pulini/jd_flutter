import 'package:audioplayers/audioplayers.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jd_flutter/bean/http/response/out_box_labels_info.dart';
import 'package:jd_flutter/utils/app_init.dart';
import 'package:jd_flutter/utils/extension_util.dart';
import 'package:jd_flutter/widget/combination_button_widget.dart';
import 'package:jd_flutter/widget/custom_widget.dart';
import 'package:jd_flutter/widget/dialogs.dart';
import 'package:jd_flutter/widget/scanner.dart';

import 'carton_label_scan_logic.dart';
import 'carton_label_scan_state.dart';

class CartonLabelScanClearTailDetailPage extends StatefulWidget {
  const CartonLabelScanClearTailDetailPage({super.key});

  @override
  State<CartonLabelScanClearTailDetailPage> createState() =>
      _CartonLabelScanClearTailDetailPageState();
}

class _CartonLabelScanClearTailDetailPageState
    extends State<CartonLabelScanClearTailDetailPage> {
  final CartonLabelScanLogic logic = Get.find<CartonLabelScanLogic>();
  final CartonLabelScanState state = Get.find<CartonLabelScanLogic>().state;

  late AudioPlayer player;
  var as1 = 'audios/audio_success1.mp3';
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

  @override
  Widget build(BuildContext context) {
    return pageBody(
        title: 'carton_label_scan_order_order_clearance_scan'.tr,
        body: Obx(() => Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
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
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        textSpan(
                          hint: 'carton_label_scan_outside_code'.tr,
                          text:
                              state.outBoxList[state.showIndex].outBoxBarCode ??
                                  '',
                        ),
                        Padding(
                          padding: const EdgeInsets.only(
                            top: 8,
                            left: 4,
                            right: 4,
                            bottom: 8,
                          ),
                          child: CustomProgressIndicator(
                            max: state.tailLabelTotal.value.toDouble(),
                            value: state.tailScannedLabelTotal.value.toDouble(),
                          ),
                        ),
                        Row(
                          children: [
                            Expanded(
                              child: CombinationButton(
                                text: 'carton_label_scan_rescan_inside_code'.tr,
                                click: () => logic.cleanDetailScanned(),
                                combination: Combination.intact,
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
                      itemCount: state.outBoxList[state.showIndex]
                          .mantissaDataSizeList?.length,
                      itemBuilder: (c, i) => _CartonInsideLabelItem(
                          data: state.outBoxList[state.showIndex]
                              .mantissaDataSizeList![i]),
                    ),
                  ),
                  CombinationButton(
                    text: 'carton_label_scan_submit'.tr,
                    click: () {
                      askDialog(
                          content: 'carton_label_scan_order_sure_submit'.tr,
                          confirm: () {
                            logic.subMantissa((s) => {
                                  successDialog(
                                      content: s,
                                      back: () {
                                        Get.back(result: true);
                                      })
                                });
                          });
                    },
                  )
                ],
              ),
            )));
  }

  void _scan() {
    pdaScanner(scan: (barCode) {
      logic.tailDetailScan(
          add: () {
            playAudio(as1);
          },
          full: () {
            playAudio(ae2);
          },
          barCode: barCode);
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
  void dispose() {
    super.dispose();
  }
}

class _CartonInsideLabelItem extends StatelessWidget {
  final MantissaDataSizeList data;

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
                text: data.thisShortQty.toString(),
                textColor: Colors.black,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
