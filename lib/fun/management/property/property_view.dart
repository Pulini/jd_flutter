import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jd_flutter/bean/http/response/property_info.dart';
import 'package:jd_flutter/widget/combination_button_widget.dart';
import 'package:jd_flutter/widget/custom_widget.dart';
import 'package:jd_flutter/widget/edit_text_widget.dart';
import 'package:jd_flutter/widget/picker/picker_view.dart';
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
      onTap: () => logic.getPropertyDetail(data.interID ?? -1),
      child: Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(5),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.all(Radius.circular(10)),
          ),
          child: Column(
            children: [
              Row(
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
              SizedBox(
                height: 20,
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
                        data.sapInvoiceNo ?? '',
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
              Row(
                children: [
                  Text('property_item_hint3'.tr),
                  Text(
                    data.address ?? '',
                    style: const TextStyle(color: Colors.green),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text('property_item_hint2'.tr),
                  Expanded(
                    flex: 1,
                    child: Text(
                      data.custodianName ?? '',
                      style: const TextStyle(color: Colors.green),
                    ),
                  ),
                  Text('property_item_hint4'.tr),
                  Text('${data.labelPrintQty}'),
                ],
              ),
            ],
          )),
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
      bottomSheet: [
        EditText(
          hint: 'property_query_et_property_number'.tr,
          onChanged: (v) => state.etPropertyNumber = v,
        ),
        EditText(
          hint: 'property_query_et_property_name'.tr,
          onChanged: (v) => state.etPropertyName = v,
        ),
        EditText(
          hint: 'property_query_et_serial_number'.tr,
          onChanged: (v) => state.etSerialNumber = v,
        ),
        EditText(
          hint: 'property_query_et_invoice_number'.tr,
          onChanged: (v) => state.etInvoiceNumber = v,
        ),
        Row(
          children: [
            Expanded(
                flex: 1,
                child: EditText(
                  hint: 'property_query_et_name'.tr,
                  onChanged: (v) => state.etName = v,
                )),
            Expanded(
                flex: 1,
                child: EditText(
                  hint: 'property_query_et_worker_number'.tr,
                  onChanged: (v) => state.etWorkerNumber = v,
                )),
          ],
        ),
        DatePicker(pickerController: logic.pickerControllerStartDate),
        DatePicker(pickerController: logic.pickerControllerEndDate),
      ],
      query:() => logic.queryProperty(),
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
                padding: const EdgeInsets.only(left: 2, right: 2, bottom: 15),
                child: CombinationButton(
                  text: 'property_bt_print'.tr,
                  click: () => logic.printLabel(),
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
