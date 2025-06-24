import 'package:get/get_rx/src/rx_types/rx_types.dart';

class QualityInspectionShowColor {
  QualityInspectionShowColor({
    this.subItem,
    this.name,
    this.code,
    this.color,
    this.qty,
    this.allQty,

  });


  String? subItem;  //是否合计栏   2 分色合计  3冲销合计
  String? name;  //物料名称
  String? code;  //物料编码
  String? color;  //色系
  double? qty;  //数量
  double? allQty;  //数量
  RxBool isSelected = false.obs;

}





