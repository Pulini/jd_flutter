import 'package:get/get_rx/get_rx.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';
import 'package:jd_flutter/bean/http/response/group_dispatch_info.dart';
import 'package:jd_flutter/bean/http/response/people_message_info.dart';
import 'package:jd_flutter/bean/http/response/worker_info.dart';
import 'package:jd_flutter/utils/web_api.dart';

class GroupDispatchState {

  var titleInfo = Rxn<ProcessWorkCardInfo>();
  var partList=<ComponentItem>[].obs;
  var workerList = <WorkerInfo>[].obs;


  GroupDispatchState() {
    ///Initialize variables
  }

  //获取包装清单贴标总数量
  void getProcessWorkCardInfo(
    String order, {
    required Function(WorkCardDetail) success,
    required Function(String) error,
  }) {
    httpGet(
      method: webApiGetProcessWorkCardInfo,
      loading: 'maintain_label_getting_label_info'.tr,
      params: {'processNo': order},
    ).then((response) {
      if (response.resultCode == resultSuccess) {
        success.call(WorkCardDetail.fromJson(response.data));
      } else {
        error.call(response.message ?? 'query_default_error'.tr);
      }
    });
  }

  void saveProcessWorkCardInfo({
    required void Function(String) success,
  }) {
    // httpPost(
    //   method: webApiSaveProcessWorkCardInfo,
    //   loading: 'team_leader_issue_work_order'.tr,
    //   body: {
    //     'FInterID': workCardInfo.processWorkCardInfo!.interID,
    //     'FCardNo': workCardInfo.processWorkCardInfo!.fCardNo,
    //     'SizeList': [
    //       for (var comp in workCardInfo.componentList ?? [])
    //         for (var data in comp.sizeList ?? [])
    //           {
    //             'Size': data.size,
    //             'EmpID': data.empID,
    //             'AllocatedQty': data.currentQty.value,
    //             'FItemID': data.fItemID,
    //             'FRouteEntryFID': data.fRouteEntryFID,
    //             'FMtono': data.fMtono,
    //           }
    //     ],
    //   },
    // ).then((response) {
    //   if (response.resultCode == resultSuccess) {
    //     success.call(response.message ?? '');
    //   } else {
    //     errorDialog(content: response.message ?? '');
    //   }
    // });
  }

  //根据组织(工作中心)id 获取对应人员，刷新人员选择列表
  void getWorkerInfo({
    String? department,
  }) {
    httpGet(method: webApiGetWorkerInfo, params: {
      'EmpNumber': '',
      'DeptmentID': department,
    }).then((response) {
      if (response.resultCode == resultSuccess) {
      } else {}
    });
  }

  // 根据工号获取人员信息（右侧花名册匹配不到时调用），返回查到的人员，失败返回 null
  Future<PeopleMessageInfo?> searchPeople(String number) async {
    if (number.isNotEmpty && number.length == 6) {
      var response = await httpGet(
        method: webApiGetEmpAndLiableByEmpCode,
        loading: 'device_maintenance_personnel_information'.tr,
        params: {
          'EmpCode': number,
        },
      );
      if (response.resultCode == resultSuccess) {
        return PeopleMessageInfo.fromJson(response.data);
      } else {
        // errorDialog(content: response.message);
      }
    }
    return null;
  }
}
