import 'package:get/get.dart';
import 'package:jd_flutter/bean/http/response/device_detail_info.dart';
import 'package:jd_flutter/bean/http/response/device_list_info.dart';
import 'package:jd_flutter/fun/other/hydroelectric_excess/hydroelectric_excess_state.dart';
import 'package:jd_flutter/utils/extension_util.dart';
import 'package:jd_flutter/widget/dialogs.dart';

class HydroelectricExcessLogic extends GetxController {
  final HydroelectricExcessState state = HydroelectricExcessState();

  //用户手动输入后，清理数据
  void clearData() {
    state.dataDetail.value = DeviceDetailInfo();
    state.thisMonthUse.value = '';
    state.stateToSearch.value = '0';
  }

  //根据输入的度数，
  void countMonth(String thisTime) {
    var degree = thisTime.toIntTry();
    var lastDegree = state.dataDetail.value.lastDegree.toIntTry();

    if (lastDegree >= 0 && degree > 0 && degree > lastDegree) {
      state.thisMonthUse.value = (degree - lastDegree).toString();
    } else {
      state.thisMonthUse.value = '0';
    }
  }

  //计算本月使用量
  void setDeviceUse(DeviceDetailInfo data) {
    var last = data.lastDegree.toIntTry();
    var now = data.nowDegree.toIntTry();

    if (now > 0 && last >= 0 && now > last) {
      state.thisMonthUse.value = (now - last).toString();
    } else {
      state.thisMonthUse.value = '0';
    }
  }

  void searchRoom({
    required String  searchType,
    required DeviceListInfo data,
    required bool isBack,
     Function(String, String)? refresh,
     Function()? setRoom,
  }) {
    state.searchRoom(
      type: searchType,
      data: data,
      success: (list) {
        if (list.isNotEmpty) {
          state.dataDetail.value = list.first;
          refresh?.call(list.first.number!, list.first.nowDegree!);
        }
        if (list.isNotEmpty) setDeviceUse(list.first); //设置本月使用量
        if (isBack) Get.back(result: true);
      },
      error: (msg) => errorDialog(content: msg),
    );
  }

  void searchData({
    required String deviceNumber,
    required String bedNumber,
  }) {
    state.getWaterEnergyMachine(
      deviceNumber: deviceNumber,
      bedNumber: bedNumber,
    );
  }
}
