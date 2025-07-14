import 'package:get/get.dart';
import 'package:jd_flutter/bean/http/response/wait_picking_material_info.dart';
import 'package:jd_flutter/fun/warehouse/out/wait_picking_material/wait_picking_material_detail_view.dart';
import 'package:jd_flutter/widget/custom_widget.dart';
import 'package:jd_flutter/widget/dialogs.dart';
import 'package:jd_flutter/widget/preview_a4paper_widget.dart';

import 'wait_picking_material_state.dart';

class WaitPickingMaterialLogic extends GetxController {
  final WaitPickingMaterialState state = WaitPickingMaterialState();

  selectedDepartment({required int group, required int sub}) {
    state.selectedDepartment =
        state.companyDepartmentList[group].departmentList?[sub];
    state.queryParamDepartment.value =
        state.selectedDepartment?.departmentName ?? '';
  }

  query({
    required String typeBody,
    required String instruction,
    required String materialCode,
    required String clientPurchaseOrder,
    required String purchaseVoucher,
    required String productionDemand,
    required String pickerNumber,
    required String startDate,
    required String endDate,
    required String postingDate,
    required String factory,
    required String factoryWarehouse,
    required String workshopWarehouse,
    required String supplier,
    required String processFlow,
  }) {
    if (state.queryParamOrderType.value == 0 &&
        supplier == '' &&
        processFlow == '') {
      msgDialog(
          content:
              'wait_picking_material_order_search_all_need_supplier_or_process'
                  .tr);
      return;
    }
    if ((state.queryParamOrderType.value == 1 ||
            state.queryParamOrderType.value == 3) &&
        processFlow == '') {
      msgDialog(
          content:
              'wait_picking_material_order_search_not_outsource_need_process'
                  .tr);
      return;
    }
    if ((state.queryParamOrderType.value == 2 ||
            state.queryParamOrderType.value == 4) &&
        supplier == '') {
      msgDialog(
          content:
              'wait_picking_material_order_search_outsource_need_supplier'.tr);
      return;
    }
    state.queryPickingMaterialList(
      typeBody: typeBody,
      instruction: instruction,
      materialCode: materialCode,
      clientPurchaseOrder: clientPurchaseOrder,
      purchaseVoucher: purchaseVoucher,
      productionDemand: productionDemand,
      pickerNumber: pickerNumber,
      startDate: startDate,
      endDate: endDate,
      postingDate: postingDate,
      factory: factory,
      factoryWarehouse: factoryWarehouse,
      workshopWarehouse: workshopWarehouse,
      supplier: supplier,
      processFlow: processFlow,
      error: (msg) => errorDialog(content: msg),
    );
  }

  goDetail(WaitPickingMaterialOrderInfo order, int index) {
    state.detail = order;
    state.detailSubIndex = index;
    Get.to(() => const WaitPickingMaterialDetailPage())?.then((_) {
      refreshSelect();
    });
  }

  selectOrderAll(bool select, WaitPickingMaterialOrderInfo data) {
    data.items?.forEach((v1) => selectSubItemAll(select, v1));
  }

  selectSubItemAll(bool select, WaitPickingMaterialOrderSubInfo data) {
    data.models?.forEach((v2) {
      if (select) {
        if (v2.pickingQty.value > 0) v2.isSelected.value = true;
      } else {
        v2.isSelected.value = false;
      }
    });
  }

  bool detailHasSelected() => state.detailSubIndex >= 0
      ? state.detail.items![state.detailSubIndex].selectedCount() > 0
      : state.detail.hasSelected();

  detailSelectAll(bool select) {
    if (state.detailSubIndex >= 0) {
      state.detail.items![state.detailSubIndex].models?.forEach(
        (v) => v.isSelected.value = select,
      );
    } else {
      state.detail.items?.forEach(
        (v) => v.models?.forEach((v2) => v2.isSelected.value = select),
      );
    }
  }

  refreshSelect() {
    if (state.detailSubIndex >= 0) {
      state.detail.items![state.detailSubIndex].models?.forEach(
        (v) {
          if (v.pickingQty.value <= 0) {
            v.isSelected.value = false;
          }
        },
      );
    } else {
      state.detail.items?.forEach(
        (v) => v.models?.forEach((v2) {
          if (v2.pickingQty.value <= 0) {
            v2.isSelected.value = false;
          }
        }),
      );
    }
  }

  List<WaitPickingMaterialOrderSubInfo> getDetailSelectedList() {
    var list = <WaitPickingMaterialOrderSubInfo>[];
    if (state.detailSubIndex >= 0) {
      list.add(state.detail.items![state.detailSubIndex]);
    } else {
      list.addAll(state.detail.items!.where((v) => v.selectedCount() > 0));
    }
    return list;
  }

  List<WaitPickingMaterialOrderModelInfo> getDetailModifySelectedList() {
    var list = <WaitPickingMaterialOrderModelInfo>[];
    getDetailSelectedList().forEach(
      (v) => list.addAll(
        v.models!.where((v2) => v2.isSelected.value),
      ),
    );
    return list;
  }

  List<WaitPickingMaterialOrderModelInfo> getDetailBatchSelectedList(
      WaitPickingMaterialOrderInfo order) {
    var list = <WaitPickingMaterialOrderModelInfo>[];
    for (var v in order.items!) {
      list.addAll(v.models!
          .where((v2) => v2.isSelected.value && v2.batch?.isNotEmpty == true));
    }
    return list;
  }

  getRealTimeInventory({
    required Function(List<ImmediateInventoryInfo>) show,
  }) {
    state.getMaterialInventory(
      factoryCode: state.detail.factoryNumber ?? '',
      materialCode: state.detail.rawMaterialCode ?? '',
      success: show,
      error: (msg) => errorDialog(content: msg),
    );
  }

  checkPickingMaterial({
    required Function() oneFaceCheck,
    required Function() twoFaceCheck,
  }) {
    var list = <WaitPickingMaterialOrderInfo>[];
    var orderType = <String>[];
    for (var v in state.orderList) {
      var insList = v.items!.where((v2) => v2.getEffectiveSelection().isNotEmpty);
      if (insList.isNotEmpty) {
        list.add(v);
        for (var v2 in insList) {
          if (!orderType.contains(v2.documentType)) {
            orderType.add(v2.documentType ?? '');
          }
        }
      }
    }
    if (list.isEmpty) {
      msgDialog(content: 'wait_picking_material_order_not_select'.tr);
      return;
    }
    if (orderType.length > 1) {
      msgDialog(
          content:
              'wait_picking_material_order_selected_order_type_different'.tr);
      return;
    }

    if (orderType[0] == '1' || orderType[0] == '3') {
      twoFaceCheck.call();
    } else {
      oneFaceCheck.call();
    }
  }

  pickingMaterial({
    required bool isMove,
    required bool isPosting,
    String? pickerNumber,
    String? pickerBase64,
    String? userBase64,
    required Function(
      List<WaitPickingMaterialOrderInfo>,
      String,
      String,
    ) modifyLocation,
    required Function(String, String) refresh,
  }) {
    state.submitPickingMaterial(
      isMove: isMove,
      isPosting: isPosting,
      pickerNumber: pickerNumber ?? '',
      pickerBase64: pickerBase64,
      userBase64: userBase64,
      success: (msg, number) {
        var list = state.orderList
            .where((v) => v.hasSelected() && v.location.isBlank == false)
            .toList();
        if (list.isNotEmpty) {
          modifyLocation.call(list, msg, number);
        } else {
          refresh.call(msg, number);
        }
      },
      error: (msg) => errorDialog(content: msg),
    );
  }

  printMaterialList(String orderNumber) {
    state.getMaterialPrintInfo(
      orderNumber: orderNumber,
      success: (info) =>
          Get.to(() => PreviewA4Paper(paperWidgets: createA4Paper2(info))),
      error: (msg) => errorDialog(content: msg),
    );
  }
}
