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

  ///日期选择器的控制器
  var startDate = DatePickerController(
    PickerType.startDate,
    saveKey: '${RouteConfig.deviceMaintenance.name}${PickerType.startDate}',
  )..firstDate = DateTime(
      DateTime.now().year - 5, DateTime.now().month, DateTime.now().day);

  ///日期选择器的控制器
  var endDate = DatePickerController(
    PickerType.endDate,
    saveKey: '${RouteConfig.deviceMaintenance.name}${PickerType.endDate}',
  );

  ///日期选择器的控制器
  var repairStartDate = DatePickerController(
    buttonName: "报修时间",
    PickerType.startDate,
    saveKey: '${RouteConfig.deviceMaintenance.name}${'repairStartDate'}',
  )..lastDate = DateTime(
      DateTime.now().year, DateTime.now().month + 2, DateTime.now().day);

  ///日期选择器的控制器
  var repairEndDate = DatePickerController(
    buttonName: "修复时间",
    PickerType.endDate,
    saveKey: '${RouteConfig.deviceMaintenance.name}${'repairEndDate'}',
  )..lastDate = DateTime(
      DateTime.now().year, DateTime.now().month + 2, DateTime.now().day);

  ///搜索按钮的分辨事件
  search() {
    if (state.deviceNumber.isNotEmpty) {
      searchDeviceInfo(state.deviceNumber);
    } else {
      searchDeviceList();
    }
  }

  ///下拉选择器的控制器
  late SpinnerController spinnerControllerWorkShop;

  ///获取维修列表
  searchDeviceList() {
    httpGet(
      method: webApiGetRepairOrderList,
      loading: '正在获取设备维修单列表...',
      params: {
        // 'StartDate': startDate.getDateFormatYMD(),
        'StartDate': "2020-01-16",
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

  ///设备报修提交数据
  submitRecordData({
    required Function(String msg) success,
  }) {
    if (state.custodianNumber.toString().length != 6 ||
        state.peoPleInfo.value.empName == null) {
      showSnackBar(title: '警告', message: '持有人输入错误');
    } else if (state.maintenanceUnit.toString().isEmpty) {
      showSnackBar(title: '警告', message: '请输入维修单位');
    } else if (state.faultDescription.isEmpty) {
      showSnackBar(title: '警告', message: '请输入故障说明');
    } else if (state.assessmentPrevention.isEmpty) {
      showSnackBar(title: '警告', message: '请输入维修后评估及预防');
    } else {
      httpPost(method: webApiSubmitRecordData, loading: '正在提交报修信息...', body: {
        'DeviceID': state.deviceData.value.deviceMessage!.deviceID.toString(),
        'FaultDescription': state.faultDescription.value,
        'RepairTime': repairEndDate.getDateFormatYMD(), //修复时间
        'InspectionTime': repairStartDate.getDateFormatYMD(), //报修时间
        'IssueCause': state.issueCauseId,
        'AssessmentPrevention': state.assessmentPrevention.value,
        'CustodianID':
            state.deviceData.value.deviceMessage!.custodianID.toString(),
        'CustodianNumber':
            state.deviceData.value.deviceMessage!.custodianCode.toString(),
        'UserID': getUserInfo()!.userID.toString(),
        'RepairParts': state.repairParts.value,
        'MaintenanceUnit': state.maintenanceUnit.value,
        'RepairEntryData': [
          for (var i = 0; i < state.repairEntryData.length; ++i)
            {
              'AccessoriesName': state.repairEntryData[i].accessoriesName,
              'Manufacturer': state.repairEntryData[i].manufacturer,
              'Specification': state.repairEntryData[i].specification,
              'Quantity': state.repairEntryData[i].quantity,
              'Unit': state.repairEntryData[i].unit,
              'Remarks': state.repairEntryData[i].remarks,
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

  ///设备维修记录单故障原因
  goRepair() {
    httpGet(
      method: webApiGetIssueCauseType,
      loading: '正在获取设备维修记录单故障原因...',
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
          onChanged: (index) => {
            state.issueCause = list[index].issueCause.toString(),
            state.issueCauseId = list[index].iD.toString()
          },
        );

        Get.to(() => const DeviceMaintenanceRecordRepairPage());
      } else {
        errorDialog(content: response.message);
      }
    });
  }

  ///作废记录单
  repairOrderVoid({
    required String interId,
    required String reason,
    required Function(String msg) success,
  }) {
    httpPost(
      method: webApiRepairOrderVoid,
      loading: '正在作废记录单...',
      params: {
        'InterID': startDate.getDateFormatYMD(),
        'VoidReason': endDate.getDateFormatYMD(),
        'UserID': getUserInfo()!.userID,
      },
    ).then((response) {
      if (response.resultCode == resultSuccess) {
        success.call(response.message ?? '');
      } else {
        errorDialog(content: response.message);
      }
    });
  }

  ///获取设备详情
  searchDeviceInfo(String deviceNumber) {
    httpGet(
      method: webApiGetDeviceInformationByFNumber,
      loading: '正在获取设备信息...',
      params: {
        'DeviceNo': deviceNumber,
      },
    ).then((response) {
      if (response.resultCode == resultSuccess) {
        state.deviceData.value = DeviceMaintenanceInfo.fromJson(response.data);
        if (state.deviceData.value.repairOrder.isNull) {
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

  ///根据工号获取人员信息
  searchPeople(String number) {
    if (number.isNotEmpty && number.length == 6) {
      httpGet(
        method: webApiGetEmpAndLiableByEmpCode,
        loading: '正在读取人员信息...',
        params: {
          'EmpCode': number,
        },
      ).then((response) {
        if (response.resultCode == resultSuccess) {
          state.peoPleInfo.value = PeopleMessageInfo.fromJson(response.data);
        } else {
          errorDialog(content: response.message);
        }
      });
    }
  }
}
