import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/src/extension_instance.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';
import 'package:jd_flutter/fun/warehouse/out/material_label_scan/material_label_scan_logic.dart';
import 'package:jd_flutter/widget/custom_widget.dart';

import 'material_label_scan_state.dart';

class MaterialLabelScanDetailPage extends StatefulWidget {
  const MaterialLabelScanDetailPage({super.key});

  @override
  State<MaterialLabelScanDetailPage> createState() =>
      _MaterialLabelScanDetailPageState();
}

class _MaterialLabelScanDetailPageState
    extends State<MaterialLabelScanDetailPage> {

  final MaterialLabelScanLogic logic = Get.find<MaterialLabelScanLogic>();
  final MaterialLabelScanState state =
      Get.find<MaterialLabelScanLogic>().state;

  var hintStyle = const TextStyle(color: Colors.black);
  var greenText = const TextStyle(color: Colors.green);
  var redText = const TextStyle(color: Colors.red);
  var yellowText = const TextStyle(color: Colors.yellow);
  var textStyle = TextStyle(color: Colors.blue.shade900);

  Container _titleText({
    required String mes,
    required Color backColor,
    required bool head,
    required double paddingNumber,
  }) {
    var textColor = Colors.white;
    if (head) {
      textColor = Colors.white;
    } else {
      textColor = Colors.black;
    }
    return Container(
      height: 35,
      decoration: BoxDecoration(
        color: backColor, // 背景颜色
        border: Border.all(
          color: Colors.grey, // 边框颜色
          width: 1.0, // 边框宽度
        ),
      ),
      child: Padding(
        padding: EdgeInsets.only(top: paddingNumber, bottom: paddingNumber),
        child: Center(
          child: Text(
            mes,
            maxLines: 1,
            style: TextStyle(color: textColor),
          ),
        ),
      ),
    );
  }


  Column _title() {
    const borders = BorderSide(color: Colors.grey, width: 1);
    return Column(
      children: [
        Container(
          width: double.maxFinite,
          decoration: BoxDecoration(
            border: const Border(top: borders, left: borders, right: borders),
            gradient: LinearGradient(
              colors: [Colors.blue.shade300, Colors.blue.shade100],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: Row(
            children: [
              Expanded(
                  flex: 1,
                  child: _titleText(
                    //尺码
                      mes: 'material_label_scan_detail_size'.tr,
                      backColor: Colors.blueAccent,
                      head: true,
                      paddingNumber: 5)),
              Expanded(
                  flex: 1,
                  child: _titleText(
                    //订单数
                      mes: 'material_label_scan_detail_order_qty'.tr,
                      backColor: Colors.blueAccent,
                      head: true,
                      paddingNumber: 5)),
              Expanded(
                  flex: 1,
                  child: _titleText(
                    //已领
                      mes: 'material_label_scan_detail_claimed'.tr,
                      backColor: Colors.blueAccent,
                      head: true,
                      paddingNumber: 5)),
              Expanded(
                  flex: 1,
                  child: _titleText(
                    //未领
                      mes: 'material_label_scan_detail_not_claimed'.tr,
                      backColor: Colors.blueAccent,
                      head: true,
                      paddingNumber: 5)),
              Expanded(
                  flex: 1,
                  child: _titleText(
                    //本次领料
                      mes: 'material_label_scan_detail_this_collar'.tr,
                      backColor: Colors.blueAccent,
                      head: true,
                      paddingNumber: 5)),
            ],
          ),
        )
      ],
    );
  }

  Row _text(String hint, String? text1) {
    return Row(
      children: [
        Container(
          width: 60,
          margin: const EdgeInsets.only(right: 10),
          alignment: Alignment.centerRight,
          child: Text(hint, style: hintStyle),
        ),
        Expanded(
          child: Text(text1 ?? '', style: textStyle),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return pageBody(
        title: 'material_label_scan_material_detail'.tr,
        body: Column(
          children: [
            _text('material_label_scan_detail_order'.tr, state.dataDetailList[0].mtoNo),
            _text('material_label_scan_detail_type_body'.tr, ''),
            _title(),
            // Expanded(
            //   child: Obx(
            //     () => ListView.builder(
            //       itemCount: state.dataDetailList.length,
            //       itemBuilder: (context, index) =>
            //           _item(state.barCodeByMonoData[index], index),
            //     ),
            //   ),
            // ),
          ],
        ));
  }
}
