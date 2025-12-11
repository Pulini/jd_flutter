import 'dart:ui';

import 'package:get/get.dart';
import 'package:jd_flutter/bean/http/response/property_detail_info.dart';
import 'package:jd_flutter/bean/http/response/property_info.dart';
import 'package:jd_flutter/utils/extension_util.dart';
import 'package:jd_flutter/utils/utils.dart';
import 'package:jd_flutter/utils/web_api.dart';
import 'package:jd_flutter/widget/custom_widget.dart';

enum AuditedType { audited, unAudited, underAudit }

class PropertyState {
  var tabColors = <AuditedType, Color>{
    AuditedType.audited: const Color(0xff191970),
    AuditedType.unAudited: const Color(0xff40826d),
    AuditedType.underAudit: const Color(0xff007ba7),
  };
  Rx<AuditedType> selectedTab = AuditedType.audited.obs;
  RxList<PropertyInfo> propertyList = <PropertyInfo>[].obs;
  var detail = PropertyDetailInfo();
  var participatorName = ''.obs;
  var custodianName = ''.obs;
  var liableEmpName = ''.obs;
  var assetPicture = ''.obs;
  var ratingPlatePicture = ''.obs;
  bool canModify = false;

  void setParticipator({String empCode = '', String empName = '', int empID = -1}) {
    detail.participatorCode = empCode;
    detail.participatorName = empName;
    detail.participator = empID;
    participatorName.value = empName;
  }

  void setCustodian({String empCode = '', String empName = '', int empID = -1}) {
    detail.custodianCode = empCode;
    detail.custodianName = empName;
    custodianName.value = empName;
  }

  void setLiable({String empCode = '', String empName = '', int empID = -1}) {
    detail.liableEmpCode = empCode;
    detail.liableEmpName = empName;
    detail.liableEmpID = empID;
    liableEmpName.value = empName;
  }

  void queryProperty({
    required String propertyNumber,
    required String propertyName,
    required String serialNumber,
    required String invoiceNumber,
    required String name,
    required String workerNumber,
    required String startDate,
    required String endDate,
    required Function(String msg) error,
  }) {
    httpGet(
      method: webApiQueryProperty,
      loading: 'property_querying'.tr,
      params: {
        'PropertyNumber': propertyNumber,
        'PropertyName': propertyName,
        'SerialNumber': serialNumber,
        'InvoiceNumber': invoiceNumber,
        'EmpName': name,
        'EmpCode': workerNumber,
        'StartDate': startDate,
        'EndDate': endDate,
      },
    ).then((response) {
      if (response.resultCode == resultSuccess) {
        propertyList.value = [
          for (var json in response.data) PropertyInfo.fromJson(json)
        ];
      } else {
        propertyList.value = [];
        error.call(response.message ?? '');
      }
    });
  }

  void getPropertyDetail({
    required int detailId,
    required Function() success,
    required Function(String msg) error,
  }) {
    httpGet(
      method: webApiGetPropertyDetail,
      loading: 'property_querying'.tr,
      params: {'InterID': detailId},
    ).then((response) {
      if (response.resultCode == resultSuccess) {
        detail = PropertyDetailInfo.fromJson(response.data);
        canModify = detail.processStatus == 0;
        participatorName.value = detail.participatorName ?? '';
        custodianName.value = detail.custodianName ?? '';
        liableEmpName.value = detail.liableEmpName ?? '';
        assetPicture.value = detail.assetPicture ?? '';
        ratingPlatePicture.value = detail.ratingPlatePicture ?? '';
        success.call();
      } else {
        error.call(response.message ?? '');
      }
    });
  }

  void propertyClose({
    required int detailId,
    required Function(String msg) success,
    required Function(String msg) error,
  }) {
    httpPost(
      method: webApiPropertyClose,
      loading: 'property_detail_closing'.tr,
      params: {'InterID': detailId},
    ).then((response) {
      if (response.resultCode == resultSuccess) {
        success.call(response.message ?? '');
      } else {
        error.call(response.message ?? '');
      }
    });
  }

  void skipAcceptance({
    required int detailId,
    required Function(String msg) success,
    required Function(String msg) error,
  }) {
    httpPost(
      method: webApiSkipAcceptance,
      loading: 'property_detail_skipping_acceptance'.tr,
      params: {'InterID': detailId},
    ).then((response) {
      if (response.resultCode == resultSuccess) {
        success.call(response.message ?? '');
      } else {
        error.call(response.message ?? '');
      }
    });
  }

  void updatePropertyInfo({
    required Function(String msg) success,
    required Function(String msg) error,
  }) {
    httpPost(
      method: webApiUpdateProperty,
      loading: 'property_detail_submitting'.tr,
      body: {
        'Address': detail.address,
        'AssetPicture': assetPicture.value,
        'RatingPlatePicture': ratingPlatePicture.value,
        'DeptID': detail.deptID,
        'GuaranteePeriod': detail.guaranteePeriod,
        'ExpectedLife': detail.expectedLife,
        'InterID': detail.interID,
        'KeepEmpID': detail.keepEmpID,
        'LiableEmpID': detail.liableEmpID,
        'Manufacturer': detail.manufacturer,
        'Model': detail.model,
        'Name': detail.name,
        'Notes': detail.notes,
        'Number': detail.number,
        'OrgVal': detail.orgVal.toShowString(),
        'Participator': detail.participator,
        'Price': detail.price.toShowString(),
        'RegistrationerID': userInfo?.empID,
        'WriteDate': detail.writeDate,
        'BuyDate': detail.buyDate,
        'ReviceDate': detail.reviceDate,
      },
    ).then((response) {
      if (response.resultCode == resultSuccess) {
        success.call(response.message ?? '');
      } else {
        error.call(response.message ?? '');
      }
    });
  }

  void setPrintAssetsLaser() {
    httpPost(
      method: webApiPrintAssetsLaser,
      loading: 'property_detail_update_print_times'.tr,
      body: {
        [
          {
            'InterID': detail.interID,
          }
        ]
      },
    ).then((response) {
      if (response.resultCode == resultSuccess) {
        showSnackBar(message: response.message?? '');
      } else {
        showSnackBar(message: response.message?? '');
      }
    });
  }
}
