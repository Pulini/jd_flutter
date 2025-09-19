import 'package:collection/collection.dart';
import 'package:get/get.dart';
import 'package:jd_flutter/bean/http/response/handover_report_list_info.dart';
import 'package:jd_flutter/utils/extension_util.dart';
import 'package:jd_flutter/utils/utils.dart';
import 'package:jd_flutter/widget/custom_widget.dart';
import 'package:jd_flutter/bean/http/response/show_handover_report_list.dart';
import 'package:jd_flutter/route.dart';
import 'package:jd_flutter/utils/web_api.dart';
import 'package:jd_flutter/widget/dialogs.dart';
import 'package:jd_flutter/widget/picker/picker_controller.dart';
import 'package:jd_flutter/widget/spinner_widget.dart';
import 'handover_report_list_state.dart';

class HandoverReportListLogic extends GetxController {
  final HandoverReportListState state = HandoverReportListState();

  //日期选择器的控制器
  late DatePickerController pickerControllerDate = DatePickerController(
      PickerType.date,
      saveKey: '${RouteConfig.handoverReportList.name}${PickerType.date}',
      buttonName: 'handover_report_date'.tr);

  //下拉选择器的控制器(选择报工类型)
  late SpinnerController reportType = SpinnerController(
    saveKey: RouteConfig.handoverReportList.name,
    dataList: [
      'handover_report_report_spinner_hint1'.tr,
      'handover_report_report_spinner_hint2'.tr,
    ],
    onChanged: (index) {
      state.reportPosition = index;
      if (state.handoverDataList.isNotEmpty) {arrangeData();}
    },
  );

  //下拉选择器的控制器(选择早晚班)
  late SpinnerController shiftType = SpinnerController(
      saveKey: '${RouteConfig.handoverReportList.name}shift',
      dataList: [
        'handover_report_shift_spinner_hint1'.tr,
        'handover_report_shift_spinner_hint2'.tr,
        'handover_report_shift_spinner_hint3'.tr,
      ],
      onChanged: (index) {
            state.shiftType = index;
            if (state.handoverDataList.isNotEmpty) {arrangeData();}
          });

  //全选或者反选
  selectAll(bool select) {
    for (var c in state.dataList) {
      c.select = select;
    }

    state.dataList.refresh();
  }

  //获取报工交接列表
  getInstructionDetailsFile() {
    httpGet(
      loading: 'handover_report_get_handover_list'.tr,
      method: webApiGetScWorkCardReportCheckList,
      params: {
        'Date': pickerControllerDate.getDateFormatYMD(),
        'UserID': userInfo?.userID,
      },
    ).then((response) {
      if (response.resultCode == resultSuccess) {
        var list = <HandoverReportListInfo>[
          for (var i = 0; i < response.data.length; ++i)
            HandoverReportListInfo.fromJson(response.data[i])
        ];
        state.handoverDataList = list;
        arrangeData();
      } else {
        errorDialog(content: response.message ?? 'query_default_error'.tr);
      }
    });
  }

  //spinner 点击后的筛选
  arrangeData() {
    if (reportType.selectIndex == 0) {
      //已报工
      switch (shiftType.selectIndex) {
        case 0: // 全部
          arrangeShowData('', true);
          break;
        case 1: // 早班
          arrangeShowData('白班', true);
          break;
        default: //晚班
          arrangeShowData('晚班', true);
          break;
      }
    } else {
      //未报工
      switch (shiftType.selectIndex) {
        case 0: // 全部
          arrangeShowData('', false);
          break;
        case 1: // 早班
          arrangeShowData('白班', false);
          break;
        default: //晚班
          arrangeShowData('晚班', false);
          break;
      }
    }
  }

  //整理显示数据
  arrangeShowData(String type, bool isState) {
    var data = <ShowHandoverReportList>[];
    logger.f('type:$type');
    if (type.isEmpty) {
      logger.f('-------------');
      state.handoverDataList
          .where((data) => data.status == isState)
          .forEach((v) {
        var processNames = '';

        v.empList?.forEachIndexed((c, v) {
          if (c % 2 == 0) {
            processNames =
                '$processNames${v.processName}:${v.empName}  数量：${v.qty.toShowString()}${v.unit}    ';
          } else {
            processNames =
                '$processNames${v.processName}:${v.empName}    数量：${v.qty.toShowString()}${v.unit}\n';
          }
        });

        var list = <SubList>[];
        v.sizeList?.forEach((s) {
          list.add(SubList(
              subSize: s.size,
              subCapacity: s.capacity,
              subLastMantissa: s.lastMantissa,
              subMantissa: s.mantissa,
              subBox: s.boxesQty,
              subQty: s.qty,
              subDispatchNum: s.dispatchQty));
        });

        list.add(SubList(
            subSize: '合计',
            subCapacity: v.sizeList
                ?.map((sub) => sub.capacity)
                .fold(0.0, (total, capacity) => total.add(capacity ?? 0.0)),
            subLastMantissa: v.sizeList?.map((sub) => sub.lastMantissa).fold(
                0.0, (total, lastMantissa) => total.add(lastMantissa ?? 0.0)),
            subMantissa: v.sizeList
                ?.map((sub) => sub.mantissa)
                .fold(0.0, (total, mantissa) => total.add(mantissa ?? 0.0)),
            subBox: v.sizeList
                ?.map((sub) => sub.boxesQty)
                .fold(0.0, (total, boxesQty) => total.add(boxesQty ?? 0.0)),
            subQty: v.sizeList
                ?.map((sub) => sub.qty)
                .fold(0.0, (total, qty) => total.add(qty ?? 0.0)),
            subDispatchNum: v.sizeList?.map((sub) => sub.dispatchQty).fold(
                0.0, (total, dispatchQty) => total.add(dispatchQty ?? 0.0))));

        data.add(ShowHandoverReportList(
            interID: v.interID,
            dispatchNumber: v.dispatchNumber,
            machine: v.machine,
            factoryType: v.factoryType,
            status: v.status,
            shift: v.shift,
            select: false,
            changeColor: false,
            processName: processNames,
            subList: list));
      });
    } else {
      logger.f('-------0------');
      state.handoverDataList
          .where((data) => data.status == isState && data.shift == type)
          .forEach((v) {
        var processNames = '';

        v.empList?.forEachIndexed((c, v) {
          if (c % 2 == 0) {
            processNames =
                '$processNames${v.processName}:${v.empName}  数量：${v.qty.toShowString()}${v.unit}    ';
          } else {
            processNames =
                '$processNames${v.processName}:${v.empName}    数量：${v.qty.toShowString()}${v.unit}\n';
          }
        });
        var list = <SubList>[];
        v.sizeList?.forEach((s) {
          list.add(SubList(
              subSize: s.size,
              subCapacity: s.capacity,
              subLastMantissa: s.lastMantissa,
              subMantissa: s.mantissa,
              subBox: s.boxesQty,
              subQty: s.qty,
              subDispatchNum: s.dispatchQty));
        });

        list.add(SubList(
            subSize: '合计',
            subCapacity: v.sizeList
                ?.map((sub) => sub.capacity)
                .fold(0.0, (total, capacity) => total.add(capacity ?? 0.0)),
            subLastMantissa: v.sizeList?.map((sub) => sub.lastMantissa).fold(
                0.0, (total, lastMantissa) => total.add(lastMantissa ?? 0.0)),
            subMantissa: v.sizeList
                ?.map((sub) => sub.mantissa)
                .fold(0.0, (total, mantissa) => total.add(mantissa ?? 0.0)),
            subBox: v.sizeList
                ?.map((sub) => sub.boxesQty)
                .fold(0.0, (total, boxesQty) => total.add(boxesQty ?? 0.0)),
            subQty: v.sizeList
                ?.map((sub) => sub.qty)
                .fold(0.0, (total, qty) => total.add(qty ?? 0.0)),
            subDispatchNum: v.sizeList?.map((sub) => sub.dispatchQty).fold(
                0.0, (total, dispatchQty) => total.add(dispatchQty ?? 0.0))));

        data.add(ShowHandoverReportList(
            interID: v.interID,
            dispatchNumber: v.dispatchNumber,
            machine: v.machine,
            factoryType: v.factoryType,
            status: v.status,
            shift: v.shift,
            select: false,
            changeColor: false,
            processName: processNames,
            subList: list));
      });
    }

    state.dataList.value = data;
  }

  //选中第几条数据
  selectPosition(position) {
    state.dataList[position].select = !state.dataList[position].select!;
    state.dataList.refresh();
  }

  //是否有选中数据
  bool haveSelect() {
    if (state.dataList.where((data) => data.select == true).isNotEmpty) {
      return true;
    } else {
      showSnackBar(message: 'handover_report_select_data'.tr);
      return false;
    }
  }

  //删除并反审核
  reverseWork({
    required Function(String) success,
  }) {
    var interList = <int>[];
    state.dataList.where((data) => data.select == true).forEach((c) {
      interList.add(c.interID!);
    });
    httpPost(
      method: webApiUnCheckScWorkCardReport,
      loading: 'handover_report_delete_and_reverse'.tr,
      body: {
        'InterIDs': interList,
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

  //删除
  deleteWork({
    required Function(String) success,
  }) {
    var interList = <int>[];
    state.dataList.where((data) => data.select == true).forEach((c) {
      interList.add(c.interID!);
    });
    httpPost(
      method: webApiDelScWorkCardReport,
      loading: 'handover_report_delete'.tr,
      body: {
        'InterIDs': interList,
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

  bool screenData() {
    var judge = 0;
    state.dataList.where((data) => data.select == true).forEach((c) {
      if(c.subList!.where((sub) => sub.subDispatchNum == 0.0 && sub.subBox! > 1.0).isNotEmpty){
        c.changeColor = true;
      }
      c.subList!.where((sub) => sub.subDispatchNum == 0.0 && sub.subBox! > 1.0).forEach((v) {
        judge = judge + 1;
      });
    });

    if(judge>0){
      return false;
    }else{
      return true;
    }
  }

  //审核生成工序汇报单
  checkWork({
    required Function(String) success,
  }) {
    var interList = <int>[];
    state.dataList.where((data) => data.select == true).forEach((c) {
      interList.add(c.interID!);
    });
    httpPost(
      method: webApiCheckScWorkCardReport,
      loading: 'handover_report_review_and_generate'.tr,
      body: {
        'InterIDs': interList,
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
}
