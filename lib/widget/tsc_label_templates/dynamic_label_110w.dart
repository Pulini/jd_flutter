import 'package:flutter/material.dart';
import 'package:jd_flutter/utils/extension_util.dart';
import 'package:jd_flutter/utils/utils.dart';
import 'package:qr_flutter/qr_flutter.dart';

var _border = BoxDecoration(border: Border.all(color: Colors.black, width: 1));
var _textStyle = const TextStyle(fontWeight: FontWeight.bold, fontSize: 17);
var _bigStyle = const TextStyle(fontSize: 22, fontWeight: FontWeight.bold);
var _smallStyle = const TextStyle(
  fontSize: 12,
  fontWeight: FontWeight.bold,
  height: 0,
);
var _textPadding = const EdgeInsets.only(left: 3, right: 3);

Widget _paddingTextLeft({
  required String text,
  required int flex,
  TextStyle? style,
  EdgeInsetsGeometry? padding,
}) {
  var container = Container(
    decoration: _border,
    padding: padding ?? _textPadding,
    alignment: Alignment.centerLeft,
    child: Text(text, style: style ?? _textStyle),
  );
  return flex == 0 ? container : Expanded(flex: flex, child: container);
}

Widget _paddingTextCenter({
  required String text,
  required int flex,
  TextStyle? style,
}) {
  var container = Container(
    decoration: _border,
    padding: _textPadding,
    alignment: Alignment.center,
    child: text.isNullOrEmpty()
        ? null
        : Text(
            text,
            style: style ?? _textStyle,
            textAlign: TextAlign.center,
          ),
  );
  return flex == 0 ? container : Expanded(flex: flex, child: container);
}

IntrinsicHeight _createRowText({
  required String title,
  AlignmentGeometry? titleAlignment,
  int flex = 5,
  TextStyle? style,
  EdgeInsetsGeometry? padding,
  required List<Widget> rw,
}) =>
    IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            flex: flex,
            child: Container(
              decoration: _border,
              padding: padding ?? _textPadding,
              alignment: titleAlignment ?? Alignment.centerLeft,
              child: Text(
                title,
                style: style ?? _textStyle,
              ),
            ),
          ),
          ...rw
        ],
      ),
    );

List<Widget> _createSizeList({
  required Map<String, List> list,
  TextStyle? style,
}) {
  frameText({
    int flex = 1,
    Alignment alignment = Alignment.centerLeft,
    required String text,
  }) =>
      Expanded(
        flex: flex,
        child: Container(
          decoration: _border,
          alignment: alignment,
          child: Text(
            maxLines: 1,
            text,
            style: style ?? _textStyle,
            strutStyle: const StrutStyle(forceStrutHeight: true, leading: 0.8),
            textAlign: TextAlign.center,
          ),
        ),
      );

  var tableList = <Widget>[];
  if (list.isNotEmpty) {
    int max = 5;
    final maxColumns = (list.values.toList()[0].length / max).ceil();
    for (int i = 0; i < maxColumns; i++) {
      //轮次
      list.forEach((ins, data) {
        var line = <Widget>[];
        //添加表格第一列指令列
        line.add(frameText(flex: 2, text: ins));

        var sizeList = data.sublist(0, data.length - 1);
        var start = i * max;
        var surplus = sizeList.length - start;
        var to = surplus > max ? start + max : start + surplus;
        for (var j = start; j < to; ++j) {
          //添加尺码列
          line.add(frameText(
            alignment: Alignment.center,
            text: sizeList[j],
          ));
        }
        var fill = max - ((to + 1) - start);
        if (fill > 0) {
          //如果数据不足Max列，则填充空白列
          line.add(Expanded(
            flex: max - ((to + 1) - start),
            child: Container(decoration: _border),
          ));
        }

        if (to - start < max) {
          //添加末尾列（合计）
          line.add(frameText(alignment: Alignment.center, text: data.last));
        }
        tableList.add(IntrinsicHeight(child: Row(children: line)));
      });
    }
  }
  return tableList;
}

Widget _labelContainer({required List<Widget> widgets}) => Container(
      color: Colors.white,
      width: 110 * 5.5,
      child: Padding(
        padding: const EdgeInsets.all(2 * 5.5),
        child: Container(
          decoration: _border,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: widgets,
          ),
        ),
      ),
    );

///动态格式 1098无尺码物料
///110 x N（高度由内容决定）
///物料列表格式 [['物料编码','物料规格','装箱数量','报关单位'],['物料编码','物料规格','装箱数量','报关单位']]
Widget dynamicMaterialLabel1098({
  required String labelID, //标签ID
  required String myanmarApprovalDocument, //缅甸批文
  required String typeBody, //工厂型体
  required String trackNo, //跟踪号
  required String instructionNo, //指令号
  required List<List> materialList, //物料列表
  required String customsDeclarationType, //报关形式
  required String pieceNo, //件数
  required String pieceID, //件号
  required String grossWeight, //毛重
  required String netWeight, //净重
  required String specifications, //规格
  required String volume, //体积
  required String supplier, //供应商
  required String manufactureDate, //生产日期
  required bool hasNotes, //是否打印备注行
  required String notes, //备注
}) =>
    _labelContainer(
      widgets: [
        _createRowText(
          title: 'Description:',
          rw: [_paddingTextLeft(text: myanmarApprovalDocument, flex: 15)],
        ),
        _createRowText(
          title: 'Style:',
          rw: [_paddingTextLeft(text: typeBody, flex: 15)],
        ),
        _createRowText(
          title: 'Lot No:',
          rw: [_paddingTextLeft(text: trackNo, flex: 15)],
        ),
        _createRowText(
          title: 'Order No:',
          rw: [_paddingTextLeft(text: instructionNo, flex: 15)],
        ),
        _createRowText(
          title: 'Mtl No:',
          rw: [
            _paddingTextCenter(text: 'Mtl Des.', flex: 5),
            _paddingTextCenter(text: 'Qty', flex: 5),
            _paddingTextCenter(text: 'Unit', flex: 5),
          ],
        ),
        for (var item in materialList)
          _createRowText(
            title: item.isNotEmpty ? item[0] : '',
            style: _bigStyle,
            rw: [
              _paddingTextCenter(
                text: item.length > 1 ? item[1] : '',
                style: _bigStyle,
                flex: 5,
              ),
              _paddingTextCenter(
                text: item.length > 2 ? item[2] : '',
                style: _bigStyle,
                flex: 5,
              ),
              _paddingTextCenter(
                text: item.length > 3 ? item[3] : '',
                style: _bigStyle,
                flex: 5,
              ),
            ],
          ),
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                flex: 15,
                child: Column(
                  children: [
                    SizedBox(
                      height: 50,
                      child: Row(
                        children: [
                          _paddingTextLeft(text: 'Package No:', flex: 5),
                          _paddingTextCenter(text: pieceNo, flex: 10),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 50,
                      child: Row(
                        children: [
                          _paddingTextLeft(text: 'Gross Weight:', flex: 5),
                          _paddingTextLeft(text: grossWeight, flex: 5),
                          _paddingTextLeft(text: 'KGS', flex: 5),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 50,
                      child: Row(
                        children: [
                          _paddingTextLeft(text: 'Net Weight:', flex: 5),
                          _paddingTextLeft(text: netWeight, flex: 5),
                          _paddingTextLeft(text: 'KGS', flex: 5),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                flex: 5,
                child: Container(
                  decoration: _border,
                  child: Column(
                    children: [
                      SizedBox(
                        height: 130,
                        child: QrImageView(
                          data: labelID,
                          padding: const EdgeInsets.all(5),
                          version: QrVersions.auto,
                        ),
                      ),
                      Text(pieceID, style: _smallStyle),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        _createRowText(
          title: 'MEA.:(LxWxH)CM',
          rw: [
            _paddingTextCenter(text: specifications, flex: 5),
            _paddingTextCenter(text: volume, flex: 5),
            _paddingTextCenter(text: 'CBM', flex: 5),
          ],
        ),
        _createRowText(
          title: 'Tracing:',
          rw: [
            _paddingTextCenter(text: supplier, flex: 5),
            _paddingTextCenter(text: 'Production Date: MM-DD-YYYY', flex: 5),
            _paddingTextCenter(text: manufactureDate, flex: 5),
          ],
        ),
        if (hasNotes)
          _createRowText(
            title: 'Note:',
            rw: [_paddingTextCenter(text: notes, flex: 15)],
          ),
        Row(
          children: [
            _paddingTextCenter(text: ' MADE IN CHINA', flex: 15),
            _paddingTextCenter(text: customsDeclarationType, flex: 5)
          ],
        )
      ],
    );

///动态格式 1098尺码物料小标
///110 x N（高度由内容决定）
///物料列表格式 [['物料编码','物料规格'],['物料编码','物料规格'],['物料编码','物料规格']]
Widget dynamicSizeMaterialLabel1098({
  required String labelID, //标签ID
  required String myanmarApprovalDocument, //缅甸批文
  required String typeBody, //工厂型体
  required String trackNo, //跟踪号
  required Map<String, List> materialList, //物料列表
  required String instructionNo, //指令号
  required String materialCode, //物料编号
  required String size, //尺码
  required String inBoxQty, //装箱数
  required String customsDeclarationUnit, //报关单位
  required String customsDeclarationType, //报关形式
  required String pieceNo, //件数
  required String pieceID, //件号
  required String grossWeight, //毛重
  required String netWeight, //净重
  required String specifications, //规格
  required String volume, //体积
  required String supplier, //供应商
  required String manufactureDate, //生产日期
  required bool hasNotes, //是否打印备注行
  required String notes, //备注
}) =>
    _labelContainer(
      widgets: [
        _createRowText(
          title: 'Description:',
          rw: [_paddingTextLeft(text: myanmarApprovalDocument, flex: 15)],
        ),
        _createRowText(
          title: 'Style:',
          rw: [_paddingTextLeft(text: typeBody, flex: 15)],
        ),
        _createRowText(
          title: 'Lot No:',
          rw: [_paddingTextLeft(text: trackNo, flex: 15)],
        ),
        if (materialList.isEmpty)
          _createRowText(
            title: 'Order No:',
            rw: [_paddingTextLeft(text: instructionNo, flex: 15)],
          ),
        materialList.isNotEmpty
            ? _createRowText(
                title: 'Mtl No:',
                style: _bigStyle,
                rw: [
                  _paddingTextLeft(
                    style: _bigStyle,
                    text: materialCode,
                    flex: 15,
                  ),
                ],
              )
            : _createRowText(
                title: 'Mtl No:',
                style: _bigStyle,
                rw: [
                  _paddingTextCenter(
                    style: _bigStyle,
                    text: materialCode,
                    flex: 6,
                  ),
                  _paddingTextCenter(style: _bigStyle, text: 'Size', flex: 3),
                  _paddingTextCenter(style: _bigStyle, text: '$size#', flex: 6),
                ],
              ),
        if (materialList.isNotEmpty) ..._createSizeList(list: materialList),
        _createRowText(
          title: 'Quantity:',
          style: _bigStyle,
          rw: [
            _paddingTextCenter(style: _bigStyle, text: inBoxQty, flex: 6),
            _paddingTextCenter(
              style: _bigStyle,
              text: customsDeclarationUnit,
              flex: 3,
            ),
            _paddingTextCenter(
              style: _bigStyle,
              text: customsDeclarationType,
              flex: 6,
            ),
          ],
        ),
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                flex: 14,
                child: Column(
                  children: [
                    SizedBox(
                      height: 50,
                      child: Row(
                        children: [
                          _paddingTextLeft(text: 'Package No:', flex: 5),
                          _paddingTextCenter(text: pieceNo, flex: 9),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 50,
                      child: Row(
                        children: [
                          _paddingTextLeft(text: 'Gross Weight:', flex: 5),
                          _paddingTextCenter(text: grossWeight, flex: 6),
                          _paddingTextCenter(text: 'KGS', flex: 3),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 50,
                      child: Row(
                        children: [
                          _paddingTextLeft(text: 'Net Weight:', flex: 5),
                          _paddingTextCenter(text: netWeight, flex: 6),
                          _paddingTextCenter(text: 'KGS', flex: 3),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                flex: 6,
                child: Container(
                  decoration: _border,
                  child: Column(
                    children: [
                      SizedBox(
                        height: 130,
                        child: QrImageView(
                          data: labelID,
                          padding: const EdgeInsets.all(5),
                          version: QrVersions.auto,
                        ),
                      ),
                      Text(pieceID, style: _smallStyle),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        _createRowText(
          title: 'MEA.:(LxWxH)CM:',
          flex: 10,
          rw: [
            _paddingTextCenter(text: specifications, flex: 18),
            _paddingTextCenter(text: volume, flex: 5),
            _paddingTextCenter(text: 'CBM', flex: 7),
          ],
        ),
        _createRowText(
          title: 'Tracing:',
          flex: 10,
          rw: [
            _paddingTextCenter(text: supplier, flex: 12),
            _paddingTextCenter(text: 'Production Date: MM-DD-YYYY', flex: 11),
            _paddingTextCenter(text: manufactureDate, flex: 7),
          ],
        ),
        if (hasNotes)
          _createRowText(
            title: 'Note:',
            rw: [_paddingTextCenter(text: notes, flex: 15)],
          ),
        _paddingTextCenter(text: 'MADE IN CHINA', flex: 0)
      ],
    );

///动态格式物料外箱标
///110 x N（高度由内容决定）
///物料列表格式 [['物料编码','物料名称','数量','单位'],['物料编码','物料名称','数量','单位'],['物料编码','物料名称','数量','单位']]
Widget dynamicOutBoxLabel1095n1096({
  required String productName, //品名
  required String companyOrderType, //公司订单类型
  required String customsDeclarationType, //报关形式
  List<List>? materialList, //物料列表
  required String pieceNo, //件号
  required String grossWeight, //毛重
  required String netWeight, //净重
  required String qrCode, //二维码ID
  required String pieceID, //标签码ID
  required String specifications, //规格型号
  required String volume, //体积
  required String supplier, //供应商
  required String manufactureDate, //生产日期
  required String consignee, //收货方
  required bool hasNotes, //是否打印备注行
  required String notes, //备注
}) =>
    _labelContainer(
      widgets: [
        _createRowText(
          title: '品名/Product/Produk:',
          rw: [
            _paddingTextCenter(text: productName, flex: 10),
            _paddingTextCenter(text: companyOrderType, flex: 5),
          ],
        ),
        _createRowText(
          title: '加工贸易/PT/PP',
          rw: [
            _paddingTextCenter(text: customsDeclarationType, flex: 10),
            _paddingTextCenter(text: 'MADE IN CHINA', flex: 5),
          ],
        ),
        if (materialList != null && materialList.isNotEmpty)
          _createRowText(
            title: '物编/Mtl No/Nomor material',
            rw: [
              _paddingTextCenter(text: '物料描述/Mtl Des./Bahan Des', flex: 10),
              _paddingTextCenter(text: '数量/Qty/kuantitas', flex: 5),
            ],
          ),
        for (var item in materialList ?? [])
          _createRowText(
            title: item[0],
            rw: [
              _paddingTextCenter(text: item[1], flex: 10),
              _paddingTextCenter(text: item[2], flex: 3),
              _paddingTextCenter(text: item[3], flex: 2),
            ],
          ),
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                flex: 15,
                child: Column(
                  children: [
                    SizedBox(
                      height: 50,
                      child: Row(
                        children: [
                          _paddingTextLeft(text: '件号/Serial/Seri', flex: 5),
                          _paddingTextCenter(text: pieceNo, flex: 10),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 50,
                      child: Row(
                        children: [
                          _paddingTextLeft(text: '毛重/G.W/Berat Kotor', flex: 5),
                          _paddingTextCenter(text: grossWeight, flex: 5),
                          _paddingTextCenter(text: 'KGS', flex: 5),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 50,
                      child: Row(
                        children: [
                          _paddingTextLeft(
                              text: '净重/N.W/Berat Bersih', flex: 5),
                          _paddingTextCenter(text: netWeight, flex: 5),
                          _paddingTextCenter(text: 'KGS', flex: 5),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                flex: 5,
                child: Container(
                  decoration: _border,
                  child: Column(
                    children: [
                      SizedBox(
                        height: 130,
                        child: QrImageView(
                          data: qrCode,
                          padding: const EdgeInsets.all(5),
                          version: QrVersions.auto,
                        ),
                      ),
                      Text(pieceID, style: _smallStyle),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        _createRowText(
          title: '规格/MEA/Spesifikasi',
          rw: [
            _paddingTextCenter(text: specifications, flex: 10),
            _paddingTextCenter(text: volume, flex: 3),
            _paddingTextCenter(text: 'cbm', flex: 2),
          ],
        ),
        _createRowText(
          title: '供应商/Supplier/Pemasok',
          rw: [
            _paddingTextCenter(text: supplier, flex: 5),
            _paddingTextCenter(text: '生产日期/Manufact Date/Tanggal', flex: 5),
            _paddingTextCenter(text: manufactureDate, flex: 5),
          ],
        ),
        if (hasNotes)
          _createRowText(
            title: 'Note:',
            rw: [_paddingTextCenter(text: notes, flex: 15)],
          ),
        _createRowText(
          title: '收货方/Consignee/Penerima Barang',
          rw: [_paddingTextCenter(text: consignee, flex: 15)],
        ),
      ],
    );

///动态格式物料小标
///110 x N（高度由内容决定）
///物料列表格式 [['物料编码','物料名称','数量','单位'],['物料编码','物料名称','数量','单位'],['物料编码','物料名称','数量','单位']]
Widget dynamicInBoxLabel1095n1096({
  required String productName, //品名
  required String companyOrderType, //公司订单类型
  required String customsDeclarationType, //报关形式
  List<List>? materialList, //物料列表
  required String pieceNo, //件号
  required String qrCode, //二维码ID
  required String pieceID, //标签码ID
  required String supplier, //供应商
  required bool haveSupplier, //供应商
  required String manufactureDate, //生产日期
  required bool hasNotes, //是否打印备注行
  required String notes, //备注
}) =>
    _labelContainer(
      widgets: [
        _createRowText(
          title: '品名/Product/Produck',
          rw: [
            _paddingTextCenter(text: productName, flex: 10),
            _paddingTextCenter(text: companyOrderType, flex: 5),
          ],
        ),
        _createRowText(
          title: '加工贸易/PT/PP',
          rw: [
            _paddingTextCenter(text: customsDeclarationType, flex: 10),
            _paddingTextCenter(text: 'MADE IN CHINA', flex: 5),
          ],
        ),
        if (materialList != null && materialList.isNotEmpty)
          _createRowText(
            title: '物编/Mtl No/Nomor material',
            rw: [
              _paddingTextCenter(text: '物料描述/Mtl Des./Bahan Des', flex: 10),
              _paddingTextCenter(text: '数量/Qty/kuantitas', flex: 5),
            ],
          ),
        for (var item in (materialList ?? []))
          _createRowText(
            title: item[0],
            rw: [
              _paddingTextCenter(text: item[1], flex: 10),
              _paddingTextCenter(text: item.length > 2 ? item[2] : '', flex: 3),
              _paddingTextCenter(text: item.length > 3 ? item[3] : '', flex: 2),
            ],
          ),
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                flex: 15,
                child: Column(
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          _paddingTextLeft(text: '件号/Serial/Seri', flex: 5),
                          _paddingTextCenter(text: pieceNo, flex: 10),
                        ],
                      ),
                    ),
                    Expanded(
                      flex: 3,
                      child: Row(
                        children: [
                          _paddingTextLeft(
                            text: '生产日期/Production Date/Tanggal produksi',
                            flex: 5,
                          ),
                          _paddingTextCenter(text: manufactureDate, flex: 10),
                        ],
                      ),
                    ),
                    if (haveSupplier)
                      Expanded(
                        flex: 2,
                        child: Row(
                          children: [
                            _paddingTextLeft(
                              text: '供应商/Supplier/Pemasok',
                              flex: 5,
                            ),
                            _paddingTextCenter(text: supplier, flex: 10),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
              Expanded(
                flex: 5,
                child: Container(
                  decoration: _border,
                  child: Column(
                    children: [
                      SizedBox(
                        height: haveSupplier ? 130 : 110,
                        child: QrImageView(
                          data: qrCode,
                          padding: const EdgeInsets.all(5),
                          version: QrVersions.auto,
                        ),
                      ),
                      Text(
                        '$pieceID\n(小标)',
                        textAlign: TextAlign.center,
                        style: _smallStyle,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        if (hasNotes)
          _createRowText(
            title: 'Note:',
            rw: [_paddingTextCenter(text: notes, flex: 15)],
          ),
      ],
    );

///动态格式尺码物料标
///110 x N（高度由内容决定）
///物料列表格式 [['物料编码','物料名称','数量','单位'],['物料编码','物料名称','数量','单位'],['物料编码','物料名称','数量','单位']]
Widget dynamicSizeMaterialLabel1095n1096({
  required String labelID, //二维码ID
  required String productName, //品名
  required String orderType, //补单
  required String typeBody, //工厂型体
  required String trackNo, //跟踪号
  required String instructionNo, //指令
  required String generalMaterialNumber, //一般可配置物料
  required String materialDescription, //物料长描述
  required Map<String, List> materialList, //物料列表
  required String inBoxQty, //装箱数量
  required String customsDeclarationUnit, //报关单位
  required String customsDeclarationType, //报关形式
  required String pieceID, //件号
  required String pieceNo, //件数
  required String grossWeight, //毛重
  required String netWeight, //净重
  required String specifications, //规格型号
  required String volume, //体积
  required String supplier, //供应商
  required String manufactureDate, //生产日期
  required String consignee, //收货方
  required bool hasNotes, //是否打印备注行
  required String notes, //备注
}) =>
    _labelContainer(
      widgets: [
        _createRowText(
          title: '品名/Product/Produk',
          rw: [
            _paddingTextCenter(text: productName, flex: 10),
            _paddingTextCenter(text: orderType, flex: 5),
          ],
        ),
        _createRowText(
          title: '型体/Style/Bentuk',
          rw: [_paddingTextCenter(text: typeBody, flex: 15)],
        ),
        _createRowText(
          title: '批次/Lot No/Banyak No',
          rw: [_paddingTextCenter(text: trackNo, flex: 15)],
        ),
        if (instructionNo.isNotEmpty)
          _createRowText(
            title: '指令号/Order No/Pesanan No',
            rw: [_paddingTextCenter(text: instructionNo, flex: 15)],
          ),
        _createRowText(
          title: '物编/Mtl No/Nomor material',
          rw: [_paddingTextCenter(text: '物料描述/Mtl Des./Bahan Des', flex: 15)],
        ),
        _createRowText(
          title: generalMaterialNumber,
          style: _bigStyle,
          rw: [
            _paddingTextCenter(
              style: _bigStyle,
              text: materialDescription,
              flex: 15,
            )
          ],
        ),
        if (materialList.isNotEmpty) ..._createSizeList(list: materialList),
        _createRowText(
          title: '数量/Qty/kuantitas:',
          style: _bigStyle,
          rw: [
            _paddingTextCenter(style: _bigStyle, text: inBoxQty, flex: 5),
            _paddingTextCenter(
              style: _bigStyle,
              text: customsDeclarationUnit,
              flex: 5,
            ),
            _paddingTextCenter(
              style: _bigStyle,
              text: customsDeclarationType,
              flex: 5,
            ),
          ],
        ),
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                flex: 15,
                child: Column(
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          _paddingTextLeft(text: '件号/Serial/Seri', flex: 5),
                          _paddingTextCenter(text: pieceNo, flex: 10),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Row(
                        children: [
                          _paddingTextLeft(text: '毛重/G.W/Berat Kotor', flex: 5),
                          _paddingTextCenter(text: grossWeight, flex: 5),
                          _paddingTextCenter(text: 'KGS', flex: 5),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Row(
                        children: [
                          _paddingTextLeft(
                              text: '净重/N.W/Berat Bersih', flex: 5),
                          _paddingTextCenter(text: netWeight, flex: 5),
                          _paddingTextCenter(text: 'KGS', flex: 5),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                flex: 5,
                child: Container(
                  decoration: _border,
                  child: Column(
                    children: [
                      SizedBox(
                        height: 130,
                        child: QrImageView(
                          data: labelID,
                          padding: const EdgeInsets.all(5),
                          version: QrVersions.auto,
                        ),
                      ),
                      Text(pieceID, style: _smallStyle),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        _createRowText(
          title: '规格/MEA/Spesifikasi',
          rw: [
            _paddingTextCenter(text: specifications, flex: 10),
            _paddingTextCenter(text: volume, flex: 3),
            _paddingTextCenter(text: 'cbm', flex: 2),
          ],
        ),
        _createRowText(
          title: '供应商/Supplier/Pemasok',
          rw: [
            _paddingTextCenter(text: supplier, flex: 5),
            _paddingTextCenter(
                text: '生产日期/Production Date/Tanggal produksi', flex: 5),
            _paddingTextCenter(text: manufactureDate, flex: 5),
          ],
        ),
        if (hasNotes)
          _createRowText(
            title: 'Note:',
            rw: [_paddingTextCenter(text: notes, flex: 15)],
          ),
        _createRowText(
          title: '收货方/Consignee/Penerima Barang',
          rw: [
            _paddingTextCenter(text: consignee, flex: 10),
            _paddingTextCenter(text: 'MADE IN CHINA', flex: 5),
          ],
        ),
      ],
    );

///动态格式 国内物料标  单尺码 多尺码 无尺码
///
///110 x N（高度由内容决定）
///物料列表格式 [['物料编码','物料名称','数量','单位'],['物料编码','物料名称','数量','单位'],['物料编码','物料名称','数量','单位']]
Widget dynamicDomesticMaterialLabel({
  required String labelID, //二维码ID
  required String productName, //品名
  required String orderType, //补单
  required String
      materialNumber, //物料编码。单尺码标 传入 物料编号(MATNR) ,无尺码或多尺码 传入 一般可配置物料(SATNR)
  required String materialDescription, //物料描述
  required Map<String, List> materialList, //物料列表。多尺码 传入尺码列表map,单尺码或无尺码传空map{}
  required String inBoxQty, //装箱数量
  required String customsDeclarationUnit, //报关单位
  required String customsDeclarationType, //报关形式
  required String pieceID, //件号
  required String pieceNo, //件数
  required String grossWeight, //毛重
  required String netWeight, //净重
  required String specifications, //规格型号
  required String volume, //体积
  required String supplierName, //供应商
  required String manufactureDate, //生产日期
  required String factoryWarehouse, //厂区 仓库
  required bool hasNotes, //是否打印备注行
  required String notes, //备注
}) =>
    _labelContainer(
      widgets: [
        _createRowText(
          title: '品名:',
          rw: [
            _paddingTextCenter(text: productName, flex: 10),
            _paddingTextCenter(text: orderType, flex: 5),
          ],
        ),
        _createRowText(
          title: '物编',
          rw: [_paddingTextCenter(text: '物料描述', flex: 15)],
        ),
        _createRowText(
          title: materialNumber,
          style: _bigStyle,
          padding: materialList.isEmpty ? const EdgeInsets.all(0) : null,
          rw: [
            _paddingTextCenter(
              style: _bigStyle,
              text: materialDescription,
              flex: 15,
            )
          ],
        ),
        if (materialList.isNotEmpty)
          ..._createSizeList(
            list: materialList,
            style: _bigStyle,
          ),
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                flex: 15,
                child: Column(
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          _paddingTextLeft(
                            style: _bigStyle,
                            text: materialList.isNotEmpty ? '总数:' : '数量:',
                            flex: 5,
                          ),
                          _paddingTextCenter(
                            style: _bigStyle,
                            text: inBoxQty,
                            flex: 5,
                          ),
                          _paddingTextCenter(
                            style: _bigStyle,
                            text: customsDeclarationUnit,
                            flex: 5,
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Row(
                        children: [
                          _paddingTextLeft(text: '件号:', flex: 5),
                          _paddingTextCenter(text: pieceNo, flex: 10),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Row(
                        children: [
                          _paddingTextLeft(text: '毛重:', flex: 5),
                          _paddingTextCenter(text: grossWeight, flex: 5),
                          _paddingTextCenter(text: 'KGS', flex: 5),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Row(
                        children: [
                          _paddingTextLeft(text: '净重:', flex: 5),
                          _paddingTextCenter(text: netWeight, flex: 5),
                          _paddingTextCenter(text: 'KGS', flex: 5),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                flex: 5,
                child: Container(
                  decoration: _border,
                  child: Column(
                    children: [
                      SizedBox(
                        height: 130,
                        child: QrImageView(
                          data: labelID,
                          padding: const EdgeInsets.all(5),
                          version: QrVersions.auto,
                        ),
                      ),
                      Text(pieceID, style: _smallStyle),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        _createRowText(
          title: '规格:',
          rw: [
            _paddingTextCenter(text: specifications, flex: 5),
            _paddingTextCenter(text: volume, flex: 5),
            _paddingTextCenter(text: 'cbm', flex: 5),
          ],
        ),
        _createRowText(
          title: '供应商:',
          rw: [
            _paddingTextCenter(text: supplierName, flex: 10),
            _paddingTextCenter(text: '生产日期', flex: 5),
          ],
        ),
        _createRowText(
          title: '收货方:',
          rw: [
            _paddingTextCenter(text: factoryWarehouse, flex: 10),
            _paddingTextCenter(text: manufactureDate, flex: 5),
          ],
        ),
        if (hasNotes)
          _createRowText(
            title: 'Note:',
            rw: [_paddingTextCenter(text: notes, flex: 15)],
          ),
      ],
    );

///动态格式 国内物料标  单尺码 多尺码 无尺码
/// 标准物料清单  [['物料编码','单位',[件1数量,件2数量,...]],...]
/// 混装物料清单  [[['物料编码',数量,'单位'],['物料编码',数量,'单位']],...]
///110 x N（高度由内容决定）
Widget dynamicPalletDetail({
  required String palletNo, //托盘号
  required List<List> materialList, //标准物料清单
  required List<List> mixMaterialList, //混装物料清单
}) {
  var supBigStyle1 = const TextStyle(fontSize: 26, fontWeight: FontWeight.bold);
  var supBigStyle2 = const TextStyle(fontSize: 32, fontWeight: FontWeight.bold);
  var index = 1;
  var materialWidgetList = <Widget>[];
  for (var item in materialList) {
    materialWidgetList.add(_createRowText(
      title: index.toString(),
      titleAlignment: Alignment.center,
      style: _bigStyle,
      flex: 4,
      rw: [
        Expanded(
          flex: 26,
          child: Column(
            children: [
              Row(
                children: [
                  _paddingTextLeft(
                    text: (item[0] as String),
                    flex: 12,
                    style: supBigStyle1,
                  ),
                  _paddingTextCenter(
                    text: (item[2] as List).length.toString(),
                    flex: 4,
                    style: supBigStyle1,
                  ),
                  _paddingTextCenter(
                    text: (item[2] as List)
                        .map((v) => (v as double))
                        .reduce((a, b) => a.add(b))
                        .toShowString(),
                    flex: 6,
                    style: supBigStyle1,
                  ),
                  _paddingTextCenter(
                    text: (item[1] as String),
                    flex: 4,
                    style: supBigStyle1,
                  ),
                ],
              ),
              _paddingTextLeft(
                text: (item[2] as List)
                    .map((v) => (v as double).toShowString())
                    .join('  +  '),
                style: supBigStyle2,
                flex: 0,
              ),
            ],
          ),
        )
      ],
    ));
    index++;
  }
  var mixMaterialWidgetList = <Widget>[];
  for (var item in mixMaterialList) {
    materialWidgetList.add(_createRowText(
      title: '$index(混)',
      titleAlignment: Alignment.center,
      style: _bigStyle,
      flex: 4,
      rw: [
        Expanded(
          flex: 12,
          child: Column(
            children: [
              for (var line in item)
                _paddingTextLeft(
                  text: (line[0] as String),
                  flex: 0,
                  style: supBigStyle1,
                ),
            ],
          ),
        ),
        _paddingTextCenter(
          text: '1',
          flex: 4,
          style: supBigStyle1,
        ),
        Expanded(
          flex: 6,
          child: Column(
            children: [
              for (var line in item)
                _paddingTextCenter(
                  text: (line[1] as double).toShowString(),
                  flex: 0,
                  style: supBigStyle1,
                ),
            ],
          ),
        ),
        Expanded(
          flex: 4,
          child: Column(
            children: [
              for (var line in item)
                _paddingTextCenter(
                  text: (line[2] as String),
                  flex: 0,
                  style: supBigStyle1,
                ),
            ],
          ),
        ),
      ],
    ));
    index++;
  }

  return _labelContainer(
    widgets: [
      _createRowText(
        title: '托盘号',
        titleAlignment: Alignment.center,
        style: _bigStyle,
        flex: 4,
        rw: [
          _paddingTextCenter(
            text: palletNo,
            flex: 12,
            style: _bigStyle,
          ),
          _paddingTextCenter(
            text: '${userInfo?.name}(${getPrintTime()})',
            flex: 14,
          ),
        ],
      ),
      _createRowText(
        title: '序号',
        titleAlignment: Alignment.center,
        style: _bigStyle,
        flex: 4,
        rw: [
          _paddingTextCenter(
            text: '物料代码',
            flex: 12,
            style: _bigStyle,
          ),
          _paddingTextCenter(
            text: '件数',
            flex: 4,
            style: _bigStyle,
          ),
          _paddingTextCenter(
            text: '数量',
            flex: 6,
            style: _bigStyle,
          ),
          _paddingTextCenter(
            text: '单位',
            flex: 4,
            style: _bigStyle,
          ),
        ],
      ),
      ...materialWidgetList,
      ...mixMaterialWidgetList,
    ],
  );
}



List<Widget> getTableWidget({required List table}) {
  //尺码列数
  var column = 5;
  //表格头指令号
  String ins = table[0];
  //表格单码装数据
  List<Map<String, List<double>>> singleDataList = table[1];
  //表格单码装总数
  double singleListTotalQty = table[2];
  //表格单码装总件数
  int singleListTotalPiece = table[3];
  //表格混码装数据
  List<Map<String, List<List>>> mixDataList = table[4];
  //表格混码装总数
  double mixListTotalQty = table[5];
  //表格混码装总件数
  int mixListTotalPiece = table[6];
  //需要根据列数拆分成多少组
  var singleGroupCount = (singleDataList.length / column).ceil();
  //需要根据列数拆分成多少组
  var mixGroupCount = (mixDataList.length / column).ceil();

  //拆分重组单码装数据
  var singleDataGroupList = List.generate(
    singleGroupCount,
    (i) {
      var start = i * column;
      var end = (start + column < singleDataList.length)
          ? start + column
          : singleDataList.length;
      return singleDataList.sublist(start, end);
    },
  );
  //如果最后一组数据不足列数，则填充空数据
  for (var i = 0; i < singleGroupCount; i++) {
    if (singleDataGroupList[i].length < column) {
      singleDataGroupList[i].addAll(
        List.generate(
          column - singleDataGroupList[i].length,
          (index) => {},
        ),
      );
    }
  }

  List<Map<String, List<List<List>>>> mixDataGroupList = [];
  for (var piece in mixDataList) {
    var pieceNo = piece.keys.first;
    var sizeList = piece.values.first.toList();
    //拆分重组单码装数据
    var list =sizeList.length>column? List.generate(
      mixGroupCount,
      (i) {
        var start = i * column;
        var end = (start + column < sizeList.length)
            ? start + column
            : sizeList.length;
        return sizeList.sublist(start, end);
      },
    ):[sizeList];
    //如果最后一组数据不足列数，则填充空数据
    for (var i = 0; i < mixGroupCount; i++) {
      if (list[i].length < column) {
        list[i].addAll(
          List.generate(
            column - list[i].length,
            (index) => [],
          ),
        );
      }
    }
    list.removeWhere((v) =>
        v.every((v2) => v2.isEmpty || v2.last.toString().toDoubleTry() == 0));
    mixDataGroupList.add({pieceNo: list});
  }

  // logger.f(singleDataGroupList);
  // logger.f(mixDataGroupList);
  var singleMaterialWidget = IntrinsicHeight(
    child: Row(
      children: [
        _paddingTextCenter(text: '单', flex: 1,  style: _bigStyle,),
        Expanded(
          flex: 10,
          child: Column(
            children: [
              for (var item in singleDataGroupList)
                IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      for (var line in item)
                        Expanded(
                          flex: 2,
                          child: Column(
                            children: line.isEmpty||line.values.first.isEmpty
                                ? [
                                    _paddingTextCenter(text: '', flex: 1),
                                    _paddingTextCenter(text: '', flex: 1),
                                    _paddingTextCenter(text: '', flex: 1),
                                  ]
                                : [
                                    _paddingTextCenter(
                                      text: '${line.keys.first}#',
                                      flex: 1,
                                      style: _bigStyle,
                                    ),
                                    _paddingTextCenter(
                                      text: line.values.first.isEmpty
                                          ? ''
                                          : line.values.first
                                              .map((v) => v)
                                              .reduce((a, b) => a.add(b))
                                              .toShowString(),
                                      flex: 1,
                                      style: _bigStyle,
                                    ),
                                    _paddingTextCenter(
                                      text: line.values.first.isEmpty
                                          ? ''
                                          : line.values.first.length.toString(),
                                      flex: 1,
                                      style: _bigStyle,
                                    ),
                                  ],
                          ),
                        ),
                    ],
                  ),
                ),
            ],
          ),
        ),
        Expanded(
          flex: 2,
          child: Column(
            children: [
              _paddingTextCenter(
                text: '双数',
                flex: 0,
                style: _bigStyle,
              ),
              _paddingTextCenter(
                text: singleListTotalQty.toShowString(),
                flex: 1,
                style: _bigStyle,
              ),
            ],
          ),
        ),
        Expanded(
          flex: 2,
          child: Column(
            children: [
              _paddingTextCenter(
                text: '件数',
                flex: 0,
                style: _bigStyle,
              ),
              _paddingTextCenter(
                text: singleListTotalPiece.toString(),
                flex: 1,
                style: _bigStyle,
              ),
            ],
          ),
        ),
      ],
    ),
  );
  var mixMaterialWidget = IntrinsicHeight(
    child: Row(
      children: [
        _paddingTextCenter(text: '混', flex: 1,  style: _bigStyle,),
        Expanded(
          flex: 14,
          child: Column(
            children: [
              for (var item in mixDataGroupList)
                IntrinsicHeight(
                  child: Row(
                    children: [
                      Expanded(
                        flex: 10,
                        child: Column(
                          children: [
                            for (var line in item.values.first) ...[
                              IntrinsicHeight(
                                child: Row(
                                  children: [
                                    for (var sub in line)
                                      _paddingTextCenter(
                                        text: sub.isEmpty ||
                                                sub.last
                                                        .toString()
                                                        .toDoubleTry() ==
                                                    0
                                            ? ''
                                            : '${sub.first}#',
                                        flex: 2,
                                        style: _bigStyle,
                                      ),
                                  ],
                                ),
                              ),
                              IntrinsicHeight(
                                child: Row(
                                  children: [
                                    for (var sub in line)
                                      _paddingTextCenter(
                                        text: sub.isEmpty
                                            ? ''
                                            : (sub.last as double) == 0
                                                ? ''
                                                : (sub.last as double)
                                                    .toShowString(),
                                        flex: 2,
                                        style: _bigStyle,
                                      ),
                                  ],
                                ),
                              ),
                            ]
                          ],
                        ),
                      ),
                      _paddingTextCenter(
                        text: item.values
                            .toList()
                            .map((v) => v.first
                                .map((v2) => v2.isEmpty
                                    ? 0.0
                                    : v2.last.toString().toDoubleTry())
                                .reduce((a, b) => a.add(b)))
                            .reduce((a, b) => a.add(b))
                            .toShowString(),
                        flex: 2,
                        style: _bigStyle,
                      ),
                      _paddingTextCenter(
                        text: '1',
                        flex: 2,
                        style: _bigStyle,
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ],
    ),
  );
  return [
    _createRowText(
      title: '指令号',
      titleAlignment: Alignment.center,
      style: _bigStyle,
      flex: 3,
      rw: [
        _paddingTextCenter(
          text: ins,
          flex: 12,
          style: _bigStyle,
        ),
      ],
    ),
    //单码装表格
    singleMaterialWidget,
    //混码装表格
    mixMaterialWidget,
    _createRowText(
      title: '小计',
      titleAlignment: Alignment.center,
      style: _bigStyle,
      flex: 11,
      rw: [
        _paddingTextCenter(
          text: singleListTotalQty.add(mixListTotalQty).toShowString(),
          flex: 2,
          style: _bigStyle,
        ),
        _paddingTextCenter(
          text: (singleListTotalPiece + mixListTotalPiece).toString(),
          flex: 2,
          style: _bigStyle,
        ),
      ],
    ),
    Container(
      decoration: _border,
      height: 10,
    )
  ];
}

///动态格式 国内物料标  单尺码 多尺码 无尺码
/// 表格列表
///110 x N（高度由内容决定）
Widget dynamicPalletSizeMaterialDetail({
  required String palletNo, //托盘号
  required List<List> tableList, //表格列表
}) {
  return _labelContainer(
    widgets: [
      _createRowText(
        title: '托盘号',
        titleAlignment: Alignment.center,
        style: _bigStyle,
        flex: 3,
        rw: [
          _paddingTextCenter(
            text: palletNo,
            flex: 6,
            style: _bigStyle,
          ),
          _paddingTextCenter(
            text: '${userInfo?.name}(${getPrintTime()})',
            flex: 6,
          ),
        ],
      ),
      for (var table in tableList) ...[
        ...getTableWidget(table: table),
      ],
      _createRowText(
        title: '合计',
        titleAlignment: Alignment.center,
        style: _bigStyle,
        flex: 11,
        rw: [
          _paddingTextCenter(
            text: tableList
                .map((v) => (v[2] as double).add((v[5] as double)))
                .reduce((a, b) => a.add(b))
                .toShowString(),
            style: _bigStyle,
            flex: 2,
          ),
          _paddingTextCenter(
            text: tableList
                .map((v) => (v[3] as int) + (v[6] as int))
                .reduce((a, b) => a + b)
                .toString(),
            style: _bigStyle,
            flex: 2,
          ),
        ],
      ),
    ],
  );
}
