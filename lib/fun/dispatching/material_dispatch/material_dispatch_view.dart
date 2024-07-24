import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jd_flutter/utils.dart';
import 'package:jd_flutter/widget/custom_widget.dart';
import 'package:jd_flutter/widget/dialogs.dart';
import 'package:rotated_corner_decoration/rotated_corner_decoration.dart';

import '../../../bean/http/response/material_dispatch_info.dart';
import '../../../route.dart';
import '../../../widget/picker/picker_view.dart';
import 'material_dispatch_dialogs.dart';
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
                flex: 3,
                child: AutoSizeText(
                  '物料：<${data.materialNumber}> ${data.materialName}',
                  style: itemTitleStyle,
                  maxLines: 2,
                  minFontSize: 8,
                  maxFontSize: 18,
                ),
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
                    child: Row(children: _subItemButton(data: data)),
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
                  click: () => showBillNoList(data.children?[i].billNo ?? ''),
                  text: data.children?[i].billNo ?? '',
                  textColor: Colors.blue.shade900,
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
                  text: data.children![i].sapColorBatch ?? '',
                ),
                Container(
                  height: 32,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    color: Colors.transparent,
                  ),
                  alignment: Alignment.centerLeft,
                  child: Row(
                    children:
                        _subItemButton(data: data, subData: data.children![i]),
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
                click: () => materialListDialog(context, data),
                combination: Combination.left,
              ),
              CombinationButton(
                text: '工艺说明书',
                click: () => logic.queryProcessSpecification(
                  data.productName ?? '',
                  (list) => processSpecificationDialog(list),
                ),
                combination: Combination.middle,
              ),
              CombinationButton(
                text: '贴标列表',
                click: () => labelListDialog(context, data),
                combination: Combination.middle,
              ),
              CombinationButton(
                text: '报工',
                click: () => askDialog(
                  content: '确定要整组报工吗?',
                  confirm: () => logic.itemReport(data),
                ),
                combination: Combination.middle,
              ),
              CombinationButton(
                text: '取消报工',
                click: () => askDialog(
                  content: '确定要整组取消报工吗',
                  confirm: () => logic.itemCancelReport(data),
                ),
                combination: Combination.right,
              )
            ],
          ),
        ),
      ],
    );
  }

  _subItemButton({
    required MaterialDispatchInfo data,
    Children? subData,
  }) {
    btReport() {
      if (subData != null) {
        subItemReportDialog(
          context,
          data,
          subData,
          (d) {
            subData.qty = d.toShowString();
            logic.subItemReport(data, subData, false);
          },
        );
      }
    }
    btCancelReport() {
      if (subData != null) {
        print('btCancelReport');
      }
    }

    btPrint() {
      if (subData != null) {
        subItemReportDialog(
          context,
          data,
          subData,
          (d) {
            subData.qty = d.toShowString();
            logic.subItemReport(data, subData, true);
          },
        );
      }
    }

    btWarehouse() {
      if (subData != null) {
        askDialog(
          content: '确定要提交入库吗？',
          confirm: () => logic.subItemWarehousing(
            subData,
            data.sapDecideArea ?? '',
          ),
        );
      }
    }

    var buttons = <Widget>[
      CombinationButton(
        text: '报工',
        click: btReport,
        combination: Combination.left,
      ),
      CombinationButton(
        text: '取消报工',
        click: btCancelReport,
        combination: Combination.middle,
      ),
      CombinationButton(
        text: '入库',
        click: btWarehouse,
        combination: Combination.right,
      )
    ];

    // if (data.printLabel == '1') {
    //   if (data.children![0].partialWarehousing == '1') {
    //     buttons.add(CombinationButton(
    //       text: '打印标签',
    //       click: btPrint,
    //       combination: Combination.left,
    //     ));
    //     buttons.add(CombinationButton(
    //       text: '入库',
    //       click: btWarehouse,
    //       combination: Combination.right,
    //     ));
    //   } else {
    //     buttons.add(CombinationButton(
    //       text: '打印标签',
    //       click: btPrint,
    //     ));
    //   }
    // } else {
    //   if (data.children![0].partialWarehousing == '1') {
    //     buttons.add(CombinationButton(
    //       text: '报工',
    //       click: btReport,
    //       combination: Combination.left,
    //     ));
    //     buttons.add(CombinationButton(
    //       text: '取消报工',
    //       click: btCancelReport,
    //       combination: Combination.middle,
    //     ));
    //     buttons.add(CombinationButton(
    //       text: '入库',
    //       click: btWarehouse,
    //       combination: Combination.right,
    //     ));
    //   } else {
    //     buttons.add(CombinationButton(
    //       text: '报工',
    //       click: btReport,
    //       combination: Combination.left,
    //     ));
    //     buttons.add(CombinationButton(
    //       text: '取消报工',
    //       click: btCancelReport,
    //       combination: Combination.right,
    //     ));
    //   }
    // }
    return buttons;
  }

  @override
  Widget build(BuildContext context) {
    if (state.isNeedSetInitData()) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        pickPallet(
            isFirst: true,
            savePalletDate: state.date,
            saveMachine: state.machineId,
            saveWarehouseLocation: state.locationId,
            savePallet: state.palletNumber,
            context: context,
            callback: (
              int date,
              String machineId,
              String locationId,
              String palletNumber,
            ) =>
                setState(() => state.savePickData(
                      date: date,
                      machineId: machineId,
                      locationId: locationId,
                      palletNumber: palletNumber,
                    )));
      });
      return Container(
        decoration: backgroundColor,
        child: Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            title: Text(getFunctionTitle()),
          ),
        ),
      );
    } else {
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
            click: () => pickPallet(
              savePalletDate: state.date,
              saveMachine: state.machineId,
              saveWarehouseLocation: state.locationId,
              savePallet: state.palletNumber,
              context: context,
              callback: (
                int date,
                String machineId,
                String locationId,
                String palletNumber,
              ) =>
                  state.savePickData(
                date: date,
                machineId: machineId,
                locationId: locationId,
                palletNumber: palletNumber,
              ),
            ),
            combination: Combination.left,
          ),
          CombinationButton(
            text: '批量入库',
            click: () => askDialog(
              content: '确定要批量提交入库吗？',
              confirm: () => logic.batchWarehousing(),
            ),
            combination: Combination.middle,
          ),
          CombinationButton(
            text: '贴合区域图',
            click: () => showAreaPhoto(context),
            combination: Combination.middle,
          ),
          CombinationButton(
            text: '报工到SAP',
            click: () => askDialog(
              content: '确定要报工到SAP吗？',
              confirm: () => logic.reportToSAP(),
            ),
            combination: Combination.right,
          ),
          const SizedBox(width: 10),
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
              itemBuilder: (context, index) =>
                  _item1(state.showOrderList[index]),
            )),
      );
    }
  }

  @override
  void dispose() {
    Get.delete<MaterialDispatchLogic>();
    super.dispose();
  }
}
