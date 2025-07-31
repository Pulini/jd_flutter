import 'dart:convert';
import 'dart:io';

import 'package:collection/collection.dart';
import 'package:get/get.dart';
import 'package:jd_flutter/bean/http/response/base_data.dart';
import 'package:jd_flutter/bean/http/response/incoming_inspection_info.dart';
import 'package:jd_flutter/utils/utils.dart';
import 'package:jd_flutter/utils/web_api.dart';

class IncomingInspectionState {
  var deliveryList = <List<List<InspectionDeliveryInfo>>>[].obs;
  var addMaterialList = <InspectionDeliveryInfo>[].obs;
  var inspectionType = '1'.obs;
  var inspectionOrderList = <InspectionOrderInfo>[].obs;
  InspectionDetailInfo? inspectionDetail;
  var inspectionPhotoList = <File>[].obs;

  queryIncomingInspectionList({
    String barcode = '',
    String area = '',
    String factory = '',
    String supplier = '',
    required String deliveryNo ,
    required String materialCode ,
    required Function() success,
    required Function(String) error,
  }) {
    Future<BaseData> doHttp;
    if (barcode.isEmpty) {
      doHttp = httpGet(
        loading: 'incoming_inspection_querying_delivery_list_tips'.tr,
        method: webApiGetDeliListBySupplier,
        params: {
          'ZQY': area,
          'factory': factory,
          'Supplier': supplier,
          'deliveryNo': deliveryNo,
          'materialCode': materialCode,
        },
      );
    } else {
      doHttp = httpGet(
        loading: 'incoming_inspection_querying_delivery_list_tips'.tr,
        method: webApiGetDeliListByBarCode,
        params: {
          'Type': jsonDecode(barcode)['BarCodeType'],
          'Zno': jsonDecode(barcode)['BillNOval'],
        },
      );
    }

    doHttp.then((response) {
      deliveryList.clear();
      if (response.resultCode == resultSuccess) {
        var list = <InspectionDeliveryInfo>[
          for (var json in response.data) InspectionDeliveryInfo.fromJson(json)
        ];
        groupBy(list, (v1) => v1.identifying()).forEach((k1, v1) {
          var mList = <List<InspectionDeliveryInfo>>[];
          groupBy(v1, (v2) => v2.materialName).forEach((k2, v2) {
            mList.add(v2);
          });
          deliveryList.add(mList);
        });
        success.call();
      } else {
        error.call(response.message ?? 'query_default_error'.tr);
      }
    });
  }

  applyInspection({
    required String number,
    required Function(String) success,
    required Function(String) error,
  }) {
    httpPost(
      loading: 'incoming_inspection_submitting_inspection_apply_tips'.tr,
      method: webApiInspectionApplication,
      body: {
        'EmpCode': number,
        'UserID': userInfo?.userID,
        'Items': [
          for (var d in deliveryList)
            for (var g in d)
              for (var m in g) m.toJson(),
          for (var am in addMaterialList) am.toJson(),
        ]
      },
    ).then((response) {
      if (response.resultCode == resultSuccess) {
        success.call(response.message ?? '');
      } else {
        error.call(response.message ?? 'query_default_error'.tr);
      }
    });
  }

  getInspectionOrders({
    required String startDate,
    required String endDate,
    required String inspectionSuppler,
    Function()? success,
    required Function(String) error,
  }) {
    httpGet(
      loading: 'incoming_inspection_querying_inspection_list_tips'.tr,
      method: webApiGetIncomingList,
      params: {
        'StartDate': startDate,
        'EndDate': endDate,
        'Supplier': inspectionSuppler,
        'Type': inspectionType.value,
      },
    ).then((response) {
      if (response.resultCode == resultSuccess) {
        inspectionOrderList.value = [
          for (var json in response.data) InspectionOrderInfo.fromJson(json)
        ];
        success?.call();
      } else {
        inspectionOrderList.value = [];
        error.call(response.message ?? 'query_default_error'.tr);
      }
    });
  }

  getInspectionOrderDetails({
    required String interID,
    required Function() success,
    required Function(String) error,
  }) {
    httpGet(
      loading: 'incoming_inspection_getting_inspection_detail_tips'.tr,
      method: webApiGetIncomingMessage,
      params: {
        'InterID': interID,
      },
    ).then((response) {
      if (response.resultCode == resultSuccess) {
        inspectionDetail = InspectionDetailInfo.fromJson(response.data);
        success.call();
      } else {
        error.call(response.message ?? 'query_default_error'.tr);
      }
    });
  }

  submitInspection({
    required String inspector,
    required String results,
    required Function(String) success,
    required Function(String) error,
  }) {
    httpPost(
      loading: 'incoming_inspection_submitting_inspection_result_tips'.tr,
      method: webApiIncomingInspection,
      body: {
        'InterID': inspectionDetail?.interID,
        'Number': inspectionDetail?.number,
        'EmpCode': inspector,
        'InspectionResult': results,
        'Pictures':inspectionPhotoList.map((v)=>v.toBase64()).toList(),
      },
    ).then((response) {
      if (response.resultCode == resultSuccess) {
        success.call(response.message ?? '');
      } else {
        error.call(response.message ?? 'query_default_error'.tr);
      }
    });
  }

  signOrder({
    required Function(String) success,
    required Function(String msg) error,
  }) {
    httpPost(
      loading: 'incoming_inspection_signing'.tr,
      method: webApiSigning,
      params: {
        'InterID': inspectionDetail?.interID,
        'UserID': userInfo?.userID,
      },
    ).then((response) {
      if (response.resultCode == resultSuccess) {
        success.call(response.message ?? '');
      } else {
        error.call(response.message ?? 'query_default_error'.tr);
      }
    });
  }

  reportException({
    required String exceptionInfo,
    required Function(String) success,
    required Function(String msg) error,
  }) {
    httpPost(
      loading: 'incoming_inspection_reporting_exception'.tr,
      method: webApiAbnormalUpload,
      params: {
        'InterID': inspectionDetail?.interID,
        'UserID': userInfo?.userID,
        'ExceptionInformation': exceptionInfo,
      },
    ).then((response) {
      if (response.resultCode == resultSuccess) {
        success.call(response.message ?? '');
      } else {
        error.call(response.message ?? 'query_default_error'.tr);
      }
    });
  }

  exceptionHandling({
    required String handlingResult,
    required Function(String) success,
    required Function(String) error,
  }) {
    httpPost(
      loading: 'incoming_inspection_submitting_processing'.tr,
      method: webApiAuditExceptionHandling,
      params: {
        'InterID': inspectionDetail?.interID,
        'UserID': userInfo?.userID,
        'ExceptionHandling': handlingResult,
      },
    ).then((response) {
      if (response.resultCode == resultSuccess) {
        success.call(response.message ?? '');
      } else {
        error.call(response.message ?? 'query_default_error'.tr);
      }
    });
  }

  submitCloseOrder({
    required Function(String) success,
    required Function(String) error,
  }) {
    httpPost(
      loading: 'incoming_inspection_submitting_close_case'.tr,
      method: webApiClosingCase,
      params: {
        'InterID': inspectionDetail?.interID,
        'UserID': userInfo?.userID,
      },
    ).then((response) {
      if (response.resultCode == resultSuccess) {
        success.call(response.message ?? '');
      } else {
        error.call(response.message ?? 'query_default_error'.tr);
      }
    });
  }
}
