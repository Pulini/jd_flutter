import 'package:get/get.dart';
import 'package:jd_flutter/utils.dart';

import '../../../bean/http/response/visit_data_list_info.dart';
import '../../../web_api.dart';
import '../../../route.dart';
import '../../../widget/dialogs.dart';
import '../../../widget/picker/picker_controller.dart';
import 'visit_register_state.dart';

class VisitRegisterLogic extends GetxController {
  //逻辑代码
  final VisitRegisterState state = VisitRegisterState();

  ///部门选择器的控制器
  var pickerControllerDepartment = OptionsPickerController(
    PickerType.mesDepartment,
    saveKey: '${RouteConfig.dailyReport.name}${PickerType.mesDepartment}',
  );

  ///日期选择器的控制器
  var pickerControllerStartDate = DatePickerController(
    PickerType.date,
    saveKey: '${RouteConfig.propertyPage.name}StartDate',
  );

  ///日期选择器的控制器
  var pickerControllerEndDate = DatePickerController(
    PickerType.date,
    saveKey: '${RouteConfig.propertyPage.name}EndDate',
  );

  getVisitList({
    String? name,
    String? iDCard,
    String? interviewee,
    String? intervieweeName,
    String? securityStaff,
    String? startTime,
    String? endTime,
    String? leave,
    String? phone,
    String? carNo,
    String? credentials,
  }) {
    httpPost(method: webApiGetVisitDtBySqlWhere, loading: '正在获取来访列表...', body: {
      'Name': name,
      'IDCard': iDCard,
      'VisitedFactory': getUserInfo()?.organizeID,
      'Interviewee': interviewee,
      'IntervieweeName': intervieweeName,
      'SecurityStaff': securityStaff,
      'StartTime': startTime,
      'EndTime': endTime,
      'Leave': leave,
      'Phone': phone,
      'CarNo': carNo,
      'Credentials': credentials,
    }).then((response) {
      if (response.resultCode == resultSuccess) {
        state.dataList.value = [
          for (var i = 0; i < response.data.length; ++i)
            VisitDataListInfo.fromJson(response.data[i])
        ];
      } else {
        state.dataList.value = [];
        errorDialog(content: response.message);
      }
    });
  }

  getInviteCode() {
    httpGet(
      method: webApiGetInviteCode,
      loading: '正在获取来访编号...',
    ).then((response) {
      if (response.resultCode == resultSuccess) {
        state.visitCode = response.data.toString();
      } else {
        state.visitCode = response.message!;
        errorDialog(content: response.message);
      }
    });
  }

  @override
  void onReady() {
    super.onReady();
    getVisitList(leave: "0");
    getInviteCode();
  }

  @override
  void onClose() {
    // TODO: implement onClose
    super.onClose();
  }
}
