import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jd_flutter/bean/http/response/wait_picking_material_info.dart';
import 'package:jd_flutter/fun/warehouse/out/wait_picking_material/wait_picking_material_detail_view.dart';
import 'package:jd_flutter/utils/utils.dart';
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
    debugPrint('typeBody=$typeBody'
        'instruction=$instruction'
        'materialCode=$materialCode'
        'clientPurchaseOrder=$clientPurchaseOrder'
        'purchaseVoucher=$purchaseVoucher'
        'productionDemand=$productionDemand'
        'pickerNumber=$pickerNumber'
        'startDate=$startDate '
        'endDate=$endDate '
        'postingDate=$postingDate '
        'factory=$factory '
        'factoryWarehouse=$factoryWarehouse '
        'workshopWarehouse=$workshopWarehouse '
        'supplier=$supplier '
        'processFlow=$processFlow');

    if (state.queryParamOrderType.value == 0 &&
        supplier == '' &&
        processFlow == '') {
      informationDialog(content: '单据类型为所有，需要选择供应商或者制程');
      return;
    }
    if ((state.queryParamOrderType.value == 1 ||
            state.queryParamOrderType.value == 3) &&
        processFlow == '') {
      informationDialog(content: '单据类型为正单或者不但，需要选择制程');
      return;
    }
    if ((state.queryParamOrderType.value == 2 ||
            state.queryParamOrderType.value == 4) &&
        supplier == '') {
      informationDialog(content: '单据类型为委外，需要选择供应商');
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
    required Function() needCheck,
    required Function() picking,
  }) {
    var list = <WaitPickingMaterialOrderInfo>[];
    var orderType = <String>[];
    for (var v in state.orderList) {
      var insList =
          v.items!.where((v2) => v2.getEffectiveSelection().isNotEmpty);
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
      informationDialog(content: '请选择要领取的物料');
      return;
    }
    if (orderType.length > 1) {
      informationDialog(content: '请选择相同单据类型的物料');
      return;
    }
    if (orderType[0] == '1' || orderType[0] == '3') {
      needCheck.call();
    } else {
      picking.call();
    }
  }

  pickingMaterial({
    String? pickerNumber,
    String? pickerBase64,
    String? userBase64,
    required Function(List<WaitPickingMaterialOrderInfo>, String)
        modifyLocation,
    required Function(String) refresh,
  }) {
    state.submitPickingMaterial(
      isMove: false,
      pickerNumber: pickerNumber ?? '',
      pickerBase64: pickerBase64,
      userBase64: userBase64,
      success: (msg) {
        var rList = state.orderList
            .where((v) => v.hasSelected() && v.location.isBlank == false)
            .toList();
        if (rList.isNotEmpty) {
          modifyLocation.call(rList, msg);
        } else {
          refresh.call(msg);
        }
      },
      error: (msg) => errorDialog(content: msg),
    );
  }

  printMaterialList() {
    Get.to(() => PreviewA4Paper(
          paperWidgets: createA4Paper(
            state.orderList.where((v) => v.hasSelected()).toList(),
          ),
        ));
  }

  Widget _tableSubTitle(String factoryName) => Container(
        height: 29,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.black, width: 0.5),
        ),
        padding: const EdgeInsets.only(left: 5, right: 5),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '工厂：$factoryName',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Colors.black,
              ),
            )
          ],
        ),
      );

  Widget _tableRowItem({
    required int flex,
    required String text,
    required CrossAxisAlignment alignment,
  }) {
    return Expanded(
      flex: flex,
      child: Container(
        height: double.infinity,
        padding: const EdgeInsets.only(left: 5, right: 5),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.black, width: 0.5),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: alignment,
          children: [
            Text(
              text,
              style: const TextStyle(
                color: Colors.black,
                fontSize: 16,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _paperTableItem({
    required Color backgroundColor,
    required String? rawMaterialCode,
    required String? rawMaterialDescription,
    required String? colorSystem,
    required String? pickingWarehouse,
    required String? location,
    required String? unit,
    required String? picking,
    required String? actual,
  }) {
    return Container(
      height: 29,
      color: backgroundColor,
      child: Row(
        children: [
          _tableRowItem(
            flex: 3,
            text: rawMaterialCode ?? '',
            alignment: CrossAxisAlignment.start,
          ),
          _tableRowItem(
            flex: 15,
            text: rawMaterialDescription ?? '',
            alignment: CrossAxisAlignment.start,
          ),
          _tableRowItem(
            flex: 3,
            text: colorSystem ?? '',
            alignment: CrossAxisAlignment.start,
          ),
          _tableRowItem(
            flex: 1,
            text: pickingWarehouse ?? '',
            alignment: CrossAxisAlignment.start,
          ),
          _tableRowItem(
            flex: 3,
            text: location ?? '',
            alignment: CrossAxisAlignment.start,
          ),
          _tableRowItem(
            flex: 1,
            text: unit ?? '',
            alignment: CrossAxisAlignment.center,
          ),
          _tableRowItem(
            flex: 2,
            text: picking ?? '',
            alignment: CrossAxisAlignment.end,
          ),
          _tableRowItem(
            flex: 2,
            text: actual ?? '',
            alignment: CrossAxisAlignment.end,
          ),
        ],
      ),
    );
  }

  Widget _addPaper({
    required List<Widget> item,
    required int page,
    required double paperWidth,
    required double paperHeight,
    required double paperPadding,
    required double paperTitleHeight,
    required double paperSubTitleHeight,
    required double paperFooterHeight,
    required int totalHeight,
  }) {
    double tableHeight = paperHeight -
        paperTitleHeight -
        paperSubTitleHeight -
        paperFooterHeight -
        paperPadding * 2;
    return Container(
      padding: EdgeInsets.all(paperPadding),
      width: paperWidth,
      height: paperHeight,
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            height: paperTitleHeight,
            child: Center(
              child: Text(
                '仓库备料单',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),
          ),
          SizedBox(
            height: paperSubTitleHeight,
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    '领料单号：',
                    style: TextStyle(
                      fontSize: 20,
                      color: Colors.black,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    '合同号：',
                    style: TextStyle(
                      fontSize: 20,
                      color: Colors.black,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    '供应商：',
                    style: TextStyle(
                      fontSize: 20,
                      color: Colors.black,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.black, width: 0.5),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: item,
            ),
          ),
          Expanded(child: Container()),
          Container(
            height: paperFooterHeight,
            padding: const EdgeInsets.only(right: 5),
            child: Row(
              children: [
                Text(
                  '打印日期：${getDateYMD()} ${getTimeHms()}',
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 12,
                  ),
                  textAlign: TextAlign.end,
                ),
                const SizedBox(width: 50),
                Text(
                  '打印人：(${userInfo?.number})${userInfo?.name}',
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 12,
                  ),
                  textAlign: TextAlign.end,
                ),
                const Expanded(child: Center()),
                Text(
                  '页码：$page/${(totalHeight / tableHeight).ceil()}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                    fontSize: 12,
                  ),
                  textAlign: TextAlign.end,
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  List<Widget> createA4Paper(List<WaitPickingMaterialOrderInfo> list) {
    var scale = 0.5;
    double paperHeight = 2380 * scale;
    double paperWidth = 3368 * scale;
    var factoryList = <List<WaitPickingMaterialOrderInfo>>[];
    groupBy(list, (v) => v.factoryNumber ?? '').forEach((k, v) {
      factoryList.add(v);
    });

    var widgetList = <List<dynamic>>[];
    for (var item1 in factoryList) {
      widgetList.add([30, _tableSubTitle(item1[0].factoryName ?? '')]);
      widgetList.add([
        30,
        _paperTableItem(
          backgroundColor: Colors.grey.shade400,
          rawMaterialCode: '物料编号',
          rawMaterialDescription: '物料描述',
          colorSystem: '色系',
          pickingWarehouse: '仓库',
          location: '库位',
          unit: '单位',
          picking: '应领料数量',
          actual: '实际领料数量',
        )
      ]);
      for (var i = 0; i < item1.length; ++i) {
        widgetList.add([
          30,
          _paperTableItem(
            backgroundColor: i % 2 == 0 ? Colors.white : Colors.grey.shade200,
            rawMaterialCode: item1[i].rawMaterialCode,
            rawMaterialDescription: item1[i].rawMaterialDescription,
            colorSystem: item1[i].items![0].models![0].colorSystem,
            pickingWarehouse: item1[i].pickingWarehouse,
            location: item1[i].location,
            unit: item1[i].getUnit(),
            picking: item1[i].getPicking().toFixed(3).toShowString(),
            actual: '',
          )
        ]);
      }
    }
    double paperTitleHeight = 30;
    double paperSubTitleHeight = 25;
    double paperFooterHeight = 20;
    double paperPadding = 20;
    var page = 1;
    var height = 0.0;
    var paperList = <Widget>[];
    var item = <Widget>[];
    int totalHeight =
        widgetList.map((v) => (v[0] as int)).reduce((a, b) => a + b);
    double tableHeight = paperHeight -
        paperTitleHeight -
        paperSubTitleHeight -
        paperFooterHeight -
        paperPadding * 2;
    for (var w in widgetList) {
      if (height + w[0] <= tableHeight) {
        height += w[0];
        item.add(w[1]);
        if (widgetList.last == w) {
          paperList.add(_addPaper(
            item: item,
            page: page,
            paperWidth: paperWidth,
            paperHeight: paperHeight,
            paperPadding: paperPadding,
            paperTitleHeight: paperTitleHeight,
            paperSubTitleHeight: paperSubTitleHeight,
            paperFooterHeight: paperFooterHeight,
            totalHeight: totalHeight,
          ));
          item = [];
        }
      } else {
        height = 0.0;
        item.add(w[1]);
        paperList.add(_addPaper(
          item: item,
          page: page,
          paperWidth: paperWidth,
          paperHeight: paperHeight,
          paperPadding: paperPadding,
          paperTitleHeight: paperTitleHeight,
          paperSubTitleHeight: paperSubTitleHeight,
          paperFooterHeight: paperFooterHeight,
          totalHeight: totalHeight,
        ));
        page += 1;
        item = [];
      }
    }
    return paperList;
  }
}
