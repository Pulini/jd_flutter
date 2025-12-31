import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jd_flutter/bean/http/response/material_label_scan_info.dart';
import 'package:jd_flutter/fun/warehouse/out/material_label_scan/material_label_scan_logic.dart';
import 'package:jd_flutter/utils/extension_util.dart';
import 'package:jd_flutter/widget/combination_button_widget.dart';
import 'package:jd_flutter/widget/custom_widget.dart';
import 'package:jd_flutter/widget/scanner.dart';

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
  final MaterialLabelScanState state = Get.find<MaterialLabelScanLogic>().state;

  var hintStyle = const TextStyle(color: Colors.black);
  var textStyle = TextStyle(color: Colors.blue.shade900);
  var blackText = Colors.black;
  var greenText = Colors.green;
  var redText = Colors.red;
  var yellowText = Colors.yellow;

  Container _titleText({
    required String mes,
    required Color backColor,
    required Color textColor,
    required double paddingNumber,
  }) {
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
                      paddingNumber: 5,
                      textColor: blackText)),
              Expanded(
                  flex: 1,
                  child: _titleText(
                      //订单数
                      mes: 'material_label_scan_detail_order_qty'.tr,
                      backColor: Colors.blueAccent,
                      textColor: blackText,
                      paddingNumber: 5)),
              Expanded(
                  flex: 1,
                  child: _titleText(
                      //已领
                      mes: 'material_label_scan_detail_claimed'.tr,
                      backColor: Colors.blueAccent,
                      textColor: greenText,
                      paddingNumber: 5)),
              Expanded(
                  flex: 1,
                  child: _titleText(
                      //未领
                      mes: 'material_label_scan_detail_not_claimed'.tr,
                      backColor: Colors.blueAccent,
                      textColor: redText,
                      paddingNumber: 5)),
              Expanded(
                  flex: 1,
                  child: _titleText(
                      //本次领料
                      mes: 'material_label_scan_detail_this_collar'.tr,
                      backColor: Colors.blueAccent,
                      textColor: yellowText,
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
          child: InkWell(
            child: Text(text1 ?? '', style: textStyle),
            onTap: () {
              if (text1!.isNotEmpty) {
                showSnackBar(message: text1);
              }
            },
          ),
        ),
      ],
    );
  }

  Row _item(MaterialLabelScanDetailInfo data, int position) {
    return Row(
      children: [
        Expanded(
            flex: 1,
            child: _titleText(
                //尺码
                mes: data.size ?? '',
                backColor: Colors.lightBlueAccent.shade100,
                paddingNumber: 5,
                textColor: blackText)),
        Expanded(
            flex: 1,
            child: _titleText(
                //订单数
                mes: data.orderQty.toShowString(),
                backColor: Colors.lightBlueAccent.shade100,
                textColor: blackText,
                paddingNumber: 5)),
        Expanded(
            flex: 1,
            child: _titleText(
                //已领
                mes: data.qtyReceived.toShowString(),
                backColor: Colors.lightBlueAccent.shade100,
                textColor: greenText,
                paddingNumber: 5)),
        Expanded(
            flex: 1,
            child: _titleText(
                //未领
                mes: data.unclaimedQty.toShowString(),
                backColor: Colors.lightBlueAccent.shade100,
                textColor: redText,
                paddingNumber: 5)),
        Expanded(
            flex: 1,
            child: _titleText(
                //本次领料
                mes: data.thisTime.toShowString(),
                backColor: Colors.lightBlueAccent.shade100,
                textColor: yellowText,
                paddingNumber: 5)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return pageBody(
        title: 'material_label_scan_material_detail'.tr,
        body: Column(
          children: [
            _text('material_label_scan_detail_order'.tr,
                state.dataDetailList[0].mtoNo ?? ''),
            _text('material_label_scan_detail_type_body'.tr,
                state.dataDetailList[0].productName ?? ''),
            _text(
                'material_label_scan_detail_material'.tr,
                (state.dataDetailList[0].materialNumber ?? '') +
                    (state.dataDetailList[0].materialName ?? '')),
            Obx(
              () => _text('material_label_scan_detail_command'.tr,
                  state.commandNumber.value),
            ),
            Obx(
              () => _text(
                  'material_label_scan_detail_quantity'.tr, state.allQty.value),
            ),
            _title(),
            Expanded(
              child: Obx(
                () => ListView.builder(
                  itemCount: state.dataDetailList.length,
                  itemBuilder: (context, index) =>
                      _item(state.dataDetailList[index], index),
                ),
              ),
            ),
            Row(
              children: [
                Expanded(
                  child: CombinationButton(
                    //清空条码
                    text: 'material_label_scan_detail_clear_barcode'.tr,
                    click: () {},
                    combination: Combination.left,
                  ),
                ),
                Expanded(
                  //提交
                  child: CombinationButton(
                    text: 'material_label_scan_detail_submit'.tr,
                    click: () {},
                    combination: Combination.right,
                  ),
                ),
              ],
            )
          ],
        ));
  }

  void scanBarCode() {
    pdaScanner(
      scan: (code) {
        if(state.canScan){
          if(code.isNotEmpty){
            logic.queryBarCodeDetail(barCode: code);
          }
        }else{
         showSnackBar(message: 'material_label_scan_detail_quick'.tr);
        }
      },
    );
  }

  @override
  void initState() {
    scanBarCode();
    super.initState();
  }
}
