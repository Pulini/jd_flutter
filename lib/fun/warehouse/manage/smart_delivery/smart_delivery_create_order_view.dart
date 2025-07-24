import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jd_flutter/bean/http/response/smart_delivery_info.dart';
import 'package:jd_flutter/utils/utils.dart';
import 'package:jd_flutter/widget/combination_button_widget.dart';
import 'package:jd_flutter/widget/custom_widget.dart';

import 'smart_delivery_dialog.dart';
import 'smart_delivery_logic.dart';

class CreateDeliveryOrderPage extends StatefulWidget {
  const CreateDeliveryOrderPage({super.key});

  @override
  State<CreateDeliveryOrderPage> createState() =>
      _CreateDeliveryOrderPageState();
}

class _CreateDeliveryOrderPageState extends State<CreateDeliveryOrderPage> {
  final logic = Get.find<SmartDeliveryLogic>();
  final state = Get.find<SmartDeliveryLogic>().state;

  _saveDelivery() {
    var pickDate = DateTime.now();
    showDatePicker(
      locale: View.of(Get.overlayContext!).platformDispatcher.locale,
      context: Get.overlayContext!,
      initialDate: pickDate,
      firstDate: DateTime(pickDate.year, pickDate.month - 1, pickDate.day),
      lastDate: pickDate,
    ).then((date) {
      if (date != null) {
        logic.saveDelivery(
          date: getDateYMD(time: date),
          refresh: () => setState(() {}),
        );
      }
    });
  }

  @override
  void initState() {
    logic.setTableLineData();
    super.initState();
  }

  table(DeliveryDetailInfo ddi, List<WorkData> list) {
    return Expanded(
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: SizedBox(
          //列标题占比2、合计占比1
          width: ((ddi.partsSizeList?.length ?? 0) + 2 + 1) * 50,
          child: ListView(
            padding: const EdgeInsets.only(top: 10, bottom: 10),
            children: [
              Row(
                children: [
                  expandedFrameText(
                    flex: 2,
                    text: 'smart_delivery_create_order_size'.tr,
                    backgroundColor: Colors.blueAccent,
                    textColor: Colors.white,
                    borderColor: Colors.black,
                    alignment: Alignment.center,
                  ),
                  for (PartsSizeList data in ddi.partsSizeList ?? [])
                    expandedFrameText(
                      text: data.size ?? '',
                      backgroundColor: Colors.blueAccent,
                      textColor: Colors.white,
                      borderColor: Colors.black,
                      alignment: Alignment.center,
                    ),
                  expandedFrameText(
                    text: 'smart_delivery_create_order_total'.tr,
                    backgroundColor: Colors.blueAccent,
                    textColor: Colors.white,
                    borderColor: Colors.black,
                    alignment: Alignment.center,
                  ),
                ],
              ),
              Row(
                children: [
                  expandedFrameText(
                    flex: 2,
                    text: 'smart_delivery_create_order_shoe_tree_inventory'.tr,
                    backgroundColor: Colors.green,
                    textColor: Colors.white,
                    borderColor: Colors.black,
                    alignment: Alignment.center,
                  ),
                  for (PartsSizeList data
                      in state.deliveryDetail!.partsSizeList ?? [])
                    expandedFrameText(
                      text: data.shoeTreeQty.toString(),
                      backgroundColor: Colors.green,
                      textColor: Colors.white,
                      borderColor: Colors.black,
                      alignment: Alignment.centerRight,
                    ),
                  expandedFrameText(
                    text: state.deliveryDetail!.getShoeTreeTotal().toString(),
                    backgroundColor: Colors.green,
                    textColor: Colors.white,
                    borderColor: Colors.black,
                    alignment: Alignment.centerRight,
                  ),
                ],
              ),
              Row(
                children: [
                  expandedFrameText(
                    flex: 2,
                    text: 'smart_delivery_create_order_order_qty'.tr,
                    backgroundColor: Colors.orange.shade100,
                    borderColor: Colors.black,
                    alignment: Alignment.center,
                  ),
                  for (PartsSizeList data in ddi.partsSizeList ?? [])
                    expandedFrameText(
                      text: data.qty.toString(),
                      backgroundColor: Colors.orange.shade100,
                      borderColor: Colors.black,
                      alignment: Alignment.centerRight,
                    ),
                  expandedFrameText(
                    text: ddi.getOrderTotal().toString(),
                    backgroundColor: Colors.orange.shade100,
                    borderColor: Colors.black,
                    alignment: Alignment.centerRight,
                  ),
                ],
              ),
              for (var i = 0; i < list.length; ++i)
                Row(
                  children: [
                    expandedFrameText(
                      click: () {
                        if (!ddi.workData.isNullOrEmpty()) {
                          if (list[i].sendType == 1) {
                            checkAgvTask(
                              taskId: list[i].taskID ?? '',
                              agvNumber: list[i].agvNumber ?? '',
                              cancelTask: (id) => _cancelTack(id),
                            );
                          } else {
                            setState(() {
                              list[i].isSelected = !list[i].isSelected;
                            });
                          }
                        }
                      },
                      flex: 2,
                      text: list[i].sendType == 2
                          ? 'smart_delivery_create_order_round_star'.trArgs([
                              list[i].round.toString(),
                            ])
                          : 'smart_delivery_create_order_round'.trArgs([
                              list[i].round.toString(),
                            ]),
                      backgroundColor: list[i].sendType == 1
                          ? Colors.green.shade300
                          : list[i].isSelected
                              ? Colors.blue.shade200
                              : Colors.white,
                      borderColor: Colors.black,
                      alignment: Alignment.center,
                    ),
                    for (SizeInfo data in list[i].sendSizeList ?? [])
                      expandedFrameText(
                        text: data.qty.toString(),
                        textColor: data.qty == 0 ? Colors.grey : Colors.black87,
                        backgroundColor: list[i].sendType == 1
                            ? Colors.green.shade300
                            : list[i].isSelected
                                ? Colors.blue.shade200
                                : Colors.white,
                        borderColor: Colors.black,
                        alignment: Alignment.centerRight,
                      ),
                    expandedFrameText(
                      text: list[i].getTotalQty().toString(),
                      backgroundColor: list[i].sendType == 1
                          ? Colors.green.shade300
                          : list[i].isSelected
                              ? Colors.blue.shade200
                              : Colors.white,
                      borderColor: Colors.black,
                      alignment: Alignment.centerRight,
                    ),
                  ],
                )
            ],
          ),
        ),
      ),
    );
  }

  mergeDeliveryTable(DeliveryDetailInfo ddi) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: SizedBox(
        //列标题占比2、合计占比1
        width: ((ddi.partsSizeList?.length ?? 0) + 2 + 1) * 50,
        child: Column(
          children: [
            Row(
              children: [
                expandedFrameText(
                  flex: 2,
                  text: 'smart_delivery_create_order_size'.tr,
                  backgroundColor: Colors.blueAccent,
                  textColor: Colors.white,
                  borderColor: Colors.black,
                  alignment: Alignment.center,
                ),
                for (PartsSizeList data in ddi.partsSizeList ?? [])
                  expandedFrameText(
                    text: data.size ?? '',
                    backgroundColor: Colors.blueAccent,
                    textColor: Colors.white,
                    borderColor: Colors.black,
                    alignment: Alignment.center,
                  ),
                expandedFrameText(
                  text: 'smart_delivery_create_order_total'.tr,
                  backgroundColor: Colors.blueAccent,
                  textColor: Colors.white,
                  borderColor: Colors.black,
                  alignment: Alignment.center,
                ),
              ],
            ),
            for (var i = 0; i < ddi.workData!.length; ++i)
              Row(
                children: [
                  expandedFrameText(
                    click: () {
                      if (state.deliveryDetail!.partsID == ddi.partsID &&
                          state.deliveryDetail?.newWorkCardInterID !=
                              ddi.newWorkCardInterID) {
                        if (ddi.workData![i].sendType == 1) {
                          checkAgvTask(
                            taskId: ddi.workData![i].taskID ?? '',
                            agvNumber: ddi.workData![i].agvNumber ?? '',
                            cancelTask: (id) => _cancelTack(id),
                          );
                        } else {
                          setState(() {
                            ddi.workData![i].isSelected =
                                !ddi.workData![i].isSelected;
                          });
                        }
                      }
                    },
                    flex: 2,
                    text: ddi.workData![i].sendType == 2
                        ? 'smart_delivery_create_order_round_star'.trArgs([
                            ddi.workData![i].round.toString(),
                          ])
                        : 'smart_delivery_create_order_round'.trArgs([
                            ddi.workData![i].round.toString(),
                          ]),
                    backgroundColor: ddi.workData![i].sendType == 1
                        ? Colors.green.shade300
                        : ddi.workData![i].isSelected
                            ? Colors.blue.shade200
                            : Colors.white,
                    borderColor: Colors.black,
                    alignment: Alignment.center,
                  ),
                  for (SizeInfo data in ddi.workData![i].sendSizeList ?? [])
                    expandedFrameText(
                      text: data.qty.toString(),
                      textColor: data.qty == 0 ? Colors.grey : Colors.black87,
                      backgroundColor: ddi.workData![i].sendType == 1
                          ? Colors.green.shade300
                          : ddi.workData![i].isSelected
                              ? Colors.blue.shade200
                              : Colors.white,
                      borderColor: Colors.black,
                      alignment: Alignment.centerRight,
                    ),
                  expandedFrameText(
                    text: ddi.workData![i].getTotalQty().toString(),
                    backgroundColor: ddi.workData![i].sendType == 1
                        ? Colors.green.shade300
                        : ddi.workData![i].isSelected
                            ? Colors.blue.shade200
                            : Colors.white,
                    borderColor: Colors.black,
                    alignment: Alignment.centerRight,
                  ),
                ],
              ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  _cancelTack(String taskID) {
    setState(() {
      state.deliveryList
          .where((v) => v.taskID == taskID)
          .forEach((v) => v.sendType = 2);
      state.saveDeliveryDetail?.workData
          ?.where((v) => v.taskID == taskID)
          .forEach((v) => v.sendType = 2);
    });
  }

  @override
  Widget build(BuildContext context) {
    var line1 = Row(
      children: [
        expandedTextSpan(
          hint: 'smart_delivery_create_order_type_body'.tr,
          text: state.deliveryDetail!.typeBody ?? '',
        ),
        expandedTextSpan(
          hint: 'smart_delivery_create_order_sales_order'.tr,
          text: state.deliveryDetail!.seOrders ?? '',
        ),
        expandedTextSpan(
          hint: 'smart_delivery_create_order_po'.tr,
          text: state.deliveryDetail!.clientOrderNumber ?? '',
        ),
      ],
    );
    var line2 = Row(
      children: [
        expandedTextSpan(
          flex: 2,
          hint: 'smart_delivery_create_order_part'.tr,
          text: state.deliveryDetail!.partName ?? '',
        ),
        expandedTextSpan(
          hint: 'smart_delivery_create_order_goods_no'.tr,
          text: state.deliveryDetail!.mapNumber ?? '',
        ),
      ],
    );
    var bt1V = state.deliveryDetail?.hasDelivered() == false;
    var bt2V = state.saveDeliveryDetail == null &&
        state.deliveryList.any((v) => v.isSelected);
    var bt3V = state.deliveryDetail?.workData.isNullOrEmpty();
    var bt4V = state.deliveryList.any((v) => v.isSelected);
    var bt5V = state.deliveryList.any((v) => v.isSelected);

    return pageBody(
      title: 'smart_delivery_create_order_create_delivery_order'.tr,
      actions: [
        if (bt1V)
          CombinationButton(
            text: state.deliveryDetail?.workData.isNullOrEmpty() == true
                ? 'smart_delivery_create_order_reserve_shoe_tree'.tr
                : 'smart_delivery_create_order_remake_order'.tr,
            backgroundColor: state.deliveryDetail?.workData.isNullOrEmpty() == true
                ? Colors.blue
                : Colors.red,
            click: () => state.deliveryDetail?.workData.isNullOrEmpty() == true
                ? reserveShoeTreeDialog(
                    state.deliveryDetail?.partsSizeList ?? [],
                    (list) => setState(() {
                      state.deliveryDetail?.partsSizeList = list;
                      logic.setTableLineData();
                    }),
                  )
                : logic.resetDeliveryOrder(
                    refresh: () => setState(() {
                      logic.setTableLineData();
                    }),
                  ),
          ),
        if (bt2V)
          CombinationButton(
            backgroundColor: Colors.orange,
            text: 'smart_delivery_create_order_merge_delivery'.tr,
            click: () => logic.mergeDeliveryRound(() => setState(() {})),
          ),
        if (bt3V == true)
          CombinationButton(
            backgroundColor: Colors.blue,
            text: 'smart_delivery_create_order_save_pre_sort'.tr,
            click: () => _saveDelivery(),
          ),
        if (bt4V)
          CombinationButton(
            backgroundColor:
                logic.isCanCache() ? Colors.blue : Colors.amberAccent,
            text: logic.isCanCache()
                ? 'smart_delivery_create_order_save_temporary'.tr
                : 'smart_delivery_create_order_cancel_temporary'.tr,
            click: () => logic.cacheDelivery(() => setState(() {})),
          ),
        if (bt5V)
          CombinationButton(
            backgroundColor: Colors.green,
            text:
                'smart_delivery_create_order_create_material_issuance_task'.tr,
            click: () => createDeliveryTaskDialog(
              nowOrderId: state.deliveryDetail?.newWorkCardInterID ?? '',
              nowOrderPartsId: state.deliveryDetail?.partsID ?? '',
              nowOrderRoundList:
                  state.deliveryList.where((v) => v.isSelected).toList(),
              mergeOrderId: state.saveDeliveryDetail?.newWorkCardInterID ?? '',
              mergeOrderPartsId: state.saveDeliveryDetail?.partsID ?? '',
              mergeOrderRoundList: state.saveDeliveryDetail?.workData!
                      .where((v) => v.isSelected)
                      .toList() ??
                  [],
              success: (taskId, agvNumber) => setState(
                () => logic.refreshCreated(taskId, agvNumber),
              ),
            ),
          ),
        const SizedBox(width: 10),
      ],
      body: Padding(
        padding: const EdgeInsets.only(left: 10, right: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            line1,
            line2,
            table(state.deliveryDetail!, state.deliveryList),
            const SizedBox(height: 20),
            if (state.saveDeliveryDetail != null)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      expandedTextSpan(
                        hint: 'smart_delivery_create_order_part'.tr,
                        text: state.saveDeliveryDetail!.partName ?? '',
                      ),
                      if (state.deliveryDetail?.newWorkCardInterID ==
                              state.saveDeliveryDetail?.newWorkCardInterID &&
                          state.saveDeliveryDetail!.partsID ==
                              state.deliveryDetail!.partsID)
                        CombinationButton(
                          text: 'smart_delivery_create_order_cancel_merge'.tr,
                          backgroundColor: Colors.orange,
                          click: () =>
                              setState(() => logic.cancelMergeDelivery()),
                        )
                    ],
                  ),
                  const SizedBox(height: 10),
                  mergeDeliveryTable(state.saveDeliveryDetail!),
                ],
              )
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    state.deliveryDetail = null;
    state.deliveryList = [];
    super.dispose();
  }
}
