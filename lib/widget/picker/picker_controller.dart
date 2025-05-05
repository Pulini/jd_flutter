import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:jd_flutter/bean/http/response/base_data.dart';
import 'package:jd_flutter/utils/utils.dart';
import 'package:jd_flutter/utils/web_api.dart';

import 'picker_item.dart';

enum PickerType {
  ghost,
  sapSupplier,
  sapCompany,
  sapFactory,
  sapWorkCenter,
  sapDepartment,
  sapProcessFlow,
  sapMachine,
  sapWorkCenterNew,
  sapGroup,
  sapFactoryWarehouse,
  sapWarehouseStorageLocation,
  mesWorkShop,
  mesDepartment,
  mesOrganization,
  mesProcessFlow,
  mesProductionReportType,
  mesMoldingPackAreaReportType,
  mesGroup,
  date,
  startDate,
  endDate,
  mesStockList,
  mesBillStockList
}

abstract class PickerController {
  late PickerType pickerType;
  late bool hasAll;

  PickerController(this.pickerType, {this.hasAll = false});

  String getButtonName() {
    switch (pickerType) {
      case PickerType.sapSupplier:
        return 'picker_type_sap_supplier'.tr;
      case PickerType.sapCompany:
        return 'picker_type_sap_company'.tr;
      case PickerType.sapFactory:
        return 'picker_type_sap_factory'.tr;
      case PickerType.sapWorkCenter:
        return 'picker_type_sap_work_center'.tr;
      case PickerType.sapDepartment:
        return 'picker_type_sap_department'.tr;
      case PickerType.sapProcessFlow:
        return 'picker_type_sap_process_flow'.tr;
      case PickerType.sapMachine:
        return 'picker_type_sap_machine'.tr;
      case PickerType.sapWorkCenterNew:
        return 'picker_type_sap_work_center_new'.tr;
      case PickerType.sapGroup:
        return 'picker_type_sap_group'.tr;
      case PickerType.sapFactoryWarehouse:
        return 'picker_type_sap_factory_warehouse'.tr;
      case PickerType.sapWarehouseStorageLocation:
        return 'picker_type_sap_warehouse_storage_location'.tr;
      case PickerType.mesWorkShop:
        return 'picker_type_mes_work_shop'.tr;
      case PickerType.mesDepartment:
        return 'picker_type_mes_department'.tr;
      case PickerType.mesOrganization:
        return 'picker_type_mes_organization'.tr;
      case PickerType.mesProcessFlow:
        return 'picker_type_mes_process_flow'.tr;
      case PickerType.mesProductionReportType:
        return 'picker_type_mes_production_report_type'.tr;
      case PickerType.mesMoldingPackAreaReportType:
        return 'picker_type_mes_molding_pack_area_report_type'.tr;
      case PickerType.mesGroup:
        return 'picker_type_mes_group'.tr;
      case PickerType.date:
        return 'picker_type_date'.tr;
      case PickerType.startDate:
        return 'picker_type_start_date'.tr;
      case PickerType.endDate:
        return 'picker_type_end_date'.tr;
      case PickerType.mesStockList:
        return 'picker_type_mes_stock_list'.tr;
      case PickerType.mesBillStockList:
        return 'picker_type_order_stock_list'.tr;
      default:
        return 'Picker';
    }
  }

  Function getDataList() {
    switch (pickerType) {
      case PickerType.sapSupplier:
        return getSapSupplier;
      case PickerType.sapCompany:
        return getSapCompany;
      case PickerType.sapFactory:
        return getSapFactory;
      case PickerType.sapWorkCenter:
        return getSapWorkCenter;
      case PickerType.sapDepartment:
        return getSapDepartment;
      case PickerType.sapProcessFlow:
        return getSapProcessFlow;
      case PickerType.sapMachine:
        return getSapMachine;
      case PickerType.sapWorkCenterNew:
        return getSapWorkCenterNew;
      case PickerType.sapGroup:
        return getSapGroup;
      case PickerType.sapFactoryWarehouse:
        return getSapFactoryAndWarehouse;
      case PickerType.sapWarehouseStorageLocation:
        return getSapWarehouseStorageLocation;
      case PickerType.mesWorkShop:
        return getMesWorkShop;
      case PickerType.mesDepartment:
        return getMesDepartment;
      case PickerType.mesOrganization:
        return getMesOrganization;
      case PickerType.mesProcessFlow:
        return getMesProcessFlow;
      case PickerType.mesProductionReportType:
        return getMesProductionReportType;
      case PickerType.mesMoldingPackAreaReportType:
        return getMesMoldingPackArea;
      case PickerType.mesGroup:
        return getMeGroup;
      case PickerType.mesStockList:
        return getMesStockList;
      case PickerType.mesBillStockList:
        return getOrderStockList;
      default:
        return getDataListError;
    }
  }

  Future getDataListError() async {
    return 'picker_type_error'.tr;
  }

  //获取Sap供应商列表
  Future getSapSupplier() async {
    var response = await httpGet(method: webApiPickerSapSupplier);
    if (response.resultCode == resultSuccess) {
      try {
        List<PickerItem> list = [
          if (hasAll) PickerSapSupplier(name: '全部', supplierNumber: '')
        ];
        list.addAll(await compute(
          parseJsonToList,
          ParseJsonParams(
            response.data,
            PickerSapSupplier.fromJson,
          ),
        ));
        return list;
      } on Error catch (e) {
        logger.e(e);
        return 'json_format_error'.tr;
      }
    } else {
      return response.message;
    }
  }

  //获取Sap公司列表
  Future getSapCompany() async {
    var response = await httpGet(method: webApiPickerSapCompany);
    if (response.resultCode == resultSuccess) {
      try {
        List<PickerItem> list = [];
        list.addAll(await compute(
          parseJsonToList,
          ParseJsonParams(
            response.data,
            PickerSapCompany.fromJson,
          ),
        ));
        return list;
      } on Error catch (e) {
        logger.e(e);
        return 'json_format_error'.tr;
      }
    } else {
      return response.message;
    }
  }

  //获取Sap厂区列表
  Future getSapFactory() async {
    var response = await httpGet(method: webApiPickerSapFactory);
    if (response.resultCode == resultSuccess) {
      try {
        List<PickerItem> list = [
          if (hasAll) PickerSapFactory(name: '全部', number: 0)
        ];
        list.addAll(await compute(
          parseJsonToList,
          ParseJsonParams(
            response.data,
            PickerSapFactory.fromJson,
          ),
        ));
        return list;
      } on Error catch (e) {
        logger.e(e);
        return 'json_format_error'.tr;
      }
    } else {
      return response.message;
    }
  }

  //获取Sap工作中心列表
  Future getSapWorkCenter() async {
    var response = await httpGet(method: webApiPickerSapWorkCenter);
    if (response.resultCode == resultSuccess) {
      try {
        List<PickerItem> list = [
          if (hasAll) PickerSapWorkCenter(name: '全部', number: '')
        ];
        list.addAll(await compute(
          parseJsonToList,
          ParseJsonParams(
            response.data,
            PickerSapWorkCenter.fromJson,
          ),
        ));
        return list;
      } on Error catch (e) {
        logger.e(e);
        return 'json_format_error'.tr;
      }
    } else {
      return response.message;
    }
  }

  //获取Sap部门列表
  Future getSapDepartment() async {
    var response = await httpGet(method: webApiPickerSapDepartment);
    if (response.resultCode == resultSuccess) {
      try {
        List<PickerItem> list = [
          if (hasAll)
            PickerSapDepartment(name: '全部', departmentId: 0, number: '')
        ];
        list.addAll(await compute(
          parseJsonToList,
          ParseJsonParams(
            response.data,
            PickerSapDepartment.fromJson,
          ),
        ));
        return list;
      } on Error catch (e) {
        logger.e(e);
        return 'json_format_error'.tr;
      }
    } else {
      return response.message;
    }
  }

  //获取Mes车间列表
  Future getMesWorkShop() async {
    var response = await httpGet(method: webApiPickerMesWorkShop);
    if (response.resultCode == resultSuccess) {
      try {
        List<PickerItem> list = [
          if (hasAll)
            PickerMesWorkShop(name: '全部', number: '', processFlowId: 0)
        ];
        list.addAll(await compute(
          parseJsonToList,
          ParseJsonParams(
            response.data,
            PickerMesWorkShop.fromJson,
          ),
        ));
        return list;
      } on Error catch (e) {
        logger.e(e);
        return 'json_format_error'.tr;
      }
    } else {
      return response.message;
    }
  }

  //获取Mes部门列表
  Future getMesDepartment() async {
    var response = await httpGet(
      method: webApiPickerMesDepartment,
      params: {'OrganizeID': userInfo?.organizeID ?? -1},
    );
    if (response.resultCode == resultSuccess) {
      try {
        List<PickerItem> list = [
          if (hasAll)
            PickerMesDepartment(name: '全部', number: '', departmentId: 0)
        ];
        list.addAll(await compute(
          parseJsonToList,
          ParseJsonParams(
            response.data,
            PickerMesDepartment.fromJson,
          ),
        ));
        return list;
      } on Error catch (e) {
        logger.e(e);
        return 'json_format_error'.tr;
      }
    } else {
      return response.message;
    }
  }

  //获取Mes组织列表
  Future getMesOrganization() async {
    var response = await httpGet(method: webApiPickerMesOrganization);
    if (response.resultCode == resultSuccess) {
      try {
        List<PickerItem> list = [
          if (hasAll)
            PickerMesOrganization(
                itemId: 0, code: '', name: '全部', number: '', adminOrganizeId: 0)
        ];
        list.addAll(await compute(
          parseJsonToList,
          ParseJsonParams(
            response.data,
            PickerMesOrganization.fromJson,
          ),
        ));
        return list;
      } on Error catch (e) {
        logger.e(e);
        return 'json_format_error'.tr;
      }
    } else {
      return response.message;
    }
  }

  //获取Sap制程列表
  Future getSapProcessFlow() async {
    var response = await httpGet(method: webApiPickerSapProcessFlow);
    if (response.resultCode == resultSuccess) {
      try {
        List<PickerItem> list = [
          if (hasAll) PickerSapProcessFlow(name: '全部', number: '')
        ];
        list.addAll(await compute(
          parseJsonToList,
          ParseJsonParams(
            response.data,
            PickerSapProcessFlow.fromJson,
          ),
        ));
        return list;
      } on Error catch (e) {
        logger.e(e);
        return 'json_format_error'.tr;
      }
    } else {
      return response.message;
    }
  }

  //获取Mes制程列表
  Future getMesProcessFlow() async {
    var response = await httpGet(method: webApiPickerMesProcessFlow);
    if (response.resultCode == resultSuccess) {
      try {
        List<PickerItem> list = [
          if (hasAll) PickerMesProcessFlow(name: '', processFlowId: 0)
        ];
        list.addAll(await compute(
          parseJsonToList,
          ParseJsonParams(
            response.data,
            PickerMesProcessFlow.fromJson,
          ),
        ));
        return list;
      } on Error catch (e) {
        logger.e(e);
        return 'json_format_error'.tr;
      }
    } else {
      return response.message;
    }
  }

  //获取Mes生产计件报表类型
  Future getMesProductionReportType() async {
    var response = await httpGet(
      method: webApiGetProductionReportType,
      params: {'SearchType': 'app'},
    );
    if (response.resultCode == resultSuccess) {
      try {
        List<PickerItem> list = [
          if (hasAll) PickerMesProductionReportType(itemID: 0, itemName: '全部')
        ];
        list.addAll(await compute(
          parseJsonToList,
          ParseJsonParams(
            response.data,
            PickerMesProductionReportType.fromJson,
          ),
        ));
        return list;
      } on Error catch (e) {
        logger.e(e);
        return 'json_format_error'.tr;
      }
    } else {
      return response.message;
    }
  }

  //获取Sap机台列表
  Future getSapMachine() async {
    var response = await httpGet(
      method: webApiPickerSapMachine,
      params: {'EmpID': userInfo?.empID ?? 0},
    );
    if (response.resultCode == resultSuccess) {
      try {
        List<PickerItem> list = [
          if (hasAll)
            PickerSapMachine(
              id: 0,
              number: '',
              name: '全部',
              sapNumber: '',
              sapCostCenterNumber: '',
            )
        ];
        list.addAll(await compute(
          parseJsonToList,
          ParseJsonParams(
            response.data,
            PickerSapMachine.fromJson,
          ),
        ));
        return list;
      } on Error catch (e) {
        logger.e(e);
        return 'json_format_error'.tr;
      }
    } else {
      return response.message;
    }
  }

  //获取Sap工作中心(新)列表
  Future getSapWorkCenterNew() async {
    var response = await httpGet(
      method: webApiPickerSapWorkCenterNew,
      params: {
        'ShowType': 10,
        'UserID': userInfo?.userID ?? 0,
      },
    );
    if (response.resultCode == resultSuccess) {
      try {
        List<PickerItem> list = [
          if (hasAll) PickerSapWorkCenterNew(name: '全部', number: '')
        ];
        list.addAll(await compute(
          parseJsonToList,
          ParseJsonParams(
            response.data,
            PickerSapWorkCenterNew.fromJson,
          ),
        ));
        return list;
      } on Error catch (e) {
        logger.e(e);
        return 'json_format_error'.tr;
      }
    } else {
      return response.message;
    }
  }

  //获取Sap组别列表
  Future getSapGroup() async {
    var response = await httpGet(
      method: webApiPickerSapGroup,
      params: {'EmpID': userInfo?.empID ?? 0},
    );
    if (response.resultCode == resultSuccess) {
      try {
        List<PickerItem> list = [
          if (hasAll) PickerSapGroup(name: '全部', itemId: 0)
        ];
        list.addAll(await compute(
          parseJsonToList,
          ParseJsonParams(
            response.data,
            PickerSapGroup.fromJson,
          ),
        ));
        return list;
      } on Error catch (e) {
        logger.e(e);
        return 'json_format_error'.tr;
      }
    } else {
      return response.message;
    }
  }

  //获取Sap工厂及仓库列表
  Future getSapFactoryAndWarehouse() async {
    var response = await httpGet(method: webApiPickerSapFactoryAndWarehouse);
    if (response.resultCode == resultSuccess) {
      try {
        List<LinkPickerItem> list = [
          if (hasAll)
            PickerSapFactoryAndWarehouse(
              name: '全部',
              number: '',
              warehouseList: [
                PickerSapWarehouse(
                  warehouseName: '全部',
                  warehouseNumber: '',
                  warehouseId: '',
                )
              ],
            )
        ];

        list.addAll(await compute(
          parseJsonToList,
          ParseJsonParams(
            response.data,
            PickerSapFactoryAndWarehouse.fromJson,
          ),
        ));
        if (hasAll) {
          for (var v in list) {
            (v as PickerSapFactoryAndWarehouse).warehouseList = [
              PickerSapWarehouse(
                warehouseName: '全部',
                warehouseNumber: '',
                warehouseId: '',
              ),
              ...v.warehouseList!
            ];
          }
        }
        return list;
      } on Error catch (e) {
        logger.e(e);
        return 'json_format_error'.tr;
      }
    } else {
      return response.message;
    }
  }

  //获取Mes包装区域列表
  Future getMesMoldingPackArea() async {
    var response = await httpGet(method: webApiGetPickerMesMoldingPackArea);
    if (response.resultCode == resultSuccess) {
      try {
        List<PickerItem> list = [
          if (hasAll) PickerMesMoldingPackArea(id: 0, name: '全部')
        ];
        list.addAll(await compute(
          parseJsonToList,
          ParseJsonParams(
            response.data,
            PickerMesMoldingPackArea.fromJson,
          ),
        ));
        return list;
      } on Error catch (e) {
        logger.e(e);
        return 'json_format_error'.tr;
      }
    } else {
      return response.message;
    }
  }

  //获取Sap仓库库位列表
  Future getSapWarehouseStorageLocation() async {
    var response = await httpGet(
      method: webApiPickerSapWarehouseStorageLocation,
      params: {
        'factory': userInfo?.factory,
        'warehouse': userInfo?.defaultStockNumber,
      },
    );
    if (response.resultCode == resultSuccess) {
      try {
        List<PickerItem> list = [];
        list.addAll(await compute(
          parseJsonToList,
          ParseJsonParams(
            response.data,
            PickerSapWarehouseLocation.fromJson,
          ),
        ));
        return list;
      } on Error catch (e) {
        logger.e(e);
        return 'json_format_error'.tr;
      }
    } else {
      return response.message;
    }
  }

  //获取Sap仓库库位列表
  Future getMeGroup() async {
    var response = await httpGet(
      method: webApiPickerMesGroup,
      params: {'UserID': userInfo?.userID},
    );
    if (response.resultCode == resultSuccess) {
      try {
        List<PickerItem> list = [
          if (hasAll)
            PickerMesGroup(
              departmentID: 0,
              departmentNumber: '',
              departmentName: '全部',
            )
        ];
        list.addAll(await compute(
          parseJsonToList,
          ParseJsonParams(
            response.data,
            PickerMesGroup.fromJson,
          ),
        ));
        return list;
      } on Error catch (e) {
        logger.e(e);
        return 'json_format_error'.tr;
      }
    } else {
      return response.message;
    }
  }

  //获取Mes仓库
  Future getMesStockList() async {
    var response = await httpGet(method: webApiPickerMesStockList, params: {
      'OrganizeID': userInfo?.organizeID,
    });
    if (response.resultCode == resultSuccess) {
      try {
        List<LinkPickerItem> list = [
          if (hasAll)
            MesStockInfo(
              itemID: -1,
              name: '全部',
              stockList: [StockItem(itemID: -1, name: '全部')],
            )
        ];
        list.addAll(await compute(
          parseJsonToList<MesStockInfo>,
          ParseJsonParams<MesStockInfo>(
            response.data,
            MesStockInfo.fromJson,
          ),
        ));
        return list;
      } on Error catch (e) {
        logger.e(e);
        return 'json_format_error'.tr;
      }
    } else {
      return response.message;
    }
  }

  //获取单据对应仓库列表
  Future getOrderStockList() async {
    var response = await httpGet(method: webApiPickerOrderStockList, params: {
      'UserID': userInfo?.userID,
      'ReportType': 1,
    });
    if (response.resultCode == resultSuccess) {
      try {
        List<PickerItem> list = [];
        list.addAll(await compute(
          parseJsonToList,
          ParseJsonParams(
            response.data,
            OrderStockItem.fromJson,
          ),
        ));
        return list;
      } on Error catch (e) {
        logger.e(e);
        return 'json_format_error'.tr;
      }
    } else {
      return response.message;
    }
  }
}

class OptionsPickerController extends PickerController {
  var selectedName = ''.obs;
  var selectedId = ''.obs;
  var loadingError = ''.obs;
  var enable = true.obs;
  String searchText = '';
  final String? saveKey;
  final String? buttonName;
  final Function? dataList;
  List<PickerItem> pickerData = [];
  RxList<PickerItem> pickerItems = <PickerItem>[].obs;
  var selectItem = 0;
  final Function(PickerItem)? onChanged;
  final Function(PickerItem)? onSelected;
  String initId;

  OptionsPickerController(
    super.pickerType, {
    super.hasAll,
    this.saveKey,
    this.buttonName,
    this.dataList,
    this.onChanged,
    this.onSelected,
    this.initId = '',
  });

  select(int item) {
    selectedName.value = pickerItems[item].pickerName();
    selectedId.value = pickerItems[item].pickerId();
    selectItem = pickerData.indexWhere((v) => v.pickerId() == selectedId.value);
    if (saveKey != null && saveKey!.isNotEmpty) {
      spSave(saveKey!, pickerItems[item].pickerId());
    }
    onSelected?.call(pickerItems[selectItem]);
    onChanged?.call(pickerItems[selectItem]);
  }

  search(String text) {
    searchText = text;
    if (text.trim().isEmpty) {
      pickerItems.value = pickerData;
    } else {
      pickerItems.value = pickerData
          .where(
            (v) => v.toShow().toUpperCase().contains(text.toUpperCase()),
          )
          .toList();
    }
  }

  int getSave() {
    var select = selectItem;
    if (initId.isEmpty) {
      if (saveKey != null && saveKey!.isNotEmpty) {
        var save = spGet(saveKey!);
        if (save != null && save.isNotEmpty) {
          var find1 =
              pickerItems.indexWhere((element) => element.pickerId() == save);
          if (find1 >= 0) {
            select = find1;
          }
        }
      }
    } else {
      var index = pickerItems.indexWhere((v) => v.pickerId() == initId);
      if (index != -1) select = index;
    }
    return select;
  }

  getData() {
    if (pickerItems.isEmpty) {
      loadingError.value = 'picker_loading'.tr;
      Function fun = dataList ?? getDataList();
      fun().then((value) {
        if (value is List<PickerItem>) {
          loadingError.value = '';
          pickerData = value;
          pickerItems.value = value;
          if (value.isNotEmpty) {
            var save = getSave();
            selectedName.value = pickerItems[save].pickerName();
            selectedId.value = pickerItems[save].pickerId();
            selectItem = save;
            onSelected?.call(pickerItems[selectItem]);
          }
        } else {
          loadingError.value = value as String;
        }
      });
    }
  }
}

class LinkOptionsPickerController extends PickerController {
  var selectedName = ''.obs;
  var loadingError = ''.obs;
  var enable = true.obs;
  List<LinkPickerItem> pickerData = [];
  RxList<PickerItem> pickerItems1 = <PickerItem>[].obs;
  RxList<PickerItem> pickerItems2 = <PickerItem>[].obs;
  String searchText = '';
  var selectItem1 = 0;
  var selectItem2 = 0;

  final String? saveKey;
  final String? buttonName;
  final Function? dataList;
  final Function(PickerItem, PickerItem)? onChanged;
  final Function(PickerItem, PickerItem)? onSelected;

  LinkOptionsPickerController(
    super.pickerType, {
    super.hasAll,
    this.saveKey,
    this.buttonName,
    this.dataList,
    this.onChanged,
    this.onSelected,
  });

  PickerItem getOptionsPicker1() => pickerData[selectItem1];

  PickerItem getOptionsPicker2() =>
      pickerData[selectItem1].subList()[selectItem2];

  select(int item1, int item2) {
    if (pickerItems1.isEmpty) return;
    var pick1 = pickerItems1[item1];
    var pick2 = pickerItems2[item2];
    selectedName.value = '${pick1.pickerName()}-${pick2.pickerName()}';
    selectItem1 =
        pickerItems1.indexWhere((v) => v.pickerId() == pick1.pickerId());
    selectItem2 = pickerData[selectItem1]
        .subList()
        .indexWhere((v) => v.pickerId() == pick2.pickerId());
    if (saveKey != null && saveKey!.isNotEmpty) {
      spSave(saveKey!, '${pick1.pickerId()}@@@${pick2.pickerId()}');
    }
    onSelected?.call(getOptionsPicker1(), getOptionsPicker2());
    onChanged?.call(getOptionsPicker1(), getOptionsPicker2());
  }

  refreshItem2(int index) {
    if (searchText.isNotEmpty) {
      var list = (pickerItems1[index] as LinkPickerItem).subList();
      var searchList = list
          .where((v) =>
              v.toShow().toUpperCase().contains(searchText.toUpperCase()))
          .toList();
      if (searchList.isEmpty) {
        pickerItems2.value = list;
      } else {
        pickerItems2.value = searchList;
      }
    } else {
      pickerItems2.value = (pickerItems1[index] as LinkPickerItem).subList();
    }
  }

  List<int> getSave() {
    var select1 = selectItem1;
    var select2 = selectItem2;
    if (saveKey != null && saveKey!.isNotEmpty) {
      String? key = spGet(saveKey!);
      if (key != null && key.contains('@@@')) {
        var save = key.split('@@@');
        if (save.length == 2) {
          var find1 =
              pickerData.indexWhere((element) => element.pickerId() == save[0]);
          if (find1 >= 0) {
            select1 = find1;
            var list = pickerData[find1].subList();
            if (list.isNotEmpty) {
              var find2 =
                  list.indexWhere((element) => element.pickerId() == save[1]);
              if (find2 >= 0) {
                select2 = find2;
              }
            }
          }
        }
      }
    }
    return [select1, select2];
  }

  getData() {
    if (pickerItems1.isEmpty && pickerItems2.isEmpty) {
      loadingError.value = 'picker_loading'.tr;
      Function fun = dataList ?? getDataList();
      fun().then((value) {
        if (value is List<LinkPickerItem>) {
          loadingError.value = '';
          pickerData = value;
          pickerItems1.value = pickerData;
          if (pickerData.length > 1) {
            var save = getSave();
            selectItem1 = save[0];
            selectItem2 = save[1];
            var pick1 = pickerItems1[selectItem1];
            pickerItems2.value = pickerData[selectItem1].subList();
            var pick2 = pickerItems2[selectItem2];
            selectedName.value = '${pick1.pickerName()}-${pick2.pickerName()}';
            onSelected?.call(getOptionsPicker1(), getOptionsPicker2());
          }
        } else {
          loadingError.value = value as String;
        }
      });
    }
  }

  search(String text) {
    searchText = text;
    if (text.trim().isEmpty && pickerData.isNotEmpty) {
      pickerItems1.value = pickerData;
      pickerItems2.value = pickerData[selectItem1].subList();
    } else {
      pickerItems1.value = pickerData
          .where(
            (v1) =>
                v1.toShow().toUpperCase().contains(text.toUpperCase()) ||
                v1.subList().any((v2) =>
                    v2.toShow().toUpperCase().contains(text.toUpperCase())),
          )
          .toList();
      if (pickerItems1.isNotEmpty) {
        var list = (pickerItems1[0] as LinkPickerItem).subList();
        var searchList = list
            .where((v) => v.toShow().toUpperCase().contains(text.toUpperCase()))
            .toList();
        if (searchList.isEmpty) {
          pickerItems2.value = list;
        } else {
          pickerItems2.value = searchList;
        }
      } else {
        pickerItems2.value = [];
      }
    }
  }
}

class DatePickerController extends PickerController {
  Rx<DateTime> pickDate = DateTime.now().obs;
  var enable = true.obs;
  final String? saveKey;
  DateTime firstDate = DateTime(
      DateTime.now().year - 1, DateTime.now().month, DateTime.now().day);
  DateTime lastDate = DateTime(
      DateTime.now().year, DateTime.now().month, DateTime.now().day + 7);
  final String? buttonName;
  int initDate;
  final Function(DateTime)? onChanged;
  final Function(DateTime)? onSelected;

  DatePickerController(
    super.pickerType, {
    this.saveKey,
    DateTime? firstDate,
    DateTime? lastDate,
    this.buttonName,
    this.onChanged,
    this.onSelected,
    this.initDate = 0,
  }) {
    var save = initDate > 0
        ? DateTime.fromMillisecondsSinceEpoch(initDate)
        : getSave();
    if (firstDate != null) this.firstDate = firstDate;
    if (lastDate != null) this.lastDate = lastDate;
    if (this.firstDate.isAfter(save) == true) {
      pickDate.value = this.firstDate;
    } else {
      pickDate.value = save;
    }
    onSelected?.call(pickDate.value);
  }

  select(DateTime date) {
    pickDate.value = date;
    if (saveKey != null && saveKey!.isNotEmpty) {
      spSave(saveKey!, date.millisecondsSinceEpoch);
    }
    onSelected?.call(date);
    onChanged?.call(date);
  }

  DateTime getSave() {
    DateTime time = pickDate.value;
    if (saveKey != null && saveKey!.isNotEmpty) {
      int? save = spGet(saveKey!);
      if (save != null) {
        time = DateTime.fromMillisecondsSinceEpoch(save);
      }
    }
    return time;
  }

  String getDateFormatYMD() {
    return getDateYMD(time: pickDate.value);
  }

  String getDateFormatSapYMD() {
    return getDateSapYMD(time: pickDate.value);
  }
}

class CheckBoxPickerController extends PickerController {
  var isSelectAll = false.obs;
  var selectedText = 'CheckBox'.obs;
  var selectedIds = <String>[];
  var loadingError = ''.obs;
  var enable = true.obs;
  var checkboxData = <PickerItem>[];
  var checkboxItems = <PickerItem>[].obs;

  final String? saveKey;
  final String? buttonName;
  final Function? dataList;
  final Function(List<String>)? onChanged;
  final Function(List<String>)? onSelected;

  CheckBoxPickerController(
    super.pickerType, {
    this.saveKey,
    this.buttonName,
    this.dataList,
    this.onChanged,
    this.onSelected,
  });

  select() {
    var list = checkboxItems
        .where((v) => (v as PickerMesMoldingPackArea).isChecked)
        .toList();
    var text = '';
    selectedIds.clear();
    for (var s in list) {
      text += '${s.pickerName()}  ';
      selectedIds.add(s.pickerId());
    }
    selectedText.value = text.substring(0, text.length - 1);
    if (saveKey != null && saveKey!.isNotEmpty) {
      spSave(saveKey!, selectedIds);
    }
    onSelected?.call(selectedIds);
    onChanged?.call(selectedIds);
  }

  search(String text) {
    if (text.trim().isEmpty) {
      checkboxItems.value = checkboxData;
    } else {
      checkboxItems.value = checkboxData
          .where(
            (v) => v.toShow().toUpperCase().contains(text.toUpperCase()),
          )
          .toList();
    }
    refreshCheckedAll();
  }

  refreshCheckedAll() {
    isSelectAll.value =
        checkboxItems.every((v) => (v as PickerMesMoldingPackArea).isChecked);
  }

  refreshCheckedList(bool checked) {
    isSelectAll.value = checked;
    for (var v in checkboxItems) {
      (v as PickerMesMoldingPackArea).isChecked = checked;
    }
    checkboxItems.refresh();
  }

  refreshCheckedItem(int index, bool checked) {
    (checkboxItems[index] as PickerMesMoldingPackArea).isChecked = checked;
    checkboxItems.refresh();
    refreshCheckedAll();
  }

  List<PickerItem> getSave() {
    var list = <PickerItem>[];
    if (saveKey != null && saveKey!.isNotEmpty) {
      List<String> save = spGet(saveKey!) ?? <String>[];
      for (var s in save) {
        var item = checkboxData.firstWhereOrNull((e) => e.pickerId() == s);
        if (item != null) {
          list.add(item);
        }
      }
    }
    return list;
  }

  initSelectState() {
    for (var s in checkboxItems) {
      (s as PickerMesMoldingPackArea).isChecked = false;
    }
    for (var s in getSave()) {
      (checkboxItems.firstWhere((v) => v.pickerId() == s.pickerId())
              as PickerMesMoldingPackArea)
          .isChecked = true;
    }
    checkboxItems.refresh();
    refreshCheckedAll();
  }

  getData() {
    if (checkboxItems.isEmpty) {
      loadingError.value = 'picker_loading'.tr;
      Function fun = dataList ?? getDataList();
      fun().then((value) {
        if (value is List<PickerItem>) {
          loadingError.value = '';
          checkboxData = value;
          checkboxItems.value = value;
          if (value.length > 1) {
            var save = getSave();
            if (save.isEmpty) {
              (checkboxItems[0] as PickerMesMoldingPackArea).isChecked = true;
              save.add(checkboxItems[0]);
            }
            var text = '';
            selectedIds.clear();
            for (var s in save) {
              text += '${s.pickerName()}  ';
              selectedIds.add(s.pickerId());
              (checkboxItems.firstWhere((v) => v.pickerId() == s.pickerId())
                      as PickerMesMoldingPackArea)
                  .isChecked = true;
            }
            selectedText.value = text.substring(0, text.length - 1);
            onSelected?.call(selectedIds);
          }
        } else {
          loadingError.value = value as String;
        }
      });
    } else {
      initSelectState();
    }
  }
}
