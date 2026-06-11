import 'package:get/get.dart';
import 'package:jd_flutter/bean/http/response/part_dispatch_label_manage_info.dart';
import 'package:jd_flutter/utils/web_api.dart';

class ConfirmPackingMethodState {
  var barCode='';
  var needBack=false;
  var partList = <PartDispatchMaterialList>[].obs;
  var packingMethodList = <PartDispatchPackingMethodInfo>[].obs;
  var packingMethodName = ''.obs;
  var packingMethodID = 0.obs;
  var packingMethodCapacityQty = (0.0).obs;

  void getPartDispatchConfirmInfo({
    required String barCode,
     Function()? success,
    required Function(String msg) error,
  }) {

    httpGet(
      method: webApiGetWorkCardMtoNoListByQrCode,
      loading: 'part_dispatch_order_querying_instruction_list'.tr,
      params: {'BarCode': barCode},
    ).then((response) {
    this.barCode=barCode;
      if (response.resultCode == resultSuccess) {
        var data = PartDispatchConfirmInfo.fromJson(response.data);
        partList.value = data.materialList!;
        packingMethodList.value = data.packingMethodList!;
        try {
          var packingMethod = packingMethodList.firstWhere(
            (v) => v.itemID == data.packingMethod!.packingMethodID,
          );
          packingMethodName.value = packingMethod.name ?? '';
          packingMethodID.value = packingMethod.itemID ?? 0;
          packingMethodCapacityQty.value = data.packingMethod!.packingMethodCapacityQty??0;
        } on StateError catch (_) {
          packingMethodName.value='';
          packingMethodID.value =0;
          packingMethodCapacityQty.value = 0.0;
        }
        success?.call();
      } else {
        error.call(response.message ?? '');
      }
    });
  }

  void modifyOrderPackProfile({
    required int packProfileID,
    required double capacityQty,
    required void Function(String) success,
    required void Function(String) error,
  }) {
    httpPost(
      method: webApiCreatePackageByWorkCardIDAndQty,
      loading: 'part_dispatch_pack_order_modifying_pack_profile'.tr,
      body: {
        'WorkCardIDs': partList.map((v)=>v.workCardID).toList(),
        'PackageProfileID': packProfileID,
        'PackageProfileCapacityQty': capacityQty,
      },
    ).then((response) {
      if (response.resultCode == resultSuccess) {
        success.call(response.message ?? '');
      } else {
        error.call(response.message ?? '');
      }
    });
  }
}
