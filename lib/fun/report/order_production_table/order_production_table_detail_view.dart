import 'package:audioplayers/audioplayers.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:jd_flutter/utils/app_init.dart';
import 'package:jd_flutter/utils/extension_util.dart';
import 'package:rotated_corner_decoration/rotated_corner_decoration.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/src/extension_instance.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';
import 'package:jd_flutter/bean/http/response/carton_label_scan_clear_tail_info.dart';
import 'package:jd_flutter/fun/report/order_production_table/order_production_table_logic.dart';
import 'package:jd_flutter/fun/report/order_production_table/order_production_table_state.dart';
import 'package:jd_flutter/widget/custom_widget.dart';
import 'package:jd_flutter/widget/scanner.dart';

class OrderProductionTableDetailPage extends StatefulWidget {
  const OrderProductionTableDetailPage({super.key});

  @override
  State<OrderProductionTableDetailPage> createState() =>
      _OrderProductionTableDetailPageState();
}

class _OrderProductionTableDetailPageState
    extends State<OrderProductionTableDetailPage> {
  final OrderProductionTableLogic logic = Get.find<OrderProductionTableLogic>();
  final OrderProductionTableState state =
      Get.find<OrderProductionTableLogic>().state;

  late AudioPlayer player;
  var ae1 = 'audios/audio_error1.mp3'; // 错误
  var as1 = 'audios/audio_success1.mp3'; // 成功

  void playAudio(String as) {
    if ((deviceInfo() as AndroidDeviceInfo).version.release.toDoubleTry() >=
        8) {
      if (player.state != PlayerState.completed) {
        player.stop();
        player.setSource(AssetSource(as));
        player.resume();
      } else {
        player.play(AssetSource(as));
      }
    }
  }

  void scan() {
    pdaScanner(scan: (barCode) {
      if (barCode.isNotEmpty) {
        logic.addUnFull(
            code: barCode,
            fullError: () {
              playAudio(ae1);
            },
            addSuccess: () {
              playAudio(as1);
            });
      }
      ;
    });
  }

  Widget _item(ClearTailListInfo data) {
    bool isTotal = data.size == 'carton_label_scan_order_total'.tr;
    return Row(
      children: [
        item(data.size ?? '', true, isTotal: isTotal),
        item(data.orderQty.toString(), true, isTotal: isTotal),
        item(data.fullBoxQty.toString(), true, isTotal: isTotal),
        item((data.unFullBoxQty! + data.thisScanQty!).toString(), true,
            isTotal: isTotal),
        item((data.unFullBoxQty! + data.fullBoxQty!).toString(), true,
            isTotal: isTotal),
        // 欠数列：与其它列同款格子，仅文字显示为红色
        item(data.arrears.toString(), true,
            isTotal: isTotal, textColor: isTotal ? null : Colors.red),
      ],
    );
  }

  Widget item(String text, bool isSub,
          {bool isTotal = false, Color? textColor}) =>
      ExpandedFrameText(
        text: text,
        borderColor: Colors.blue,
        alignment: Alignment.center,
        isBold: !isSub,
        textColor: textColor ??
            (isTotal
                ? Colors.white
                : (isSub ? Colors.black : Colors.blue.shade700)),
        backgroundColor: isTotal
            ? Colors.blue.shade800
            : (isSub ? Colors.white : Colors.grey.shade300),
      );

  @override
  Widget build(BuildContext context) {
    return pageBody(
      title: 'carton_label_scan_order_size_detail'.tr,
      body: Padding(
        padding:
            const EdgeInsets.only(left: 10, right: 10, bottom: 10, top: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 顶部信息卡片（含"生产中"角标）
            _buildInfoCard(),
            const SizedBox(height: 10),
            // 表格标题栏
            _buildTableTitle(),
            const SizedBox(height: 5),
            // 表头
            Row(
              children: [
                item('carton_label_scan_order_size'.tr, false),
                item('carton_label_scan_order_quality'.tr, false),
                item('carton_label_scan_order_full_box'.tr, false),
                item('carton_label_scan_order_not_full_box'.tr, false),
                item('carton_label_scan_order_completed_quantity'.tr, false),
                item('carton_label_scan_order_arrears'.tr, false),
              ],
            ),
            // 尺码数据列表
            Expanded(
              child: Obx(
                () => ListView.builder(
                  itemCount: state.reportBoxList.length,
                  itemBuilder: (context, index) =>
                      _item(state.reportBoxList[index]),
                ),
              ),
            ),
            const SizedBox(height: 10),
            // 底部按钮
            if (state.searcherData?.isNeedInnerBoxLabel == false)
              _buildBottomButtons(),
          ],
        ),
      ),
    );
  }

  // 顶部信息卡片（白底圆角 + 右上角"生产中"角标）
  Widget _buildInfoCard() {
    return Obx(
      () => Container(
        foregroundDecoration: RotatedCornerDecoration.withColor(
          color: Colors.blue,
          badgeCornerRadius: const Radius.circular(8),
          badgeSize: const Size(60, 60),
          textSpan: TextSpan(
            text: 'carton_label_scan_in_production'.tr,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.white,
            ),
          ),
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        padding: const EdgeInsets.only(left: 8, top: 5, right: 8, bottom: 5),
        child: Column(
          children: [
            _infoGridRow(
              icon: '🏭',
              label: 'carton_label_scan_factory_model'.tr,
              value: state.factoryBody.value,
              valueColor: Colors.blue.shade700,
              icon2: '📋',
              label2: 'carton_label_scan_sales_order'.tr,
              value2: state.salesOrder.value,
              valueColor2: Colors.green.shade600,
            ),
            _infoGridRow(
              icon: '👷',
              label: 'carton_label_scan_current_group_title'.tr,
              value: state.groupName.value,
              valueColor: Colors.blue.shade700,
              icon2: '✏️',
              label2: 'carton_label_scan_work_order_no'.tr,
              value2: state.showDispatchNumber.value,
              valueColor2: Colors.green.shade600,
            ),
            _infoGridRow(
              icon: '📄',
              label: 'carton_label_scan_customer_order_no'.tr,
              value: state.customerOrderNumber.value,
              valueColor: Colors.blue.shade700,
              icon2: '📦',
              label2: 'carton_label_scan_brand'.tr,
              value2: state.searcherData!.band ?? '',
              valueColor2: Colors.green.shade600,
            ),
          ],
        ),
      ),
    );
  }

  /// 信息网格行：左右各一个字段（icon + 标签 + 值）
  Widget _infoGridRow({
    required String icon,
    required String label,
    required String value,
    required Color valueColor,
    required String icon2,
    required String label2,
    required String value2,
    required Color valueColor2,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
              child: _infoCell(
                  icon: icon,
                  label: label,
                  value: value,
                  valueColor: valueColor)),
          const SizedBox(width: 16),
          Expanded(
              child: _infoCell(
                  icon: icon2,
                  label: label2,
                  value: value2,
                  valueColor: valueColor2)),
        ],
      ),
    );
  }

  /// 单个信息格子：图标+标签一行 + 值一行
  Widget _infoCell({
    required String icon,
    required String label,
    required String value,
    required Color valueColor,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            Text(icon, style: const TextStyle(fontSize: 13)),
            const SizedBox(width: 3),
            Text(label,
                style: TextStyle(color: Colors.grey.shade600, fontSize: 11)),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
              color: valueColor, fontSize: 14, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  // 表格标题栏：蓝竖条 + "尺码明细" + 右侧"单位：双"
  Widget _buildTableTitle() {
    return Row(
      children: [
        Container(width: 3, height: 16, color: Colors.blue),
        const SizedBox(width: 6),
        Text(
          'carton_label_scan_size_detail'.tr,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const Spacer(),
        Text(
          'carton_label_scan_unit_pair'.tr,
          style: const TextStyle(fontSize: 14, color: Colors.black87),
        ),
      ],
    );
  }

  // 底部两个按钮：尾数重置 / 尾数提交
  Widget _buildBottomButtons() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () => logic.resetTailNumber(),
            icon: const Icon(Icons.refresh, size: 16),
            label:  Text('carton_label_scan_remain_reset'.tr),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () => logic.submitTailNumber(),
            icon: const Icon(Icons.upload_outlined, size: 16),
            label:  Text('carton_label_scan_remain_submit'.tr),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  void initState() {
    if ((deviceInfo() as AndroidDeviceInfo).version.release.toDoubleTry() >=
        8) {
      player = AudioPlayer();
    }
    if (state.searcherData?.isNeedInnerBoxLabel == false) {
      scan();
    }
    super.initState();
  }

  @override
  void dispose() {
    player.dispose();
    super.dispose();
  }
}
