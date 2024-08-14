import 'package:get/get.dart';

import '../../../bean/http/response/visit_data_list_info.dart';

class VisitRegisterState {   //接口数据返回
  var dataList = <VisitDataListInfo>[].obs;
  var visitCode = "";
  var radioValue=0;
  var select = 0.obs;
}
