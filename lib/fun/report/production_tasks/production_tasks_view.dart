import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jd_flutter/bean/http/response/feishu_info.dart';
import 'package:jd_flutter/bean/http/response/production_tasks_info.dart';
import 'package:jd_flutter/route.dart';
import 'package:jd_flutter/utils/mqtt.dart';
import 'package:jd_flutter/utils/utils.dart';
import 'package:jd_flutter/widget/combination_button_widget.dart';
import 'package:jd_flutter/widget/custom_widget.dart';
import 'package:jd_flutter/widget/web_page.dart';

import 'production_tasks_logic.dart';
import 'production_tasks_state.dart';

class ProductionTasksPage extends StatefulWidget {
  const ProductionTasksPage({super.key});

  @override
  State<ProductionTasksPage> createState() => _ProductionTasksPageState();
}

class _ProductionTasksPageState extends State<ProductionTasksPage> {
  final ProductionTasksLogic logic = Get.put(ProductionTasksLogic());
  final ProductionTasksState state = Get.find<ProductionTasksLogic>().state;
  final orderListKey = GlobalKey<AnimatedListState>();
  late MqttUtil mqtt = MqttUtil(
    server: state.mqttServer,
    port: state.mqttPort,
    topic: state.mqttTopic,
    connectListener: (m) => mqtt.send(
      topic: state.mqttSend,
      msg: '{"IsGetAllList":1}',
    ),
    msgListener: (topic, data) => logic.mqttRefresh(
      topic: topic,
      data: data,
      refreshItem: (msg) => showScanTips(
        tips: msg,
        color: Colors.red,
        duration: const Duration(milliseconds: 750),
      ),
      refreshAll: () => _refreshTable(),
    ),
  );

  _pickFilePopup(List<FeishuWikiSearchItemInfo> list) {
    showCupertinoModalPopup(
      context: Get.overlayContext!,
      barrierDismissible: false,
      builder: (BuildContext context) => PopScope(
        canPop: true,
        child: SingleChildScrollView(
          primary: true,
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Container(
            height: MediaQuery.of(context).size.height * 0.35,
            padding: const EdgeInsets.all(8.0),
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
              gradient: LinearGradient(
                colors: [Colors.lightBlueAccent, Colors.blueAccent],
                begin: Alignment.bottomLeft,
                end: Alignment.topRight,
              ),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        '工艺书列表',
                        style: const TextStyle(
                          fontSize: 24,
                          color: Colors.white,
                          decoration: TextDecoration.none,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Get.back(),
                      icon: const Icon(
                        Icons.cancel_rounded,
                        color: Colors.white,
                      ),
                    )
                  ],
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: list.length,
                    itemBuilder: (c, i) => Card(
                      child: Padding(
                        padding: const EdgeInsets.only(left: 10, right: 10),
                        child: Row(
                          children: [
                            Expanded(child: Text(list[i].title ?? '')),
                            IconButton(
                              onPressed: () {
                                Get.back();
                                Get.to(() => WebPage(
                                      title: list[i].title ?? '',
                                      url: list[i].url ?? '',
                                    ));
                              },
                              icon: const Icon(
                                Icons.chevron_right,
                                color: Colors.blueAccent,
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _orderItem(
    ProductionTasksSubInfo data,
    Animation<double> animation,
    int index,
  ) {
    var duration = const Duration(milliseconds: 500);
    var errorImage = Image.asset(
      'assets/images/ic_logo.png',
      color: Colors.blue,
    );
    var image = Hero(
        tag: 'ProductionTasksDetailImage-${data.itemImage}',
        child: AspectRatio(
          aspectRatio: 16 / 9,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(7),
            child: data.itemImage?.isEmpty == true
                ? errorImage
                : Image.network(
                    fit: BoxFit.fill,
                    data.itemImage ?? '',
                    errorBuilder: (ctx, err, stackTrace) => errorImage,
                  ),
          ),
        ));
    return SizeTransition(
      sizeFactor: animation,
      axis: Axis.horizontal,
      child: GestureDetector(
        onTap: () {
          if (index != 0) {
            setState(() {
              if (state.selected.value == index) {
                state.selected.value = -1;
              } else {
                state.selected.value = index;
              }
            });
          }
        },
        child: AnimatedContainer(
          curve: Curves.fastOutSlowIn,
          margin: const EdgeInsets.only(left: 5, right: 5, top: 10, bottom: 10),
          padding: const EdgeInsets.all(5),
          width: state.selected.value != 0 && state.selected.value == index
              ? 250
              : 200,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                index == 0
                    ? Colors.green.shade100
                    : state.selected.value == index
                        ? Colors.green.shade100
                        : Colors.blue.shade100,
                index == 0 ? Colors.green.shade300 : Colors.green.shade50
              ],
            ),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.grey, width: 2),
          ),
          duration: duration,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                data.productName ?? '',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              index == 0
                  ? image
                  : Row(
                      children: [
                        AnimatedOpacity(
                          curve: Curves.fastOutSlowIn,
                          duration: duration,
                          opacity: state.selected.value == index ? 1 : 0,
                          child: AnimatedContainer(
                            duration: duration,
                            curve: Curves.fastOutSlowIn,
                            width: state.selected.value == index ? 50 : 0,
                            height: state.selected.value == index ? 50 : 0,
                            child: IconButton(
                              onPressed: () => logic.changeSort(
                                oldIndex: index,
                                newIndex: index - 1,
                                refresh: () => _moveUpOrderItem(index),
                              ),
                              icon: const Icon(
                                Icons.arrow_back_ios_rounded,
                                color: Colors.blueAccent,
                              ),
                            ),
                          ),
                        ),
                        Expanded(child: image),
                        AnimatedOpacity(
                          opacity: state.selected.value == index &&
                                  index < state.orderList.length - 1
                              ? 1
                              : 0,
                          curve: Curves.fastOutSlowIn,
                          duration: duration,
                          child: AnimatedContainer(
                            duration: duration,
                            curve: Curves.fastOutSlowIn,
                            width: state.selected.value == index ? 50 : 0,
                            height: state.selected.value == index ? 50 : 0,
                            child: IconButton(
                              onPressed: () {
                                if (index < state.orderList.length - 1) {
                                  logic.changeSort(
                                    oldIndex: index,
                                    newIndex: index + 1,
                                    refresh: () => _moveDownOrderItem(index),
                                  );
                                }
                              },
                              icon: const Icon(
                                Icons.arrow_forward_ios_rounded,
                                color: Colors.blueAccent,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
              AnimatedOpacity(
                opacity: state.selected.value == index ? 1 : 0,
                curve: Curves.fastOutSlowIn,
                duration: duration,
                child: AnimatedContainer(
                  duration: duration,
                  curve: Curves.fastOutSlowIn,
                  height: state.selected.value == index ? 39 : 0,
                  child: CombinationButton(
                    text: '置顶',
                    click: () => logic.changeSort(
                      oldIndex: index,
                      newIndex: 0,
                      refresh: () => _moveTopOrderItem(index),
                    ),
                  ),
                ),
              ),
              // Text(data.mtoNo ?? ''),
              // Text(data.clientOrderNumber ?? ''),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: AnimatedContainer(
                            height: 39,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.only(
                                topLeft: const Radius.circular(20),
                                bottomLeft: const Radius.circular(20),
                                topRight: Radius.circular(
                                  state.selected.value == index || index == 0
                                      ? 0
                                      : 20,
                                ),
                                bottomRight: Radius.circular(
                                  state.selected.value == index || index == 0
                                      ? 0
                                      : 20,
                                ),
                              ),
                              border: Border.all(
                                color:
                                    state.selected.value == index || index == 0
                                        ? Colors.blueAccent
                                        : Colors.transparent,
                                width: 2,
                              ),
                            ),
                            duration: duration,
                            child: TextButton(
                              onPressed: () {
                                if (state.selected.value == index ||
                                    index == 0) {
                                  logic.getDetail(
                                    ins: data.mtoNo ?? '',
                                    imageUrl: data.itemImage ?? '',
                                  );
                                } else {
                                  setState(() => state.selected.value = index);
                                }
                              },
                              child: Text(
                                data.mtoNo ?? '',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: state.selected.value == index ||
                                          index == 0
                                      ? Colors.blueAccent
                                      : Colors.black87,
                                ),
                              ),
                            ),
                          ),
                        ),
                        if (state.selected.value == index || index == 0)
                          AnimatedContainer(
                            height: 39,
                            decoration: BoxDecoration(
                              borderRadius: const BorderRadius.only(
                                topRight: Radius.circular(20),
                                bottomRight: Radius.circular(20),
                              ),
                              border: Border.all(
                                color:
                                    state.selected.value == index || index == 0
                                        ? Colors.blueAccent
                                        : Colors.transparent,
                                width: 2,
                              ),
                            ),
                            duration: duration,
                            child: TextButton(
                              onPressed: () {
                                if (state.selected.value == index ||
                                    index == 0) {
                                  logic.queryProcessInstruction(
                                    // query: data.shoeStyle ?? '',
                                    query: 'pdf',
                                    files: (files) => _pickFilePopup(files),
                                  );
                                } else {
                                  setState(() => state.selected.value = index);
                                }
                              },
                              child: Text(
                                '工艺书',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blueAccent,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                    AnimatedContainer(
                      margin: const EdgeInsets.only(top: 5),
                      height: 39,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: state.selected.value == index || index == 0
                              ? Colors.blueAccent
                              : Colors.transparent,
                          width: 2,
                        ),
                      ),
                      duration: duration,
                      child: TextButton(
                        onPressed: () {
                          if (state.selected.value == index || index == 0) {
                            logic.getDetail(
                              po: data.clientOrderNumber ?? '',
                              imageUrl: data.itemImage ?? '',
                            );
                          } else {
                            setState(() => state.selected.value = index);
                          }
                        },
                        child: Text(
                          data.clientOrderNumber ?? '',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: state.selected.value == index || index == 0
                                ? Colors.blueAccent
                                : Colors.black87,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _orderRemoveItem(
    Animation<double> animation,
  ) {
    return SizeTransition(
      sizeFactor: animation,
      axis: Axis.horizontal,
      child: Container(
        margin: const EdgeInsets.only(left: 5, right: 5, top: 10, bottom: 10),
        width: 200,
      ),
    );
  }

  AnimatedRemovedItemBuilder getRemovedBuilder(int index) =>
      (BuildContext context, Animation<double> animation) {
        return _orderRemoveItem(animation);
      };

  _moveUpOrderItem(int index) {
    setState(() {
      state.selected.value = -1;
    });
    Future.delayed(const Duration(milliseconds: 500), () {
      state.orderList.insert(index - 1, state.orderList.removeAt(index));
      orderListKey.currentState!.removeItem(index, getRemovedBuilder(index));
      orderListKey.currentState!.insertItem(index - 1);
      state.refreshUiData();
    });
  }

  _moveDownOrderItem(int index) {
    setState(() {
      state.selected.value = -1;
    });
    Future.delayed(const Duration(milliseconds: 500), () {
      state.orderList.insert(index + 1, state.orderList.removeAt(index));
      orderListKey.currentState!.removeItem(index, getRemovedBuilder(index));
      orderListKey.currentState!.insertItem(index + 1);
      state.refreshUiData();
    });
  }

  _moveTopOrderItem(int index) {
    setState(() {
      state.selected.value = -1;
    });
    Future.delayed(const Duration(milliseconds: 500), () {
      state.orderList.insert(0, state.orderList.removeAt(index));
      orderListKey.currentState!.removeAllItems((context, animation) {
        return _orderItem(state.orderList[index], animation, index);
      });

      Future.delayed(const Duration(milliseconds: 500), () {
        orderListKey.currentState!.insertAllItems(0, state.orderList.length);
      });
      state.refreshUiData();
    });
  }

  Widget productionTasksTableItem({
    WorkCardSizeInfos? data,
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
        data = logic.getTotalItem();
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

  _refreshTable() {
    setState(() {
      orderListKey.currentState!.removeAllItems((context, animation) {
        return _orderRemoveItem(animation);
      });
      Future.delayed(const Duration(milliseconds: 300), () {
        orderListKey.currentState!.insertAllItems(0, state.orderList.length);
      });
    });
  }

  _packetWay() => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 10),
          Text(
            '装箱方式',
            style: TextStyle(
                color: Colors.blue.shade700, fontWeight: FontWeight.bold),
          ),
          Container(
            padding: const EdgeInsets.all(5),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blue.shade100, Colors.green.shade50],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              // color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.blue, width: 2),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [for (var i in state.packetWay) Text(i)],
            ),
          )
        ],
      );

  _specificRequirements() => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 10),
          Text(
            '客人特殊要求',
            style: TextStyle(
                color: Colors.blue.shade700, fontWeight: FontWeight.bold),
          ),
          Container(
            padding: const EdgeInsets.all(5),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blue.shade100, Colors.green.shade50],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              // color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.blue, width: 2),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [for (var i in state.specificRequirements) Text(i)],
            ),
          )
        ],
      );

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      mqtt.connect();
      // logic.refreshTable(refresh: () => _refreshTable());
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return pageBody(
      title: '${getFunctionTitle()}  <${userInfo?.departmentName}>',
      actions: [
        IconButton(
          onPressed: () => logic.refreshTable(refresh: () => _refreshTable()),
          icon: const Icon(Icons.refresh),
        )
      ],
      body: Padding(
        padding: const EdgeInsets.only(left: 7, right: 7, bottom: 7),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Obx(() => textSpan(
                      hint: '今日目标数：',
                      text: state.todayTargetQty.value.toShowString(),
                    )),
                Obx(() => textSpan(
                      hint: '今日完成数：',
                      text: state.todayCompleteQty.value.toShowString(),
                    )),
                Obx(() => textSpan(
                      hint: '月完成数：',
                      text: state.monthCompleteQty.value.toShowString(),
                    )),
              ],
            ),
            SizedBox(
              height: 260,
              child: AnimatedList(
                key: orderListKey,
                scrollDirection: Axis.horizontal,
                initialItemCount: state.orderList.length,
                itemBuilder: (context, index, animation) {
                  return _orderItem(state.orderList[index], animation, index);
                },
              ),
            ),
            Row(
              children: [
                Obx(() => expandedTextSpan(
                      hint: '型体：',
                      text: state.typeBody.value,
                    )),
                Obx(() => expandedTextSpan(
                      hint: '指令号：',
                      text: state.instructionNo.value,
                    )),
                Obx(() => expandedTextSpan(
                      hint: '客户PO：',
                      text: state.customerPO.value,
                    )),
              ],
            ),
            Row(
              children: [
                Obx(() => expandedTextSpan(
                      hint: '应装箱数：',
                      text: state.shouldPackQty.value.toShowString(),
                    )),
                Obx(() => expandedTextSpan(
                      hint: '已装箱数：',
                      text: state.packagedQty.value.toShowString(),
                    )),
                Obx(() => expandedTextSpan(
                      hint: '未装箱数：',
                      text: state.shouldPackQty.value
                          .sub(state.packagedQty.value)
                          .toShowString(),
                    )),
              ],
            ),
            const SizedBox(height: 10),
            productionTasksTableItem(type: 1),
            Expanded(
              child: Obx(() => ListView(
                    children: [
                      for (var item in state.tableInfo)
                        productionTasksTableItem(data: item),
                      if (state.tableInfo.isNotEmpty)
                        productionTasksTableItem(type: 2),
                      if (state.packetWay.isNotEmpty) _packetWay(),
                      if (state.specificRequirements.isNotEmpty)
                        _specificRequirements()
                    ],
                  )),
            ),
            // MQTTExample()
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    mqtt.disconnect();
    Get.delete<ProductionTasksLogic>();
    super.dispose();
  }
}
