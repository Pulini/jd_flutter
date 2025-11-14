import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:jd_flutter/bean/http/response/base_data.dart';
import 'package:jd_flutter/bean/http/response/picking_material_order_info.dart';
import 'package:jd_flutter/bean/http/response/wait_picking_material_info.dart';
import 'package:jd_flutter/utils/utils.dart';
import 'package:jd_flutter/utils/web_api.dart';

class WaitPickingMaterialState {
  var queryParamOrderType = 0.obs;
  var queryParamAllCanPick = false.obs;
  var queryParamShowNoInventory = false.obs;
  var queryParamReceived = false.obs;
  var queryParamIsShowAll = false.obs;

  var companyDepartmentList = <CompanyInfo>[];
  DepartmentInfo? selectedDepartment;
  var queryParamDepartment = ''.obs;

  var orderList = <WaitPickingMaterialOrderInfo>[].obs;
  late WaitPickingMaterialOrderInfo detail;
  int detailSubIndex = -1;

  WaitPickingMaterialState();

  void getPickerInfo({
    required String pickerNumber,
    required Function() success,
    required Function(String) error,
  }) {
    sapPost(
      loading: 'wait_picking_material_order_querying_picker_info'.tr,
      method: webApiSapGetPickerInfo,
      body: {'USNAM': pickerNumber},
    ).then((response) {
      if (response.resultCode == resultSuccess) {
        companyDepartmentList = [
          for (var json in response.data) CompanyInfo.fromJson(json)
        ];
        queryParamDepartment.value=companyDepartmentList[0].companyName??'';
        success.call();
      } else {
        companyDepartmentList = [];
        error.call(response.message ?? 'query_default_error'.tr);
      }
    });
  }

  void queryPickingMaterialList({
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
    required Function(String) error,
  }) {
    httpPost(
      loading: 'wait_picking_material_order_getting_picking_material_data'.tr,
      method: webApiGetMaterialList,
      body: {
        'StartDate': startDate,
        'EndDate': endDate,
        'FactoryNumber': factory,
        'FactoryType': typeBody,
        'MoNo': instruction,
        'MaterialCode': materialCode,
        'IssueWarehouse': factoryWarehouse,
        'WorkshopWarehouse': workshopWarehouse,
        'CustomerPurchaseOrderNumber': clientPurchaseOrder,
        'PostingDate': postingDate,
        'AllAvailableMaterials': queryParamAllCanPick.value ? '1' : '0',
        'WarehouseKeeperNo': userInfo?.number,
        'MaterialCollectorNo': pickerNumber,
        'DisplayNoStock': queryParamShowNoInventory.value ? 'X' : '',
        'Type': queryParamOrderType.value,
        'SupplierNumber': supplier,
        'PurchasingDocuments': purchaseVoucher,
        'MachinedPartsRequiredQty': productionDemand,
        'ProcessFlow': processFlow,
        'Received': queryParamReceived.value ? 'X' : '',
        'IsShowAll': queryParamIsShowAll.value ? 'X' : '',
        'PickingDepartment': selectedDepartment?.departmentID ?? '',
      },
    ).then((response) {
      if (response.resultCode == resultSuccess) {
        compute(
          parseJsonToList<WaitPickingMaterialOrderInfo>,
          ParseJsonParams(
            response.data,
            WaitPickingMaterialOrderInfo.fromJson,
          ),
        ).then((list) {
          orderList.value = list;
        });
      } else {
        orderList.value = [];
        error.call(response.message ?? 'query_default_error'.tr);
      }
    });
  }

  void getMaterialInventory({
    required String factoryCode,
    required String materialCode,
    required Function(List<ImmediateInventoryInfo>) success,
    required Function(String) error,
  }) {
    httpGet(
      loading: 'wait_picking_material_order_getting_inventory_data'.tr,
      method: webApiGetMaterialInventoryList,
      params: {
        'FactoryCode': factoryCode,
        'MaterialCode': materialCode,
      },
    ).then((response) {
      if (response.resultCode == resultSuccess) {
        success.call([
          for (var json in response.data) ImmediateInventoryInfo.fromJson(json)
        ]);
      } else {
        error.call(response.message ?? 'query_default_error'.tr);
      }
    });
  }

  void submitPickingMaterial({
    required bool isMove,
    required bool isPosting,
    String? pickerNumber,
    String? pickerBase64,
    String? userBase64,
    required Function(String, String) success,
    required Function(String) error,
  }) {
    sapPost(
      loading: 'wait_picking_material_order_posting_picking_material'.tr,
      method: webApiSapSubmitPickingMaterialOrder,
      body: {
        'MOVE': isMove ? 'X' : '',
        'CREATE': isPosting ? '' : 'X',
        'GT_REQITEMS': [
          for (var item1 in orderList.where((v) => v.hasSelected()))
            ...item1.getSapPostBody(pickerNumber ?? '')
        ],
        'GT_PICTURE': [
          if (pickerBase64?.isNotEmpty == true)
            {
              'ZZKEYWORD': pickerNumber,
              'ZZITEMNO': 2,
              'ZZDATA': pickerBase64,
            },
          if (userBase64?.isNotEmpty == true)
            {
              'ZZKEYWORD': userInfo?.number,
              'ZZITEMNO': 1,
              'ZZDATA': userBase64,
            },
        ]
      },
    ).then((response) {
      if (response.resultCode == resultSuccess) {
        success.call(response.message ?? '', response.data);
      } else {
        error.call(response.message ?? 'query_default_error'.tr);
      }
    });
  }

  void getMaterialPrintInfo({
    required String orderNumber,
    required Function(PickingMaterialOrderPrintInfo) success,
    required Function(String) error,
  }) {
    sapPost(
      loading: 'wait_picking_material_order_getting_material_print_info'.tr,
      method: webApiSapGetMaterialPrintInfo,
      body: {'WOFNR': orderNumber},
    ).then((response) {
      if (response.resultCode == resultSuccess) {
        success.call(PickingMaterialOrderPrintInfo.fromJson(response.data));
      } else {
        error.call(response.message ?? 'query_default_error'.tr);
      }
    });
  }
}
