import 'package:get/get.dart';
import 'package:jd_flutter/bean/http/response/device_maintenance_info.dart';
import 'package:jd_flutter/bean/http/response/device_maintenance_list_info.dart';
import 'package:jd_flutter/bean/http/response/issue_cause_info.dart';
import 'package:jd_flutter/bean/http/response/people_message_info.dart';
import 'package:jd_flutter/fun/other/device_maintenance_record/device_maintenance_record_detail_view.dart';
import 'package:jd_flutter/fun/other/device_maintenance_record/device_maintenance_record_repair_view.dart';
import 'package:jd_flutter/fun/other/device_maintenance_record/device_maintenance_record_state.dart';
import 'package:jd_flutter/route.dart';
import 'package:jd_flutter/utils/utils.dart';
import 'package:jd_flutter/utils/web_api.dart';
import 'package:jd_flutter/widget/custom_widget.dart';
import 'package:jd_flutter/widget/dialogs.dart';
import 'package:jd_flutter/widget/picker/picker_controller.dart';
import 'package:jd_flutter/widget/spinner_widget.dart';

class DeviceMaintenanceRecordLogic extends GetxController {
  final DeviceMaintenanceRecordState state = DeviceMaintenanceRecordState();

  //日期选择器的控制器
  var startDate = DatePickerController(
    PickerType.startDate,
    saveKey: '${RouteConfig.deviceMaintenance.name}${PickerType.startDate}',
  )..firstDate = DateTime(
      DateTime.now().year - 5, DateTime.now().month, DateTime.now().day);

  //日期选择器的控制器
  var endDate = DatePickerController(
    PickerType.endDate,
    saveKey: '${RouteConfig.deviceMaintenance.name}${PickerType.endDate}',
  );

  //日期选择器的控制器
  var repairStartDate = DatePickerController(
    buttonName: 'device_maintenance_repair_time'.tr,
    PickerType.startDate,
    saveKey: '${RouteConfig.deviceMaintenance.name}${'repairStartDate'}',
  )..lastDate = DateTime(
      DateTime.now().year, DateTime.now().month + 2, DateTime.now().day);

  //日期选择器的控制器
  var repairEndDate = DatePickerController(
    buttonName: 'device_maintenance_fixed_time'.tr,
    PickerType.endDate,
    saveKey: '${RouteConfig.deviceMaintenance.name}${'repairEndDate'}',
  )..lastDate = DateTime(
      DateTime.now().year, DateTime.now().month + 2, DateTime.now().day);

  //搜索按钮的分辨事件
  search() {
    if (state.deviceNumber.isNotEmpty) {
      searchDeviceInfo(state.deviceNumber);
    } else {
      searchDeviceList();
    }
  }

  //下拉选择器的控制器
  late SpinnerController spinnerControllerWorkShop;

  //获取维修列表
  searchDeviceList() {
    httpGet(
      method: webApiGetRepairOrderList,
      loading: 'device_maintenance_repair_orders_list'.tr,
      params: {
        'StartDate': startDate.getDateFormatYMD(),
        'EndDate': endDate.getDateFormatYMD(),
      },
    ).then((response) {
      if (response.resultCode == resultSuccess) {
        var list = <DeviceMaintenanceListInfo>[
          for (var i = 0; i < response.data.length; ++i)
            DeviceMaintenanceListInfo.fromJson(response.data[i])
        ];
        state.dataList.value = list;
      } else {
        errorDialog(content: response.message);
      }
    });
  }

  //设备报修提交数据
  submitRecordData({
    required Function(String msg) success,
  }) {
    if (state.custodianNumber.toString().length != 6 ||
        state.peoPleInfo.value.empName == null) {
      showSnackBar(title: 'shack_bar_warm'.tr, message: 'device_maintenance_holder_input_error'.tr);
    } else if (state.maintenanceUnit.toString().isEmpty) {
      showSnackBar(title: 'shack_bar_warm'.tr, message: 'device_maintenance_repair_unit'.tr);
    } else if (state.faultDescription.isEmpty) {
      showSnackBar(title: 'shack_bar_warm'.tr, message: 'device_maintenance_input_fault_description'.tr);
    } else if (state.assessmentPrevention.isEmpty) {
      showSnackBar(title: 'shack_bar_warm'.tr, message: 'device_maintenance_evaluation_prevention'.tr);
    } else {
      httpPost(method: webApiSubmitRecordData, loading: 'device_maintenance_submitting_repair_information'.tr, body: {
        'DeviceID': state.deviceData.value.deviceMessage!.deviceID.toString(),
        'FaultDescription': state.faultDescription.value,
        'RepairTime': repairEndDate.getDateFormatYMD(), //修复时间
        'InspectionTime': repairStartDate.getDateFormatYMD(), //报修时间
        'IssueCause': state.issueCauseId,  //故障原因判断
        'AssessmentPrevention': state.assessmentPrevention.value,  //维修后评估及预防
        'CustodianID':
            state.deviceData.value.deviceMessage!.custodianID.toString(), //使用人
        'CustodianNumber':
            state.deviceData.value.deviceMessage!.custodianCode.toString(), //工号
        'UserID': userInfo?.userID.toString(),
        'RepairParts': state.repairParts.value,  //检修部件
        'MaintenanceUnit': state.maintenanceUnit.value,  //维修单位
        'RepairEntryData': [
          for (var i = 0; i < state.repairEntryData.length; ++i)
            {
              'AccessoriesName': state.repairEntryData[i].accessoriesName,  //更换配件名称
              'Manufacturer': state.repairEntryData[i].manufacturer, //厂商/品牌
              'Specification': state.repairEntryData[i].specification, //规格
              'Quantity': state.repairEntryData[i].quantity, //数量
              'Unit': state.repairEntryData[i].unit, //单位
              'Remarks': state.repairEntryData[i].remarks, //备注
            }
        ]
      }).then((response) {
        if (response.resultCode == resultSuccess) {
          success.call(response.message ?? '');
        } else {
          errorDialog(content: response.message);
        }
      });
    }
  }

  //设备维修记录单故障原因
  goRepair() {
    httpGet(
      method: webApiGetIssueCauseType,
      loading: 'device_maintenance_record_malfunction'.tr,
    ).then((response) {
      if (response.resultCode == resultSuccess) {
        var list = <IssueCauseInfo>[
          for (var i = 0; i < response.data.length; ++i)
            IssueCauseInfo.fromJson(response.data[i])
        ];
        var lists = <String>[];
        for (int i = 0; i < list.length; i++) {
          lists.add(list[i].issueCause.toString());
        }
        spinnerControllerWorkShop = SpinnerController(
          saveKey: RouteConfig.productionDayReport.name,
          dataList: lists,
          onChanged: (index) {
            state.issueCause = list[index].issueCause.toString();
            state.issueCauseId = list[index].iD.toString();
          },
        );

        Get.to(() => const DeviceMaintenanceRecordRepairPage());
      } else {
        errorDialog(content: response.message);
      }
    });
  }

  //作废记录单
  repairOrderVoid({
    required String interId,
    required String reason,
    required Function(String msg) success,
  }) {
    httpPost(
      method: webApiRepairOrderVoid,
      loading: 'device_maintenance_cancelling_record_sheet'.tr,
      params: {
        'InterID': startDate.getDateFormatYMD(),
        'VoidReason': endDate.getDateFormatYMD(),
        'UserID': userInfo?.userID,
      },
    ).then((response) {
      if (response.resultCode == resultSuccess) {
        success.call(response.message ?? '');
      } else {
        errorDialog(content: response.message);
      }
    });
  }

  //获取设备详情
  searchDeviceInfo(String deviceNumber) {
    httpGet(
      method: webApiGetDeviceInformationByFNumber,
      loading: 'device_maintenance_device_information'.tr,
      params: {
        'DeviceNo': deviceNumber,
      },
    ).then((response) {
      if (response.resultCode == resultSuccess) {
        state.deviceData.value = DeviceMaintenanceInfo.fromJson(response.data);
        if (state.deviceData.value.repairOrder==null) {
          state.isHave.value = false;
        } else {
          state.isHave.value = true;
        }
        Get.to(() => const DeviceMaintenanceRecordDetailPage());
      } else {
        errorDialog(content: response.message);
      }
    });
  }

  //根据工号获取人员信息
  searchPeople(String number) {
    if (number.isNotEmpty && number.length == 6) {
      httpGet(
        method: webApiGetEmpAndLiableByEmpCode,
        loading: 'device_maintenance_personnel_information'.tr,
        params: {
          'EmpCode': number,
        },
      ).then((response) {
        if (response.resultCode == resultSuccess) {
          state.custodianNumber.value = number;
          state.peoPleInfo.value = PeopleMessageInfo.fromJson(response.data);
        } else {
          errorDialog(content: response.message);
        }
      });
    }
  }
}
