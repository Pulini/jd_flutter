import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:jd_flutter/bean/http/response/base_data.dart';
import 'package:jd_flutter/bean/http/response/temporary_order_info.dart';
import 'package:jd_flutter/utils/utils.dart';
import 'package:jd_flutter/utils/web_api.dart';

class TemporaryOrderState {
  var showInspectionAbnormal = false.obs;
  var orderType = 1.obs;
  var temporaryOrderList = <List<TemporaryOrderInfo>>[].obs;
  TemporaryOrderDetailInfo? detailInfo;

  TemporaryOrderState() {
    ///Initialize variables
  }

  void getTemporaryList({
    required String startDate,
    required String endDate,
    required String temporaryNo,
    required String productionNumber,
    required String factoryType,
    required String supplierName,
    required String materialCode,
    required String factoryArea,
    required String factoryNo,
    required String divisionId,
    required String userNumber,
    required String trackNo,
    required Function(String) error,
  }) {
    httpGet(
      loading: 'temporary_order_loading_query_list'.tr,
      method: webApiGetTemporaryList,
      params: {
        'StartDate': startDate,
        'EndDate': endDate,
        'TempreNo': temporaryNo,
        'Mtono': productionNumber,
        'FactoryType': factoryType,
        'SupplierName': supplierName,
        'MaterialCode': materialCode,
        'FinishType': orderType.value.toString(),
        'AbnormalQuality': showInspectionAbnormal.value,
        'FactoryArea': factoryArea,
        'FactoryNo': factoryNo,
        'UserNumber': userNumber,
        'TrackNo': trackNo,
        'Character': userInfo?.sapRole,
        'UserID': userInfo?.userID,
        'division': divisionId,
      },
    ).then((response) {
      if (response.resultCode == resultSuccess) {
        compute(
          parseJsonToList<TemporaryOrderInfo>,
          ParseJsonParams(response.data, TemporaryOrderInfo.fromJson),
        ).then((list) {
          var group = <List<TemporaryOrderInfo>>[];
          groupBy(list, (v) => v.temporaryNo).forEach((k, v) {
            group.add(v);
          });
          temporaryOrderList.value = group;
        });
      } else {
        temporaryOrderList.value = [];
        error.call(response.message ?? 'query_default_error'.tr);
      }
    });
  }

  void deleteTemporaryOrder({
    required String reason,
    required String temporaryNo,
    required Function(String) success,
    required Function(String) error,
  }) {
    httpPost(
      loading: 'temporary_order_loading_delete'.tr,
      method: webApiDeleteTemporary,
      params: {
        'TempreNo': temporaryNo,
        'Reason': reason,
        'EmpCode': userInfo?.number,
      },
    ).then((response) {
      if (response.resultCode == resultSuccess) {
        success.call(response.message ?? '');
      } else {
        error.call(response.message ?? 'query_default_error'.tr);
      }
    });
  }

  void getTemporaryOrderDetail({
    required String temporaryNo,
    required String materialCode,
    required Function() success,
    required Function(String msg) error,
  }) {
    httpGet(
      loading: 'temporary_order_loading_query_detail'.tr,
      method: webApiGetTemporaryDetail,
      params: {
        'Type': 'TempInstock',
        'Zno': temporaryNo,
        'materialCode': materialCode,
        'EmpCode': userInfo?.number,
      },
    ).then((response) {
      if (response.resultCode == resultSuccess) {
        detailInfo = TemporaryOrderDetailInfo.fromJson(response.data);
        success.call();
      } else {
        detailInfo = null;
        error.call(response.message ?? 'query_default_error'.tr);
      }
    });
  }
}
