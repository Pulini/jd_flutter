import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jd_flutter/bean/http/response/production_materials_info.dart';
import 'package:jd_flutter/utils/utils.dart';
import 'package:jd_flutter/widget/custom_widget.dart';
import 'package:jd_flutter/widget/edit_text_widget.dart';
import 'package:jd_flutter/widget/picker/picker_view.dart';
import 'package:jd_flutter/widget/switch_button_widget.dart';

import 'production_materials_report_logic.dart';

class ProductionMaterialsReportPage extends StatefulWidget {
  const ProductionMaterialsReportPage({super.key});

  @override
  State<ProductionMaterialsReportPage> createState() =>
      _ProductionMaterialsReportPageState();
}

class _ProductionMaterialsReportPageState
    extends State<ProductionMaterialsReportPage> {
  final logic = Get.put(ProductionMaterialsReportLogic());
  final state = Get.find<ProductionMaterialsReportLogic>().state;

  var tableColumns = [
    DataColumn(label: Text('production_materials_report_table_hint1'.tr)),
    DataColumn(label: Text('production_materials_report_table_hint2'.tr)),
    DataColumn(label: Text('production_materials_report_table_hint3'.tr)),
    DataColumn(label: Text('production_materials_report_table_hint4'.tr)),
    DataColumn(label: Text('production_materials_report_table_hint5'.tr)),
    DataColumn(label: Text('production_materials_report_table_hint6'.tr)),
    DataColumn(label: Text('production_materials_report_table_hint7'.tr)),
    DataColumn(label: Text('production_materials_report_table_hint8'.tr)),
    DataColumn(label: Text('production_materials_report_table_hint9'.tr)),
    DataColumn(label: Text('production_materials_report_table_hint10'.tr)),
    DataColumn(label: Text('production_materials_report_table_hint11'.tr)),
    DataColumn(label: Text('production_materials_report_table_hint12'.tr)),
    DataColumn(
      label: Text('production_materials_report_table_hint13'.tr),
      numeric: true,
    ),
    DataColumn(
        label: Text('production_materials_report_table_hint14'.tr),
        numeric: true),
    DataColumn(label: Text('production_materials_report_table_hint15'.tr)),
    DataColumn(label: Text('production_materials_report_table_hint16'.tr)),
    DataColumn(label: Text('production_materials_report_table_hint17'.tr)),
    DataColumn(label: Text('production_materials_report_table_hint18'.tr)),
    DataColumn(label: Text('production_materials_report_table_hint19'.tr)),
    DataColumn(label: Text('production_materials_report_table_hint20'.tr)),
    DataColumn(label: Text('production_materials_report_table_hint21'.tr)),
    DataColumn(label: Text('production_materials_report_table_hint22'.tr)),
    DataColumn(
      label: Text('production_materials_report_table_hint23'.tr),
      numeric: true,
    ),
    DataColumn(label: Text('production_materials_report_table_hint24'.tr)),
    DataColumn(
      label: Text('production_materials_report_table_hint25'.tr),
      numeric: true,
    ),
    DataColumn(
      label: Text('production_materials_report_table_hint26'.tr),
      numeric: true,
    ),
    DataColumn(
      label: Text('production_materials_report_table_hint27'.tr),
      numeric: true,
    ),
    DataColumn(
      label: Text('production_materials_report_table_hint28'.tr),
      numeric: true,
    ),
  ];

  _tableDataRow(List<ProductionMaterialsInfo> list, int index) {
    return DataRow(
      color: WidgetStateProperty.resolveWith<Color?>(
        (Set<WidgetState> states) {
          return index % 2 != 0 ? Colors.blue.shade200 : Colors.white;
        },
      ),
      onSelectChanged: (selected) {
        if (list[index].batch == '有') {
          logic.itemQuery(list[index]);
        }
      },
      cells: [
        DataCell(Text(list[index].salesOrderNumber ?? '')),
        DataCell(Text(list[index].productionOrderNumber ?? '')),
        DataCell(Text(list[index].orderType ?? '')),
        DataCell(Text(list[index].materialCode ?? '')),
        DataCell(Text(list[index].materialDescription ?? '')),
        DataCell(Text(list[index].orderDeliveryDate ?? '')),
        DataCell(Text(list[index].plannedStartTime ?? '')),
        DataCell(Text(list[index].plannedCompletionTime ?? '')),
        DataCell(Text(list[index].size ?? '')),
        DataCell(Text(list[index].bomNo ?? '')),
        DataCell(Text(list[index].bomVersion ?? '')),
        DataCell(Text(list[index].company ?? '')),
        DataCell(Text(list[index].productionNum.toDoubleTry().toShowString())),
        DataCell(Text(
            list[index].dispatchedWorkersNumber.toDoubleTry().toShowString())),
        DataCell(Text(list[index].position ?? '')),
        DataCell(Text(list[index].outsourcingProcess ?? '')),
        DataCell(Text(list[index].subItemMaterialCode ?? '')),
        DataCell(Text(list[index].subItemMaterialName ?? '')),
        DataCell(Text(list[index].specificationAndModel ?? '')),
        DataCell(Text(list[index].subUnits ?? '')),
        DataCell(Text(list[index].subItemSize ?? '')),
        DataCell(Text(list[index].materialRequirementDate ?? '')),
        DataCell(Text(
            list[index].latestBOMDemandQuantity.toDoubleTry().toShowString())),
        DataCell(Text(list[index].batch ?? '')),
        DataCell(Text(list[index].demandQuantity.toDoubleTry().toShowString())),
        DataCell(
            Text(list[index].deliveryQuantity.toDoubleTry().toShowString())),
        DataCell(Text(list[index].noPickQuantity.toDoubleTry().toShowString())),
        DataCell(Text(list[index]
            .supplementaryOrdersQuantity
            .toDoubleTry()
            .toShowString())),
      ],
    );
  }

  getPageBody() {
    return Obx(
      () => ListView.builder(
          padding: const EdgeInsets.all(5),
          itemCount: state.tableData.length,
          itemBuilder: (BuildContext context, int index) {
            var data = state.tableData[index];
            var demandQty = 0.0;
            var collectQty = 0.0;
            var uncollectedQty = 0.0;
            var orderQty = 0.0;
            for (var v in data) {
              demandQty = demandQty.add(v.demandQuantity.toDoubleTry());
              collectQty = collectQty.add(v.deliveryQuantity.toDoubleTry());
              uncollectedQty =
                  uncollectedQty.add(v.noPickQuantity.toDoubleTry());
              orderQty =
                  orderQty.add(v.supplementaryOrdersQuantity.toDoubleTry());
            }
            return Card(
              child: ExpansionTile(
                backgroundColor: Colors.white,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                ),
                title: Text(
                  '<${data[0].subItemMaterialCode}> ${data[0].subItemMaterialName}',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue.shade800,
                  ),
                ),
                subtitle: Row(
                  children: [
                    Text(
                      '${'production_materials_report_table_hint25'.tr}${demandQty.toShowString()}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 50),
                    Text(
                      '${'production_materials_report_table_hint26'.tr}${collectQty.toShowString()}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 50),
                    Text(
                      '${'production_materials_report_table_hint27'.tr}${uncollectedQty.toShowString()}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 50),
                    Text(
                      '${'production_materials_report_table_hint28'.tr}${orderQty.toShowString()}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                children: [
                  Padding(
                    padding:
                        const EdgeInsets.only(left: 10, right: 10, bottom: 20),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: DataTable(
                        showCheckboxColumn: false,
                        headingRowColor:
                            WidgetStateProperty.resolveWith<Color?>(
                          (Set<WidgetState> states) {
                            return Colors.blueAccent.shade100;
                          },
                        ),
                        columns: tableColumns,
                        rows: [
                          for (var i = 0; i < data.length; ++i)
                            _tableDataRow(data, i)
                        ],
                      ),
                    ),
                  )
                ],
              ),
            );
          }),
    );
  }

  _radioClick() {
    if (state.select.value == 1) {
      state.select.value = 0;
    } else {
      state.select.value = 1;
    }
  }

  @override
  void initState() {
    if (Get.arguments != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        logic.otherInQuery(Get.arguments['interID']);
      });
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Get.arguments == null
        ? pageBodyWithDrawer(
            queryWidgets: [
              Obx(() => Row(
                    children: [
                      Expanded(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Radio(
                              value: 0,
                              groupValue: state.select.value,
                              onChanged: (v) => state.select.value = v!,
                            ),
                            GestureDetector(
                              onTap: _radioClick,
                              child: Text(
                                'production_materials_report_query_hint1'.tr,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Radio(
                              value: 1,
                              groupValue: state.select.value,
                              onChanged: (v) => state.select.value = v!,
                            ),
                            GestureDetector(
                              onTap: _radioClick,
                              child: Text(
                                'production_materials_report_query_hint2'.tr,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  )),
              EditText(
                  hint: 'production_materials_report_query_hint3'.tr,
                  onChanged: (v) => state.etInstruction = v),
              EditText(
                  hint: 'production_materials_report_query_hint4'.tr,
                  onChanged: (v) => state.etOrderNumber = v),
              EditText(
                  hint: 'production_materials_report_query_hint5'.tr,
                  onChanged: (v) => state.etSizeOrderNumber = v),
              OptionsPicker(
                  pickerController: logic.pickerControllerSapProcessFlow),
              SwitchButton(
                name: 'production_materials_report_query_hint6'.tr,
                value: state.isPickingMaterialCompleted.value,
                onChanged: (bool isSelect) =>
                    state.isPickingMaterialCompleted.value = isSelect,
              ),
            ],
            query: () => logic.query(),
            body: getPageBody(),
          )
        : pageBody(body: getPageBody());
  }

  @override
  void dispose() {
    Get.delete<ProductionMaterialsReportLogic>();
    super.dispose();
  }
}
