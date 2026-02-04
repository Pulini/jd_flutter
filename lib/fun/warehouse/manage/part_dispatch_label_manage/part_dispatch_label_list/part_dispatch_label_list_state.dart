import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:jd_flutter/bean/http/response/pack_order_list_info.dart';
import 'package:jd_flutter/utils/web_api.dart';

class PartDispatchLabelListState {
  var labelList = <PartLabelInfo>[].obs;

  void getLabelList({
    String? partIds,
    int? packOrderId,
    required Function() success,
    required Function(String msg) error,
  }) {
    httpGet(
      method: webApiGetLargeCardNoList,
      loading: '正在获取标签列表...',
      body: {
        'WorkCardEntryFIDs': partIds ?? '',
        'OrderPackageID': packOrderId ?? 0,
      },
    ).then((response) {
      if (response.resultCode == resultSuccess) {
        labelList.value = [
          for (var item in response.data) PartLabelInfo.fromJson(item)
        ];
        success.call();
      } else {
        error.call(response.message ?? '');
      }
    });
  }
}
