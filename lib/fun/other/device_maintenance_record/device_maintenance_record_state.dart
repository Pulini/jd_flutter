import 'package:get/get.dart';
import 'package:jd_flutter/bean/http/response/device_maintenance_info.dart';
import 'package:jd_flutter/bean/http/response/device_maintenance_list_info.dart';
import 'package:jd_flutter/bean/http/response/people_message_info.dart';
import 'package:jd_flutter/utils/utils.dart';
import 'package:jd_flutter/widget/custom_widget.dart';

class DeviceMaintenanceRecordState {
  
  var deviceNumber = "";
  var isHave = false.obs;
  var dataList = <DeviceMaintenanceListInfo>[].obs; //设备维修列表
  var deviceData = DeviceMaintenanceInfo().obs; //设备维修详情
  var peoPleInfo = PeopleMessageInfo().obs; //员工详情
  var repairEntryData = <RepairEntryData>[].obs; //设备维修的部件
  var repairUnit = ''; //维修单位
  var repairPart = ''; //检修部位
  var repairReason = ''; //故障说明
  var repairPrevent = ''; //维修后评估及预防


  ///要添加的零部件信息
  var brand = ""; // 零部件的品牌
  var partName = ""; // 零部件的名字
  var partNumber = ""; // 零部件的数量
  var partUnit = ""; // 零部件的单位
  var partNorms = ""; // 零部件的规格
  var partRemark = ""; // 零部件的备注


  ///要去报修的设备信息
  var custodianNumber =''.obs; //持有人工号
  var maintenanceUnit =''.obs; //维修单位
  var repairParts =''.obs; //维修部位
  var faultDescription =''.obs; //故障说明
  var assessmentPrevention =''.obs; //维修后评估及预防
  var issueCause =''; //故障原因判断
  var issueCauseId =''; //故障原因id


  ///删除零部件信息
  deleteRepairEntry(RepairEntryData data){
    repairEntryData.remove(data);
  }


  ///添加零部件信息
  addRepairEntryData({
    required Function() success,
  }) {
    if (brand == "") {
      showSnackBar(title: '警告', message: '零部件品牌为空');
      return;
    } else if (partName == "") {
      showSnackBar(title: '警告', message: '零部件名称为空');
      return;
    } else if (partNumber == "") {
      showSnackBar(title: '警告', message: '零部件数量为空');
      return;
    } else if (partNorms == "") {
      showSnackBar(title: '警告', message: '零部件规格为空');
      return;
    } else if (partUnit == "") {
      showSnackBar(title: '警告', message: '零部件单位为空');
      return;
    } else {
      repairEntryData.add(RepairEntryData(
          accessoriesName: partName,
          manufacturer: brand,
          specification: partNorms,
          quantity: partNumber.toIntTry(),
          unit: partUnit,
          budget: 0,
          remarks: partRemark));
      success.call();
    }
  }
}
