import 'package:get/get.dart';
import 'package:jd_flutter/fun/warehouse/code_list_report/code_list_report_view.dart';
import 'package:jd_flutter/fun/warehouse/manage/warehouse_allocation/warehouse_allocation_state.dart';
import 'package:jd_flutter/utils/utils.dart';
import 'package:jd_flutter/utils/web_api.dart';
import 'package:jd_flutter/widget/custom_widget.dart';
import 'package:jd_flutter/widget/dialogs.dart';


class WarehouseAllocationLogic extends GetxController {
  final WarehouseAllocationState state = WarehouseAllocationState();

  void goReport({required String outStockId, required String onStockId}) {
    if (state.dataList.isNotEmpty) {
      if (outStockId == '' || onStockId == '') {
        showSnackBar(title: 'shack_bar_warm'.tr, message: 'warehouse_allocation_select_warehouse'.tr);
      } else {
        httpPost(
          method: webApiNewGetSubmitBarCodeReport,
          loading: 'warehouse_allocation_summary_information'.tr,
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
            'OrganizeID': userInfo?.organizeID,
            'DefaultStockID': userInfo?.defaultStockID,
            'UserID': userInfo?.userID,
          },
        ).then((response) {
          if (response.resultCode == resultSuccess) {
            state.outStockId = outStockId;
            state.onStockId = onStockId;
            Get.to(() => const CodeListReportPage(),arguments: {'reportData': response.data})?.then((v) {
              if (v == null) {
                showSnackBar(title: 'dialog_default_title_information'.tr, message: 'Inspection not completed'.tr);
              }else if(v == true){
                submit();
              }
            });
          } else {
            errorDialog(content: response.message);
          }
        });
      }
    } else {
      showSnackBar(title: 'shack_bar_warm'.tr, message: 'warehouse_allocation_not_barcode'.tr);
    }
  }

  //删除条码
  void deleteCode(int position){
    state.dataList.removeAt(position);
  }

  //提交条码
  void submit(
  ) {
    httpPost(
      method: webApiUploadWarehouseAllocation,
      loading: 'warehouse_allocation_submitting_transfer'.tr,
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
        'OrganizeID': userInfo?.organizeID,
        'UserID': userInfo?.userID,
      },
    ).then((response) {
      if (response.resultCode == resultSuccess) {
        successDialog(content: response.message, back: () =>    state.clearData());
      } else {
        errorDialog(content: response.message);
      }
    });
  }
}
