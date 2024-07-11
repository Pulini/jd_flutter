import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jd_flutter/widget/custom_widget.dart';

import 'material_dispatch_logic.dart';

class MaterialDispatchPage extends StatefulWidget {
  const MaterialDispatchPage({Key? key}) : super(key: key);

  @override
  State<MaterialDispatchPage> createState() => _MaterialDispatchPageState();
}

class _MaterialDispatchPageState extends State<MaterialDispatchPage> {
  final logic = Get.put(MaterialDispatchLogic());
  final state = Get.find<MaterialDispatchLogic>().state;

  @override
  Widget build(BuildContext context) {
    return pageBodyWithDrawer(
      queryWidgets: [],
      query: () => logic.query(),
      body: Column(
        children: [],
      ),
    );
  }

  @override
  void dispose() {
    Get.delete<MaterialDispatchLogic>();
    super.dispose();
  }
}
