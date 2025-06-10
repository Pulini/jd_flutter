import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:jd_flutter/bean/http/response/forming_collection_info.dart';
import 'package:jd_flutter/fun/report/forming_barcode_collection/forming_barcode_collection_logic.dart';
import 'package:jd_flutter/widget/custom_widget.dart';

class FormingBarcodeCollectionPriorityPage extends StatefulWidget {
  const FormingBarcodeCollectionPriorityPage({super.key});

  @override
  State<FormingBarcodeCollectionPriorityPage> createState() =>
      _FormingBarcodeCollectionPriorityPageState();
}

class _FormingBarcodeCollectionPriorityPageState
    extends State<FormingBarcodeCollectionPriorityPage> {
  final logic = Get.find<FormingBarcodeCollectionLogic>();
  final state = Get.find<FormingBarcodeCollectionLogic>().state;

  _item(FormingCollectionInfo data) {
    return GestureDetector(
      onTap: () {},
      child: Column(
        children: [],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return pageBody(
        body: Column(
      children: [
        Expanded(
          child: Obx(
            () => ListView.builder(
              itemCount: state.dataList.length,
              itemBuilder: (context, index) => _item(state.dataList[index]),
            ),
          ),
        ),
      ],
    ));
  }
}
