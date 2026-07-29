import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/src/extension_instance.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';
import 'package:jd_flutter/bean/http/response/order_production_execution_info.dart';
import 'package:jd_flutter/fun/report/order_production_table/order_production_table_logic.dart';
import 'package:jd_flutter/fun/report/order_production_table/order_production_table_state.dart';
import 'package:jd_flutter/widget/custom_widget.dart';
import 'package:jd_flutter/widget/dialogs.dart';
import 'package:jd_flutter/widget/edit_text_widget.dart';
import 'package:jd_flutter/widget/picker/picker_view.dart';
import 'package:jd_flutter/widget/scanner.dart';
import 'package:jd_flutter/widget/spinner_widget.dart';
import 'package:jd_flutter/widget/switch_button_widget.dart';
import 'order_production_table_detail_view.dart';
import 'order_production_table_tail_clean_view.dart';

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

  // ===== 统一视觉规范（配色 / 圆角）=====
  static const Color _primary = Color(0xFF1976D2); // 主色蓝
  static const Color _bg = Color(0xFFF4F6F9); // 页面背景灰
  static const Color _textPrimary = Color(0xFF1F2733);
  static const Color _textSecondary = Color(0xFF707A89);
  static const Color _border = Color(0xFFE5E9F0);

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
                    colors: [accent, accent.withOpacity(0.75)],
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
                      color: accent.withOpacity(0.35),
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

  // 搜索框右侧「跳转」按钮（样式已设计好，点击事件由你自己实现）
  Widget _jumpButton() {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: () {
          Get.to(() => const OrderProductionTableTailCleanPage())?.then((v) {
            _scan();
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF1976D2), Color(0xFF42A5F5)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(12),
            boxShadow: const [
              BoxShadow(
                // 用十六进制 alpha（0x40≈25%）代替 withOpacity，避免弃用提示
                color: Color(0x401976D2),
                blurRadius: 6,
                offset: Offset(0, 3),
              ),
            ],
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.published_with_changes_sharp,
                  size: 14, color: Colors.white),
              SizedBox(width: 6),
              Text(
                '外箱清尾',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
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
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _border, width: 1),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0D000000),
            blurRadius: 10,
            offset: Offset(0, 3),
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
                  topLeft: Radius.circular(10),
                  bottomLeft: Radius.circular(10),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 4, 12, 2),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 第一行：订单号（大标题）+ 品牌标签
                Row(
                  children: [
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        item.seOrderNo ?? '',
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1A1A2E),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    // 品牌标签 + 下方单位
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: item.band == 'DHM'
                                ? const Color(0xFF27AE60)
                                : const Color(0xFFE53935),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Text(
                            item.band ?? '',
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w600),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                // 顶部信息栏：产品编号 | 颜色 | 尺码 | DHM标签（随订单号下移）
                _buildTopBar(item),
                const SizedBox(height: 4),
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
                const SizedBox(height: 4),
                // 按 searchType 渲染不同内容区
                _buildCardContent(item, type, accent),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ===== 顶部信息栏：产品编号 badge | 颜色 | 尺码 | 工厂标签 =====
  Widget _buildTopBar(OrderProductionExecutionInfo item) {
    return Row(
      children: [
        // 产品编号 badge
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: _primary,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            item.productName ?? '',
            style: const TextStyle(
                color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
          ),
        ),
        const SizedBox(width: 10),
        // 颜色 + 尺码（纵向排列，恢复语义色图标）
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                children: [
                  const Icon(Icons.palette_outlined,
                      size: 14, color: Colors.green),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(item.color ?? '',
                        style: const TextStyle(
                            fontSize: 12, color: Color(0xFF555555)),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis),
                  ),
                ],
              ),
              Row(
                children: [
                  Transform.rotate(
                    angle: 0.4,
                    child: const Icon(Icons.straighten_outlined,
                        size: 14, color: Color(0xFF5C6BC0)),
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(item.sizeRange ?? '',
                        style: const TextStyle(
                            fontSize: 12, color: Color(0xFF555555)),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis),
                  ),
                ],
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 10),
          child: Text(
            '${'carton_label_scan_unit_pair_sprit'.tr}${item.unit?? ''}',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold,color: Color(0xFF5A98CF)),
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

  // ===== 统一信息行：图标 | 标签 | 值（图标按语义上色，数值带语义色）=====
  Widget _infoRow({
    required IconData icon,
    required String label,
    String? value,
    Widget? valueWidget,
    Color valueColor = _textPrimary,
    Color iconColor = const Color(0xFF1976D2),
    double valueSize = 14,
    bool bold = false,
  }) {
    return Row(
      children: [
        Icon(icon, size: 16, color: iconColor),
        const SizedBox(width: 8),
        Text(label,
            style: const TextStyle(fontSize: 13, color: _textSecondary)),
        const Spacer(),
        valueWidget ??
            Text(
              value ?? '',
              style: TextStyle(
                fontSize: valueSize,
                fontWeight: bold ? FontWeight.bold : FontWeight.w600,
                color: valueColor,
              ),
            ),
      ],
    );
  }

  // 卡片内容区分隔线
  Widget _divider() => Container(
        height: 1,
        margin: const EdgeInsets.symmetric(vertical: 6),
        color: _border,
      );

  // 详情按钮（与"生产中"模板一致：白底蓝框 + 图标 + 详情文字）
  Widget _buildDetailButton(OrderProductionExecutionInfo item) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => logic.getDetail(
          data: item,
          successTo: () {
            Get.to(() => const OrderProductionTableDetailPage())?.then((v) {
              _scan();
            });
          },
        ),
        borderRadius: BorderRadius.circular(22),
        child: Container(
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            border: Border.all(color: _primary, width: 1.5),
            borderRadius: BorderRadius.circular(22),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.description_outlined,
                  size: 15, color: _primary),
              const SizedBox(width: 6),
              Text(
                'carton_label_scan_detail'.tr,
                style: const TextStyle(
                  color: _primary,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
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
                  fontSize: 12, fontWeight: FontWeight.w600, color: dotColor)),
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
        _infoRow(
          icon: Icons.inventory_2_outlined,
          iconColor: const Color(0xFF1976D2),
          label: 'carton_label_scan_order_qty'.tr,
          value: '$qty',
          valueSize: 18,
          bold: true,
        ),
        const SizedBox(height: 4),
        _infoRow(
          icon: Icons.calendar_today_outlined,
          iconColor: const Color(0xFFF2994A),
          label: 'carton_label_scan_plan_finish_date'.tr,
          valueWidget:
              _buildDateBadge(item.planEndDate ?? '', item.daysDifference),
        ),
        const SizedBox(height: 4),
        _infoRow(
          icon: Icons.factory_outlined,
          iconColor: const Color(0xFF009688),
          label: 'carton_label_scan_production_line'.tr,
          value: item.departmentName ?? '',
        ),
        _divider(),
        Align(
          alignment: Alignment.centerRight,
          child: _buildDetailButton(item),
        ),
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
        _infoRow(
          icon: Icons.bar_chart_outlined,
          iconColor: const Color(0xFF1976D2),
          label: 'carton_label_scan_order_complete_qty'.tr,
          value: '$orderQty / $doneQty',
          valueSize: 16,
        ),
        const SizedBox(height: 4),
        _infoRow(
          icon: Icons.error_outline,
          iconColor: const Color(0xFFE53935),
          label: 'carton_label_scan_order_owe_qty'.tr,
          value: '$pendingCount',
          valueColor: const Color(0xFFE53935),
          valueSize: 18,
          bold: true,
        ),
        const SizedBox(height: 4),
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
        const SizedBox(height: 4),
        _infoRow(
          icon: Icons.factory_outlined,
          iconColor: const Color(0xFF009688),
          label: 'carton_label_scan_production_line'.tr,
          value: item.departmentName ?? '',
        ),
        const SizedBox(height: 4),
        _infoRow(
          icon: Icons.calendar_today_outlined,
          iconColor: const Color(0xFFF2994A),
          label: 'carton_label_scan_plan_finish_date'.tr,
          valueWidget:
              _buildDateBadge(item.fetchDate ?? '', item.daysDifference),
        ),
        _divider(),
        // 底部按钮行：待确认 | 详情 | 清尾确认
        Row(
          children: [
            Expanded(
                flex: 3,
                child: Container(
                    alignment: Alignment.center,
                    padding: const EdgeInsets.symmetric(vertical: 8),
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
                        ]))),
            const SizedBox(width: 8),
            Expanded(
                flex: 3,
                child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                        onTap: () => logic.getDetail(
                            data: item,
                            successTo: () {
                              Get.to(() =>
                                      const OrderProductionTableDetailPage())
                                  ?.then((v) {
                                _scan();
                              });
                            }),
                        borderRadius: BorderRadius.circular(22),
                        child: Container(
                            alignment: Alignment.center,
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            decoration: BoxDecoration(
                                border: Border.all(color: _primary, width: 1.5),
                                borderRadius: BorderRadius.circular(22)),
                            child: Row(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.description_outlined,
                                      size: 15, color: _primary),
                                  const SizedBox(width: 6),
                                  Text('carton_label_scan_detail'.tr,
                                      style: const TextStyle(
                                          color: _primary,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600))
                                ]))))),
            const SizedBox(width: 8),
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
                        borderRadius: BorderRadius.circular(22),
                        child: Container(
                            alignment: Alignment.center,
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            decoration: BoxDecoration(
                                color: _primary,
                                borderRadius: BorderRadius.circular(22),
                                boxShadow: const [
                                  BoxShadow(
                                      color: Color(0x401976D2),
                                      blurRadius: 6,
                                      offset: Offset(0, 3))
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
    // 待清尾 = 订单 - 完工
    final tailQty = (orderQty - doneQty).clamp(0, 99999);

    return Column(
      children: [
        _infoRow(
          icon: Icons.bar_chart_outlined,
          iconColor: const Color(0xFF1976D2),
          label: 'carton_label_scan_order_complete_qty'.tr,
          value: '$orderQty / $doneQty',
          valueSize: 16,
        ),
        const SizedBox(height: 4),
        _infoRow(
          icon: Icons.warning_amber_rounded,
          iconColor: const Color(0xFFF2994A),
          label: 'carton_label_scan_wait_clear_tail'.tr,
          value: '$tailQty',
          valueColor: const Color(0xFFE53935),
          valueSize: 18,
          bold: true,
        ),
        const SizedBox(height: 4),
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
        const SizedBox(height: 4),
        _infoRow(
          icon: Icons.factory_outlined,
          iconColor: const Color(0xFF009688),
          label: 'carton_label_scan_production_line'.tr,
          value: item.departmentName ?? '',
        ),
        const SizedBox(height: 10),
        _infoRow(
          icon: Icons.calendar_today_outlined,
          iconColor: const Color(0xFFF2994A),
          label: 'carton_label_scan_plan_finish_date'.tr,
          valueWidget:
              _buildDateBadge(item.fetchDate ?? '', item.daysDifference),
        ),
        _divider(),
        // 底部按钮：详情 | 取消清尾确认（平分）
        Row(
          children: [
            Expanded(child: _buildDetailButton(item)),
            const SizedBox(width: 8),
            Expanded(
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
                  borderRadius: BorderRadius.circular(22),
                  child: Container(
                    alignment: Alignment.center,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    decoration: BoxDecoration(
                      border: Border.all(
                          color: const Color(0xFFF2994A), width: 1.5),
                      borderRadius: BorderRadius.circular(22),
                    ),
                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                      const Icon(Icons.close,
                          size: 15, color: Color(0xFFF2994A)),
                      const SizedBox(width: 3),
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
        _infoRow(
          icon: Icons.bar_chart_outlined,
          iconColor: const Color(0xFF1976D2),
          label: 'carton_label_scan_order_complete_qty'.tr,
          value: '$orderQty / $doneQty',
          valueSize: 16,
        ),
        const SizedBox(height: 4),
        _infoRow(
          icon: Icons.factory_outlined,
          iconColor: const Color(0xFF009688),
          label: 'carton_label_scan_production_line'.tr,
          value: item.departmentName ?? '',
        ),
        const SizedBox(height: 4),
        _infoRow(
          icon: Icons.check_circle_outline,
          iconColor: const Color(0xFF27AE60),
          label: 'carton_label_scan_case_close_date'.tr,
          value: item.lastDate ?? '',
        ),
        _divider(),
        Align(
          alignment: Alignment.centerRight,
          child: _buildDetailButton(item),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return pageBodyWithDrawer(
        actions: [],
        body: Container(
          color: _bg,
          child: Column(
            children: [
              // 搜索框 + 跳转按钮（按指令号 / 派工单号 搜索当前 Tab 下的内容）
              Padding(
                padding: const EdgeInsets.fromLTRB(5, 5, 5, 2),
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: _border),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x0A000000),
                              blurRadius: 6,
                              offset: Offset(0, 2),
                            ),
                          ],
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
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 9),
                            hintText:
                                'carton_label_scan_search_instruction_no'.tr,
                            hintStyle: const TextStyle(
                                color: Color(0xFF999999), fontSize: 13),
                            prefixIcon: const Icon(Icons.search,
                                size: 18, color: Color(0xFF999999)),
                            prefixIconConstraints: const BoxConstraints(
                                minWidth: 34, minHeight: 0),
                            suffixIcon: Obx(() =>
                                state.searchKey.value.isNotEmpty
                                    ? GestureDetector(
                                        onTap: () {
                                          state.searchTec.clear();
                                          state.searchKey.value = '';
                                          logic.selectShow();
                                        },
                                        child: const Icon(Icons.clear,
                                            size: 18, color: Color(0xFF999999)),
                                      )
                                    : const SizedBox.shrink()),
                            suffixIconConstraints: const BoxConstraints(
                                minWidth: 34, minHeight: 0),
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    _jumpButton(),
                  ],
                ),
              ),
              // 4 个状态 Tab（分段控件样式）
              Padding(
                padding: const EdgeInsets.fromLTRB(5, 4, 5, 4),
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: _border),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: _statusTabButton(0, 'carton_label_scan_todo'.tr),
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child:
                            _statusTabButton(1, 'carton_label_scan_produce'.tr),
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: _statusTabButton(
                            2, 'carton_label_scan_clear_tail'.tr),
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: _statusTabButton(3, 'carton_label_scan_done'.tr),
                      ),
                    ],
                  ),
                ),
              ),
              // 统计信息条（message 为空时不显示）
              Obx(
                () => state.message.value.isEmpty
                    ? const SizedBox.shrink()
                    : Padding(
                        padding: const EdgeInsets.fromLTRB(5, 2, 5, 4),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 5),
                          decoration: BoxDecoration(
                            color: const Color(0xFFEAF2FE),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.info_outline,
                                  size: 16, color: _primary),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  state.message.value,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: Color(0xFF33475B),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
              ),
              Expanded(
                child: Obx(
                  () => ListView.builder(
                    itemCount: state.tailNumberList.length,
                    padding: const EdgeInsets.only(bottom: 2),
                    itemBuilder: (context, index) =>
                        _item(state.tailNumberList[index]),
                  ),
                ),
              ),
            ],
          ),
        ),
        queryWidgets: [
          EditText(
            hint: 'carton_label_scan_order_input_command'.tr,
            controller: state.tecCommand,
          ),
          EditText(
            hint: 'carton_label_scan_input_work_order'.tr,
            controller: state.tecWorkOrder,
          ),
          EditText(
            hint: 'carton_label_scan_input_carton_barcode'.tr,
            controller: state.tailBarCode,
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
          queryList();
        });
  }

  void queryList(){
    logic.queryOrderList(
      success: () {
        setState(() {
          logic.selectShow();
          spinnerController2 = SpinnerController(
              dataList: state.lineList,
              onChanged: (index) {
                state.selectIndex = index;
                logic.selectShow();
                Get.back();
              });
        });
      },
    );
  }

  void _scan() {
    pdaScanner(scan: (barCode) {
      if (barCode.isNotEmpty) {
        if (barCode.startsWith('P')) {
          state.tecWorkOrder.text = barCode;
          queryList();
        } else {
          state.tailBarCode.text = barCode;
          queryList();
        }
      }
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
    _scan();
  }
}
