import 'package:flutter/material.dart';
import 'package:jd_flutter/utils/extension_util.dart';

// ============================================================================
// 工序卡明细 Bean（接口：api/ProcessWorkCard/GetProcessWorkCardInfo）
// 对应后端响应 Data 节点：
//   ProcessWorkCardInfo  工序卡主信息
//   ComponentList        部件清单（含工序列表 + 物料清单 MaterialList）
//   DispatchedList       已派工列表（员工 + 尺码 Size）
//   SizeList             尺码数量列表
//
// 说明：
//   1. 字段名采用标准小驼峰命名，JSON key 映射集中在 fromJson/toJson 中；
//   2. 字段与后端返回 JSON 严格一一对应（已去除后端不返回的多余字段）；
//   3. 统一使用 JsonParse 解析，保证解析结果不为 null。
// ============================================================================

/// Data 根节点
class WorkCardDetail {
  final ProcessWorkCardInfo? processWorkCardInfo;
  final List<ComponentItem> componentList;
  final List<DispatchedItem> dispatchedList;
  final List<SizeInfo> sizeList;

  WorkCardDetail({
    this.processWorkCardInfo,
    this.componentList = const [],
    this.dispatchedList = const [],
    this.sizeList = const [],
  });

  factory WorkCardDetail.fromJson(Map<String, dynamic> json) => WorkCardDetail(
        processWorkCardInfo: json['ProcessWorkCardInfo'] == null
            ? null
            : ProcessWorkCardInfo.fromJson(json['ProcessWorkCardInfo']),
        componentList:
            JsonParse.list(json['ComponentList'], ComponentItem.fromJson),
        dispatchedList:
            JsonParse.list(json['DispatchedList'], DispatchedItem.fromJson),
        sizeList: JsonParse.list(json['SizeList'], SizeInfo.fromJson),
      );

  Map<String, dynamic> toJson() => {
        'ProcessWorkCardInfo': processWorkCardInfo?.toJson(),
        'ComponentList': componentList.map((e) => e.toJson()).toList(),
        'DispatchedList': dispatchedList.map((e) => e.toJson()).toList(),
        'SizeList': sizeList.map((e) => e.toJson()).toList(),
      };
}

/// 工序卡主信息（ProcessWorkCardInfo）
class ProcessWorkCardInfo {
  final int interId;
  final String processNumber;
  final String factoryName;
  final String date;
  final String departName;
  final int departId;
  final String productNumber;
  final String packag;
  final String cardNo;
  final int reportStatus;
  final String batchNo;
  final String processName;
  final String mtono;

  const ProcessWorkCardInfo({
    this.interId = 0,
    this.processNumber = '',
    this.factoryName = '',
    this.date = '',
    this.departId = 0,
    this.departName = '',
    this.productNumber = '',
    this.packag = '',
    this.cardNo = '',
    this.reportStatus = 0,
    this.batchNo = '',
    this.processName = '',
    this.mtono = '',
  });

  factory ProcessWorkCardInfo.fromJson(Map<String, dynamic> json) =>
      ProcessWorkCardInfo(
        interId: JsonParse.toInt(json['InterID']),
        processNumber: JsonParse.str(json['ProcessNumber']),
        factoryName: JsonParse.str(json['FactoryName']),
        date: JsonParse.str(json['Date']),
        departId: JsonParse.toInt(json['DepartID']),
        departName: JsonParse.str(json['DepartName']),
        productNumber: JsonParse.str(json['ProductNumber']),
        packag: JsonParse.str(json['Packag']),
        cardNo: JsonParse.str(json['CardNo']),
        reportStatus: JsonParse.toInt(json['ReportStatus']),
        batchNo: JsonParse.str(json['BatchNo']),
        processName: JsonParse.str(json['ProcessName']),
        mtono: JsonParse.str(json['Mtono']),
      );

  Map<String, dynamic> toJson() => {
        'InterID': interId,
        'ProcessNumber': processNumber,
        'FactoryName': factoryName,
        'Date': date,
        'DepartID': departId,
        'DepartName': departName,
        'ProductNumber': productNumber,
        'Packag': packag,
        'CardNo': cardNo,
        'ReportStatus': reportStatus,
        'BatchNo': batchNo,
        'ProcessName': processName,
        'Mtono': mtono,
      };
}

/// 部件项（ComponentList 元素）
class ComponentItem {
  final int itemId;
  final String pictureUrl;
  final List<String> includesProcess;
  final String componentName;
  final String componentNo;
  final List<String> processList;
  final List<MaterialItem> materialList;

  const ComponentItem({
    this.itemId = 0,
    this.pictureUrl = '',
    this.includesProcess = const [],
    this.componentName = '',
    this.componentNo = '',
    this.processList = const [],
    this.materialList = const [],
  });

  factory ComponentItem.fromJson(Map<String, dynamic> json) => ComponentItem(
        itemId: JsonParse.toInt(json['ItemID']),
        pictureUrl: JsonParse.str(json['PictureUrl']),
        includesProcess: JsonParse.strList(json['IncludesProcess']),
        componentName: JsonParse.str(json['ComponentName']),
        componentNo: JsonParse.str(json['Componentno']),
        processList: JsonParse.strList(json['ProcessList']),
        materialList:
            JsonParse.list(json['MaterialList'], MaterialItem.fromJson),
      );

  /// 工序纯文本（用 → 连接、不含颜色），用于日志、复制等场景
  String get processTextPlain => processList.join(' → ');

  Map<String, dynamic> toJson() => {
        'ItemID': itemId,
        'PictureUrl': pictureUrl,
        'IncludesProcess': includesProcess,
        'ComponentName': componentName,
        'Componentno': componentNo,
        'ProcessList': processList,
        'MaterialList': materialList.map((e) => e.toJson()).toList(),
      };

  /// 工序文本控件：将 [processList] 各项用「 → 」连接（箭头为灰色）；
  /// 若某项同时存在于 [includesProcess] 中，则该项显示为绿色，否则为黑色。
  Widget getProcessText() {
    const blackTextStyle = TextStyle(
      fontWeight: FontWeight.bold,
      color: Colors.black87,
    );
    const greenTextStyle = TextStyle(
      fontWeight: FontWeight.bold,
      color: Colors.green,
    );
    const grayTextStyle = TextStyle(
      fontWeight: FontWeight.bold,
      color: Colors.grey,
    );
    return Text.rich(
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      TextSpan(
        children: [
          for (var i = 0; i < processList.length; i++) ...[
            // 除第一项外，先补一个灰色右箭头分隔符
            if (i > 0) const TextSpan(text: ' → ', style: grayTextStyle),
            TextSpan(
              text: processList[i],
              style: includesProcess.contains(processList[i])
                  ? greenTextStyle
                  : blackTextStyle,
            ),
          ],
        ],
      ),
    );
  }
}

/// 物料项（MaterialList 元素）
class MaterialItem {
  final int materialID;
  final String materialNo;
  final String materialName;
  final String unit;
  final double ingredients;

  const MaterialItem({
    this.materialID = 0,
    this.materialNo = '',
    this.materialName = '',
    this.unit = '',
    this.ingredients = 0,
  });

  factory MaterialItem.fromJson(Map<String, dynamic> json) => MaterialItem(
        materialID: JsonParse.toInt(json['MaterialID']),
        materialNo: JsonParse.str(json['MaterialNo']),
        materialName: JsonParse.str(json['MaterialName']),
        unit: JsonParse.str(json['Unit']),
        ingredients: JsonParse.toDouble(json['Ingredients']),
      );

  Map<String, dynamic> toJson() => {
        'MaterialID': materialID,
        'MaterialNo': materialNo,
        'MaterialName': materialName,
        'Unit': unit,
        'Ingredients': ingredients,
      };

  /// 物料展示文本，格式：`(物料编码) 物料名称 <用量单位>`
  String get materialText => '($materialNo) $materialName <$ingredients$unit>';
}

/// 已派工项（DispatchedList 元素）
class DispatchedItem {
  final int itemId;
  final String number;
  final String name;
  final String avatarPath;
  final String size;

  const DispatchedItem({
    this.itemId = 0,
    this.number = '',
    this.name = '',
    this.avatarPath = '',
    this.size = '',
  });

  factory DispatchedItem.fromJson(Map<String, dynamic> json) => DispatchedItem(
        itemId: JsonParse.toInt(json['ItemID']),
        number: JsonParse.str(json['Number']),
        name: JsonParse.str(json['Name']),
        avatarPath: JsonParse.str(json['AvatarPath']),
        size: JsonParse.str(json['Size']),
      );

  Map<String, dynamic> toJson() => {
        'ItemID': itemId,
        'Number': number,
        'Name': name,
        'AvatarPath': avatarPath,
        'Size': size,
      };
}

/// 尺码数量（SizeList 元素）
///
/// 纯数据对象：不含响应式状态，该尺码下已分配的员工由
/// [GroupDispatchState.dispatchMap] 按尺码维护。
class SizeInfo {
  final String size;
  final double totalQty;

  const SizeInfo({
    this.size = '',
    this.totalQty = 0,
  });

  factory SizeInfo.fromJson(Map<String, dynamic> json) => SizeInfo(
        size: JsonParse.str(json['Size']),
        totalQty: JsonParse.toDouble(json['TotalQty']),
      );

  Map<String, dynamic> toJson() => {
        'Size': size,
        'TotalQty': totalQty,
      };

  /// 提交派工时的数据：尺码、数量，以及该尺码下所有员工 ID（逗号分隔）
  ///
  /// [workers] 该尺码下已分配的员工列表
  Map<String, dynamic> getSubmitData(List<DispatchedItem> workers) =>
      <String, dynamic>{
        'Size': size,
        'TotalQty': totalQty,
        'EmpID': workers.map((v) => v.itemId).toList(),
      };
}
