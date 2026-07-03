import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jd_flutter/bean/home_button.dart';
import 'package:jd_flutter/bean/http/response/production_tasks_info.dart';
import 'package:jd_flutter/utils/mqtt/mqtt.dart';

import 'package:jd_flutter/utils/extension_util.dart';
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
    webSocketServer: state.mqttWebSocketServer,
    webSocketPort: state.mqttWebSocketPort,
    tcpServer: state.mqttTcpServer,
    tcpPort: state.mqttTcpPort,
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
  ) =>
      _ProductionTasksOrderItem(
        data: data,
        animation: animation,
        index: index,
        state: state,
        logic: logic,
        onSelected: (idx) => setState(() => state.selected = idx),
        onMoveUp: (idx) => _moveUpOrderItem(idx),
        onMoveDown: (idx) => _moveDownOrderItem(idx),
        onMoveTop: (idx) => _moveTopOrderItem(idx),
      );

  Widget _orderRemoveItem(
    Animation<double> animation,
  ) =>
      _ProductionTasksOrderRemoveItem(animation: animation);

  AnimatedRemovedItemBuilder getRemovedBuilder(int index) =>
      (BuildContext context, Animation<double> animation) {
        return _orderRemoveItem(animation);
      };

  void _moveUpOrderItem(int index) {
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

  void _moveDownOrderItem(int index) {
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

  void _moveTopOrderItem(int index) {
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

  Widget productionTasksTableTitle() => IntrinsicHeight(
        child: Row(
          children: [
            ExpandedFrameText(
              flex: isPad()?13:14,
              text: '打包区',
              backgroundColor: Colors.blue.shade300,
              textColor: Colors.white,
              isBold: true,
              alignment: Alignment.center,
            ),
            ExpandedFrameText(
              flex: 6,
              text: '产线',
              backgroundColor: Colors.green.shade300,
              textColor: Colors.white,
              isBold: true,
              alignment: Alignment.center,
            ),
          ],
        ),
      );

  Widget productionTasksTableItem({
    WorkCardSizeInfos? data,
    int? type,
  }) {
    var size = '';
    var qty = '';
    var productScannedQty = '';
    var manualScannedQty = '';
    var totalQty = '';
    var packOwe = '';
    var productionOwe = '';
    var completionRate = '';
    var scanTotalQty = '';
    var noFullInstalledQty = '';
    var bkgColor = type != null && type == 1
        ? Colors.blueAccent
        : type == 2
            ? Colors.blue.shade100
            : Colors.white;
    var bkgColor2 = type != null && type == 1
        ? Colors.green
        : type == 2
            ? Colors.green.shade100
            : Colors.white;
    var textColor = type != null && type == 1 ? Colors.white : Colors.black87;
    if (type != null && type == 1) {
      size = 'production_tasks_size'.tr;
      qty = 'production_tasks_production_qty'.tr;
      scanTotalQty = 'production_tasks_scan_total_qty'.tr;
      noFullInstalledQty = 'production_tasks_no_full_installed_qty'.tr;
      totalQty = 'production_tasks_total_qty'.tr;
      packOwe = 'production_tasks_owing_qty'.tr;
      completionRate = 'production_tasks_completion_rate'.tr;
      productScannedQty = 'production_tasks_auto_scan'.tr;
      manualScannedQty = 'production_tasks_manual_scan'.tr;
      productionOwe = 'production_tasks_owing_qty'.tr;
    } else {
      if (type != null && type == 2) {
        data = logic.getTotalItem();
      }
      size = data!.size ?? '';
      qty = data.qty.toShowString();
      scanTotalQty = data.scanTotalQty.toShowString();
      noFullInstalledQty = data.noFullInstalledQty.toShowString();
      totalQty = data.totalQty.toShowString();
      packOwe = data.getPackOwe().toShowString();
      completionRate = data.getCompletionRate();
      productScannedQty = data.productScannedQty.toShowString();
      manualScannedQty = data.manualScannedQty.toShowString();
      productionOwe = data.getProductionOwe().toShowString();
    }
    return IntrinsicHeight(
      child: Row(
        children: [
          ExpandedFrameText(
            flex: isPad() ? 1 : 2,
            maxLines: type == 1 ? 2 : 1,
            text: size,
            backgroundColor: bkgColor,
            textColor: textColor,
            isBold: true,
            alignment: Alignment.center,
          ),
          ExpandedFrameText(
            flex: 2,
            maxLines: type == 1 ? 2 : 1,
            text: qty,
            backgroundColor: bkgColor,
            textColor: textColor,
            isBold: true,
            alignment: Alignment.center,
          ),
          ExpandedFrameText(
            flex: 2,
            maxLines: type == 1 ? 2 : 1,
            text: scanTotalQty,
            backgroundColor: bkgColor,
            textColor: textColor,
            isBold: true,
            alignment: Alignment.center,
          ),
          ExpandedFrameText(
            flex: 2,
            maxLines: type == 1 ? 2 : 1,
            text: noFullInstalledQty,
            backgroundColor: bkgColor,
            textColor: textColor,
            isBold: true,
            alignment: Alignment.center,
          ),
          ExpandedFrameText(
            flex: 2,
            maxLines: type == 1 ? 2 : 1,
            text: totalQty,
            backgroundColor: bkgColor,
            textColor: textColor,
            isBold: true,
            alignment: Alignment.center,
          ),
          ExpandedFrameText(
            flex: 2,
            maxLines: type == 1 ? 2 : 1,
            text: packOwe,
            backgroundColor: bkgColor,
            textColor: textColor,
            isBold: true,
            alignment: Alignment.center,
          ),
          ExpandedFrameText(
            flex: 2,
            maxLines: type == 1 ? 2 : 1,
            text: completionRate,
            backgroundColor: bkgColor,
            textColor: textColor,
            isBold: true,
            alignment: Alignment.center,
          ),
          ExpandedFrameText(
            flex: 2,
            maxLines: type == 1 ? 2 : 1,
            text: productScannedQty,
            backgroundColor: bkgColor2,
            textColor: textColor,
            isBold: true,
            alignment: Alignment.center,
          ),
          ExpandedFrameText(
            flex: 2,
            maxLines: type == 1 ? 2 : 1,
            text: manualScannedQty,
            backgroundColor: bkgColor2,
            textColor: textColor,
            isBold: true,
            alignment: Alignment.center,
          ),
          ExpandedFrameText(
            flex: 2,
            maxLines: type == 1 ? 2 : 1,
            text: productionOwe,
            backgroundColor: bkgColor2,
            textColor: textColor,
            isBold: true,
            alignment: Alignment.center,
          ),
        ],
      ),
    );
  }

  void _refreshTable() {
    setState(() {
      orderListKey.currentState!.removeAllItems((context, animation) {
        return _orderRemoveItem(animation);
      });
      Future.delayed(const Duration(milliseconds: 300), () {
        orderListKey.currentState!.insertAllItems(0, state.orderList.length);
      });
    });
  }

  Widget _packetWay() => _ProductionTasksPacketWay(packetWay: state.packetWay);

  Widget _specificRequirements() => _ProductionTasksSpecificRequirements(
      specificRequirements: state.specificRequirements);

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
    var typeBody = Obx(() => expandedTextSpan(
          flex: isPad() ? 1 : 2,
          hint: 'production_tasks_type_body'.tr,
          text: state.typeBody.value,
        ));
    var instructionNo = Obx(() => expandedTextSpan(
          flex: isPad() ? 1 : 2,
          hint: 'production_tasks_instruction_no'.tr,
          text: state.instructionNo.value,
        ));
    var customerPo = Obx(() => expandedTextSpan(
          flex: isPad() ? 1 : 2,
          hint: 'production_tasks_customer_po'.tr,
          text: state.customerPO.value,
        ));
    var shouldPackingBoxQty = Obx(() => expandedTextSpan(
          hint: 'production_tasks_should_packing_box_qty'.tr,
          text: state.shouldPackQty.value.toShowString(),
        ));
    var packagedBoxQ = Obx(() => expandedTextSpan(
          hint: 'production_tasks_packaged_box_qty'.tr,
          text: state.packagedQty.value.toShowString(),
        ));
    var unpackagedBoxQty = Obx(() => expandedTextSpan(
          hint: 'production_tasks_unpackaged_box_qty'.tr,
          text: state.shouldPackQty.value
              .sub(state.packagedQty.value)
              .toShowString(),
        ));
    var subTitle = isPad()
        ? [
            Row(children: [typeBody, instructionNo, customerPo]),
            Row(children: [
              shouldPackingBoxQty,
              packagedBoxQ,
              unpackagedBoxQty
            ]),
          ]
        : [
            Row(children: [typeBody, shouldPackingBoxQty]),
            Row(children: [instructionNo, packagedBoxQ]),
            Row(children: [customerPo, unpackagedBoxQty]),
          ];
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
        padding: const EdgeInsets.only(left: 7, bottom: 7),
        child: Column(
          children: [
            Obx(() => _DailyTargetHeader(
                  monthCompleteQty: state.monthCompleteQty.value,
                  todayCompleteQty: state.todayCompleteQty.value,
                  todayTargetQty: state.todayTargetQty.value,
                  refresh: () =>
                      logic.refreshTable(refresh: () => _refreshTable()),
                )),
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
            ...subTitle,
            const SizedBox(height: 10),
            productionTasksTableTitle(),
            productionTasksTableItem(type: 1),
            Expanded(
              child: Obx(() {
                final items = <Widget>[
                  for (var item in state.tableInfo)
                    productionTasksTableItem(data: item),
                  if (state.tableInfo.isNotEmpty)
                    productionTasksTableItem(type: 2),
                  if (state.packetWay.isNotEmpty) _packetWay(),
                  if (state.specificRequirements.isNotEmpty)
                    _specificRequirements()
                ];
                return ListView.builder(
                  itemCount: items.length,
                  itemBuilder: (context, index) => items[index],
                );
              }),
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

class _DailyTargetHeader extends StatelessWidget {
  final double monthCompleteQty;
  final double todayCompleteQty;
  final double todayTargetQty;
  final Function() refresh;

  const _DailyTargetHeader({
    required this.monthCompleteQty,
    required this.todayCompleteQty,
    required this.todayTargetQty,
    required this.refresh,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(left: 5, right: 5),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.green.shade300, Colors.blue.shade300],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.28),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: isPad()
          ? const EdgeInsets.only(left: 20, top: 20, right: 10, bottom: 20)
          : const EdgeInsets.only(left: 10, top: 10, right: 5, bottom: 10),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: _MetricItem(
              label: '日目标',
              value: todayTargetQty.toShowString(),
              icon: Icons.flag_rounded,
              color: Colors.white,
            ),
          ),
          _Divider(),
          Expanded(
            flex: 3,
            child: _MetricItem(
              label: '日完成',
              value: todayCompleteQty.toShowString(),
              icon: Icons.check_circle_rounded,
              color: todayTargetQty == todayCompleteQty
                  ? Colors.greenAccent
                  : Colors.white,
              highlight: todayTargetQty == todayCompleteQty,
            ),
          ),
          _Divider(),
          Expanded(
            flex: 3,
            child: _RateItem(
              label: '日达成率',
              rate: todayCompleteQty.div(todayTargetQty).toFixed(2),
              rateStr:
                  '${todayCompleteQty.div(todayTargetQty).mul(100).toFixed(2).toShowString()}%',
              isOver: todayTargetQty == todayCompleteQty,
              accentColor: Colors.greenAccent,
            ),
          ),
          _Divider(),
          Expanded(
            flex: 2,
            child: _MetricItem(
              label: '月完成',
              value: monthCompleteQty.toShowString(),
              icon: Icons.calendar_month_rounded,
              color: Colors.white,
            ),
          ),
          IconButton(
            padding: const EdgeInsets.all(0),
            onPressed: refresh,
            icon: Icon(
              Icons.refresh,
              color: Colors.white,
              size: isPad() ? 40 : 30,
            ),
          ),
        ],
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 52,
      margin: const EdgeInsets.symmetric(horizontal: 8),
      color: Colors.white.withValues(alpha: 0.3),
    );
  }
}

class _MetricItem extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final bool highlight;

  const _MetricItem({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    this.highlight = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 12, color: color.withValues(alpha: 0.7)),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: isPad() ? 14 : 10,
                color: color,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          value,
          style: TextStyle(
            fontSize: isPad() ? 24 : 18,
            fontWeight: FontWeight.w800,
            color: color,
            height: 1.1,
            letterSpacing: -0.4,
          ),
        ),
      ],
    );
  }
}

class _RateItem extends StatelessWidget {
  final String label;
  final double rate;
  final String rateStr;
  final bool isOver;
  final Color accentColor;

  const _RateItem({
    required this.label,
    required this.rate,
    required this.rateStr,
    required this.isOver,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    final progressRate = rate.clamp(0.0, 1.0);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.speed_rounded,
              size: 12,
              color: isOver ? accentColor : Colors.white,
            ),
            const SizedBox(width: 4),
            Text(label,
                style: TextStyle(
                  fontSize: isPad() ? 13 : 10,
                  color: isOver ? accentColor : Colors.white,
                  fontWeight: FontWeight.w500,
                )),
            const Spacer(),
            if (isOver && isPad())
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.25),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  '已达标',
                  style: TextStyle(
                    fontSize: isPad() ? 12 : 10,
                    fontWeight: FontWeight.w700,
                    color: accentColor,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 3),
        Text(
          rateStr,
          style: TextStyle(
            fontSize: isPad() ? 23 : 18,
            fontWeight: FontWeight.w800,
            color: isOver ? accentColor : Colors.white,
            height: 1.1,
            letterSpacing: -0.4,
          ),
        ),
        const SizedBox(height: 3),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: SizedBox(
            height: 5,
            child: LinearProgressIndicator(
              value: progressRate,
              backgroundColor: Colors.white.withValues(alpha: 0.12),
              valueColor: AlwaysStoppedAnimation(
                isOver ? accentColor : Colors.white.withValues(alpha: 0.7),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
/*
Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue.shade50, Colors.white],
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
    );
    */

class _ProductionTasksOrderItem extends StatefulWidget {
  final ProductionTasksSubInfo data;
  final Animation<double> animation;
  final int index;
  final ProductionTasksState state;
  final ProductionTasksLogic logic;
  final ValueSetter<int> onSelected;
  final ValueSetter<int> onMoveUp;
  final ValueSetter<int> onMoveDown;
  final ValueSetter<int> onMoveTop;

  const _ProductionTasksOrderItem({
    required this.data,
    required this.animation,
    required this.index,
    required this.state,
    required this.logic,
    required this.onSelected,
    required this.onMoveUp,
    required this.onMoveDown,
    required this.onMoveTop,
  });

  @override
  State<_ProductionTasksOrderItem> createState() =>
      _ProductionTasksOrderItemState();
}

class _ProductionTasksOrderItemState extends State<_ProductionTasksOrderItem> {
  bool _isSelected() => widget.state.selected == widget.index;

  @override
  Widget build(BuildContext context) {
    var data = widget.data;
    var logic = widget.logic;
    var state = widget.state;
    var index = widget.index;
    var animation = widget.animation;
    var onSelected = widget.onSelected;
    var onMoveUp = widget.onMoveUp;
    var onMoveDown = widget.onMoveDown;
    var onMoveTop = widget.onMoveTop;
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
              : cachedNetworkImage(
                  data.itemImage,
                  fit: BoxFit.fill,
                  errorWidget: errorImage,
                ),
        ),
      ),
    );
    var up = AnimatedOpacity(
      curve: Curves.fastOutSlowIn,
      duration: duration,
      opacity: _isSelected() ? 1 : 0,
      child: AnimatedContainer(
        duration: duration,
        curve: Curves.fastOutSlowIn,
        width: _isSelected() ? 50 : 0,
        height: _isSelected() ? 50 : 0,
        child: IconButton(
          onPressed: () => logic.changeSort(
              oldIndex: index,
              newIndex: index - 1,
              refresh: () => onMoveUp(index)),
          icon: const Icon(
            Icons.arrow_back_ios_rounded,
            color: Colors.blueAccent,
          ),
        ),
      ),
    );
    var down = AnimatedOpacity(
      opacity: _isSelected() && index < state.orderList.length - 1 ? 1 : 0,
      curve: Curves.fastOutSlowIn,
      duration: duration,
      child: AnimatedContainer(
        duration: duration,
        curve: Curves.fastOutSlowIn,
        width: _isSelected() ? 50 : 0,
        height: _isSelected() ? 50 : 0,
        child: IconButton(
          onPressed: () {
            if (index < state.orderList.length - 1) {
              logic.changeSort(
                  oldIndex: index,
                  newIndex: index + 1,
                  refresh: () => onMoveDown(index));
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
      opacity: _isSelected() ? 1 : 0,
      curve: Curves.fastOutSlowIn,
      duration: duration,
      child: AnimatedContainer(
        duration: duration,
        curve: Curves.fastOutSlowIn,
        height: _isSelected() ? 39 : 0,
        child: CombinationButton(
          text: 'production_tasks_top_up'.tr,
          click: () => logic.changeSort(
              oldIndex: index, newIndex: 0, refresh: () => onMoveTop(index)),
        ),
      ),
    );
    var mtoNo = TextButton(
      onPressed: () {
        if (_isSelected() || index == 0) {
          logic.getDetail(
            ins: data.mtoNo ?? '',
            imageUrl: data.itemImage ?? '',
          );
        } else {
          onSelected(index);
        }
      },
      child: Text(
        data.mtoNo ?? '',
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color:
              _isSelected() || index == 0 ? Colors.blueAccent : Colors.black87,
        ),
      ),
    );
    var viewFile = AnimatedOpacity(
      opacity: _isSelected() || index == 0 ? 1 : 0,
      curve: Curves.fastOutSlowIn,
      duration: duration,
      child: AnimatedContainer(
        width: _isSelected() || index == 0 ? 50 : 0,
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
          color: _isSelected() || index == 0
              ? Colors.blueAccent
              : Colors.transparent,
          width: 2,
        ),
      ),
      duration: duration,
      child: TextButton(
        onPressed: () {
          if (_isSelected() || index == 0) {
            logic.getDetail(
              po: data.clientOrderNumber ?? '',
              imageUrl: data.itemImage ?? '',
            );
          } else {
            onSelected(index);
          }
        },
        child: Text(
          data.clientOrderNumber ?? '',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: _isSelected() || index == 0
                ? Colors.blueAccent
                : Colors.black87,
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
            if (_isSelected()) {
              onSelected(-1);
            } else {
              onSelected(index);
            }
          }
        },
        child: AnimatedContainer(
          foregroundDecoration: outBox,
          curve: Curves.fastOutSlowIn,
          margin: const EdgeInsets.only(left: 5, right: 5, top: 10, bottom: 10),
          padding: const EdgeInsets.all(5),
          width: state.selected != 0 && _isSelected() ? 250 : 200,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                index == 0
                    ? Colors.green.shade100
                    : _isSelected()
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
                          color: _isSelected() || index == 0
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
}

class _ProductionTasksOrderRemoveItem extends StatelessWidget {
  final Animation<double> animation;

  const _ProductionTasksOrderRemoveItem({required this.animation});

  @override
  Widget build(BuildContext context) {
    return SizeTransition(
      sizeFactor: animation,
      axis: Axis.horizontal,
      child: Container(
        margin: const EdgeInsets.only(left: 5, right: 5, top: 10, bottom: 10),
        width: 200,
      ),
    );
  }
}

class _ProductionTasksPacketWay extends StatelessWidget {
  final List<String> packetWay;

  const _ProductionTasksPacketWay({required this.packetWay});

  @override
  Widget build(BuildContext context) {
    return Column(
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
              colors: [Colors.blue.shade50, Colors.white],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.blue, width: 2),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [for (var i in packetWay) Text(i)],
          ),
        )
      ],
    );
  }
}

class _ProductionTasksSpecificRequirements extends StatelessWidget {
  final List<String> specificRequirements;

  const _ProductionTasksSpecificRequirements(
      {required this.specificRequirements});

  @override
  Widget build(BuildContext context) {
    return Column(
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
              colors: [Colors.blue.shade50, Colors.white],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.blue, width: 2),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [for (var i in specificRequirements) Text(i)],
          ),
        )
      ],
    );
  }
}
