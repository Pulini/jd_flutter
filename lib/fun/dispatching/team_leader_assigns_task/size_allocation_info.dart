import 'package:flutter/material.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';

class SizeAllocationInfo {
  String? size; //冲刀尺码
  int? totalQty; //总数量
  var assignedOperator = ''.obs; //分配操作工（工号）
  var currentQty = ''.obs; //本次分配数量（输入框）
  int get remainingQty => (totalQty ?? 0) - (int.tryParse(currentQty.value) ?? 0); //剩余未分配 = 总数量 - 本次分配
  var isMatched = false.obs; //是否匹配到员工

  // TextEditingController 持久化，避免 Obx 重建导致光标错乱
  late final TextEditingController operatorController;
  late final TextEditingController qtyController;

  SizeAllocationInfo({
    this.size,
    this.totalQty,
    String? assignedOperator,
    String? currentQty,
  }) {
    this.assignedOperator.value = assignedOperator ?? '';
    this.currentQty.value = currentQty ?? '';
    operatorController = TextEditingController(text: this.assignedOperator.value);
    qtyController = TextEditingController(text: this.currentQty.value);
  }

  // 重置时同步清空 controller
  void reset() {
    assignedOperator.value = '';
    currentQty.value = '';
    isMatched.value = false;
    operatorController.clear();
    qtyController.clear();
  }
}
