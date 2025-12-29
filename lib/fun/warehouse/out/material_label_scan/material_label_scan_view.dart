import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jd_flutter/bean/http/response/material_label_scan_info.dart';
import 'package:jd_flutter/route.dart';
import 'package:jd_flutter/widget/custom_widget.dart';
import 'package:jd_flutter/widget/edit_text_widget.dart';
import 'package:jd_flutter/widget/picker/picker_controller.dart';
import 'package:jd_flutter/widget/picker/picker_view.dart';

import 'material_label_scan_logic.dart';

class MaterialLabelScanPage extends StatefulWidget {
  const MaterialLabelScanPage({super.key});

  @override
  State<MaterialLabelScanPage> createState() => _MaterialLabelScanPageState();
}

class _MaterialLabelScanPageState extends State<MaterialLabelScanPage> {
  final logic = Get.put(MaterialLabelScanLogic());
  final state = Get.find<MaterialLabelScanLogic>().state;

  var hintStyle = const TextStyle(color: Colors.black);
  var textStyle = TextStyle(color: Colors.blue.shade900);

  //日期选择器的控制器
  var startDate = DatePickerController(
    buttonName: 'material_label_scan_start_time'.tr,
    PickerType.startDate,
    saveKey: '${RouteConfig.materialLabelScan.name}${PickerType.startDate}',
  );

  //日期选择器的控制器
  var endDate = DatePickerController(
    buttonName: 'material_label_scan_end_time'.tr,
    PickerType.startDate,
    saveKey: '${RouteConfig.materialLabelScan.name}${PickerType.startDate}',
  );

  //工厂仓库
  var factoryWarehouse = LinkOptionsPickerController(
    hasAll: false,
    PickerType.sapFactoryWarehouse,
    saveKey:
        '${RouteConfig.materialLabelScan.name}${PickerType.sapFactoryWarehouse}',
    buttonName: 'material_label_scan_factory'.tr,
  );

  var controller = TextEditingController(); //工票
  var materialNumber = TextEditingController(); //物料代码

  Row _text(String hint, String? text1) {
    return Row(
      children: [
        Container(
          width: 90,
          margin: const EdgeInsets.only(right: 10),
          alignment: Alignment.centerRight,
          child: Text(hint, style: hintStyle),
        ),
        Expanded(
          child: Text(text1 ?? '', style: textStyle),
        ),
      ],
    );
  }

  Container _item1(MaterialLabelScanInfo data) {
    return Container(
      height: 95,
      margin: const EdgeInsets.only(right: 5, bottom: 10),
      padding: const EdgeInsets.only(left: 5, right: 5, top: 5),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        gradient: LinearGradient(
          colors: [Colors.blue.shade200, Colors.white],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _text('material_label_scan_number'.tr, '1'),
          _text('material_label_scan_processed'.tr, '2'),
          _text('material_label_scan_command'.tr, '3'),
          _text('material_label_scan_time'.tr, '4')
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return pageBodyWithDrawer(
      title: 'material_label_scan_title'.tr,
      queryWidgets: [
        DatePicker(pickerController: startDate),
        DatePicker(pickerController: endDate),
        LinkOptionsPicker(pickerController: factoryWarehouse),
        EditText(
          hint: 'material_label_scan_material_code'.tr,
          controller: materialNumber,
        ),
      ],
      query: () => logic.query(
          startDate: startDate.getDateFormatYMD(),
          endDate: endDate.getDateFormatYMD()),
      body: Obx(() => ListView.builder(
            padding: const EdgeInsets.all(8),
            itemCount: state.dataList.length,
            itemBuilder: (context, index) => _item1(state.dataList[index]),
          )),
    );
  }
}
