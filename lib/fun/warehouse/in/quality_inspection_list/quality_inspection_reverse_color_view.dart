import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:jd_flutter/bean/http/response/quality_inspection_show_color.dart';
import 'package:jd_flutter/utils/utils.dart';
import 'package:jd_flutter/widget/combination_button_widget.dart';
import 'package:jd_flutter/widget/custom_widget.dart';
import 'package:jd_flutter/widget/dialogs.dart';
import 'package:jd_flutter/widget/edit_text_widget.dart';
import 'quality_inspection_list_logic.dart';
import 'quality_inspection_list_state.dart';

class QualityInspectionReverseColorPage extends StatefulWidget {
  const QualityInspectionReverseColorPage({super.key});

  @override
  State<QualityInspectionReverseColorPage> createState() =>
      _QualityInspectionReverseColorPageState();
}

class _QualityInspectionReverseColorPageState
    extends State<QualityInspectionReverseColorPage> {
  final QualityInspectionListLogic logic =
      Get.find<QualityInspectionListLogic>();
  final QualityInspectionListState state =
      Get.find<QualityInspectionListLogic>().state;

  var textNumber = TextEditingController(); //实际数量

  var inputNumber = [
    FilteringTextInputFormatter.allow(RegExp('[0-9]')),
  ];

  // 输入数量
  showInputDialog({
    required double allQty,
    required String code,
    required int position,
  }) {
    var qty = 0.0;
    Get.dialog(
      PopScope(
        //拦截返回键
        canPop: false,
        child: AlertDialog(
          title: Text('quality_inspection_input_qty'.tr,
              style: const TextStyle(
                  color: Colors.black, fontWeight: FontWeight.bold)),
          content: NumberDecimalEditText(
            hint: 'production_dispatch_dialog_input_dispatch_qty'.tr,
            max: allQty,
            initQty: allQty,
            hasFocus: true,
            onChanged: (v) {
              qty = v;
            },
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Get.back();
                logic.colorInputQty(qty, position, code);
              },
              child: Text('dialog_default_confirm'.tr),
            ),
            TextButton(
              onPressed: () {
                Get.back();
              },
              child: Text(
                'dialog_default_cancel'.tr,
                style: const TextStyle(color: Colors.grey),
              ),
            ),
          ],
        ),
      ),
      barrierDismissible: false, //拦截dialog外部点击
    );
  }

  _text({
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
            style: TextStyle(color: textColor),
          ),
        ),
      ),
    );
  }

  _item(QualityInspectionShowColor data, int position) {
    var backColors = Colors.white;

    if (data.subItem == '2' || data.subItem == '3') {
      backColors = Colors.greenAccent;
    } else {
      if (data.isSelected.value == true) {
        backColors = Colors.yellowAccent.shade100;
      } else {
        backColors = Colors.white;
      }
    }

    return Row(
      children: [
        Expanded(
            child: InkWell(
          child: _text(
            mes: data.name ?? '',
            backColor: backColors,
            head: false,
            paddingNumber: 5,
          ),
          onTap: () {
            logic.selectColorSubItem(position);
          },
        )),
        Expanded(
            child: _text(
          mes: data.code ?? '',
          backColor: backColors,
          head: false,
          paddingNumber: 5,
        )),
        Expanded(
            child: InkWell(
          child: _text(
            mes: data.color ?? '',
            backColor: backColors,
            head: false,
            paddingNumber: 5,
          ),
          onTap: () {
            if (data.subItem == '1') {
              reasonInputPopup(
                title: [
                  Center(
                    child: Text(
                      'quality_inspection_color_title'.tr,
                      style: const TextStyle(fontSize: 20, color: Colors.white),
                    ),
                  )
                ],
                hintText: 'quality_inspection_input_color'.tr,
                isCanCancel: true,
                confirm: (s) {
                  Get.back();
                  logic.inputColor(s, position);
                },
              );
            }
          },
        )),
        Expanded(
            child: InkWell(
          child: _text(
            mes: data.qty.toShowString(),
            backColor: backColors,
            head: false,
            paddingNumber: 5,
          ),
          onTap: () {
            if (data.subItem == '1') {
              showInputDialog(
                  allQty: data.qty!,
                  position: position,
                  code: data.code.toString());
            }
          },
        ))
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return pageBody(
      title: 'quality_inspection_color_scheme'.tr,
      body: Column(
        children: [
          Row(
            children: [
              Expanded(
                  child: _text(
                mes: 'quality_inspection_material_name'.tr,
                backColor: Colors.blueAccent.shade100,
                head: true,
                paddingNumber: 5,
              )),
              Expanded(
                  child: _text(
                mes: 'quality_inspection_material_code'.tr,
                backColor: Colors.blueAccent.shade100,
                head: true,
                paddingNumber: 5,
              )),
              Expanded(
                  child: _text(
                mes: 'quality_inspection_color_title'.tr,
                backColor: Colors.blueAccent.shade100,
                head: true,
                paddingNumber: 5,
              )),
              Expanded(
                  child: _text(
                mes: 'quality_inspection_quality_title'.tr,
                backColor: Colors.blueAccent.shade100,
                head: true,
                paddingNumber: 5,
              )),
            ],
          ),
          Expanded(
            child: Obx(
              () => ListView.builder(
                itemCount: state.showReceiptColorList.length,
                itemBuilder: (context, index) =>
                    _item(state.showReceiptColorList[index], index),
              ),
            ),
          ),
          Row(
            children: [
              Expanded(
                  child: CombinationButton(
                //新增
                text: 'quality_inspection_add'.tr,
                click: () {
                  logic.colorAdd();
                },
                combination: Combination.left,
              )),
              Expanded(
                  child: CombinationButton(
                //删除
                text: 'quality_inspection_delete_btn'.tr,
                click: () {
                  logic.colorDelete();
                },
                combination: Combination.middle,
              )),
              Expanded(
                  child: CombinationButton(
                //提交
                text: 'quality_inspection_submit'.tr,
                click: () {
                  if (logic.checkSubmit()) {
                    reasonInputPopup(
                      title: [
                        Center(
                          child: Text(
                            'quality_inspection_reverse'.tr,
                            style: const TextStyle(
                                fontSize: 20, color: Colors.white),
                          ),
                        )
                      ],
                      hintText: 'quality_inspection_reversal_reason'.tr,
                      isCanCancel: true,
                      confirm: (s) {
                        Get.back();
                        logic.colorSubmit(
                            reason: '',
                            success: (s) {
                                successDialog(content: s,back: (){
                                  Get.back(result: true);
                                });
                            });
                      },
                    );
                  }
                },
                combination: Combination.right,
              )),
            ],
          )
        ],
      ),
    );
  }
}
