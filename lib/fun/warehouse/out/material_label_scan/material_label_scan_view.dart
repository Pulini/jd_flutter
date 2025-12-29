import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jd_flutter/bean/http/response/material_label_scan_info.dart';
import 'package:jd_flutter/route.dart';
import 'package:jd_flutter/utils/web_api.dart';
import 'package:jd_flutter/widget/custom_widget.dart';
import 'package:jd_flutter/widget/picker/picker_controller.dart';
import 'package:jd_flutter/widget/picker/picker_view.dart';
import 'package:jd_flutter/widget/scanner.dart';

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
  var dispatchDate = DatePickerController(
    buttonName: 'process_dispatch_dispatch_date'.tr,
    PickerType.date,
    saveKey: '${RouteConfig.materialLabelScan.name}${PickerType.date}',
  );

  var controller = TextEditingController();
  var numberController = TextEditingController();


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

  add() {
    logger.f('点击了----------');
    var list = <MaterialLabelScanInfo>[];
    list.add(MaterialLabelScanInfo(interID: '1'));
    state.dataList.value = list;
  }

  @override
  Widget build(BuildContext context) {
    return pageBodyWithDrawer(
      queryWidgets: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 5), // 左右 5 像素
          child: CupertinoSearchTextField(
            //工票
            prefixIcon: const SizedBox.shrink(),
            controller: controller,
            suffixIcon: const Icon(Icons.qr_code_scanner_outlined),
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(20),
            ),
            onChanged: (s) {
              state.materialListNumber = s;
            },
            onSuffixTap: () {
              Get.to(() => const Scanner())?.then((v) {
                if (v != null) {

                }
              });
            },
            placeholder: 'process_dispatch_work_ticket'.tr,
            suffixMode: OverlayVisibilityMode.always, // 添加这一行
          ),
        ),
        Center(child: Text('process_dispatch_or'.tr)),
        DatePicker(pickerController: dispatchDate),

      ],
      query: () => {add()},
      body: Obx(() => ListView.builder(
            padding: const EdgeInsets.all(8),
            itemCount: state.dataList.length,
            itemBuilder: (context, index) => _item1(state.dataList[index]),
          )),
    );
  }
}
