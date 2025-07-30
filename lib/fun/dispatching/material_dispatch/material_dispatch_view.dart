import 'package:auto_size_text/auto_size_text.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jd_flutter/bean/home_button.dart';
import 'package:jd_flutter/bean/http/response/material_dispatch_info.dart';
import 'package:jd_flutter/bean/http/response/material_dispatch_label_detail.dart';
import 'package:jd_flutter/route.dart';
import 'package:jd_flutter/utils/printer/print_util.dart';
import 'package:jd_flutter/utils/utils.dart';
import 'package:jd_flutter/utils/web_api.dart';
import 'package:jd_flutter/widget/check_box_widget.dart';
import 'package:jd_flutter/widget/combination_button_widget.dart';
import 'package:jd_flutter/widget/custom_widget.dart';
import 'package:jd_flutter/widget/dialogs.dart';
import 'package:jd_flutter/widget/edit_text_widget.dart';
import 'package:jd_flutter/widget/feishu_authorize.dart';
import 'package:jd_flutter/widget/picker/picker_view.dart';
import 'package:jd_flutter/widget/preview_label_widget.dart';
import 'package:jd_flutter/widget/spinner_widget.dart';
import 'package:rotated_corner_decoration/rotated_corner_decoration.dart';
import '../../../widget/tsc_label_template.dart';
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

  final PrintUtil pu = PrintUtil();

  printLabel({
    required MaterialDispatchInfo data,
    required String billNo,
    required String color,
    required String guid,
    required String pick,
    required List<MaterialDispatchLabelDetail> bill,
    required String qty,
  }) async {
    if (state.allInstruction.value) {
      var list = <String>[];

      billNo.split(',').forEach((data) {
        if (data.isNotEmpty) {
          list.add(data);
        }
      });
      var chunked = [
        for (int i = 0; i < list.length; i += 4)
          list.sublist(i, (i + 4).clamp(0, list.length))
      ];
      var subList = <String>[];
      for (var data in chunked) {
        var splitData = '';
        for (var subData in data) {
          splitData = '$splitData$subData,';
        }
        subList.add(splitData.substring(0, splitData.length - 1));
      }
      var labelTable = Padding(
        padding: const EdgeInsets.only(
          left: 5,
          right: 5,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            for (var i = 0; i < subList.length; ++i) ...[Text(subList[i],style: const TextStyle(fontSize: 14),)]
          ],
        ),
      );
      Get.to(() => PreviewLabel(
              labelWidget: dynamicLabelTemplate75xN(
            qrCode: guid,
            title: Text(data.productName ?? '',style: const TextStyle(fontSize: 20)),
            subTitle: Text(data.materialName ?? '',style: const TextStyle(fontSize: 16)),
            header: Text(
                '部件：${data.materialName}(${data.materialNumber})<${data.processName}>'),
            table: labelTable,
            footer: Column(
              children: [
                Row(
                  children: [
                    Expanded(child: Text(data.sapDecideArea ?? '',style: const TextStyle(fontSize: 16))),
                    Expanded(child: Text('色系：$color',style: const TextStyle(fontSize: 16)))
                  ],
                ),
                Row(
                  children: [
                    Expanded(child: Text(data.drillingCrewName ?? '',style: const TextStyle(fontSize: 16))),
                    Expanded(child: Text('数量：$qty${data.unitName}',style: const TextStyle(fontSize: 16)))
                  ],
                )
              ],
            ),
          )));
    } else {
      var ins = '';
      var toPrint = '';
      for (var data in bill) {
        if (data.billNo!.isNotEmpty) {
          ins = '$ins${data.billNo!},';
        }
      }
      ins.split(',').forEachIndexed((i, s) {
        if (i <= 1 && s.isNotEmpty) {
          toPrint = '$toPrint$s,';
          logger.f('toPrint:$toPrint');
        }
      });
      if (toPrint.endsWith(',')) {
        toPrint.substring(0, toPrint.length - 1);
      }

      Get.to(() => PreviewLabel(
            labelWidget: fixedLabelTemplate75x45(
              qrCode: guid,
              title: Text(data.productName ?? '',style: const TextStyle(fontSize: 20)),
              subTitle: Text('${data.partName}$toPrint<${data.processName}>',style: const TextStyle(fontSize: 16)),
              content: Text('${data.materialName}(${data.materialNumber})'),
              bottomLeft:
                  Column(mainAxisAlignment: MainAxisAlignment.start, children: [
                Text('仓位：${state.palletNumber}',
                    style: const TextStyle(fontSize: 12)),
                Text(data.drillingCrewName ?? '',
                    style: const TextStyle(fontSize: 12))
              ]),
              bottomMiddle: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text('$color/$qty${data.unitName}',
                      style: const TextStyle(fontSize: 12)),
                  Text('取件码：$pick', style: const TextStyle(fontSize: 12))
                ],
              ),
              bottomRight: Center(
                  child: Text(data.sapDecideArea ?? '',
                      style: const TextStyle(fontSize: 12))),
            ),
          ));
    }
  }

  _item1(MaterialDispatchInfo data, int index) {
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
              ? RotatedCornerDecoration.withColor(
                  color: Colors.red,
                  badgeCornerRadius: const Radius.circular(8),
                  badgeSize: const Size(45, 45),
                  textSpan: TextSpan(
                    text: 'material_dispatch_last'.tr,
                    style: const TextStyle(fontSize: 14),
                  ),
                )
              : null,
          child: Row(
            children: [
              Expanded(
                flex: 3,
                child: AutoSizeText(
                  'material_dispatch_material'.trArgs([
                    data.materialNumber ?? '',
                    data.materialName ?? '',
                  ]),
                  style: itemTitleStyle,
                  maxLines: 2,
                  minFontSize: 8,
                  maxFontSize: 18,
                ),
              ),
              Expanded(
                child: Text(
                  'material_dispatch_type_body'
                      .trArgs([data.productName ?? '']),
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
                hint: 'material_dispatch_position'.tr,
                text: data.partName ?? '',
                textColor: Colors.black54,
              ),
              expandedTextSpan(
                hint: 'material_dispatch_progress_name'.tr,
                text: data.processName ?? '',
                textColor: Colors.black54,
              ),
              expandedTextSpan(
                hint: 'material_dispatch_dispatch_date'.tr,
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
                hint: 'material_dispatch_material_code'.tr,
                text: '${data.stuffNumber}',
                textColor: Colors.black54,
              ),
              expandedTextSpan(
                hint: 'material_dispatch_factory'.tr,
                text: '${data.sapDecideArea}',
                textColor: Colors.redAccent,
              ),
              expandedTextSpan(
                hint: 'material_dispatch_machine'.tr,
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
                text: 'material_dispatch_ins_number'.tr,
                backgroundColor: Colors.blue.shade50,
                flex: 3,
              ),
              expandedFrameText(
                text: 'material_dispatch_quantity'.tr,
                backgroundColor: Colors.blue.shade50,
              ),
              expandedFrameText(
                text: 'material_dispatch_completed_qty'.tr,
                backgroundColor: Colors.blue.shade50,
              ),
              expandedFrameText(
                text: 'material_dispatch_progress_dispatch_order'.tr,
                backgroundColor: Colors.blue.shade50,
                flex: 2,
              ),
              expandedFrameText(
                text: 'material_dispatch_printed_qty'.tr,
                backgroundColor: Colors.blue.shade50,
              ),
              expandedFrameText(
                text: 'material_dispatch_not_printed_qty'.tr,
                backgroundColor: Colors.blue.shade50,
              ),
              expandedFrameText(
                text: 'material_dispatch_color_batch'.tr,
                backgroundColor: Colors.blue.shade50,
              ),
              Container(
                  height: 35,
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
                        children: _subItemButton(
                            data: data, titlePosition: index, position: -1)),
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
                  height: 35,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    color: Colors.transparent,
                  ),
                  alignment: Alignment.centerLeft,
                  child: Row(
                    children: _subItemButton(
                        data: data,
                        subData: data.children![i],
                        position: i,
                        titlePosition: index),
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
                      'material_dispatch_completion_amount'
                          .trArgs([data.unitName ?? '']),
                      style: style,
                    ),
                    SizedBox(
                      width: 100,
                      child: percentIndicator(
                        max: data.qty.toDoubleTry(),
                        value: data.finishQty.toDoubleTry(),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 10, right: 10),
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
                      'material_dispatch_label_generation_amount'
                          .trArgs([data.unitName ?? '']),
                      style: style,
                    ),
                    SizedBox(
                      width: 100,
                      child: percentIndicator(
                        max: data.qty.toDoubleTry(),
                        value: data.codeQty.toDoubleTry(),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 10, right: 10),
                      child: Text(
                        '${data.codeQty} / ${data.qty}',
                        style: style,
                      ),
                    ),
                  ],
                ),
              ),
              CombinationButton(
                text: 'material_dispatch_material_list'.tr,
                click: () => materialListDialog(context, data),
                combination: Combination.left,
              ),
              CombinationButton(
                text: 'material_dispatch_progress_manual'.tr,
                click: () => feishuViewWikiFiles(
                  query: data.productName ?? '',
                ),
                combination: Combination.middle,
              ),
              CombinationButton(
                text: 'material_dispatch_label_list'.tr,
                click: () =>
                    labelListDialog(state.date,context, data, callback: (info, label) {
                      var data = info.children!.firstWhere((data) => data.sapColorBatch == label.sapColorBatch && label.sapColorBatch!.isNotEmpty);
                      if(state.allInstruction.value){
                        printLabel(
                            data: info,
                            billNo: data.billNo!,
                            color: data.sapColorBatch!,
                            guid: label.guid!,
                            pick: label.pickUpCode!,
                            bill: <MaterialDispatchLabelDetail>[],
                            qty: label.qty.toShowString());
                      }else{
                        state.getLabelDetail(
                          guid: label.guid!,
                          success: (List<MaterialDispatchLabelDetail> bill) {
                            printLabel(
                                data: info,
                                billNo: data.billNo!,
                                color: data.sapColorBatch!,
                                guid: label.guid!,
                                pick: label.pickUpCode!,
                                bill: bill,
                                qty: label.qty.toShowString());
                          },
                        );
                      }
                }, refreshCallBack: () {
                  logic.refreshDataList();
                }),
                combination: Combination.middle,
              ),
              CombinationButton(
                text: 'material_dispatch_report'.tr,
                click: () => askDialog(
                  content: 'material_dispatch_report_tips'.tr,
                  confirm: () => logic.itemReport(data),
                ),
                combination: Combination.middle,
              ),
              CombinationButton(
                text: 'material_dispatch_cancel_report'.tr,
                click: () => askDialog(
                  content: 'material_dispatch_cancel_all_report_tips'.tr,
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
    required int titlePosition,
    required int position,
  }) {
    btReport() {
      if (subData != null) {
        subItemReportDialog(
          context,
          data,
          subData,
          (d) {
            logic.subItemReport(
              qty: d.toShowString(),
              titlePosition: titlePosition,
              clickPosition: position,
              isPrint: false,
              success: (String guid, String pick,
                  List<MaterialDispatchLabelDetail> bill) {
                //不需要走打印
              },
              submitData: data,
              subData: subData,
            );
          },
        );
      }
    }

    btCancelReport() {
      if (subData != null) {
        askDialog(
          content: 'material_dispatch_cancel_report_tips'.tr,
          confirm: () => logic.subItemCancelReport(subData),
        );
      }
    }

    btPrint() {
      if (subData != null) {
        subItemReportDialog(
          context,
          data,
          subData,
          (d) {
            logic.subItemReport(
                qty: d.toShowString(),
                titlePosition: titlePosition,
                clickPosition: position,
                submitData: data,
                subData: subData,
                isPrint: true,
                success: (String guid, String pick,
                    List<MaterialDispatchLabelDetail> bills) {
                  printLabel(
                      data: data,
                      billNo: subData.billNo!,
                      color: subData.sapColorBatch!,
                      guid: guid,
                      pick: pick,
                      bill: bills,
                      qty: d.toShowString());
                });
          },
        );
      }
    }

    btWarehouse() {
      if (subData != null) {
        askDialog(
          content: 'material_dispatch_stock_in_tips'.tr,
          confirm: () => logic.subItemWarehousing(
            subData,
            data.sapDecideArea ?? '',
          ),
        );
      }
    }

    var buttons = <Widget>[];

    if (data.printLabel == '1') {
      if (data.children![0].partialWarehousing == '1') {
        buttons.add(CombinationButton(
          text: 'material_dispatch_print_label'.tr,
          click: btPrint,
          combination: Combination.left,
        ));
        buttons.add(CombinationButton(
          text: 'material_dispatch_stock_in'.tr,
          click: btWarehouse,
          combination: Combination.right,
        ));
      } else {
        buttons.add(CombinationButton(
          text: 'material_dispatch_print_label'.tr,
          click: btPrint,
        ));
      }
    } else {
      if (data.children![0].partialWarehousing == '1') {
        buttons.add(CombinationButton(
          text: 'material_dispatch_report'.tr,
          click: btReport,
          combination: Combination.left,
        ));
        buttons.add(CombinationButton(
          text: 'material_dispatch_cancel_report'.tr,
          click: btCancelReport,
          combination: Combination.middle,
        ));
        buttons.add(CombinationButton(
          text: 'material_dispatch_stock_in'.tr,
          click: btWarehouse,
          combination: Combination.right,
        ));
      } else {
        buttons.add(CombinationButton(
          text: 'material_dispatch_report'.tr,
          click: btReport,
          combination: Combination.left,
        ));
        buttons.add(CombinationButton(
          text: 'material_dispatch_cancel_report'.tr,
          click: btCancelReport,
          combination: Combination.right,
        ));
      }
    }
    return buttons;
  }

  @override
  void initState() {
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
            date,
            machineId,
            locationId,
            palletNumber,
          ) =>
              setState(() => state.savePickData(
                    date: date,
                    machineId: machineId,
                    locationId: locationId,
                    palletNumber: palletNumber,
                  )),
        );
      });
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (state.isNeedSetInitData()) {
      return Container(
        decoration: backgroundColor(),
        child: Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            title: Text(functionTitle),
          ),
        ),
      );
    } else {
      return pageBodyWithDrawer(
        actions: [
          SizedBox(
            width: 400,
            child: EditText(
              hint: 'material_dispatch_select_tips'.tr,
              onChanged: (s) => logic.search(s),
            ),
          ),
          CombinationButton(
            text: 'material_dispatch_storage_pallet_select'.tr,
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
            text: 'material_dispatch_batch_stock_in'.tr,
            click: () => askDialog(
              content: 'material_dispatch_batch_stock_in_tips'.tr,
              confirm: () => logic.batchWarehousing(),
            ),
            combination: Combination.middle,
          ),
          CombinationButton(
            text: 'material_dispatch_map'.tr,
            click: () => showAreaPhoto(context),
            combination: Combination.middle,
          ),
          CombinationButton(
            text: 'material_dispatch_report_to_sap'.tr,
            click: () => askDialog(
              content: 'material_dispatch_report_to_sap_tips'.tr,
              confirm: () => logic.reportToSAP(),
            ),
            combination: Combination.right,
          ),
          const SizedBox(width: 10),
        ],
        queryWidgets: [
          EditText(
            hint: 'material_dispatch_enter_type_body_tips'.tr,
            onChanged: (s) => state.typeBody = s,
          ),
          DatePicker(pickerController: logic.dpcStartDate),
          DatePicker(pickerController: logic.dpcEndDate),
          Spinner(controller: logic.scReportState),
          Obx(() => CheckBox(
                onChanged: (c) => state.lastProcess.value = c,
                name: 'material_dispatch_show_last'.tr,
                value: state.lastProcess.value,
              )),
          Obx(() => CheckBox(
                onChanged: (c) => state.unStockIn.value = c,
                name: 'material_dispatch_show_not_stock_in'.tr,
                value: state.unStockIn.value,
              )),
          Obx(() => CheckBox(
                onChanged: (c) => state.allInstruction.value = c,
                name: 'material_dispatch_btn_print_all'.tr,
                value: state.allInstruction.value,
              )),
        ],
        query: () => logic.refreshDataList(),
        body: Obx(() => ListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: state.showOrderList.length,
              itemBuilder: (context, index) =>
                  _item1(state.showOrderList[index], index),
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
