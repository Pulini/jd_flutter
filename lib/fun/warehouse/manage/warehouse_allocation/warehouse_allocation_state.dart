import 'package:get/get.dart';
import 'package:jd_flutter/bean/http/response/report_info.dart';
import 'package:jd_flutter/bean/http/response/scan_code.dart';
import 'package:jd_flutter/widget/custom_widget.dart';

class WarehouseAllocationState {

  var dataList  =  <ScanCode>[].obs;
  var reportDataList = <ReportInfo>[].obs;
  var outStockId ="";
  var onStockId ="";


  clearData(){
    dataList.clear();
  }

  //添加条码
  addCode( String code ) {
      if(code.isNotEmpty){ //如果条码不为空
          if(isExists(code)){
            showSnackBar(title: 'shack_bar_warm'.tr, message: 'warehouse_allocation_have_code'.tr);
          }else{
            dataList.add(ScanCode(code: code,palletNumber: ''));
          }
      }else{
        showSnackBar(title: 'shack_bar_warm'.tr, message: 'warehouse_allocation_input_code'.tr);
      }
  }

 bool isExists(String code ) {
    for (var v in dataList) {
      if(v.code == code){
        return true;
      }
    }
    return false;
  }

}
