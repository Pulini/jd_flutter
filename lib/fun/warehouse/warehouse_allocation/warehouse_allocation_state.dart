import 'package:get/get.dart';
import 'package:jd_flutter/widget/custom_widget.dart';
import '../../../bean/http/response/scan_code.dart';

class WarehouseAllocationState {
  var code = "";
  var dataList  =  <ScanCode>[].obs;

  addCode( String code ) {
      if(code.isNotEmpty){ //如果条码不为空
          if(isExists(code)){
            showSnackBar(title: '警告', message: '条码已存在');
          }else{
            dataList.add(ScanCode(code: code));
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
