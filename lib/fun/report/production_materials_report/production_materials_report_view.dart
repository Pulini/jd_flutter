import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jd_flutter/route.dart';
import 'package:jd_flutter/utils.dart';

import '../../../bean/http/response/production_materials_info.dart';
import '../../../widget/custom_widget.dart';
import '../../../widget/picker/picker_view.dart';
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
    DataColumn(label: Text('销售订单号')),
    DataColumn(label: Text('生产订单编号')),
    DataColumn(label: Text('订单类型')),
    DataColumn(label: Text('产品编码')),
    DataColumn(label: Text('产品名称')),
    DataColumn(label: Text('订单交期')),
    DataColumn(label: Text('计划开工日期')),
    DataColumn(label: Text('计划完工日期')),
    DataColumn(label: Text('尺码')),
    DataColumn(label: Text('BOM号')),
    DataColumn(label: Text('BOM版本')),
    DataColumn(label: Text('单位')),
    DataColumn(label: Text('生产数量'), numeric: true),
    DataColumn(label: Text('已派工数量'), numeric: true),
    DataColumn(label: Text('部位')),
    DataColumn(label: Text('外发工序')),
    DataColumn(label: Text('子项物料编码')),
    DataColumn(label: Text('子项物料名称')),
    DataColumn(label: Text('规格型号')),
    DataColumn(label: Text('子项单位')),
    DataColumn(label: Text('子项尺码')),
    DataColumn(label: Text('物料需求日期')),
    DataColumn(label: Text('最新BOM需求数量'), numeric: true),
    DataColumn(label: Text('批次')),
    DataColumn(label: Text('需求数量'), numeric: true),
    DataColumn(label: Text('已领数量'), numeric: true),
    DataColumn(label: Text('未领数量'), numeric: true),
    DataColumn(label: Text('补单数量'), numeric: true),
  ];

  _tableDataRow(List<ProductionMaterialsInfo> list, int index) {
    return DataRow(
      color: MaterialStateProperty.resolveWith<Color?>(
        (Set<MaterialState> states) {
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
                      '需求数量：${demandQty.toShowString()}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 50),
                    Text(
                      '已领数量：${collectQty.toShowString()}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 50),
                    Text(
                      '未领数量：${uncollectedQty.toShowString()}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 50),
                    Text(
                      '补单数量：${orderQty.toShowString()}',
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
                            MaterialStateProperty.resolveWith<Color?>(
                          (Set<MaterialState> states) {
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
            title: getFunctionTitle(),
            children: [
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
                              child: Text('全部'),
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
                              child: Text('汇总'),
                            ),
                          ],
                        ),
                      ),
                    ],
                  )),
              EditText(hint: '指令', onChanged: (v) => state.etInstruction = v),
              EditText(
                  hint: '生产订单号', onChanged: (v) => state.etOrderNumber = v),
              EditText(
                  hint: '尺码生产订单号',
                  onChanged: (v) => state.etSizeOrderNumber = v),
              OptionsPicker(
                  pickerController: logic.pickerControllerSapProcessFlow),
              SwitchButton(
                name: '领料完成',
                value: state.isPickingMaterialCompleted.value,
                onChanged: (bool isSelect) =>
                    state.isPickingMaterialCompleted.value = isSelect,
              ),
            ],
            query: () => logic.query(),
            body: getPageBody(),
          )
        : pageBody(title: getFunctionTitle(), body: getPageBody());
  }

  @override
  void dispose() {
    Get.delete<ProductionMaterialsReportLogic>();
    super.dispose();
  }
}
