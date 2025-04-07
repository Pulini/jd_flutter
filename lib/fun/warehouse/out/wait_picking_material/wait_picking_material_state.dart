import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:jd_flutter/bean/http/response/base_data.dart';
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

  getPickerInfo({
    required String pickerNumber,
    required Function() success,
    required Function(String) error,
  }) {
    sapPost(
      loading: '正在提交领料...',
      method: webApiSapGetPickerInfo,
      body: {
        'USNAM': pickerNumber,
      },
    ).then((response) {
      if (response.resultCode == resultSuccess) {
        companyDepartmentList = [
          for (var json in response.data) CompanyInfo.fromJson(json)
        ];
        success.call();
      } else {
        companyDepartmentList = [];
        error.call(response.message ?? 'query_default_error'.tr);
      }
    });
  }

  queryPickingMaterialList({
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
      loading: '正在获取待领料数据...',
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
          debugPrint('list=${list.length}');
        });
      } else {
        error.call(response.message ?? 'query_default_error'.tr);
      }
    });
  }

  getMaterialInventory({
    required String factoryCode,
    required String materialCode,
    required Function(List<ImmediateInventoryInfo>) success,
    required Function(String) error,
  }) {
    httpGet(
      loading: '正在获取待领料数据...',
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

  submitPickingMaterial({
    required bool isMove,
    String? pickerNumber,
    String? pickerBase64,
    String? userBase64,
    required  Function(String) success,
    required Function(String) error,
  }) {
    var bodyMap = {
      'Move': isMove ? 'X' : '',
      'MaterialList': [
        for (var item1 in orderList.where((v) => v.hasSelected()))
          ...item1.getPostBody(pickerNumber??'')
      ],
      'PictureList': [
        if (pickerBase64?.isNotEmpty == true)
          {
            'EmpCode': pickerNumber,
            'Photo': pickerBase64,
          },
        if (userBase64?.isNotEmpty == true)
          {
            'EmpCode': userInfo?.number,
            'Photo': userBase64,
          }
      ]
    };
    success.call('123');
  }
}
