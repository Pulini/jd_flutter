import 'dart:ui';

import 'package:get/get.dart';

import '../../../http/response/property_info.dart';

enum AuditedType { audited, unAudited, underAudit }

class PropertyState {

  var tabColors = <AuditedType, Color>{
    AuditedType.audited: const Color(0xff191970),
    AuditedType.unAudited: const Color(0xff40826d),
    AuditedType.underAudit: const Color(0xff007ba7),
  };
  Rx<AuditedType> selectedTab = AuditedType.audited.obs;
  RxList<PropertyInfo> propertyList=<PropertyInfo>[].obs;

  PropertyState() {
    ///Initialize variables
  }
}
