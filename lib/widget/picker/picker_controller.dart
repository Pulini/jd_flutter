import 'dart:convert';

import 'package:get/get.dart';

import '../../http/response/picker_item.dart';
import '../../http/web_api.dart';
import '../../utils.dart';

enum PickerType {
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
  mesWorkShop,
  mesDepartment,
  mesOrganization,
  mesProcessFlow,
  date,
  startDate,
  endDate,
}

abstract class PickerController {
  late PickerType pickerType;

  PickerController(this.pickerType);

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
      case PickerType.mesWorkShop:
        return 'picker_type_mes_work_shop'.tr;
      case PickerType.mesDepartment:
        return 'picker_type_mes_department'.tr;
      case PickerType.mesOrganization:
        return 'picker_type_mes_organization'.tr;
      case PickerType.mesProcessFlow:
        return 'picker_type_mes_process_flow'.tr;
      case PickerType.date:
        return 'picker_type_date'.tr;
      case PickerType.startDate:
        return 'picker_type_start_date'.tr;
      case PickerType.endDate:
        return 'picker_type_end_date'.tr;
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
      case PickerType.mesWorkShop:
        return getMesWorkShop;
      case PickerType.mesDepartment:
        return getMesDepartment;
      case PickerType.mesOrganization:
        return getMesOrganization;
      case PickerType.mesProcessFlow:
        return getMesProcessFlow;
      default:
        return getDataListError;
    }
  }
}

class OptionsPickerController extends PickerController {
  var selectedName = ''.obs;
  var selectedId = ''.obs;
  var loadingError = ''.obs;
  var enable = true.obs;
  List<PickerItem> pickerData = [];
  RxList<PickerItem> pickerItems = <PickerItem>[].obs;
  var selectItem = 0;

  OptionsPickerController(super.pickerType);

  select(String? saveKey, int item) {
    selectedName.value = pickerItems[item].pickerName();
    selectedId.value = pickerItems[item].pickerId();
    selectItem = item;
    if (saveKey != null && saveKey.isNotEmpty) {
      spSave(saveKey, pickerItems[item].pickerId());
    }
  }

  search(String text) {
    if (text.trim().isEmpty) {
      pickerItems.value = pickerData;
    } else {
      pickerItems.value = pickerData
          .where((element) => element.pickerName().contains(text))
          .toList();
    }
  }

  getSave(String? saveKey) {
    var select = selectItem;
    if (saveKey != null && saveKey.isNotEmpty) {
      var save = spGet(saveKey);
      if (save != null && save.isNotEmpty) {
        var find1 =
            pickerItems.indexWhere((element) => element.pickerId() == save);
        if (find1 >= 0) {
          select = find1;
        }
      }
    }
    return select;
  }

  getData(String? saveKey, Function? getDataList) {
    if (pickerItems.isEmpty) {
      loadingError.value = 'picker_loading'.tr;
      Function fun = getDataList ?? this.getDataList();
      fun().then((value) {
        if (value is List<PickerItem>) {
          loadingError.value = '';
          pickerData = value;
          pickerItems.value = value;
          if (value.length > 1) {
            var save = 0;
            if (saveKey != null && saveKey.isNotEmpty) {
              save = getSave(saveKey);
            }
            select(null, save);
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
  var selectedId = ''.obs;
  var loadingError = ''.obs;
  var enable = true.obs;
  List<PickerItem> pickerData = [];
  RxList<PickerItem> pickerItems1 = <PickerItem>[].obs;
  RxList<PickerItem> pickerItems2 = <PickerItem>[].obs;

  var selectItem1 = 0;
  var selectItem2 = 0;

  LinkOptionsPickerController(super.pickerType);

  select(String? saveKey, int item1, int item2) {
    if (pickerItems1.isEmpty) return;
    selectedName.value =
        '${pickerItems1[item1].pickerName()}-${pickerItems2[item2].pickerName()}';
    selectedId.value = pickerItems2[item2].pickerId();
    selectItem1 = item1;
    selectItem2 = item2;
    if (saveKey != null && saveKey.isNotEmpty) {
      spSave(saveKey,
          '${pickerItems1[item1].pickerId()}@@@${pickerItems2[item2].pickerId()}');
    }
  }

  refreshItem2(int index) {
    pickerItems2.value = (pickerItems1[index] as PickerSapFactoryAndWarehouse)
        .warehouseList as List<PickerItem>;
  }

  getSave(String? saveKey) {
    var select1 = selectItem1;
    var select2 = selectItem2;
    if (saveKey != null && saveKey.isNotEmpty) {
      String? key = spGet(saveKey);
      if (key != null && key.contains('@@@')) {
        var save = key.split('@@@');
        if (save.length == 2) {
          var find1 = pickerItems1
              .indexWhere((element) => element.pickerId() == save[0]);
          if (find1 >= 0) {
            select1 = find1;
            pickerItems2.value =
                (pickerItems1[find1] as PickerSapFactoryAndWarehouse)
                    .warehouseList as List<PickerItem>;
            if (pickerItems2.isNotEmpty) {
              var find2 = pickerItems2
                  .indexWhere((element) => element.pickerId() == save[1]);
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

  getData(String? saveKey, Function? getDataList) {
    if (pickerItems1.isEmpty && pickerItems2.isEmpty) {
      loadingError.value = 'picker_loading'.tr;
      Function fun = getDataList ?? this.getDataList();
      fun().then((value) {
        if (value is List<PickerItem>) {
          loadingError.value = '';
          pickerData = value;
          pickerItems1.value = value;
          if (value.length > 1) {
            pickerItems2.value = (value[0] as PickerSapFactoryAndWarehouse)
                .warehouseList as List<PickerItem>;
            var save = getSave(saveKey);
            select(null, save[0], save[1]);
          }
        } else {
          loadingError.value = value as String;
        }
      });
    }
  }

  search(String text) {
    if (text.trim().isEmpty) {
      pickerItems1.value = pickerData;
      pickerItems2.value =
          (pickerData[selectItem2] as PickerSapFactoryAndWarehouse)
              .warehouseList as List<PickerItem>;
    } else {
      pickerItems1.value = pickerData
          .where((element) =>
              element.pickerName().contains(text) ||
              (element as PickerSapFactoryAndWarehouse)
                  .warehouseList!
                  .any((element) => element.pickerName().contains(text)))
          .toList();
      if (pickerItems1.isNotEmpty) {
        for (var item1 in pickerItems1) {
          var newList = (item1 as PickerSapFactoryAndWarehouse)
              .warehouseList
              ?.where((element) => element.pickerName().contains(text))
              .toList();
          item1.warehouseList = newList;
        }
        pickerItems2.value = (pickerItems1[0] as PickerSapFactoryAndWarehouse)
            .warehouseList as List<PickerItem>;
      } else {
        pickerItems2.value = [];
      }
    }
  }
}

class DatePickerController extends PickerController {
  Rx<DateTime> pickDate = DateTime.now().obs;
  var enable = true.obs;

  DatePickerController(super.pickerType);

  select(String? saveKey, DateTime date) {
    pickDate.value = date;
    if (saveKey != null && saveKey.isNotEmpty) {
      spSave(saveKey, date.millisecondsSinceEpoch);
    }
  }

  getSave(String? saveKey) {
    DateTime time = DateTime.now();
    if (saveKey != null && saveKey.isNotEmpty) {
      int? save = spGet(saveKey);
      if (save != null) {
        time = DateTime.fromMillisecondsSinceEpoch(save);
      }
    }
    return time;
  }

  String getDateFormatYMD() {
    return '${pickDate.value.year}-${pickDate.value.month}-${pickDate.value.day}';
  }
}

Future getDataListError() async {
  return 'picker_type_error'.tr;
}

///获取Sap供应商列表
Future getSapSupplier() async {
  var response = await httpGet(method: webApiPickerSapSupplier);
  if (response.resultCode == resultSuccess) {
    try {
      List<PickerItem> list = [];
      for (var item in jsonDecode(response.data)) {
        list.add(PickerSapSupplier.fromJson(item));
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

///获取Sap公司列表
Future getSapCompany() async {
  var response = await httpGet(method: webApiPickerSapCompany);
  if (response.resultCode == resultSuccess) {
    try {
      List<PickerItem> list = [];
      for (var item in jsonDecode(response.data)) {
        list.add(PickerSapCompany.fromJson(item));
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

///获取Sap厂区列表
Future getSapFactory() async {
  var response = await httpGet(method: webApiPickerSapFactory);
  if (response.resultCode == resultSuccess) {
    try {
      List<PickerItem> list = [];
      for (var item in jsonDecode(response.data)) {
        list.add(PickerSapFactory.fromJson(item));
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

///获取Sap工作中心列表
Future getSapWorkCenter() async {
  var response = await httpGet(method: webApiPickerSapWorkCenter);
  if (response.resultCode == resultSuccess) {
    try {
      List<PickerItem> list = [];
      for (var item in jsonDecode(response.data)) {
        list.add(PickerSapWorkCenter.fromJson(item));
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

///获取Sap部门列表
Future getSapDepartment() async {
  var response = await httpGet(method: webApiPickerSapDepartment);
  if (response.resultCode == resultSuccess) {
    try {
      List<PickerItem> list = [];
      for (var item in jsonDecode(response.data)) {
        list.add(PickerSapDepartment.fromJson(item));
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

///获取Mes车间列表
Future getMesWorkShop() async {
  var response = await httpGet(method: webApiPickerMesWorkShop);
  if (response.resultCode == resultSuccess) {
    try {
      List<PickerItem> list = [];
      for (var item in jsonDecode(response.data)) {
        list.add(PickerMesWorkShop.fromJson(item));
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

///获取Mes部门列表
Future getMesDepartment() async {
  var response = await httpGet(
    method: webApiPickerMesDepartment,
    query: {'OrganizeID': userController.user.value!.organizeID ?? -1},
  );
  if (response.resultCode == resultSuccess) {
    try {
      List<PickerItem> list = [];
      for (var item in jsonDecode(response.data)) {
        list.add(PickerMesDepartment.fromJson(item));
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

///获取Mes组织列表
Future getMesOrganization() async {
  var response = await httpGet(method: webApiPickerMesOrganization);
  if (response.resultCode == resultSuccess) {
    try {
      List<PickerItem> list = [];
      for (var item in jsonDecode(response.data)) {
        list.add(PickerMesOrganization.fromJson(item));
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

///获取Sap制程列表
Future getSapProcessFlow() async {
  var response = await httpGet(method: webApiPickerSapProcessFlow);
  if (response.resultCode == resultSuccess) {
    try {
      List<PickerItem> list = [];
      for (var item in jsonDecode(response.data)) {
        list.add(PickerSapProcessFlow.fromJson(item));
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

///获取Mes制程列表
Future getMesProcessFlow() async {
  var response = await httpGet(method: webApiPickerMesProcessFlow);
  if (response.resultCode == resultSuccess) {
    try {
      List<PickerItem> list = [];
      for (var item in jsonDecode(response.data)) {
        list.add(PickerMesProcessFlow.fromJson(item));
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

///获取Sap机台列表
Future getSapMachine() async {
  var response = await httpGet(
    method: webApiPickerSapMachine,
    query: {'EmpID': userController.user.value?.empID ?? 0},
  );
  if (response.resultCode == resultSuccess) {
    try {
      List<PickerItem> list = [];
      for (var item in jsonDecode(response.data)) {
        list.add(PickerSapMachine.fromJson(item));
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

///获取Sap工作中心(新)列表
Future getSapWorkCenterNew() async {
  var response = await httpGet(
    method: webApiPickerSapWorkCenterNew,
    query: {
      'ShowType': 10,
      'UserID': userController.user.value?.userID ?? 0,
    },
  );
  if (response.resultCode == resultSuccess) {
    try {
      List<PickerItem> list = [];
      for (var item in jsonDecode(response.data)) {
        list.add(PickerSapWorkCenterNew.fromJson(item));
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

///获取Sap组别列表
Future getSapGroup() async {
  var response = await httpGet(
    method: webApiPickerSapGroup,
    query: {'EmpID': userController.user.value?.empID ?? 0},
  );
  if (response.resultCode == resultSuccess) {
    try {
      List<PickerItem> list = [];
      for (var item in jsonDecode(response.data)) {
        list.add(PickerSapGroup.fromJson(item));
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

///获取Sap工厂及仓库列表
Future getSapFactoryAndWarehouse() async {
  var response = await httpGet(method: webApiPickerSapFactoryAndWarehouse);
  if (response.resultCode == resultSuccess) {
    try {
      List<PickerItem> list = [];
      for (var item in jsonDecode(response.data)) {
        list.add(PickerSapFactoryAndWarehouse.fromJson(item));
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
