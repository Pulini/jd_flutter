
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
//     "data": {
//         "has_more": false,
//         "items": [
//             {
//                 "node_id": "LK5YwQFdwiorgIkeac6cGszGnwb",
//                 "obj_token": "QseyboUDComDVtxGMw6cfcbvnab",
//                 "obj_type": 5,
//                 "parent_id": "",
//                 "sort_id": 1,
//                 "space_id": "7356843246644887580",
//                 "title": "(2008.10.29-)欧盟REACH法规高关注物质清单.pdf",
//                 "url": "https://goldemperor.feishu.cn/wiki/LK5YwQFdwiorgIkeac6cGszGnwb"
//             }
//         ]
//     },
//     "msg": "success"
// }
class FeishuWikiSearchInfo {
  int? code;
  FeishuWikiSearchDataInfo? data;
  String? msg;

  FeishuWikiSearchInfo.fromJson(dynamic json) {
    code = json['code'];
    if(json['data']!=null){
      data = FeishuWikiSearchDataInfo.fromJson(json['data']);
    }
    msg = json['msg'];
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['code'] = code;
    if (data != null) {
      map['data'] = data?.toJson();
    }
    map['msg'] = msg;
    return map;
  }
}

class FeishuWikiSearchDataInfo {
  bool? hasMore;
  List<FeishuWikiSearchItemInfo>? items;

  FeishuWikiSearchDataInfo({
    this.hasMore,
    this.items,
  });

  FeishuWikiSearchDataInfo.fromJson(dynamic json) {
    hasMore = json['has_more'];
    if (json['items'] != null) {
      items = [];
      json['items'].forEach((v) {
        items?.add(FeishuWikiSearchItemInfo.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['has_more'] = hasMore;
    if (items != null) {
      map['items'] = items?.map((v) => v.toJson()).toList();
    }
    return map;
  }
}

class FeishuWikiSearchItemInfo {
  String? nodeId;
  String? objToken;
  int? objType;
  String? parentId;
  int? sortId;
  String? spaceId;
  String? title;
  String? url;

  FeishuWikiSearchItemInfo({
    this.nodeId,
    this.objToken,
    this.objType,
    this.parentId,
    this.sortId,
    this.spaceId,
    this.title,
    this.url,
  });

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

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['node_id'] = nodeId;
    map['obj_token'] = objToken;
    map['obj_type'] = objType;
    map['parent_id'] = parentId;
    map['sort_id'] = sortId;
    map['space_id'] = spaceId;
    map['title'] = title;
    map['url'] = url;
    return map;
  }
}
