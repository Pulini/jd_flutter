import 'package:collection/collection.dart';
import 'package:get/get.dart';
import 'package:jd_flutter/bean/http/response/sap_purchase_stock_in_info.dart';
import 'package:jd_flutter/fun/warehouse/in/sap_purchase_stock_in/sap_purchase_stock_in_check_view.dart';
import 'package:jd_flutter/fun/warehouse/in/sap_purchase_stock_in/sap_purchase_stock_in_detail_view.dart';
import 'package:jd_flutter/widget/dialogs.dart';
import 'sap_purchase_stock_in_state.dart';

class SapPurchaseStockInLogic extends GetxController {
  final SapPurchaseStockInState state = SapPurchaseStockInState();

  @override
  void onReady() {
    // TODO: implement onReady
    super.onReady();
  }

  @override
  void onClose() {
    // TODO: implement onClose
    super.onClose();
  }

  queryOrder({
    required String deliNo,
    required String startDate,
    required String endDate,
    required String factory,
    required String warehouse,
    required String supplier,
    required String company,
  }) {
    state.getDeliveryList(
      deliNo: deliNo,
      startDate: startDate,
      endDate: endDate,
      factory: factory,
      warehouse: warehouse,
      supplier: supplier,
      company: company,
      error: (msg) => errorDialog(content: msg),
    );
  }

  queryDetail(int index, String deliveryNumber) {
    state.getDeliveryDetail(
      deliveryNumber: deliveryNumber,
      success: () => Get.to(() => const SapPurchaseStockInDetailPage()),
      error: (msg) => errorDialog(content: msg),
    );
  }

  checkOrder({
    required int index,
    required SapPurchaseStockInInfo list,
    required Function() refresh,
  }) {
    state.checkTemporaryOrder(
      list: [list],
      success: () => Get.to(() => const SapPurchaseStockInCheckPage(),
          arguments: {'index': index})?.then(
        (v) => refresh.call(),
      ),
      error: (msg) => errorDialog(content: msg),
    );
  }

  saveDeliveryCheck({
    required String location,
    required String inspector,
    required List<SapPurchaseStockInInfo> list,
  }) {
    state.saveDeliveryCheck(
      location: location,
      inspector: inspector,
      list: list,
      success: (msg) => successDialog(
          content: msg,
          back: () {
            Get.back(result: true);
          }),
      error: (msg) => errorDialog(content: msg),
    );
  }

  List<SapPurchaseStockInInfo> getSelected() {
    var list = <SapPurchaseStockInInfo>[];
    state.selectedList.forEachIndexed((i, selected) {
      if (selected) {
        list.addAll(state.orderList[i]);
      }
    });
    return list;
  }

  checkStockInWriteOffSelected(
      Function(List<SapPurchaseStockInInfo>) callback) {
    var exempt = <SapPurchaseStockInInfo>[];
    var notExempt = <SapPurchaseStockInInfo>[];
    state.selectedList.forEachIndexed((i, selected) {
      if (selected) {
        if (state.orderList[i][0].isExempt == 'X') {
          exempt.addAll(state.orderList[i]);
        } else {
          notExempt.addAll(state.orderList[i]);
        }
      }
    });
    if (exempt.isNotEmpty && notExempt.isNotEmpty) {
      errorDialog(content: '所选条目包含免检与非免检');
    } else {
      callback.call([...exempt, ...notExempt]);
    }}

  checkTemporarySelected(Function(List<SapPurchaseStockInInfo>) callback) {
    var noInspector = 0;
    var isExempt = 0;
    var selectList = <SapPurchaseStockInInfo>[];
    state.selectedList.forEachIndexed((i, selected) {
      if (selected) {
        selectList.addAll(state.orderList[i]);
        if (state.orderList[i][0].isExempt == 'X') {
          isExempt++;
        }
        if (state.orderList[i][0].inspector?.isEmpty == true) {
          noInspector++;
        }
      }
    });
    if (isExempt > 0) {
      errorDialog(content: '免检物料禁止暂收！');
      return;
    }
    if (noInspector > 0) {
      errorDialog(content: '含有未清点数据！');
      return;
    }
    callback.call(selectList);
  }
}
