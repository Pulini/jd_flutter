import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'puma_label_manage_logic.dart';
import 'puma_label_manage_state.dart';

class PumaLabelManagePage extends StatefulWidget {
  const PumaLabelManagePage({super.key});

  @override
  State<PumaLabelManagePage> createState() => _PumaLabelManagePageState();
}

class _PumaLabelManagePageState extends State<PumaLabelManagePage> {
  final PumaLabelManageLogic logic = Get.put(PumaLabelManageLogic());
  final PumaLabelManageState state = Get.find<PumaLabelManageLogic>().state;

  @override
  Widget build(BuildContext context) {
    return Container();
  }

  @override
  void dispose() {
    Get.delete<PumaLabelManageLogic>();
    super.dispose();
  }
}