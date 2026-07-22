import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/src/extension_instance.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';
import 'package:jd_flutter/bean/http/response/order_production_execution_info.dart';
import 'package:jd_flutter/fun/report/order_production_table/order_production_table_logic.dart';
import 'package:jd_flutter/fun/report/order_production_table/order_production_table_state.dart';
import 'package:jd_flutter/widget/custom_widget.dart';
import 'package:jd_flutter/widget/dialogs.dart';
import 'package:jd_flutter/widget/edit_text_widget.dart';
import 'package:jd_flutter/widget/picker/picker_view.dart';
import 'package:jd_flutter/widget/spinner_widget.dart';
import 'package:jd_flutter/widget/switch_button_widget.dart';

class OrderProductionTablePage extends StatefulWidget {
  const OrderProductionTablePage({super.key});

  @override
  State<OrderProductionTablePage> createState() =>
      _OrderProductionTablePageState();
}

class _OrderProductionTablePageState extends State<OrderProductionTablePage> {
  final OrderProductionTableLogic logic = Get.put(OrderProductionTableLogic());
  final OrderProductionTableState state =
      Get.find<OrderProductionTableLogic>().state;

  late SpinnerController spinnerController2; //全部线别

  var style = const TextStyle(color: Color(0xFF333333), fontSize: 13);
  var textStyle = const TextStyle(
    color: Color(0xFF1967D2),
    fontSize: 13,
    fontWeight: FontWeight.w500,
  );

  // 每个 Tab 的主题色
  static const List<Color> _tabColors = [
    Color(0xFF7B8794), // 未生产 - 灰蓝
    Color(0xFF1967D2), // 在生产 - 蓝
    Color(0xFFF2994A), // 待清尾 - 橙
    Color(0xFF27AE60), // 已完成 - 绿
  ];

  // 单选状态 Tab 按钮（调用处已用 Expanded 包裹，这里不要再返回 Expanded）
  // 数量 count 在内部 Obx 中按 index 读取对应的响应式变量，保证加载/切换时实时刷新
  Widget _statusTabButton(int index, String label) {
    return Obx(() {
      bool selected = state.selectedTabIndex.value == index;
      Color accent = _tabColors[index];
      // 根据 index 读取对应状态数量（响应式）
      String count;
      switch (index) {
        case 0:
          count = state.notProduced.value;
          break;
        case 1:
          count = state.inProduction.value;
          break;
        case 2:
          count = state.waitingClearTail.value;
          break;
        case 3:
        default:
          count = state.completed.value;
          break;
      }
      // 数量超过 99 时，隐藏前面的状态圆点，给更宽的数字腾出空间
      final int? countNum = int.tryParse(count);
      final bool hideFrontSymbol = countNum != null && countNum > 99;

      return GestureDetector(
        onTap: () {
          state.selectedTabIndex.value = index;
          logic.selectShow();
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
          decoration: BoxDecoration(
            gradient: selected
                ? LinearGradient(
                    colors: [accent, accent.withValues(alpha: 0.75)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                : null,
            color: selected ? null : Colors.white,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
              color: selected ? accent : const Color(0xFFE5E9F0),
              width: 1,
            ),
            boxShadow: selected
                ? [
                    BoxShadow(
                      color: accent.withValues(alpha: 0.35),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    )
                  ]
                : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 状态小圆点（数量 > 99 时隐藏，给数字腾空间）
              if (!hideFrontSymbol)
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: selected ? Colors.white : accent,
                    shape: BoxShape.circle,
                  ),
                ),
              if (!hideFrontSymbol) const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  color: selected ? Colors.white : const Color(0xFF333333),
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 4),
              // 数字区域：显示真实数量；空间不足时自动等比缩小，避免溢出
              Flexible(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    count,
                    style: TextStyle(
                      color: selected
                          ? Colors.white
                          : (count.isEmpty ? const Color(0xFFB0B7C3) : accent),
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  // ===== 卡片左边框颜色：按 searchType 匹配 =====
  static const List<Color> _cardBorderColors = [
    Color(0xFFE53935), // 待办 - 红
    Color(0xFFF2994A), // 生产中 - 橙
    Color(0xFFE53935), // 待清尾 - 红
    Color(0xFFF06292), // 已办 - 粉
  ];

  // ===== 主卡片组件（根据 searchType 渲染不同布局）=====
  Widget _item(OrderProductionExecutionInfo item) {
    int type = item.status ?? 1;
    // status 是 1 基（1,2,3,4），颜色数组是 0 基，故 -1 取索引
    Color accent = _cardBorderColors[(type - 1).clamp(0, 3)];

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFEEEEEE), width: 1),
        boxShadow: const [
          BoxShadow(
            color: Color(0x08000000),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Stack(
        children: [
          // 左侧彩色强调条
          Positioned(
            left: 0,
            top: 0,
            bottom: 0,
            child: Container(
              width: 4,
              decoration: BoxDecoration(
                color: accent,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  bottomLeft: Radius.circular(12),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 顶部信息栏：产品编号 | 颜色 | 尺码 | DHM标签
                _buildTopBar(item),
                const SizedBox(height: 6),
                // 订单号（大标题）
                Text(
                  item.seOrderNo ?? '',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1A1A2E),
                  ),
                ),
                const SizedBox(height: 6),
                // 虚线分隔
                Container(
                  height: 1,
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    border: Border.all(
                        color: const Color(0xFFE0E0E0),
                        style: BorderStyle.solid),
                  ),
                ),
                const SizedBox(height: 8),
                // 按 searchType 渲染不同内容区
                _buildCardContent(item, type, accent),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ===== 顶部信息栏：产品编号badge | 颜色 | 尺码 | 部门标签 =====
  Widget _buildTopBar(OrderProductionExecutionInfo item) {
    return Row(
      children: [
        // 产品编号 badge
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: const Color(0xFF1565C0),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Text(
            item.productName ?? '',
            style: const TextStyle(
                color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
          ),
        ),
        const SizedBox(width: 8),
        // 颜色
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.palette_outlined,
                    size: 14, color: Colors.green),
                const SizedBox(width: 3),
                Text(item.color ?? '',
                    style: const TextStyle(
                        fontSize: 12, color: Color(0xFF555555))),
              ],
            ),
            const SizedBox(width: 8),
            // 尺码
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Transform.rotate(
                  angle: 0.4,
                  child: const Icon(Icons.straighten_outlined,
                      size: 14, color: Color(0xFF5C6BC0)),
                ),
                const SizedBox(width: 3),
                Text(item.sizeRange ?? '',
                    style: const TextStyle(
                        fontSize: 12, color: Color(0xFF555555))),
              ],
            ),
          ],
        ),
        const Spacer(),
        // DHM 标签
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: const Color(0xFF27AE60),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Text(
            item.band ?? '',
            style: const TextStyle(
                color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }

  // ===== 根据 searchType 分发到对应的内容布局 =====
  Widget _buildCardContent(
      OrderProductionExecutionInfo item, int type, Color accent) {
    switch (type) {
      case 1:
        return _buildPendingContent(item, accent);
      case 2:
        return _buildProducingContent(item, accent);
      case 3:
        return _buildClearTailContent(item, accent);
      case 4:
        return _buildCompletedContent(item, accent);
      default:
        return _buildPendingContent(item, accent);
    }
  }

  // ===== 日期状态标签 =====
  Widget _buildDateBadge(String dateStr, int? daysDifference) {
    if (daysDifference == null) {
      return Text(dateStr,
          style: const TextStyle(fontSize: 13, color: Color(0xFF555555)));
    }

    final diff = daysDifference;
    String label;
    Color bgColor;
    Color dotColor;

    if (diff < 0) {
      label = '已超${diff.abs()}天';
      bgColor = const Color(0xFFFFEBEE);
      dotColor = const Color(0xFFE53935);
    } else if (diff == 0) {
      label = 'carton_label_scan_due_today'.tr;
      bgColor = const Color(0xFFFFF3E0);
      dotColor = const Color(0xFFF2994A);
    } else if (diff <= 3) {
      label = '剩$diff天';
      bgColor = const Color(0xFFFFF3E0);
      dotColor = const Color(0xFFF2994A);
    } else {
      label = '剩$diff天';
      bgColor = const Color(0xFFF5F5F5);
      dotColor = const Color(0xFF9E9E9E);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
          color: bgColor, borderRadius: BorderRadius.circular(16)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
              width: 7,
              height: 7,
              decoration:
                  BoxDecoration(color: dotColor, shape: BoxShape.circle)),
          const SizedBox(width: 6),
          Text('$dateStr $label',
              style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: dotColor)),
        ],
      ),
    );
  }

  // ===== 进度条组件 =====
  Widget _buildProgressBar(double ratio,
      {Color barColor = const Color(0xFFF2994A)}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
                value: ratio.clamp(0.0, 1.0),
                minHeight: 8,
                backgroundColor: const Color(0xFFF0F0F0),
                valueColor: AlwaysStoppedAnimation<Color>(barColor))),
      ],
    );
  }

  // ===== Type 0：待办 布局 =====
  Widget _buildPendingContent(OrderProductionExecutionInfo item, Color accent) {
    final qty = (item.seOrderQty ?? 0).toInt();
    return Column(
      children: [
        // 订单数量（右对齐大字）
        Row(children: [
          const Icon(Icons.inventory_2_outlined,
              size: 16, color: Color(0xFF1976D2)),
          const SizedBox(width: 6),
          Text('carton_label_scan_order_qty'.tr,
              style: const TextStyle(fontSize: 13, color: Color(0xFF666666))),
          const Spacer(),
          Text('$qty${'carton_label_scan_pair'.tr}',
              style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A1A2E)))
        ]),
        const SizedBox(height: 6),
        // 计划完工日期 + 日期标签
        Row(children: [
          const Icon(Icons.calendar_today, size: 16, color: Color(0xFFF2994A)),
          const SizedBox(width: 6),
          Text('carton_label_scan_plan_finish_date'.tr,
              style: const TextStyle(fontSize: 13, color: Color(0xFF666666))),
          const Spacer(),
          _buildDateBadge(item.planEndDate ?? '', item.daysDifference)
        ]),
        const SizedBox(height: 6),
        // 产线
        Row(children: [
          const Icon(Icons.factory, size: 16, color: Color(0xFF009688)),
          const SizedBox(width: 6),
          Text('carton_label_scan_production_line'.tr,
              style: const TextStyle(fontSize: 13, color: Color(0xFF666666))),
          const Spacer(),
          Text(item.departmentName ?? '',
              style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF333333)))
        ]),
      ],
    );
  }

  // ===== Type 1：生产中 布局 =====
  Widget _buildProducingContent(
      OrderProductionExecutionInfo item, Color accent) {
    final orderQty = (item.seOrderQty ?? 0).toInt();
    final doneQty = (item.scanQty ?? 0).toInt();
    final ratio = orderQty > 0 ? doneQty / orderQty : 0.0;
    // 订单次数量
    final pendingCount = (orderQty - doneQty).clamp(0, 99999);

    return Column(
      children: [
        // 订单数 / 完工数
        Row(children: [
          const Icon(Icons.bar_chart, size: 16, color: Color(0xFF1976D2)),
          const SizedBox(width: 6),
          Text('carton_label_scan_order_complete_qty'.tr,
              style: const TextStyle(fontSize: 13, color: Color(0xFF666666))),
          const Spacer(),
          Text('$orderQty / $doneQty ${'carton_label_scan_pair'.tr}',
              style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1A1A2E)))
        ]),
        const SizedBox(height: 6),
        // 订单次数量（红色醒目大字）
        Row(children: [
          const Icon(Icons.show_chart, size: 16, color: Color(0xFFE53935)),
          const SizedBox(width: 6),
          Text('carton_label_scan_order_owe_qty'.tr,
              style: const TextStyle(fontSize: 13, color: Color(0xFF666666))),
          const Spacer(),
          Text('$pendingCount${'carton_label_scan_pair'.tr}',
              style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFE53935)))
        ]),
        const SizedBox(height: 6),
        // 进度条 + 百分比
        Row(children: [
          Expanded(
              child:
                  _buildProgressBar(ratio, barColor: const Color(0xFFF2994A))),
          const SizedBox(width: 10),
          Text('${(ratio * 100).toStringAsFixed(1)}%',
              style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFF2994A)))
        ]),
        const SizedBox(height: 6),
        // 计划完工日期 + 日期标签
        Row(children: [
          const Icon(Icons.calendar_today, size: 16, color: Color(0xFFF2994A)),
          const SizedBox(width: 6),
          Text('carton_label_scan_plan_finish_date'.tr,
              style: const TextStyle(fontSize: 13, color: Color(0xFF666666))),
          const Spacer(),
          _buildDateBadge(item.fetchDate ?? '', item.daysDifference)
        ]),
        const SizedBox(height: 8),
        // 底部按钮行：待确认 | 详情 | 清尾确认
        Row(
          children: [
            Expanded(
                flex: 3,
                child: Material(
                    color: Colors.transparent,
                    child: Container(
                        alignment: Alignment.center,
                        padding: const EdgeInsets.symmetric(vertical: 9),
                        child: Row(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                  width: 8,
                                  height: 8,
                                  decoration: const BoxDecoration(
                                      color: Color(0xFFF2994A),
                                      shape: BoxShape.circle)),
                              const SizedBox(width: 6),
                              Text('carton_label_scan_wait_confirm'.tr,
                                  style: const TextStyle(
                                      color: Color(0xFFF2994A),
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600))
                            ])))),
            const SizedBox(width: 10),
            Expanded(
                flex: 3,
                child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                        onTap: () => logic.getDetail(item),
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                            alignment: Alignment.center,
                            padding: const EdgeInsets.symmetric(vertical: 9),
                            decoration: BoxDecoration(
                                border: Border.all(
                                    color: const Color(0xFF1976D2), width: 1.5),
                                borderRadius: BorderRadius.circular(20)),
                            child: Row(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.description_outlined,
                                      size: 15, color: Color(0xFF1976D2)),
                                  const SizedBox(width: 6),
                                  Text('carton_label_scan_detail'.tr,
                                      style: const TextStyle(
                                          color: Color(0xFF1976D2),
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600))
                                ]))))),
            const SizedBox(width: 10),
            Expanded(
                flex: 4,
                child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                        onTap: () {
                          askDialog(
                              content:
                                  'carton_label_scan_confirm_clear_tail_tip'.tr,
                              confirm: () {
                                logic.confirmTailCartonRecords(item, true);
                              });
                        },
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                            alignment: Alignment.center,
                            padding: const EdgeInsets.symmetric(vertical: 9),
                            decoration: BoxDecoration(
                                color: const Color(0xFF1976D2),
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                      color: const Color(0xFF1976D2)
                                          .withValues(alpha: 0.25),
                                      blurRadius: 6)
                                ]),
                            child: Row(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.check_circle_outline,
                                      size: 15, color: Colors.white),
                                  const SizedBox(width: 6),
                                  Text(
                                      'carton_label_scan_clear_tail_confirm'.tr,
                                      style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600))
                                ]))))),
          ],
        ),
      ],
    );
  }

  // ===== Type 2：待清尾 布局 =====
  Widget _buildClearTailContent(
      OrderProductionExecutionInfo item, Color accent) {
    final orderQty = (item.seOrderQty ?? 0).toInt();
    final doneQty = (item.scanQty ?? 0).toInt();
    final ratio = orderQty > 0 ? doneQty / orderQty : 0.0;
    // 待清尾 = 订单 - 完工（示例逻辑，实际按业务定）
    final tailQty = (orderQty - doneQty).clamp(0, 99999);

    return Column(
      children: [
        // 订单数 / 完工数
        Row(children: [
          const Icon(Icons.bar_chart, size: 16, color: Color(0xFF1976D2)),
          const SizedBox(width: 6),
          Text('carton_label_scan_order_complete_qty'.tr,
              style: const TextStyle(fontSize: 13, color: Color(0xFF666666))),
          const Spacer(),
          Text('$orderQty / $doneQty${'carton_label_scan_pair'.tr}',
              style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1A1A2E)))
        ]),
        const SizedBox(height: 6),
        // 待清尾数量（红色醒目）
        Row(children: [
          const Icon(Icons.warning_amber_rounded,
              size: 16, color: Color(0xFFE53935)),
          const SizedBox(width: 6),
          Text('carton_label_scan_wait_clear_tail'.tr,
              style: const TextStyle(fontSize: 13, color: Color(0xFF666666))),
          const Spacer(),
          Text('$tailQty${'carton_label_scan_pair'.tr}',
              style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFE53935)))
        ]),
        const SizedBox(height: 6),
        // 绿色进度条 + 百分比
        Row(children: [
          Expanded(
              child:
                  _buildProgressBar(ratio, barColor: const Color(0xFF27AE60))),
          const SizedBox(width: 10),
          Text('${(ratio * 100).toStringAsFixed(1)}%',
              style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF27AE60)))
        ]),
        const SizedBox(height: 6),
        // 尾数原因
        Row(children: [
          const Icon(Icons.edit_note, size: 16, color: Color(0xFFF9A825)),
          const SizedBox(width: 6),
          Text('carton_label_scan_wait_rework'.tr,
              style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF333333)))
        ]),
        const SizedBox(height: 6),
        // 计划完工日期 + 日期标签
        Row(children: [
          const Icon(Icons.calendar_today, size: 16, color: Color(0xFFF2994A)),
          const SizedBox(width: 6),
          Text('carton_label_scan_plan_finish_date'.tr,
              style: const TextStyle(fontSize: 13, color: Color(0xFF666666))),
          const Spacer(),
          _buildDateBadge(item.fetchDate ?? '', item.daysDifference)
        ]),
        const SizedBox(height: 8),
        // 底部按钮：取消清尾确认
        Align(
          alignment: Alignment.centerRight,
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                askDialog(
                    content: 'carton_label_scan_cancel_clear_tail_tip'.tr,
                    confirm: () {
                      logic.confirmTailCartonRecords(item, false);
                    });
              },
              borderRadius: BorderRadius.circular(20),
              child: Container(
                alignment: Alignment.center,
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 9),
                decoration: BoxDecoration(
                  border:
                      Border.all(color: const Color(0xFFF2994A), width: 1.5),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  const Icon(Icons.close, size: 15, color: Color(0xFFF2994A)),
                  const SizedBox(width: 6),
                  Text('carton_label_scan_cancel_clear_tail_confirm'.tr,
                      style: const TextStyle(
                          color: Color(0xFFF2994A),
                          fontSize: 14,
                          fontWeight: FontWeight.w600)),
                ]),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ===== Type 3：已办 布局 =====
  Widget _buildCompletedContent(
      OrderProductionExecutionInfo item, Color accent) {
    final orderQty = (item.seOrderQty ?? 0).toInt();
    final doneQty = (item.scanQty ?? 0).toInt();

    return Column(
      children: [
        // 订单数 / 完工数
        Row(children: [
          const Icon(Icons.bar_chart, size: 16, color: Color(0xFF1976D2)),
          const SizedBox(width: 6),
          Text('carton_label_scan_order_complete_qty'.tr,
              style: const TextStyle(fontSize: 13, color: Color(0xFF666666))),
          const Spacer(),
          Text('$orderQty / $doneQty${'carton_label_scan_pair'.tr}',
              style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1A1A2E)))
        ]),
        const SizedBox(height: 6),
        // 产线
        Row(children: [
          const Icon(Icons.factory, size: 16, color: Color(0xFF009688)),
          const SizedBox(width: 6),
           Text('carton_label_scan_production_line'.tr,
              style: const TextStyle(fontSize: 13, color: Color(0xFF666666))),
          const Spacer(),
          Text(item.departmentName ?? '',
              style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF333333)))
        ]),
        const SizedBox(height: 6),
        // 结案日期
        Row(children: [
          const Icon(Icons.check_circle_outline,
              size: 16, color: Color(0xFF27AE60)),
          const SizedBox(width: 6),
          Text('carton_label_scan_case_close_date'.tr,
              style: const TextStyle(fontSize: 13, color: Color(0xFF666666))),
          const Spacer(),
          Text(item.lastDate ?? '',
              style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF333333)))
        ]),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return pageBodyWithDrawer(
        actions: [],
        body: Column(
          children: [
            // 搜索框（按指令号 / 派工单号 搜索当前 Tab 下的内容）
            Padding(
              padding: const EdgeInsets.all(4),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFE5E9F0)),
                ),
                child: TextField(
                  controller: state.searchTec,
                  onChanged: (v) {
                    state.searchKey.value = v;
                    logic.selectShow();
                  },
                  style: const TextStyle(fontSize: 13),
                  decoration: InputDecoration(
                    isDense: true,
                    isCollapsed: true,
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                    hintText: 'carton_label_scan_search_instruction_no'.tr,
                    hintStyle:
                        const TextStyle(color: Color(0xFF999999), fontSize: 13),
                    prefixIcon: const Icon(Icons.search,
                        size: 18, color: Color(0xFF999999)),
                    prefixIconConstraints:
                        const BoxConstraints(minWidth: 34, minHeight: 0),
                    border: InputBorder.none,
                  ),
                ),
              ),
            ),
            // 4 个状态 Tab 按钮（单选）
            Padding(
              padding: const EdgeInsets.all(5),
              child: Row(
                children: [
                  Expanded(
                    child: _statusTabButton(0, 'carton_label_scan_todo'.tr),
                  ),
                  const SizedBox(width: 5),
                  Expanded(
                    child: _statusTabButton(1, 'carton_label_scan_produce'.tr),
                  ),
                  const SizedBox(width: 5),
                  Expanded(
                    child:
                        _statusTabButton(2, 'carton_label_scan_clear_tail'.tr),
                  ),
                  const SizedBox(width: 5),
                  Expanded(
                    child: _statusTabButton(3, 'carton_label_scan_done'.tr),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 5),
              child: Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: const Color(0xFFE5E9F0)),
                ),
                child: Obx(() => Text(state.message.value)),
              ),
            ),
            Expanded(
              child: Obx(
                () => ListView.builder(
                  itemCount: state.tailNumberList.length,
                  itemBuilder: (context, index) =>
                      _item(state.tailNumberList[index]),
                ),
              ),
            ),
          ],
        ),
        queryWidgets: [
          EditText(
            hint: 'carton_label_scan_order_input_command'.tr,
            controller: state.tecCommand,
          ),
          DatePicker(pickerController: state.startDate),
          DatePicker(pickerController: state.endDate),
          SizedBox(child: Spinner(controller: spinnerController2)),
          Obx(
            () => SwitchButton(
              onChanged: (s) {
                state.type.value = s;
              },
              name: state.type.value == true
                  ? 'carton_label_scan_order_dispatch_date'.tr
                  : 'carton_label_scan_order_delivery_time'.tr,
              value: state.type.value,
            ),
          )
        ],
        query: () {
          logic.queryOrderList(
            success: () {
              setState(() {
                logic.selectShow();
                spinnerController2 = SpinnerController(
                    dataList: state.lineList,
                    onChanged: (index) {
                      state.selectIndex = index;
                      logic.selectShow();
                    });
              });
            },
          );
        });
  }

  @override
  void dispose() {
    Get.delete<OrderProductionTableLogic>();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    spinnerController2 =
        SpinnerController(dataList: ['carton_label_scan_order_all_lines'.tr]);
  }
}
