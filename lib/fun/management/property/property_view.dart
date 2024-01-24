import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jd_flutter/http/response/property_info.dart';
import 'package:jd_flutter/route.dart';
import 'package:jd_flutter/utils.dart';

import '../../../widget/custom_widget.dart';
import '../../../widget/picker/picker_view.dart';
import 'property_logic.dart';

class PropertyPage extends StatefulWidget {
  const PropertyPage({super.key});

  @override
  State<PropertyPage> createState() => _PropertyPageState();
}

class _PropertyPageState extends State<PropertyPage> {
  final logic = Get.put(PropertyLogic());
  final state = Get.find<PropertyLogic>().state;

  _item(PropertyInfo data) {
    return GestureDetector(
      onTap: () {},
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(5),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(10),
                topRight: Radius.circular(10),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  flex: 1,
                  child: Text(
                    '${data.name}<${data.number}>',
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                if (data.visitedNum == 0)
                  Text(
                    'property_item_hint'.tr,
                    style: const TextStyle(
                      color: Colors.orange,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
              ],
            ),
          ),
          Container(
            height: 20,
            padding: const EdgeInsets.only(left: 5, right: 5),
            color: Colors.white,
            child: Row(
              children: [
                Text(
                  'property_item_hint1'.tr,
                  style: const TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Text(
                    data.sapCgOrderNo ?? '',
                    style: TextStyle(
                      color: Colors.blue[900],
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Checkbox(
                  value: data.isChecked,
                  onChanged: (checked) {
                    if (checked != null) {
                      data.isChecked = checked;
                      state.propertyList.refresh();
                    }
                  },
                )
              ],
            ),
          ),
          Container(
            height: 20,
            padding: const EdgeInsets.only(left: 5, right: 5),
            color: Colors.white,
            child: Row(
              children: [
                Text('property_item_hint2'.tr),
                Text(
                  data.custodianName ?? '',
                  style: const TextStyle(color: Colors.green),
                ),
              ],
            ),
          ),
          Container(
            height: 20,
            padding: const EdgeInsets.only(left: 5, right: 5),
            color: Colors.white,
            child: Row(
              children: [
                Text('property_item_hint3'.tr),
                Text(
                  data.address ?? '',
                  style: const TextStyle(color: Colors.green),
                ),
              ],
            ),
          ),
          Container(
            height: 20,
            padding: const EdgeInsets.only(left: 5, right: 5),
            color: Colors.white,
            child: Row(
              children: [
                Text('property_item_hint4'.tr),
                Text(data.buyDate ?? ''),
              ],
            ),
          ),
          Container(
            height: 20,
            padding: const EdgeInsets.only(left: 5, right: 5),
            color: Colors.white,
            child: Row(
              children: [
                Text('property_item_hint5'.tr),
                Text(data.writeDate ?? ''),
              ],
            ),
          ),
          Container(
            height: 25,
            padding: const EdgeInsets.only(bottom: 5, right: 5),
            margin: const EdgeInsets.only(bottom: 10),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(10),
                bottomRight: Radius.circular(10),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text('property_item_hint6'.tr),
                Text('${data.labelPrintQty}'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  listView(String status) {
    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount:
          state.propertyList.where((v) => v.processStatus == status).length,
      itemBuilder: (BuildContext context, int index) => _item(state.propertyList
          .where((v) => v.processStatus == status)
          .toList()[index]),
    );
  }

  @override
  Widget build(BuildContext context) {
    return pageBodyWithBottomSheet(
      title: getFunctionTitle(),
      bottomSheet: [
        EditText(
          hint: 'property_query_et_property_number'.tr,
          controller: logic.textControllerPropertyNumber,
        ),
        EditText(
          hint: 'property_query_et_property_name'.tr,
          controller: logic.textControllerPropertyName,
        ),
        EditText(
          hint: 'property_query_et_serial_number'.tr,
          controller: logic.textControllerSerialNumber,
        ),
        EditText(
          hint: 'property_query_et_invoice_number'.tr,
          controller: logic.textControllerInvoiceNumber,
        ),
        Row(
          children: [
            Expanded(
                flex: 1,
                child: EditText(
                  hint: 'property_query_et_name'.tr,
                  controller: logic.textControllerName,
                )),
            Expanded(
                flex: 1,
                child: EditText(
                  hint: 'property_query_et_worker_number'.tr,
                  controller: logic.textControllerWorkerNumber,
                )),
          ],
        ),
        DatePicker(pickerController: logic.pickerControllerStartDate),
        DatePicker(pickerController: logic.pickerControllerEndDate),
      ],
      query: () => logic.queryProperty(),
      body: Scaffold(
          backgroundColor: Colors.transparent,
          appBar: TabBar(
            controller: logic.tabController,
            dividerColor: Colors.blueAccent,
            indicatorColor: Colors.blueAccent,
            labelColor: Colors.blueAccent,
            unselectedLabelColor: Colors.grey,
            overlayColor: MaterialStateProperty.all(Colors.transparent),
            tabs: [
              Tab(text: 'property_tab_type_1'.tr),
              Tab(text: 'property_tab_type_2'.tr),
              Tab(text: 'property_tab_type_3'.tr)
            ],
          ),
          body: Column(
            children: [
              Expanded(
                child: Obx(() => TabBarView(
                      controller: logic.tabController,
                      children: [
                        listView("2"),
                        listView("0"),
                        listView("1"),
                      ],
                    )),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 10,right: 10,bottom: 15),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                    ),
                    onPressed: () => logic.printLabel(),
                    child: Text(
                      'property_bt_print'.tr,
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ),
            ],
          )),
    );
  }

  @override
  void dispose() {
    Get.delete<PropertyLogic>();
    super.dispose();
  }
}
