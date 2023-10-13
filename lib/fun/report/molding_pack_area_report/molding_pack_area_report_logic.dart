import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jd_flutter/widget/picker/picker_controller.dart';

import '../../../http/response/molding_pack_area_report_info.dart';
import '../../../http/web_api.dart';
import '../../../route.dart';
import '../../../widget/dialogs.dart';

class MoldingPackAreaReportPageLogic extends GetxController {
  var textControllerInstruction = TextEditingController();
  var textControllerOrderNumber = TextEditingController();
  var textControllerTypeBody = TextEditingController();

  late DatePickerController dateControllerStart;
  late DatePickerController dateControllerEnd;
  var checkBoxController = CheckBoxController(
    PickerType.mesMoldingPackAreaReportType,
  );

  RxList<DataRow> tableDataRows = <DataRow>[].obs;
  List<DataColumn> tableDataColumn = <DataColumn>[
    DataColumn(label: Text('page_production_day_report_table_title_hint2'.tr)),
    DataColumn(
      label: Text('page_production_day_report_table_title_hint3'.tr),
      numeric: true,
    ),
  ];

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

  // @override
  // void onReady() {
  //   super.onReady();
  //   refreshList();
  // }

  // string startDate,
  // string endDate,
  // string factoryType,
  // string billNO,
  // string clientOrderNumber,
  // List<string> packAreaIDs

  query() {
    httpGet(
        method: webApiGetMoldingPackAreaReport,
        loading: '正在查询区域报表...',
        query: {
          'startDate': '',
          'endDate': '',
          'factoryType': '',
          'billNO': '',
          'clientOrderNumber': '',
          'packAreaIDs': ['1', '2', '3'],
        }).then((response) {
      if (response.resultCode == resultSuccess) {
        var list = <MoldingPackAreaReportInfo>[];
        for (var item in jsonDecode(response.data)) {
          list.add(MoldingPackAreaReportInfo.fromJson(item));
        }
      } else {
        errorDialog(content: response.message);
      }
    });
  }

  // string MoID,
  // string clientOrderNumber
  getDetails(String interID, String clientOrderNumber) {
    httpGet(
        method: webApiGetMoldingPackAreaReportDetail,
        loading: '正在获取报表明细...',
        query: {
          'MoID': interID,
          'clientOrderNumber': clientOrderNumber,
        }).then((response) {
      if (response.resultCode == resultSuccess) {
        var list = <MoldingPackAreaReportDetailInfo>[];
        for (var item in jsonDecode(response.data)) {
          list.add(MoldingPackAreaReportDetailInfo.fromJson(item));
        }
      } else {
        errorDialog(content: response.message);
      }
    });
  }
}
