import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jd_flutter/bean/http/response/part_detail_info.dart';
import 'package:jd_flutter/fun/dispatching/work_order_list/work_order_list_logic.dart';
import 'package:jd_flutter/fun/work_reporting/part_process_scan/part_process_scan_view.dart';
import 'package:jd_flutter/utils/extension_util.dart';
import 'package:jd_flutter/utils/utils.dart';
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

  _createLabelDialog(SizeInfo data) {
    var max = data.qty.sub(data.createQty ?? 0);
    var boxCapacity = max;
    var createQty = max;
    var empID = '';
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
                  onChanged: (wi) {
                    if (wi != null) {
                      empID = wi.empID.toString();
                    } else {
                      empID = '';
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

  _printLabelDialog(List<BarCodeInfo> dataList) {
    var select = <RxBool>[];
    var data = <BarCodeInfo>[].obs;
    for (var v in dataList) {
      select.add(false.obs);
      data.add(v);
    }
    Get.dialog(
      PopScope(
        canPop: false,
        child: Obx(() => AlertDialog(
              title: Row(
                children: [
                  Expanded(child: Text('part_label_label_list_delete_tips'.tr)),
                  GestureDetector(
                    onTap: () {
                      var isSelectAll = select.isNotEmpty &&
                          select.where((v) => v.value).length == select.length;
                      for (var s in select) {
                        s.value = !isSelectAll;
                      }
                    },
                    child: Text(
                      'part_label_all'.tr,
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                  Checkbox(
                    value: select.isNotEmpty &&
                        select.where((v) => v.value).length == select.length,
                    onChanged: (c) {
                      for (var s in select) {
                        s.value = c!;
                      }
                    },
                  ),
                ],
              ),
              content: SizedBox(
                width: getScreenSize().width * 0.8,
                height: getScreenSize().height * 0.8,
                child: ListView.builder(
                  padding: const EdgeInsets.all(8),
                  itemCount: data.length,
                  itemBuilder: (context, index) => GestureDetector(
                    onLongPress: () {
                      if (checkUserPermission('1052504')) {
                        askDialog(
                          content: 'part_label_delete_tips'
                              .trArgs([data[index].barCode ?? '']),
                          confirm: () {
                            logic.deleteLabel(
                              data[index].barCode ?? '',
                              () {
                                data.removeAt(index);
                                select.removeAt(index);
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
                    onTap: () => select[index].value = !select[index].value,
                    child: Card(
                      color: select[index].value
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
                TextButton(
                  onPressed: () {},
                  child: Text(
                    'part_label_print'.tr,
                  ),
                ),
              ],
            )),
      ),
    );
  }

  _paddingText(String text) {
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

  _item(SizeInfo data) {
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
                hint: 'part_label_label'.tr,
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

  _itemTotal(SizeInfo data) {
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
        if (state.partDetail?.barCodeList?.isNotEmpty == true)
          CombinationButton(
            text: 'part_label_print_label'.tr,
            click: () {
              if (checkUserPermission('1052501')) {
                _printLabelDialog(state.partDetail?.barCodeList ?? []);
              } else {
                showSnackBar(
                  message: 'part_label_no_label_operation_permission'.tr,
                  isWarning: true,
                );
              }
            },
          ),
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
              text: state.partDetail?.factoryType ?? '',
              textColor: Colors.blueAccent,
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 10),
            child: textSpan(
              hint: 'part_label_part'.tr,
              text: state.partDetail?.partName ?? '',
              textColor: Colors.blueAccent,
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 10),
            child: textSpan(
              hint: 'part_label_process'.tr,
              text: state.partDetail?.processName ?? '',
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
                    return _itemTotal(state.partDetail!.getSizeListTotal());
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
