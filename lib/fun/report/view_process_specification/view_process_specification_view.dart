import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../route.dart';
import '../../../utils.dart';
import '../../../widget/custom_text.dart';
import 'view_process_specification_logic.dart';

class ViewProcessSpecificationPage extends StatefulWidget {
  const ViewProcessSpecificationPage({Key? key}) : super(key: key);

  @override
  State<ViewProcessSpecificationPage> createState() =>
      _ViewProcessSpecificationPageState();
}

class _ViewProcessSpecificationPageState
    extends State<ViewProcessSpecificationPage> {
  final logic = Get.put(ViewProcessSpecificationLogic());
  final state = Get.find<ViewProcessSpecificationLogic>().state;

  @override
  Widget build(BuildContext context) {
    // WebViewWidget(controller: logic.webViewController)
    return titleWithDrawer(
      title: getFunctionTitle(),
      children: [
        EditText(hint: '请输入型体', controller: logic.textControllerTypeBody),
      ],
      query: () => logic.queryProcessSpecification(),
      body: Text('data')
      // body: Obx(() => ListView.builder(
      //       padding: const EdgeInsets.all(8),
      //       itemCount: state.dataList.length,
      //       itemBuilder: (BuildContext context, int index) => ListTile(
      //         title: Text(
      //           '物料：${item.materialName}',
      //           style: const TextStyle(color: Colors.grey),
      //         ),
      //         subtitle: Text(
      //           '数量：${item.empFinishQty.toShowString()}',
      //           style: const TextStyle(color: Colors.grey),
      //         ),
      //       ),
      //     )),
    );
  }

  @override
  void dispose() {
    Get.delete<ViewProcessSpecificationLogic>();
    super.dispose();
  }
}
