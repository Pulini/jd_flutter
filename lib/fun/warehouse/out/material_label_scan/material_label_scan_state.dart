import 'package:flutter/cupertino.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';
import 'package:jd_flutter/bean/http/response/material_label_scan_info.dart';
import 'package:jd_flutter/fun/warehouse/out/material_label_scan/material_label_scan_detail_view.dart';
import 'package:jd_flutter/utils/utils.dart';
import 'package:jd_flutter/utils/web_api.dart';
import 'package:jd_flutter/widget/custom_widget.dart';
import 'package:jd_flutter/widget/dialogs.dart';

class MaterialLabelScanState {
  var dataList = <MaterialLabelScanInfo>[].obs;
  var dataDetailList = <String, List<Items>>{}.obs;
  var dataDetail = MaterialLabelScanDetailInfo();
  var scanDetailList = <MaterialLabelScanBarCodeInfo>[].obs;
  var canScan = true; //是否能扫描

  var materialListNumber = ''; //备料单号
  var peopleNumber = TextEditingController(); //员工工号
  var peopleName = ''.obs; //员工姓名

  //备料任务清单
  void getQueryList({
    required String startDate,
    required String endDate,
    required Function(String) error,
  }) {
    httpGet(
      loading: 'material_label_scan_get_material_list'.tr,
      method: webApiGetPickMatList,
      params: {
        'NoticeDateStart': '2024-01-26',
        'NoticeDateEnd': '2025-12-26',
        'ProductName': '',
        'MaterialNumber': '',
      },
    ).then((response) {
      if (response.resultCode == resultSuccess) {
        var list = <MaterialLabelScanInfo>[
          for (var i = 0; i < response.data.length; ++i)
            MaterialLabelScanInfo.fromJson(response.data[i])
        ];

        dataList.value = list;
      } else {
        error.call(response.message ?? 'query_default_error'.tr);
      }
    });
  }

  //备料任务详情
  void getQueryDetail({
    required String workCardNo,
  }) {
    httpGet(
      loading: 'material_label_scan_get_material_detail'.tr,
      method: webApiGetPickMatDetail,
      params: {
        'WorkCardNo': workCardNo,
      },
    ).then((response) {
      if (response.resultCode == resultSuccess) {
        dataDetail = MaterialLabelScanDetailInfo.fromJson(response.data);
        // 按物料分组
        var groupedByMaterial = <String, List<Items>>{};
        for (var item in dataDetail.items!) {
          String materialKey = item.materialID.toString();
          if (!groupedByMaterial.containsKey(materialKey)) {
            groupedByMaterial[materialKey] = [];
          }
          groupedByMaterial[materialKey]?.add(item);
        }

        dataDetailList.value = groupedByMaterial;
        Get.to(() => const MaterialLabelScanDetailPage());
      } else {
        dataDetail = MaterialLabelScanDetailInfo();
        errorDialog(content: response.message ?? 'query_default_error'.tr);
      }
    });
  }

  //备料通过条码获取指令尺码数量信息
  void getQueryBarCodeDetail({
    required String barCode,
    required Function() success,
    required Function(String) error,
  }) {
    httpGet(
      loading: 'material_label_scan_detail_get_barcode_message'.tr,
      method: webApiPickGetBarCodeInfo,
      params: {
        'BarCode': barCode,
      },
    ).then((response) {
      if (response.resultCode == resultSuccess) {
        var list = <MaterialLabelScanBarCodeInfo>[
          for (var i = 0; i < response.data.length; ++i)
            MaterialLabelScanBarCodeInfo.fromJson(response.data[i])
        ];
        setScanDetail(
            lists: list,
            success: () {
              success.call();
            });
        canScan = true;
      } else {
        canScan = true;
        error.call(response.message ?? 'query_default_error'.tr);
      }
    });
  }

  //设置扫码信息
  void setScanDetail({
    required List<MaterialLabelScanBarCodeInfo> lists,
    required Function() success,
  }) {
    bool allFound = true;

    // 遍历每个扫码信息
    for (var scanItem in lists) {
      bool found = false;

      // 遍历所有物料分组
      for (var entry in dataDetailList.entries) {
        // 获取当前物料分组下的所有明细
        var materialList = entry.value;

        // 在当前物料分组中查找匹配的尺码
        for (var detailItem in materialList) {
          if (detailItem.size == scanItem.size &&
              detailItem.isScan == false &&
              detailItem.materialID == scanItem.materialID &&
              detailItem.srcICMOInterID == scanItem.srcICMOInterID) {
            // 更新数据
            detailItem.thisTime = scanItem.barCodeQty;
            detailItem.isScan = true;
            found = true;
            break; // 找到后退出内层循环
          }
        }

        // 如果在当前物料分组中未找到，继续下一个分组
        if (found) break;
      }

      // 如果整个数据中都未找到匹配项
      if (!found) {
        showSnackBar(message: '未找到匹配的物料信息');
        allFound = false;
      }
    }

    // 刷新数据状态
    dataDetailList.refresh();

    // 只有当所有扫码信息都处理完才调用成功回调
    if (allFound) {
      success.call();
    }
  }

  //备料提交领料
  void submitCodeDetail({
    required int receiverEmpID,
    required Function() success,
  }) {
    httpPost(
      loading: 'material_label_scan_detail_submit_message'.tr,
      method: webApiSubmitPickMatDetail,
      body: {
        'WorkCardInterID': '',
        'UserID': userInfo!.userID,
        'StockID': userInfo!.defaultStockID,
        'ReceiverEmpID': receiverEmpID, //手输
        'IssuerEmpID': userInfo!.empID,
        'pickMatDetailItems': [
          for (var entry in dataDetailList.entries)
            {
              // 获取当前物料分组下的所有明细
              for (var detailItem in entry.value)
                {
                  'SrcICMOInterID': detailItem.srcICMOInterID,
                  'MaterialID': detailItem.materialID,
                  'Size': detailItem.size,
                  'SubmitQty': detailItem.thisTime,
                }
            }
        ]
      },
    ).then((response) {
      if (response.resultCode == resultSuccess) {
      } else {
        errorDialog(content: response.message ?? 'query_default_error'.tr);
      }
    });
  }
}
