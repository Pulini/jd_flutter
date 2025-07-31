import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jd_flutter/fun/report/forming_barcode_collection/forming_barcode_collection_logic.dart';
import 'package:jd_flutter/utils/utils.dart';
import 'package:jd_flutter/widget/custom_widget.dart';
import 'package:jd_flutter/widget/dialogs.dart';
import 'package:jd_flutter/widget/edit_text_widget.dart';

class FormingBarcodeCollectionPriorityPage extends StatefulWidget {
  const FormingBarcodeCollectionPriorityPage({super.key});

  @override
  State<FormingBarcodeCollectionPriorityPage> createState() =>
      _FormingBarcodeCollectionPriorityPageState();
}

class _FormingBarcodeCollectionPriorityPageState
    extends State<FormingBarcodeCollectionPriorityPage> {
  final logic = Get.find<FormingBarcodeCollectionLogic>();
  final state = Get.find<FormingBarcodeCollectionLogic>().state;
  //搜索天数
  var controller = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return pageBody(
        actions: [
          TextButton(
            onPressed: () {
              askDialog(
                content: 'forming_code_collection_sure_submit'.tr,
                confirm: () => logic.prioritySubmit(success: () {
                  Get.back(result: true);
                }),
              );
            },
            child: Text(
              'forming_code_collection_submit'.tr,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          )
        ],
        body: Column(
          children: [
            Row(
              children: [
                Expanded(
                  flex: 4,
                  child: NumberEditText(
                    hint: 'forming_code_collection_input_days'.tr,
                    onChanged: (s) {
                      if (controller.text.toDoubleTry() > 365) {
                        controller.text = '365';
                      }
                    },
                    controller: controller,
                  ),
                ),
                Expanded(
                  child: TextButton(
                    onPressed: () {
                      logic.getWorkCardPriority(day: controller.text);
                    },
                    child: Text(
                      'forming_code_collection_search'.tr,
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 20,
                      ),
                    ),
                  ),
                )
              ],
            ),
            Expanded(
                child: Obx(() => ReorderableListView.builder(
                      itemCount: state.prioriInfoList.length,
                      buildDefaultDragHandles: false,
                      itemBuilder: (context, index) {
                        return ListTile(
                          key: ValueKey(state.prioriInfoList[index]),
                          title: Container(
                            padding: const EdgeInsets.all(5),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: Colors.white,
                              border: Border.all(
                                color: Colors.blue,
                                width: 2,
                              ),
                            ),
                            height: 80,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                        child: textSpan(
                                            //销售订单
                                            hint: 'forming_code_collection_sale_order'.tr,
                                            text: state.prioriInfoList[index]
                                                    .sONo ??
                                                '')),
                                    Expanded(
                                        child: textSpan(
                                            //客户订单
                                            hint:
                                                'forming_code_collection_customer_orders'
                                                    .tr,
                                            text: state.prioriInfoList[index]
                                                    .clientOrderNumber ??
                                                ''))
                                  ],
                                ),
                                Row(
                                  children: [
                                    Expanded(
                                        child: textSpan(
                                            //型体
                                            hint:
                                                'forming_code_collection_type_body'
                                                    .tr,
                                            text: state.prioriInfoList[index]
                                                    .workCardNo ??
                                                '')),
                                    Expanded(
                                        child: textSpan(
                                            //派工数量
                                            hint:
                                                'forming_code_collection_dispatch_qty'
                                                    .tr,
                                            text: state.prioriInfoList[index]
                                                .requireQty
                                                .toShowString()))
                                  ],
                                ),
                                Row(
                                  children: [
                                    Expanded(
                                        child: textSpan(
                                            //欠数
                                            hint:
                                                'forming_code_collection_owing_amounts'
                                                    .tr,
                                            text: state.prioriInfoList[index]
                                                .requireQty
                                                .toShowString())),
                                    Expanded(
                                        child: textSpan(
                                            //序号
                                            hint:
                                                'forming_code_collection_serial_number'
                                                    .tr,
                                            text: state
                                                .prioriInfoList[index].index
                                                .toString())),
                                  ],
                                )
                              ],
                            ),
                          ),
                          trailing: ReorderableDragStartListener(
                            index: index,
                            child:
                                const Icon(Icons.ads_click_outlined), // 自定义拖拽图标
                          ),
                        );
                      },
                      onReorder: (oldIndex, newIndex) {
                        // 排序逻辑
                        setState(() {
                          if (newIndex > oldIndex) {
                            newIndex -= 1; // 如果目标位置在被拖动项的后面，需要减 1
                          }

                          // 获取被拖动的 Item 和目标位置的 Item
                          final movedItem =
                          state.prioriInfoList.removeAt(oldIndex);


                          // 插入被拖动的 Item 到新位置
                          state.prioriInfoList.insert(newIndex, movedItem);
                          
                          state.prioriInfoList[newIndex].isChange = true;
                          state.prioriInfoList[oldIndex].isChange = true;

                        });
                      },
                    )))
          ],
        ));
  }

  @override
  void dispose() {
    controller.clear();
    logic.clearData();
    super.dispose();
  }
}
