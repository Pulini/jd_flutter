/// ItemID : "6870"
/// Number : "SJLB509B"
/// Name : "热水表"
/// OrganizeName : "金帝PUMA厂区"
/// DormitoriesName : "金隆宿舍楼"
/// Floor : ""
/// TypeName : "热水表"
/// IsUse : "已使用"
/// IsWriteMeter : "未抄表"
/// RoomNumber : "11.5.509"

class DeviceListInfo {
  DeviceListInfo({
      this.itemID='',
      this.number='',
      this.name='',
      this.organizeName='',
      this.dormitoriesName='',
      this.floor='',
      this.typeName='',
      this.isUse='',
      this.isWriteMeter='',
      this.roomNumber='',});

  DeviceListInfo.fromJson(dynamic json) {
    itemID = json['ItemID'];
    number = json['Number'];
    name = json['Name'];
    organizeName = json['OrganizeName'];
    dormitoriesName = json['DormitoriesName'];
    floor = json['Floor'];
    typeName = json['TypeName'];
    isUse = json['IsUse'];
    isWriteMeter = json['IsWriteMeter'];
    roomNumber = json['RoomNumber'];
  }
  String? itemID;
  String? number;  //设备编号
  String? name;  //设备名称
  String? organizeName;
  String? dormitoriesName;
  String? floor;  //楼层
  String? typeName;  //设备类型
  String? isUse;  //是否使用
  String? isWriteMeter;  //本月是否抄表
  String? roomNumber;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['ItemID'] = itemID;
    map['Number'] = number;
    map['Name'] = name;
    map['OrganizeName'] = organizeName;
    map['DormitoriesName'] = dormitoriesName;
    map['Floor'] = floor;
    map['TypeName'] = typeName;
    map['IsUse'] = isUse;
    map['IsWriteMeter'] = isWriteMeter;
    map['RoomNumber'] = roomNumber;
    return map;
  }

}