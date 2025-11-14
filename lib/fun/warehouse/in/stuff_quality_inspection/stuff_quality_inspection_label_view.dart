import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jd_flutter/bean/http/response/stuff_quality_inspection_label_info.dart';
import 'package:jd_flutter/fun/warehouse/in/stuff_quality_inspection/stuff_quality_inspection_logic.dart';
import 'package:jd_flutter/fun/warehouse/in/stuff_quality_inspection/stuff_quality_inspection_state.dart';
import 'package:jd_flutter/utils/extension_util.dart';
import 'package:jd_flutter/widget/combination_button_widget.dart';
import 'package:jd_flutter/widget/custom_widget.dart';
import 'package:jd_flutter/widget/edit_text_widget.dart';

class StuffQualityInspectionLabelPage extends StatefulWidget {
  const StuffQualityInspectionLabelPage({super.key});

  @override
  State<StuffQualityInspectionLabelPage> createState() =>
      _StuffQualityInspectionLabelPageState();
}

class _StuffQualityInspectionLabelPageState
    extends State<StuffQualityInspectionLabelPage> {
  final StuffQualityInspectionLogic logic =
      Get.find<StuffQualityInspectionLogic>();
  final StuffQualityInspectionState state =
      Get.find<StuffQualityInspectionLogic>().state;

  var borders = const BorderSide(color: Colors.grey, width: 1);

  void _showChangeDialog(StuffQualityInspectionLabelInfo data, int position) {
    var changeQty = data.unqualified;
    var changeShort = data.short;
    var changeVolume = data.volume;
    var changeGrossWeight = data.grossWeight;
    var changeNetWeight = data.netWeight;
    Get.dialog(
      PopScope(
        canPop: false,
        child: AlertDialog(
          title: Text('quality_inspection_input_detail'.tr),
          content: SizedBox(
            height: 100,
            width: 450,
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                        child: NumberDecimalEditText(
                      hint: '不合格数量',
                      max: data.boxQty,
                      initQty: data.unqualified,
                      onChanged: (d) => changeQty = d,
                    )),
                    Expanded(
                        child: NumberDecimalEditText(
                      hint: '短码',
                      initQty: data.short,
                      onChanged: (d) => changeShort = d,
                    ))
                  ],
                ),
                Row(
                  children: [
                    Expanded(
                        child: NumberDecimalEditText(
                      hint: '体积',
                      initQty: data.volume,
                      onChanged: (d) => changeVolume = d,
                    )),
                    Expanded(
                        child: NumberDecimalEditText(
                      hint: '毛重',
                      initQty: data.grossWeight,
                      onChanged: (d) => changeGrossWeight = d,
                    )),
                    Expanded(
                        child: NumberDecimalEditText(
                      hint: '净重',
                      initQty: data.netWeight,
                      onChanged: (d) => changeNetWeight = d,
                    ))
                  ],
                )
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                logic.changeLabel(
                  position: position,
                  changeQty: changeQty!,
                  changeShort: changeShort!,
                  changeVolume: changeVolume!,
                  changeGrossWeight: changeGrossWeight!,
                  changeNetWeight: changeNetWeight!,
                );
                Get.back();
              },
              child: Text(
                'dialog_default_confirm'.tr,
                style: const TextStyle(color: Colors.grey),
              ),
            ),
            TextButton(
              onPressed: () => Get.back(),
              child: Text(
                'dialog_default_cancel'.tr,
                style: const TextStyle(color: Colors.grey),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _item(StuffQualityInspectionLabelInfo data, int position) {
    var backColors = Colors.white;
    if (data.barCode == '合计') {
      backColors = Colors.yellow.shade200;
    } else {
      if (data.select) {
        backColors = Colors.green.shade100;
      } else {
        backColors = Colors.white;
      }
    }
    return SizedBox(
      width: 100 * 9,
      child: SizedBox(
        height: 35,
        child: InkWell(
          onTap: () {
            setState(() {
              if(data.barCode!='合计'){
                data.select = !data.select;
              }
            });
          },
          child: Row(
            children: [
              Expanded(
                  flex: 5,
                  child: _text(
                      //标签
                      mes: data.label ?? '',
                      backColor: backColors,
                      head: false,
                      paddingNumber: 5)),
              Expanded(
                  flex: 2,
                  child: _text(
                      //装箱数量
                      mes: data.barCode=='合计'? '':data.boxQty.toShowString(),
                      backColor: backColors,
                      head: false,
                      paddingNumber: 5)),
              Expanded(
                  flex: 2,
                  child: _text(
                      //尺码
                      mes: data.size ?? '',
                      backColor: backColors,
                      head: false,
                      paddingNumber: 5)),
              Expanded(
                  flex: 2,
                  child: _text(
                      //不合格数量
                      mes: data.unqualified.toShowString(),
                      backColor: backColors,
                      head: false,
                      paddingNumber: 5)),
              Expanded(
                  flex: 2,
                  child: _text(
                      //短码
                      mes: data.short.toShowString(),
                      backColor: backColors,
                      head: false,
                      paddingNumber: 5)),
              Expanded(
                  flex: 2,
                  child: _text(
                      //体积
                      mes: data.barCode=='合计'? '':data.volume.toShowString(),
                      backColor: backColors,
                      head: false,
                      paddingNumber: 5)),
              Expanded(
                  flex: 2,
                  child: _text(
                      //毛重
                      mes:  data.barCode=='合计'? '':data.grossWeight.toShowString(),
                      backColor: backColors,
                      head: false,
                      paddingNumber: 5)),
              Expanded(
                  flex: 2,
                  child: _text(
                      //净重
                      mes: data.barCode=='合计'? '':data.netWeight.toShowString(),
                      backColor: backColors,
                      head: false,
                      paddingNumber: 5)),
              Expanded(
                  flex: 14,
                  child: _text(
                      //物料名称
                      mes: data.barCode=='合计'? '':'(${data.materialCode ?? ''})${data.materialName ?? ''}',
                      backColor: backColors,
                      head: false,
                      paddingNumber: 5)),
            ],
          ),
          onLongPress: () {
            if(data.barCode!='合计'){
              _showChangeDialog(data, position);
            }
          },
        ),
      ),
    );
  }

  Container _text({
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
            maxLines: 1,
            mes,
            style: TextStyle(color: textColor,),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return pageBody(
      title: 'quality_inspection_unqualified_details'.tr,
      body: Obx(() => SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SizedBox(
              width: 130 * 10,
              child: Column(
                children: [
                  Row(
                    children: [
                      const SizedBox(width: 20),
                      //送货单号
                      expandedTextSpan(
                          hint: 'quality_inspection_delivery_number'.tr,
                          text: state.deliveryNoteNumberToSelect),
                      //品检单号
                      expandedTextSpan(
                          hint: 'quality_inspection_inspection_split_number'.tr,
                          text: state.inspectionNumberToSelect),
                      expandedTextSpan(
                          hint: 'quality_inspection_unqualified'.tr,
                          text: state.labelUnQty.toShowString()),
                      expandedTextSpan(
                          hint: 'quality_inspection_short_quality'.tr,
                          text: state.labelShortQty.toShowString())
                    ],
                  ),
                  Container(
                    height: 35,
                    decoration: BoxDecoration(
                      border:
                          Border(top: borders, left: borders, right: borders),
                      color: Colors.blue.shade300,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                            flex: 5,
                            child: _text(
                                //标签
                                mes: 'quality_inspection_label'.tr,
                                backColor: Colors.blueAccent.shade100,
                                head: true,
                                paddingNumber: 5)),
                        Expanded(
                            flex: 2,
                            child: _text(
                                //标签数量
                                mes: 'quality_inspection_label_box_number'.tr,
                                backColor: Colors.blueAccent.shade100,
                                head: true,
                                paddingNumber: 5)),
                        Expanded(
                            flex: 2,
                            child: _text(
                                //尺码
                                mes: 'quality_inspection_size'.tr,
                                backColor: Colors.blueAccent.shade100,
                                head: true,
                                paddingNumber: 5)),
                        Expanded(
                            flex: 2,
                            child: _text(
                                //不合格数量
                                mes: 'quality_inspection_unQuality'.tr,
                                backColor: Colors.blueAccent.shade100,
                                head: true,
                                paddingNumber: 5)),
                        Expanded(
                            flex: 2,
                            child: _text(
                                //短码
                                mes: 'quality_inspection_short'.tr,
                                backColor: Colors.blueAccent.shade100,
                                head: true,
                                paddingNumber: 5)),
                        Expanded(
                            flex: 2,
                            child: _text(
                                //体积
                                mes: 'quality_inspection_volume'.tr,
                                backColor: Colors.blueAccent.shade100,
                                head: true,
                                paddingNumber: 5)),
                        Expanded(
                            flex: 2,
                            child: _text(
                                //毛重
                                mes: 'quality_inspection_gross_weight'.tr,
                                backColor: Colors.blueAccent.shade100,
                                head: true,
                                paddingNumber: 5)),
                        Expanded(
                            flex: 2,
                            child: _text(
                                //净重
                                mes: 'quality_inspection_net_weight'.tr,
                                backColor: Colors.blueAccent.shade100,
                                head: true,
                                paddingNumber: 5)),
                        Expanded(
                            flex: 14,
                            child: _text(
                                //物料名称
                                mes: 'quality_inspection_material'.tr,
                                backColor: Colors.blueAccent.shade100,
                                head: true,
                                paddingNumber: 5)),
                      ],
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                      itemCount: state.labelData.length,
                      itemBuilder: (BuildContext context, int index) =>
                          _item(state.labelData[index], index),
                    ),
                  ),
                  SizedBox(
                    width: double.maxFinite,
                    child: Row(
                      children: [
                        Expanded(
                            child: CombinationButton(
                          //全部不合格
                          text: 'quality_inspection_all_unqualified'.tr,
                          click: () {
                              logic.selectAllUnqualified(true);
                          },
                          combination: Combination.left,
                        )),
                        Expanded(
                            child: CombinationButton(
                              //提交
                              text: 'quality_inspection_submit'.tr,
                              click: () {
                                if (logic.submitSelect()) {
                                  Get.back(result: true);
                                }
                              },
                              combination: Combination.middle,
                            )),
                        Expanded(
                            child: CombinationButton(
                          //全部短码
                          text: 'quality_inspection_all_short'.tr,
                          click: () {
                            logic.selectAllUnqualified(false);
                          },
                          combination: Combination.right,
                        )),
                      ],
                    ),
                  )
                ],
              ),
            ),
          )),
    );
  }
}
