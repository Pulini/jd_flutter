import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jd_flutter/bean/http/response/stuff_quality_inspection_info.dart';
import 'package:jd_flutter/fun/warehouse/in/quality_inspection_list/quality_inspection_list_dialog.dart';
import 'package:jd_flutter/utils/utils.dart';
import 'package:jd_flutter/widget/combination_button_widget.dart';
import 'package:jd_flutter/widget/custom_widget.dart';
import 'package:jd_flutter/widget/dialogs.dart';
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

  _item(List<QualityInspectionShowColor> list, int position) {
    Color backColors;
    if (list[position].subItem == '2' || list[position].subItem == '3') {
      backColors = Colors.greenAccent;
    } else {
      if (list[position].isSelected.value == true) {
        backColors = Colors.yellowAccent.shade100;
      } else {
        backColors = Colors.white;
      }
    }
    return Row(
      children: [
        expandedFrameText(
          text: list[position].name ?? '',
          backgroundColor: backColors,
          click: () => logic.selectColorSubItem(position),
        ),
        expandedFrameText(
          text: list[position].code ?? '',
          backgroundColor: backColors,
        ),
        expandedFrameText(
          text: list[position].color ?? '',
          backgroundColor: backColors,
          click: () {
            if (list[position].subItem == '1') {
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
        ),
        expandedFrameText(
          text: list[position].qty.toShowString(),
          backgroundColor: backColors,
          click: () {
            if (list[position].subItem == '1') {
              showInputDialog(
                allQty: list[position].qty!,
                callback: (qty) {
                  logic.colorInputQty(
                    qty,
                    position,
                    list[position].code.toString(),
                  );
                },
              );
            }
          },
        ),
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
              expandedFrameText(
                text: 'quality_inspection_material_name'.tr,
                backgroundColor: Colors.blueAccent.shade100,
                textColor: Colors.white,
              ),
              expandedFrameText(
                text: 'quality_inspection_material_code'.tr,
                backgroundColor: Colors.blueAccent.shade100,
                textColor: Colors.white,
              ),
              expandedFrameText(
                text: 'quality_inspection_color_title'.tr,
                backgroundColor: Colors.blueAccent.shade100,
                textColor: Colors.white,
              ),
              expandedFrameText(
                text: 'quality_inspection_quality_title'.tr,
                backgroundColor: Colors.blueAccent.shade100,
                textColor: Colors.white,
              ),
            ],
          ),
          Expanded(
            child: Obx(
              () => ListView.builder(
                itemCount: state.showReceiptColorList.length,
                itemBuilder: (context, index) =>
                    _item(state.showReceiptColorList, index),
              ),
            ),
          ),
          Row(
            children: [
              Expanded(
                child: CombinationButton(
                  //新增
                  text: 'quality_inspection_add'.tr,
                  click: () => logic.colorAdd(),
                  combination: Combination.left,
                ),
              ),
              Expanded(
                child: CombinationButton(
                  //删除
                  text: 'quality_inspection_delete_btn'.tr,
                  click: () => logic.colorDelete(),
                  combination: Combination.middle,
                ),
              ),
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
                        confirm: (reason) {
                          Get.back();
                          logic.colorSubmit(reason: reason, success: () {  });
                        },
                      );
                    }
                  },
                  combination: Combination.right,
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}
