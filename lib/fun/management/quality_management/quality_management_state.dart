import 'dart:async';

import 'package:get/get.dart';
import 'package:jd_flutter/bean/http/response/add_entry_detail_info.dart';
import 'package:jd_flutter/bean/http/response/exception_type_info.dart';
import '../../../bean/http/response/abnormal_quality_info.dart';
import '../../../bean/http/response/abnormal_quality_list_info.dart';
import '../../../utils.dart';
import '../../../web_api.dart';

class QualityManagementState {
  RxList<AbnormalQualityInfo> dataList = <AbnormalQualityInfo>[].obs;
  RxList<ExceptionTypeInfo> exceptionDataList = <ExceptionTypeInfo>[].obs;

  RxList<AbnormalQualityListInfo> orderShowSubDataList =
      <AbnormalQualityListInfo>[].obs;
  RxList<Entry> showEntryDataList = <Entry>[].obs;
  var isOutsourcing =
      spGet('${Get.currentRoute}/QualityOutsourcing') ?? false; //是否委外
  var isAutomatic =
      spGet('${Get.currentRoute}/QualityAutomatic') ?? false; //是否自动提交

  var order = "";
  var slight = true.obs; //轻微
  var serious = false.obs; //严重

  var headIndex = 0; //2级列表头index
  var selected = (-1).obs;
  var personal = ("${"${getUserInfo()!.name!}（${getUserInfo()!.number}"})").obs;
  var searchPeople = '';
  var searchPeopleEmpId = '';
  var searchPeopleDepartmentID = '';

  var countTimer = 0;
  var countTimerNumber = "3".obs;
  var dialogMiss = false.obs;

  ///需要提交的数据
  var departmentID =getUserInfo()!.departmentID.toString();  //部门id
  var empID =getUserInfo()!.empID.toString();  //员工empId
  var entryID ="";  //异常id
  var interID ="";  //工单id
  var number = "1".obs;  //异常数量
  AddEntryDetailInfo? addEntryDetailInfo;


  getProductionProcessInfo({
    required String mtoNo,
    required bool outsourcing,
    required Function(String msg) error,
  }) {
    httpGet(method: webApiGetSCDispatchOrders, loading: '正在获取数据详情...', params: {
      'MtoNo': mtoNo,
      // 'dateStart': pcStartDate.getDateFormatYMD(),
      // 'dateEnd': pcEndDate.getDateFormatYMD(),
      'dateStart': '',
      'dateEnd': '',
      'isOutsourcing': outsourcing,
    }).then((response) {
      if (response.resultCode == resultSuccess) {
        dataList.value = [
          for (var json in response.data) AbnormalQualityInfo.fromJson(json)
        ];

        orderShowSubDataList.clear();
        var list = <String>[];
        list.clear();
        for (var i = 0; i < dataList.length; ++i) {
          if (!list.contains(dataList[i].orderNumber)) {
            list.add(dataList[i].orderNumber!);
          }
        }

        for (var i = 0; i < list.length; ++i) {
          var listData = <AbnormalQualityInfo>[];
          listData.clear();
          for (var o = 0; o < dataList.length; ++o) {
            if (dataList[o].orderNumber == list[i]) {
              listData.add(dataList[o]);
            }
          }
          orderShowSubDataList.add(AbnormalQualityListInfo(
              abnormalQualityInfo: listData, orderNumber: list[i]));
        }
        if (orderShowSubDataList.isNotEmpty) Get.back();
      } else {
        dataList.value = [];
        orderShowSubDataList.value = [];
        error.call(response.message ?? '');
      }
    });
  }

  timeDown() {
    Timer.periodic(
      const Duration(milliseconds: 1000),
      (timer) {
        countTimer++;
        if (countTimer == 3) {
          timer.cancel();
          countTimer = 0;
          countTimerNumber.value = "0";
        } else {
          countTimerNumber.value = (3 - countTimer).toString();
        }
      },
    );
  }

  arrangementData(int index) {
    var lists = <Entry>[];
    lists.clear();
    showEntryDataList.value =
        orderShowSubDataList[headIndex].abnormalQualityInfo![index].entry!;

    interID = orderShowSubDataList[headIndex].abnormalQualityInfo![index].interID.toString();
  }

  getProcessFlowEXTypes({
    required int index,
    required Function(String msg) error,
  }) {
    httpGet(
        method: webApiGetProcessFlowEXTypes,
        loading: '正在获取异常类型...',
        params: {
          'processFlowID': orderShowSubDataList[headIndex]
              .abnormalQualityInfo![index]
              .processFlowID!,
        }).then((response) {
      if (response.resultCode == resultSuccess) {
        exceptionDataList.value = [
          for (var json in response.data) ExceptionTypeInfo.fromJson(json)
        ];
      } else {
        exceptionDataList.value = [];
        error.call(response.message ?? '');
      }
    });
  }

  submitReview({
    required Function(String msg) error,
  }) {

    logger.f('serious:$serious');
    logger.f('slight:$slight');

    var type ='';

    if(serious.value){
      type='1';
    }

    if(slight.value){
      type='0';
    }


    httpPost(method: webApiAddAbnormalQuality, loading: '正在上传品质异常数据...', body: {
      'DeptmentID': departmentID,
      'EmpID': empID,
      'WorkCardEntryID': entryID,
      'WorkCardInterID': interID,
      'Qty': number.value,
      'Entry': [
        {
          'EntryID': "1",
          'ExceptionID': entryID,
          'ExceptionLevel': type,
        }
      ],
    }).then((response) {
      if (response.resultCode == resultSuccess) {

        addEntryDetailInfo = AddEntryDetailInfo.fromJson(response.data);
        var list = <Entry>[];
        list.clear();

        for (var o = 0; o < showEntryDataList.length; ++o) {
          list.add(showEntryDataList[o]);
        }

        list.add(Entry());
        showEntryDataList.value = list;

      } else {
        error.call(response.message ?? '');
      }
    });
  }
}
