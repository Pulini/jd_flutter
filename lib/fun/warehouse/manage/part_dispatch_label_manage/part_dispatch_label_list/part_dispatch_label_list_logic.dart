import 'package:get/get.dart';
import 'package:jd_flutter/widget/dialogs.dart';

import 'part_dispatch_label_list_state.dart';

class PartDispatchLabelListLogic extends GetxController {
  final PartDispatchLabelListState state = PartDispatchLabelListState();

  void getLabelList({
    required String? partIds,
    required int? packOrderId,
    Function()? success,
  }) {
    state.getLabelList(
      partIds: partIds,
      packOrderId: packOrderId,
      success: () => success?.call(),
      error: (msg) => errorDialog(content: msg),
    );
  }

  void deleteLabel(){

  }

  void printLockOrUnlock(){

  }

  void selectAllItem(){

  }

  void printLabels(){

  }

}
