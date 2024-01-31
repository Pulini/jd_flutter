class UpdateProperty {
  UpdateProperty({
    this.address,
    this.assetPicture,
    this.ratingPlatePicture,
    this.deptID,
    this.guaranteePeriod,
    this.interID,
    this.keepEmpID,
    this.liableEmpID,
    this.manufacturer,
    this.model,
    this.name,
    this.notes,
    this.number,
    this.orgVal,
    this.participator,
    this.price,
    this.registrationerID,
    this.writeDate,
    this.buyDate,
    this.reviceDate,
  });

  UpdateProperty.fromJson(dynamic json) {
    address=json['Address'];
    assetPicture=json['AssetPicture'];
    ratingPlatePicture=json['RatingPlatePicture'];
    deptID=json['DeptID'];
    guaranteePeriod=json['GuaranteePeriod'];
    interID=json['InterID'];
    keepEmpID=json['KeepEmpID'];
    liableEmpID=json['LiableEmpID'];
    manufacturer=json['Manufacturer'];
    model=json['Model'];
    name=json['Name'];
    notes=json['Notes'];
    number=json['Number'];
    orgVal=json['OrgVal'];
    participator=json['Participator'];
    price=json['Price'];
    registrationerID=json['RegistrationerID'];
    writeDate=json['WriteDate'];
    buyDate=json['BuyDate'];
    reviceDate=json['ReviceDate'];
  }

  String? address;//存放地址
  String? assetPicture;//固定资产图片（base64格式）
  String? ratingPlatePicture;//固定资产图片（base64格式）
  int? deptID;//保管部门
  String? guaranteePeriod;//财产保修期
  int? interID;//id
  int? keepEmpID;//保管人
  int? liableEmpID;//责任人
  String? manufacturer;//制造商
  String? model;//规格型号
  String? name;//设备名称
  String? notes;//备注
  String? number;//财产编号-由财产管理员编写
  String? orgVal;//金额
  int? participator;//参与验收人
  String? price;//单价
  int? registrationerID;//登记人ID
  String? writeDate;//入账日期-登记日期
  String? buyDate;//购买日期
  String? reviceDate;//保管日期


  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['Address']=address;
    map['AssetPicture']=assetPicture;
    map['RatingPlatePicture']=ratingPlatePicture;
    map['DeptID']=deptID;
    map['GuaranteePeriod']=guaranteePeriod;
    map['InterID']=interID;
    map['KeepEmpID']=keepEmpID;
    map['LiableEmpID']=liableEmpID;
    map['Manufacturer']=manufacturer;
    map['Model']=model;
    map['Name']=name;
    map['Notes']=notes;
    map['Number']=number;
    map['OrgVal']=orgVal;
    map['Participator']=participator;
    map['Price']=price;
    map['RegistrationerID']=registrationerID;
    map['WriteDate']=writeDate;
    map['BuyDate']=buyDate;
    map['ReviceDate']=reviceDate;
    return map;
  }
}
