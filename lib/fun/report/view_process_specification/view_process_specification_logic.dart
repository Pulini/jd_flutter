import 'package:get/get.dart';
import 'package:jd_flutter/utils/utils.dart';
import 'package:jd_flutter/widget/dialogs.dart';

import 'view_process_specification_state.dart';

class ViewProcessSpecificationLogic extends GetxController {
  final ViewProcessSpecificationState state = ViewProcessSpecificationState();

  void queryProcessSpecification(String typeBody) {
    getProcessManual(
      typeBody: typeBody,
      error: (msg) => errorDialog(content: msg),
      manualList: (list) => state.pdfList.value = list,
    );
  }
}
