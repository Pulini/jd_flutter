import 'dart:ui';

// ClassName : "生产"
// BackGroundColor : "＃00FF00"
// FontColor : "#ffffff"
// Icon : "./icon/icon1.png"
// Subfunctions : [{"Name":"派工","Description":"车间生产派工","Icon":"./icon/icon1.png","FunctionGroup":[{"Id":1,"Version":1,"Name":"工单列表","Description":"根据工票生成条码并打印条码","Icon":"./icon/icon1.png","RouteSrc":"","HasPermission":false},{"Id":2,"Version":1,"Name":"生产派工","Description":"MES生产派工单列表APP端","Icon":"./icon/icon1.png","RouteSrc":"","HasPermission":true},{"Id":3,"Version":1,"Name":"材料车间派工","Description":"贴合、抽条报工","Icon":"./icon/icon1.png","RouteSrc":"","HasPermission":false},{"Id":4,"Version":1,"Name":"裁断车间工单列表","Description":"","Icon":"./icon/icon1.png","RouteSrc":"","HasPermission":false},{"Id":5,"Version":1,"Name":"机台派工单","Description":"圆盘机派工单","Icon":"./icon/icon1.png","RouteSrc":"","HasPermission":false},{"Id":6,"Version":1,"Name":"机台模具派工单列表","Description":"","Icon":"./icon/icon1.png","RouteSrc":"","HasPermission":false}]},{"Name":"报工","Description":"车间生产报表","Icon":"./icon/icon1.png","FunctionGroup":[{"Id":1,"Version":1,"Name":"车间计工","Description":"金灿车间报个件、团件","Icon":"./icon/icon1.png","RouteSrc":"","HasPermission":false},{"Id":2,"Version":1,"Name":"湿印工序派工","Description":"湿印车间打条码、报工","Icon":"./icon/icon1.png","RouteSrc":"","HasPermission":false},{"Id":3,"Version":1,"Name":"部件工序扫描","Description":"","Icon":"./icon/icon1.png","RouteSrc":"","HasPermission":false},{"Id":4,"Version":1,"Name":"生产部件交接单","Description":"","Icon":"./icon/icon1.png","RouteSrc":"","HasPermission":false},{"Id":5,"Version":1,"Name":"报工交接确认列表","Description":"金臻注塑车间报工交接","Icon":"./icon/icon1.png","RouteSrc":"","HasPermission":false},{"Id":6,"Version":1,"Name":"注塑车间扫码报工","Description":"金臻注塑车间扫描报工","Icon":"./icon/icon1.png","RouteSrc":"","HasPermission":false},{"Id":7,"Version":1,"Name":"部件扫描报工","Description":"激光裁断报工","Icon":"./icon/icon1.png","RouteSrc":"","HasPermission":false},{"Id":8,"Version":1,"Name":"工序派工单列表","Description":"裁断一体机生成条码并打印条码","Icon":"./icon/icon1.png","RouteSrc":"","HasPermission":false},{"Id":9,"Version":1,"Name":"工序汇报","Description":"工票扫码报工","Icon":"./icon/icon1.png","RouteSrc":"","HasPermission":false},{"Id":10,"Version":1,"Name":"成型后段扫码","Description":"成型线与仓库交接并入库","Icon":"./icon/icon1.png","RouteSrc":"","HasPermission":true},{"Id":11,"Version":1,"Name":"成型条码采集","Description":"生产线报工","Icon":"./icon/icon1.png","RouteSrc":"","HasPermission":true},{"Id":12,"Version":1,"Name":"个件列表","Description":"个件报工审批","Icon":"./icon/icon1.png","RouteSrc":"","HasPermission":false},{"Id":13,"Version":1,"Name":"部件报工或取消","Description":"按部件扫码报工旧版","Icon":"./icon/icon1.png","RouteSrc":"","HasPermission":false},{"Id":14,"Version":1,"Name":"品质管理","Description":"针车品质输入合格数","Icon":"./icon/icon1.png","RouteSrc":"","HasPermission":true}]},{"Name":"报表","Description":"报表","Icon":"./icon/icon1.png","FunctionGroup":[{"Id":1,"Version":1,"Name":"供应商合格率报表","Description":"近2年无使用记录","Icon":"./icon/icon1.png","RouteSrc":"","HasPermission":true},{"Id":2,"Version":1,"Name":"供应商质量分析表","Description":"近2年无使用记录","Icon":"./icon/icon1.png","RouteSrc":"","HasPermission":true},{"Id":3,"Version":1,"Name":"战情室扫码查询","Description":"近2年无使用记录","Icon":"./icon/icon1.png","RouteSrc":"","HasPermission":false},{"Id":4,"Version":1,"Name":"扫码日产量报表","Description":"","Icon":"./icon/icon1.png","RouteSrc":"","HasPermission":true},{"Id":5,"Version":1,"Name":"车间产量实时汇总表","Description":"","Icon":"./icon/icon1.png","RouteSrc":"","HasPermission":true},{"Id":6,"Version":1,"Name":"生产日报表","Description":"针车平板中查看日产量报表","Icon":"./icon/icon1.png","RouteSrc":"","HasPermission":true},{"Id":7,"Version":1,"Name":"车间生产日报表","Description":"针车平板中查看日产量报表","Icon":"./icon/icon1.png","RouteSrc":"","HasPermission":true},{"Id":8,"Version":1,"Name":"生产效率表","Description":"针车平板中查看日产量报表","Icon":"./icon/icon1.png","RouteSrc":"","HasPermission":true},{"Id":9,"Version":1,"Name":"生产订单用料表","Description":"查工单组件领料情况","Icon":"./icon/icon1.png","RouteSrc":"","HasPermission":false},{"Id":10,"Version":1,"Name":"查看指令明细","Description":"查看指令表","Icon":"./icon/icon1.png","RouteSrc":"","HasPermission":false},{"Id":11,"Version":1,"Name":"员工计件产量查询","Description":"","Icon":"./icon/icon1.png","RouteSrc":"","HasPermission":false},{"Id":12,"Version":1,"Name":"员工计件明细","Description":"员工产量明细","Icon":"./icon/icon1.png","RouteSrc":"","HasPermission":true},{"Id":13,"Version":1,"Name":"查看工艺说明书","Description":"PDF工艺书","Icon":"./icon/icon1.png","RouteSrc":"","HasPermission":false}]}]

class HomeFunctions {
  HomeFunctions({
    this.className,
    this.backGroundColor,
    this.fontColor,
    this.icon,
    this.subFunctions,
  });

  HomeFunctions.fromJson(dynamic json) {
    className = json['ClassName'];
    backGroundColor = json['BackGroundColor'];
    fontColor = json['FontColor'];
    icon = json['Icon'];
    if (json['Subfunctions'] != null) {
      subFunctions = [];
      json['Subfunctions'].forEach((v) {
        subFunctions?.add(SubFunctions.fromJson(v));
      });
    }
  }

  String? className;
  int? backGroundColor;
  int? fontColor;
  String? icon;
  List<SubFunctions>? subFunctions;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['ClassName'] = className;
    map['BackGroundColor'] = backGroundColor;
    map['FontColor'] = fontColor;
    map['Icon'] = icon;
    if (subFunctions != null) {
      map['Subfunctions'] = subFunctions?.map((v) => v.toJson()).toList();
    }
    return map;
  }

  getTextColor() => Color(fontColor ?? 0xffffffff);

  getBKGColor() => Color(backGroundColor ?? 0xffffffff);
}

// Name : "派工"
// Description : "车间生产派工"
// Icon : "./icon/icon1.png"
// FunctionGroup : [{"Id":1,"Version":1,"Name":"工单列表","Description":"根据工票生成条码并打印条码","Icon":"./icon/icon1.png","RouteSrc":"","HasPermission":false},{"Id":2,"Version":1,"Name":"生产派工","Description":"MES生产派工单列表APP端","Icon":"./icon/icon1.png","RouteSrc":"","HasPermission":true},{"Id":3,"Version":1,"Name":"材料车间派工","Description":"贴合、抽条报工","Icon":"./icon/icon1.png","RouteSrc":"","HasPermission":false},{"Id":4,"Version":1,"Name":"裁断车间工单列表","Description":"","Icon":"./icon/icon1.png","RouteSrc":"","HasPermission":false},{"Id":5,"Version":1,"Name":"机台派工单","Description":"圆盘机派工单","Icon":"./icon/icon1.png","RouteSrc":"","HasPermission":false},{"Id":6,"Version":1,"Name":"机台模具派工单列表","Description":"","Icon":"./icon/icon1.png","RouteSrc":"","HasPermission":false}]

class SubFunctions {
  SubFunctions({
    this.name,
    this.description,
    this.icon,
    this.functionGroup,
  });

  SubFunctions.fromJson(dynamic json) {
    name = json['Name'];
    description = json['Description'];
    icon = json['Icon'];
    if (json['FunctionGroup'] != null) {
      functionGroup = [];
      json['FunctionGroup'].forEach((v) {
        functionGroup?.add(FunctionGroup.fromJson(v));
      });
    }
  }

  String? name;
  String? description;
  String? icon;
  List<FunctionGroup>? functionGroup;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['Name'] = name;
    map['Description'] = description;
    map['Icon'] = icon;
    if (functionGroup != null) {
      map['FunctionGroup'] = functionGroup?.map((v) => v.toJson()).toList();
    }
    return map;
  }
}

// Id : 1
// Version : 1
// Name : "工单列表"
// Description : "根据工票生成条码并打印条码"
// Icon : "./icon/icon1.png"
// RouteSrc : ""
// HasPermission : false

class FunctionGroup {
  FunctionGroup({
    this.id,
    this.version,
    this.name,
    this.description,
    this.icon,
    this.routeSrc,
    this.hasPermission,
  });

  FunctionGroup.fromJson(dynamic json) {
    id = json['Id'];
    version = json['Version'];
    name = json['Name'];
    description = json['Description'];
    icon = json['Icon'];
    routeSrc = json['RouteSrc'];
    hasPermission = json['HasPermission'];
  }

  int? id;
  int? version;
  String? name;
  String? description;
  String? icon;
  String? routeSrc;
  bool? hasPermission;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['Id'] = id;
    map['Version'] = version;
    map['Name'] = name;
    map['Description'] = description;
    map['Icon'] = icon;
    map['RouteSrc'] = routeSrc;
    map['HasPermission'] = hasPermission;
    return map;
  }
}
