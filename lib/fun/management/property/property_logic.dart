import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jd_flutter/fun/management/property/property_detail_view.dart';
import '../../../bean/http/response/property_detail_info.dart';
import '../../../bean/http/response/property_info.dart';
import '../../../web_api.dart';
import '../../../route.dart';
import '../../../utils.dart';
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
    PickerType.date,
    saveKey: '${RouteConfig.propertyPage.name}StartDate',
  );

  ///日期选择器的控制器
  var pickerControllerEndDate = DatePickerController(
    PickerType.date,
    saveKey: '${RouteConfig.propertyPage.name}EndDate',
  );

  @override
  void onReady() {
    super.onReady();
    queryProperty();
  }

  queryProperty() {
    httpGet(
      method: webApiQueryProperty,
      loading: 'property_querying'.tr,
      params: {
        'PropertyNumber': state.etPropertyNumber,
        'PropertyName': state.etPropertyName,
        'SerialNumber': state.etSerialNumber,
        'InvoiceNumber': state.etInvoiceNumber,
        'EmpName': state.etName,
        'EmpCode': state.etWorkerNumber,
        'StartDate': pickerControllerStartDate.getDateFormatYMD(),
        'EndDate': pickerControllerEndDate.getDateFormatYMD(),
      },
    ).then((response) {
      if (response.resultCode == resultSuccess) {
        state.propertyList.value = [
          for (var i = 0; i < response.data.length; ++i)
            PropertyInfo.fromJson(response.data[i])
        ];
      } else {
        state.propertyList.value = [];
        errorDialog(content: response.message);
      }
    });
  }

  getPropertyDetail(int detailId) {
    httpGet(
      method: webApiGetPropertyDetail,
      loading: 'property_querying'.tr,
      params: {'InterID': detailId},
    ).then((response) {
      if (response.resultCode == resultSuccess) {
        state.detail = PropertyDetailInfo.fromJson(response.data);
        state.canModify = state.detail.processStatus == 0;
        state.participatorName.value = state.detail.participatorName ?? '';
        state.custodianName.value = state.detail.custodianName ?? '';
        state.liableEmpName.value = state.detail.liableEmpName ?? '';
        state.assetPicture.value = state.detail.assetPicture ?? '';
        state.ratingPlatePicture.value = state.detail.ratingPlatePicture ?? '';
        Get.to(() => const PropertyDetailPage());
      } else {
        errorDialog(content: response.message);
      }
    });
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
      );
    } else {
      state.setLiable();
    }
  }

  propertyClose(int detailId) {
    httpPost(
      method: webApiPropertyClose,
      loading: 'property_detail_closing'.tr,
      params: {'InterID': detailId},
    ).then((response) {
      if (response.resultCode == resultSuccess) {
        successDialog(content: response.message);
      } else {
        errorDialog(content: response.message);
      }
    });
  }

  skipAcceptance(int detailId) {
    httpPost(
      method: webApiSkipAcceptance,
      loading: 'property_detail_skipping_acceptance'.tr,
      params: {'InterID': detailId},
    ).then((response) {
      if (response.resultCode == resultSuccess) {
        successDialog(content: response.message);
      } else {
        errorDialog(content: response.message);
      }
    });
  }

  updatePropertyInfo() {
    httpPost(
      method: webApiUpdateProperty,
      loading: 'property_detail_submitting'.tr,
      body: state.upDatePropertyBody(),
    ).then((response) {
      if (response.resultCode == resultSuccess) {
        successDialog(content: response.message);
      } else {
        errorDialog(content: response.message);
      }
    });
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
