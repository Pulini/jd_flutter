class FeishuUserTokenInfo {
  int? code;
  String? tokenType;
  String? accessToken;
  int? expiresIn;
  String? scope;

  int time = 0;

  FeishuUserTokenInfo.fromJson(Map<String, dynamic> json) {
    code = json['code'];
    tokenType = json['token_type'];
    accessToken = json['access_token'];
    expiresIn = json['expires_in'];
    scope = json['scope'];
    time = DateTime.now().millisecondsSinceEpoch;
  }

  FeishuUserTokenInfo.fromSaveJson(Map<String, dynamic> json) {
    code = json['code'];
    tokenType = json['token_type'];
    accessToken = json['access_token'];
    expiresIn = json['expires_in'];
    scope = json['scope'];
    time = json['time'];
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
class FeishuSearchResultInfo {
  int? code;
  dynamic data;
  String? msg;

  FeishuSearchResultInfo.fromJson(dynamic json) {
    code = json['code'];
    data = json['data'];
    msg = json['msg'];
  }
}

//{
//  "has_more": false,
//  "items": []
//}
class FeishuWikiSearchDataInfo {
  bool? hasMore;
  List<FeishuWikiSearchItemInfo>? items;

  FeishuWikiSearchDataInfo.fromJson(dynamic json) {
    hasMore = json['has_more'];
    if (json['items'] != null) {
      items = [];
      json['items'].forEach((v) {
        items?.add(FeishuWikiSearchItemInfo.fromJson(v));
      });
    }
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
class FeishuWikiSearchItemInfo {
  String? nodeId;
  String? objToken;
  int? objType;
  String? parentId;
  int? sortId;
  String? spaceId;
  String? title;
  String? url;

  FeishuWikiSearchItemInfo.fromJson(dynamic json) {
    nodeId = json['node_id'];
    objToken = json['obj_token'];
    objType = json['obj_type'];
    parentId = json['parent_id'];
    sortId = json['sort_id'];
    spaceId = json['space_id'];
    title = json['title'];
    url = json['url'];
  }
}

//  "docs_entities": [],
//  "has_more": true,
//  "total": 59
class FeishuCloudDocSearchInfo {
  List<FeishuCloudDocSearchItemInfo>? docs;
  bool? hasMore;
  int? total;

  FeishuCloudDocSearchInfo.fromJson(dynamic json) {
    if (json['docs_entities'] != null) {
      docs = [];
      json['docs_entities'].forEach((v) {
        docs?.add(FeishuCloudDocSearchItemInfo.fromJson(v));
      });
    }
    hasMore = json['has_more'];
    total = json['total'];
  }
}

//{
//  "docs_token": "shtcnLkpxnlYksumuGNZM1abcef",
//  "docs_type": "sheet",
//  "owner_id": "ou_b97fbe610114d9489ff3b501a71abcef",
//  "title": "项目进展周报"
//},
class FeishuCloudDocSearchItemInfo {
  String? docsToken;
  String? docsType;
  String? ownerId;
  String? title;

  FeishuCloudDocSearchItemInfo.fromJson(dynamic json) {
    docsToken = json['docs_token'];
    docsType = json['docs_type'];
    ownerId = json['owner_id'];
    title = json['title'];
  }
}

//{
//  "metas": [],
//  "failed_list": []
// }
class FeishuCloudDocFileInfo {
  List<FeishuCloudDocFileMetasInfo>? metas;
  List<FeishuCloudDocFileFailedInfo>? failedList;

  FeishuCloudDocFileInfo.fromJson(dynamic json) {
    if (json['metas'] != null) {
      metas = [];
      json['metas'].forEach((v) {
        metas?.add(FeishuCloudDocFileMetasInfo.fromJson(v));
      });
    }
    if (json['failed_list'] != null) {
      failedList = [];
      json['failed_list'].forEach((v) {
        failedList?.add(FeishuCloudDocFileFailedInfo.fromJson(v));
      });
    }
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
class FeishuCloudDocFileMetasInfo {
  String? docToken;
  String? docType;
  String? title;
  String? ownerId;
  String? createTime;
  String? latestModifyUser;
  String? latestModifyTime;
  String? url;
  String? secLabelName;

  FeishuCloudDocFileMetasInfo.fromJson(dynamic json) {
    docToken = json['doc_token'];
    docType = json['doc_type'];
    title = json['title'];
    ownerId = json['owner_id'];
    createTime = json['create_time'];
    latestModifyUser = json['latest_modify_user'];
    latestModifyTime = json['latest_modify_time'];
    url = json['url'];
    secLabelName = json['sec_label_name'];
  }
}

//{
//  "token": "boxcnrHpsg1QDqXAAAyachabcef",
//  "code": 970005
// }
class FeishuCloudDocFileFailedInfo {
  String? token;
  int? code;

  FeishuCloudDocFileFailedInfo.fromJson(dynamic json) {
    token = json['token'];
    code = json['code'];
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
class FeishuUserInfo {
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

  FeishuUserInfo.fromJson(dynamic json) {
    name = json['name'];
    enName = json['en_name'];
    avatarUrl = json['avatar_url'];
    avatarThumb = json['avatar_thumb'];
    avatarMiddle = json['avatar_middle'];
    avatarBig = json['avatar_big'];
    openId = json['open_id'];
    unionId = json['union_id'];
    email = json['email'];
    enterpriseEmail = json['enterprise_email'];
    userId = json['user_id'];
    mobile = json['mobile'];
    tenantKey = json['tenant_key'];
    employeeNo = json['employee_no'];
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
