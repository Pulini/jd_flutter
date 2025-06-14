import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:jd_flutter/utils/utils.dart';
import 'package:qr_flutter/qr_flutter.dart';

Widget surplusMaterialLabelTemplate({
  required String qrCode,
  required String machine,
  required String shift,
  required String startDate,
  required String typeBody,
  required String materialName,
  required String materialCode,
}) {
  var bs = const BorderSide(color: Colors.black, width: 1.5);
  var qrCodeWidget = Container(
    decoration: BoxDecoration(border: Border(right: bs)),
    child: QrImageView(
      data: qrCode,
      padding: const EdgeInsets.all(5),
      version: QrVersions.auto,
    ),
  );
  var detailWidget = Column(
    children: [
      Expanded(
        flex: 5,
        child: Container(
          padding: const EdgeInsets.only(left: 3, right: 3),
          decoration: BoxDecoration(border: Border(bottom: bs)),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '机台：$machine',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              Text(
                '班次：$shift',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      ),
      Expanded(
        flex: 5,
        child: Container(
          padding: const EdgeInsets.only(left: 3, right: 3),
          decoration: BoxDecoration(border: Border(bottom: bs)),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                '派工日期：',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              Text(
                startDate,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      ),
      Expanded(
        flex: 33,
        child: Padding(
          padding: const EdgeInsets.only(left: 3, right: 3),
          child: Text(
            maxLines: 5,
            overflow: TextOverflow.ellipsis,
            '($materialCode)$materialName'.allowWordTruncation(),
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
          ),
        ),
      ),
    ],
  );
  var typeBodyWidget = Container(
    padding: const EdgeInsets.only(left: 3, right: 3),
    decoration: BoxDecoration(border: Border(top: bs)),
    child: Text(
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      '型体：$typeBody',
      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
    ),
  );
  return Container(
    color: Colors.white,
    width: 75 * 5.5,
    height: 45 * 5.5,
    child: Padding(
      padding: const EdgeInsets.all(4),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(
            color: Colors.black,
            width: 1.5,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
                flex: 38,
                child: Row(
                  children: [
                    Expanded(
                      flex: 38,
                      child: qrCodeWidget,
                    ),
                    Expanded(
                      flex: 35,
                      child: detailWidget,
                    ),
                  ],
                )),
            Expanded(
              flex: 5,
              child: typeBodyWidget,
            ),
          ],
        ),
      ),
    ),
  );
}

//标准格式标签模版
//75*45大小
Widget fixedLabelTemplate75x45({
  required String qrCode,
  Widget? title,
  Widget? subTitle,
  Widget? content,
  Widget? bottomLeft,
  Widget? bottomMiddle,
  Widget? bottomRight,
}) {
  var bs = const BorderSide(color: Colors.black, width: 1.5);
  var titleWidget = Container(
    decoration: BoxDecoration(
      border: Border(bottom: bs),
    ),
    child: Row(
      children: [
        Container(
          decoration: BoxDecoration(border: Border(right: bs)),
          child: QrImageView(
            data: qrCode,
            padding: const EdgeInsets.all(5),
            version: QrVersions.auto,
          ),
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                decoration: BoxDecoration(border: Border(bottom: bs)),
                child: Center(
                  child: Text(
                    qrCode,
                    style: const TextStyle(
                      fontSize: 8,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              Expanded(
                flex: 2,
                child: Container(
                  decoration: BoxDecoration(border: Border(bottom: bs)),
                  child: Padding(
                    padding: const EdgeInsets.only(left: 3, right: 3),
                    child: title ?? const Text(''),
                  ),
                ),
              ),
              Expanded(
                flex: 3,
                child: Padding(
                  padding: const EdgeInsets.only(left: 3, right: 3),
                  child: subTitle ?? const Text(''),
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
  var contentWidget = Container(
    decoration: BoxDecoration(
      border: Border(bottom: bs),
    ),
    child: Padding(
      padding: const EdgeInsets.only(left: 3, right: 3),
      child: content ?? const Text(''),
    ),
  );

  var bottomWidget = Row(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      Expanded(
        flex: 3,
        child: Container(
          decoration: BoxDecoration(
            border: Border(right: bs),
          ),
          child: Padding(
            padding: const EdgeInsets.only(left: 3, right: 3),
            child: bottomLeft ?? const Text(''),
          ),
        ),
      ),
      Expanded(
        flex: 5,
        child: Padding(
          padding: const EdgeInsets.only(left: 3, right: 3),
          child: bottomMiddle ?? const Text(''),
        ),
      ),
      Expanded(
        flex: 2,
        child: Container(
          decoration: BoxDecoration(
            border: Border(left: bs),
          ),
          child: Padding(
            padding: const EdgeInsets.only(left: 3, right: 3),
            child: bottomRight ?? const Text(''),
          ),
        ),
      ),
    ],
  );

  return Container(
    color: Colors.white,
    width: 75 * 5.5,
    height: 45 * 5.5,
    child: Padding(
      padding: const EdgeInsets.all(4),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(
            color: Colors.black,
            width: 1.5,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(flex: 19, child: titleWidget),
            Expanded(flex: 17, child: contentWidget),
            Expanded(flex: 7, child: bottomWidget),
          ],
        ),
      ),
    ),
  );
}

//动态格式标签模版
//75 x N（高度由内容决定）
Widget dynamicLabelTemplate75xN({
  required String qrCode,
  Widget? title,
  Widget? subTitle,
  Widget? header,
  Widget? table,
  Widget? footer,
}) {
  var bs = const BorderSide(color: Colors.black, width: 1.5);
  var titleWidget = Container(
    decoration: BoxDecoration(border: Border(bottom: bs)),
    child: Row(
      children: [
        Container(
          decoration: BoxDecoration(border: Border(right: bs)),
          child: QrImageView(
            data: qrCode,
            padding: const EdgeInsets.all(5),
            version: QrVersions.auto,
          ),
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                decoration: BoxDecoration(border: Border(bottom: bs)),
                child: Center(
                  child: Text(
                    qrCode,
                    style: const TextStyle(
                      fontSize: 8,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              Expanded(
                flex: 2,
                child: Container(
                  decoration: BoxDecoration(border: Border(bottom: bs)),
                  child: title ?? const Text(''),
                ),
              ),
              Expanded(
                flex: 3,
                child: subTitle ?? const Text(''),
              ),
            ],
          ),
        ),
      ],
    ),
  );

  return Container(
    color: Colors.white,
    width: 75 * 5.5,
    child: Padding(
      padding: const EdgeInsets.all(4),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(
            color: Colors.black,
            width: 1.5,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              height: 19 * 5.5,
              child: titleWidget,
            ),
            if (header != null) header,
            if (table != null) ...[
              const SizedBox(height: 5),
              table,
              const SizedBox(height: 5),
            ],
            if (footer != null) ...[footer, const SizedBox(height: 5)],
          ],
        ),
      ),
    ),
  );
}

//标签表格格式化
List<List<String>> labelTableFormat({
  required String title,
  String? total,
  required Map<String, List<List<String>>> list,
}) {
  if (list.isEmpty) return [];

  List<List<String>> result = [];
  // 取出所有尺码
  List<String> titleList = [];
  List<String> columnsTitleList = [];

  list.forEach((k, v) {
    for (var t in v) {
      if (!titleList.contains(t[0])) {
        titleList.add(t[0]);
      }
    }
  });

  titleList.sort((a, b) => a.toDoubleTry().compareTo(b.toDoubleTry()));

  // 指令缺的尺码做补位处理
  list.forEach((k, v) {
    List<List<String>> text = [];
    for (var t in titleList) {
      try {
        text.add(v.firstWhere((v) => v[0] == t));
      } catch (e) {
        text.add([t, '']);
      }
    }
    v.clear();
    v.addAll(text);
  });

  List<List<String>> printList = [];

  // 保存表格列第一格
  columnsTitleList.add(title);
  // 添加表格头行
  printList.add([for (var s in titleList) s]);

  // 添加表格体
  list.forEach((k, v) {
    // 保存表格列第一格
    columnsTitleList.add(k);
    // 添加表格行
    printList.add([for (var data in v) data[1]]);
  });

  if (total != null && total.isNotEmpty) {
    // 保存表格列第一格
    columnsTitleList.add(total);
    var print = <String>[];
    // 保存表格最后一行
    titleList.forEachIndexed((i, v) {
      double sum = 0.0;
      list.forEach((key, value) {
        if (i < titleList.length) {
          sum = sum.add(value[i][1].toDoubleTry());
        }
      });
      print.add(sum.toShowString());
    });
    // 添加表格尾行
    printList.add(print);
  }

  const max = 6;
  final maxColumns = (titleList.length / max).ceil();

  for (int i = 0; i < maxColumns; i++) {
    // 添加表格
    printList.forEachIndexed((index, data) {
      var s = i * max;
      var t = i * max + max;
      List<String> subData = [];
      // 添加行表头
      subData.add(columnsTitleList[index]);
      // 添加行
      subData.addAll(data.sublist(
        s,
        s < data.length && t <= data.length ? t : data.length,
      ));
      result.add(subData);
    });
    if (i < maxColumns - 1) {
      // 加入空行用于区分表格换行
      result.add([]);
    }
  }
  return result;
}

//动态格式物料外箱标
//110 x N（高度由内容决定）
//物料列表格式 [['物料编码','物料名称','数量','单位'],['物料编码','物料名称','数量','单位'],['物料编码','物料名称','数量','单位']]
Widget dynamicOutBoxLabel110xN({
  required String productName, //品名
  required String companyOrderType, //公司订单类型
  required String customsDeclarationType, //报关形式
  List<List>? materialList, //物料列表
  required String pieceNo, //件号
  required String grossWeight, //毛重
  required String netWeight, //净重
  required String qrCode, //二维码ID
  required String code, //标签码ID
  required String specifications, //规格型号
  required String volume, //体积
  required String supplier, //供应商
  required String manufactureDate, //生产日期
  required String consignee, //收货方
}) {
  var border = BoxDecoration(border: Border.all(color: Colors.black, width: 1));
  var style = const TextStyle(
    fontWeight: FontWeight.bold,
    fontSize: 17,
  );
  var textPadding = const EdgeInsets.only(left: 3, right: 3);
  var vDivider = Container(width: 2, color: Colors.black);
  var hDivider = Container(height: 2, color: Colors.black);
  paddingText(String text) =>
      Padding(padding: textPadding, child: Text(text, style: style));

  paddingTextCenter(String text) => Padding(
        padding: textPadding,
        child: Text(text, style: style, textAlign: TextAlign.center),
      );
  return Container(
    color: Colors.white,
    width: 110 * 5.5,
    child: Padding(
      padding: const EdgeInsets.all(2 * 5.5),
      child: Container(
        decoration: border,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            createRowText(
              title: '品名/Product/Produck',
              cw: paddingTextCenter(productName),
              rw: paddingTextCenter(companyOrderType),
            ),
            createRowText(
              title: '加工贸易/PT/PP',
              cw: paddingTextCenter(customsDeclarationType),
              rw: paddingTextCenter('MADE IN CHINA'),
            ),
            if (materialList != null)
              createRowText(
                title: '物编/Mtl No/Nomor material',
                cw: paddingTextCenter('物料描述/Mtl Des./Bahan Des'),
                rw: paddingTextCenter('数量/Qty/kuantitas'),
              ),
            for (var item in materialList ?? [])
              createRowText(
                title: item[0],
                cw: paddingTextCenter(item[1]),
                rw: Row(
                  children: [
                    Expanded(flex: 3, child: paddingTextCenter(item[2])),
                    vDivider,
                    Expanded(flex: 2, child: paddingTextCenter(item[3])),
                  ],
                ),
              ),
            Container(
              decoration: border,
              child: IntrinsicHeight(
                child: Row(
                  children: [
                    Expanded(
                      flex: 6,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Expanded(child: paddingText('件号/Serial/Seri')),
                          hDivider,
                          Expanded(
                            flex: 2,
                            child: paddingText('毛重/G.W/Berat Kotor'),
                          ),
                          hDivider,
                          Expanded(
                            flex: 2,
                            child: paddingText('净重/N.W/Berat Bersih'),
                          ),
                        ],
                      ),
                    ),
                    vDivider,
                    Expanded(
                      flex: 9,
                      child: Column(
                        children: [
                          Expanded(child: paddingTextCenter(pieceNo)),
                          hDivider,
                          Expanded(
                            flex: 2,
                            child: Row(
                              children: [
                                Expanded(child: paddingTextCenter(grossWeight)),
                                vDivider,
                                Expanded(child: paddingTextCenter('KGS')),
                              ],
                            ),
                          ),
                          hDivider,
                          Expanded(
                            flex: 2,
                            child: Row(
                              children: [
                                Expanded(child: paddingTextCenter(netWeight)),
                                vDivider,
                                Expanded(child: paddingTextCenter('KGS')),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    vDivider,
                    Expanded(
                        flex: 5,
                        child: Column(
                          children: [
                            SizedBox(
                              height: 120,
                              child: QrImageView(
                                data: qrCode,
                                padding: const EdgeInsets.all(5),
                                version: QrVersions.auto,
                              ),
                            ),
                            Text(
                              code,
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                height: 0,
                              ),
                            ),
                          ],
                        )),
                  ],
                ),
              ),
            ),
            createRowText(
              title: '规格/MEA/Spesifikasi',
              cw: paddingTextCenter(specifications),
              rw: Row(
                children: [
                  Expanded(flex: 3, child: paddingTextCenter(volume)),
                  vDivider,
                  Expanded(flex: 2, child: paddingTextCenter('cbm')),
                ],
              ),
            ),
            createRowText(
              title: '供应商/Supplier/Pemasok',
              cw: Row(
                children: [
                  Expanded(child: paddingTextCenter(supplier)),
                  vDivider,
                  Expanded(child: paddingText('生产日期/Manufact Date/Tanggal'))
                ],
              ),
              rw: paddingTextCenter(manufactureDate),
            ),
            Container(
              decoration: border,
              child: IntrinsicHeight(
                child: Row(
                  children: [
                    Expanded(
                      flex: 6,
                      child: paddingText('收货方/Consignee/Penerima Barang'),
                    ),
                    vDivider,
                    Expanded(flex: 14, child: paddingTextCenter('consignee')),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

//动态格式物料小标
//110 x N（高度由内容决定）
//物料列表格式 [['物料编码','物料名称','数量','单位'],['物料编码','物料名称','数量','单位'],['物料编码','物料名称','数量','单位']]
Widget dynamicInBoxLabel110xN({
  required String productName, //品名
  required String companyOrderType, //公司订单类型
  required String customsDeclarationType, //报关形式
  List<List>? materialList, //物料列表
  required String pieceNo, //件号
  required String qrCode, //二维码ID
  required String code, //标签码ID
  required String supplier, //供应商
  required String manufactureDate, //生产日期
}) {
  var border = BoxDecoration(border: Border.all(color: Colors.black, width: 1));
  var style = const TextStyle(
    fontWeight: FontWeight.bold,
    fontSize: 17,
  );
  var textPadding = const EdgeInsets.only(left: 3, right: 3);
  var vDivider = Container(width: 2, color: Colors.black);
  var hDivider = Container(height: 2, color: Colors.black);
  paddingText(String text) =>
      Padding(padding: textPadding, child: Text(text, style: style));

  paddingTextCenter(String text) => Padding(
        padding: textPadding,
        child: Text(text, style: style, textAlign: TextAlign.center),
      );
  return Container(
    color: Colors.white,
    width: 110 * 5.5,
    child: Padding(
      padding: const EdgeInsets.all(5 * 5.5),
      child: Container(
        decoration: border,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            createRowText(
              title: '品名/Product/Produck',
              cw: paddingTextCenter(productName),
              rw: paddingTextCenter(companyOrderType),
            ),
            createRowText(
              title: '加工贸易/PT/PP',
              cw: paddingTextCenter(customsDeclarationType),
              rw: paddingTextCenter('MADE IN CHINA'),
            ),
            if (materialList != null)
              createRowText(
                title: '物编/Mtl No/Nomor material',
                cw: paddingTextCenter('物料描述/Mtl Des./Bahan Des'),
                rw: paddingTextCenter('数量/Qty/kuantitas'),
              ),
            for (var item in materialList ?? [])
              createRowText(
                title: item[0],
                cw: paddingTextCenter(item[1]),
                rw: Row(
                  children: [
                    Expanded(flex: 3, child: paddingTextCenter(item[2])),
                    vDivider,
                    Expanded(flex: 2, child: paddingTextCenter(item[3])),
                  ],
                ),
              ),
            Container(
              decoration: border,
              child: IntrinsicHeight(
                child: Row(
                  children: [
                    Expanded(
                      flex: 6,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Expanded(child: paddingText('件号/Serial/Seri')),
                          hDivider,
                          Expanded(
                            flex: 2,
                            child: paddingText('生产日期/Manufact Date/Tanggal'),
                          ),
                          hDivider,
                          Expanded(
                            flex: 2,
                            child: paddingText('供应商/Supplier/Pemasok'),
                          ),
                        ],
                      ),
                    ),
                    vDivider,
                    Expanded(
                      flex: 9,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Expanded(child: paddingTextCenter(pieceNo)),
                          hDivider,
                          Expanded(
                            flex: 2,
                            child: Center(
                              child: paddingTextCenter(manufactureDate),
                            ),
                          ),
                          hDivider,
                          Expanded(
                            flex: 2,
                            child: Center(
                              child: paddingTextCenter(supplier),
                            ),
                          ),
                        ],
                      ),
                    ),
                    vDivider,
                    Expanded(
                        flex: 5,
                        child: Column(
                          children: [
                            SizedBox(
                              height: 120,
                              child: QrImageView(
                                data: qrCode,
                                padding: const EdgeInsets.all(5),
                                version: QrVersions.auto,
                              ),
                            ),
                            Text(
                              '$code(小标)',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                height: 0,
                              ),
                            ),
                          ],
                        )),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

Widget createRowText({
  required String title,
  required Widget cw,
  required Widget rw,
}) =>
    Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black, width: 1),
      ),
      child: IntrinsicHeight(
        child: Row(
          children: [
            Expanded(
              flex: 6,
              child: Padding(
                padding: const EdgeInsets.only(left: 3, right: 3),
                child: Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 17,
                  ),
                ),
              ),
            ),
            Container(width: 2, color: Colors.black),
            Expanded(flex: 9, child: cw),
            Container(width: 2, color: Colors.black),
            Expanded(flex: 5, child: rw),
          ],
        ),
      ),
    );
