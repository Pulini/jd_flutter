import 'abnormal_quality_info.dart';
import 'package:jd_flutter/utils/extension_util.dart';

// Entry : [{"exNumber":"SCPZYCD200000108","billDate":"2020/7/9 16:35:01","empID":139697,"qty":"28","exceptionID":30,"exceptionName":"清洁不良","exceptionLevel":"轻微","reCheck":"复检合格"}]
// qty : "834.0000000000"

class AbnormalQualityListInfo {
  AbnormalQualityListInfo({
      this.abnormalQualityInfo,
      this.orderNumber,});

  AbnormalQualityListInfo.fromJson(dynamic json) {
    abnormalQualityInfo = JsonParse.list(json['AbnormalQualityInfo'], AbnormalQualityInfo.fromJson);
    orderNumber = JsonParse.str(json['orderNumber']);
  }
  List<AbnormalQualityInfo>? abnormalQualityInfo;
  String? orderNumber;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (abnormalQualityInfo != null) {
      map['AbnormalQualityInfo'] = abnormalQualityInfo?.map((v) => v.toJson()).toList();
    }
    map['orderNumber'] = orderNumber;
    return map;
  }
}
