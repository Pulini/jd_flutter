import 'package:jd_flutter/utils/extension_util.dart';
class LarkUserTokenInfo {
  int? code;
  String? tokenType;
  String? accessToken;
  int? expiresIn;
  String? scope;

  int time = 0;

  LarkUserTokenInfo.fromJson(Map<String, dynamic> json) {
    code = JsonParse.toInt(json['code']);
    tokenType = JsonParse.str(json['token_type']);
    accessToken = JsonParse.str(json['access_token']);
    expiresIn = JsonParse.toInt(json['expires_in']);
    scope = JsonParse.str(json['scope']);
    time = DateTime.now().millisecondsSinceEpoch;
  }

  LarkUserTokenInfo.fromSaveJson(Map<String, dynamic> json) {
    code = JsonParse.toInt(json['code']);
    tokenType = JsonParse.str(json['token_type']);
    accessToken = JsonParse.str(json['access_token']);
    expiresIn = JsonParse.toInt(json['expires_in']);
    scope = JsonParse.str(json['scope']);
    time = JsonParse.toInt(json['time']);
  }

  bool isTimeout() {
    var now = DateTime.now().millisecondsSinceEpoch;
    var durationSeconds = Duration(milliseconds: now - time).inSeconds;
    return durationSeconds > (expiresIn ?? 0);
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['code'] = code;
    map['token_type'] = tokenType;
    map['access_token'] = accessToken;
    map['expires_in'] = expiresIn;
    map['scope'] = scope;
    map['time'] = time;
    return map;
  }
}

// {
//     "code": 0,
//     "data": data,
//     "msg": "success"
// }
class LarkSearchResultInfo {
  int? code;
  dynamic data;
  String? msg;

  LarkSearchResultInfo.fromJson(dynamic json) {
    code = JsonParse.toInt(json['code']);
    // data 是 dynamic（可能是对象/数组/字符串），不能转 String，否则会破坏结构
    data = json['data'];
    msg = JsonParse.str(json['msg']);
  }
}

//{
//  "has_more": false,
//  "items": []
//}
class LarkWikiSearchDataInfo {
  bool? hasMore;
  List<LarkWikiSearchItemInfo>? items;

  LarkWikiSearchDataInfo.fromJson(dynamic json) {
    hasMore = JsonParse.toBool(json['has_more']);
    items = JsonParse.list(json['items'], LarkWikiSearchItemInfo.fromJson);
  }
}

//{
//  "node_id": "LK5YwQFdwiorgIkeac6cGszGnwb",
//  "obj_token": "QseyboUDComDVtxGMw6cfcbvnab",
//  "obj_type": 5,
//  "parent_id": "",
//  "sort_id": 1,
//  "space_id": "7356843246644887580",
//  "title": "(2008.10.29-)欧盟REACH法规高关注物质清单.pdf",
//  "url": "https://goldemperor.feishu.cn/wiki/LK5YwQFdwiorgIkeac6cGszGnwb"
//}
class LarkWikiSearchItemInfo {
  String? nodeId;
  String? objToken;
  int? objType;
  String? parentId;
  int? sortId;
  String? spaceId;
  String? title;
  String? url;

  LarkWikiSearchItemInfo.fromJson(dynamic json) {
    nodeId = JsonParse.str(json['node_id']);
    objToken = JsonParse.str(json['obj_token']);
    objType = JsonParse.toInt(json['obj_type']);
    parentId = JsonParse.str(json['parent_id']);
    sortId = JsonParse.toInt(json['sort_id']);
    spaceId = JsonParse.str(json['space_id']);
    title = JsonParse.str(json['title']);
    url = JsonParse.str(json['url']);
  }
}

//  "docs_entities": [],
//  "has_more": true,
//  "total": 59
class LarkCloudDocSearchInfo {
  List<LarkCloudDocSearchItemInfo>? docs;
  bool? hasMore;
  int? total;

  LarkCloudDocSearchInfo.fromJson(dynamic json) {
    docs = JsonParse.list(json['docs_entities'], LarkCloudDocSearchItemInfo.fromJson);
    hasMore = JsonParse.toBool(json['has_more']);
    total = JsonParse.toInt(json['total']);
  }
}

//{
//  "docs_token": "shtcnLkpxnlYksumuGNZM1abcef",
//  "docs_type": "sheet",
//  "owner_id": "ou_b97fbe610114d9489ff3b501a71abcef",
//  "title": "项目进展周报"
//},
class LarkCloudDocSearchItemInfo {
  String? docsToken;
  String? docsType;
  String? ownerId;
  String? title;

  LarkCloudDocSearchItemInfo.fromJson(dynamic json) {
    docsToken = JsonParse.str(json['docs_token']);
    docsType = JsonParse.str(json['docs_type']);
    ownerId = JsonParse.str(json['owner_id']);
    title = JsonParse.str(json['title']);
  }
}

//{
//  "metas": [],
//  "failed_list": []
// }
class LarkCloudDocFileInfo {
  List<LarkCloudDocFileMetasInfo>? metas;
  List<LarkCloudDocFileFailedInfo>? failedList;

  LarkCloudDocFileInfo.fromJson(dynamic json) {
    metas = JsonParse.list(json['metas'], LarkCloudDocFileMetasInfo.fromJson);
    failedList = JsonParse.list(json['failed_list'], LarkCloudDocFileFailedInfo.fromJson);
  }
}

//{
//  "doc_token": "doccnfYZzTlvXqZIGTdAHKabcef",
//  "doc_type": "doc",
//  "title": "sampletitle",
//  "owner_id": "ou_b13d41c02edc52ce66aaae67bf1abcef",
//  "create_time": "1652066345",
//  "latest_modify_user": "ou_b13d41c02edc52ce66aaae67bf1abcef",
//  "latest_modify_time": "1652066345",
//  "url": "https://sample.feishu.cn/docs/doccnfYZzTlvXqZIGTdAHKabcef",
//  "sec_label_name": "L2-内部"
// }
class LarkCloudDocFileMetasInfo {
  String? docToken;
  String? docType;
  String? title;
  String? ownerId;
  String? createTime;
  String? latestModifyUser;
  String? latestModifyTime;
  String? url;
  String? secLabelName;

  LarkCloudDocFileMetasInfo.fromJson(dynamic json) {
    docToken = JsonParse.str(json['doc_token']);
    docType = JsonParse.str(json['doc_type']);
    title = JsonParse.str(json['title']);
    ownerId = JsonParse.str(json['owner_id']);
    createTime = JsonParse.str(json['create_time']);
    latestModifyUser = JsonParse.str(json['latest_modify_user']);
    latestModifyTime = JsonParse.str(json['latest_modify_time']);
    url = JsonParse.str(json['url']);
    secLabelName = JsonParse.str(json['sec_label_name']);
  }
}

//{
//  "token": "boxcnrHpsg1QDqXAAAyachabcef",
//  "code": 970005
// }
class LarkCloudDocFileFailedInfo {
  String? token;
  int? code;

  LarkCloudDocFileFailedInfo.fromJson(dynamic json) {
    token = JsonParse.str(json['token']);
    code = JsonParse.toInt(json['code']);
  }
}

//  "name": "zhangsan",
//         "en_name": "zhangsan",
//         "avatar_url": "www.feishu.cn/avatar/icon",
//         "avatar_thumb": "www.feishu.cn/avatar/icon_thumb",
//         "avatar_middle": "www.feishu.cn/avatar/icon_middle",
//         "avatar_big": "www.feishu.cn/avatar/icon_big",
//         "open_id": "ou-caecc734c2e3328a62489fe0648c4b98779515d3",
//         "union_id": "on-d89jhsdhjsajkda7828enjdj328ydhhw3u43yjhdj",
//         "email": "zhangsan@feishu.cn",
//         "enterprise_email": "demo@mail.com",
//         "user_id": "5d9bdxxx",
//         "mobile": "+86130002883xx",
//         "tenant_key": "736588c92lxf175d",
// 		"employee_no": "111222333"
class LarkUserInfo {
  String? name;
  String? enName;
  String? avatarUrl;
  String? avatarThumb;
  String? avatarMiddle;
  String? avatarBig;
  String? openId;
  String? unionId;
  String? email;
  String? enterpriseEmail;
  String? userId;
  String? mobile;
  String? tenantKey;
  String? employeeNo;

  LarkUserInfo.fromJson(dynamic json) {
    name = JsonParse.str(json['name']);
    enName = JsonParse.str(json['en_name']);
    avatarUrl = JsonParse.str(json['avatar_url']);
    avatarThumb = JsonParse.str(json['avatar_thumb']);
    avatarMiddle = JsonParse.str(json['avatar_middle']);
    avatarBig = JsonParse.str(json['avatar_big']);
    openId = JsonParse.str(json['open_id']);
    unionId = JsonParse.str(json['union_id']);
    email = JsonParse.str(json['email']);
    enterpriseEmail = JsonParse.str(json['enterprise_email']);
    userId = JsonParse.str(json['user_id']);
    mobile = JsonParse.str(json['mobile']);
    tenantKey = JsonParse.str(json['tenant_key']);
    employeeNo = JsonParse.str(json['employee_no']);
  }

 Map toJson() => {
        'name': name,
        'en_name': enName,
        'avatar_url': avatarUrl,
        'avatar_thumb': avatarThumb,
        'avatar_middle': avatarMiddle,
        'avatar_big': avatarBig,
        'open_id': openId,
        'union_id': unionId,
        'email': email,
        'enterprise_email': enterpriseEmail,
        'user_id': userId,
        'mobile': mobile,
        'tenant_key': tenantKey,
        'employee_no': employeeNo
      };
}
