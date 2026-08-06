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

// 去除小数尾部多余的 0：0.035000 -> 0.035，12.000 -> 12；非数字或整数保持不变
String _trimTrailingZeros(String? text) {
  if (text == null || text.isEmpty) return '';
  if (!text.contains('.')) return text;
  var s = text;
  while (s.length > 1 && s.endsWith('0')) {
    s = s.substring(0, s.length - 1);
  }
  if (s.endsWith('.')) s = s.substring(0, s.length - 1);
  return s;
}

Widget _paddingTextLeft({
  required String text,
  required int flex,
  TextStyle? style,
  EdgeInsets? padding,
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
  EdgeInsets? padding,
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
  int headerFlex = 2,
  bool repeatHeader = true,
  bool centerInstruction = false, //印尼标(1095)：指令列居中
  bool alignSegments = false, //印尼标(1095)：多段尺码时各行对齐（修正填充 off-by-one）
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
    // 一行最多放 7 个尺码（印尼标每箱最多混装 7 个尺码，故一行恰好能放下）
    const int max = 7;
    // 本行尺码区的固定槽位数：repeatHeader==true 时末段还要画合计列，统一多留 1 格保证各段列宽一致
    final int slots = repeatHeader ? max + 1 : max;
    // 首列(尺码/指令列)宽度：
    // repeatHeader==false(印尼标) 换算到与顶部 _createRowText 相同的份制(字段名 5 : 内容 15，共 20 份)，
    // 使首列恒定占 headerFlex/20，不随本行实际尺码个数而伸缩；
    // repeatHeader==true 保持原比例，不影响既有模板。
    final int needFlex = repeatHeader ? headerFlex : headerFlex * slots;
    final int cellFlex = repeatHeader ? 1 : (20 - headerFlex);
    // 去掉末尾合计项后再算段数，避免 5 尺码(6列)被算成 2 段而产生空行
    final maxColumns = ((list.values.toList()[0].length - 1) / max).ceil();
    for (int i = 0; i < maxColumns; i++) {
      //轮次
      list.forEach((ins, data) {
        var line = <Widget>[];
        //添加表格第一列指令列
        line.add(frameText(
          flex: needFlex,
          text: ins,
          alignment: centerInstruction ? Alignment.center : Alignment.center,
        ));

        var sizeList = data.sublist(0, data.length - 1);
        var start = i * max;
        var surplus = sizeList.length - start;
        var to = surplus > max ? start + max : start + surplus;
        for (var j = start; j < to; ++j) {
          //添加尺码列
          line.add(frameText(
            flex: cellFlex,
            alignment: Alignment.center,
            text: sizeList[j],
          ));
        }
        //如果尺码不足一整段，则填充空白列，保证首列宽度恒定、各段列宽一致
        //alignSegments=true（印尼标）：末段把尺码填到 max 格，非末段多留 1 格给"合计"位置，
        //使各段总 flex 一致、合计列不偏移；alignSegments=false 保持 1098 原行为。
        var fill = repeatHeader
            ? (alignSegments
                ? (i == maxColumns - 1
                    ? max - (to - start)
                    : max - (to - start) + 1)
                : max - ((to + 1) - start))
            : slots - (to - start);
        if (fill > 0) {
          line.add(Expanded(
            flex: fill * cellFlex,
            child: Container(decoration: _border),
          ));
        }

        if (repeatHeader && i == maxColumns - 1) {
          //添加末尾列（合计）：仅最后一段且允许重复表头时绘制
          line.add(frameText(
            flex: cellFlex,
            alignment: Alignment.center,
            text: data.last,
          ));
        }
        tableList.add(IntrinsicHeight(child: Row(children: line)));
      });
    }
  }
  return tableList;
}

Widget _labelContainer({required List<Widget> widgets}) => Container(
      color: Colors.white,
      width: 100 * 5.5,
      height: 160 * 5.5,
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


///固定格式尺码物料标。金臻
///110 x 160（高度由内容决定）
///物料列表格式 [['物料编码','物料名称','数量','单位'],['物料编码','物料名称','数量','单位'],['物料编码','物料名称','数量','单位']]
Widget dynamicSizeMaterialLabel1095n1096height160({
  //印尼标
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
  bool repeatHeader = true, //是否重复表头/绘制合计列（默认原行为）
  int headerFlex = 2, //首列（指令/标题列）宽度
}) =>
    _labelContainer(
      widgets: [
        _createRowText(
          title: '品名/Product/Produk',
          flex: 6,
          rw: [
            _paddingTextCenter(text: productName, flex: 10),
            _paddingTextCenter(text: orderType, flex: 5),
          ],
        ),
        _createRowText(
          title: '型体/Style/Bentuk',
          flex: 6,
          rw: [_paddingTextCenter(text: typeBody, flex: 15)],
        ),
        _createRowText(
          title: '批次/Lot No/Banyak No',
          flex: 6,
          rw: [_paddingTextCenter(text: trackNo, flex: 15)],
        ),
        if (instructionNo.isNotEmpty)
          _createRowText(
            title: '指令号/Order No/Pesanan No',
            flex: 6,
            rw: [_paddingTextCenter(text: instructionNo, flex: 15)],
          ),
        _createRowText(
          title: '物编/Mtl No/Nomor material',
          flex: 6,
          rw: [_paddingTextCenter(text: '物料描述/Mtl Des./Bahan Des', flex: 15)],
        ),
        _createRowText(
          title: generalMaterialNumber,
          style: _bigStyle,
          flex: 6,
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
            repeatHeader: repeatHeader,
            headerFlex: headerFlex,
          ),
        _createRowText(
          title: '数量/Qty/kuantitas:',
          style: _bigStyle,
          flex: 6,
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
                flex: 16,
                child: Column(
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          _paddingTextLeft(text: '件号/Serial/Seri', flex: 6),
                          _paddingTextCenter(text: pieceNo, flex: 10),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Row(
                        children: [
                          _paddingTextLeft(text: '毛重/G.W/Berat Kotor', flex: 6),
                          _paddingTextCenter(text: grossWeight, flex: 5),
                          _paddingTextCenter(text: 'KGS', flex: 5),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Row(
                        children: [
                          _paddingTextLeft(
                              text: '净重/N.W/Berat Bersih', flex: 6),
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
                      Text(labelID, style: _smallStyle),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        _createRowText(
          title: '规格/MEA/Spesifikasi',
          flex: 6,
          rw: [
            _paddingTextCenter(text: specifications, flex: 10),
            _paddingTextCenter(text: _trimTrailingZeros(volume), flex: 3),
            _paddingTextCenter(text: 'cbm', flex: 2),
          ],
        ),
        _createRowText(
          title: '供应商/Supplier/Pemasok',
          flex: 6,
          rw: [
            _paddingTextCenter(text: supplier, flex: 5),
            _paddingTextCenter(
                text: '生产日期/Production Date/Tanggal produksi', flex: 5),
            _paddingTextCenter(text: manufactureDate, flex: 5),
          ],
        ),
        _createRowText(
          title: '收货方/Consignee/Penerima Barang',
          flex: 6,
          rw: [
            _paddingTextCenter(text: consignee, flex: 10),
            _paddingTextCenter(text: 'MADE IN CHINA', flex: 5),
          ],
        ),
      ],
    );

///固定格式 1098尺码物料小标
///110 x 160（高度由内容决定）
///物料列表格式 [['物料编码','物料规格'],['物料编码','物料规格'],['物料编码','物料规格']]
Widget dynamicSizeMaterialLabel1098height160({
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
            _paddingTextCenter(text: _trimTrailingZeros(volume), flex: 5),
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

