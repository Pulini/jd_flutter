import 'package:get/get.dart';
import 'package:jd_flutter/bean/http/response/part_detail_info.dart';
import 'package:jd_flutter/bean/http/response/work_order_info.dart';
import 'package:jd_flutter/utils/utils.dart';
import 'package:jd_flutter/utils/web_api.dart';

class WorkOrderListState {

  var dataList = <WorkOrderInfo>[].obs;
  var isOutsourcing = spGet('${Get.currentRoute}/isClosed') ?? false;
  var isClosed = spGet('${Get.currentRoute}/isClosed') ?? false;
  var orderId = '';
  var partList = <PartInfo>[].obs;
  PartDetailInfo? partDetail;
  var partDetailSizeList = <SizeInfo>[].obs;


  query({
    required String pcStartDate,
    required String pcEndDate,
    required String workBarCode,
    required String planOrderNumber,
    required String pcGroup,
    required Function(String msg) error,
  }) {
    httpGet(
      method: webApiGetWorkCardOrderList,
      loading: 'work_order_list_getting_packing_list_box_capacity'.tr,
      params: {
        'StartTime': workBarCode.isEmpty ? pcStartDate : '',
        'EndTime': workBarCode.isEmpty ? pcEndDate : '',
        'DeptID': workBarCode.isEmpty ? pcGroup : '',
        'IsClose': workBarCode.isEmpty ? isClosed : false,
        'isOutsourcing': workBarCode.isEmpty ? isOutsourcing : false,
        'moNo': workBarCode.isEmpty ? planOrderNumber : '',
        'ProcessWorkBarCode': workBarCode,
      },
    ).then((response) {
      if (response.resultCode == resultSuccess) {
        dataList.value = [
          for (var json in response.data) WorkOrderInfo.fromJson(json)
        ];
      } else {
        error.call(response.message ?? '');
      }
    });
  }

  queryPartList({
    required Function(String msg) error,
  }) {
    httpGet(
      method: webApiGetPartList,
      loading: 'work_order_list_getting_part_list'.tr,
      params: {
        'WorkCardBarCode': orderId,
        'DeptID': userInfo?.departmentID,
      },
    ).then((response) {
      if (response.resultCode == resultSuccess) {
        partList.value = [
          for (var json in response.data) PartInfo.fromJson(json)
        ];
      } else {
        error.call(response.message ?? '');
      }
    });
  }

  queryPartDetail({
    required Function() success,
    required Function(String msg) error,
  }) {
    var list = <String>[];
    partList.where((v) => v.select).forEach((data) {
      if (data.linkPartName?.isEmpty == true) {
        list.add(data.partName ?? '');
      } else {
        list.addAll(data.linkPartName ?? []);
      }
    });
    httpPost(
      method: webApiGetPartDetail,
      loading: 'work_order_list_getting_part_detail'.tr,
      body: {
        'WorkCardBarCode': orderId,
        'PartNames': list.toSet().toList(),
        'DeptID': userInfo?.departmentID ?? 0,
      },
    ).then((response) {
      if (response.resultCode == resultSuccess) {
        partDetail = PartDetailInfo.fromJson(response.data);
        partDetailSizeList.value = partDetail?.sizeList ?? [];
      } else {
        error.call(response.message ?? '');
      }
    });
  }

  createPartLabel({
    required double boxCapacity,
    required double qty,
    required String size,
    required String empId,
    required Function(String msg) success,
    required Function(String msg) error,
  }) {
    var list = <String>[];
    for (var data in partList) {
      if (data.linkPartName?.isNotEmpty == true) {
        list.addAll(data.linkPartName!);
      } else {
        list.add(data.partName ?? '');
      }
    }
    httpPost(
      method: webApiCreatePartLabel,
      loading: 'work_order_list_creating_label'.tr,
      body: {
        'BoxCapacity': boxCapacity,
        'FID': partDetail?.fIDs ?? [],
        'Qty': qty,
        'Size': size,
        'UserID': userInfo?.userID,
        'PartNames': list.toSet().toList(),
        'DeptID': userInfo?.departmentID,
        'EmpID': empId,
      },
    ).then((response) {
      if (response.resultCode == resultSuccess) {
        partDetail = PartDetailInfo.fromJson(response.data);
        partDetailSizeList.value = partDetail?.sizeList ?? [];
        success.call(response.message ?? '');
      } else {
        error.call(response.message ?? '');
      }
    });
  }

  deleteLabel({
    required String barCode,
    required Function() success,
    required Function(String msg) error,
  }) {
    httpPost(
      method: webApiDeletePartLabel,
      loading: 'work_order_list_deleting_label'.tr,
      params: {
        'Barcode': barCode,
        'UserID': userInfo?.userID,
        'DeptID': userInfo?.departmentID,
      },
    ).then((response) {
      if (response.resultCode == resultSuccess) {
        partDetail?.barCodeList?.removeAt(
            partDetail?.barCodeList?.indexWhere((v) => v.barCode == barCode) ??
                0);
        success.call();
      } else {
        error.call(response.message ?? '');
      }
    });
  }
}
