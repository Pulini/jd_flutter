import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';
import 'package:jd_flutter/bean/http/response/sap_picking_posting_info.dart';
import 'package:jd_flutter/utils/extension_util.dart';
import 'package:jd_flutter/utils/web_api.dart';

class SapPickingPostingState {
  var order = ''.obs;
  var semiFinishedProductList = <SapPickingPostingGroup>[].obs;
  var finishedProductList = <SapPickingPostingInfo>[].obs;

  SapPickingPostingState() {
    ///Initialize variables
  }

  void getNewOrderNumber({
    required Function(String) error,
  }) {
    sapPost(
      loading: '正在生成拣配单号...',
      method: webApiSapCreatePickingOrderNumber,
      body: {'ORDER_TYPE': 'SCJP'},
    ).then((response) {
      if (response.resultCode == resultSuccess) {
        order.value = response.data['ORDER_NUM'];
      } else {
        error.call(response.message ?? 'query_default_error'.tr);
      }
    });
  }

  void getPickingMaterialDetail({
    required String code,
    required Function(SapPickingPostingInfo) success,
    required Function(String) error,
  }) {
    sapPost(
      loading: '正在查询物料信息...',
      method: webApiSapGetPickingMaterialDetail,
      body: {'BQID': code},
    ).then((response) {
      if (response.resultCode == resultSuccess) {
        success.call(SapPickingPostingInfo.fromJsonWithLabel(response.data, code));
      } else {
        error.call(response.message ?? 'query_default_error'.tr);
      }
    });
  }

  void submitPickingLabel({
    required bool isPosting,
    required Function(String) success,
    required Function(String) error,
  }) {
    sapPost(
      loading: '正在提交拣配过账...',
      method: webApiSapSubmitPickingOrder,
      body: {
        'ORDER_NUM': order.value,
        'ORDER_STATUS': isPosting ? '02' : '01',
        'MATNR': finishedProductList.isNotEmpty
            ? finishedProductList.first.materialCode
            : '',
        'MAKTX': finishedProductList.isNotEmpty
            ? finishedProductList.first.materialName
            : '',
        'VBELN': finishedProductList.isNotEmpty
            ? finishedProductList.first.salesOrder
            : '',
        'POSNR': finishedProductList.isNotEmpty
            ? finishedProductList.first.salesOrderItem
            : '',
        'MENGE': finishedProductList.isNotEmpty
            ? finishedProductList
                .map((v) => v.quantity ?? 0)
                .reduce((a, b) => a.add(b))
            : 0,
        'BQ': finishedProductList.isNotEmpty
            ? finishedProductList.map((v) => {'BQID': v.label}).toList()
            : [],
        'ITEM': semiFinishedProductList.isNotEmpty
            ? semiFinishedProductList
                .map((v) => {
                      'ITEM_NO': '',
                      'MATNR': v.dataList.first.materialCode,
                      'MAKTX': v.dataList.first.materialName,
                      'MENGE': v.cumulativeQty(),
                      'BQ': v.dataList.first.label.isNullOrEmpty()
                          ? []
                          : v.dataList.map((v) => {'BQID': v.label}).toList()
                    })
                .toList()
            : [],
      },
    ).then((response) {
      if (response.resultCode == resultSuccess) {
        success.call(response.message??'');
      } else {
        error.call(response.message ?? 'query_default_error'.tr);
      }
    });
  }




}
