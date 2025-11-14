import 'package:flutter/material.dart';
import 'package:flutter/services.dart' as services;
import 'package:jd_flutter/utils/extension_util.dart';
import 'package:jd_flutter/utils/utils.dart';
import 'package:jd_flutter/utils/web_api.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

// 在函数开始处加载中文字体
Future<pw.Font> loadFont() async => pw.Font.ttf(
    await services.rootBundle.load('assets/fonts/SourceHanSansCN-Medium.ttf'));

/// 生成多页A4纸报表
/// paperTitle 单据标题
/// orderType  工单类型
/// palletNumber 托盘号
/// sizeMaterialTable 尺码物料表格数据
///     [
///        指令号(String),
///        单尺码装数据(List),
///        单尺码装总货数(double),
///        单尺码装总件数(int),
///        混码装数据(List),
///        混码装总货数(double),
///        混码装总件数(int),
///     ]
///      单尺码装数据(List)：[{ 尺码: [件货数]}]
///     [
///          { 4.5: [20.0, 20.0] },
///          { 5: [20.0, 20.0] },
///          { 5.5: [20.0] }
///     ]
///      混码装数据(List)：[ { 件码: [ [尺码,数量],[尺码,数量],[尺码,数量]]} ]
///     [
///          { 25092000000013:
///            [
///              [3, 25.0], [4, 25.0], [5, 25.0], [5.5, 25.0],
///            ]
///          },
///          { 25092000000014:
///            [
///              [6.5, 10.0], [7, 10.0]
///            ]
///          },
///          { 25092000000015:
///            [
///              [3, 20.0], [3.5, 20.0], [4, 20.0]
///            ]
///          }
///     ]
/// materialTable  物料表格数据
/// [
///   [
///     物料代码,
///     单位,
///     [10,20,30,20],
///   ],
///   [
///     物料代码,
///     单位,
///     [10,20,30,20],
///   ],
/// ]
Future<List<pw.Widget>> createA4PaperMaterialListPdf({
  required String paperTitle,
  required String factoryName,
  required String orderType,
  required String customsDeclarationType,
  required String palletNumber,
  required List<List> sizeMaterialTable,
  required List<List> materialTable,
}) async {
  var font = await loadFont();
  double paperWidth = 595; //A4纸宽度
  double paperHeight = 842; //A4纸高度
  double paperPadding = 20; //边距
  double paperTitleHeight = 70; //表头高度
  double paperFooterHeight = 20; //底部分页行高度
  //表格高度
  double tableHeight =
      paperHeight - paperTitleHeight - paperFooterHeight - paperPadding * 2;
  //表格宽度
  double tableWidth = paperWidth - paperPadding * 2;

  //控件列表
  var widgetList = <List>[];
  //表格单码装总数
  double singleListTotalQty = 0.0;
  //表格单码装总件数
  int singleListTotalPiece = 0;
  //表格混码装总数
  double mixListTotalQty = 0.0;
  //表格混码装总件数
  int mixListTotalPiece = 0;

  for (var sub in sizeMaterialTable) {
    _createSizeMaterialTable(
      font: font,
      tableData: sub,
      callback: (tableWidget, height) => widgetList.add([height, tableWidget]),
    );
    singleListTotalQty = singleListTotalQty.add((sub[2] as double));
    singleListTotalPiece += (sub[3] as int);
    mixListTotalQty = mixListTotalQty.add((sub[5] as double));
    mixListTotalPiece += (sub[6] as int);
  }
  //根据指令大小进行排序
  widgetList.sort((a, b) => (a.first as int).compareTo((b.first as int)));
  //末尾合计行
  widgetList.add([
    20,
    pw.Container(
      decoration: const pw.BoxDecoration(
        border: pw.Border(
          left: pw.BorderSide(color: PdfColors.black, width: 1),
          bottom: pw.BorderSide(color: PdfColors.black, width: 1),
          right: pw.BorderSide(color: PdfColors.black, width: 1),
        ),
      ),
      child: pw.Row(children: [
        _borderText(font: font, text: '合计', flex: 37),
        _borderText(
          font: font,
          text: singleListTotalQty.add(mixListTotalQty).toShowString(),
          flex: 5,
        ),
        _borderText(
          font: font,
          text: (singleListTotalPiece + mixListTotalPiece).toString(),
          flex: 5,
        ),
      ]),
    )
  ]);

  if (materialTable.isNotEmpty) {
    widgetList.add([30, pw.SizedBox(height: 30)]);
    widgetList.add([
      20,
      pw.Container(
        decoration: const pw.BoxDecoration(
          border: pw.Border(
            left: pw.BorderSide(color: PdfColors.black, width: 1),
            top: pw.BorderSide(color: PdfColors.black, width: 1),
            right: pw.BorderSide(color: PdfColors.black, width: 1),
          ),
        ),
        child: pw.Row(children: [
          _borderText(font: font, text: '序号', flex: 2),
          _borderText(font: font, text: '物料代码', flex: 16),
          _borderText(font: font, text: '件数', flex: 2),
          _borderText(font: font, text: '数量', flex: 5),
          _borderText(font: font, text: '单位', flex: 2),
        ]),
      ),
    ]);
  }
  for (var i = 0; i < materialTable.length; ++i) {
    _createMaterialTable(
      font: font,
      index: i,
      tableWidth: tableWidth,
      tableData: materialTable[i],
      callback: (tableWidget, height) => widgetList.add([height, tableWidget]),
    );
  }

  logger.f(widgetList);

  var paperList = <pw.Widget>[]; //纸张列表
  List<List<pw.Widget>> pages = [];
  List<pw.Widget> currentPage = [];
  int currentPageHeight = 0;

  for (var widgetItem in widgetList) {
    int widgetHeight = widgetItem[0] as int;
    pw.Widget widget = widgetItem[1] as pw.Widget;

    // 如果当前控件加入后会超出页面高度
    if (currentPageHeight + widgetHeight > tableHeight) {
      // 保存当前页
      if (currentPage.isNotEmpty) {
        pages.add(List<pw.Widget>.from(currentPage));
      }
      // 开始新页面
      currentPage = [widget];
      currentPageHeight = widgetHeight;
    } else {
      // 添加到当前页
      currentPage.add(widget);
      currentPageHeight += widgetHeight;
    }
  }

  // 添加最后一页
  if (currentPage.isNotEmpty) {
    pages.add(currentPage);
  }

// 然后为每组创建纸张
  for (int i = 0; i < pages.length; i++) {
    paperList.add(_createPaper(
      paperPadding: paperPadding,
      font: font,
      paperWidth: paperWidth,
      paperHeight: paperHeight,
      tableTitleHeight: paperTitleHeight,
      tableFooterHeight: paperFooterHeight,
      palletNumber: palletNumber,
      title: paperTitle,
      factoryName: factoryName,
      orderType: orderType,
      customsDeclarationType: customsDeclarationType,
      qrCode: palletNumber,
      item: pages[i],
      page: i + 1,
      totalPage: pages.length,
    ));
  }
  return paperList;
}

/// 创建A4纸报表
/// paperWidth  纸张宽度
/// paperHeight 纸张高度
/// tablePadding  表格边距
/// tableTitleHeight  标题头高度
/// tableFooterHeight 结尾页码高度
/// palletNumber  托盘编号
/// title 标题文本
/// factoryName 原料工厂名称
/// orderType 单据类型
/// customsDeclarationType 报关形式
/// qrCode  二维码内容
/// item  表格行块
/// page  当前页码
/// totalPage 总页数
pw.Widget _createPaper({
  required pw.Font font,
  required double paperPadding,
  required double paperWidth,
  required double paperHeight,
  required double tableTitleHeight,
  required double tableFooterHeight,
  required String palletNumber,
  required String title,
  required String factoryName,
  required String orderType,
  required String customsDeclarationType,
  required String qrCode,
  required List<pw.Widget> item,
  required int page,
  required int totalPage,
}) =>
    pw.Container(
      padding: pw.EdgeInsets.all(paperPadding),
      width: paperWidth,
      height: paperHeight,
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.stretch,
        children: [
          pw.SizedBox(
            height: tableTitleHeight,
            child: pw.Stack(
              alignment: pw.Alignment.center,
              children: [
                pw.Positioned(
                  bottom: 25,
                  left: 0,
                  right: tableTitleHeight,
                  child: pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text(
                        customsDeclarationType,
                        style: pw.TextStyle(
                          fontSize: 15,
                          fontWeight: pw.FontWeight.bold,
                          font: font,
                        ),
                      ),
                      pw.Text(
                        '原料厂区：$factoryName',
                        style: pw.TextStyle(
                          fontSize: 15,
                          fontWeight: pw.FontWeight.bold,
                          font: font,
                        ),
                      ),
                      pw.Text(
                        orderType,
                        style: pw.TextStyle(
                          fontSize: 15,
                          fontWeight: pw.FontWeight.bold,
                          font: font,
                        ),
                      ),
                    ],
                  ),
                ),
                pw.Positioned(
                  top: 0,
                  child: pw.Text(
                    title,
                    style: pw.TextStyle(
                      fontSize: 20,
                      fontWeight: pw.FontWeight.bold,
                      font: font,
                    ),
                  ),
                ),
                pw.Positioned(
                  bottom: 5,
                  right: tableTitleHeight + paperPadding,
                  child: pw.Text(
                    '${userInfo?.name}(${getPrintTime()})',
                    style: pw.TextStyle(
                      fontSize: 10,
                      fontWeight: pw.FontWeight.bold,
                      font: font,
                    ),
                  ),
                ),
                pw.Positioned(
                  top: 0,
                  right: 0,
                  bottom: 5,
                  child: pw.SizedBox(
                      width: tableTitleHeight,
                      child: pw.Column(
                        mainAxisAlignment: pw.MainAxisAlignment.center,
                        children: [
                          pw.Expanded(
                            child: pw.BarcodeWidget(
                              data: qrCode,
                              barcode: pw.Barcode.qrCode(),
                            ),
                          ),
                          pw.Text(
                            palletNumber,
                            style: pw.TextStyle(
                              fontSize: 10,
                              fontWeight: pw.FontWeight.bold,
                              font: font,
                            ),
                          ),
                        ],
                      )),
                ),
              ],
            ),
          ),
          ...item,
          pw.Expanded(child: pw.Container()),
          pw.SizedBox(
            height: tableFooterHeight,
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.end,
              children: [
                pw.Text(
                  '$page / $totalPage',
                  style: pw.TextStyle(
                    fontWeight: pw.FontWeight.bold,
                    fontSize: 12,
                    font: font,
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );

///创建带边框的文本
/// text  文本内容
/// flex  Expanded占比
/// style 字体样式
/// titleAlignment  文本对齐方向
/// padding 文本框内边距
pw.Widget _borderText({
  required pw.Font font,
  required String text,
  int? flex,
  pw.TextStyle? style,
  pw.Alignment? titleAlignment,
  pw.EdgeInsets? padding,
}) {
  var widget = pw.Container(
    height: 20,
    decoration: pw.BoxDecoration(
      border: pw.Border.all(color: PdfColors.black, width: 1),
    ),
    padding: padding ?? const pw.EdgeInsets.only(left: 3, right: 3),
    alignment: titleAlignment ?? pw.Alignment.center,
    child: pw.Text(
      text,
      style: style ??
          pw.TextStyle(
            fontWeight: pw.FontWeight.bold,
            fontSize: 12,
            font: font,
          ),
    ),
  );
  return flex == null ? widget : pw.Expanded(flex: flex, child: widget);
}

/// 创建尺码物料表格
/// tableData: 表格数据
/// sizeMaterialTable 尺码物料表格数据：
///     [
///        指令号(String),
///        单尺码装数据(List),
///        单尺码装总货数(double),
///        单尺码装总件数(int),
///        混码装数据(List),
///        混码装总货数(double),
///        混码装总件数(int),
///     ]
///      单尺码装数据(List)：[{ 尺码: [件货数]}]
///     [
///          { 4.5: [20.0, 20.0] },
///          { 5: [20.0, 20.0] },
///          { 5.5: [20.0] }
///     ]
///      混码装数据(List)：[ { 件码: [ [尺码,数量],[尺码,数量],[尺码,数量]]} ]
///     [
///          { 25092000000013:
///            [
///              [3, 25.0], [4, 25.0], [5, 25.0], [5.5, 25.0],
///            ]
///          },
///          { 25092000000014:
///            [
///              [6.5, 10.0], [7, 10.0]
///            ]
///          },
///          { 25092000000015:
///            [
///              [3, 20.0], [3.5, 20.0], [4, 20.0]
///            ]
///          }
///     ]
/// callback: 回调 表格widget 行数
void _createSizeMaterialTable({
  required pw.Font font,
  required List tableData,
  required Function(pw.Widget, int) callback,
}) {
  //尺码列数
  int column = 7;
  //表格头指令号
  String ins = tableData[0];
  //表格单码装数据
  List<Map<String, List<double>>> singleDataList = tableData[1];
  //表格单码装总数
  double singleListTotalQty = tableData[2];
  //表格单码装总件数
  int singleListTotalPiece = tableData[3];
  //表格混码装数据
  List<Map<String, List<List>>> mixDataList = tableData[4];
  //表格混码装总数
  double mixListTotalQty = tableData[5];
  //表格混码装总件数
  int mixListTotalPiece = tableData[6];
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
    var list = sizeList.length > column
        ? List.generate(
            mixGroupCount,
            (i) {
              var start = i * column;
              var end = (start + column < sizeList.length)
                  ? start + column
                  : sizeList.length;
              return sizeList.sublist(start, end);
            },
          )
        : [sizeList];

    //如果最后一组数据不足列数，则填充空数据
    for (var i = 0; i < mixGroupCount; i++) {
      if (list.first.length < column) {
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

  var singleMaterialWidget = singleDataGroupList.isEmpty
      ? pw.Container()
      : pw.SizedBox(
          height: singleDataGroupList.length * 20 * 3,
          child: pw.Row(
            children: [
              pw.Expanded(
                flex: 2,
                child: pw.Container(
                  decoration: pw.BoxDecoration(
                    border: pw.Border.all(color: PdfColors.black, width: 1),
                  ),
                  padding: const pw.EdgeInsets.only(left: 3, right: 3),
                  alignment: pw.Alignment.center,
                  child: pw.Text(
                    '单',
                    style: pw.TextStyle(
                      fontWeight: pw.FontWeight.bold,
                      fontSize: 12,
                      font: font,
                    ),
                  ),
                ),
              ),
              pw.Expanded(
                flex: column * 4,
                child: pw.Column(
                  children: [
                    for (var item in singleDataGroupList)
                      pw.SizedBox(
                          height: 20 * 3,
                          child: pw.Row(
                            crossAxisAlignment: pw.CrossAxisAlignment.stretch,
                            children: [
                              for (var line in item)
                                pw.Expanded(
                                  child: pw.Column(
                                    children: line.isEmpty ||
                                            line.values.first.isEmpty
                                        ? [
                                            _borderText(
                                                font: font, text: '', flex: 1),
                                            _borderText(
                                                font: font, text: '', flex: 1),
                                            _borderText(
                                                font: font, text: '', flex: 1),
                                          ]
                                        : [
                                            _borderText(
                                              font: font,
                                              text: '${line.keys.first}#',
                                              flex: 1,
                                            ),
                                            _borderText(
                                              font: font,
                                              text: line.values.first.isEmpty
                                                  ? ''
                                                  : line.values.first
                                                      .map((v) => v)
                                                      .reduce(
                                                          (a, b) => a.add(b))
                                                      .toShowString(),
                                              flex: 1,
                                            ),
                                            _borderText(
                                              font: font,
                                              text: line.values.first.isEmpty
                                                  ? ''
                                                  : line.values.first.length
                                                      .toString(),
                                              flex: 1,
                                            ),
                                          ],
                                  ),
                                ),
                            ],
                          )),
                  ],
                ),
              ),
              pw.Expanded(
                flex: 5,
                child: pw.Column(
                  children: [
                    _borderText(
                      font: font,
                      text: '双数',
                      flex: 0,
                    ),
                    _borderText(
                      font: font,
                      text: singleListTotalQty.toShowString(),
                      flex: 1,
                    ),
                  ],
                ),
              ),
              pw.Expanded(
                flex: 5,
                child: pw.Column(
                  children: [
                    _borderText(
                      font: font,
                      text: '件数',
                      flex: 0,
                    ),
                    _borderText(
                      font: font,
                      text: singleListTotalPiece.toString(),
                      flex: 1,
                    ),
                  ],
                ),
              ),
            ],
          ));

  var mixMaterialWidget = mixDataGroupList.isEmpty
      ? pw.Container()
      : pw.SizedBox(
          height: mixDataGroupList.length * 20 * 2,
          child: pw.Row(
            children: [
              pw.Expanded(
                flex: 2,
                child: pw.Container(
                  decoration: pw.BoxDecoration(
                    border: pw.Border.all(color: PdfColors.black, width: 1),
                  ),
                  padding: const pw.EdgeInsets.only(left: 3, right: 3),
                  alignment: pw.Alignment.center,
                  child: pw.Text(
                    '混',
                    style: pw.TextStyle(
                      fontWeight: pw.FontWeight.bold,
                      fontSize: 12,
                      font: font,
                    ),
                  ),
                ),
              ),
              pw.Expanded(
                flex: column * 4 + 5 * 2,
                child: pw.Column(
                  children: [
                    for (var item in mixDataGroupList)
                      pw.SizedBox(
                          height: 20 * 2,
                          child: pw.Row(
                            children: [
                              pw.Expanded(
                                flex: column * 4,
                                child: pw.Column(
                                  children: [
                                    for (var line in item.values.first) ...[
                                      pw.Row(
                                        children: [
                                          for (var sub in line)
                                            _borderText(
                                              font: font,
                                              text: sub.isEmpty ||
                                                      sub.last
                                                              .toString()
                                                              .toDoubleTry() ==
                                                          0
                                                  ? ''
                                                  : '${sub.first}#',
                                              flex: 2,
                                            ),
                                        ],
                                      ),
                                      pw.Row(
                                        children: [
                                          for (var sub in line)
                                            _borderText(
                                              font: font,
                                              text: sub.isEmpty
                                                  ? ''
                                                  : (sub.last as double) == 0
                                                      ? ''
                                                      : (sub.last as double)
                                                          .toShowString(),
                                              flex: 2,
                                            ),
                                        ],
                                      )
                                    ]
                                  ],
                                ),
                              ),
                              pw.Expanded(
                                flex: 5,
                                child: pw.Container(
                                  decoration: pw.BoxDecoration(
                                    border: pw.Border.all(
                                        color: PdfColors.black, width: 1),
                                  ),
                                  padding: const pw.EdgeInsets.only(
                                      left: 3, right: 3),
                                  alignment: pw.Alignment.center,
                                  child: pw.Text(
                                    item.values
                                        .toList()
                                        .map((v) => v.first
                                            .map((v2) => v2.isEmpty
                                                ? 0.0
                                                : v2.last
                                                    .toString()
                                                    .toDoubleTry())
                                            .reduce((a, b) => a.add(b)))
                                        .reduce((a, b) => a.add(b))
                                        .toShowString(),
                                    style: pw.TextStyle(
                                      fontWeight: pw.FontWeight.bold,
                                      fontSize: 12,
                                      font: font,
                                    ),
                                  ),
                                ),
                              ),
                              pw.Expanded(
                                flex: 5,
                                child: pw.Container(
                                  decoration: pw.BoxDecoration(
                                    border: pw.Border.all(
                                        color: PdfColors.black, width: 1),
                                  ),
                                  padding: const pw.EdgeInsets.only(
                                      left: 3, right: 3),
                                  alignment: pw.Alignment.center,
                                  child: pw.Text(
                                    '1',
                                    style: pw.TextStyle(
                                      fontWeight: pw.FontWeight.bold,
                                      fontSize: 12,
                                      font: font,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ))
                  ],
                ),
              ),
            ],
          ));

  var tableWidget = pw.Container(
    decoration: const pw.BoxDecoration(
      border: pw.Border(
        left: pw.BorderSide(color: PdfColors.black, width: 1),
        right: pw.BorderSide(color: PdfColors.black, width: 1),
      ),
    ),
    child: pw.Column(
      children: [
        pw.SizedBox(
          height: (singleDataGroupList.length * 20 * 3) +
              (mixDataGroupList.length * 20 * 2),
          child: pw.Row(
            children: [
              pw.Expanded(
                flex: 7,
                child: pw.Column(
                  children: [
                    _borderText(font: font, text: '指令号'),
                    _borderText(font: font, text: ins, flex: 1),
                  ],
                ),
              ),
              pw.Expanded(
                flex: 40,
                child: pw.Column(
                  children: [
                    singleMaterialWidget,
                    mixMaterialWidget,
                  ],
                ),
              )
            ],
          ),
        ),
        pw.Row(children: [
          _borderText(font: font, text: '小计', flex: 37),
          _borderText(
            font: font,
            text: singleListTotalQty.add(mixListTotalQty).toShowString(),
            flex: 5,
          ),
          _borderText(
            font: font,
            text: (singleListTotalPiece + mixListTotalPiece).toString(),
            flex: 5,
          ),
        ]),
        pw.SizedBox(height: 5),
      ],
    ),
  );
  callback.call(
    tableWidget,
    //(单码每组3行 + 混码每组2行 + 1组小计) x 行高20 +行间距5
    (singleGroupCount * 3 + mixDataGroupList.length * 2 + 1) * 20 + 5,
  );
}

///创建物料表格
/// index 索引
/// tableWidth  表格宽度
/// tableData   表格数据
///   [
///       物料代码,
///       单位,
///       [10,20,30,20],
///   ],
/// callback: 回调 表格widget 行数
void _createMaterialTable({
  required pw.Font font,
  required int index,
  required double tableWidth,
  required List tableData,
  required Function(pw.Widget, int) callback,
}) {
  String materialCode = tableData.first;
  String unit = tableData[1];
  List<double> qtyList = tableData[2];
  double total = qtyList.map((v) => v).reduce((a, b) => a.add(b));
  double expandedWidth = (25 / 27) * tableWidth;
  String text = qtyList.map((v) => v.toShowString()).join(' + ');
  var sizeHeight =
      getTextSize(text: text, maxWidth: expandedWidth).height / 18 * 20;
  var tableItem = pw.Container(
    height: sizeHeight + 20,
    decoration: const pw.BoxDecoration(
      border: pw.Border(
        left: pw.BorderSide(color: PdfColors.black, width: 1),
        right: pw.BorderSide(color: PdfColors.black, width: 1),
      ),
    ),
    child: pw.Row(
      children: [
        pw.Expanded(
          flex: 2,
          child: pw.Container(
            decoration: pw.BoxDecoration(
              border: pw.Border.all(color: PdfColors.black, width: 1),
            ),
            padding: const pw.EdgeInsets.only(left: 3, right: 3),
            alignment: pw.Alignment.center,
            child: pw.Text(
              (index + 1).toString(),
              style: pw.TextStyle(
                fontWeight: pw.FontWeight.bold,
                fontSize: 12,
                font: font,
              ),
            ),
          ),
        ),
        pw.Expanded(
          flex: 25,
          child: pw.Column(
            children: [
              pw.SizedBox(
                height: 20,
                child: pw.Row(
                  children: [
                    _borderText(
                      font: font,
                      text: materialCode,
                      flex: 16,
                      titleAlignment: pw.Alignment.centerLeft,
                    ),
                    _borderText(
                      font: font,
                      text: qtyList.length.toString(),
                      flex: 2,
                    ),
                    _borderText(
                      font: font,
                      text: total.toShowString(),
                      flex: 5,
                    ),
                    _borderText(
                      font: font,
                      text: unit,
                      flex: 2,
                    ),
                  ],
                ),
              ),
              pw.Container(
                height: sizeHeight,
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: PdfColors.black, width: 1),
                ),
                padding: const pw.EdgeInsets.only(left: 3, right: 3),
                alignment: pw.Alignment.centerLeft,
                child: pw.Text(
                  text,
                  style: pw.TextStyle(
                    fontWeight: pw.FontWeight.bold,
                    fontSize: 12,
                    lineSpacing: 6,
                    font: font,
                  ),
                ),
              ),
            ],
          ),
        )
      ],
    ),
  );
  callback.call(tableItem, sizeHeight.toInt() + 20);
}

///获取文本尺寸
/// text  文本
/// maxWidth  最大宽度限制
/// style 字体样式
Size getTextSize({
  required String text,
  required double maxWidth,
  TextStyle? style,
}) {
  //pdf插件没有pw.TextPainter,只能根据原生的TextPainter获取尺寸，但存在尺寸上的偏差，经测试偏移量大概在0.85左右。
  var textPainter = TextPainter(
    text: TextSpan(
      text: text,
      style: style ??
          const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 12,
            fontFamily: 'SourceHanSansCN',
          ),
    ),
    textDirection: TextDirection.ltr,
  )..layout(maxWidth: maxWidth * 0.85);
  return Size(textPainter.width, textPainter.height);
}
