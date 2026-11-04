import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jd_flutter/bean/http/response/part_detail_info.dart';
import 'package:jd_flutter/fun/dispatching/work_order_list/work_order_list_logic.dart';
import 'package:jd_flutter/fun/work_reporting/part_process_scan/part_process_scan_view.dart';

import 'package:jd_flutter/utils/extension_util.dart';
import 'package:jd_flutter/utils/utils.dart';
import 'package:jd_flutter/widget/check_box_widget.dart';
import 'package:jd_flutter/widget/combination_button_widget.dart';
import 'package:jd_flutter/widget/custom_widget.dart';
import 'package:jd_flutter/widget/dialogs.dart';
import 'package:jd_flutter/widget/edit_text_widget.dart';
import 'package:jd_flutter/widget/worker_check_widget.dart';

class PartLabelPage extends StatefulWidget {
  const PartLabelPage({super.key});

  @override
  State<PartLabelPage> createState() => _PartLabelPageState();
}

class _PartLabelPageState extends State<PartLabelPage> {
  final logic = Get.find<WorkOrderListLogic>();
  final state = Get.find<WorkOrderListLogic>().state;

  void _salesOrderListDialog(List<String> labels) {
    Get.dialog(
      PopScope(
        canPop: false,
        child: AlertDialog(
          title: Text('part_label_sales_order_list'.tr),
          content: SizedBox(
            width: 200,
            height: 300,
            child: ListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: labels.length,
              itemBuilder: (context, index) => Card(
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Text(labels[index]),
                ),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Get.back(),
              child: Text(
                'part_label_back'.tr,
                style: const TextStyle(color: Colors.grey),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _createLabelDialog(SizeInfo data) {
    var max = data.qty.sub(data.createQty ?? 0);
    var boxCapacity = max;
    var createQty = max;
    var empID = '';
    var number = spGet('CreateLabelWorkerNumber')??'';
    Get.dialog(
      PopScope(
        canPop: false,
        child: AlertDialog(
          title: Text('part_label_create_label'.tr),
          content: SizedBox(
            width: 300,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _paddingText('part_label_box_capacity'.tr),
                NumberDecimalEditText(
                  max: max,
                  initQty: max,
                  onChanged: (d) => boxCapacity = d,
                ),
                _paddingText('part_label_create_total'.tr),
                NumberDecimalEditText(
                  max: max,
                  initQty: max,
                  onChanged: (d) => createQty = d,
                ),
                const SizedBox(height: 20),
                WorkerCheck(
                  hint: 'part_label_dispatch_worker_number'.tr,
                  init: number,
                  onChanged: (wi) {
                    if (wi != null) {
                      empID = wi.empID.toString();
                      number = wi.empCode.toString();
                    } else {
                      empID = '';
                      number = '';
                    }
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => logic.createPartLabel(
                boxCapacity,
                createQty,
                data.size ?? '',
                empID,
                number,
              ),
              child: Text(
                'part_label_create'.tr,
              ),
            ),
            TextButton(
              onPressed: () => Get.back(),
              child: Text(
                'part_label_back'.tr,
                style: const TextStyle(color: Colors.grey),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Padding _paddingText(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 10),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 12,
          color: Colors.grey,
        ),
      ),
    );
  }

  GestureDetector _item(SizeInfo data) {
    return GestureDetector(
      onTap: () {
        if (checkUserPermission('1052501')) {
          _createLabelDialog(data);
        } else {
          showSnackBar(
            message: 'part_label_no_label_operation_permission'.tr,
            isWarning: true,
          );
        }
      },
      child: Card(
        child: ListTile(
          title: textSpan(
            hint: 'part_label_sales_order_no'.tr,
            text: data.getSalesOrderNumber(),
            textColor: Colors.green.shade900,
          ),
          leading: IconButton(
            icon: const Icon(Icons.menu, color: Colors.blueAccent),
            onPressed: () {
              _salesOrderListDialog([
                for (var i = 0; i < (data.mtonoList ?? []).length; ++i)
                  data.mtonoList?[i].mtono ?? ''
              ]);
            },
          ),
          subtitle: Row(
            children: [
              expandedTextSpan(
                hint: 'part_label_size'.tr,
                text: data.size ?? '',
                textColor: Colors.blue.shade900,
              ),
              expandedTextSpan(
                hint: 'part_label_dispatched'.tr,
                text: data.createQty.toShowString(),
                textColor: Colors.blue.shade900,
              ),
              expandedTextSpan(
                hint: 'part_label_qty'.tr,
                text: data.qty.toShowString(),
                textColor: Colors.blue.shade900,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Card _itemTotal(SizeInfo data) {
    return Card(
      color: Colors.blueAccent,
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Row(
          children: [
            expandedTextSpan(
              hint: 'part_label_total'.tr,
              hintColor: Colors.white,
              text: '',
            ),
            expandedTextSpan(
              hint: 'part_label_dispatched'.tr,
              hintColor: Colors.white,
              text: data.createQty.toShowString(),
              textColor: Colors.white,
            ),
            textSpan(
              hint: 'part_label_qty'.tr,
              hintColor: Colors.white,
              text: data.qty.toShowString(),
              textColor: Colors.white,
            ),
          ],
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      logic.queryPartDetail(success: () => setState(() {}));
    });
  }

  @override
  Widget build(BuildContext context) {
    return pageBody(
      title: 'part_label_part_process_label'.tr,
      actions: [
        Obx(() => state.partDetail.value?.barCodeList?.isNotEmpty == true
            ? CombinationButton(
                text: 'part_label_print_label'.tr,
                click: () {
                  if (checkUserPermission('1052501')) {
                    Get.to(() => const LabelListPage());
                  } else {
                    showSnackBar(
                      message: 'part_label_no_label_operation_permission'.tr,
                      isWarning: true,
                    );
                  }
                },
              )
            : Container()),
        CombinationButton(
          text: 'part_label_process_scan'.tr,
          click: () {
            Get.to(() => const PartProcessScanPage());
          },
        ),
        const SizedBox(width: 20),
      ],
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 10),
            child: textSpan(
              hint: 'part_label_type_body'.tr,
              text: state.partDetail.value?.factoryType ?? '',
              textColor: Colors.blueAccent,
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 10),
            child: textSpan(
              hint: 'part_label_part'.tr,
              text: state.partDetail.value?.partName ?? '',
              textColor: Colors.blueAccent,
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 10),
            child: textSpan(
              hint: 'part_label_process'.tr,
              text: state.partDetail.value?.processName ?? '',
              textColor: Colors.blueAccent,
            ),
          ),
          Expanded(
            child: Obx(
              () => ListView.builder(
                padding: const EdgeInsets.all(8),
                itemCount: state.partDetailSizeList.isNotEmpty
                    ? state.partDetailSizeList.length + 1
                    : 0,
                itemBuilder: (context, index) {
                  if (index == state.partDetailSizeList.length) {
                    return _itemTotal(
                        state.partDetail.value!.getSizeListTotal());
                  } else {
                    return _item(state.partDetailSizeList[index]);
                  }
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class LabelListPage extends StatefulWidget {
  const LabelListPage({super.key});

  @override
  State<LabelListPage> createState() => _LabelListPageState();
}

class _LabelListPageState extends State<LabelListPage> {
  final logic = Get.find<WorkOrderListLogic>();
  final state = Get.find<WorkOrderListLogic>().state;
  var data = <BarCodeInfo>[].obs;

  @override
  void initState() {
    for (var v in state.partDetail.value?.barCodeList ?? []) {
      data.add(v);
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return pageBody(
      title: 'part_label_label_list_delete_tips'.tr,
      actions: [
        Obx(() => CheckBox(
              onChanged: (v) {
                for (var s in data) {
                  s.isSelect.value = v;
                }
              },
              name: 'part_label_all'.tr,
              value: data.every((v) => v.isSelect.value),
            ))
      ],
      body: Column(
        children: [
          Obx(
            () => Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(8),
                itemCount: data.length,
                itemBuilder: (context, index) => _item(index),
              ),
            ),
          ),
          SizedBox(
            width: double.infinity,
            child: CombinationButton(
              text: 'part_label_print'.tr,
              click: () => logic.printLabel(
                list: data.where((v) => v.isSelect.value).toList(),
                partName: state.partDetail.value?.partName ?? '',
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _item(int index) => GestureDetector(
        onLongPress: () {
          if (checkUserPermission('1052504')) {
            askDialog(
              content:
                  'part_label_delete_tips'.trArgs([data[index].barCode ?? '']),
              confirm: () {
                logic.deleteLabel(
                  data[index].barCode ?? '',
                  () {
                    data.removeAt(index);
                  },
                );
              },
            );
          } else {
            showSnackBar(
              message: 'part_label_no_delete_permission'.tr,
              isWarning: true,
            );
          }
        },
        onTap: () => data[index].isSelect.value = !data[index].isSelect.value,
        child: Obx(() => Card(
              color: data[index].isSelect.value
                  ? Colors.green.shade100
                  : Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    textSpan(
                        hint: 'part_label_label'.tr,
                        text: data[index].barCode ?? '',
                        textColor: Colors.green.shade700),
                    Row(
                      children: [
                        expandedTextSpan(
                          hint: 'part_label_size'.tr,
                          text: data[index].size ?? '',
                        ),
                        expandedTextSpan(
                          hint: 'part_label_qty'.tr,
                          text: data[index].createQty.toShowString(),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        expandedTextSpan(
                          hint: 'part_label_worker'.tr,
                          text: data[index].getWorkerName(),
                        ),
                        expandedTextSpan(
                          hint: 'part_label_report_status'.tr,
                          text: (data[index].reported ?? false)
                              ? 'part_label_reported'.tr
                              : 'part_label_unreported'.tr,
                          textColor: (data[index].reported ?? false)
                              ? Colors.green
                              : Colors.redAccent,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            )),
      );
}
