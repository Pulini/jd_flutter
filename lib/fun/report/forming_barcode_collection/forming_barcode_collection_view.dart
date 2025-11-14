import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jd_flutter/bean/http/response/forming_collection_info.dart';
import 'package:jd_flutter/fun/report/forming_barcode_collection/forming_barcode_collection_logic.dart';
import 'package:jd_flutter/fun/report/forming_barcode_collection/forming_barcode_collection_priority_view.dart';
import 'package:jd_flutter/fun/report/forming_barcode_collection/forming_barcode_collection_state.dart';
import 'package:jd_flutter/utils/extension_util.dart';
import 'package:jd_flutter/utils/utils.dart';
import 'package:jd_flutter/widget/combination_button_widget.dart';
import 'package:jd_flutter/widget/custom_widget.dart';
import 'package:jd_flutter/widget/dialogs.dart';
import 'package:jd_flutter/widget/scanner.dart';

import 'forming_barcode_collection_shoe_box_view.dart';
import 'forming_barcode_collection_switch_view.dart';

class FormingBarcodeCollectionPage extends StatefulWidget {
  const FormingBarcodeCollectionPage({super.key});

  @override
  State<FormingBarcodeCollectionPage> createState() =>
      _FormingBarcodeCollectionPageState();
}

class _FormingBarcodeCollectionPageState
    extends State<FormingBarcodeCollectionPage>    with SingleTickerProviderStateMixin{
  final FormingBarcodeCollectionLogic logic =
      Get.put(FormingBarcodeCollectionLogic());
  final FormingBarcodeCollectionState state =
      Get.find<FormingBarcodeCollectionLogic>().state;

  //tab控制器
  late TabController tabController = TabController(length: 2, vsync: this);



  // 其他功能
  void showOther() {
    Get.dialog(
      PopScope(
        //拦截返回键
        canPop: false,
        child: AlertDialog(
          title: Text('forming_code_collection_other_functions'.tr,
              style: const TextStyle(
                  color: Colors.black, fontWeight: FontWeight.bold)),
          content: SizedBox(
            height: 150,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                TextButton(
                    onPressed: () {
                      Get.back();
                      logic.getWorkLineReport(success: (mes) {
                        msgDialog(
                            title: 'forming_code_collection_analysis'.tr,
                            content: mes);
                      });
                    },
                    child: Text('forming_code_collection_analysis'.tr)),
                TextButton(
                    onPressed: () {
                      Get.back();
                      logic.getHistory();
                    },
                    child:
                        Text('forming_code_collection_historical_records'.tr)),
                TextButton(
                    onPressed: () {
                      Get.back();
                      Get.to(() => const FormingBarcodeCollectionShoeBoxPage())
                          ?.then((v) {
                        if (v != null) {
                            if(state.dataList.firstWhere((data)=> data.isShow==true).mtoNo == v){
                              logic.getProductionOrderST(first: '2', shoeBoxBillNo: v);
                            }
                        }
                        _scan();
                      });
                    },
                    child: Text('forming_code_collection_special'.tr))
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Get.back();
              },
              child: Text(
                'dialog_default_cancel'.tr,
                style: const TextStyle(color: Colors.grey),
              ),
            ),
          ],
        ),
      ),
      barrierDismissible: false, //拦截dialog外部点击
    );
  }

  _item(ScWorkCardSizeInfos data) {
    return Row(
      children: [
        Expanded(
            child: _text(
                mes: data.size ?? '',
                backColor:
                    data.size == '合计' ? Colors.yellowAccent : Colors.white,
                head: false,
                paddingNumber: 5)),
        Expanded(
            child: _text(
                mes: data.qty.toShowString(),
                backColor:
                    data.size == '合计' ? Colors.yellowAccent : Colors.white,
                head: false,
                paddingNumber: 5)),
        Expanded(
            child: _text(
                mes: data.todayScannedQty.toShowString(),
                backColor:
                    data.size == '合计' ? Colors.yellowAccent : Colors.white,
                head: false,
                paddingNumber: 5)),
        Expanded(
            child: _text(
                mes: data.scannedQty.toShowString(),
                backColor:
                    data.size == '合计' ? Colors.yellowAccent : Colors.white,
                head: false,
                paddingNumber: 5)),
        Expanded(
            child: _text(
                mes: data.qty.sub(data.scannedQty ?? 0.0).toShowString(),
                backColor: data.size == '合计'
                    ? Colors.yellowAccent
                    : Colors.red.shade200,
                head: false,
                paddingNumber: 5)),
        Expanded(
            child: _text(
                mes:
                    '${(data.scannedQty.div(data.qty ?? 1)).mul(100).toStringAsFixed(1)}%',
                backColor:
                    data.size == '合计' ? Colors.yellowAccent : Colors.white,
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
                  child: textSpan(
                      hint: 'forming_code_collection_group'.tr,
                      text: getUserInfo()!.departmentName ?? ''))
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
              hint: 'forming_code_collection_code'.tr,
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
                itemCount: state.showDataList.length,
                itemBuilder: (context, index) =>
                    _item(state.showDataList[index]),
              ),
            ),
          ),
          Row(
            children: [
              Expanded(
                  child: CombinationButton(
                //切换订单
                text: 'forming_code_collection_switch'.tr,
                click: () {
                  Get.to(() => const FormingBarcodeCollectionSwitchPage())
                      ?.then((v) {
                    if (v != null) {
                      logic.setFirstData(
                          first: '1', entryFid: v, shoeBoxBill: '');
                    }
                    _scan();
                  });
                },
                combination: Combination.left,
              )),
              Expanded(
                  child: CombinationButton(
                //更改优先级
                text: 'forming_code_collection_change'.tr,
                click: () {
                  Get.to(() => const FormingBarcodeCollectionPriorityPage())
                      ?.then((v) {
                    if (v == true) {
                      logic.getProductionOrderST(first: '0', shoeBoxBillNo: '');
                    }
                  });
                },
                combination: Combination.middle,
              )),
              Expanded(
                  child: CombinationButton(
                //其他功能
                text: 'forming_code_collection_other'.tr,
                click: () {
                  showOther();
                },
                combination: Combination.right,
              ))
            ],
          )
        ],
      ),
    );
  }

  _tabPage2() {
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
                      text: state.factoryTypeClear.value))),
              Expanded(
                  child: Obx(() => textSpan(
                      hint: 'forming_code_collection_order'.tr,
                      text: state.saleOrderClear.value)))
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                  child: Obx(() => textSpan(
                      hint: 'forming_code_collection_order_quantity'.tr,
                      text: state.orderNumClear.value))),
              Expanded(
                  child: Obx(() => textSpan(
                      hint: 'forming_code_collection_completion_quantity'.tr,
                      text: state.completionNumClear.value)))
            ],
          ),
          Obx(() => textSpan(
              hint: 'forming_code_collection_customer_order'.tr,
              text: state.customerOrderClear.value)),
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
                itemCount: state.showScanDataList.length,
                itemBuilder: (context, index) =>
                    _item(state.showScanDataList[index]),
              ),
            ),
          ),
          Row(
            children: [
              Expanded(
                  child: CombinationButton(
                //切换订单
                text: 'forming_code_collection_switch'.tr,
                click: ()  {
                  Get.to(() => const FormingBarcodeCollectionSwitchPage())
                      ?.then((v) {
                    if (v != null) {
                      logic.setShowScanData(v);
                    }
                    _scan();
                  });
                },
                combination: Combination.intact,
              )),
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
            'forming_code_collection_refresh'.tr,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      ],
      title: 'forming_code_collection_title'.tr,
      body: Scaffold(
          backgroundColor: Colors.transparent,
          appBar: TabBar(
            controller: tabController,
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
              Expanded(
                child: TabBarView(
                  controller: tabController,
                  children: [_tabPage1(), _tabPage2()],
                ),
              ),
            ],
          )),
    );
  }

  _scan() {
    pdaScanner(scan: (scanCode) {
      if (tabController.index == 0) {
        if (scanCode.isNotEmpty && state.canScan == true) {
          state.canScan = true;
          // 条码不为空，可以扫描
          logic.checkCode(
              code: scanCode,
              success: (scanCode, dataBean) {
                state.scanCode.value = scanCode;
                logic.submitCode(
                    bean: dataBean,
                    success: () {
                      showScanTips();
                      logic.setShowData(dataBean);
                    });
              });
        }
      }
    });
  }

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      logic.getProductionOrderST(first: '0', shoeBoxBillNo: '');
    });
    _scan();
    super.initState();
  }
}
