import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jd_flutter/bean/http/response/sap_injection_molding_stock_in_info.dart';
import 'package:jd_flutter/fun/warehouse/in/sap_injection_molding_stock_in/sap_injection_molding_stock_in_logic.dart';
import 'package:jd_flutter/fun/warehouse/in/sap_injection_molding_stock_in/sap_injection_molding_stock_in_state.dart';
import 'package:jd_flutter/fun/warehouse/in/sap_no_label_stock_in/sap_no_label_stock_in_dialog.dart';
import 'package:jd_flutter/utils/extension_util.dart';
import 'package:jd_flutter/widget/combination_button_widget.dart';
import 'package:jd_flutter/widget/custom_widget.dart';

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

  Widget listTitle() => const _StockInReportTitle();

  Widget listItem(List<SapInjectionMoldingStockInInfo> list) =>
      _StockInReportItem(list: list);

  Widget listTotal() => _StockInReportTotal(state: state);

  @override
  Widget build(BuildContext context) {
    return pageBody(
        title: 'sap_injection_molding_stock_in_report_stock_in_summary'.tr,
        actions: [
          CombinationButton(
            text: 'sap_injection_molding_stock_in_report_confirm_stock_in'.tr,
            click: () => checkStockInHandoverDialog(
              handoverCheck: (ln, ls, un, us, d) => logic.submitStockIn(
                leaderNumber: ln,
                leaderSignature: ls,
                userNumber: un,
                userSignature: us,
                postingDate: d,
              ),
            ),
          )
        ],
        body: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: SizedBox(
            width: 7 * 100,
            child: ListView(
              children: [
                listTitle(),
                for (var list in state.reportList) listItem(list),
                listTotal(),
              ],
            ),
          ),
        ));
  }
}

class _StockInReportTitle extends StatelessWidget {
  const _StockInReportTitle();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        ExpandedFrameText(
          flex: 3,
          text: 'sap_injection_molding_stock_in_report_dispatch_no'.tr,
          backgroundColor: Colors.blueAccent,
          textColor: Colors.white,
          borderColor: Colors.black,
          alignment: Alignment.center,
        ),
        ExpandedFrameText(
          flex: 3,
          text: 'sap_injection_molding_stock_in_report_type_body'.tr,
          backgroundColor: Colors.blueAccent,
          textColor: Colors.white,
          borderColor: Colors.black,
          alignment: Alignment.center,
        ),
        ExpandedFrameText(
          text: 'sap_injection_molding_stock_in_report_size'.tr,
          backgroundColor: Colors.blueAccent,
          textColor: Colors.white,
          borderColor: Colors.black,
          alignment: Alignment.center,
        ),
        ExpandedFrameText(
          text: 'sap_injection_molding_stock_in_report_unit'.tr,
          backgroundColor: Colors.blueAccent,
          textColor: Colors.white,
          borderColor: Colors.black,
          alignment: Alignment.center,
        ),
        ExpandedFrameText(
          flex: 2,
          text: 'sap_injection_molding_stock_in_report_not_stocked_qty'.tr,
          backgroundColor: Colors.blueAccent,
          textColor: Colors.white,
          borderColor: Colors.black,
          alignment: Alignment.center,
        ),
        ExpandedFrameText(
          flex: 2,
          text: 'sap_injection_molding_stock_in_report_stocked_qty'.tr,
          backgroundColor: Colors.blueAccent,
          textColor: Colors.white,
          borderColor: Colors.black,
          alignment: Alignment.center,
        ),
        ExpandedFrameText(
          flex: 2,
          text: 'sap_injection_molding_stock_in_report_report_qty'.tr,
          backgroundColor: Colors.blueAccent,
          textColor: Colors.white,
          borderColor: Colors.black,
          alignment: Alignment.center,
        ),
      ],
    );
  }
}

class _StockInReportItem extends StatelessWidget {
  final List<SapInjectionMoldingStockInInfo> list;
  late final String _totalDispatchQtyText;
  _StockInReportItem({required this.list}) {
    _totalDispatchQtyText = list
        .map((v) => v.dispatchQty ?? 0)
        .reduce((a, b) => a.add(b))
        .toShowString();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        ExpandedFrameText(
          flex: 3,
          text: list.first.dispatchNumber ?? '',
          backgroundColor: Colors.white,
          textColor: Colors.black,
          borderColor: Colors.black,
          alignment: Alignment.center,
        ),
        ExpandedFrameText(
          flex: 3,
          text: list.first.typeBody ?? '',
          backgroundColor: Colors.white,
          textColor: Colors.black,
          borderColor: Colors.black,
          alignment: Alignment.center,
        ),
        ExpandedFrameText(
          text: list.first.size ?? '',
          backgroundColor: Colors.white,
          textColor: Colors.black,
          borderColor: Colors.black,
          alignment: Alignment.center,
        ),
        ExpandedFrameText(
          text: list.first.basicUnit ?? '',
          backgroundColor: Colors.white,
          textColor: Colors.black,
          borderColor: Colors.black,
          alignment: Alignment.center,
        ),
        ExpandedFrameText(
          flex: 2,
          text: _totalDispatchQtyText,
          backgroundColor: Colors.white,
          textColor: Colors.black,
          borderColor: Colors.black,
          alignment: Alignment.center,
        ),
        ExpandedFrameText(
          flex: 2,
          text: list.first.receivedQty.toShowString(),
          backgroundColor: Colors.white,
          textColor: Colors.black,
          borderColor: Colors.black,
          alignment: Alignment.center,
        ),
        ExpandedFrameText(
          flex: 2,
          text: list.first.reportQty.toShowString(),
          backgroundColor: Colors.white,
          textColor: Colors.black,
          borderColor: Colors.black,
          alignment: Alignment.center,
        ),
      ],
    );
  }
}

class _StockInReportTotal extends StatelessWidget {
  final SapInjectionMoldingStockInState state;
  late final String _totalDispatchQtyText;
  late final String _totalReceivedQtyText;
  late final String _totalReportQtyText;
  _StockInReportTotal({required this.state}) {
    _totalDispatchQtyText = state.reportList
        .map((v) => v
            .map((v2) => v2.dispatchQty ?? 0)
            .reduce((a, b) => a.add(b)))
        .reduce((a, b) => a.add(b))
        .toShowString();
    _totalReceivedQtyText = state.reportList
        .map((v) => v.first.receivedQty ?? 0)
        .reduce((a, b) => a.add(b))
        .toShowString();
    _totalReportQtyText = state.reportList
        .map((v) => v.first.reportQty ?? 0)
        .reduce((a, b) => a.add(b))
        .toShowString();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        ExpandedFrameText(
          flex: 3,
          text: 'sap_injection_molding_stock_in_report_total'.tr,
          backgroundColor: Colors.white,
          textColor: Colors.black,
          borderColor: Colors.black,
          alignment: Alignment.center,
        ),
        Expanded(
          flex: 5,
          child: Container(
            height: 35,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.black),
              color: Colors.white,
            ),
          ),
        ),
        ExpandedFrameText(
          flex: 2,
          text: _totalDispatchQtyText,
          backgroundColor: Colors.white,
          textColor: Colors.black,
          borderColor: Colors.black,
          alignment: Alignment.center,
        ),
        ExpandedFrameText(
          flex: 2,
          text: _totalReceivedQtyText,
          backgroundColor: Colors.white,
          textColor: Colors.black,
          borderColor: Colors.black,
          alignment: Alignment.center,
        ),
        ExpandedFrameText(
          flex: 2,
          text: _totalReportQtyText,
          backgroundColor: Colors.white,
          textColor: Colors.black,
          borderColor: Colors.black,
          alignment: Alignment.center,
        )
      ],
    );
  }
}
