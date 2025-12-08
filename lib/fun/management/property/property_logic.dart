import 'package:get/get.dart';
import 'package:jd_flutter/fun/management/property/property_detail_view.dart';
import 'package:jd_flutter/utils/utils.dart';
import 'package:jd_flutter/widget/custom_widget.dart';
import 'package:jd_flutter/widget/dialogs.dart';

import 'property_state.dart';

class PropertyLogic extends GetxController {
  final PropertyState state = PropertyState();

  void queryProperty({
    required String propertyNumber,
    required String propertyName,
    required String serialNumber,
    required String invoiceNumber,
    required String name,
    required String workerNumber,
    required String startDate,
    required String endDate,
  }) {
    state.queryProperty(
      propertyNumber: propertyNumber,
      propertyName: propertyName,
      serialNumber: serialNumber,
      invoiceNumber: invoiceNumber,
      name: name,
      workerNumber: workerNumber,
      startDate: startDate,
      endDate: endDate,
      error: (msg) => errorDialog(content: msg),
    );
  }

  void getPropertyDetail(int detailId) {
    state.getPropertyDetail(
      detailId: detailId,
      success: () => Get.to(() => const PropertyDetailPage()),
      error: (msg) => errorDialog(content: msg),
    );
  }

  void setParticipator(String str) {
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

  void setCustodian(String str) {
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

  void setLiable(String str) {
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

  void propertyClose(int detailId) {
    state.propertyClose(
      detailId: detailId,
      success: (msg) => successDialog(content: msg),
      error: (msg) => errorDialog(content: msg),
    );
  }

  void skipAcceptance(int detailId) {
    state.skipAcceptance(
      detailId: detailId,
      success: (msg) => successDialog(content: msg),
      error: (msg) => errorDialog(content: msg),
    );
  }

  void updatePropertyInfo() {
    state.updatePropertyInfo(
      success: (msg) => successDialog(content: msg),
      error: (msg) => errorDialog(content: msg),
    );
  }

  bool checkData() {
    if (state.detail.name?.isEmpty == true) {
      showSnackBar(
        title: 'property_lack_data'.tr,
        message: '请输入名称',
        isWarning: true,
      );
      return false;
    }
    if (state.detail.number?.isEmpty == true) {
      showSnackBar(
        title: 'property_lack_data'.tr,
        message: '请输入编号',
        isWarning: true,
      );
      return false;
    }
    if (state.detail.model?.isEmpty == true) {
      showSnackBar(
        title: 'property_lack_data'.tr,
        message: '请输入规格型号',
        isWarning: true,
      );
      return false;
    }
    if (state.detail.price != null && state.detail.price! <= 0) {
      showSnackBar(
        title: 'property_lack_data'.tr,
        message: '请输入单价',
        isWarning: true,
      );
      return false;
    }
    if (state.detail.orgVal != null && state.detail.orgVal! <= 0) {
      showSnackBar(
        title: 'property_lack_data'.tr,
        message: '请输入原值',
        isWarning: true,
      );
      return false;
    }
    if (state.detail.manufacturer?.isEmpty == true) {
      showSnackBar(
        title: 'property_lack_data'.tr,
        message: '请输入制造商',
        isWarning: true,
      );
      return false;
    }
    if (state.detail.guaranteePeriod?.isEmpty == true) {
      showSnackBar(
        title: 'property_lack_data'.tr,
        message: '请输入保修期限(月)',
        isWarning: true,
      );
      return false;
    }
    if (state.detail.expectedLife != null && state.detail.expectedLife! <= 0) {
      showSnackBar(
        title: 'property_lack_data'.tr,
        message: '请输入预计使用时长(月)',
        isWarning: true,
      );
      return false;
    }
    if (state.detail.participator != null && state.detail.participator! == -1) {
      showSnackBar(
        title: 'property_lack_data'.tr,
        message: '请输入参检人工号',
        isWarning: true,
      );
      return false;
    }
    if (state.detail.keepEmpID != null && state.detail.keepEmpID! == -1) {
      showSnackBar(
        title: 'property_lack_data'.tr,
        message: '请输入保管人工号',
        isWarning: true,
      );
      return false;
    }
    if (state.detail.liableEmpID != null && state.detail.liableEmpID! == -1) {
      showSnackBar(
        title: 'property_lack_data'.tr,
        message: '请输入监管人工号',
        isWarning: true,
      );
      return false;
    }
    if (state.detail.writeDate?.isEmpty == true) {
      showSnackBar(
        title: 'property_lack_data'.tr,
        message: '请选择登记日期',
        isWarning: true,
      );
      return false;
    }
    if (state.detail.address?.isEmpty == true) {
      showSnackBar(
        title: 'property_lack_data'.tr,
        message: '请输入存放地点',
        isWarning: true,
      );
      return false;
    }
    if (state.assetPicture.isEmpty) {
      showSnackBar(
        title: 'property_lack_data'.tr,
        message: '请拍摄现场照片',
        isWarning: true,
      );
      return false;
    }
    if (state.ratingPlatePicture.isEmpty) {
      showSnackBar(
        title: 'property_lack_data'.tr,
        message: '请拍摄铭牌照片',
        isWarning: true,
      );
      return false;
    }
    return true;
  }

  void printLabel(int pageIndex) {
    var selectItem = [];
    switch (pageIndex) {
      case 0:
        selectItem = state.propertyList
            .where((v) => v.processStatus == '2' && v.isChecked)
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

  int interceptId(String mes) {
    if (mes.contains("FInterID=")) {
      return int.tryParse(mes.split("=")[1]) ?? 0;
    } else {
      return 0;
    }
  }

}
