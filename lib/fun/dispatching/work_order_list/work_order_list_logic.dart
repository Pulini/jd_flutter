import 'dart:convert';

import 'package:get/get.dart';
import 'package:jd_flutter/fun/dispatching/work_order_list/part_label_view.dart';
import 'package:jd_flutter/utils.dart';
import 'package:jd_flutter/widget/custom_widget.dart';

import '../../../bean/http/request/part_detail.dart';
import '../../../bean/http/response/part_detail_info.dart';
import '../../../bean/http/response/work_order_info.dart';
import '../../../route.dart';
import '../../../web_api.dart';
import '../../../widget/dialogs.dart';
import '../../../widget/picker/picker_controller.dart';
import 'work_order_list_state.dart';

class WorkOrderListLogic extends GetxController {
  final WorkOrderListState state = WorkOrderListState();

  ///组别选择器的控制器
  var pcGroup = OptionsPickerController(
    PickerType.sapGroup,
    saveKey: '${RouteConfig.workOrderListPage.name}${PickerType.sapGroup}',
  );

  ///日期选择器的控制器
  var pcStartDate = DatePickerController(
    PickerType.startDate,
    saveKey: '${RouteConfig.workOrderListPage.name}${PickerType.startDate}',
  );

  ///日期选择器的控制器
  var pcEndDate = DatePickerController(
    PickerType.endDate,
    saveKey: '${RouteConfig.workOrderListPage.name}${PickerType.endDate}',
  );

  @override
  void onReady() {
    // TODO: implement onReady
    super.onReady();
  }

  @override
  void onClose() {
    // TODO: implement onClose
    super.onClose();
  }

  query() {
    httpGet(
      method: webApiGetWorkCardOrderList,
      loading: '正在获取包装清单箱容配置信息...',
      params: {
        'StartTime':
            state.workBarCode.isEmpty ? pcStartDate.getDateFormatYMD() : '',
        'EndTime':
            state.workBarCode.isEmpty ? pcEndDate.getDateFormatYMD() : '',
        'DeptID': state.workBarCode.isEmpty ? pcGroup.selectedId.value : '',
        'IsClose': state.workBarCode.isEmpty ? state.isClosed : false,
        'isOutsourcing':
            state.workBarCode.isEmpty ? state.isOutsourcing : false,
        'moNo': state.workBarCode.isEmpty ? state.planOrderNumber : '',
        'ProcessWorkBarCode': state.workBarCode,
      },
    ).then((response) {
      if (response.resultCode == resultSuccess) {
        var list = <WorkOrderInfo>[].obs;
        var jsonList = jsonDecode(response.data);
        for (var i = 0; i < jsonList.length; ++i) {
          list.add(WorkOrderInfo.fromJson(jsonList[i]));
        }
        state.dataList.value = list;
        if (list.isNotEmpty) Get.back();
      } else {
        errorDialog(content: response.message);
      }
    });
  }

  queryPartList() {
    httpGet(
      method: webApiGetPartList,
      loading: '正在获取部件列表...',
      params: {
        'WorkCardBarCode': state.orderId,
        'DeptID': userInfo?.departmentID,
      },
    ).then((response) {
      if (response.resultCode == resultSuccess) {
        var list = <PartInfo>[].obs;
        var jsonList = jsonDecode(response.data);
        for (var i = 0; i < jsonList.length; ++i) {
          list.add(PartInfo.fromJson(jsonList[i]));
        }
        state.partList.value = list;
      } else {
        errorDialog(content: response.message);
      }
    });
  }

  submitCheck() {
    var selected = state.partList.where((v) => v.select);
    if (selected.isEmpty) {
      showSnackBar(title: '错误', message: '至少选择一个部件', isWarning: true);
    } else {
      if (selected.length > 1) {
        var names = <String>[];
        var name = '';
        for (var data in selected) {
          names.add(data.partName ?? '');
        }
        name = names.join('和');
        askDialog(
            content: '确定要合并：$name吗？',
            confirm: () {
              Get.to(() => const PartLabelPage());
            });
      } else {
        Get.to(() => const PartLabelPage());
      }
    }
  }

  queryPartDetail() {
    var list = <String>[];
    state.partList.where((v) => v.select).forEach((data) {
      if (data.linkPartName?.isEmpty == true) {
        list.add(data.partName ?? '');
      } else {
        list.addAll(data.linkPartName ?? []);
      }
    });
    list = list.toSet().toList();
    httpPost(
      method: webApiGetPartDetail,
      loading: '正在获取部件详情...',
      body: PartDetailQuery(
        workCardBarCode: state.orderId,
        partNames: list,
        deptID: userInfo?.departmentID ?? 0,
      ),
    ).then((response) {
      var barCode = [
        BarCodeInfo(
          barCode: '111111',
          printTimes: 1,
          size: '30',
          createQty: 40,
          reported: false,
          mtonoList: [
            MtonoInfo(
              mtono: 'j111111',
              qty: 100,
              createQty: 50,
              empID: 101,
              empNumber: '012345',
              empName: '张三',
            ),
            MtonoInfo(
              mtono: 'j222222',
              qty: 100,
              createQty: 50,
              empID: 101,
              empNumber: '012345',
              empName: '赵四',
            ),
          ],
        ),
        BarCodeInfo(
          barCode: '222222',
          printTimes: 1,
          size: '30',
          createQty: 40,
          reported: false,
          mtonoList: [
            MtonoInfo(
              mtono: 'j111111',
              qty: 100,
              createQty: 50,
              empID: 101,
              empNumber: '012345',
              empName: '张三',
            ),
            MtonoInfo(
              mtono: 'j222222',
              qty: 100,
              createQty: 50,
              empID: 101,
              empNumber: '012345',
              empName: '赵四',
            ),
          ],
        )
      ];
      if (response.resultCode == resultSuccess) {
        state.partDetail = PartDetailInfo.fromJson(jsonDecode(response.data));
        state.partDetail?.barCodeList = barCode;
        state.partDetailSizeList.value = state.partDetail?.sizeList ?? [];
      } else {
        errorDialog(content: response.message);
      }
    });
  }

  createPartLabel(
    double boxCapacity,
    double qty,
    String size,
    String empId,
  ) {
    if (boxCapacity <= 0) {
      showSnackBar(title: '错误', message: '请输入箱容！', isWarning: true);
      return;
    }
    if (qty <= 0) {
      showSnackBar(title: '错误', message: '请输入创建数量！', isWarning: true);
      return;
    }
    if (empId.isEmpty) {
      showSnackBar(title: '错误', message: '请输入被指派员工工号！', isWarning: true);
      return;
    }
    var partList = <String>[];
    for (var data in state.partList) {
      if (data.linkPartName?.isNotEmpty == true) {
        partList.addAll(data.linkPartName!);
      } else {
        partList.add(data.partName ?? '');
      }
    }
    partList = partList.toSet().toList();
    logger.f(PartDetailCreate(
      boxCapacity: boxCapacity,
      fID: state.partDetail?.fIDs ?? [],
      qty: qty,
      size: size,
      userID: userInfo?.userID ?? 0,
      partNames: partList,
      deptID: userInfo?.departmentID ?? 0,
      empID: empId,
    ).toJson());
    httpPost(
      method: webApiCreatePartLabel,
      loading: '正在创建条码...',
      body: PartDetailCreate(
        boxCapacity: boxCapacity,
        fID: state.partDetail?.fIDs ?? [],
        qty: qty,
        size: size,
        userID: userInfo?.userID ?? 0,
        partNames: partList,
        deptID: userInfo?.departmentID ?? 0,
        empID: empId,
      ),
    ).then((response) {
      if (response.resultCode == resultSuccess) {
        successDialog(
          content: response.message,
          back: () {
            state.partDetail =
                PartDetailInfo.fromJson(jsonDecode(response.data));
            state.partDetailSizeList.value = state.partDetail?.sizeList ?? [];
          },
        );
      } else {
        errorDialog(content: response.message);
      }
    });
  }

  deleteLabel(String barCode, Function() callback) {
    httpPost(
      method: webApiDeletePartLabel,
      loading: '正在删除贴标...',
      params: {
        'Barcode': barCode,
        'UserID': userInfo?.userID,
        'DeptID': userInfo?.departmentID,
      },
    ).then((response) {
      if (response.resultCode == resultSuccess) {
        var index = state.partDetail?.barCodeList
                ?.indexWhere((v) => v.barCode == barCode) ??
            0;
        state.partDetail?.barCodeList?.removeAt(index);
        callback.call();
      } else {
        errorDialog(content: response.message);
      }
    });
  }
}
