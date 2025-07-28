import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jd_flutter/bean/home_button.dart';
import 'package:jd_flutter/bean/http/response/production_tasks_info.dart';
import 'package:jd_flutter/utils/mqtt.dart';
import 'package:jd_flutter/utils/utils.dart';
import 'package:jd_flutter/widget/combination_button_widget.dart';
import 'package:jd_flutter/widget/custom_widget.dart';
import 'package:jd_flutter/widget/feishu_authorize.dart';
import 'package:rotated_corner_decoration/rotated_corner_decoration.dart';

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
  var controller = TextEditingController();
  final orderListKey = GlobalKey<AnimatedListState>();
  late MqttUtil mqtt = MqttUtil(
    server: state.mqttServer,
    port: state.mqttPort,
    topic: state.mqttTopic,
    // connectListener: (m) => mqtt.send(
    //   topic: state.mqttSend,
    //   msg: '{"IsGetAllList":1}',
    // ),
    connectListener: (m) => logic.refreshTable(refresh: () => _refreshTable()),
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

  Widget _orderItem(
    ProductionTasksSubInfo data,
    Animation<double> animation,
    int index,
  ) {
    isSelected() => state.selected == index;

    var duration = const Duration(milliseconds: 500);
    var errorImage = Image.asset(
      'assets/images/ic_logo.png',
      color: Colors.blue,
    );
    var outBox = RotatedCornerDecoration.withColor(
      color: data.existOutBoxBarCode == true ? Colors.green : Colors.red,
      badgeCornerRadius: const Radius.circular(10),
      badgeSize: const Size(55, 55),
      textSpan: TextSpan(
        text: 'production_tasks_barcode'.tr,
        style: const TextStyle(
          fontSize: 14,
          color: Colors.white,
        ),
      ),
    );
    var image = Hero(
      tag: 'ProductionTasksDetailImage-${data.itemImage}-${data.mtoNo}',
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
      ),
    );
    var up = AnimatedOpacity(
      curve: Curves.fastOutSlowIn,
      duration: duration,
      opacity: isSelected() ? 1 : 0,
      child: AnimatedContainer(
        duration: duration,
        curve: Curves.fastOutSlowIn,
        width: isSelected() ? 50 : 0,
        height: isSelected() ? 50 : 0,
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
    );
    var down = AnimatedOpacity(
      opacity: isSelected() && index < state.orderList.length - 1 ? 1 : 0,
      curve: Curves.fastOutSlowIn,
      duration: duration,
      child: AnimatedContainer(
        duration: duration,
        curve: Curves.fastOutSlowIn,
        width: isSelected() ? 50 : 0,
        height: isSelected() ? 50 : 0,
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
    );
    var top = AnimatedOpacity(
      opacity: isSelected() ? 1 : 0,
      curve: Curves.fastOutSlowIn,
      duration: duration,
      child: AnimatedContainer(
        duration: duration,
        curve: Curves.fastOutSlowIn,
        height: isSelected() ? 39 : 0,
        child: CombinationButton(
          text: 'production_tasks_top_up'.tr,
          click: () => logic.changeSort(
            oldIndex: index,
            newIndex: 0,
            refresh: () => _moveTopOrderItem(index),
          ),
        ),
      ),
    );
    var mtoNo = TextButton(
      onPressed: () {
        if (isSelected() || index == 0) {
          logic.getDetail(
            ins: data.mtoNo ?? '',
            imageUrl: data.itemImage ?? '',
          );
        } else {
          setState(() => state.selected = index);
        }
      },
      child: Text(
        data.mtoNo ?? '',
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color:
              isSelected() || index == 0 ? Colors.blueAccent : Colors.black87,
        ),
      ),
    );
    var viewFile = AnimatedOpacity(
      opacity: isSelected() || index == 0 ? 1 : 0,
      curve: Curves.fastOutSlowIn,
      duration: duration,
      child: AnimatedContainer(
        width: isSelected() || index == 0 ? 50 : 0,
        duration: duration,
        child: IconButton(
          padding: const EdgeInsets.all(0),
          onPressed: () => showCupertinoModalPopup(
            context: context,
            builder: (context) => CupertinoActionSheet(
              title: Text(
                'production_tasks_view_title'.tr,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                  fontSize: 22,
                ),
              ),
              actions: [
                CupertinoActionSheetAction(
                  isDefaultAction: true,
                  onPressed: () {
                    Get.back();
                    feishuViewWikiFiles(query: data.shoeStyle ?? '');
                  },
                  child: Text('production_tasks_manuel'.tr),
                ),
                CupertinoActionSheetAction(
                  isDefaultAction: true,
                  onPressed: () {
                    Get.back();
                    feishuViewCloudDocFiles(
                      query: '${data.mtoNo}-${data.clientOrderNumber}',
                    );
                  },
                  child: Text('production_tasks_pack_manual'.tr),
                ),
                CupertinoActionSheetAction(
                  isDefaultAction: true,
                  onPressed: () {
                    Get.back();
                    logic.getOrderPackMaterialInfo(data.mtoNo ?? '');
                  },
                  child: Text('production_tasks_pack_material_info'.tr),
                ),
              ],
              cancelButton: CupertinoActionSheetAction(
                isDefaultAction: true,
                onPressed: () => Get.back(),
                child: Text(
                  'dialog_default_cancel'.tr,
                  style: const TextStyle(color: Colors.grey),
                ),
              ),
            ),
          ),
          icon: const Icon(
            Icons.menu_book,
            color: Colors.blueAccent,
          ),
        ),
      ),
    );
    var clientOrderNo = AnimatedContainer(
      margin: const EdgeInsets.only(top: 5),
      height: 39,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isSelected() || index == 0
              ? Colors.blueAccent
              : Colors.transparent,
          width: 2,
        ),
      ),
      duration: duration,
      child: TextButton(
        onPressed: () {
          if (isSelected() || index == 0) {
            logic.getDetail(
              po: data.clientOrderNumber ?? '',
              imageUrl: data.itemImage ?? '',
            );
          } else {
            setState(() => state.selected = index);
          }
        },
        child: Text(
          data.clientOrderNumber ?? '',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color:
                isSelected() || index == 0 ? Colors.blueAccent : Colors.black87,
          ),
        ),
      ),
    );
    return SizeTransition(
      sizeFactor: animation,
      axis: Axis.horizontal,
      child: GestureDetector(
        onTap: () {
          if (index != 0) {
            setState(() {
              if (isSelected()) {
                state.selected = -1;
              } else {
                state.selected = index;
              }
            });
          }
        },
        child: AnimatedContainer(
          foregroundDecoration: outBox,
          curve: Curves.fastOutSlowIn,
          margin: const EdgeInsets.only(left: 5, right: 5, top: 10, bottom: 10),
          padding: const EdgeInsets.all(5),
          width: state.selected != 0 && isSelected() ? 250 : 200,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                index == 0
                    ? Colors.green.shade100
                    : isSelected()
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
              SizedBox(
                width: double.infinity,
                child: Text(
                  data.productName ?? '',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              index == 0
                  ? image
                  : Row(children: [up, Expanded(child: image), down]),
              top,
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    AnimatedContainer(
                      height: 39,
                      decoration: BoxDecoration(
                        borderRadius:
                            const BorderRadius.all(Radius.circular(20)),
                        border: Border.all(
                          color: isSelected() || index == 0
                              ? Colors.blueAccent
                              : Colors.transparent,
                          width: 2,
                        ),
                      ),
                      duration: duration,
                      child: Row(children: [Expanded(child: mtoNo), viewFile]),
                    ),
                    clientOrderNo,
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
      state.selected = -1;
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
      state.selected = -1;
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
      state.selected = -1;
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
      size = 'production_tasks_size'.tr;
      qty = 'production_tasks_production_qty'.tr;
      productScannedQty = 'production_tasks_auto_scan'.tr;
      manualScannedQty = 'production_tasks_manual_scan'.tr;
      scannedQty = 'production_tasks_total_scan'.tr;
      owe = 'production_tasks_owing_qty'.tr;
      completionRate = 'production_tasks_completion_rate'.tr;
      installedQty = 'production_tasks_packaged_qty'.tr;
      scannedNotInstalled = 'production_tasks_scanned_unpackaged'.tr;
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
            'production_tasks_packing_method'.tr,
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
            'production_tasks_guests_special_requests'.tr,
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
      title: '$functionTitle  <${userInfo?.departmentName}>',
      actions: [
        Container(
          width: 260,
          margin: const EdgeInsets.all(5),
          height: 40,
          child: TextField(
            controller: controller,
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.only(
                top: 0,
                bottom: 0,
                left: 15,
                right: 10,
              ),
              filled: true,
              fillColor: Colors.grey[300],
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
                borderSide: const BorderSide(
                  color: Colors.transparent,
                ),
              ),
              border: const OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(20)),
              ),
              labelText: '国际装箱标准',
              labelStyle: const TextStyle(color: Colors.black54),
              prefixIcon: IconButton(
                onPressed: () => controller.clear(),
                icon: const Icon(
                  Icons.replay_circle_filled,
                  color: Colors.red,
                ),
              ),
              suffixIcon: CombinationButton(
                text: '搜索',
                click: () {
                  hidKeyboard();
                  feishuViewCloudDocFiles(query: controller.text);
                },
              ),
            ),
          ),
        ),
      ],
      body: Padding(
        padding: const EdgeInsets.only(left: 7, right: 7, bottom: 7),
        child: Column(
          children: [
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.blue.shade100, Colors.green.shade50],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                // color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: Colors.blue, width: 2),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Obx(() => textSpan(
                              hint: 'production_tasks_today_target'.tr,
                              text: state.todayTargetQty.value.toShowString(),
                            )),
                        Obx(() => textSpan(
                              hint: 'production_tasks_today_completion'.tr,
                              text: state.todayCompleteQty.value.toShowString(),
                            )),
                        Obx(() => textSpan(
                              hint: 'production_tasks_monthly_completion'.tr,
                              text: state.monthCompleteQty.value.toShowString(),
                            )),
                      ],
                    ),
                  ),
                  Container(
                    height: 35,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(13),
                      border: Border.all(color: Colors.green, width: 2),
                    ),
                    child: IconButton(
                      padding: const EdgeInsets.all(0),
                      onPressed: () =>
                          logic.refreshTable(refresh: () => _refreshTable()),
                      icon: const Icon(
                        Icons.refresh,
                        color: Colors.green,
                      ),
                    ),
                  ),
                ],
              ),
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
                      hint: 'production_tasks_type_body'.tr,
                      text: state.typeBody.value,
                    )),
                Obx(() => expandedTextSpan(
                      hint: 'production_tasks_instruction_no'.tr,
                      text: state.instructionNo.value,
                    )),
                Obx(() => expandedTextSpan(
                      hint: 'production_tasks_customer_po'.tr,
                      text: state.customerPO.value,
                    )),
              ],
            ),
            Row(
              children: [
                Obx(() => expandedTextSpan(
                      hint: 'production_tasks_should_packing_box_qty'.tr,
                      text: state.shouldPackQty.value.toShowString(),
                    )),
                Obx(() => expandedTextSpan(
                      hint: 'production_tasks_packaged_box_qty'.tr,
                      text: state.packagedQty.value.toShowString(),
                    )),
                Obx(() => expandedTextSpan(
                      hint: 'production_tasks_unpackaged_box_qty'.tr,
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
