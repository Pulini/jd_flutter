import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jd_flutter/bean/http/response/production_dispatch_order_info.dart';
import 'package:jd_flutter/fun/dispatching/production_dispatch/production_dispatch_logic.dart';
import 'package:jd_flutter/widget/custom_widget.dart';

class ProductionDispatchProgressPage extends StatefulWidget {
  const ProductionDispatchProgressPage({super.key});

  @override
  State<ProductionDispatchProgressPage> createState() =>
      _ProductionDispatchProgressPageState();
}

class _ProductionDispatchProgressPageState
    extends State<ProductionDispatchProgressPage> {
  final logic = Get.find<ProductionDispatchLogic>();
  final state = Get.find<ProductionDispatchLogic>().state;

  Widget _item(OrderProgressShowInfo data) {
    if (data.itemType == 1) {
      return Row(
        children: [
          expandedFrameText(
            backgroundColor: Colors.white,
            textColor: Colors.red,
            maxLines: 2,
            isBold: true,
            flex: 34,
            text: data.material,
          ),
          expandedFrameText(
            backgroundColor: Colors.white,
            textColor: Colors.red,
            maxLines: 2,
            isBold: true,
            flex: 16,
            text: data.factoryType,
          ),
          expandedFrameText(
            backgroundColor: Colors.white,
            textColor: Colors.red,
            maxLines: 2,
            isBold: true,
            flex: data.sizeMax * 6 + 2,
            text: data.factory,
          ),
        ],
      );
    } else if (data.itemType == 2) {
      return Row(
        children: [
          expandedFrameText(
            backgroundColor: Colors.blue.shade50,
            flex: 14,
            text: data.mtoNo,
          ),
          expandedFrameText(
            alignment: Alignment.center,
            backgroundColor: Colors.blue.shade50,
            flex: 6,
            text: data.unit,
          ),
          expandedFrameText(
            alignment: Alignment.center,
            backgroundColor: Colors.blue.shade50,
            flex: 8,
            text: data.qty,
          ),
          for (var size in data.sizeData)
            expandedFrameText(
              alignment: Alignment.center,
              backgroundColor: Colors.blue.shade50,
              flex: 6,
              text: size,
            ),
          expandedFrameText(
            alignment: Alignment.center,
            backgroundColor: Colors.blue.shade50,
            flex: 8,
            text: data.inStockQty,
          ),
          expandedFrameText(
            alignment: Alignment.center,
            backgroundColor: Colors.blue.shade50,
            flex: 8,
            text: data.reportedQty,
          ),
          expandedFrameText(
            alignment: Alignment.center,
            backgroundColor: Colors.blue.shade50,
            flex: 8,
            text: data.priority,
          ),
        ],
      );
    } else if (data.itemType == 3) {
      return Row(
        children: [
          expandedFrameText(
            backgroundColor: Colors.white,
            flex: 14,
            text: data.mtoNo,
          ),
          expandedFrameText(
            alignment: Alignment.center,
            backgroundColor: Colors.white,
            flex: 6,
            text: data.unit,
          ),
          expandedFrameText(
            alignment: Alignment.centerRight,
            backgroundColor: Colors.white,
            flex: 8,
            text: data.qty,
          ),
          for (var size in data.sizeData)
            expandedFrameText(
              alignment: Alignment.centerRight,
              backgroundColor: Colors.white,
              flex: 6,
              text: size,
            ),
          expandedFrameText(
            alignment: Alignment.centerRight,
            backgroundColor: Colors.white,
            flex: 8,
            text: data.inStockQty,
          ),
          expandedFrameText(
            alignment: Alignment.centerRight,
            backgroundColor: Colors.white,
            flex: 8,
            text: data.reportedQty,
          ),
          expandedFrameText(
            alignment: Alignment.center,
            backgroundColor: Colors.white,
            flex: 8,
            text: data.priority,
          ),
        ],
      );
    } else if (data.itemType == 4) {
      return Row(
        children: [
          expandedFrameText(
            backgroundColor: Colors.green.shade50,
            flex: 14,
            text: '',
          ),
          expandedFrameText(
            alignment: Alignment.center,
            backgroundColor: Colors.green.shade50,
            flex: 6,
            text: '合计',
          ),
          expandedFrameText(
            alignment: Alignment.centerRight,
            backgroundColor: Colors.green.shade50,
            flex: 8,
            text: data.qty,
          ),
          for (var size in data.sizeData)
            expandedFrameText(
              alignment: Alignment.centerRight,
              backgroundColor: Colors.green.shade50,
              flex: 6,
              text: size,
            ),
          expandedFrameText(
            backgroundColor: Colors.green.shade50,
            flex: 24,
            text: '',
          ),
        ],
      );
    } else {
      return Row(
        children: [
          expandedFrameText(
            backgroundColor: Colors.orange.shade50,
            flex: 14,
            text: '',
          ),
          expandedFrameText(
            alignment: Alignment.center,
            backgroundColor: Colors.orange.shade50,
            flex: 6,
            text: '预补1%',
          ),
          expandedFrameText(
            alignment: Alignment.centerRight,
            backgroundColor: Colors.orange.shade50,
            flex: 8,
            text: data.qty,
          ),
          for (var size in data.sizeData)
            expandedFrameText(
              alignment: Alignment.centerRight,
              backgroundColor: Colors.orange.shade50,
              flex: 6,
              text: size,
            ),
          expandedFrameText(
            backgroundColor: Colors.orange.shade50,
            flex: 24,
            text: '',
          ),
        ],
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return pageBody(
      title: '工单进度',
      body: Padding(
        padding: const EdgeInsets.only(left: 10, right: 10, bottom: 10),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: SizedBox(
            width: state.orderProgressTableWeight.value,
            child: ListView.builder(
              itemCount: state.orderProgressList.length,
              itemBuilder: (c, i) {
                return state.orderProgressList[i].preCompensation
                    ? Padding(
                        padding: const EdgeInsets.only(bottom: 35),
                        child: _item(state.orderProgressList[i]),
                      )
                    : _item(state.orderProgressList[i]);
              },
            ),
          ),
        ),
      ),
    );
  }
}
