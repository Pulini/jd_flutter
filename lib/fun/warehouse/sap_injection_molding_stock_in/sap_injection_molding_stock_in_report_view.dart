import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jd_flutter/bean/http/response/sap_injection_molding_stock_in_info.dart';
import 'package:jd_flutter/fun/warehouse/sap_injection_molding_stock_in/sap_injection_molding_stock_in_logic.dart';
import 'package:jd_flutter/fun/warehouse/sap_injection_molding_stock_in/sap_injection_molding_stock_in_state.dart';
import 'package:jd_flutter/widget/custom_widget.dart';

import '../sap_no_label_stock_in/sap_no_label_stock_in_dialog.dart';

class SapInjectionMoldingStockInReportPage extends StatefulWidget {
  const SapInjectionMoldingStockInReportPage({super.key});

  @override
  State<SapInjectionMoldingStockInReportPage> createState() =>
      _SapInjectionMoldingStockInReportPageState();
}

class _SapInjectionMoldingStockInReportPageState
    extends State<SapInjectionMoldingStockInReportPage> {
  final SapInjectionMoldingStockInLogic logic =
      Get.find<SapInjectionMoldingStockInLogic>();
  final SapInjectionMoldingStockInState state =
      Get.find<SapInjectionMoldingStockInLogic>().state;

  _item(List<SapInjectionMoldingStockInInfo> i) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: SizedBox(
          //列标题占比2、合计占比1
          width: 8 * 50,
          child: ListView(
            padding: const EdgeInsets.only(top: 10, bottom: 10),
            children: [
              Row(
                children: [
                  expandedFrameText(
                    flex: 2,
                    text: '派工单号',
                    backgroundColor: Colors.blueAccent,
                    textColor: Colors.white,
                    borderColor: Colors.black,
                    alignment: Alignment.center,
                  ),
                  expandedFrameText(
                    text: '型体',
                    backgroundColor: Colors.blueAccent,
                    textColor: Colors.white,
                    borderColor: Colors.black,
                    alignment: Alignment.center,
                  ),
                  expandedFrameText(
                    text: '尺码',
                    backgroundColor: Colors.blueAccent,
                    textColor: Colors.white,
                    borderColor: Colors.black,
                    alignment: Alignment.center,
                  ),
                  expandedFrameText(
                    text: '单位',
                    backgroundColor: Colors.blueAccent,
                    textColor: Colors.white,
                    borderColor: Colors.black,
                    alignment: Alignment.center,
                  ),
                  expandedFrameText(
                    text: '待入库数',
                    backgroundColor: Colors.blueAccent,
                    textColor: Colors.white,
                    borderColor: Colors.black,
                    alignment: Alignment.center,
                  ),
                  expandedFrameText(
                    text: '已入库数',
                    backgroundColor: Colors.blueAccent,
                    textColor: Colors.white,
                    borderColor: Colors.black,
                    alignment: Alignment.center,
                  ),
                  expandedFrameText(
                    text: '报工数',
                    backgroundColor: Colors.blueAccent,
                    textColor: Colors.white,
                    borderColor: Colors.black,
                    alignment: Alignment.center,
                  ),
                ],
              ),
              for (var data in state.reportList)
                Row(
                  children: [
                    expandedFrameText(
                      flex: 2,
                      text: data[0].dispatchNumber ?? '',
                      backgroundColor: Colors.white,
                      borderColor: Colors.black,
                      alignment: Alignment.center,
                    ),
                  ],
                )
            ],
          )),
    );
  }

  @override
  Widget build(BuildContext context) {
    return pageBody(
      title: '入库汇总',
      actions: [
        TextButton(
            onPressed: () => checkStockInHandoverDialog(
                  handoverCheck: (ln, ls, un, us, d) => logic.submitStockIn(
                    leaderNumber: ln,
                    leaderSignature: ls,
                    userNumber: un,
                    userSignature: us,
                    postingDate: d,
                  ),
                ),
            child: Text('确认入库'))
      ],
      body: SingleChildScrollView(
        child: ListView(
          children: [
            for (var i in state.reportList) _item(i),
          ],
        ),
      ),
    );
  }
}
