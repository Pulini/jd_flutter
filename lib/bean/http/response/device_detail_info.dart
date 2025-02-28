// ID : "35666"
// ItemID : "10"
// Number : "DDSA202A"
// Name : "普通电表"
// OrganizeName : "温州金臻实业股份有限公司"
// DormitoriesName : "帝胜宿舍楼"
// Floor : ""
// RoomNumber : "13.2.202"
// TypeName : "电表"
// IsUse : "已使用"
// LastDateTime : "2020/11/27 13:10:55"
// LastDegree : "500"
// NowDegree : "500"

class DeviceDetailInfo {
  DeviceDetailInfo({
      this.id='',
      this.itemID='',
      this.number='',
      this.name='',
      this.organizeName='',
      this.dormitoriesName='',
      this.floor='',
      this.roomNumber='',
      this.typeName='',
      this.isUse='',
      this.lastDateTime='',
      this.lastDegree='',
      this.nowDegree='',});

  DeviceDetailInfo.fromJson(dynamic json) {
    id = json['ID'];
    itemID = json['ItemID'];
    number = json['Number'];
    name = json['Name'];
    organizeName = json['OrganizeName'];
    dormitoriesName = json['DormitoriesName'];
    floor = json['Floor'];
    roomNumber = json['RoomNumber'];
    typeName = json['TypeName'];
    isUse = json['IsUse'];
    lastDateTime = json['LastDateTime'];
    lastDegree = json['LastDegree'];
    nowDegree = json['NowDegree'];
  }
  String? id;
  String? itemID;
  String? number;
  String? name;
  String? organizeName;
  String? dormitoriesName;
  String? floor;
  String? roomNumber;
  String? typeName;
  String? isUse;
  String? lastDateTime;
  String? lastDegree;
  String? nowDegree;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['ID'] = id;
    map['ItemID'] = itemID;
    map['Number'] = number;
    map['Name'] = name;
    map['OrganizeName'] = organizeName;
    map['DormitoriesName'] = dormitoriesName;
    map['Floor'] = floor;
    map['RoomNumber'] = roomNumber;
    map['TypeName'] = typeName;
    map['IsUse'] = isUse;
    map['LastDateTime'] = lastDateTime;
    map['LastDegree'] = lastDegree;
    map['NowDegree'] = nowDegree;
    return map;
  }

}