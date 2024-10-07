import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jd_flutter/widget/custom_widget.dart';

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
  var controller = EasyRefreshController(controlFinishRefresh: true);

  @override
  Widget build(BuildContext context) {
    return pageBodyWithBottomSheet(
      bottomSheet: [
        DatePicker(pickerController: logic.pcStartDate),
        DatePicker(pickerController: logic.pcEndDate),
        OptionsPicker(pickerController: logic.pcGroup),
      ],
      query: () =>logic.queryOrder(),
      body: EasyRefresh(
        controller: controller,
        header: const MaterialHeader(),
        onRefresh: () => logic.refreshOrder(
          refresh: () => controller.finishRefresh(),
        ),
        onLoad: () => logic.loadMoreOrder(
          refresh: () => controller.finishLoad(),
        ),
        child: ListView.builder(
          padding: const EdgeInsets.all(8),
          itemCount: state.orderList.length,
          itemBuilder: (BuildContext context, int index) => Text(''),
        ),
      ),
    );
  }

  @override
  void dispose() {
    Get.delete<SmartDeliveryLogic>();
    super.dispose();
  }
}
