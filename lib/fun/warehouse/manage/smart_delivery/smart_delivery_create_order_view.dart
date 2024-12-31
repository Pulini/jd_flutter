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
                    text: '尺码',
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
                    text: '合计',
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
                    text: '楦头库存',
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
                    text: '订单数',
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
                      text:
                          '${list[i].sendType == 2 ? '★' : ''}第 ${list[i].round} 轮',
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
                  text: '尺码',
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
                  text: '合计',
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
                    text:
                        '${ddi.workData![i].sendType == 2 ? '★' : ''}第 ${ddi.workData![i].round} 轮',
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
            SizedBox(height: 10),
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
          hint: '工厂型体：',
          text: state.deliveryDetail!.typeBody ?? '',
        ),
        expandedTextSpan(
          hint: '销售订单：',
          text: state.deliveryDetail!.seOrders ?? '',
        ),
        expandedTextSpan(
          hint: 'PO号：',
          text: state.deliveryDetail!.clientOrderNumber ?? '',
        ),
      ],
    );
    var line2 = Row(
      children: [
        expandedTextSpan(
          flex: 2,
          hint: '部位：',
          text: state.deliveryDetail!.partName ?? '',
        ),
        expandedTextSpan(
          hint: '货号：',
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
      title: '创建配送单',
      actions: [
        if (bt1V)
          CombinationButton(
            text: state.deliveryDetail?.workData.isNullOrEmpty()
                ? '预留楦头'
                : '重制工单',
            backgroundColor: state.deliveryDetail?.workData.isNullOrEmpty()
                ? Colors.blue
                : Colors.red,
            click: () => state.deliveryDetail?.workData.isNullOrEmpty()
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
            text: '合并配送',
            click: () => logic.mergeDeliveryRound(() => setState(() {})),
          ),
        if (bt3V)
          CombinationButton(
            backgroundColor: Colors.blue,
            text: '保存预排',
            click: () => _saveDelivery(),
          ),
        if (bt4V)
          CombinationButton(
            backgroundColor:
                logic.isCanCache() ? Colors.blue : Colors.amberAccent,
            text: logic.isCanCache() ? '暂存' : '取消暂存',
            click: () => logic.cacheDelivery(() => setState(() {})),
          ),
        if (bt5V)
          CombinationButton(
            backgroundColor: Colors.green,
            text: '创建发料任务',
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
              success: (taskId, agvNumber) =>
                  setState(() => logic.refreshCreated(taskId, agvNumber)),
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
                        hint: '部位：',
                        text: state.saveDeliveryDetail!.partName ?? '',
                      ),
                      if (state.deliveryDetail?.newWorkCardInterID ==
                              state.saveDeliveryDetail?.newWorkCardInterID &&
                          state.saveDeliveryDetail!.partsID ==
                              state.deliveryDetail!.partsID)
                        CombinationButton(
                            text: '取消合并',
                            backgroundColor: Colors.orange,
                            click: () =>
                                setState(() => logic.cancelMergeDelivery()))
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
