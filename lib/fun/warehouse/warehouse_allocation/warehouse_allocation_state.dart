import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:jd_flutter/bean/http/response/report_info.dart';
import 'package:jd_flutter/utils/web_api.dart';
import 'package:jd_flutter/widget/custom_widget.dart';
import '../../../bean/http/response/scan_code.dart';
class WarehouseAllocationState {

  var code = "";
  var dataList  =  <ScanCode>[].obs;
  var reportDataList = <ReportInfo>[].obs;
  var outStockId ="";
  var onStockId ="";


  clearData(){
    dataList.clear();
  }

  ///添加条码
  addCode( String code ) {
      if(code.isNotEmpty){ //如果条码不为空
          if(isExists(code)){
            showSnackBar(title: '警告', message: '条码已存在');
          }else{
            dataList.add(ScanCode(code: code,palletNumber: ''));
          }
      }else{
        showSnackBar(title: '警告', message: '请输入条码');
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
