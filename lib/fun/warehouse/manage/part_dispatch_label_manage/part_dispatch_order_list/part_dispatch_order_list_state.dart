import 'package:flutter/cupertino.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:jd_flutter/bean/http/response/part_dispatch_label_manage_info.dart';
import 'package:jd_flutter/utils/utils.dart';
import 'package:jd_flutter/utils/web_api.dart';

class PartDispatchLabelManageState {
  var isSelectedClosed = false.obs;
  var queryBatchNo = ''.obs;
  var isSingleInstruction = false;
  var orderNo = ''.obs;
  var instructions = ''.obs;
  var typeBody = ''.obs;
  var sizeListText = ''.obs;
  var dispatchBatchNo = ''.obs;
  var total = ''.obs;
  var productUrlList = <String>[].obs;
  var partList = <PartDispatchOrderPartInfo>[].obs;
  var part = ''.obs;
  var createSizeList = <CreateLabelInfo>[].obs;
  var partListId = '';
  var isSingleSize = true;
  var hasLastLabel = false;

  PartDispatchLabelManageState() {
    ///Initialize variables
  }

  void getInstructions({
    String? barCode,
    String? productName,
    String? startTime,
    String? endTime,
    required Function(List<PartDispatchInstructionInfo>) success,
    required Function(String msg) error,
  }) {
    httpGet(
      method: webApiGetWorkCardMtoNoList,
      loading: '正在查询指令列表...',
      params: {
        'BarCode': barCode ?? '',
        'BatchNo': queryBatchNo.value,
        'ProductName': productName ?? '',
        'StartTime': startTime ?? '',
        'EndTime': endTime ?? '',
        'DeptID': userInfo?.departmentID,
      },
    ).then((response) {
      if (response.resultCode == resultSuccess) {
        success.call([
          for (var json in response.data)
            PartDispatchInstructionInfo.fromJson(json)
        ]);
      } else {
        error.call(response.message ?? '');
      }
    });
  }

  void getPartOrderDetails({
    required List<int> list,
    required bool isSingleInstruction,
    required Function(String msg) error,
  }) {
    this.isSingleInstruction = isSingleInstruction;
    debugPrint('isSingleInstruction=$isSingleInstruction');
    orderNo.value = '';
    instructions.value = '';
    typeBody.value = '';
    sizeListText.value = '';
    dispatchBatchNo.value = '';
    total.value = '';
    productUrlList.value = [];
    partList.value = [];
    httpPost(
      method: webApiGetPartWorkCardListNew,
      loading: '正在查询部件派工单明细...',
      body: list,
    ).then((response) {
      if (response.resultCode == resultSuccess) {
        var data = PartDispatchOrderDetailInfo.fromJson(response.data);
        orderNo.value = data.workCardNo ?? '';
        instructions.value = data.seOrderNo ?? '';
        typeBody.value = data.productName ?? '';
        sizeListText.value = data.sizeWithQty ?? '';
        dispatchBatchNo.value = data.batchNo ?? '';
        total.value = data.totalQtyWithUnitName ?? '';
        productUrlList.value = data.productUrlList ?? [];
        partList.value = data.partList ?? [];
      } else {
        error.call(response.message ?? '');
      }
    });
  }

  void getDispatchOrdersSizeDetail({
    required List<String> orders,
    required Function(List<PartDispatchOrderCreateSizeInfo>) success,
    required Function(String msg) error,
  }) {
    httpGet(
      method: webApiGetPartProductionDispatchOrdersDetail,
      loading: '正在获取尺码明细...',
      body: {'WorkCardIDs': orders},
    ).then((response) {
      if (response.resultCode == resultSuccess) {
        var data = PartDispatchOrderCreateInfo.fromJson(response.data);
        part.value = data.materialName ?? '';
        partListId=data.sizeList!.map((v)=>v.workCardEntryFID??0).toSet().join(',');
        success.call(data.sizeList!);
      } else {
        error.call(response.message ?? '');
      }
    });
  }

}
