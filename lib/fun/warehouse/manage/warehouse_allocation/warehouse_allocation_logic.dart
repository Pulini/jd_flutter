import 'package:get/get.dart';
import 'package:jd_flutter/bean/http/response/bar_code.dart';
import 'package:jd_flutter/fun/warehouse/code_list_report/code_list_report_view.dart';
import 'package:jd_flutter/fun/warehouse/manage/warehouse_allocation/warehouse_allocation_state.dart';
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
        getWaitInStockBarCodeReport(
          barCodeList: [
            for (var item in state.dataList)
              BarCodeInfo(
                  code: item.code,
                  type: BarCodeReportType.warehouseAllocation.name)
                ..palletNo = item.palletNumber,
          ],
          type: BarCodeReportType.warehouseAllocation,
          reverse: true,
          success: (data){
            state.outStockId = outStockId;
            state.onStockId = onStockId;
            Get.to(() => const CodeListReportPage(),
                arguments: {'reportData': data})?.then((v) {
              if (v == null) {
                showSnackBar(title: '温馨提示', message: '检查未完成');
              } else if (v == true) {
                submit();
              }
            });
          },
          error: (msg)=>errorDialog(content: msg),
        );
      }
    } else {
      showSnackBar(title: '警告', message: '没有条码可提交');
    }
  }

  //删除条码
  deleteCode(int position) {
    state.dataList.removeAt(position);
  }

  //提交条码
  submit() {
    httpPost(
      method: webApiUploadWarehouseAllocation,
      loading: '正在提交调拨...',
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
        successDialog(content: response.message, back: () => state.clearData());
      } else {
        errorDialog(content: response.message);
      }
    });
  }
}
