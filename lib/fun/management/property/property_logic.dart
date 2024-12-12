import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jd_flutter/fun/management/property/property_detail_view.dart';

import '../../../route.dart';
import '../../../utils/utils.dart';
import '../../../utils/web_api.dart';
import '../../../widget/custom_widget.dart';
import '../../../widget/dialogs.dart';
import '../../../widget/picker/picker_controller.dart';
import 'property_state.dart';

class PropertyLogic extends GetxController
    with GetSingleTickerProviderStateMixin {
  final PropertyState state = PropertyState();

  ///tab控制器
  late TabController tabController = TabController(length: 3, vsync: this);

  ///日期选择器的控制器
  var pickerControllerStartDate = DatePickerController(
    PickerType.startDate,
    saveKey: '${RouteConfig.property.name}${PickerType.startDate}',
  );

  ///日期选择器的控制器
  var pickerControllerEndDate = DatePickerController(
    PickerType.endDate,
    saveKey: '${RouteConfig.property.name}${PickerType.endDate}',
  );

  @override
  void onReady() {
    super.onReady();
    queryProperty();
  }

  queryProperty() {
    state.queryProperty(
      startDate: pickerControllerStartDate.getDateFormatYMD(),
      endDate: pickerControllerEndDate.getDateFormatYMD(),
      error: (msg) => errorDialog(content: msg),
    );
  }

  getPropertyDetail(int detailId) {
    state.getPropertyDetail(
      detailId: detailId,
      success: () => Get.to(() => const PropertyDetailPage()),
      error: (msg) => errorDialog(content: msg),
    );
  }

  setParticipator(String str) {
    if (str.length >= 6) {
      getWorkerInfo(
        number: str,
        workers: (list) {
          state.setParticipator(
            empCode: list[0].empCode ?? '',
            empName: list[0].empName ?? '',
            empID: list[0].empID ?? -1,
          );
        },
        error: (msg) => errorDialog(content: msg),
      );
    } else {
      state.setParticipator();
    }
  }

  setCustodian(String str) {
    if (str.length >= 6) {
      getWorkerInfo(
        number: str,
        workers: (list) {
          state.setCustodian(
            empCode: list[0].empCode ?? '',
            empName: list[0].empName ?? '',
            empID: list[0].empID ?? -1,
          );
        },
        error: (msg) => errorDialog(content: msg),
      );
    } else {
      state.setCustodian();
    }
  }

  setLiable(String str) {
    if (str.length >= 6) {
      getWorkerInfo(
        number: str,
        workers: (list) {
          state.setLiable(
            empCode: list[0].empCode ?? '',
            empName: list[0].empName ?? '',
            empID: list[0].empID ?? -1,
          );
        },
        error: (msg) => errorDialog(content: msg),
      );
    } else {
      state.setLiable();
    }
  }

  propertyClose(int detailId) {
    state.propertyClose(
      detailId: detailId,
      success: (msg) => successDialog(content: msg),
      error: (msg) => errorDialog(content: msg),
    );
  }

  skipAcceptance(int detailId) {
    state.skipAcceptance(
      detailId: detailId,
      success: (msg) => successDialog(content: msg),
      error: (msg) => errorDialog(content: msg),
    );
  }

  updatePropertyInfo() {
    state.updatePropertyInfo(
      success: (msg) => successDialog(content: msg),
      error: (msg) => errorDialog(content: msg),
    );
  }

  bool checkData() {
    logger.f(state.detail.toJson());
    if (state.detail.name?.isEmpty == true) {
      showSnackBar(title: '缺少数据', message: '请输入名称', isWarning: true);
      return false;
    }
    if (state.detail.number?.isEmpty == true) {
      showSnackBar(title: '缺少数据', message: '请输入编号', isWarning: true);
      return false;
    }
    if (state.detail.model?.isEmpty == true) {
      showSnackBar(title: '缺少数据', message: '请输入规格型号', isWarning: true);
      return false;
    }
    if (state.detail.price != null && state.detail.price! <= 0) {
      showSnackBar(title: '缺少数据', message: '请输入单价', isWarning: true);
      return false;
    }
    if (state.detail.orgVal != null && state.detail.orgVal! <= 0) {
      showSnackBar(title: '缺少数据', message: '请输入原值', isWarning: true);
      return false;
    }
    if (state.detail.manufacturer?.isEmpty == true) {
      showSnackBar(title: '缺少数据', message: '请输入制造商', isWarning: true);
      return false;
    }
    if (state.detail.guaranteePeriod?.isEmpty == true) {
      showSnackBar(title: '缺少数据', message: '请输入保修期限(月)', isWarning: true);
      return false;
    }
    if (state.detail.expectedLife != null && state.detail.expectedLife! <= 0) {
      showSnackBar(title: '缺少数据', message: '请输入预计使用时长(月)', isWarning: true);
      return false;
    }
    if (state.detail.participator != null && state.detail.participator! == -1) {
      showSnackBar(title: '缺少数据', message: '请输入参检人工号', isWarning: true);
      return false;
    }
    if (state.detail.keepEmpID != null && state.detail.keepEmpID! == -1) {
      showSnackBar(title: '缺少数据', message: '请输入保管人工号', isWarning: true);
      return false;
    }
    if (state.detail.liableEmpID != null && state.detail.liableEmpID! == -1) {
      showSnackBar(title: '缺少数据', message: '请输入监管人工号', isWarning: true);
      return false;
    }
    if (state.detail.writeDate?.isEmpty == true) {
      showSnackBar(title: '缺少数据', message: '请选择登记日期', isWarning: true);
      return false;
    }
    if (state.detail.address?.isEmpty == true) {
      showSnackBar(title: '缺少数据', message: '请输入存放地点', isWarning: true);
      return false;
    }
    if (state.assetPicture.isEmpty) {
      showSnackBar(title: '缺少数据', message: '请拍摄现场照片', isWarning: true);
      return false;
    }
    if (state.ratingPlatePicture.isEmpty) {
      showSnackBar(title: '缺少数据', message: '请拍摄铭牌照片', isWarning: true);
      return false;
    }
    return true;
  }

  printLabel() {
    var selectItem = [];
    switch (tabController.index) {
      case 0:
        selectItem = state.propertyList
            .where((v) => v.processStatus == "2" && v.isChecked)
            .toList();
        break;
      case 1:
        selectItem = state.propertyList
            .where((v) => v.processStatus == "0" && v.isChecked)
            .toList();
        break;
      case 2:
        selectItem = state.propertyList
            .where((v) => v.processStatus == "1" && v.isChecked)
            .toList();
        break;
    }
    if (selectItem.isEmpty) {
      errorDialog(content: 'property_print_no_selected'.tr);
      return;
    }
  }
}
