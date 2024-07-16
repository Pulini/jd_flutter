import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jd_flutter/utils.dart';
import 'package:jd_flutter/widget/custom_widget.dart';
import 'package:rotated_corner_decoration/rotated_corner_decoration.dart';

import '../../../bean/http/response/material_dispatch_info.dart';
import '../../../widget/picker/picker_view.dart';
import 'material_dispatch_logic.dart';

class MaterialDispatchPage extends StatefulWidget {
  const MaterialDispatchPage({super.key});

  @override
  State<MaterialDispatchPage> createState() => _MaterialDispatchPageState();
}

class _MaterialDispatchPageState extends State<MaterialDispatchPage> {
  final logic = Get.put(MaterialDispatchLogic());
  final state = Get.find<MaterialDispatchLogic>().state;

  _item1(MaterialDispatchInfo data) {
    var style = const TextStyle(
      color: Colors.black87,
      fontWeight: FontWeight.bold,
    );
    var itemTitleStyle = const TextStyle(
      color: Colors.white,
      fontSize: 18,
      fontWeight: FontWeight.bold,
    );
    return Column(
      children: [
        Container(
          height: 50,
          padding: const EdgeInsets.all(5),
          decoration: BoxDecoration(
            color: data.billStyle == '0'
                ? Colors.blue.shade900
                : Colors.green.shade700,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(10),
              topRight: Radius.circular(10),
            ),
          ),
          foregroundDecoration: data.children?[0].lastProcessNode == '1'
              ? const RotatedCornerDecoration.withColor(
                  color: Colors.red,
                  badgeCornerRadius: Radius.circular(8),
                  badgeSize: Size(45, 45),
                  textSpan: TextSpan(
                    text: '末道',
                    style: TextStyle(fontSize: 14),
                  ),
                )
              : null,
          child: Row(
            children: [
              Expanded(
                child: Text(
                  '物料：<${data.materialNumber}> ${data.materialName}',
                  style: itemTitleStyle,
                ),
                flex: 3,
              ),
              Expanded(
                child: Text(
                  '工厂型体：${data.productName}',
                  style: itemTitleStyle,
                ),
              ),
              // Expanded(
              //   child: Text(
              //     '厂区：${data.sapDecideArea}',
              //     style: itemTitleStyle,
              //   ),
              // ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.only(left: 5, top: 5, right: 5),
          color: Colors.white,
          child: Row(
            children: [
              expandedTextSpan(
                  hint: '部位：',
                  text: data.partName ?? '',
                  textColor: Colors.black54),
              expandedTextSpan(
                  hint: '工序名称：',
                  text: data.processName ?? '',
                  textColor: Colors.black54),
              expandedTextSpan(
                hint: '派工日期：',
                text: data.date ?? '',
                textColor: Colors.black54,
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.only(left: 5, top: 5, right: 5),
          color: Colors.white,
          child: Row(
            children: [
              expandedTextSpan(
                hint: '物料编码：',
                text: '${data.stuffNumber}',
                textColor: Colors.black54,
              ),
              expandedTextSpan(
                hint: '厂区：',
                text: '${data.sapDecideArea}',
                textColor: Colors.redAccent,
              ),
              expandedTextSpan(
                hint: '机台：',
                text: '${data.drillingCrewName}',
                textColor: Colors.redAccent,
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.only(left: 5, top: 5, right: 5),
          color: Colors.white,
          child: Row(
            children: [
              expandedFrameText(
                text: '指令号',
                backgroundColor: Colors.blue.shade50,
                flex: 3,
              ),
              expandedFrameText(
                text: '数量',
                backgroundColor: Colors.blue.shade50,
              ),
              expandedFrameText(
                text: '完成数量',
                backgroundColor: Colors.blue.shade50,
              ),
              expandedFrameText(
                  text: '工序派工单', backgroundColor: Colors.blue.shade50, flex: 2),
              expandedFrameText(
                text: '已印标数',
                backgroundColor: Colors.blue.shade50,
              ),
              expandedFrameText(
                text: '未印标数',
                backgroundColor: Colors.blue.shade50,
              ),
              expandedFrameText(
                text: '配色批次',
                backgroundColor: Colors.blue.shade50,
              ),
              // expandedFrameText(
              //   text: ' ',
              //   flex: 3,
              //   backgroundColor: Colors.blue.shade50,
              // )
              Container(
                  height: 32,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    color: Colors.blue.shade50,
                  ),
                  alignment: Alignment.centerLeft,
                  child: Visibility(
                    visible: false,
                    maintainAnimation: true,
                    maintainSize: true,
                    maintainState: true,
                    child: Row(
                      children: _subItemButton(data, isTitle: true),
                    ),
                  ))
            ],
          ),
        ),
        for (var i = 0; i < data.children!.length; ++i)
          Container(
            padding: const EdgeInsets.only(left: 5, right: 5),
            color: Colors.white,
            child: Row(
              children: [
                expandedFrameText(
                  text: data.children?[i].billNo ?? '',
                  flex: 3,
                ),
                expandedFrameText(
                  text: data.children![i].qty ?? '',
                ),
                expandedFrameText(
                  text: data.children![i].finishQty ?? '',
                ),
                expandedFrameText(
                  text: data.children?[i].workProcessNumber ?? '',
                  flex: 2,
                ),
                expandedFrameText(
                  text: data.children![i].codeQty ?? '',
                ),
                expandedFrameText(
                  text: data.children![i].noCodeQty ?? '',
                ),
                expandedFrameText(
                  text: data.children![i].sAPColorBatch ?? '',
                ),
                Container(
                  height: 32,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    color: Colors.transparent,
                  ),
                  alignment: Alignment.centerLeft,
                  child: Row(
                    children: _subItemButton(data),
                  ),
                )
              ],
            ),
          ),
        Container(
          padding: const EdgeInsets.all(5),
          height: 50,
          margin: const EdgeInsets.only(bottom: 10),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(10),
              bottomRight: Radius.circular(10),
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: Row(
                  children: [
                    Text(
                      '完成量(${data.unitName})：',
                      style: style,
                    ),
                    SizedBox(
                      width: 150,
                      child: percentIndicator(
                        max: data.qty.toDoubleTry(),
                        value: data.finishQty.toDoubleTry(),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(left: 10, right: 10),
                      child: Text(
                        '${data.finishQty} / ${data.qty}',
                        style: style,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Row(
                  children: [
                    Text(
                      '标签生成量(${data.unitName})：',
                      style: style,
                    ),
                    SizedBox(
                      width: 150,
                      child: percentIndicator(
                        max: data.qty.toDoubleTry(),
                        value: data.codeQty.toDoubleTry(),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(left: 10, right: 10),
                      child: Text(
                        '${data.codeQty} / ${data.qty}',
                        style: style,
                      ),
                    ),
                  ],
                ),
              ),
              CombinationButton(
                text: '用料清单',
                click: () {},
                combination: Combination.left,
              ),
              CombinationButton(
                text: '工艺说明书',
                click: () {},
                combination: Combination.middle,
              ),
              CombinationButton(
                text: '贴标列表',
                click: () {},
                combination: Combination.middle,
              ),
              CombinationButton(
                text: '报工',
                click: () {},
                combination: Combination.middle,
              ),
              CombinationButton(
                text: '取消报工',
                click: () {},
                combination: Combination.right,
              )
            ],
          ),
        ),
      ],
    );
  }

  _subItemButton(MaterialDispatchInfo data, {bool isTitle = false}) {
    btReport() {
      if (!isTitle) {
        print('btReport');
      }
    }

    btCancelReport() {
      if (!isTitle) {
        print('btCancelReport');
      }
    }

    btPrint() {
      if (!isTitle) {
        print('btPrint');
      }
    }

    btWarehouse() {
      if (!isTitle) {
        print('btWarehouse');
      }
    }

    var buttons = <Widget>[];
    if (data.printLabel == '1') {
      if (data.children![0].partialWarehousing == '1') {
        buttons.add(CombinationButton(
          text: '打印标签',
          click: btPrint,
          combination: Combination.left,
        ));
        buttons.add(CombinationButton(
          text: '入库',
          click: btWarehouse,
          combination: Combination.right,
        ));
      } else {
        buttons.add(CombinationButton(
          text: '打印标签',
          click: btPrint,
        ));
      }
    } else {
      if (data.children![0].partialWarehousing == '1') {
        buttons.add(CombinationButton(
          text: '报工',
          click: btReport,
          combination: Combination.left,
        ));
        buttons.add(CombinationButton(
          text: '取消报工',
          click: btCancelReport,
          combination: Combination.middle,
        ));
        buttons.add(CombinationButton(
          text: '入库',
          click: btWarehouse,
          combination: Combination.right,
        ));
      } else {
        buttons.add(CombinationButton(
          text: '报工',
          click: btReport,
          combination: Combination.left,
        ));
        buttons.add(CombinationButton(
          text: '取消报工',
          click: btCancelReport,
          combination: Combination.right,
        ));
      }
    }
    return buttons;
  }

  _item(MaterialDispatchInfo data) {
    var style = TextStyle(color: Colors.black87, fontWeight: FontWeight.bold);
    var shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(10)),
    );
    return Container(
      padding: EdgeInsets.only(bottom: 10),
      foregroundDecoration: data.children?[0].lastProcessNode == '1'
          ? const RotatedCornerDecoration.withColor(
              color: Colors.red,
              badgeCornerRadius: Radius.circular(8),
              badgeSize: Size(50, 50),
              textSpan: TextSpan(
                text: '末道',
                style: TextStyle(fontSize: 14),
              ),
            )
          : null,
      child: ExpansionTile(
        shape: shape,
        collapsedShape: shape,
        collapsedBackgroundColor: Colors.white,
        backgroundColor: Colors.yellow.shade200,
        leading: IconButton(
          onPressed: () => _itemSheet(data),
          icon: Icon(
            Icons.assignment_outlined,
            size: 40,
            color: Colors.blue.shade900,
          ),
        ),
        title: Row(
          children: [
            expandedTextSpan(
                hint: '物料：',
                text: '<${data.materialNumber}> ${data.materialName}'),
            textSpan(hint: '型体：', text: data.productName ?? ''),
          ],
        ),
        subtitle: Column(
          children: [
            Row(
              children: [
                expandedTextSpan(
                  hint: '厂区：',
                  text: data.sapDecideArea ?? '',
                  textColor: Colors.black54,
                ),
                expandedTextSpan(
                  hint: '机台：',
                  text: data.drillingCrewName ?? '',
                  textColor: Colors.redAccent,
                ),
                expandedTextSpan(
                  hint: '工单类型：',
                  text: data.billStyle == '0' ? '正单' : '补单',
                  textColor:
                      data.billStyle == '0' ? Colors.green : Colors.redAccent,
                ),
              ],
            ),
            Row(
              children: [
                expandedTextSpan(
                  hint: '派工日：',
                  text: data.date ?? '',
                  textColor: Colors.black54,
                ),
                expandedTextSpan(
                  hint: '部位：',
                  text: data.partName ?? '',
                  textColor: Colors.black54,
                ),
                expandedTextSpan(
                  hint: '工序名：',
                  text: data.processName ?? '',
                  textColor: Colors.black54,
                ),
              ],
            ),
            Row(
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Text(
                        '完成量(${data.unitName})：',
                        style: style,
                      ),
                      SizedBox(
                        width: 300,
                        child: progressIndicator(
                          max: data.qty.toDoubleTry(),
                          value: data.finishQty.toDoubleTry(),
                        ),
                      ),
                      Text(
                        '${data.qty}',
                        style: style,
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Row(
                    children: [
                      Text(
                        '标签生成量(${data.unitName})：',
                        style: style,
                      ),
                      SizedBox(
                        width: 300,
                        child: progressIndicator(
                          max: data.qty.toDoubleTry(),
                          value: data.codeQty.toDoubleTry(),
                        ),
                      ),
                      Text(
                        '${data.qty}',
                        style: style,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
        children: _subItem(data),
      ),
    );
  }

  _subItem(MaterialDispatchInfo data) {
    var style = TextStyle(color: Colors.black87, fontWeight: FontWeight.bold);
    return [
      for (var i = 0; i < data.children!.length; ++i)
        Padding(
          padding: EdgeInsets.only(left: 10, right: 10),
          child: Card(
            color: Colors.blue.shade50,
            child: ListTile(
              trailing: IconButton(
                onPressed: () => _subItemSheet(data.children![i]),
                icon: Icon(
                  Icons.settings_suggest_sharp,
                  size: 30,
                ),
              ),
              title: textSpan(
                hint: '指令：',
                text: data.children?[i].billNo ?? '',
                textColor: Colors.red.shade400,
              ),
              subtitle: Column(
                children: [
                  Row(
                    children: [
                      expandedTextSpan(
                        hint: '工序派工单号：',
                        text: data.children?[i].workProcessNumber ?? '',
                        textColor: Colors.black54,
                      ),
                      expandedTextSpan(
                        hint: '配色批次：',
                        text: data.children?[i].sAPColorBatch ?? '',
                        textColor: Colors.black54,
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            Text(
                              '完成量：',
                              style: style,
                            ),
                            SizedBox(
                              width: 200,
                              child: progressIndicator(
                                max: data.children![i].qty.toDoubleTry(),
                                value:
                                    data.children![i].finishQty.toDoubleTry(),
                              ),
                            ),
                            Text(
                              '${data.children![i].qty}',
                              style: style,
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Row(
                          children: [
                            Text(
                              '标签生成量：',
                              style: style,
                            ),
                            SizedBox(
                              width: 200,
                              child: progressIndicator(
                                max: data.children![i].qty.toDoubleTry(),
                                value: data.children![i].codeQty.toDoubleTry(),
                              ),
                            ),
                            Text(
                              '${data.children![i].qty}',
                              style: style,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      SizedBox(height: 10),
    ];
  }

  _itemSheet(MaterialDispatchInfo data) {
    showSheet(
      context,
      Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              expandedTextSpan(
                  hint: '物料：',
                  text: '<${data.materialNumber}> ${data.materialName}'),
              textSpan(hint: '型体：', text: data.productName ?? ''),
            ],
          ),
          Row(
            children: [
              Expanded(
                child: CombinationButton(
                  text: '用料清单',
                  click: () {},
                  combination: Combination.left,
                ),
              ),
              Expanded(
                child: CombinationButton(
                  text: '工艺说明书',
                  click: () {},
                  combination: Combination.middle,
                ),
              ),
              Expanded(
                child: CombinationButton(
                  text: '贴标列表',
                  click: () {},
                  combination: Combination.middle,
                ),
              ),
              Expanded(
                child: CombinationButton(
                  text: '报工',
                  click: () {},
                  combination: Combination.middle,
                ),
              ),
              Expanded(
                child: CombinationButton(
                  text: '取消报工',
                  click: () {},
                  combination: Combination.right,
                ),
              ),
            ],
          )
        ],
      ),
      scrollControlled: true,
    );
  }

  _subItemSheet(Children data) {
    showSheet(
      context,
      Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          textSpan(
            hint: '指令：',
            text: data.billNo ?? '',
            textColor: Colors.red.shade400,
          ),
          Row(
            children: [
              Expanded(
                child: CombinationButton(
                  text: '报工',
                  click: () {},
                  combination: Combination.left,
                ),
              ),
              Expanded(
                child: CombinationButton(
                  text: '取消报工',
                  click: () {},
                  combination: Combination.middle,
                ),
              ),
              Expanded(
                child: CombinationButton(
                  text: '打印标签',
                  click: () {},
                  combination: Combination.middle,
                ),
              ),
              Expanded(
                child: CombinationButton(
                  text: '入库',
                  click: () {},
                  combination: Combination.right,
                ),
              ),
            ],
          ),
        ],
      ),
      scrollControlled: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    return pageBodyWithDrawer(
      actions: [
        SizedBox(
          width: 400,
          child: EditText(
            hint: '输入物料编号进行筛选',
            onChanged: (s) => logic.search(s),
          ),
        ),
        CombinationButton(
          text: '库位托盘选择',
          click: () {},
          combination: Combination.left,
        ),
        CombinationButton(
          text: '批量入库',
          click: () {},
          combination: Combination.middle,
        ),
        CombinationButton(
          text: '贴合区域图',
          click: () {},
          combination: Combination.middle,
        ),
        CombinationButton(
          text: '报工到SAP',
          click: () {},
          combination: Combination.right,
        ),
        SizedBox(width: 10),
      ],
      queryWidgets: [
        EditText(
          hint: '请输入型体名称',
          onChanged: (s) => state.typeBody = s,
        ),
        DatePicker(pickerController: logic.dpcStartDate),
        DatePicker(pickerController: logic.dpcEndDate),
        Spinner(controller: logic.scReportState),
        Obx(() => CheckBox(
              onChanged: (c) => state.lastProcess.value = c,
              name: '显示末道工序',
              value: state.lastProcess.value,
            )),
        Obx(() => CheckBox(
              onChanged: (c) => state.unStockIn.value = c,
              name: '显示未入库',
              value: state.unStockIn.value,
            )),
      ],
      query: () => logic.query(),
      body: Obx(() => ListView.builder(
            padding: const EdgeInsets.all(8),
            itemCount: state.showOrderList.length,
            itemBuilder: (context, index) => _item1(state.showOrderList[index]),
          )),
    );
  }

  @override
  void dispose() {
    Get.delete<MaterialDispatchLogic>();
    super.dispose();
  }
}
