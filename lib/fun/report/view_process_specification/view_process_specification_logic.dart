import 'package:get/get.dart';
import 'package:jd_flutter/widget/dialogs.dart';

import 'view_process_specification_state.dart';

class ViewProcessSpecificationLogic extends GetxController {
  final ViewProcessSpecificationState state = ViewProcessSpecificationState();

  queryProcessSpecification() {
    if (state.etTypeBody.isEmpty) {
      errorDialog(content: 'view_process_specification_query_hint'.tr);
      return;
    }
    state.getProcessSpecificationList(
      error: (msg) => errorDialog(content: msg),
    );
  }
}
