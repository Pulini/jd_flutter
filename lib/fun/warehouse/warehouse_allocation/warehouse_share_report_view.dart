import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jd_flutter/fun/warehouse/warehouse_allocation/warehouse_allocation_logic.dart';
import 'package:jd_flutter/fun/warehouse/warehouse_allocation/warehouse_allocation_state.dart';
import '../../../bean/http/response/report_info.dart';
import '../../../widget/custom_widget.dart';

class WarehouseShareReportPage extends StatefulWidget {
  const WarehouseShareReportPage({super.key});

  @override
  State<WarehouseShareReportPage> createState() =>
      _WarehouseShareReportPageState();
}

class _WarehouseShareReportPageState extends State<WarehouseShareReportPage> {
  final WarehouseAllocationLogic logic = Get.find<WarehouseAllocationLogic>();
  final WarehouseAllocationState state =
      Get.find<WarehouseAllocationLogic>().state;

  _item(List<DataList> data) {
    return Row(
      children: [
        for (var value in data)
          SizedBox(
            width: state.dp2Px(value.width!.toDouble(), context).toDouble(),
            child: DecoratedBox(
                decoration: const BoxDecoration(
                    border: Border(
                        left: BorderSide(width: 1, color: Colors.black),
                        right: BorderSide(width: 1, color: Colors.black))),
                child: Center(
                    child: Text(
                  value.content.toString(),
                  style: TextStyle(
                    color: Color(int.parse(
                        "0xFF${value.foreColor.toString().replaceAll("#", "")}")),
                  ),
                ))),
          )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return pageBody(
        title: '条码汇总表',
        body: Column(
          children: [
            Expanded(
              child: Obx(
                () => ListView.builder(
                  padding: const EdgeInsets.only(left: 5, right: 5),
                  itemCount: state.reportDataList.length,
                  itemBuilder: (context, index) => Container(
                    padding: const EdgeInsets.only(
                        left: 5, top: 3, right: 3, bottom: 3),
                    decoration: BoxDecoration(
                        color: Color(int.parse(
                            "0xFF${state.reportDataList[index].backgroundColor.toString().replaceAll("#", "")}")),
                        border: Border.all(color: Colors.blue, width: 1),
                        borderRadius: BorderRadius.circular(5)),
                    child: _item(state.reportDataList[index].dataList!),
                  ),
                ),
              ),
            ), Container(
              height: 40,
              width: double.maxFinite,
              margin: const EdgeInsets.all(5),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  padding: const EdgeInsets.only(left: 8, right: 8),
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                  ),
                ),
                onPressed: () {
                  logic.submit();
                },
                child: const Text('提 交',
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            )
          ],
        ));
  }
}
