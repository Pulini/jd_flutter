import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jd_flutter/bean/http/response/show_process_plan_detail_info.dart';
import 'package:jd_flutter/fun/dispatching/injection_scan_report/injection_scan_report_logic.dart';
import 'package:jd_flutter/utils/click_debounce.dart';
import 'package:jd_flutter/utils/extension_util.dart';
import 'package:jd_flutter/widget/combination_button_widget.dart';
import 'package:jd_flutter/widget/custom_widget.dart';
import 'package:jd_flutter/widget/dialogs.dart';
import 'package:jd_flutter/widget/scanner.dart';

import 'injection_scan_report_label_view.dart';
import 'injection_scan_report_state.dart';

class InjectionScanReportPage extends StatefulWidget {
  const InjectionScanReportPage({super.key});

  @override
  State<InjectionScanReportPage> createState() =>
      _InjectionScanReportPageState();
}

class _InjectionScanReportPageState extends State<InjectionScanReportPage> {
  final logic = Get.put(InjectionScanReportLogic());
  final state = Get
      .find<InjectionScanReportLogic>()
      .state;
  final debouncer = ClickDebouncer();

  Widget _item1(ShowProcessPlanDetailInfo data) =>
      _InjectionScanReportItem1(data: data, logic: logic);



  Widget _title() => _InjectionScanReportTitle(state: state);

  @override
  Widget build(BuildContext context) {
    return pageBody(
        title: 'injection_scan_title'.tr,
        actions: [
          TextButton(
            //查询具体订单
            onPressed: () =>
                debouncer.run(() => logic.getScWorkCardDetail()),
            child: Text('injection_scan_query'.tr),
          ),
        ],
        body: Column(
          children: [
            _title(),
            Expanded(
              child: Obx(() =>
                  ListView.builder(
                    itemCount: state.showDataList.length,
                    itemBuilder: (context, index) =>
                        _item1(state.showDataList[index]),
                  )),
            ),
            Row(
              children: [
                Expanded(
                  flex: 1,
                  child: CombinationButton(
                    //切换订单，搜索机台全部订单
                    text: 'injection_scan_switch'.tr,
                    click: () => logic.getScWorkCardList(),
                    combination: Combination.left,
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: CombinationButton(
                    text: 'injection_scan_detail'.tr,
                    click: () {
                      if (state.showBarCodeList.isNotEmpty) {
                        Get.to(() => const InjectionScanReportLabelPage());
                      }
                    },
                    combination: Combination.middle,
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: CombinationButton(
                    //摄像头扫码
                    text: 'injection_scan_scan'.tr,
                    click: () {
                      Get.to(() => const Scanner())?.then((v) {
                        if (v != null) {
                          logic.findSizeData(v.toString());
                        }
                      });
                    },
                    combination: Combination.middle,
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: CombinationButton(
                    //清空
                    text: 'injection_scan_clean'.tr,
                    click: () {
                      askDialog(
                        content: 'injection_scan_sure_clean_box_and_label'.tr,
                        confirm: () =>
                            logic.clearBarCodeAndBoxQty(
                                success: (s) => logic.getScWorkCardList()),
                      );
                    },
                    combination: Combination.middle,
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: CombinationButton(
                    text: 'injection_scan_production_report'.tr,
                    click: () {
                      askDialog(
                        content: 'injection_scan_want_production_report'.tr,
                        confirm: () {
                          logic.productionReport(
                              success: (s) =>
                                  successDialog(
                                    //成功后刷新界面
                                    content: s,
                                    back: () =>
                                        logic.getScWorkCardDetail(),
                                  ));
                        },
                      );
                    },
                    combination: Combination.right,
                  ),
                )
              ],
            )
          ],
        ));
  }

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      logic.getScWorkCardList();
    });
    pdaScanner(scan: (code) {
      if (code.isNotEmpty) {
        logic.findSizeData(code);
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    Get.delete<InjectionScanReportLogic>();
    super.dispose();
  }
}

class _InjectionScanReportItem1 extends StatelessWidget {
  final ShowProcessPlanDetailInfo data;
  final InjectionScanReportLogic logic;

  const _InjectionScanReportItem1({
    required this.data,
    required this.logic,
  });

  @override
  Widget build(BuildContext context) {
    var backColors = Colors.white;
    var lastColor = Colors.white;
    if (data.size == '合计') {
      lastColor = Colors.blue.shade200;
      backColors = Colors.blue.shade200;
    } else {
      lastColor = Colors.greenAccent;
      backColors = Colors.white;
    }
    return InkWell(
      child: Row(
        children: [
          Expanded(
            child: _InjectionScanReportText(
                mes: data.size.toString(),
                backColor: backColors,
                head: false,
                paddingNumber: 8),
          ),
          Expanded(
            child: _InjectionScanReportText(
                mes: data.capacity.toShowString(),
                backColor: backColors,
                head: false,
                paddingNumber: 8),
          ),
          Expanded(
            child: _InjectionScanReportText(
                mes: data.box.toString().toDoubleTry().toShowString(),
                backColor: backColors,
                head: false,
                paddingNumber: 8),
          ),
          Expanded(
            child: _InjectionScanReportText(
                mes: data.lastMantissa.toShowString(),
                backColor: backColors,
                head: false,
                paddingNumber: 8),
          ),
          Expanded(
            child: _InjectionScanReportText(
                mes: data.mantissa.toShowString(),
                backColor: lastColor,
                head: false,
                paddingNumber: 8),
          ),
          Expanded(
            child: _InjectionScanReportText(
                mes: data.size == '合计'
                    ? data.allQty.toShowString()
                    : data.subtotal().toShowString(),
                backColor: backColors,
                head: false,
                paddingNumber: 8),
          )
        ],
      ),
      onTap: () {
        if (data.size != '合计') {
          if (logic.lastNum(data.size!, data.capacity!)) {
            showSnackBar(message: 'injection_scan_please_scan_last'.tr);
          } else {
            logic.showInputDialog(
                clickData: data,
                title: 'injection_scan_input_number'
                    .trArgs([data.size.toString()]),
                confirm: (s, data) {
                  logic.setSizeNumber(s, data);
                });
          }
        }
      },
    );
  }
}

class _InjectionScanReportText extends StatelessWidget {
  final String mes;
  final Color backColor;
  final bool head;
  final double paddingNumber;

  const _InjectionScanReportText({
    required this.mes,
    required this.backColor,
    required this.head,
    required this.paddingNumber,
  });

  @override
  Widget build(BuildContext context) {
    var textColor = head ? Colors.white : Colors.black;
    return Container(
      height: 35,
      decoration: BoxDecoration(
        color: backColor,
        border: Border.all(
          color: Colors.grey,
          width: 1.0,
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
}

class _InjectionScanReportTitle extends StatelessWidget {
  final InjectionScanReportState state;

  const _InjectionScanReportTitle({required this.state});

  @override
  Widget build(BuildContext context) {
    const radius = Radius.circular(5);
    const borders = BorderSide(color: Colors.grey, width: 1);
    return Column(
      children: [
        Container(
          width: double.maxFinite,
          decoration: BoxDecoration(
            border:
                const Border(top: borders, left: borders, right: borders),
            borderRadius: const BorderRadius.only(
                topLeft: radius, topRight: radius),
            gradient: LinearGradient(
              colors: [Colors.blue.shade300, Colors.blue.shade100],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: Obx(() => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(5.0),
                    child: Row(
                      children: [
                        expandedTextSpan(
                          flex: 1,
                          hint: 'injection_scan_machine'.tr,
                          text: state.machine.value,
                          textColor: Colors.yellow.shade200,
                        ),
                        expandedTextSpan(
                          flex: 2,
                          hint: 'injection_scan_dispatchNumber'.tr,
                          text: state.dispatchNumber.value,
                          textColor: Colors.yellow.shade200,
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding:
                        const EdgeInsets.only(left: 5, right: 5, bottom: 5),
                    child: Row(
                      children: [
                        expandedTextSpan(
                          hint: 'injection_scan_type_body'.tr,
                          text: state.factoryType.value,
                          textColor: Colors.yellow.shade200,
                        ),
                      ],
                    ),
                  ),
                  Row(
                    children: [
                      _buildHeaderText('injection_scan_size'.tr),
                      _buildHeaderText('injection_scan_box_capacity'.tr),
                      _buildHeaderText('injection_scan_number_of_boxes'.tr),
                      _buildHeaderText('injection_scan_last_work'.tr),
                      _buildHeaderText('injection_scan_on_duty'.tr),
                      _buildHeaderText(
                          'injection_scan_single_code_subtotal'.tr),
                    ],
                  )
                ],
              )),
        )
      ],
    );
  }

  Widget _buildHeaderText(String mes) =>
      _InjectionScanReportHeaderText(mes: mes);
}

class _InjectionScanReportHeaderText extends StatelessWidget {
  final String mes;

  const _InjectionScanReportHeaderText({required this.mes});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: _InjectionScanReportText(
        mes: mes,
        backColor: Colors.blueAccent,
        head: true,
        paddingNumber: 5,
      ),
    );
  }
}
