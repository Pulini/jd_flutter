import 'package:collection/collection.dart';
import 'package:get/get.dart';

import '../../../bean/http/response/carton_label_scan_progress_info.dart';
import '../../../utils/web_api.dart';

class CartonLabelScanProgressState {
  var progress = <CartonLabelScanProgressInfo>[].obs;

  CartonLabelScanProgressState() {
    ///Initialize variables
  }

  getCartonLabelScanHistory({
    required String orderNo,
    required Function(String) error,
  }) {
    httpGet(
      loading: '正在查询外箱标签明细...',
      method: webApiGetCartonLabelScanHistory,
      params: {'BillorPO': orderNo},
    ).then((response) {
      if (response.resultCode == resultSuccess) {
        progress.value = [
          for (var json in response.data)
            CartonLabelScanProgressInfo.fromJson(json)
        ];
        print('progress=${progress.length}');
      } else {
        error.call(response.message ?? 'query_default_error'.tr);
      }
    });
  }

  getCartonLabelScanHistoryDetail({
    required int id,
    required Function(List<List<CartonLabelScanProgressDetailInfo>>) success,
    required Function(String) error,
  }) {
    httpGet(
      loading: '正在查询外箱标签明细...',
      method: webApiGetCartonLabelScanHistoryDetail,
      params: {
        'InterID': id,
      },
    ).then((response) {
      if (response.resultCode == resultSuccess) {
        var list =<CartonLabelScanProgressDetailInfo> [
          for (var json in response.data)
            CartonLabelScanProgressDetailInfo.fromJson(json)
        ];
        var group = <List<CartonLabelScanProgressDetailInfo>>[];
        groupBy(list, (v) => v.size ?? '').forEach((k, v) {
          group.add(v);
        });
        success.call(group);
      } else {
        error.call(response.message ?? 'query_default_error'.tr);
      }
    });
  }
}
