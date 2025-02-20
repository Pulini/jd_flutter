import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:jd_flutter/bean/http/response/report_info.dart';
import 'package:jd_flutter/bean/http/response/scan_code.dart';
import 'package:jd_flutter/widget/custom_widget.dart';

class WarehouseAllocationState {
  var code = "";
  var dataList  =  <ScanCode>[].obs;
  var reportDataList = <ReportInfo>[].obs;
  var outStockId ="";
  var onStockId ="";



  //dp转换成px
  int dp2Px(double dp, BuildContext context) {

    MediaQueryData mq = MediaQuery.of(context);
    // 屏幕密度
    double pixelRatio = mq.devicePixelRatio;

      return (dp * pixelRatio + 1).toInt();
  }

  clearData(){
    dataList.clear();
  }


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
