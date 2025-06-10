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

  getTemporaryList({
    required String startDate,
    required String endDate,
    required String temporaryNo,
    required String productionNumber,
    required String factoryType,
    required String supplierName,
    required String materialCode,
    required String factoryArea,
    required String factoryNo,
    required String userNumber,
    required String trackNo,
    required Function(String) error,
  }) {
    httpGet(
      loading: '正在查询暂收单列表...',
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

  deleteTemporaryOrder({
    required String reason,
    required String temporaryNo,
    required Function(String) success,
    required Function(String) error,
  }) {
    httpPost(
      loading: '正在删除暂收单...',
      method: webApiDeleteTemporary,
      params: {
        'TempreNo': temporaryNo,
        'Reason': reason,
        'EmpCode': temporaryNo,
      },
    ).then((response) {
      if (response.resultCode == resultSuccess) {
        success.call(response.message ?? '');
      } else {
        error.call(response.message ?? 'query_default_error'.tr);
      }
    });
  }

  getTemporaryOrderDetail({
    required String temporaryNo,
    required String materialCode,
    required Function() success,
    required Function(String msg) error,
  }) {
    httpGet(
      loading: '正在查询暂收单详情...',
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
