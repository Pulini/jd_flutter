import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jd_flutter/utils/utils.dart';
import 'package:jd_flutter/widget/custom_widget.dart';

import '../../../bean/http/response/smart_delivery_info.dart';
import '../../../widget/picker/picker_view.dart';
import 'smart_delivery_logic.dart';

class SmartDeliveryPage extends StatefulWidget {
  const SmartDeliveryPage({super.key});

  @override
  State<SmartDeliveryPage> createState() => _SmartDeliveryPageState();
}

class _SmartDeliveryPageState extends State<SmartDeliveryPage> {
  final logic = Get.put(SmartDeliveryLogic());
  final state = Get.find<SmartDeliveryLogic>().state;
  var controller = EasyRefreshController(
    controlFinishRefresh: true,
    controlFinishLoad: true,
  );

  _item(SmartDeliveryOrderInfo data) {
    return GestureDetector(
      onTap: () => logic.getOrderMaterialList(data.workCardInterID ?? 0,data.typeBody??''),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          children: [
            Row(
              children: [
                expandedTextSpan(
                  hint: '派工单号：',
                  text: data.workCardNo ?? '',
                  fontSize: 19,
                  textColor: Colors.blue.shade900,
                ),
                expandedTextSpan(
                  hint: '销售订单：',
                  text: data.salesOrderNo ?? '',
                  fontSize: 19,
                  textColor: Colors.blue.shade900,
                ),
                expandedTextSpan(
                  hint: '工厂型体：',
                  text: data.typeBody ?? '',
                  fontSize: 19,
                  textColor: Colors.blue.shade900,
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                expandedTextSpan(
                  hint: '派工日期：',
                  text: data.dispatchDate ?? '',
                  hintColor: Colors.grey,
                  textColor: Colors.grey,
                ),
                expandedTextSpan(
                  hint: '订单总量：',
                  text: data.dispatchQty.toShowString(),
                  hintColor: Colors.grey,
                  textColor: Colors.grey,
                ),
                expandedTextSpan(
                  hint: '发料情况：',
                  text: data.materialIssuanceStatus ?? '',
                  hintColor: Colors.grey,
                  textColor: Colors.grey,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return pageBodyWithBottomSheet(
      bottomSheet: [
        DatePicker(pickerController: logic.pcStartDate),
        DatePicker(pickerController: logic.pcEndDate),
        OptionsPicker(pickerController: logic.pcGroup),
      ],
      query: () => controller.callRefresh(),
      body: EasyRefresh(
        controller: controller,
        header: const MaterialHeader(),
        footer: const ClassicFooter(noMoreText: '没了没了，别拉了！'),
        onRefresh: () => logic.refreshOrder(refresh: () {
          controller.finishRefresh();
          controller.resetFooter();
        }),
        onLoad: () => logic.loadMoreOrder(
          success: (noMore) => controller.finishLoad(
            noMore ? IndicatorResult.noMore : IndicatorResult.success,
          ),
          error: () => controller.finishLoad(IndicatorResult.fail),
        ),
        child: Obx(() => ListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: state.orderList.length,
              itemBuilder: (context, index) => _item(state.orderList[index]),
            )),
      ),
    );
  }

  @override
  void dispose() {
    Get.delete<SmartDeliveryLogic>();
    super.dispose();
  }
}
