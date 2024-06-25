import 'dart:convert';

import 'package:get/get.dart';
import 'package:jd_flutter/widget/picker/picker_controller.dart';

import '../../../bean/http/response/molding_pack_area_report_info.dart';
import '../../../web_api.dart';
import '../../../route.dart';
import '../../../widget/dialogs.dart';
import 'molding_pack_area_detail_report_view.dart';
import 'molding_pack_area_report_state.dart';

class MoldingPackAreaReportPageLogic extends GetxController {
  final MoldingPackAreaReportPageState state = MoldingPackAreaReportPageState();



  late DatePickerController dateControllerStart;
  late DatePickerController dateControllerEnd;
  var checkBoxController = CheckBoxPickerController(
    PickerType.mesMoldingPackAreaReportType,
    saveKey:
        '${RouteConfig.moldingPackAreaReport.name}${PickerType.mesMoldingPackAreaReportType}',
  );

  @override
  void onInit() {
    var today = DateTime.now();
    var start = DateTime(today.year, today.month - 2, today.day);
    dateControllerStart = DatePickerController(
      PickerType.startDate,
      saveKey:
          '${RouteConfig.moldingPackAreaReport.name}${PickerType.startDate}',
      firstDate: start,
      lastDate: today,
    );
    dateControllerEnd = DatePickerController(
      PickerType.endDate,
      saveKey: '${RouteConfig.moldingPackAreaReport.name}${PickerType.endDate}',
      firstDate: start,
      lastDate: today,
    );
    super.onInit();
  }
  query() {
    httpGet(
        method: webApiGetMoldingPackAreaReport,
        loading: '正在查询区域报表...',
        params: {
          'startDate': dateControllerStart.getDateFormatYMD(),
          'endDate': dateControllerEnd.getDateFormatYMD(),
          'factoryType': state.etTypeBody,
          'billNO': state.etInstruction,
          'clientOrderNumber': state.etOrderNumber,
          'packAreaIDs': checkBoxController.selectedIds,
        }).then((response) {
      if (response.resultCode == resultSuccess) {
        var jsonList = jsonDecode(response.data);
        var list = <MoldingPackAreaReportInfo>[];
        for (var i = 0; i < jsonList.length; ++i) {
          list.add( MoldingPackAreaReportInfo.fromJson(jsonList[i]));
        }
        state.tableData.value=list;
        if (list.isNotEmpty) Get.back();
      } else {
        errorDialog(content: response.message);
      }
    });
  }

  // string MoID,
  // string clientOrderNumber
  getDetails(int interID, String clientOrderNumber) {
    httpGet(
        method: webApiGetMoldingPackAreaReportDetail,
        loading: '正在获取报表明细...',
        params: {
          'interID': interID,
          'clientOrderNumber': clientOrderNumber,
        }).then((response) {
      if (response.resultCode == resultSuccess) {
        var jsonList = jsonDecode(response.data);
        var list = <MoldingPackAreaReportDetailInfo>[];
        for (var i = 0; i < jsonList.length; ++i) {
          list.add( MoldingPackAreaReportDetailInfo.fromJson(jsonList[i]));
        }
        state.detailTableData.value = list;
        Get.to(() => const MoldingPackAreaDetailReportPage());
      } else {
        errorDialog(content: response.message);
      }
    });
  }
}
