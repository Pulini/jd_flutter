import 'package:get/get.dart';
import 'package:jd_flutter/utils.dart';

import '../../../bean/http/response/part_detail_info.dart';
import '../../../bean/http/response/work_order_info.dart';

class WorkOrderListState {
  var workBarCode = '';
  var planOrderNumber = '';
  var dataList = <WorkOrderInfo>[].obs;
  var isOutsourcing = spGet('${Get.currentRoute}/isClosed') ?? false;
  var isClosed = spGet('${Get.currentRoute}/isClosed') ?? false;
  var orderId='';
  var partList=<PartInfo>[].obs;
  PartDetailInfo? partDetail;
  var partDetailSizeList=<SizeInfo>[].obs;

  WorkOrderListState() {
    ///Initialize variables
  }


}
