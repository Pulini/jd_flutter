import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jd_flutter/utils.dart';
import 'package:jd_flutter/widget/custom_widget.dart';

import '../../bean/http/response/label_info.dart';
import '../../widget/dialogs.dart';
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

  _itemWidget(
    bool selected,
    bool isPrint,
    bool isReport,
    Function(bool) onClick,
    String label,
    String total,
    List<Widget> subItem,
  ) {
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
        title: Text.rich(
          TextSpan(
            children: [
              const TextSpan(
                  text: '标签：', style: TextStyle(fontWeight: FontWeight.bold)),
              TextSpan(
                text: label,
                style: const TextStyle(
                  color: Colors.blueAccent,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        subtitle: Row(
          children: [
            Expanded(
              child: Text.rich(
                TextSpan(
                  children: [
                    const TextSpan(
                        text: '合计：',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    TextSpan(
                      text: total,
                      style: TextStyle(
                        color: Colors.green.shade900,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
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
        children: subItem,
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
          Expanded(
            flex: 5,
            child: TextContainer(
              text: Text(
                text1,
                style: TextStyle(
                  color: type == 1
                      ? Colors.black
                      : type == 3
                          ? Colors.redAccent
                          : Colors.green.shade900,
                ),
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: TextContainer(
              text: Text(
                text2,
                style: TextStyle(
                  color: type == 1
                      ? Colors.black
                      : type == 3
                          ? Colors.redAccent
                          : Colors.green.shade900,
                ),
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: TextContainer(
              text: Text(
                text3,
                style: TextStyle(
                  color: type == 1
                      ? Colors.black
                      : type == 3
                          ? Colors.redAccent
                          : Colors.green.shade900,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  _item1(LabelInfo data) {
    var total = 0.0;
    data.items?.forEach((v) => total = total.add(v.qty ?? 0));
    return _itemWidget(
      data.select,
      data.isBillPrint ?? false,
      data.isScProcessReport ?? false,
      (c) => setState(() => data.select = c),
      data.barCode ?? '',
      total.toShowString(),
      [
        _subitem('指令', '尺码', '装箱数', 1),
        for (var i = 0; i < data.items!.length; ++i)
          _subitem(data.items![i].billNo ?? '指令错误', data.items![i].size ?? '',
              data.items![i].qty.toShowString(), 2)
      ],
    );
  }

  _item2(List<LabelInfo> data) {
    var total = 0.0;
    for (var v in data) {
      total = total.add(v.items?[0].qty ?? 0);
    }
    var widgetList = <Widget>[_subitem('指令', '尺码', '装箱数', 1)];
    groupBy(data, (v) => v.items?[0].size).forEach((k, v) {
      for (var v2 in v) {
        widgetList.add(_subitem(v2.items![0].billNo ?? '指令错误',
            v2.items![0].size ?? '', v2.items![0].qty.toShowString(), 2));
      }
      if (state.isSingleLabel) {
        var subtotal = 0.0;
        for (var v2 in v) {
          subtotal = subtotal.add(v2.items![0].qty ?? 0.0);
        }
        widgetList.add(_subitem('', k!, subtotal.toShowString(), 3));
      }
    });
    return _itemWidget(
      data.where((v) => v.select).length == data.length,
      data[0].isBillPrint ?? false,
      data[0].isScProcessReport ?? false,
      (c) => setState(() {
        for (var v in data) {
          v.select = c;
        }
      }),
      data[0].barCode ?? '',
      total.toShowString(),
      widgetList,
    );
  }

  @override
  Widget build(BuildContext context) {
    return pageBody(
      title: '贴标维护',
      body: Padding(
        padding: const EdgeInsets.only(left: 10, right: 10, bottom: 10),
        child: Obx(() =>
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text.rich(
                TextSpan(
                  children: [
                    const TextSpan(
                      text: '物料：',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    TextSpan(
                      text: state.materialName.value,
                      style: TextStyle(
                        color: Colors.green.shade900,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              Row(children: [
                Expanded(
                  child: Text.rich(
                    TextSpan(
                      children: [
                        const TextSpan(
                          text: '形体：',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        TextSpan(
                          text: state.typeBody.value,
                          style: TextStyle(
                            color: Colors.green.shade900,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
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
                  padding: const EdgeInsets.all(8),
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
                          showSnackBar(title: '错误', message: '没有创建贴标权限');
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
                        click: () {},
                        combination: Combination.middle),
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
            ])),
      ),
      actions: [
        TextButton(
          onPressed: () => showSelectMaterialPopup(
              logic.getSizeList(), (s) => state.filterSize.value = s),
          child: Text('筛选', style: TextStyle(fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }
}
