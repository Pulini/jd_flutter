import 'package:get/get.dart';
import 'package:jd_flutter/utils.dart';

import '../../../bean/http/response/part_detail_info.dart';
import '../../../bean/http/response/work_order_info.dart';
import '../../../web_api.dart';

class WorkOrderListState {
  var workBarCode = '';
  var planOrderNumber = '';
  var dataList = <WorkOrderInfo>[].obs;
  var isOutsourcing = spGet('${Get.currentRoute}/isClosed') ?? false;
  var isClosed = spGet('${Get.currentRoute}/isClosed') ?? false;
  var orderId = '';
  var partList = <PartInfo>[].obs;
  PartDetailInfo? partDetail;
  var partDetailSizeList = <SizeInfo>[].obs;

  WorkOrderListState() {
    ///Initialize variables
  }

  query({
    required String pcStartDate,
    required String pcEndDate,
    required String pcGroup,
    required Function(bool isNotEmpty) success,
    required Function(String msg) error,
  }) {
    httpGet(
      method: webApiGetWorkCardOrderList,
      loading: '正在获取包装清单箱容配置信息...',
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
        success.call(dataList.isNotEmpty);
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
      loading: '正在获取部件列表...',
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
      loading: '正在获取部件详情...',
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
      loading: '正在创建条码...',
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
      loading: '正在删除贴标...',
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
