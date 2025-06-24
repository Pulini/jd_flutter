import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:jd_flutter/fun/management/quality_management/quality_management_logic.dart';
import 'package:jd_flutter/fun/management/quality_management/quality_management_state.dart';
import '../../../../widget/custom_widget.dart';

class QualityManagementPage extends StatefulWidget {
  const QualityManagementPage({super.key});

  @override
  State<QualityManagementPage> createState() => _QualityManagementPageState();
}

class _QualityManagementPageState extends State<QualityManagementPage> {
  final QualityManagementLogic logic = Get.put(QualityManagementLogic());
  final QualityManagementState state = Get.find<QualityManagementLogic>().state;

  @override
  Widget build(BuildContext context) {
    return pageBodyWithDrawer(
      queryWidgets: [],
      query: () {},
      body: Obx(
        () => Column(
          children: [
            // Expanded(
            //   child: Obx(
            //     () => ListView.builder(
            //       itemCount: state.showDataList.length,
            //       itemBuilder: (context, index) =>
            //           _item(state.showDataList[index]),
            //     ),
            //   ),
            // ),
          ],
        ),
      ),
    );
  }
}
