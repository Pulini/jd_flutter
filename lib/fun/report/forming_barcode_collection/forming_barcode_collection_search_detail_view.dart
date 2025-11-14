import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jd_flutter/bean/http/response/forming_mono_detail_info.dart';
import 'package:jd_flutter/widget/custom_widget.dart';

import 'forming_barcode_collection_logic.dart';

class FormingBarcodeCollectionSearchDetailPage extends StatefulWidget {
  const FormingBarcodeCollectionSearchDetailPage({super.key});

  @override
  State<FormingBarcodeCollectionSearchDetailPage> createState() =>
      _FormingBarcodeCollectionSearchDetailPageState();
}

class _FormingBarcodeCollectionSearchDetailPageState
    extends State<FormingBarcodeCollectionSearchDetailPage> {
  final logic = Get.find<FormingBarcodeCollectionLogic>();
  final state = Get.find<FormingBarcodeCollectionLogic>().state;

  var controller = TextEditingController();

  Container _text({
    required String mes,
    required Color backColor,
    required bool head,
    required double paddingNumber,
  }) {
    var textColor = Colors.white;
    if (head) {
      textColor = Colors.white;
    } else {
      textColor = Colors.black;
    }
    return Container(
      height: 35,
      decoration: BoxDecoration(
        color: backColor, // 背景颜色
        border: Border.all(
          color: Colors.grey, // 边框颜色
          width: 1.0, // 边框宽度
        ),
      ),
      child: Padding(
        padding: EdgeInsets.only(top: paddingNumber, bottom: paddingNumber),
        child: Center(
          child: Text(
            mes,
            style: TextStyle(color: textColor),
          ),
        ),
      ),
    );
  }
  Row _item(FormingMonoDetailInfo data){
    return Row(
      children: [
        Expanded(
            flex:2,
            child: _text(  //工厂型体
                mes: data.factoryType?? '',
                backColor: data.factoryType =='合计'? Colors.yellowAccent.shade100 :Colors.white,
                head: false,
                paddingNumber: 5)),
        Expanded(
            child: _text(  //尺码
                mes: data.size?? '',
                backColor: data.factoryType =='合计'? Colors.yellowAccent.shade100 :Colors.white,
                head: false,
                paddingNumber: 5)),
        Expanded(
            child: _text( //指令数
                mes: data.monoNum.toString(),
                backColor: data.factoryType =='合计'? Colors.yellowAccent.shade100 :Colors.white,
                head: false,
                paddingNumber: 5)),
        Expanded(
            child: _text( //汇报数
                mes: data.reportNum.toString(),
                backColor: data.factoryType =='合计'? Colors.yellowAccent.shade100 :Colors.white,
                head: false,
                paddingNumber: 5)),
        Expanded(
            child: _text( //累计数
                mes: data.totalNum.toString(),
                backColor: data.factoryType =='合计'? Colors.yellowAccent.shade100 :Colors.white,
                head: false,
                paddingNumber: 5)),
        Expanded(
            child: _text( //欠数
                mes: data.underNum.toString(),
                backColor: data.factoryType =='合计'? Colors.yellowAccent.shade100 :Colors.white,
                head: false,
                paddingNumber: 5)),
      ],
    );
  }

  Column _title() {
    const borders = BorderSide(color: Colors.grey, width: 1);
    return Column(
      children: [
        Container(
          width: double.maxFinite,
          decoration: BoxDecoration(
            border: const Border(top: borders, left: borders, right: borders),
            gradient: LinearGradient(
              colors: [Colors.blue.shade300, Colors.blue.shade100],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child:Row(
            children: [
              Expanded(
                  flex:2,
                  child: _text(  //工厂型体
                      mes: 'forming_code_collection_history_factory'.tr,
                      backColor: Colors.blueAccent,
                      head: true,
                      paddingNumber: 5)),
              Expanded(
                  child: _text(  //尺码
                      mes: 'forming_code_collection_size'.tr,
                      backColor: Colors.blueAccent,
                      head: true,
                      paddingNumber: 5)),
              Expanded(
                  child: _text( //指令数
                      mes: 'forming_code_collection_instruction'.tr,
                      backColor: Colors.blueAccent,
                      head: true,
                      paddingNumber: 5)),
              Expanded(
                  child: _text( //汇报数
                      mes: 'forming_code_collection_report'.tr,
                      backColor: Colors.blueAccent,
                      head: true,
                      paddingNumber: 5)),
              Expanded(
                  child: _text( //累计数
                      mes: 'forming_code_collection_cumulative'.tr,
                      backColor: Colors.blueAccent,
                      head: true,
                      paddingNumber: 5)),
              Expanded(
                  child: _text( //欠数
                      mes: 'forming_code_collection_owing_amount'.tr,
                      backColor: Colors.blueAccent,
                      head: true,
                      paddingNumber: 5)),
            ],
          ),
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return pageBody(
      title: 'forming_code_collection_instruction_details'.tr,
        body: Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 5), // 左右 5 像素
          child:   CupertinoSearchTextField( //指令单号
            controller: controller,
            prefixIcon: const SizedBox.shrink(),
            suffixIcon:const Icon(CupertinoIcons.search),
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(20),
            ),
            onSuffixTap:(){
              logic.getMoNoReport(commandNumber: controller.text, goPage: false);
            },
            placeholder: 'process_dispatch_work_ticket'.tr,
          ),
        ),

        _title(),
        Expanded(
          child: Obx(
            () => ListView.builder(
              itemCount: state.searchDetail.length,
              itemBuilder: (context, index) =>
                  _item(state.searchDetail[index]),
            ),
          ),
        ),
      ],
    ));
  }
}
