import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jd_flutter/fun/warehouse/in/quality_inspection_list/quality_inspection_list_logic.dart';
import 'package:jd_flutter/fun/warehouse/in/quality_inspection_list/quality_inspection_list_state.dart';
import 'package:jd_flutter/widget/custom_widget.dart';

class ColorLabelBindingPage extends StatefulWidget {
  const ColorLabelBindingPage({super.key});

  @override
  State<ColorLabelBindingPage> createState() => _ColorLabelBindingPageState();
}

class _ColorLabelBindingPageState extends State<ColorLabelBindingPage> {
  final QualityInspectionListLogic logic =
  Get.find<QualityInspectionListLogic>();
  final QualityInspectionListState state =
      Get.find<QualityInspectionListLogic>().state;
  
  @override
  Widget build(BuildContext context) {
    return pageBody(body: Column(children: [],));
  }
}
