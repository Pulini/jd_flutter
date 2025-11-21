
class CreateCustomLabelsData {
  int type;
  bool select;
  String size;
  String instruct;
  int createdLabels;
  double goodsTotal;
  double createdGoods;
  double surplusGoods;
  String capacity;
  String createGoods;

  CreateCustomLabelsData({
    this.type = 1,
    this.select = false,
    this.size = "",
    this.instruct = "",
    this.createdLabels = 0,
    this.goodsTotal = 0.0,
    this.createdGoods = 0.0,
    this.surplusGoods = 0.0,
    this.capacity = "100",
    this.createGoods = "100",
  });

  String sizeText() {
    return '尺寸: $size';
  }

  String createdLabelsText() {
    return '已创建标签: $createdLabels';
  }

  String goodsTotalText() {
    return '总货数: ${goodsTotal.toStringAsFixed(goodsTotal.truncateToDouble() == goodsTotal ? 0 : 1)}';
  }

  String createdGoodsText() {
    return '已生成货数: ${createdGoods.toStringAsFixed(createdGoods.truncateToDouble() == createdGoods ? 0 : 1)}';
  }

  String surplusGoodsText() {
    return '剩余货数: ${surplusGoods.toStringAsFixed(surplusGoods.truncateToDouble() == surplusGoods ? 0 : 1)}';
  }

  String createText() {
    return '创建: ${createLabel()}';
  }

  int createLabel() {
    final capacityValue = double.tryParse(capacity) ?? 0.0;
    final createGoodsValue = double.tryParse(createGoods) ?? 0.0;

    if (capacityValue > 0.0 && createGoodsValue > 0.0) {
      return (createGoodsValue / capacityValue).ceil();
    }
    return 0;
  }
}