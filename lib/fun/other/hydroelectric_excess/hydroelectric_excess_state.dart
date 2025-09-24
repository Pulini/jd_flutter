import 'package:get/get.dart';
import 'package:jd_flutter/bean/http/response/device_detail_info.dart';
import 'package:jd_flutter/bean/http/response/device_list_info.dart';
import 'package:jd_flutter/utils/utils.dart';
import 'package:jd_flutter/utils/web_api.dart';
import 'package:jd_flutter/widget/custom_widget.dart';
import 'package:jd_flutter/widget/dialogs.dart';

class HydroelectricExcessState {
  var dataList = <DeviceListInfo>[].obs; //来访数据
  var isShow = false.obs;
  var select = '0'.obs; //选择查询的条件
  var stateToSearch = '0'.obs; //返回回去的状态

  var dataDetail = DeviceDetailInfo().obs;
  var thisMonthUse = ''.obs; //本月使用量



//搜索具体房间信息
  searchRoom({
    required String  type,
    required DeviceListInfo data,
    required Function(List<DeviceDetailInfo>) success,
    required Function(String) error,
  }) {
    httpGet(
      method: webApiGetWaterEnergyMachineDetail,
      loading: 'hydroelectric_reading_room_information'.tr,
      params: {
        'Number': data.number,
        'EditState': type,
      },
    ).then((response) {
      if (response.resultCode == resultSuccess) {
        success.call(
            [for (var json in response.data) DeviceDetailInfo.fromJson(json)]);
      } else {
        error.call(response.message ?? 'query_default_error'.tr);
      }
    });
  }

  //获取所有设备信息
  getWaterEnergyMachine({
    required String deviceNumber,
    required String bedNumber,
  }) {
    httpGet(
      method: webApiGetWaterEnergyMachine,
      loading: 'hydroelectric_reading_device'.tr,
      params: {
        'ShowType': select.value,
        'MachineNumber': deviceNumber,
        'BedNumber': bedNumber,
      },
    ).then((response) {
      if (response.resultCode == resultSuccess) {
        var list = <DeviceListInfo>[
          for (var i = 0; i < response.data.length; ++i)
            DeviceListInfo.fromJson(response.data[i])
        ];
        dataList.value = list;
      } else {
        errorDialog(content: response.message);
      }
    });
  }

  //提交本次抄录数据
  submit({required String textThisTime}) {
    if (textThisTime.isEmpty) {
      showSnackBar(
          title: 'shack_bar_warm'.tr,
          message: 'hydroelectric_this_transcription'.tr);
    } else {
      httpPost(
        method: webApiSubmitSsWaterEnergyMachineDetail,
        loading: 'hydroelectric_submitting_degree'.tr,
        params: {
          'LastDegree': dataDetail.value.lastDegree,
          'NowDegree': textThisTime,
          'ItemID': dataDetail.value.itemID,
          'ID': dataDetail.value.id,
          'UserID': userInfo?.userID,
        },
      ).then((response) {
        if (response.resultCode == resultSuccess) {
          successDialog(content: response.message);
        } else {
          errorDialog(content: response.message);
        }
      });
    }
  }
}
