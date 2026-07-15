import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jd_flutter/bean/http/response/carton_label_scan_info.dart';
import 'package:jd_flutter/fun/warehouse/manage/new_carton_label_scan/new_carton_label_scan_priority_view.dart';
import 'package:jd_flutter/fun/warehouse/manage/new_carton_label_scan/new_carton_label_scan_progress_view.dart';
import 'package:jd_flutter/widget/custom_widget.dart';
import 'package:jd_flutter/widget/combination_button_widget.dart';
import 'package:jd_flutter/widget/dialogs.dart';
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
        successOutsideCode: () {
          playAudio(as3);
        },
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
            showBottomIconDialog();
          },
          icon: const Icon(
            Icons.menu,
            color: Colors.blue,
          ),
        ),
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
                              combination: Combination.intact,
                              text: 'carton_label_scan_submit'.tr,
                              click: () => askDialog(
                                  content: 'carton_label_scan_submit_data'.tr,
                                  confirm: () {
                                    logic.submit(() => controller.text = '');
                                  })),
                        ),
                        // Expanded(  //7.7 林总说还是采用扫码
                        //   child: CombinationButton(
                        //     combination: Combination.right,
                        //     text: 'carton_label_scan_modify_out_box_scanned'.tr,
                        //     click: () => modifyOutBoxScannedDialog(
                        //       scannedQty:
                        //           state.cartonLabelInfo?.scanned.value ?? 0,
                        //       max: state.cartonLabelInfo?.maxScanned() ?? 0,
                        //       modify: (int scannedQty) {
                        //         state.cartonLabelInfo?.scanned.value =
                        //             scannedQty;
                        //       },
                        //     ),
                        //   ),
                        // ),
                      ],
                    ),
            ],
          )),
    );
  }

  void showBottomIconDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // 必须开启，键盘才能顶起弹窗
      enableDrag: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (BuildContext ctx) {
        // 替换原来的Padding为AnimatedPadding，动态避让键盘
        return AnimatedPadding(
          duration: const Duration(milliseconds: 120),
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom,
          ),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
            // 滚动层兜底，防止任何内容溢出
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // 顶部拖拽小横条
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 5),
                  // 按钮区域，你的Row逻辑完全不动
                  Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              icon: const Icon(Icons.calendar_month),
                              style: ElevatedButton.styleFrom(
                                iconColor: Colors.blue,
                                foregroundColor: Colors.black,
                                backgroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical:4), // 压缩按钮高度
                              ),
                              label: Text('carton_label_scan_analysis_report'.tr),
                              onPressed: () {
                                Navigator.pop(ctx);
                                logic.getAnalyze();
                              },
                            ),
                          ),
                          const SizedBox(width:8),
                          Expanded(
                            child: ElevatedButton.icon(
                              icon: const Icon(Icons.published_with_changes_sharp),
                              style: ElevatedButton.styleFrom(
                                iconColor: Colors.blue,
                                foregroundColor: Colors.black,
                                backgroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical:4),
                              ),
                              label: Text('carton_label_scan_order_clean'.tr),
                              onPressed: () {
                                Navigator.pop(ctx);
                                Get.to(() => const NewCartonLabelScanClearTail())
                                    ?.then((v) {
                                  _scan();
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height:6),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              icon: const Icon(Icons.menu_book),
                              style: ElevatedButton.styleFrom(
                                iconColor: Colors.blue,
                                foregroundColor: Colors.black,
                                backgroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical:4),
                              ),
                              label: Text('carton_label_scan_scanning_progress'.tr),
                              onPressed: () {
                                Navigator.pop(ctx);
                                Get.to(
                                      () => const NewCartonLabelScanProgressPage(),
                                  arguments: {
                                    'CustomerPO': state.cartonLabelInfo?.custOrderNumber ?? ''
                                  },
                                )?.then((v) {
                                  _scan();
                                });
                              },
                            ),
                          ),
                          const SizedBox(width:8),
                          Expanded(
                            child: ElevatedButton.icon(
                              icon: const Icon(Icons.low_priority),
                              style: ElevatedButton.styleFrom(
                                iconColor: Colors.blue,
                                foregroundColor: Colors.black,
                                backgroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical:4),
                              ),
                              label: Text('carton_label_scan_dialog_change_priority'.tr),
                              onPressed: () {
                                Navigator.pop(ctx);
                                Get.to(() => const NewCartonLabelScanPriorityPage())?.then((v) => _scan());
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height:6),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              icon: const Icon(Icons.note_alt),
                              style: ElevatedButton.styleFrom(
                                iconColor: Colors.blue,
                                foregroundColor: Colors.black,
                                backgroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical:4),
                              ),
                              label: Text('carton_label_scan_label_confirmation'.tr),
                              onPressed: () {
                                // 点击先关闭底部sheet，再打开输入弹窗（关键！）
                                Navigator.pop(ctx);
                                reasonInputPopup(
                                  title: [
                                    Center(
                                      child: Text(
                                        'carton_label_scan_label_confirmation'.tr,
                                        style: const TextStyle(fontSize: 20, color: Colors.white),
                                      ),
                                    )
                                  ],
                                  hintText: 'carton_label_scan_input_instructions'.tr,
                                  isCanCancel: true,
                                  confirm: (mes) {
                                    logic.checkCode(
                                        success: (String msg) {
                                          successDialog(
                                              content: msg,
                                              back: (){
                                                Get.back();
                                              });
                                        },
                                        msg: mes);
                                  },
                                  cancel: () => Get.back(),
                                );
                              },
                            ),
                          ),
                          const SizedBox(width:8),
                          const Expanded(child: SizedBox()),
                        ],
                      )
                    ],
                  ),
                  const SizedBox(height: 5),
                  // 取消按钮
                  SizedBox(
                    width: double.infinity,
                    child: TextButton(
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 5),
                        backgroundColor: Colors.grey.shade100,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: () => Navigator.pop(ctx),
                      child: const Text(
                        "取消",
                        style: TextStyle(fontSize: 16, color: Colors.black87),
                      ),
                    ),
                  ),
                  // 底部安全距离
                  SizedBox(height: MediaQuery.of(ctx).padding.bottom),
                ],
              ),
            ),
          ),
        );
      },
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
