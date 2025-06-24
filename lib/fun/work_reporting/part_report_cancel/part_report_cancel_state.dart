import 'package:get/get.dart';
import 'package:jd_flutter/bean/http/response/part_report_ticket_info.dart';

class PartReportCancelState {

  var ticketInfo = PartReportTicketInfo(); //工票信息

  var workTicket =''; //工票
  var factory =''.obs; //工厂型体
  var part =''.obs; //部件
  var processName =''.obs; //工序名
  var qty =''.obs; //数量
  var empID ='';  //员工
  var dataList = <TicketItem>[].obs; //展示数据

}