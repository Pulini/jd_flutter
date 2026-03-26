import 'package:get/get.dart';

class CreateCustomLabelsData {
  int type;
  RxBool isSelect = false.obs;
  RxDouble capacity = 0.0.obs;
  RxDouble createGoods = 0.0.obs;
  String size;
  String instruct;
  int createdLabels;
  double goodsTotal;
  double createdGoods;
  double surplusGoods;

  CreateCustomLabelsData({
    this.type = 1,
    bool? isSelect,
    double? capacity,
    double? createGoods,
    this.size = "",
    this.instruct = "",
    this.createdLabels = 0,
    this.goodsTotal = 0.0,
    this.createdGoods = 0.0,
    this.surplusGoods = 0.0,
  }) {
    this.isSelect = RxBool(isSelect!);
    this.capacity = RxDouble(capacity!);
    this.createGoods = RxDouble(createGoods!);
  }

  // String sizeText() {
  //   return '尺寸: $size';
  // }
  //
  // String createdLabelsText() {
  //   return '已创建标签: $createdLabels';
  // }
  //
  // String goodsTotalText() {
  //   return '总货数: ${goodsTotal.toStringAsFixed(goodsTotal.truncateToDouble() == goodsTotal ? 0 : 1)}';
  // }
  String get goodsTotalValue {
    return goodsTotal
        .toStringAsFixed(goodsTotal.truncateToDouble() == goodsTotal ? 0 : 1);
  }

  // String createdGoodsText() {
  //   return '已生成货数: ${createdGoods.toStringAsFixed(createdGoods.truncateToDouble() == createdGoods ? 0 : 1)}';
  // }
  String get createdGoodsValue {
    return createdGoods.toStringAsFixed(
        createdGoods.truncateToDouble() == createdGoods ? 0 : 1);
  }

  // String surplusGoodsText() {
  //   return '剩余货数: ${surplusGoods.toStringAsFixed(surplusGoods.truncateToDouble() == surplusGoods ? 0 : 1)}';
  // }
  String get surplusGoodsValue {
    return surplusGoods.toStringAsFixed(
        surplusGoods.truncateToDouble() == surplusGoods ? 0 : 1);
  }

  // String createText() {
  //   return '创建: ${createLabel()}';
  // }
  int createLabel() => capacity.value > 0.0 && createGoods.value > 0.0
      ? (createGoods.value / capacity.value).ceil()
      : 0;

  bool isCanCreate() =>
      isSelect.value && capacity.value > 0 && createGoods.value > 0;
}
