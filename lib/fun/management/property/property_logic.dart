import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jd_flutter/fun/management/property/property_detail_view.dart';
import 'package:jd_flutter/http/response/property_detail_info.dart';
import '../../../http/response/property_info.dart';
import '../../../http/web_api.dart';
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

  var textControllerPropertyNumber = TextEditingController();
  var textControllerPropertyName = TextEditingController();
  var textControllerSerialNumber = TextEditingController();
  var textControllerInvoiceNumber = TextEditingController();
  var textControllerName = TextEditingController();
  var textControllerWorkerNumber = TextEditingController();

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
      query: {
        'PropertyNumber': textControllerPropertyNumber.text,
        'PropertyName': textControllerPropertyName.text,
        'SerialNumber': textControllerSerialNumber.text,
        'InvoiceNumber': textControllerInvoiceNumber.text,
        'EmpName': textControllerName.text,
        'EmpCode': textControllerWorkerNumber.text,
        'StartDate': pickerControllerStartDate.getDateFormatYMD(),
        'EndDate': pickerControllerEndDate.getDateFormatYMD(),
      },
    ).then((response) {
      if (response.resultCode == resultSuccess) {
        var jsonList = jsonDecode(response.data);
        var list = <PropertyInfo>[];
        for (var i = 0; i < jsonList.length; ++i) {
          list.add(PropertyInfo.fromJson(jsonList[i]));
        }
        state.propertyList.value = list;
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
      query: {'InterID': detailId},
    ).then((response) {
      if (response.resultCode == resultSuccess) {
        state.detail = PropertyDetailInfo.fromJson(jsonDecode(response.data));
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
      checkWorker(
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
      checkWorker(
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
      checkWorker(
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
      query: {'InterID': detailId},
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
      query: {'InterID': detailId},
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
      loading: 'property_detail_skipping_acceptance'.tr,
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
