import 'package:get/get.dart';
import 'package:jd_flutter/bean/http/response/report_info.dart';
import 'package:jd_flutter/fun/warehouse/warehouse_allocation/warehouse_allocation_state.dart';
import 'package:jd_flutter/fun/warehouse/warehouse_allocation/warehouse_share_report_view.dart';
import 'package:jd_flutter/utils/utils.dart';
import 'package:jd_flutter/utils/web_api.dart';
import 'package:jd_flutter/widget/custom_widget.dart';
import 'package:jd_flutter/widget/dialogs.dart';


class WarehouseAllocationLogic extends GetxController {
  final WarehouseAllocationState state = WarehouseAllocationState();

  goReport({required String outStockId, required String onStockId}) {
    if (state.dataList.isNotEmpty) {
      if (outStockId == '' || onStockId == '') {
        showSnackBar(title: '警告', message: '请选择出/入仓库');
      } else {
        httpPost(
          method: webApiNewGetSubmitBarCodeReport,
          loading: '正在获取汇总信息...',
          body: {
            'BarCodeList': [
              for (var i = 0; i < (state.dataList).length; ++i)
                {
                  'BarCode': state.dataList[i].code,
                  'PalletNo': state.dataList[i].palletNumber,
                }
            ],
            'BillTypeID': '6',
            'Red': 1,
            'ProcessFlowID': 0,
            'OrganizeID': getUserInfo()!.organizeID,
            'DefaultStockID': getUserInfo()!.defaultStockID,
            'UserID': getUserInfo()!.userID,
          },
        ).then((response) {
          if (response.resultCode == resultSuccess) {
            state.outStockId = outStockId;
            state.onStockId = onStockId;
            state.reportDataList.value = [
              for (var i = 0; i < response.data.length; ++i)
                ReportInfo.fromJson(response.data[i])
            ];
            if (state.reportDataList.isNotEmpty) {
              Get.to(() => const WarehouseShareReportPage())?.then((v) {
                if (v == null) {
                  showSnackBar(title: '温馨提示', message: '检查未完成');
                }else if(v == true){
                  state.clearData();
                }
              });
            }
          } else {
            errorDialog(content: response.message);
          }
        });
      }
    } else {
      showSnackBar(title: '警告', message: '没有条码可提交');
    }
  }

  submit(
  ) {
    httpPost(
      method: webApiUploadWarehouseAllocation,
      loading: '正在提交...',
      body: {
        'BarCodeList': [
          for (var i = 0; i < (state.dataList).length; ++i)
            {
              'BarCode': state.dataList[i].code,
              'PalletNo': state.dataList[i].palletNumber,
            }
        ],
        'SCStockID': state.outStockId,
        'DCStockID': state.onStockId,
        'OrganizeID': getUserInfo()!.organizeID,
        'UserID': getUserInfo()!.userID,
      },
    ).then((response) {
      if (response.resultCode == resultSuccess) {
        successDialog(content: response.message, back: () => Get.back(result: true));
      } else {
        errorDialog(content: response.message);
      }
    });
  }
}
