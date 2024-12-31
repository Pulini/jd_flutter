import 'package:get/get.dart';
import 'package:jd_flutter/widget/dialogs.dart';

import 'sap_produce_stock_in_state.dart';

class SapProduceStockInLogic extends GetxController {
  final SapProduceStockInState state = SapProduceStockInState();

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

  scanCode(String code) {
    try {
      var exists = state.barCodeList.firstWhere((v) => v.labelCode == code);
      var max=(exists.labelTotalQty??0)-(exists.labelReceivedQty??0);
      if(max-exists.scanQty>0){
        exists.scanQty+=1;
        state.barCodeList.refresh();
      }else{
        informationDialog(content: '条码 <$code}> 已扫描完成');
      }
    } catch (e) {
      state.getOrderInfoFromCode(
        labelCode: code,
        error: (msg) => errorDialog(content: msg),
      );
    }
  }
}
