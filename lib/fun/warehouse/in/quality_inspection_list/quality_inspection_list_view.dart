import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:jd_flutter/bean/http/response/stuff_quality_inspection_detail_info.dart';
import 'package:jd_flutter/bean/http/response/stuff_quality_inspection_info.dart';
import 'package:jd_flutter/fun/warehouse/in/quality_inspection_list/quality_inspection_list_location_dialog.dart';
import 'package:jd_flutter/fun/warehouse/in/quality_inspection_list/quality_inspection_list_logic.dart';
import 'package:jd_flutter/fun/warehouse/in/quality_inspection_list/quality_inspection_list_state.dart';
import 'package:jd_flutter/fun/warehouse/in/quality_inspection_list/quality_inspection_list_store_dialog.dart';
import 'package:jd_flutter/utils/utils.dart';
import 'package:jd_flutter/widget/combination_button_widget.dart';
import 'package:jd_flutter/widget/custom_widget.dart';
import 'package:jd_flutter/widget/dialogs.dart';
import 'package:jd_flutter/widget/edit_text_widget.dart';
import 'package:jd_flutter/widget/picker/picker_view.dart';
import 'package:jd_flutter/widget/spinner_widget.dart';


class QualityInspectionListPage extends StatefulWidget {
  const QualityInspectionListPage({super.key});

  @override
  State<QualityInspectionListPage> createState() =>
      _QualityInspectionListPageState();
}

class _QualityInspectionListPageState extends State<QualityInspectionListPage> {
  final QualityInspectionListLogic logic =
      Get.put(QualityInspectionListLogic());
  final QualityInspectionListState state =
      Get.find<QualityInspectionListLogic>().state;

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

  _colorItem(StuffColorSeparationList data) {
    return Row(
      children: [
        Expanded(
            child: _text(
          mes: data.batch.toString(),
          backColor: Colors.greenAccent.shade100,
          head: false,
          paddingNumber: 5,
        )),
        Expanded(
            child: _text(
          mes: data.colorSeparationQuantity!.toDoubleTry().toShowString(),
          backColor: Colors.greenAccent.shade100,
          head: false,
          paddingNumber: 5,
        ))
      ],
    );
  }

  showColor() {
    Get.dialog(
      PopScope(
        canPop: false,
        child: AlertDialog(
          title: Text('quality_inspection_color_message'.tr),
          content: SizedBox(
            width: 300,
            height: 300,
            child: Column(
              children: [
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                        child: _text(
                      mes: '色系',
                      backColor: Colors.blueAccent,
                      head: true,
                      paddingNumber: 5,
                    )),
                    Expanded(
                        child: _text(
                      mes: '数量',
                      backColor: Colors.blueAccent,
                      head: true,
                      paddingNumber: 5,
                    ))
                  ],
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: state.colorList.length,
                    itemBuilder: (c, i) => _colorItem(state.colorList[i]),
                  ),
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

  Widget _itemSubTitle({required String title, required String data}) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.green.shade700,
            ),
          ),
          Text(
            data,
            style: TextStyle(
              color: Colors.blue.shade900,
            ),
          )
        ],
      ),
    );
  }

  Widget _subItem(StuffQualityInspectionInfo data, int index, int position) {
    return GestureDetector(
      onTap: () {
        logic.goDetail(position);
      },
      child: Container(
        height: 40,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.black54, width: 1),
        ),
        child: Row(
          children: [
            Obx(() => Checkbox(
                  activeColor: Colors.blue,
                  side: const BorderSide(
                    color: Colors.red,
                    width: 2,
                  ),
                  value: data.isSelected.value,
                  onChanged: (v) {
                    logic.selectSubItem(v!, index, position);
                  },
                )),
            const SizedBox(width: 10),
            Expanded(
              flex: 4,
              child: Row(
                children: <Widget>[
                  Text(
                    data.salesAndDistributionVoucherNumber ?? '', //指令
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.blue.shade900,
                    ),
                  ),
                  const SizedBox(width: 10),
                  textSpan(
                    isBold: false,
                    hint: 'quality_inspection_factory_type'.tr,
                    text: data.factoryType ?? '',
                    textColor: Colors.blue.shade900,
                  ),
                  const SizedBox(width: 10),
                  expandedTextSpan(
                    isBold: false,
                    hint: 'quality_inspection_inspection_order_sub'.tr,
                    text: data.inspectionOrderNo ?? '',
                    textColor: Colors.blue.shade900,
                  ),
                ],
              ),
            ),
            Expanded(
              flex: 4,
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      data.inspectionQuantity ?? '0',
                      textAlign: TextAlign.end,
                      style: TextStyle(color: Colors.blue.shade900),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      data.samplingQuantity ?? '0',
                      textAlign: TextAlign.end,
                      style: TextStyle(color: Colors.blue.shade900),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      data.unqualifiedQuantity ?? '0',
                      textAlign: TextAlign.end,
                      style: TextStyle(color: Colors.blue.shade900),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      data.shortCodesNumber ?? '0',
                      textAlign: TextAlign.end,
                      style: TextStyle(color: Colors.blue.shade900),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      data.qualifiedQuantity ?? '0',
                      textAlign: TextAlign.end,
                      style: TextStyle(color: Colors.blue.shade900),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      data.storageQuantity ?? '0',
                      textAlign: TextAlign.end,
                      style: TextStyle(color: Colors.blue.shade900),
                    ),
                  ),
                  const SizedBox(width: 10),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  _item(List<StuffQualityInspectionInfo> data, int position) {
    var itemTitle = Row(
      children: [
        Expanded(
          child: Text(
            maxLines: 2,
            '(${data[0].materialCode}) ${data[0].materialDescription}',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.green.shade900,
            ),
          ),
        ),
        Text(
          '(${data[0].supplierNumber}) ${data[0].name1}',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.green.shade900,
          ),
        ),
      ],
    );

    var itemSubTitle = Column(
      children: [
        Row(
          children: [
            const Expanded(
              flex: 4,
              child: Row(
                children: [
                  SizedBox(
                    width: 10,
                  )
                ],
              ),
            ),
            const SizedBox(width: 63),
            Expanded(
              flex: 4,
              child: Row(
                children: [
                  _itemSubTitle(
                    title: 'quality_inspection_inspection_quantity'.tr,
                    data: data
                        .map((v) => v.inspectionQuantity.toDoubleTry())
                        .reduce((a, b) => a.add(b))
                        .toShowString(),
                  ),
                  _itemSubTitle(
                    title: 'quality_inspection_sampling_quantity'.tr,
                    data: data
                        .map((v) => v.samplingQuantity.toDoubleTry())
                        .reduce((a, b) => a.add(b))
                        .toShowString(),
                  ),
                  _itemSubTitle(
                    title: 'quality_inspection_unqualified_quantity'.tr,
                    data: data
                        .map((v) => v.unqualifiedQuantity.toDoubleTry())
                        .reduce((a, b) => a.add(b))
                        .toShowString(),
                  ),
                  _itemSubTitle(
                    title: 'quality_inspection_short_quantity'.tr,
                    data: data
                        .map((v) => v.shortCodesNumber.toDoubleTry())
                        .reduce((a, b) => a.add(b))
                        .toShowString(),
                  ),
                  _itemSubTitle(
                    title: 'quality_inspection_qualified_quantity'.tr,
                    data: data
                        .map((v) => v.qualifiedQuantity.toDoubleTry())
                        .reduce((a, b) => a.add(b))
                        .toShowString(),
                  ),
                  _itemSubTitle(
                    title: 'quality_inspection_inventory_quantity'.tr,
                    data: data
                        .map((v) => v.storageQuantity.toDoubleTry())
                        .reduce((a, b) => a.add(b))
                        .toShowString(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
    return Container(
      margin: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.blue.shade100, Colors.green.shade50],
        ),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey, width: 2),
      ),
      child: ExpansionTile(
        onExpansionChanged: (v) {
          logic.selectAllSubItem(v, position);
        },
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(10)),
        ),
        title: itemTitle,
        subtitle: itemSubTitle,
        children: [
          for (var i = 0; i < data.length; ++i)
            Padding(
              padding: const EdgeInsets.only(left: 15, right: 55),
              child: _subItem(data[i], i, position),
            ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft, // 横屏左方向
      DeviceOrientation.landscapeRight, // 横屏右方向
    ]);
    return pageBodyWithDrawer(
        queryWidgets: [
          EditText(
            hint: 'quality_inspection_type_body'.tr,
            onChanged: (c) => state.typeBody = c,
          ),
          EditText(
            hint: 'quality_inspection_material_code'.tr,
            onChanged: (c) => state.materialCode = c,
          ),
          EditText(
            hint: 'quality_inspection_instruction'.tr,
            onChanged: (c) => state.instruction = c,
          ),
          EditText(
            hint: 'quality_inspection_inspection_order'.tr,
            onChanged: (c) => state.inspectionOrder = c,
          ),
          EditText(
            hint: 'quality_inspection_temporary_receipt'.tr,
            onChanged: (c) => state.temporaryReceipt = c,
          ),
          EditText(
            hint: 'quality_inspection_receipt_voucher'.tr,
            onChanged: (c) => state.receiptVoucher = c,
          ),
          EditText(
            hint: 'quality_inspection_tracking_number'.tr,
            onChanged: (c) => state.trackingNumber = c,
          ),
          OptionsPicker(
            pickerController: logic.sapCompany,
          ),
          OptionsPicker(pickerController: logic.factoryController),
          OptionsPicker(pickerController: logic.supplierController),
          DatePicker(pickerController: logic.startDate),
          DatePicker(pickerController: logic.endDate),
          Spinner(controller: logic.spType),
        ],
        query: () {
          logic.getInspectionList();
        },
        body: Column(
          children: [
            Expanded(
              child: Obx(() => ListView.builder(
                    shrinkWrap: true,
                    itemCount: state.showDataList.length,
                    itemBuilder: (context, index) =>
                        _item(state.showDataList[index], index),
                  )),
            ),
            Row(
              children: [
                Expanded(
                    child: Obx(() => CombinationButton(
                      isEnabled: state.btnShowReverse.value,
                      //冲销
                      text: 'quality_inspection_reverse'.tr,
                      click: () {
                        logic.checkReceipt(success: () {
                          logic.receiptReversal(error: () {
                            reasonInputPopup(
                              title: [
                                Center(
                                  child: Text(
                                    'quality_inspection_reverse'.tr,
                                    style: const TextStyle(
                                        fontSize: 20,
                                        color: Colors.white),
                                  ),
                                )
                              ],
                              hintText:
                              'quality_inspection_reversal_reason'.tr,
                              isCanCancel: true,
                              confirm: (s) {
                                Get.back();
                                logic.colorSubmit(
                                    reason: '',
                                    success: (s) {
                                      successDialog(
                                          content: s,
                                          back: () {
                                            Get.back(result: true);
                                          });
                                    });
                              },
                            );
                          });
                        });
                      },
                      combination: Combination.left,
                    ))),
                Expanded(
                    child: Obx(() => CombinationButton(
                      isEnabled: state.btnShowStore.value,
                      //入库
                      text: 'quality_inspection_store'.tr,
                      click: () {
                        logic.checkStore(success:
                        qualityInspectionListStoreDialog(
                            success: (date, store1) {
                              logic.store(
                                date: date,
                                store1: store1,
                                success: (s) {
                                  successDialog(
                                      content: s,
                                      back: () {
                                        logic.getInspectionList();
                                      });
                                },
                              );
                            }));
                      },
                      combination: Combination.middle,
                    ))),
                Expanded(
                    child: Obx(() => CombinationButton(
                      //删除
                      isEnabled: state.btnShowDelete.value,
                      text: 'quality_inspection_delete_btn'.tr,
                      click: () => logic.checkDelete(
                          success: () => reasonInputPopup(
                            title: [
                              Center(
                                child: Text(
                                  'quality_inspection_delete_btn'.tr,
                                  style: const TextStyle(
                                      fontSize: 20,
                                      color: Colors.white),
                                ),
                              )
                            ],
                            hintText:
                            'quality_inspection_input_delete_reason'
                                .tr,
                            isCanCancel: true,
                            confirm: (s) {
                              Get.back();
                              logic.deleteData(
                                  reason: s,
                                  success: (s) {
                                    successDialog(
                                        content: s,
                                        back: () {
                                          logic.getInspectionList();
                                        });
                                  });
                            },
                          )),
                      combination: Combination.middle,
                    ))),
                Expanded(
                    child: Obx(() => CombinationButton(
                      //修改
                      isEnabled: state.btnShowChange.value,
                      text: 'quality_inspection_change'.tr,
                      click: () {
                        logic.checkChange(success: () {
                          logic.arrangeChangeData();
                        });
                      },
                      combination: Combination.middle,
                    ))),
                Expanded(
                    child: Obx(() =>CombinationButton(
                      //货位
                      isEnabled: state.btnShowLocation.value,
                      text: 'quality_inspection_location'.tr,
                      click: () {
                        logic.checkSame(success: () {
                          qualityInspectionListLocationDialog(
                              success: (location) {
                                logic.getLocation(
                                    store: location,
                                    success: () {
                                      reasonInputPopup(
                                        title: [
                                          Center(
                                            child: Text(
                                              'quality_inspection_change_location_title'
                                                  .tr,
                                              style: const TextStyle(
                                                  fontSize: 20,
                                                  color: Colors.white),
                                            ),
                                          )
                                        ],
                                        hintText:
                                        'quality_inspection_input_location'
                                            .tr,
                                        tips:
                                        state.locationList[0].location ??
                                            '',
                                        isCanCancel: true,
                                        confirm: (s) {
                                          Get.back();
                                          logic.changeLocation(
                                              location: s,
                                              success: () {
                                                logic.getInspectionList();
                                              });
                                        },
                                      );
                                    });
                              });
                        });
                      },
                      combination: Combination.middle,
                    ))),
                Expanded(
                    child: Obx(() => CombinationButton(
                      //分色
                      isEnabled: state.btnShowColor.value,
                      text: 'quality_inspection_color'.tr,
                      click: () {
                        logic.checkSame(success: () {
                          logic.getColor(success: showColor());
                        });
                      },
                      combination: Combination.right,
                    )))
              ],
            )
          ],
        ));
  }
}
