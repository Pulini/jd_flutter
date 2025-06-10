import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jd_flutter/bean/http/response/forming_collection_info.dart';
import 'package:jd_flutter/fun/report/forming_barcode_collection/forming_barcode_collection_logic.dart';
import 'package:jd_flutter/fun/report/forming_barcode_collection/forming_barcode_collection_priority_view.dart';
import 'package:jd_flutter/utils/utils.dart';
import 'package:jd_flutter/widget/combination_button_widget.dart';
import 'package:jd_flutter/widget/custom_widget.dart';

class FormingBarcodeCollectionPage extends StatefulWidget {
  const FormingBarcodeCollectionPage({super.key});

  @override
  State<FormingBarcodeCollectionPage> createState() =>
      _FormingBarcodeCollectionPageState();
}

class _FormingBarcodeCollectionPageState
    extends State<FormingBarcodeCollectionPage> {
  final logic = Get.find<FormingBarcodeCollectionLogic>();
  final state = Get.find<FormingBarcodeCollectionLogic>().state;

  _item(ScWorkCardSizeInfos data) {
    return Row(
      children: [
        Expanded(
            child: _text(
                mes: data.size ?? '',
                backColor: Colors.blueAccent,
                head: false,
                paddingNumber: 5)),
        Expanded(
            child: _text(
                mes: data.qty.toShowString(),
                backColor: Colors.blueAccent,
                head: false,
                paddingNumber: 5)),
        Expanded(
            child: _text(
                mes: data.todayScannedQty.toShowString(),
                backColor: Colors.blueAccent,
                head: false,
                paddingNumber: 5)),
        Expanded(
            child: _text(
                mes: data.scannedQty.toShowString(),
                backColor: Colors.blueAccent,
                head: false,
                paddingNumber: 5)),
        Expanded(
            child: _text(
                mes: data.qty.sub(data.scannedQty ?? 0.0).toShowString(),
                backColor: Colors.blueAccent,
                head: false,
                paddingNumber: 5)),
        Expanded(
            child: _text(
                mes: data.getCompletionRate(),
                backColor: Colors.blueAccent,
                head: false,
                paddingNumber: 5)),
      ],
    );
  }

  _text({
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

  _tabPage1() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                  child: Obx(() => textSpan(
                      hint: 'forming_code_collection_factory'.tr,
                      text: state.factoryType.value))),
              Expanded(
                  child: Obx(() => textSpan(
                      hint: 'forming_code_collection_group'.tr,
                      text: state.group.value)))
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                  child: Obx(() => textSpan(
                      hint: 'forming_code_collection_order'.tr,
                      text: state.saleOrder.value))),
              Expanded(
                  child: Obx(() => textSpan(
                      hint: 'forming_code_collection_customer_order'.tr,
                      text: state.customerOrder.value)))
            ],
          ),
          Obx(() => textSpan(
              hint: 'forming_code_collection_code',
              text: state.scanCode.value)),
          Row(
            children: [
              Expanded(
                  child: _text(
                      mes: 'forming_code_collection_size'.tr,
                      backColor: Colors.blueAccent,
                      head: true,
                      paddingNumber: 5)),
              Expanded(
                  child: _text(
                      mes: 'forming_code_collection_instruction'.tr,
                      backColor: Colors.blueAccent,
                      head: true,
                      paddingNumber: 5)),
              Expanded(
                  child: _text(
                      mes: 'forming_code_collection_report'.tr,
                      backColor: Colors.blueAccent,
                      head: true,
                      paddingNumber: 5)),
              Expanded(
                  child: _text(
                      mes: 'forming_code_collection_cumulative'.tr,
                      backColor: Colors.blueAccent,
                      head: true,
                      paddingNumber: 5)),
              Expanded(
                  child: _text(
                      mes: 'forming_code_collection_owing_amount'.tr,
                      backColor: Colors.blueAccent,
                      head: true,
                      paddingNumber: 5)),
              Expanded(
                  child: _text(
                      mes: 'forming_code_collection_completion_rate'.tr,
                      backColor: Colors.blueAccent,
                      head: true,
                      paddingNumber: 5)),
            ],
          ),
          Expanded(
            child: Obx(
              () => ListView.builder(
                itemCount: state.showDataList.value.scWorkCardSizeInfos?.length,
                itemBuilder: (context, index) =>
                    _item(state.showDataList.value.scWorkCardSizeInfos![index]),
              ),
            ),
          ),
          Row(
            children: [
              CombinationButton(
                //切换订单
                text: 'forming_code_collection_switch'.tr,
                click: () => {},
                combination: Combination.middle,
              ),
              CombinationButton(
                //更改优先级
                text: 'forming_code_collection_change'.tr,
                click: () => {
                  Get.to(() => const FormingBarcodeCollectionPriorityPage())
                      ?.then((v) {
                    if (v == null) {
                    } else if (v == true) {}
                  })
                },
                combination: Combination.middle,
              ),
              CombinationButton(
                //其他功能
                text: 'forming_code_collection_other'.tr,
                click: () => {},
                combination: Combination.middle,
              )
            ],
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return pageBody(
      actions: [
        TextButton(
          onPressed: () =>
              logic.getProductionOrderST(first: '0', shoeBoxBillNo: ''),
          child: Text(
            'maintain_label_filter'.tr,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      ],
      title: 'forming_code_collection_title'.tr,
      body: Scaffold(
          backgroundColor: Colors.transparent,
          appBar: TabBar(
            controller: logic.tabController,
            dividerColor: Colors.blueAccent,
            indicatorColor: Colors.blueAccent,
            labelColor: Colors.blueAccent,
            unselectedLabelColor: Colors.grey,
            overlayColor: WidgetStateProperty.all(Colors.transparent),
            tabs: [
              Tab(text: 'forming_code_collection_scan'.tr),
              Tab(text: 'forming_code_collection_clear_tail'.tr),
            ],
          ),
          body: Column(
            children: [
              // Expanded(
              //   child: Obx(() => TabBarView(
              //         controller: logic.tabController,
              //         children: [_tabPage1(), _tabPage2()],
              //       )),
              // ),
            ],
          )),
    );
  }

  @override
  void initState() {
    logic.getProductionOrderST(first: '0', shoeBoxBillNo: '');
    super.initState();
  }
}
