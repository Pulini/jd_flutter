import 'package:audioplayers/audioplayers.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jd_flutter/bean/http/response/packing_shipment_scan_info.dart';
import 'package:jd_flutter/fun/warehouse/out/forming_packing_scan/packing_scan_logic.dart';
import 'package:jd_flutter/utils/app_init.dart';
import 'package:jd_flutter/utils/extension_util.dart';
import 'package:jd_flutter/widget/custom_widget.dart';
import 'package:jd_flutter/widget/scanner.dart';

class PackingShipmentScanPage extends StatefulWidget {
  const PackingShipmentScanPage({super.key});

  @override
  State<PackingShipmentScanPage> createState() =>
      _PackingShipmentScanPageState();
}

class _PackingShipmentScanPageState extends State<PackingShipmentScanPage> {
  final logic = Get.put(PackingScanLogic());
  final state = Get.find<PackingScanLogic>().state;

  late AudioPlayer player;
  var as1 = 'audios/audio_code_error.mp3';
  var as2 = 'audios/audio_scan_repeat.mp3';
  var as3 = 'audios/audio_again_click.mp3';
  var as4 = 'audios/audio_add_fail.mp3';

  Row _item(GtItem data) {
    return Row(
      children: [
        expandedFrameText(
          maxLines: 1,
          text:
              '${data.salesDocument} ${data.originalOrderNumber} ${data.customerPO}',
          backgroundColor:
              data.isThis ? Colors.yellowAccent.shade100 : Colors.blue.shade50,
          flex: 3,
        ),
        expandedFrameText(
          text: '  ${data.sendBox}/${data.boxNumber}',
          backgroundColor:
              data.isThis ? Colors.yellowAccent.shade100 : Colors.blue.shade50,
          flex: 1,
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return pageBody(
      title: 'packing_shipment_out_title'.tr,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('packing_shipment_cabinet_number'.tr + state.showCabinetNumber),
          Obx(
            () => Text('packing_shipment_code'.tr + state.scanNumber.value),
          ),
          Row(
            children: [
              expandedFrameText(
                text: 'packing_shipment_order_no'.tr,
                backgroundColor: Colors.blue.shade50,
                flex: 3,
              ),
              expandedFrameText(
                text: '  ${'packing_shipment_issued'.tr}',
                backgroundColor: Colors.blue.shade50,
                flex: 1,
              )
            ],
          ),
          Expanded(
            child: Obx(
              () => ListView.builder(
                itemCount: state.showDataList.length,
                itemBuilder: (BuildContext context, int index) =>
                    _item(state.showDataList[index]),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void playAudio(String as) {
    if ((deviceInfo() as AndroidDeviceInfo).version.release.toDoubleTry() >=
        8) {
      //安卓8.0以上才能调用这个api
      //安卓5.1会出现 Didn't find class "android.media.AudioFocusRequest"
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
  void initState() {
    pdaScanner(
      scan: (scanCode) {
        if (state.canAdd) {
          switch (state.checkCode(
            code: scanCode,
            checkSuccess: (successOrder) {
              //扫描成功
              showScanTips();
              state.getShipmentInformation(
                  time: logic.pickerControllerDate
                      .getDateFormatYMD()
                      .replaceAll('-', ''),
                  cabinetNumber: state.showCabinetNumber,
                  isGo: false,
                  order: successOrder);
            },
            checkError: () {//添加条码失败
              playAudio(as4);
            },
          )) {
            case 1: //条码错误
              playAudio(as1);
              break;
            case 2: //含有重复的交货单
              playAudio(as2);
              break;
          }
        } else {
          //不可以一直点击
          playAudio(as3);
        }
      },
    );
    super.initState();
  }
}
