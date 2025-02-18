import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:jd_flutter/bean/http/response/device_detail_info.dart';
import 'package:jd_flutter/bean/http/response/device_list_info.dart';
import 'package:jd_flutter/utils/utils.dart';
import 'package:jd_flutter/utils/web_api.dart';
import 'package:jd_flutter/widget/custom_widget.dart';
import 'package:jd_flutter/widget/dialogs.dart';

class HydroelectricExcessState {


  var dataList = <DeviceListInfo>[].obs;  //来访数据
  var isShow = false.obs;
  var select = "0".obs; //选择查询的条件
  var stateToSearch ="0".obs;   //返回回去的状态
  var deviceNumber ="";//设备编号
  var bedNumber ="";//床铺编号
  var dataDetail = DeviceDetailInfo().obs;
  var thisMonthUse = "".obs; //本月使用量

  var textThisTime = TextEditingController(); //本次抄度
  var textNumber = TextEditingController(); //房间号


///搜索具体房间信息
  searchRoom(DeviceListInfo data,bool  isBack){
    if(select.value=='0' || select.value =='2'){
      stateToSearch.value='1';
    }else{
      stateToSearch.value='0';
    }
    httpGet(
      method: webApiGetWaterEnergyMachineDetail,
      loading: '正在读取房间信息...',
      params: {
        'Number': data.number,
        'EditState': stateToSearch.value,
      },
    ).then((response) {
      if (response.resultCode == resultSuccess) {
        var list = <DeviceDetailInfo>[
          for (var i = 0; i < response.data.length; ++i)
            DeviceDetailInfo.fromJson(response.data[i])
        ];
        if(list.isNotEmpty) {
          dataDetail.value = list[0];
          textNumber.text = dataDetail.value.number!;
          textThisTime.text = dataDetail.value.nowDegree!;
        }

        if (list.isNotEmpty) setDeviceUse(list[0]);  //设置本月使用量
        if(isBack) Get.back();
      } else {
        errorDialog(content: response.message);
      }
    });
  }

  ///用户手动输入后，清理数据
  clearData(){
    dataDetail.value = DeviceDetailInfo();
    textThisTime.clear();
    thisMonthUse.value='';
    stateToSearch.value='0';
  }

  ///根据输入的度数，
  countMonth(String thisTime){
    var degree = thisTime.toIntTry();
    var lastDegree = dataDetail.value.lastDegree.toIntTry();

    if(lastDegree>=0 && degree >0 && degree>lastDegree){
      thisMonthUse.value = (degree - lastDegree).toString();
    }else{
      thisMonthUse.value = '0';
    }
  }


  ///计算本月使用量
  setDeviceUse(DeviceDetailInfo data){

    var last = data.lastDegree.toIntTry();
    var now = data.nowDegree.toIntTry();

    if(now>0 && last>=0 && now> last){
      thisMonthUse.value = (now-last).toString();
    }else{
      thisMonthUse.value='0';
    }

  }

  ///是否显示
  clickShow(){
    if(isShow.value == true){
      isShow.value = false;
    }else{
      isShow.value = true;
    }
  }

  ///获取所有设备信息
  getWaterEnergyMachine() {
    httpGet(
      method: webApiGetWaterEnergyMachine,
      loading: '正在读取设备...',
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

  ///提交本次抄录数据
  submit() {
    if(textThisTime.text.isEmpty){
      showSnackBar(title: '警告', message:'请输入本次抄录度数！');
    }else{
      httpPost(
        method: webApiSubmitSsWaterEnergyMachineDetail,
        loading: '正在提交度数...',
        params: {
          'LastDegree': dataDetail.value.lastDegree,
          'NowDegree': textThisTime.text,
          'ItemID': dataDetail.value.itemID,
          'ID': dataDetail.value.id,
          'UserID': getUserInfo()!.userID,
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