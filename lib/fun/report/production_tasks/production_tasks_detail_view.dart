import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jd_flutter/bean/http/response/production_tasks_info.dart';
import 'package:jd_flutter/utils/utils.dart';
import 'package:jd_flutter/widget/custom_widget.dart';

import 'production_tasks_logic.dart';
import 'production_tasks_state.dart';

class ProductionTasksDetailPage extends StatefulWidget {
  const ProductionTasksDetailPage({super.key});

  @override
  State<ProductionTasksDetailPage> createState() =>
      _ProductionTasksDetailPageState();
}

class _ProductionTasksDetailPageState extends State<ProductionTasksDetailPage> {
  final ProductionTasksLogic logic = Get.find<ProductionTasksLogic>();
  final ProductionTasksState state = Get.find<ProductionTasksLogic>().state;
  final orderListKey = GlobalKey<AnimatedListState>();
  bool isInstruction = Get.arguments['isInstruction'];
  String imageUrl = Get.arguments['imageUrl'];

  Widget productionTasksTableItem({
    ProductionTasksDetailItemInfo? data,
    int? type,
  }) {
    var size = '';
    var qty = '';
    var productScannedQty = '';
    var manualScannedQty = '';
    var scannedQty = '';
    var owe = '';
    var completionRate = '';
    var installedQty = '';
    var scannedNotInstalled = '';
    var bkgColor = type != null && type == 1
        ? Colors.blueAccent
        : type == 2
            ? Colors.green.shade100
            : Colors.white;
    var textColor = type != null && type == 1 ? Colors.white : Colors.black87;
    if (type != null && type == 1) {
      size = '尺码';
      qty = '生产数';
      productScannedQty = '产线扫描数';
      manualScannedQty = '手动扫描数';
      scannedQty = '累计扫描数';
      owe = '欠数';
      completionRate = '完成率';
      installedQty = '已装数';
      scannedNotInstalled = '已扫未装数';
    } else {
      if (type != null && type == 2) {
        data = logic.getDetailTotalItem();
      }
      size = data!.size ?? '';
      qty = data.qty.toShowString();
      productScannedQty = data.productScannedQty.toShowString();
      manualScannedQty = data.manualScannedQty.toShowString();
      scannedQty = data.scannedQty.toShowString();
      owe = data.getOwe().toShowString();
      completionRate = data.getCompletionRate();
      installedQty = data.installedQty.toShowString();
      scannedNotInstalled = data.scannedNotInstalled().toShowString();
    }
    return Row(
      children: [
        expandedFrameText(
          text: size,
          backgroundColor: bkgColor,
          textColor: textColor,
          isBold: true,
          alignment: Alignment.center,
        ),
        expandedFrameText(
          text: qty,
          backgroundColor: bkgColor,
          textColor: textColor,
          isBold: true,
          alignment: Alignment.center,
        ),
        expandedFrameText(
          text: productScannedQty,
          backgroundColor: bkgColor,
          textColor: textColor,
          isBold: true,
          alignment: Alignment.center,
        ),
        expandedFrameText(
          text: manualScannedQty,
          backgroundColor: bkgColor,
          textColor: textColor,
          isBold: true,
          alignment: Alignment.center,
        ),
        expandedFrameText(
          text: scannedQty,
          backgroundColor: bkgColor,
          textColor: textColor,
          isBold: true,
          alignment: Alignment.center,
        ),
        expandedFrameText(
          text: owe,
          backgroundColor: bkgColor,
          textColor: textColor,
          isBold: true,
          alignment: Alignment.center,
        ),
        expandedFrameText(
          text: completionRate,
          backgroundColor: bkgColor,
          textColor: textColor,
          isBold: true,
          alignment: Alignment.center,
        ),
        expandedFrameText(
          text: installedQty,
          backgroundColor: bkgColor,
          textColor: textColor,
          isBold: true,
          alignment: Alignment.center,
        ),
        expandedFrameText(
          text: scannedNotInstalled,
          backgroundColor: bkgColor,
          textColor: textColor,
          isBold: true,
          alignment: Alignment.center,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('isInstruction=$isInstruction imageUrl=$imageUrl');
    return pageBody(
      title: isInstruction
          ? '指令号：${state.detailInstructionNo.value}'
          : '客户PO：${state.detailCustomerPO.value}',
      body: Padding(
        padding: const EdgeInsets.only(left: 7, right: 7, bottom: 7),
        child: Column(
          children: [
            SizedBox(
              height: 240,
              child: Row(
                children: [
                  Container(
                    margin: const EdgeInsets.only(right: 5),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.green.shade100,
                          Colors.blue.shade100,
                        ],
                      ),
                      border: Border.all(
                        color: Colors.blueAccent,
                        width: 2,
                      ),
                    ),
                    child: Hero(
                      tag: 'ProductionTasksDetailImage-$imageUrl',
                      child: AspectRatio(
                        aspectRatio: 16 / 9,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.network(
                            fit: BoxFit.fill,
                            imageUrl,
                            errorBuilder: (ctx, err, stackTrace) => Image.asset(
                              'assets/images/ic_logo.png',
                              color: Colors.blue,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.green.shade100,
                                  Colors.blue.shade100,
                                ],
                              ),
                              border: Border.all(
                                color: Colors.blueAccent,
                                width: 2,
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  width: double.infinity,
                                  padding: EdgeInsets.all(5),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8),
                                    color: Colors.blue.shade100,
                                    border: Border.all(
                                      color: Colors.blueAccent,
                                      width: 2,
                                    ),
                                  ),
                                  child: Center(
                                    child: Text(
                                      isInstruction ? '客户PO' : '指令号',
                                      style: const TextStyle(
                                        color: Colors.black,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 20,
                                      ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Center(
                                    child: Text(
                                      isInstruction
                                          ? state.detailCustomerPO.value
                                          : state.detailInstructionNo.value,
                                      style: const TextStyle(
                                        color: Colors.green,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 24,
                                      ),
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.all(5),
                          margin: const EdgeInsets.only(top: 5),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.green.shade100,
                                Colors.blue.shade100,
                              ],
                            ),
                            border: Border.all(
                              color: Colors.blueAccent,
                              width: 2,
                            ),
                          ),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  Text(
                                    '装箱进度：',
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                      child: percentIndicator(
                                    max: state.detailShouldPackQty.value,
                                    value: state.detailPackagedQty.value,
                                  ))
                                ],
                              ),
                              const SizedBox(height: 5),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  textSpan(
                                    hint: '应装：',
                                    text: state.detailShouldPackQty.value
                                        .toShowString(),
                                  ),
                                  textSpan(
                                    hint: '已装：',
                                    text: state.detailPackagedQty.value
                                        .toShowString(),
                                  ),
                                  textSpan(
                                    hint: '未装：',
                                    text: state.detailShouldPackQty.value
                                        .sub(state.detailPackagedQty.value)
                                        .toShowString(),
                                  )
                                ],
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                  )
                ],
              ),
            ),
            const SizedBox(height: 10),
            productionTasksTableItem(type: 1),
            Expanded(
              child: Obx(() => ListView(
                    children: [
                      for (var item in state.detailTableInfo)
                        productionTasksTableItem(data: item),
                      if (state.detailTableInfo.isNotEmpty)
                        productionTasksTableItem(type: 2),
                    ],
                  )),
            ),
          ],
        ),
      ),
    );
  }
}
