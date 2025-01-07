import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
import 'package:jd_flutter/utils/web_api.dart';

import '../../../widget/combination_button_widget.dart';
import '../../../widget/custom_widget.dart';

class HydroelectricExcessPage extends StatefulWidget {
  const HydroelectricExcessPage({super.key});

  @override
  State<HydroelectricExcessPage> createState() => _HydroelectricExcessPageState();
}

class _HydroelectricExcessPageState extends State<HydroelectricExcessPage> {
  @override

  @override
  Widget build(BuildContext context) {
    return Obx(
          () => pageBody(
          actions: [
            InkWell(child: const Icon(
              Icons.dehaze,
              size: 35,
              color: Colors.white,
            ),onTap: ()=>{
              logger.f('点击---------')
            },)
          ],
          body: Column(
            children: [

            ],
          )),
    );
  }
}
