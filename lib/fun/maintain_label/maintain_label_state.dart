import 'package:get/get.dart';
import 'package:jd_flutter/bean/http/response/label_info.dart';

class MaintainLabelState {
  var materialCode = '';
  var interID = 0;
  var isMaterialLabel = false.obs;
  var isSingleLabel = false;
  var materialName = ''.obs;
  var typeBody = ''.obs;
  var cbUnprinted = false.obs;
  var cbPrinted = false.obs;
  var labelList = <LabelInfo>[].obs;
  var labelGroupList = <List<LabelInfo>>[].obs;
  var filterSize = '全部'.obs;

  MaintainLabelState() {
    materialCode = Get.arguments['materialCode'];
    interID = Get.arguments['interID'];
    isMaterialLabel.value = Get.arguments['isMaterialLabel'];
  }

  List<LabelInfo> getLabelList() {
    return filterSize.value=='全部'
        ? labelList
        : labelList
            .where((v) => v.items!.any((v2) => v2.size == filterSize.value))
            .toList();
  }

  List<List<LabelInfo>> getLabelGroupList() {
    return filterSize.value=='全部'
        ? labelGroupList
        : labelGroupList
            .where((v) => v.any(
                (v2) => v2.items!.any((v3) => v3.size == filterSize.value)))
            .toList();
  }
}
