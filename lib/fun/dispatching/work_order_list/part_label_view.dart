import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jd_flutter/bean/http/response/part_detail_info.dart';
import 'package:jd_flutter/fun/dispatching/part_process_scan/part_process_scan_view.dart';
import 'package:jd_flutter/fun/dispatching/work_order_list/work_order_list_logic.dart';
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

  _salesOrderListDialog(List<String> labels) {
    Get.dialog(
      PopScope(
        canPop: false,
        child: AlertDialog(
          title: Text('销售订单列表'),
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
              child: const Text(
                '返回',
                style: TextStyle(color: Colors.grey),
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
          title: Text('贴标创建'),
          content: SizedBox(
            width: 300,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _paddingText('箱容'),
                NumberDecimalEditText(
                  max: max,
                  initQty: max,
                  onChanged: (d) => boxCapacity = d,
                ),
                _paddingText('创建总数'),
                NumberDecimalEditText(
                  max: max,
                  initQty: max,
                  onChanged: (d) => createQty = d,
                ),
                const SizedBox(height: 20),
                WorkerCheck(
                  hint: '被指派员工工号',
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
              onPressed: () => Get.back(),
              child: const Text(
                '返回',
                style: TextStyle(color: Colors.grey),
              ),
            ),
            TextButton(
              onPressed: () => logic.createPartLabel(
                boxCapacity,
                createQty,
                data.size ?? '',
                empID,
              ),
              child: const Text(
                '创建',
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
                  Expanded(child: Text('贴标列表(长按删除)')),
                  GestureDetector(
                    onTap: () {
                      var isSelectAll = select.isNotEmpty &&
                          select.where((v) => v.value).length == select.length;
                      for (var s in select) {
                        s.value = !isSelectAll;
                      }
                    },
                    child: Text(
                      '全选',
                      style: TextStyle(fontSize: 16),
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
                width: MediaQuery.of(context).size.width * 0.8,
                height: MediaQuery.of(context).size.height * 0.8,
                child: ListView.builder(
                  padding: const EdgeInsets.all(8),
                  itemCount: data.length,
                  itemBuilder: (context, index) => GestureDetector(
                    onLongPress: () {
                      if (checkUserPermission('1052504')) {
                        askDialog(
                          content: '确定要删除贴标<${data[index].barCode}>吗？',
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
                          title: 'snack_bar_default_wrong'.tr,
                          message: '缺少删除权限！',
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
                        padding: EdgeInsets.all(10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            textSpan(
                                hint: '条码：',
                                text: data[index].barCode ?? '',
                                textColor: Colors.green.shade700),
                            Row(
                              children: [
                                expandedTextSpan(
                                  hint: '尺码：',
                                  text: data[index].size ?? '',
                                ),
                                expandedTextSpan(
                                  hint: '数量：',
                                  text: data[index].createQty.toShowString(),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                expandedTextSpan(
                                  hint: '员工：',
                                  text: data[index].getWorkerName(),
                                ),
                                expandedTextSpan(
                                  hint: '报工状态：',
                                  text: (data[index].reported ?? false)
                                      ? '已报工'
                                      : '未报工',
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
                  child: const Text(
                    '返回',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
                TextButton(
                  onPressed: () {},
                  child: const Text(
                    '打印',
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
          showSnackBar(title: 'snack_bar_default_wrong'.tr, message: '缺少贴标操作权限', isWarning: true);
        }
      },
      child: Card(
        child: ListTile(
          title: textSpan(
            hint: '销售订单号：',
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
                hint: '尺码：',
                text: data.size ?? '',
                textColor: Colors.blue.shade900,
              ),
              expandedTextSpan(
                hint: '已派：',
                text: data.createQty.toShowString(),
                textColor: Colors.blue.shade900,
              ),
              expandedTextSpan(
                hint: '数量：',
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
              hint: '合计',
              hintColor: Colors.white,
              text: '',
            ),
            expandedTextSpan(
              hint: '已派：',
              hintColor: Colors.white,
              text: data.createQty.toShowString(),
              textColor: Colors.white,
            ),
            textSpan(
              hint: '数量：',
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
      logic.queryPartDetail();
    });
  }

  @override
  Widget build(BuildContext context) {
    return pageBody(
      title: '部件工序贴标',
      actions: [
        if (state.partDetail?.barCodeList?.isNotEmpty == true)
          CombinationButton(
            text: '打印标签',
            click: () {
              if (checkUserPermission('1052501')) {
                _printLabelDialog(state.partDetail?.barCodeList ?? []);
              } else {
                showSnackBar(
                  title: 'snack_bar_default_wrong'.tr,
                  message: '缺少贴标操作权限！',
                  isWarning: true,
                );
              }
            },
          ),
        CombinationButton(
          text: '工序扫描',
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
              hint: '工厂型体：',
              text: state.partDetail?.factoryType ?? '',
              textColor: Colors.blueAccent,
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 10),
            child: textSpan(
              hint: '部件：',
              text: state.partDetail?.partName ?? '',
              textColor: Colors.blueAccent,
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 10),
            child: textSpan(
              hint: '工序：',
              text: state.partDetail?.processName ?? '',
              textColor: Colors.blueAccent,
            ),
          ),
          Expanded(
            child: Obx(
              () => ListView.builder(
                padding: const EdgeInsets.all(8),
                itemCount:state.partDetailSizeList.isNotEmpty? state.partDetailSizeList.length + 1:0,
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
