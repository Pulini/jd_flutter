import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';
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
  var needRefreshPartList=false;



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
      loading: 'part_dispatch_order_querying_instruction_list'.tr,
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
      loading: 'part_dispatch_order_querying_part_dispatch_order_detail'.tr,
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
      loading: 'part_dispatch_order_querying_size_detail'.tr,
      body: {'WorkCardIDs': orders},
    ).then((response) {
      if (response.resultCode == resultSuccess) {
        var data = PartDispatchOrderCreateInfo.fromJson(response.data);
        part.value = data.materialName ?? '';
        success.call(data.sizeList!);
      } else {
        error.call(response.message ?? '');
      }
    });
  }

}
