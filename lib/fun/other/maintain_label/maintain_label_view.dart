import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jd_flutter/bean/http/response/label_info.dart';
import 'package:jd_flutter/utils/extension_util.dart';
import 'package:jd_flutter/utils/utils.dart';
import 'package:jd_flutter/widget/check_box_widget.dart';
import 'package:jd_flutter/widget/combination_button_widget.dart';
import 'package:jd_flutter/widget/custom_widget.dart';
import 'package:jd_flutter/widget/dialogs.dart';

import 'maintain_label_dialogs.dart';
import 'maintain_label_logic.dart';

class MaintainLabelPage extends StatefulWidget {
  const MaintainLabelPage({super.key});

  @override
  State<MaintainLabelPage> createState() => _MaintainLabelPageState();
}

class _MaintainLabelPageState extends State<MaintainLabelPage> {
  final logic = Get.put(MaintainLabelLogic());
  final state = Get.find<MaintainLabelLogic>().state;

  Card _itemWidget({
    required bool selected,
    required bool isPrint,
    required bool isReport,
    required Function(bool) onClick,
    required String label,
    required String total,
    required List<Widget> subItem,
  }) {
    return Card(
      color: selected ? Colors.greenAccent.shade100 : Colors.white,
      child: ExpansionTile(
        initiallyExpanded: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(10)),
        ),
        leading: Checkbox(
          value: selected,
          onChanged: (c) => onClick.call(c!),
        ),
        title: textSpan(
            hint: 'maintain_label_label'.tr, text: label, fontSize: 16),
        subtitle: Row(
          children: [
            expandedTextSpan(
              hint: 'maintain_label_total'.tr,
              text: total,
              textColor: Colors.green.shade900,
            ),
            Text(
              isReport
                  ? 'maintain_label_process_report'.tr
                  : isPrint
                      ? 'maintain_label_printed'.tr
                      : 'maintain_label_unprinted'.tr,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isReport
                    ? Colors.green.shade900
                    : isPrint
                        ? Colors.blueAccent
                        : Colors.redAccent,
              ),
            )
          ],
        ),
        children: [
          ...subItem,
          const SizedBox(height: 10),
        ],
      ),
    );
  }

  Container _subitem(String text1, String text2, String text3, int type) {
    return Container(
      margin: EdgeInsets.only(
        left: 10,
        right: 10,
      ),
      color: type == 1
          ? Colors.green[50]
          : type == 3
              ? Colors.blue[50]
              : type == 4
                  ? Colors.orange[50]
                  : Colors.white,
      child: Row(
        children: [
          expandedFrameText(
            flex: 5,
            text: text1,
            textColor: type == 3
                ? Colors.green.shade900
                : type == 4
                    ? Colors.redAccent
                    : Colors.black,
          ),
          expandedFrameText(
            text: text2,
            textColor: type == 3
                ? Colors.green.shade900
                : type == 4
                    ? Colors.redAccent
                    : Colors.black,
          ),
          expandedFrameText(
            text: text3,
            textColor: type == 3
                ? Colors.green.shade900
                : type == 4
                    ? Colors.redAccent
                    : Colors.black,
          ),
        ],
      ),
    );
  }

  Container _partOrderSubitem(
    String text1,
    String text2,
    String text3,
    String text4,
    int type,
  ) {
    return Container(
      margin: EdgeInsets.only(
        left: 10,
        right: 10,
      ),
      color: type == 1
          ? Colors.green[50]
          : type == 3
              ? Colors.blue[50]
              : type == 4
                  ? Colors.orange[50]
                  : Colors.white,
      child: Row(
        children: [
          expandedFrameText(
            flex: 3,
            text: text1,
            textColor: type == 3
                ? Colors.green.shade900
                : type == 4
                    ? Colors.redAccent
                    : Colors.black,
          ),
          expandedFrameText(
            flex: 2,
            text: text2,
            textColor: type == 3
                ? Colors.green.shade900
                : type == 4
                    ? Colors.redAccent
                    : Colors.black,
          ),
          expandedFrameText(
            text: text3,
            textColor: type == 3
                ? Colors.green.shade900
                : type == 4
                    ? Colors.redAccent
                    : Colors.black,
          ),
          expandedFrameText(
            text: text4,
            textColor: type == 3
                ? Colors.green.shade900
                : type == 4
                    ? Colors.redAccent
                    : Colors.black,
          ),
        ],
      ),
    );
  }

  dynamic _item1(LabelInfo data) {
    return _itemWidget(
      selected: data.select,
      isPrint: data.isBillPrint ?? false,
      isReport: data.isScProcessReport ?? false,
      onClick: (c) => setState(() => data.select = c),
      label: data.barCode ?? '',
      total: data.totalQty().toShowString(),
      subItem: state.isPartOrder
          ? [
              _partOrderSubitem(
                'maintain_label_instruction'.tr,
                'maintain_label_part_material'.tr,
                'maintain_label_size'.tr,
                'maintain_label_picking_qty'.tr,
                1,
              ),
              for (var sub in data.subList!)
                for (var item in sub.items!)
                  _partOrderSubitem(
                    sub.billNo ?? 'maintain_label_instruction_error'.tr,
                    item.materialName ?? '',
                    item.size ?? '',
                    item.qty.toShowString(),
                    2,
                  )
            ]
          : [
              _subitem(
                'maintain_label_instruction'.tr,
                'maintain_label_size'.tr,
                'maintain_label_picking_qty'.tr,
                1,
              ),
              for (var sub in data.subList!)
                for (var item in sub.items!)
                  _subitem(
                    sub.billNo ?? 'maintain_label_instruction_error'.tr,
                    item.size ?? '',
                    item.qty.toShowString(),
                    2,
                  )
            ],
    );
  }

  dynamic _item2(List<LabelInfo> data) {
    return _itemWidget(
      selected: data.where((v) => v.select).length == data.length,
      isPrint: data.first.isBillPrint ?? false,
      isReport: data.first.isScProcessReport ?? false,
      onClick: (c) => setState(() {
        for (var v in data) {
          v.select = c;
        }
      }),
      label: data.first.barCode ?? '',
      total: data
          .map((v) => v.totalQty())
          .reduce((a, b) => a.add(b))
          .toShowString(),
      subItem: logic.createSubItem(
        data: data,
        subItem: (t1, t2, t3, type) => _subitem(t1, t2, t3, type),
      ),
    );
  }

  void custom() {
    logic.getBarCodeCount((list) {
      if (list.length > 1) {
        selectInstructDialog(list, selectCallback: (list) {
          createCustomLabelDialog(
            list,
            state.interID,
            logic.getLabelType(LabelCreateType.customOneOrder),
            () => logic.refreshDataList(),
          );
        }, allCallback: (list) {
          createCustomLabelDialog(
            list,
            state.interID,
            logic.getLabelType(LabelCreateType.customOrders),
            () => logic.refreshDataList(),
          );
        });
      } else {
        //创建自定义标签
        createCustomLabelDialog(
          list[0],
          state.interID,
          logic.getLabelType(LabelCreateType.customOneOrder),
          () => logic.refreshDataList(),
        );
      }
    });
  }

  void mixed() {
    logic.getBarCodeCountMix((list) {
      createMixLabelDialog(
          list,
          state.interID,
          logic.getLabelType(LabelCreateType.mixed),
          () => logic.refreshDataList());
    });
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('state.isMaterialLabel.value=${state.isMaterialLabel.value}');
    return pageBody(
      title: 'maintain_label_label_maintenance'.tr,
      body: Padding(
        padding: const EdgeInsets.only(left: 10, right: 10, bottom: 10),
        child: Obx(() => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                textSpan(
                  hint: 'maintain_label_material'.tr,
                  text: state.isPartOrder
                      ? logic.getPartOrderMaterial()
                      : state.materialName.value,
                  textColor: Colors.green.shade900,
                ),
                Row(children: [
                  expandedTextSpan(
                    hint: 'maintain_label_type_body'.tr,
                    text: state.typeBody.value,
                    textColor: Colors.green.shade900,
                  ),
                  CheckBox(
                    onChanged: (c) => logic.selectPrinted(c),
                    name: 'maintain_label_printed'.tr,
                    needSave: false,
                    value: state.cbPrinted.value,
                  ),
                  CheckBox(
                    onChanged: (c) => logic.selectUnprinted(c),
                    name: 'maintain_label_unprinted'.tr,
                    needSave: false,
                    value: state.cbUnprinted.value,
                  ),
                ]),
                Obx(
                  () => Expanded(
                    child: ListView.builder(
                      itemCount: state.isMaterialLabel.value
                          ? state.getLabelList().length
                          : state.getLabelGroupList().length,
                      itemBuilder: (context, index) =>
                          state.isMaterialLabel.value
                              ? _item1(state.getLabelList()[index])
                              : _item2(state.getLabelGroupList()[index]),
                    ),
                  ),
                ),
                Row(
                  children: [
                    Expanded(
                      child: CombinationButton(
                        text: 'maintain_label_create'.tr,
                        click: () {
                          if (checkUserPermission('1051105')) {
                            logic.getCreateLabelType(onlyCustom: () {
                              custom();
                            }, allType: () {
                              createLabelSelect(
                                showAll: true,
                                single: () => logic.createSingleLabel(),
                                mix: () => mixed(),
                                custom: () => custom(),
                              );
                            }, mixAndCustom: () {
                              createLabelSelect(
                                showAll: false,
                                single: () {},
                                mix: () => mixed(),
                                custom: () => custom(),
                              );
                            });
                          } else {
                            showSnackBar(
                              message:
                                  'maintain_label_no_create_label_permission'
                                      .tr,
                              isWarning: true,
                            );
                          }
                        },
                        combination: Combination.left,
                      ),
                    ),
                    Expanded(
                      child: CombinationButton(
                        text: 'maintain_label_delete'.tr,
                        click: () {
                          var select = logic.getSelectData();
                          askDialog(
                            content: select.isEmpty
                                ? 'maintain_label_delete_packing_tips'.tr
                                : 'maintain_label_delete_label_tips'.tr,
                            confirm: () {
                              if (select.isEmpty) {
                                logic.deleteAllLabel();
                              } else {
                                logic.deleteLabels(select);
                              }
                            },
                          );
                        },
                        combination: Combination.middle,
                      ),
                    ),
                    Expanded(
                      child: CombinationButton(
                        text: 'maintain_label_print'.tr,
                        click: () => logic.checkPrintType(),
                        combination: Combination.middle,
                      ),
                    ),
                    Expanded(
                      child: CombinationButton(
                        text: 'maintain_label_set'.tr,
                        click: () => setLabelSelect(
                          property: () => logic.getMaterialProperties(
                            (list) => setLabelPropertyDialog(
                              list,
                              state.interID,
                              state.materialCodes.first,
                              () => logic.refreshDataList(),
                            ),
                          ),
                          boxCapacity: () => logic.getMaterialCapacity(
                            (s) => setLabelCapacityDialog(
                              s,
                              state.interID,
                              () => logic.refreshDataList(),
                            ),
                          ),
                          language: () => logic.getMaterialLanguages(
                            (list) => setLabelLanguageDialog(
                              list,
                              state.materialCodes.first,
                              () => logic.refreshDataList(),
                            ),
                          ),
                        ),
                        combination: Combination.right,
                      ),
                    ),
                  ],
                )
              ],
            )),
      ),
      actions: [
        CombinationButton(
          text: '打印机设置',
          click: () => showPrintSetting(
            context,
          ),
          combination: Combination.intact,
        ),
        TextButton(
          onPressed: () => selectMaterialDialog(
              logic.getSizeList(), (s) => state.filterSize.value = s),
          child: Text(
            'maintain_label_filter'.tr,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        Obx(() => CheckBox(
              onChanged: (c) => state.isShowPreview.value = c,
              name: 'maintain_label_preview'.tr,
              value: state.isShowPreview.value,
            ))
      ],
    );
  }
}
