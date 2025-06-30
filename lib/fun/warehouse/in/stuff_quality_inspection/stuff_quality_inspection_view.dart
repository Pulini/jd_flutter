import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jd_flutter/bean/http/response/show_color_batch.dart';
import 'package:jd_flutter/bean/http/response/visit_photo_bean.dart';
import 'package:jd_flutter/fun/warehouse/in/stuff_quality_inspection/stuff_quality_inspection_logic.dart';
import 'package:jd_flutter/fun/warehouse/in/stuff_quality_inspection/stuff_quality_inspection_state.dart';
import 'package:jd_flutter/utils/utils.dart';
import 'package:jd_flutter/utils/web_api.dart';
import 'package:jd_flutter/widget/check_box_widget.dart';
import 'package:jd_flutter/widget/combination_button_widget.dart';
import 'package:jd_flutter/widget/custom_widget.dart';
import 'package:jd_flutter/widget/dialogs.dart';
import 'package:jd_flutter/widget/edit_text_widget.dart';
import 'package:jd_flutter/widget/spinner_widget.dart';

class StuffQualityInspectionPage extends StatefulWidget {
  const StuffQualityInspectionPage({super.key});

  @override
  State<StuffQualityInspectionPage> createState() => _StuffQualityInspectionPageState();
}

class _StuffQualityInspectionPageState extends State<StuffQualityInspectionPage> {
  final StuffQualityInspectionLogic logic = Get.put(StuffQualityInspectionLogic());
  final StuffQualityInspectionState state = Get.find<StuffQualityInspectionLogic>().state;

  late SpinnerController spinnerController1;
  late SpinnerController spinnerController2;
  late SpinnerController spinnerController3;

  _text({required String mes}) {
    return Container(
      height: 35,
      decoration: BoxDecoration(
        color: Colors.white, // 背景颜色
        border: Border.all(
          color: Colors.grey, // 边框颜色
          width: 1.0, // 边框宽度
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.only(top: 5, bottom: 5),
        child: Center(
          child: Text(
            mes,
            style: const TextStyle(color: Colors.black),
          ),
        ),
      ),
    );
  }

  _colorItem(ShowColorBatch data, int position) {
    return GestureDetector(
      onLongPress: () {
        logic.removeColor(position);
      },
      child: Row(
        children: [
          Expanded(
              child: _text(
            mes: data.batch ?? '',
          )),
          Expanded(
              child: _text(
            mes: data.qty ?? '',
          ))
        ],
      ),
    );
  }

  showColor(String qty) {
    state.unColorQty.value = qty;

    var colorController = TextEditingController(); //色系
    var qtyController = TextEditingController(); //数量

    Get.dialog(
      PopScope(
        canPop: false,
        child: AlertDialog(
          title: Text('quality_inspection_color_message'.tr),
          content: SizedBox(
            width: 400,
            height: 280,
            child: Column(
              children: [
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Expanded(
                        child: Center(
                      child: textSpan(hint: '入库数量：', text: qty),
                    )),
                    Expanded(
                        child: Center(
                      child: Obx(() => textSpan(
                          hint: '未分色数量：', text: state.unColorQty.value)),
                    ))
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Expanded(
                        child: EditText(
                      hint: '色系'.tr,
                      controller: colorController,
                    )),
                    Expanded(
                        child: EditText(
                      hint: '数量'.tr,
                      controller: qtyController,
                    ))
                  ],
                ),
                SizedBox(
                  width: 120,
                  child: CombinationButton(
                    //分色
                    text: '添加',
                    click: () {
                      logic.addColor(colorController.text, qtyController.text);
                    },
                    combination: Combination.intact,
                  ),
                ),
                Expanded(
                  child: Obx(() => ListView.builder(
                        itemCount: state.inspectionColorList.length,
                        itemBuilder: (c, i) =>
                            _colorItem(state.inspectionColorList[i], i),
                      )),
                )
              ],
            ),
          ),
          contentPadding: const EdgeInsets.only(left: 10, right: 10),
          actionsPadding: const EdgeInsets.only(right: 10, bottom: 10),
          actions: [
            TextButton(
              onPressed: () {
                Get.back();
              },
              child: Text('dialog_default_confirm'.tr),
            ),
          ],
        ),
      ),
    );
  }

  _leavePhotoItem(VisitPhotoBean data, int index) {
    return Container(
        margin: const EdgeInsets.only(left: 20),
        child: GestureDetector(
          onTap: () {
            if (data.typeAdd == "0") {
              takePhoto(callback: (f) {
                logic.addPicture(f.toBase64());
              });
            }
          },
          onLongPress: () {
            logic.removePicture(index);
          },
          child: data.typeAdd != '0'
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(5),
                  child: Image.memory(
                    base64Decode(data.photo!),
                    gaplessPlayback: true,
                    width: 120,
                    height: 80,
                    fit: BoxFit.cover,
                  ),
                )
              : const Icon(
                  Icons.add_a_photo_outlined,
                  color: Colors.blueAccent,
                  size: 50,
                ),
        ));
  }

  _photoListView() {
    return Obx(() => Container(
        margin: const EdgeInsets.only(left: 20, right: 20),
        height: 140,
        decoration: BoxDecoration(
          //背景
          borderRadius: const BorderRadius.all(Radius.circular(4.0)),
          //设置四周边框
          border: Border.all(width: 1, color: Colors.blue),
        ),
        child: ListView.builder(
          padding: const EdgeInsets.all(8),
          scrollDirection: Axis.horizontal,
          itemCount: state.picture.length,
          itemBuilder: (BuildContext context, int index) =>
              _leavePhotoItem(state.picture.toList()[index], index),
        )));
  }

  spText({required String name, required String text}) => Container(
        height: 40,
        margin: const EdgeInsets.all(5),
        padding: const EdgeInsets.only(left: 10, right: 10),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(25),
            color: Colors.grey.shade300),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              name,
              style: const TextStyle(
                color: Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(text,
                style: const TextStyle(color: Colors.black, fontSize: 16))
          ],
        ),
      );

  @override
  Widget build(BuildContext context) {
    return pageBody(
      title: 'quality_inspection_title'.tr,
      actions: [
        Obx(() => CheckBox(
              onChanged: (s) {
                //是否让步
                state.compromise.value = !state.compromise.value;
              },
              name: 'quality_inspection_compromise'.tr,
              value: state.compromise.value,
            )),
        const SizedBox(width: 10),
        Obx(() => Visibility(
              visible: state.showColor.value,
              child: CombinationButton(
                //分色
                text: 'quality_inspection_color'.tr,
                click: () {
                  showColor(logic.qualifiedController.text);
                },
                combination: Combination.intact,
              ),
            )),
        const SizedBox(width: 10),
        //全部合格或者全部不合格
        Obx(() => Visibility(
              visible: state.showAllBtn.value,
              child: CombinationButton(
                text: state.showAllBtnName.value,
                click: () {
                  logic.allBtn();
                },
                combination: Combination.intact,
              ),
            ))
      ],
      body: Padding(
        padding: const EdgeInsets.only(left: 10, right: 10),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                const SizedBox(
                  width: 30,
                ),
               Visibility(child:  expandedTextSpan(
                   flex: 2,
                   hint: '选择不同物料时，只支持填写全部合格,如有不合格，必须分开填写!!',
                   text: '',
                   hintColor: Colors.red,
                   fontSize: 16),visible: state.isShowTips.value,),
                const SizedBox(
                  width: 30,
                ),
                Obx(
                  () => expandedTextSpan(
                    hint: '默认审核人:'.tr,
                    text:
                        '${state.peoPleInfo.value.liableEmpName ?? ''}(${state.peoPleInfo.value.liableEmpCode ?? ''})',
                  ),
                )
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: Obx(
                    () => state.inspectionTypeEnable.value
                        ? Spinner(controller: spinnerController1)
                        : spText(
                            name: 'quality_inspection_method'.tr,
                            text: state.inspectionType.value,
                          ),
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Obx(
                    () => state.typeEnable.value
                        ? Spinner(controller: spinnerController2)
                        : spText(
                            name: 'quality_inspection_category'.tr,
                            text: state.type.value,
                          ),
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Obx(
                    () => state.groupTypeEnable.value
                        ? Spinner(controller: spinnerController3)
                        : spText(
                            name: 'quality_inspection_accepting_unit'.tr,
                            text: state.groupType.value,
                          ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: Obx(() => NumberDecimalEditText(
                      hint: 'quality_inspection_inspection_quantity'.tr,
                      controller: logic.inspectionQuantityController,
                      inputEnable: state.inspectionEnable.value,
                      onChanged: (d) {})),
                ),
                Expanded(
                  child: Obx(() => NumberDecimalEditText(
                      hint: 'quality_inspection_sampling_quantity'.tr,
                      controller: logic.waitInspectionQuantityController,
                      inputEnable: state.waitInputInspectionEnable.value,
                      onChanged: (d) {})),
                ),
                Expanded(
                  child: NumberDecimalEditText(
                      hint: 'quality_inspection_qualified_quantity'.tr,
                      controller: logic.qualifiedController,
                      inputEnable: false,
                      onChanged: (d) {}),
                ),
                Expanded(
                  child: Obx(() => NumberDecimalEditText(
                      hint: 'quality_inspection_unqualified_quantity'.tr,
                      controller: logic.unqualifiedQualifiedController,
                      inputEnable: state.unqualifiedQuantityEnable.value,
                      onChanged: (d) {
                        logic.inputUnqualified(d);
                      })),
                ),
                Expanded(
                  child: Obx(() => NumberDecimalEditText(
                      hint: 'quality_inspection_short_quantity'.tr,
                      controller: logic.shortQualifiedController,
                      inputEnable: state.shortQuantityEnable.value,
                      onChanged: (d) {
                        logic.inputShort(d);
                      })),
                ),
                Expanded(
                  child: NumberDecimalEditText(
                      hint: 'quality_inspection_reviewer'.tr,
                      controller: logic.reviewerController,
                      onChanged: (d) {}),
                )
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                    child: Obx(() => EditText(
                          isEnable: state.abnormalExplanationEnable.value,
                          hint: 'quality_inspection_exception_description'.tr,
                          controller: logic.exceptionDescriptionController,
                        ))),
                Expanded(
                    child: Obx(() => EditText(
                          isEnable: state.processingMethodEnable.value,
                          hint: 'quality_inspection_processing_method'.tr,
                          controller: logic.processingMethodController,
                        ))),
                Expanded(
                    child: NumberDecimalEditText(
                  hint: 'quality_inspection_availability'.tr,
                  controller: logic.availabilityController,
                  onChanged: (d) {
                    if(d<0){
                      logic.availabilityController.text = '0';
                    }
                  },
                  max: 100,
                ))
              ],
            ),
            const SizedBox(height: 10),
            Text('quality_inspection_photo'.tr,
                style: const TextStyle(
                    color: Colors.red,
                    fontSize: 14,
                    fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            _photoListView(),
            const SizedBox(height: 80),
            Row(
              children: [
                Expanded(
                    child: CombinationButton(
                  //提交
                  text: 'quality_inspection_submit'.tr,
                  click: () {
                    askDialog(
                        content: 'quality_inspection_sure_submit'.tr,
                        confirm: () => {
                              logic.submitInspection(
                                  spinnerController1.select.value,
                                  spinnerController2.select.value,
                                  spinnerController3.select.value,
                                  success: (mes) {
                                successDialog(
                                    content: mes,
                                    back: () {
                                      Get.back(result: true);
                                    });
                              }),
                            });
                  },
                  combination: Combination.intact,
                ))
              ],
            )
          ],
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();

    if (Get.arguments != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        state.fromInspectionType = Get.arguments['inspectionType'];
        if (Get.arguments['inspectionType'] == '1') {
          logic.getData(Get.arguments['dataList']);
        } else {
          logger.f('暂收单详情到品检');
          logic.getTemporary(Get.arguments['temporaryDetail']);
        }
      });
    }
    spinnerController1 = SpinnerController(dataList: state.list1);
    spinnerController2 = SpinnerController(dataList: state.list2);
    spinnerController3 = SpinnerController(dataList: state.list3);
    state.picture.clear();
    state.picture.add(VisitPhotoBean(photo: "", typeAdd: "0"));
    WidgetsBinding.instance.addPostFrameCallback((_) {
      logic.searchPeople(userInfo?.number??'');
    });
  }

  @override
  void dispose() {
    Get.delete<StuffQualityInspectionLogic>();
    super.dispose();
  }
}
