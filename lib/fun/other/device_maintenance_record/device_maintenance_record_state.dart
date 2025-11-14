import 'package:get/get.dart';
import 'package:jd_flutter/bean/http/response/device_maintenance_info.dart';
import 'package:jd_flutter/bean/http/response/device_maintenance_list_info.dart';
import 'package:jd_flutter/bean/http/response/people_message_info.dart';
import 'package:jd_flutter/utils/extension_util.dart';
import 'package:jd_flutter/widget/custom_widget.dart';

class DeviceMaintenanceRecordState {
  var deviceNumber = '';
  var isHave = false.obs;
  var dataList = <DeviceMaintenanceListInfo>[].obs; //设备维修列表
  var deviceData = DeviceMaintenanceInfo().obs; //设备维修详情
  var peoPleInfo = PeopleMessageInfo().obs; //员工详情
  var repairEntryData = <RepairEntryData>[].obs; //设备维修的部件

  //要去报修的设备信息
  var custodianNumber = ''.obs; //持有人工号
  var maintenanceUnit = ''.obs; //维修单位
  var repairParts = ''.obs; //维修部位
  var faultDescription = ''.obs; //故障说明
  var assessmentPrevention = ''.obs; //维修后评估及预防
  var issueCause = ''; //故障原因判断
  var issueCauseId = ''; //故障原因id

  //删除零部件信息
  void deleteRepairEntry(RepairEntryData data) {
    repairEntryData.remove(data);
  }

  //添加零部件信息
  void addRepairEntryData({
    required String brand,
    required String partName,
    required String partNumber,
    required String partUnit,
    required String partNorms,
    required String partRemark,
    required Function() success,
  }) {
    if (brand == '') {
      showSnackBar(
          title: 'shack_bar_warm'.tr,
          message: 'device_maintenance_component_brand_empty'.tr);
      return;
    } else if (partName == '') {
      showSnackBar(
          title: 'shack_bar_warm'.tr,
          message: 'device_maintenance_component_name_empty'.tr);
      return;
    } else if (partNumber == '') {
      showSnackBar(
          title: 'shack_bar_warm'.tr,
          message: 'device_maintenance_component_qty_empty'.tr);
      return;
    } else if (partNorms == '') {
      showSnackBar(
          title: 'shack_bar_warm'.tr,
          message: 'device_maintenance_component_specification_empty'.tr);
      return;
    } else if (partUnit == '') {
      showSnackBar(
          title: 'shack_bar_warm'.tr,
          message: 'device_maintenance_component_unit_empty'.tr);
      return;
    } else {
      repairEntryData.add(RepairEntryData(
          accessoriesName: partName,
          manufacturer: brand,
          specification: partNorms,
          quantity: partNumber.toDoubleTry(),
          unit: partUnit,
          budget: 0,
          remarks: partRemark));
      success.call();
    }
  }
}
