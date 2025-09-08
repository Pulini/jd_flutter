import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jd_flutter/bean/http/response/smart_delivery_info.dart';
import 'package:jd_flutter/route.dart';
import 'package:jd_flutter/utils/extension_util.dart';
import 'package:jd_flutter/widget/custom_widget.dart';
import 'package:jd_flutter/widget/edit_text_widget.dart';
import 'package:jd_flutter/widget/picker/picker_controller.dart';
import 'package:jd_flutter/widget/picker/picker_view.dart';

import 'smart_delivery_logic.dart';

class SmartDeliveryPage extends StatefulWidget {
  const SmartDeliveryPage({super.key});

  @override
  State<SmartDeliveryPage> createState() => _SmartDeliveryPageState();
}

class _SmartDeliveryPageState extends State<SmartDeliveryPage> {
  final logic = Get.put(SmartDeliveryLogic());
  final state = Get.find<SmartDeliveryLogic>().state;

  TextEditingController insController = TextEditingController();

  //日期选择器的控制器
  var pcStartDate = DatePickerController(
    PickerType.startDate,
    saveKey: '${RouteConfig.smartDelivery.name}${PickerType.startDate}',
  );

  //日期选择器的控制器
  var pcEndDate = DatePickerController(
    PickerType.endDate,
    saveKey: '${RouteConfig.smartDelivery.name}${PickerType.endDate}',
  );

  //组别选择器的控制器
  var pcGroup = OptionsPickerController(
    PickerType.mesGroup,
    saveKey: '${RouteConfig.smartDelivery.name}${PickerType.mesGroup}',
  );
  var controller = EasyRefreshController(
    controlFinishRefresh: true,
    controlFinishLoad: true,
  );

  _item(SmartDeliveryOrderInfo data) {
    return GestureDetector(
      onTap: () => logic.getOrderMaterialList(
        data.workCardInterID ?? 0,
        data.typeBody ?? '',
        data.departmentId ?? 0,
      ),
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
                  hint: 'smart_delivery_sales_order'.tr,
                  text: data.salesOrderNo ?? '',
                  fontSize: 19,
                  textColor: Colors.blue.shade900,
                ),
                expandedTextSpan(
                  hint: 'smart_delivery_type_body'.tr,
                  text: data.typeBody ?? '',
                  fontSize: 19,
                  textColor: Colors.blue.shade900,
                ),
                expandedTextSpan(
                  hint: 'smart_delivery_customer_po'.tr,
                  text: data.customerPo ?? '',
                  fontSize: 19,
                  textColor: Colors.blue.shade900,
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                expandedTextSpan(
                  flex: 2,
                  hint: 'smart_delivery_dispatch_no'.tr,
                  text: '${data.workCardNo}(${data.dispatchDate})',
                  hintColor: Colors.grey,
                  textColor: Colors.grey,
                ),
                expandedTextSpan(
                  hint: 'smart_delivery_order_total_qty'.tr,
                  text: data.dispatchQty.toShowString(),
                  hintColor: Colors.grey,
                  textColor: Colors.grey,
                ),
                expandedTextSpan(
                  hint: 'smart_delivery_material_issuance_status'.tr,
                  text: data.materialIssuanceStatus == 0
                      ? 'smart_delivery_not_issuance'.tr
                      : 'smart_delivery_issued'.tr,
                  hintColor: Colors.grey,
                  textColor: data.materialIssuanceStatus == 0
                      ? Colors.grey
                      : Colors.green,
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
        EditText(
          hint: 'smart_delivery_input_instruction'.tr,
          controller: insController,
        ),
        DatePicker(pickerController: pcStartDate),
        DatePicker(pickerController: pcEndDate),
        OptionsPicker(pickerController: pcGroup),
      ],
      query: () => logic.refreshOrder(
        isQuery: true,
        instructions: insController.text,
        startDate: pcStartDate.getDateFormatYMD(),
        endDate: pcEndDate.getDateFormatYMD(),
        group: pcGroup.selectedId.value,
        refresh: () {},
      ),
      body: EasyRefresh(
        controller: controller,
        header: const MaterialHeader(),
        footer: ClassicFooter(noMoreText: 'smart_delivery_no_more_data'.tr),
        onRefresh: () => logic.refreshOrder(
          isQuery: false,
          instructions: insController.text,
          startDate: pcStartDate.getDateFormatYMD(),
          endDate: pcEndDate.getDateFormatYMD(),
          group: pcGroup.selectedId.value,
          refresh: () {
            controller.finishRefresh();
            controller.resetFooter();
          },
        ),
        onLoad: () => logic.loadMoreOrder(
          instructions: insController.text,
          startDate: pcStartDate.getDateFormatYMD(),
          endDate: pcEndDate.getDateFormatYMD(),
          group: pcGroup.selectedId.value,
          success: (noMore) => controller.finishLoad(
            noMore ? IndicatorResult.noMore : IndicatorResult.success,
          ),
          error: () => controller.finishLoad(IndicatorResult.fail),
        ),
        child: Obx(() => ListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: state.orderShowList.length,
              itemBuilder: (context, index) =>
                  _item(state.orderShowList[index]),
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
