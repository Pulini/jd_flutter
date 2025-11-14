import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:jd_flutter/bean/http/response/base_data.dart';
import 'package:jd_flutter/bean/http/response/sap_picking_scan_info.dart';
import 'package:jd_flutter/utils/utils.dart';
import 'package:jd_flutter/utils/web_api.dart';

class SapPackingScanCacheListState {
  var abnormalSearchText = ''.obs;
  var abnormalList =<SapPackingScanAbnormalInfo>[].obs;

  void getAbnormalOrders({
    required String plannedDate,
    required String destination,
    required String factory,
    required String warehouse,
    required String actualCabinet,
    required Function() success,
    required Function(String) error,
  }) {
    sapPost(
      loading: '正在获取异常单信息...',
      method: webApiSapGetAbnormalList,
      body: {
        'WERKS': factory,
        'LGORT': warehouse,
        'ZZCQ': plannedDate,
        'ZADGE_RCVER': destination,
        'ZZKHXH1': actualCabinet,
      },
    ).then((response)  {
      abnormalList.clear();
      if (response.resultCode == resultSuccess) {
         compute(
        parseJsonToList<SapPackingScanAbnormalInfo>,
        ParseJsonParams(
          response.data,
          SapPackingScanAbnormalInfo.fromJson,
        ),
        ).then((list){
           abnormalList.value=list;
           success.call();
         });
      } else {
        error.call(response.message ?? 'query_default_error'.tr);
      }
    });
  }

  deleteAbnormal({
    required List<SapPackingScanAbnormalInfo> list,
    required Function(List<SapPackingScanAbnormalInfo>,String) success,
    required Function(String) error,
  }) {
    sapPost(
      loading: '正在提交删除...',
      method: webApiSapSubmit,
      body: {
        'ITEM1': {},
        'ITEM2': {},
        'ITEM3': {
          'USNAM': userInfo?.number,
          'BQIDS': [
            for (var item in list)
              {
                'BQID': item.labelNumber,
              }
          ],
        },
      },
    ).then((response) {
      if (response.resultCode == resultSuccess) {
        success.call(list,response.message ?? '');
      } else {
        error.call(response.message ?? 'query_default_error'.tr);
      }
    });
  }

  reSubmit({
    required String actualCabinet,
    required String postingDate,
    required List<SapPackingScanAbnormalInfo> list,
    required Function(String) success,
    required Function(String) error,
  }) {
    sapPost(
      loading: '正在提交排柜信息...',
      method: webApiSapSubmit,
      body: {
        'ITEM1': {
          'WERKS': list[0].factory,
          'ZZCQ': list[0].plannedDate,
          'ZADGE_RCVER': list[0].destination,
          'ZZKHXH1': actualCabinet,
          'LGORT': list[0].warehouse,
          'BQIDS': [
            for (var item in list)
              {
                'BQID': item.labelNumber,
              }
          ],
          'BUDAT_MKPF': postingDate,
          'USNAM': userInfo?.number,
          'ZNAME_CN': userInfo?.name,
        },
        'ITEM2': {},
        'ITEM3': {},
      },
    ).then((response) {
      if (response.resultCode == resultSuccess) {
        for (var label in list) {
          abnormalList.removeWhere((v)=>v.labelNumber==label.labelNumber);
        }
        success.call(response.message ?? '');
      } else {
        error.call(response.message ?? 'query_default_error'.tr);
      }
    });
  }
}
