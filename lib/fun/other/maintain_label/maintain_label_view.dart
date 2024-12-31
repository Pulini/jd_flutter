import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jd_flutter/bean/http/response/label_info.dart';
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

  _itemWidget({
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
        title: textSpan(hint: '标签：', text: label, fontSize: 16),
        subtitle: Row(
          children: [
            expandedTextSpan(
              hint: '合计：',
              text: total,
              textColor: Colors.green.shade900,
            ),
            Text(
              isReport
                  ? '工序汇报'
                  : isPrint
                      ? '已打印'
                      : '未打印',
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

  _subitem(String text1, String text2, String text3, int type) {
    return Container(
      margin: EdgeInsets.only(
        left: 10,
        right: 10,
        bottom: type == 3 ? 10 : 0,
      ),
      color: type == 1
          ? Colors.green[50]
          : type == 3
              ? Colors.blue[50]
              : Colors.white,
      child: Row(
        children: [
          expandedFrameText(
            flex: 5,
            text: text1,
            textColor: type == 1
                ? Colors.black
                : type == 3
                    ? Colors.redAccent
                    : Colors.green.shade900,
          ),
          expandedFrameText(
            text: text2,
            textColor: type == 1
                ? Colors.black
                : type == 3
                    ? Colors.redAccent
                    : Colors.green.shade900,
          ),
          expandedFrameText(
            text: text3,
            textColor: type == 1
                ? Colors.black
                : type == 3
                    ? Colors.redAccent
                    : Colors.green.shade900,
          ),
        ],
      ),
    );
  }

  _item1(LabelInfo data) {
    return _itemWidget(
      selected: data.select,
      isPrint: data.isBillPrint ?? false,
      isReport: data.isScProcessReport ?? false,
      onClick: (c) => setState(() => data.select = c),
      label: data.barCode ?? '',
      total: (data.items ?? [])
          .map((v) => v.qty ?? 0)
          .reduce((a, b) => a.add(b))
          .toShowString(),
      subItem: [
        _subitem('指令', '尺码', '装箱数', 1),
        for (var i = 0; i < data.items!.length; ++i)
          _subitem(data.items![i].billNo ?? '指令错误', data.items![i].size ?? '',
              data.items![i].qty.toShowString(), 2)
      ],
    );
  }

  _item2(List<LabelInfo> data) {
    return _itemWidget(
      selected: data.where((v) => v.select).length == data.length,
      isPrint: data[0].isBillPrint ?? false,
      isReport: data[0].isScProcessReport ?? false,
      onClick: (c) => setState(() {
        for (var v in data) {
          v.select = c;
        }
      }),
      label: data[0].barCode ?? '',
      total: data
          .map((v) => v.items?[0].qty ?? 0)
          .reduce((a, b) => a.add(b))
          .toShowString(),
      subItem: logic.createSubItem(
          data: data,
          subItem: (t1, t2, t3, type) => _subitem(t1, t2, t3, type)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return pageBody(
      title: '贴标维护',
      body: Padding(
        padding: const EdgeInsets.only(left: 10, right: 10, bottom: 10),
        child: Obx(() => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                textSpan(
                  hint: '物料：',
                  text: state.materialName.value,
                  textColor: Colors.green.shade900,
                ),
                Row(children: [
                  expandedTextSpan(
                    hint: '形体：',
                    text: state.typeBody.value,
                    textColor: Colors.green.shade900,
                  ),
                  CheckBox(
                    onChanged: (c) => logic.selectPrinted(c),
                    name: '已打印',
                    needSave: false,
                    value: state.cbPrinted.value,
                  ),
                  CheckBox(
                    onChanged: (c) => logic.selectUnprinted(c),
                    name: '未打印',
                    needSave: false,
                    value: state.cbUnprinted.value,
                  ),
                ]),
                Expanded(
                  child: ListView.builder(
                    itemCount: state.isMaterialLabel.value
                        ? state.getLabelList().length
                        : state.getLabelGroupList().length,
                    itemBuilder: (context, index) => state.isMaterialLabel.value
                        ? _item1(state.getLabelList()[index])
                        : _item2(state.getLabelGroupList()[index]),
                  ),
                ),
                Row(
                  children: [
                    Expanded(
                      child: CombinationButton(
                        text: '创建',
                        click: () {
                          if (checkUserPermission('1051105')) {
                            createLabelSelect(
                              single: () => logic.createSingleLabel(),
                              mix: () => logic.getBarCodeCount(
                                true,
                                (data) => createMixLabelDialog(
                                  data,
                                  state.interID,
                                  () => logic.refreshDataList(),
                                ),
                              ),
                              custom: () => logic.getBarCodeCount(
                                false,
                                (data) => createCustomLabelDialog(
                                  data,
                                  state.interID,
                                  state.isMaterialLabel.value,
                                  () => logic.refreshDataList(),
                                ),
                              ),
                            );
                          } else {
                            showSnackBar(
                                title: 'snack_bar_default_wrong'.tr,
                                message: '没有创建贴标权限');
                          }
                        },
                        combination: Combination.left,
                      ),
                    ),
                    Expanded(
                      child: CombinationButton(
                        text: '删除',
                        click: () {
                          var select = logic.getSelectData();
                          askDialog(
                            content:
                                select.isEmpty ? '确定要删除包装清单吗？' : '确定要删除这些标签吗？',
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
                        text: '打印',
                        click: () => logic.checkLanguage(
                          callback: (select, language) {
                            if (language.isEmpty) {
                              logic.printLabel(select: select);
                            } else if (language.length > 1) {
                              selectLanguageDialog(
                                list: language,
                                callback: (s) => logic.printLabel(
                                  select: select,
                                  language: s,
                                ),
                              );
                            } else {
                              logic.printLabel(
                                select: select,
                                language: language[0],
                              );
                            }
                          },
                        ),
                        combination: Combination.middle,
                      ),
                    ),
                    Expanded(
                      child: CombinationButton(
                        text: '设置',
                        click: () => setLabelSelect(
                          property: () => logic.getMaterialProperties(
                            (list) => setLabelPropertyDialog(
                              list,
                              state.interID,
                              state.materialCode,
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
                              state.materialCode,
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
        TextButton(
          onPressed: () => selectMaterialDialog(
              logic.getSizeList(), (s) => state.filterSize.value = s),
          child: Text('筛选', style: TextStyle(fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }
}
