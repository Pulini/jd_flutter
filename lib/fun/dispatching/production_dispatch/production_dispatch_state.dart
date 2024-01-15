import 'package:get/get_rx/src/rx_types/rx_types.dart';

import '../../../http/response/production_dispatch_order_detail_info.dart';
import '../../../http/response/production_dispatch_order_info.dart';

class ProductionDispatchState {
  RxList<ProductionDispatchOrderInfo> orderList =
      <ProductionDispatchOrderInfo>[].obs;
  RxMap<String, List<ProductionDispatchOrderInfo>> orderGroupList =
      <String, List<ProductionDispatchOrderInfo>>{}.obs;
  ProductionDispatchOrderDetailInfo detailInfo =
      ProductionDispatchOrderDetailInfo();
}
