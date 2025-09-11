import 'dart:convert';
import 'dart:ui' as ui;

import 'package:collection/collection.dart';
import 'package:fast_gbk/fast_gbk.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image/image.dart' as img;
import 'package:jd_flutter/utils/extension_util.dart';

//dpi
const _dpi = 8;

//半dpi
const _halfDpi = 4;

//设置打印参数
//[width] 纸宽
//[height] 纸高
//[speed] 打印速度  1.0 1.5 2 3 4 6 8 10
//[density] 打印浓度  0~15
//[sensor] 感应器类型  0:垂直間距感測器(gap sensor) 1:黑標感測器(black mark )
//[sensorDistance] 感应器距离
//[sensorOffset] 感应器偏移
Uint8List _tscSetup(
  int width,
  int height, {
  int speed = 4,
  int density = 6,
  int sensor = 0,
  int sensorDistance = 2,
  int sensorOffset = 0,
}) {
  String message;
  String size = 'SIZE $width mm, $height mm';
  String speedValue = 'SPEED $speed';
  String densityValue = 'DENSITY $density';
  String sensorValue = '';
  if (sensor == 0) {
    sensorValue = 'GAP $sensorDistance mm, $sensorOffset mm';
  } else if (sensor == 1) {
    sensorValue = 'BLINE $sensorDistance mm, $sensorOffset mm';
  }
  message = '$size\r\n$speedValue\r\n$densityValue\r\n$sensorValue\r\n';
  debugPrint(message);
  return utf8.encode(message);
}

// 清空缓冲区
Uint8List _tscClearBuffer() => utf8.encode('CLS\r\n');

// 打印指令
// [quantity] 打印次数
// [copy]  复制次数
Uint8List _tscPrint({int quantity = 1, int copy = 1}) =>
    utf8.encode('PRINT $quantity, $copy\r\n');

//下发拆切指令
Uint8List _tscCutter() => utf8.encode('SET CUTTER 1\r\n');

//关闭裁切模式
Uint8List _tscCutterOff() => utf8.encode('SET CUTTER OFF\r\n');

// 矩形
// [sx] 左上角x坐标
// [sy] 左上角y坐标
// [ex] 右下角x坐标
// [ey] 右下角y坐标
// [crude] 粗细
Uint8List _tscBox(int sx, int sy, int ex, int ey, {int? crude = 4}) =>
    utf8.encode('BOX $sx,$sy,$ex,$ey,$crude\n');

//圆形
//[x] x坐标
//[y] y坐标
//[diameter] 直径
//[thickness] 粗细
// ignore: unused_element
Uint8List _tscCircle(int x, int y, int diameter, int thickness) =>
    utf8.encode('CIRCLE $x,$y,$diameter,$thickness\r\n');

// 线
//[x] 左上角x坐标
//[y] 左上角y坐标
//[width] 线宽
//[height] 线高
Uint8List _tscLine(int x, int y, int width, int height) =>
    utf8.encode('BAR $x,$y,$width,$height\r\n');

//二维码
//[x] 左上角x坐标
//[y] 左上角y坐标
//[eccLevel] 纠错等级
//[cellWidth] 单元格宽度
//[mode] 编码模式
//[rotation] 旋转角度
//[version] 版本
//[mask] 掩码
//[content] 内容
Uint8List _tscQrCode(
  int x,
  int y,
  String content, {
  String ecc = 'H',
  String cell = '4',
  String mode = 'A',
  String rotation = '0',
  String version = 'M2',
  String mask = 'S7',
}) =>
    utf8.encode(
        'QRCODE $x,$y,$ecc,$cell,$mode,$rotation,$version,$mask,"$content"\r\n');

// 打印条形码
//[x] X坐标
//[y] Y坐标
//[content] 内容
//[sym] 条码类型，默认为"UCC128CCA"
//[rotate] 旋转角度，默认为0，范围0 - 270
//[moduleWidth] 模组宽度，默认为2，范围1 - 10
//[sepHt] 分隔符高度，默认为2，可选1或2
//[segWidth] UCC/EAN-128的高度，默认为35，单位DOT，范围1-500可选
// ignore: unused_element
Uint8List _tscBarCode(
  int x,
  int y,
  String content, {
  String sym = 'UCC128CCA',
  String rotate = '0',
  String moduleWidth = '2',
  String sepHt = '2',
  String segWidth = '35',
}) =>
    utf8.encode(
        'RSS $x,$y,"$sym",$rotate,$moduleWidth,$sepHt,$segWidth,"$content"\r\n');

//文本
//[x] 左上角x坐标
//[y] 左上角y坐标
//[font] 字体
//[rotation] 旋转角度
//[xMultiplication] x方向放大倍数
//[yMultiplication] y方向放大倍数
//[string] 文本
// ignore: unused_element
List<int> _tscText(
  int x,
  int y,
  String fontSize,
  int rotation,
  int xMultiplication,
  int yMultiplication,
  String text,
) =>
    gbk.encode(
        'TEXT $x,$y,"$fontSize",$rotation,$xMultiplication,$yMultiplication,"$text"\r\n');

//图片文本
//[xAxis] 左上角x坐标
//[yAxis] 左上角y坐标
//[fontSize] 字体大小
//[text] 文本内容
Future<Uint8List> _tscBitmapText(
    int xAxis,
    int yAxis,
    double fontSize,
    String text,
    ) async {
  var recorder = ui.PictureRecorder();
  var canvas = Canvas(recorder);
  var tp = TextPainter()
    ..text = TextSpan(
      text: text,
      style: TextStyle(
        color: Colors.black,
        fontSize: fontSize,
        fontWeight: FontWeight.bold,
      ),
    )
    ..textDirection = TextDirection.rtl
    ..layout();

  // 绘制矩形框，在文字绘制前可通过textPainter.width和textPainter.height来获取文字绘制的尺寸
  canvas.drawRect(
    Rect.fromLTWH(0, 0, tp.width, tp.height),
    Paint()..color = Colors.white,
  );

  // 绘制文字
  tp.paint(canvas, const Offset(0, 0));

  //生成uiImage
  final uiImage = await recorder
      .endRecording()
      .toImage(tp.width.toInt(), tp.height.toInt());

  //获取图像byte数据
  var byte = await uiImage.toByteData(format: ui.ImageByteFormat.png);

  //创建图像处理器
  var image = img.decodeImage(byte!.buffer.asUint8List())!;

  //创建一个灰阶图，大小与原图相同
  var grayImage = img.Image(width: image.width, height: image.height);

  //设置灰阶阈值
  const int threshold = 127;

  // 遍历图像的每个像素
  for (int y = 0; y < image.height; y++) {
    for (int x = 0; x < image.width; x++) {
      // 获取当前像素的RGBA值
      final pixel = image.getPixel(x, y);

      // 计算灰度值
      var gray = (pixel.r * 0.3 + pixel.g * 0.59 + pixel.b * 0.11).round();

      // 将灰阶图二值化
      var newPixel = gray > threshold
          ? img.ColorRgba8(255, 255, 255, 255) // 白色
          : img.ColorRgba8(0, 0, 0, 255); // 黑色

      // 设置二值化后的图像的像素
      grayImage.setPixel(x, y, newPixel);
    }
  }

  //二值图位宽
  var widthByte = (grayImage.width + 7) ~/ 8;

  var width = grayImage.width;
  var height = grayImage.height;

  //二值图数据
  Uint8List stream = Uint8List(widthByte * height);

  //初始化二值图数据
  for (int i = 0; i < height * widthByte; ++i) {
    stream[i] = -1;
  }

  //遍历二值图，转换成tsc打印机可识别的数据
  for (int y = 0; y < height; ++y) {
    for (int x = 0; x < width; ++x) {
      var pixelColor = grayImage.getPixel(x, y);
      var red = pixelColor.r;
      var green = pixelColor.g;
      var blue = pixelColor.b;
      var total = (red + green + blue) / 3;
      // 像素为黑色时，将二值图数据置为1
      if (total == 0) {
        //找到二值图数据在stream中的索引
        int byteIndex = y * ((width + 7) ~/ 8) + x ~/ 8;
        // 找到二值图数据在stream中的位掩码
        int targetBitMask = (128 >> (x % 8)).toInt();
        // 将二值图数据置为1
        stream[byteIndex] ^= targetBitMask;
      }
    }
  }

  return Uint8List.fromList(List.from(
    utf8.encode('BITMAP $xAxis,$yAxis,${(tp.width + 7) ~/ 8},${tp.height},0,'),
  )
    ..addAll(stream)
    ..addAll(utf8.encode('\r\n')));
}


Future<Uint8List> _tscBitmap(
  int xAxis,
  int yAxis,
  Uint8List bitmapData,
) async {
  debugPrint('imageData=${bitmapData.lengthInBytes}');
  // 1. 将原始位图转换为灰度图像
  img.Image grayBitmap = img.grayscale(img.decodeImage(bitmapData)!);

  debugPrint('grayBitmap=${grayBitmap.lengthInBytes}');
  // 2. 将灰度图像转换为二值图像
  img.Image binaryBitmap = img.copyResize(grayBitmap,
      width: grayBitmap.width, height: grayBitmap.height);

  debugPrint('binaryBitmap=${grayBitmap.lengthInBytes}');
  // 手动进行二值化处理
  const threshold = 127;
  for (int y = 0; y < binaryBitmap.height; y++) {
    for (int x = 0; x < binaryBitmap.width; x++) {
      final pixel = binaryBitmap.getPixel(x, y);
      final grayValue = (pixel.r + pixel.g + pixel.b) / 3;
      final newValue = grayValue > threshold
          ? img.ColorRgb8(255, 255, 255) // 白色
          : img.ColorRgb8(0, 0, 0); // 黑色
      binaryBitmap.setPixel(x, y, newValue);
    }
  }
  debugPrint('binaryBitmap=${grayBitmap.lengthInBytes}');

  // 3. 构建命令字符串
  String pictureWidth = ((binaryBitmap.width + 7) ~/ 8).toString();
  String pictureHeight = binaryBitmap.height.toString();
  String mode = "0"; // 模式固定为0
  String command = "BITMAP $xAxis,$yAxis,$pictureWidth,$pictureHeight,$mode,";

  // 4. 创建字节流
  int widthBytes = (binaryBitmap.width + 7) ~/ 8;
  int width = binaryBitmap.width;
  int height = binaryBitmap.height;

  Uint8List stream = Uint8List(widthBytes * height);

  // 初始化字节流，默认值为0xFF (全1，表示白色)
  for (int i = 0; i < stream.length; i++) {
    stream[i] = 0xFF;
  }
  debugPrint('stream=${stream.lengthInBytes}');
  // 5. 根据像素值处理字节流
  for (int y = 0; y < height; ++y) {
    for (int x = 0; x < width; ++x) {
      final pixel = binaryBitmap.getPixel(x, y);
      final total = (pixel.r + pixel.g + pixel.b) ~/ 3;

      // 像素为黑色时，将对应位设为0
      if (total == 0) {
        final byteIndex = y * widthBytes + x ~/ 8;
        final bitIndex = x % 8;
        final mask = 0x80 >> bitIndex;
        stream[byteIndex] &= ~mask; // 将对应位设为0（黑色）
      }
    }
  }
  debugPrint('stream=${stream.lengthInBytes}');
  // 6. 组合完整的TSC命令
  final commandBytes = Uint8List.fromList(utf8.encode(command));
  final fullCommand = Uint8List(commandBytes.length + stream.length + 2);

  fullCommand.setRange(0, commandBytes.length, commandBytes);
  fullCommand.setRange(
      commandBytes.length, commandBytes.length + stream.length, stream);
  fullCommand[commandBytes.length + stream.length] = 13; // \r
  fullCommand[commandBytes.length + stream.length + 1] = 10; // \n

  return fullCommand;
}

//创建一个文本列表，将传入的文本根据字体大小和限宽进行拆分换行
//[text] 文本内容
//[fontSize] 字体大小
//[maxWidthPx] 最大宽度
List<String> contextFormat(String text, double fontSize, double maxWidthPx) {
  final List<String> lines = <String>[];
  String currentLine = '';
  final TextPainter textPainter = TextPainter(
    textDirection: ui.TextDirection.ltr,
  );

  for (var char in text.characters) {
    textPainter.text = TextSpan(
      text: currentLine + char,
      style: TextStyle(fontSize: fontSize),
    );

    textPainter.layout();
    if (textPainter.width <= maxWidthPx) {
      currentLine += char;
    } else {
      lines.add(currentLine);
      currentLine = char;
    }
  }

  lines.add(currentLine);
  return lines;
}

//表格格式化
//[title] 表格标题
//[bottom] 表格底部
//[tableData] 表格数据
List<List<String>> tableFormat(
  String title,
  String bottom,
  Map<String, List<List<String>>> tableData,
) {
  var list = <List<String>>[];
  if (tableData.isEmpty) return [];
  //取出所有尺码
  var titleList = <String>[];
  var columnsTitleList = <String>[];
  tableData.forEach((k, v) {
    for (var v2 in v) {
      if (!titleList.contains(v2[0])) {
        titleList.add(v2[0]);
      }
    }
  });
  titleList = titleList.sorted();

  //指令缺的尺码做补位处理
  tableData.forEach((k, v) {
    var text = <List<String>>[];
    for (var indexText in titleList) {
      text.add(v.firstWhere((e) => e[0] == indexText,
          orElse: () => [indexText, '']));
    }
    v.clear();
    v.addAll(text);
  });

  //添加表格头行
  var printList = <List<String>>[];

  //保存表格列第一格
  columnsTitleList.add(title);
  //保存表格第一行
  printList.add(titleList);

  //添加表格体
  tableData.forEach((k, v) {
    //保存表格列第一格
    columnsTitleList.add(k);
    //保存表格本体所有行
    printList.add([for (var v2 in v) v2[1]]);
  });

  //保存表格列第一格
  columnsTitleList.add(bottom);
  var print = <String>[];
  //保存表格最后一行
  for (var i = 0; i < titleList.length; ++i) {
    var sum = 0.0;
    tableData.forEach((k, v) {
      if (i < titleList.length) {
        sum = sum.add(v[i][1].toDoubleTry());
      }
    });
    print.add(sum.toShowString());
  }
  printList.add(print);

  var max = 6;
  var maxColumns =
      (titleList.length / max) + (titleList.length % max) > 0 ? 1 : 0;
  for (var i = 0; i < maxColumns; ++i) {
    //添加表格
    printList.forEachIndexed((index, data) {
      var s = i * max;
      var t = i * max + max;
      var subData = <String>[];
      //添加行表头
      subData.add(columnsTitleList[index]);
      //添加行
      subData.addAll(data.sublist(
          s, (s < data.length && t <= data.length) ? t : data.length));

      list.add(subData);
    });

    if (i < maxColumns - 1) {
      //加入空行用于区分表格换行
      list.add([]);
    }
  }

  return list;
}

//------------------------------------以上为tsc指令集--------------------------------------

// 财产标签
// 70mm X 40mm
// [id] 资产ID
// [name] 资产名称
// [number] 资产编号
// [date] 日期
Future<List<Uint8List>> labelForProperty(
  String id,
  String name,
  String number,
  String date,
) async =>
    [
      _tscClearBuffer(),
      _tscCutterOff(),
      _tscSetup(70, 40),
      _tscLine(10, 350, 820, 4),
      _tscQrCode(500, 30,
          'http://jdwx.goldemperor.com/aspx/FACard/CardInfo.aspx?FInterID=$id',
          cell: '6'),
      await _tscBitmapText(100, 360, 90, 'Gold Emperor'),
      if (name.length > 6)
        await _tscBitmapText(50, 60, 40, '名称：${name.substring(0, 6)}'),
      if (name.length > 6)
        await _tscBitmapText(200, 110, 40, name.substring(6, name.length)),
      if (name.length <= 6) await _tscBitmapText(50, 60, 40, '名称：$name'),
      await _tscBitmapText(50, 160, 40, '编号：$number'),
      await _tscBitmapText(50, 260, 40, '日期：$date'),
      _tscPrint()
    ];

//料头标签
//[qrCode] 二维码信息
//[machine] 派工机台
//[shift] 班次
//[startDate] 派工日期
//[factoryType] 工厂型体
//[stubBar] 料头名称
//[stuBarCode] 料头编码
Future<List<Uint8List>> labelForSurplusMaterial({
  required String qrCode,
  required String machine,
  required String shift,
  required String startDate,
  required String factoryType,
  required String stubBar,
  required String stuBarCode,
}) async {
  var list = <Uint8List>[];

  list.add(_tscClearBuffer());
  list.add(_tscCutterOff());
  list.add(_tscSetup(75, 45, density: 8));
  list.add(_tscQrCode(
      2 * _dpi, 2 * _dpi + _halfDpi, qrCode.replaceAll('"', '\\["]'),
      cell: '5'));
  list.add(
      await _tscBitmapText(39 * _dpi, 2 * _dpi, 26, '机台:$machine  班次:$shift'));
  list.add(await _tscBitmapText(39 * _dpi, 7 * _dpi, 26, '派工日期:$startDate'));
  list.add(await _tscBitmapText(2 * _dpi, 39 * _dpi, 30, '型体:$factoryType'));
  var format = contextFormat('($stuBarCode)$stubBar', 30, 33.0 * _dpi);
  for (var i = 0; i < format.length; ++i) {
    list.add(
        await _tscBitmapText(39 * _dpi, (13 + 4 * i) * _dpi, 30, format[i]));
  }
  list.add(_tscBox(_dpi, _dpi, 74 * _dpi, 43 * _dpi, crude: 2));
  list.add(_tscLine(39 * _dpi - _halfDpi, _dpi, 2, 38 * _dpi));
  list.add(_tscLine(39 * _dpi - _halfDpi, 6 * _dpi, 36 * _dpi - _halfDpi, 2));
  list.add(_tscLine(39 * _dpi - _halfDpi, 12 * _dpi, 36 * _dpi - _halfDpi, 2));
  list.add(_tscLine(_dpi, 39 * _dpi - _halfDpi, 73 * _dpi, 2));
  list.add(_tscPrint());

  return list;
}

//通用固定标签
//[qrCode] 二维码内容
//[title]  主标题文本
//[subTitle] 子标题文本
//[content]  主内容文本
//[subContent1]  子内容文本1
//[subContent2]  字内容文本2
//[bottomLeftText1]  左下文本1
//[bottomLeftText2]  左下文本2
//[bottomMiddleText1]  中下文本1
//[bottomMiddleText2]  中下文本2
//[bottomRightText1] 右下文本1
//[bottomRightText2] 右下文本2
Future<List<Uint8List>> labelMultipurposeFixed({
  bool isEnglish = false,
  String qrCode = '',
  String title = '',
  String subTitle = '',
  bool subTitleWrap = true,
  String content = '',
  String specification = '',
  String subContent1 = '',
  String subContent2 = '',
  String bottomLeftText1 = '',
  String bottomLeftText2 = '',
  String bottomMiddleText1 = '',
  String bottomMiddleText2 = '',
  String bottomRightText1 = '',
  String bottomRightText2 = '',
}) async {
  var list = <Uint8List>[];

  list.add(_tscClearBuffer());
  list.add(_tscSetup(75, 45,density: 12,speed: 3));
  if (qrCode.isNotEmpty) {
    list.add(_tscQrCode(2 * _dpi, 2 * _dpi + _halfDpi,
        qrCode.contains('"') ? qrCode.replaceAll('"', '\\["]') : qrCode));
    list.add(await _tscBitmapText(19 * _dpi + _halfDpi, 2 * _dpi, 16, qrCode));
  }
  if (title.isNotEmpty) {
    list.add(await _tscBitmapText(
        19 * _dpi + _halfDpi, 4 * _dpi + _halfDpi, 40, title));
  }
  if (subTitleWrap) {
    if (subTitle.isNotEmpty) {
      var format = contextFormat(subTitle, 30, 54.0 * _dpi);
      for (var i = 0; i < format.length; ++i) {
        //限制子标题行数为2
        if (i >= 2) break;
        list.add(await _tscBitmapText(19 * _dpi + _halfDpi,
            (11 + 4 * i) * _dpi - _halfDpi, 30, format[i]));
      }
    }
  } else {
    list.add(
        await _tscBitmapText(19 * _dpi + _halfDpi, 12 * _dpi, 40, subTitle));
  }
  if(!isEnglish){
    if (content.isNotEmpty) {
      var format = contextFormat(content, 30, 71.0 * _dpi);
      for (var i = 0; i < format.length; ++i) {
        //如子内容不为空，则主内容限制行数为2
        if (subContent1.isNotEmpty && subContent2.isNotEmpty && i >= 2) {
          break;
        }
        //如子内容2不为空，则主内容限制行数为3
        if (subContent1.isEmpty && subContent2.isNotEmpty && i >= 3) break;
        //如子内容为空则限制主内容行数为4
        if (i >= 4) break;
        list.add(
            await _tscBitmapText(2 * _dpi, (20 + 4 * i) * _dpi, 30, format[i]));
      }
    }
  }else{
    list.add(await _tscBitmapText(2 * _dpi, 20 * _dpi, 30, content));
  }
  if(!isEnglish){
    if (subContent1.isNotEmpty) {
      list.add(await _tscBitmapText(2 * _dpi, 28 * _dpi, 28, subContent1));
    }
  }else{

    if (specification.isNotEmpty) {
      list.add(await _tscBitmapText(2 * _dpi, 24 * _dpi, 28, specification));
    }

    if (subContent1.isNotEmpty) {
      list.add(await _tscBitmapText(2 * _dpi, 28 * _dpi, 28, subContent1));
    }
  }

  if (subContent2.isNotEmpty) {
    list.add(await _tscBitmapText(2 * _dpi, 32 * _dpi, 28, subContent2));
  }
  if (bottomLeftText1.isNotEmpty) {
    if (bottomLeftText2.isNotEmpty) {
      list.add(await _tscBitmapText(2 * _dpi, 37 * _dpi, 24, bottomLeftText1));
      list.add(await _tscBitmapText(2 * _dpi, 40 * _dpi, 24, bottomLeftText2));
    } else {
      list.add(await _tscBitmapText(2 * _dpi, 38 * _dpi, 36, bottomLeftText1));
    }
  }
  if (bottomMiddleText1.isNotEmpty) {
    if (bottomMiddleText2.isNotEmpty) {
      list.add(await _tscBitmapText(
          23 * _dpi + _halfDpi, 37 * _dpi, 24, bottomMiddleText1));
      list.add(await _tscBitmapText(
          23 * _dpi + _halfDpi, 40 * _dpi, 24, bottomMiddleText2));
    } else {
      list.add(await _tscBitmapText(
          23 * _dpi + _halfDpi, 38 * _dpi, 34, bottomMiddleText1));
    }
  }
  if (bottomRightText1.isNotEmpty) {
    if (bottomRightText2.isNotEmpty) {
      list.add(
          await _tscBitmapText(62 * _dpi, 37 * _dpi, 24, bottomRightText1));
      list.add(
          await _tscBitmapText(62 * _dpi, 40 * _dpi, 24, bottomRightText2));
    } else {
      list.add(
          await _tscBitmapText(62 * _dpi, 38 * _dpi, 36, bottomRightText1));
    }
  }
  list.add(_tscBox(_dpi, _dpi, 74 * _dpi, 44 * _dpi, crude: 2));
  list.add(_tscLine(19 * _dpi, _dpi, 2, 19 * _dpi - _halfDpi));
  list.add(_tscLine(23 * _dpi, 36 * _dpi + _halfDpi, 2, 8 * _dpi - _halfDpi));
  list.add(_tscLine(
      61 * _dpi + _halfDpi, 36 * _dpi + _halfDpi, 2, 8 * _dpi - _halfDpi));

  list.add(_tscLine(19 * _dpi, 4 * _dpi + 2, 55 * _dpi, 2));
  list.add(_tscLine(19 * _dpi, 10 * _dpi + 2, 55 * _dpi, 2));
  list.add(_tscLine(_dpi, 20 * _dpi - _halfDpi, 73 * _dpi, 2));
  list.add(_tscLine(_dpi, 36 * _dpi + _halfDpi, 73 * _dpi, 2));

  list.add(_tscPrint());

  return list;
}

//通用固定标签
//[qrCode] 二维码内容
//[title]  主标题文本
//[subTitle] 子标题文本
//[content]  主内容文本
//[subContent1]  子内容文本1
//[subContent2]  字内容文本2
//[bottomLeftText1]  左下文本1
//[bottomLeftText2]  左下文本2
//[bottomMiddleText1]  中下文本1
//[bottomMiddleText2]  中下文本2
//[bottomRightText1] 右下文本1
//[bottomRightText2] 右下文本2
Future<List<Uint8List>> labelMultipurposeEnglishFixed({
  String qrCode = '',
  String title = '',
  String subTitle = '',
  bool subTitleWrap = true,
  String content = '',
  String specification = '',
  String subContent1 = '',
  String subContent2 = '',
  String bottomLeftText1 = '',
  String bottomLeftText2 = '',
  String bottomMiddleText1 = '',
  String bottomMiddleText2 = '',
  String bottomRightText1 = '',
  String bottomRightText2 = '',
}) async {
  var list = <Uint8List>[];

  list.add(_tscClearBuffer());
  list.add(_tscCutterOff());
  list.add(_tscSetup(75, 45));
  if (qrCode.isNotEmpty) {
    list.add(_tscQrCode(2 * _dpi, 2 * _dpi + _halfDpi,
        qrCode.contains('"') ? qrCode.replaceAll('"', '\\["]') : qrCode,
        cell: '5'));
    list.add(await _tscBitmapText(19 * _dpi + _halfDpi, 2 * _dpi, 16, qrCode));
  }
  if (title.isNotEmpty) {
    list.add(await _tscBitmapText(
        19 * _dpi + _halfDpi, 4 * _dpi + _halfDpi, 40, title));
  }
  if (subTitleWrap) {
    if (subTitle.isNotEmpty) {
      var format = contextFormat(subTitle, 30, 54.0 * _dpi);
      for (var i = 0; i < format.length; ++i) {
        //限制子标题行数为2
        if (i >= 2) break;
        list.add(await _tscBitmapText(19 * _dpi + _halfDpi,
            (11 + 4 * i) * _dpi - _halfDpi, 30, format[i]));
      }
    }
  } else {
    list.add(
        await _tscBitmapText(19 * _dpi + _halfDpi, 12 * _dpi, 40, subTitle));
  }
  if (content.isNotEmpty) {
    list.add(await _tscBitmapText(2 * _dpi, 20 * _dpi, 30, content));
  }
  if (specification.isNotEmpty) {
    list.add(await _tscBitmapText(2 * _dpi, 24 * _dpi, 28, specification));
  }
  if (subContent1.isNotEmpty) {
    list.add(await _tscBitmapText(2 * _dpi, 28 * _dpi, 28, subContent1));
  }
  if (subContent2.isNotEmpty) {
    list.add(await _tscBitmapText(2 * _dpi, 32 * _dpi, 28, subContent2));
  }
  if (bottomLeftText1.isNotEmpty) {
    if (bottomLeftText2.isNotEmpty) {
      list.add(await _tscBitmapText(2 * _dpi, 37 * _dpi, 24, bottomLeftText1));
      list.add(await _tscBitmapText(2 * _dpi, 40 * _dpi, 24, bottomLeftText2));
    } else {
      list.add(await _tscBitmapText(2 * _dpi, 38 * _dpi, 36, bottomLeftText1));
    }
  }
  if (bottomMiddleText1.isNotEmpty) {
    if (bottomMiddleText2.isNotEmpty) {
      list.add(await _tscBitmapText(
          23 * _dpi + _halfDpi, 37 * _dpi, 24, bottomMiddleText1));
      list.add(await _tscBitmapText(
          23 * _dpi + _halfDpi, 40 * _dpi, 24, bottomMiddleText2));
    } else {
      list.add(await _tscBitmapText(
          23 * _dpi + _halfDpi, 38 * _dpi, 36, bottomMiddleText1));
    }
  }
  if (bottomRightText1.isNotEmpty) {
    if (bottomRightText2.isNotEmpty) {
      list.add(
          await _tscBitmapText(62 * _dpi, 37 * _dpi, 24, bottomRightText1));
      list.add(
          await _tscBitmapText(62 * _dpi, 40 * _dpi, 24, bottomRightText2));
    } else {
      list.add(
          await _tscBitmapText(62 * _dpi, 38 * _dpi, 36, bottomRightText1));
    }
  }
  list.add(_tscBox(_dpi, _dpi, 74 * _dpi, 44 * _dpi, crude: 2));
  list.add(_tscLine(19 * _dpi, _dpi, 2, 19 * _dpi - _halfDpi));
  list.add(_tscLine(23 * _dpi, 36 * _dpi + _halfDpi, 2, 8 * _dpi - _halfDpi));
  list.add(_tscLine(
      61 * _dpi + _halfDpi, 36 * _dpi + _halfDpi, 2, 8 * _dpi - _halfDpi));

  list.add(_tscLine(19 * _dpi, 4 * _dpi + 2, 55 * _dpi, 2));
  list.add(_tscLine(19 * _dpi, 10 * _dpi + 2, 55 * _dpi, 2));
  list.add(_tscLine(_dpi, 20 * _dpi - _halfDpi, 73 * _dpi, 2));
  list.add(_tscLine(_dpi, 36 * _dpi + _halfDpi, 73 * _dpi, 2));

  list.add(_tscPrint());

  return list;
}

//通用动态标签
//[qrCode] 二维码内容
//[title]  主标题文本
//[subTitle] 子标题文本
//[tableTitle] 表格标题文本
//[tableTitleTips] 表格标题提示文本
//[tableSubTitle]  表格子标题文本
//[tableFirstLineTitle]  表格第一行标题文本
//[tableLastLineTitle] 表格最后一行标题文本
//[tableData]  表格数据
//[bottomLeftText1]  左下文本1
//[bottomLeftText2]  左下文本2
//[bottomRightText1] 右下文本1
//[bottomRightText2] 右下文本2
Future<List<Uint8List>> labelMultipurposeDynamic({
  String qrCode = '',
  String title = '',
  String subTitle = '',
  String tableTitle = '',
  String tableTitleTips = '',
  String tableSubTitle = '',
  String tableFirstLineTitle = '',
  String tableLastLineTitle = '',
  Map<String, List<List<String>>> tableData = const {},
  String bottomLeftText1 = '',
  String bottomLeftText2 = '',
  String bottomRightText1 = '',
  String bottomRightText2 = '',
}) async {
  var list = <Uint8List>[];

  //标签宽度 纸张75 左右各缩进1 = 75-2
  var width = 73;

  //边距
  var margin = 3;

  //内缩
  var padding = 1;

  //二维码宽度
  var qrCodeWidth = 18;
  var qrCodeShowHeight = 2;

  //主标题文本高度
  var titleTextHeight = 6;
  //表格主标题高度
  var tableTitleHeight = 4;
  var tableTitleWidth = 54;
  var format1 = contextFormat(tableSubTitle, 30, _dpi * 71);
  var format2 = contextFormat(subTitle, 30, 54.0 * _dpi);
  //表格子标题文本高度
  var tableSubTitleHeight = 4 * format1.length;

  //表格行高
  var tableLineHeight = 5;
  //表格换行 行高
  var tableLineWrap = 2;
  //表格上下边距
  var tableMargin = 4;

  //表格数据
  var table = tableFormat(tableFirstLineTitle, tableLastLineTitle, tableData);

  //表格高度
  var tableHeight = table.where((e) => e.isEmpty).length * tableLineWrap +
      table.where((e) => e.isNotEmpty).length * tableLineHeight +
      tableMargin;
  //底部文本高度
  var bottomTextHeight = 8;

  //height:标签高度 = 边距 + 内缩 + 二维码高度 + 表格主标题高度 + 表格子标题高度 + 动态指令高度 + 底部文本高度 + 内缩 + 边距
  var height = margin +
      padding +
      qrCodeWidth +
      tableTitleHeight +
      tableSubTitleHeight +
      tableHeight +
      bottomTextHeight +
      padding +
      margin;
  var qrCodeX = (1 + padding) * _dpi;
  var qrCodeY = (margin + padding) * _dpi;
  var qrCodeShowX = (1 + padding + qrCodeWidth) * _dpi;
  var qrCodeShowY = margin * _dpi;
  var titleX = (1 + padding + qrCodeWidth) * _dpi;
  var titleY = (margin + qrCodeShowHeight) * _dpi + _halfDpi;
  var subTitleX = (1 + padding + qrCodeWidth) * _dpi;
  var subTitleY =
      (margin + qrCodeShowHeight + titleTextHeight) * _dpi + _halfDpi;
  var tableTitleX = (1 + padding) * _dpi;
  var tableTitleY = (margin + padding + qrCodeWidth) * _dpi;
  var tableTitleTipsX = (1 + tableTitleWidth + padding) * _dpi;
  var tableTitleTipsY = (margin + padding + qrCodeWidth) * _dpi;
  var tableSubTitleX = (1 + padding) * _dpi;
  var tableSubTitleY =
      (margin + padding + qrCodeWidth + tableTitleHeight) * _dpi;
  var bLeftText1X = (1 + padding) * _dpi;
  var bLeftText1Y = (margin +
          padding +
          qrCodeWidth +
          tableTitleHeight +
          tableSubTitleHeight +
          tableHeight) *
      _dpi;
  var bLeftText2X = (1 + padding) * _dpi;
  var bLeftText2Y = (margin +
          padding +
          qrCodeWidth +
          tableTitleHeight +
          tableSubTitleHeight +
          tableHeight +
          4) *
      _dpi;
  var bRightText1X = (1 + padding + 35) * _dpi;
  var bRightText1Y = (margin +
          padding +
          qrCodeWidth +
          tableTitleHeight +
          tableSubTitleHeight +
          tableHeight) *
      _dpi;
  var bRightText2X = (1 + padding + 35) * _dpi;
  var bRightText2Y = (margin +
          padding +
          qrCodeWidth +
          tableTitleHeight +
          tableSubTitleHeight +
          tableHeight +
          4) *
      _dpi;

  list.add(_tscCutter());
  list.add(_tscClearBuffer());
  list.add(_tscSetup(width, height, sensorDistance: 0));

  if (qrCode.isNotEmpty) {
    list.add(_tscQrCode(qrCodeX, qrCodeY,
        qrCode.contains('"') ? qrCode.replaceAll('"', '\\["]') : qrCode));
    list.add(await _tscBitmapText(qrCodeShowX, qrCodeShowY, 16, qrCode));
  }

  if (title.isNotEmpty) {
    list.add(await _tscBitmapText(titleX, titleY, 40, title));
  }

  if (subTitle.isNotEmpty) {
    for (var i = 0; i < format2.length; ++i) {
      //只允许行数为2
      if (i >= 2) break;
      //行高
      var lineHeight = 4;
      list.add(await _tscBitmapText(
          subTitleX, subTitleY + lineHeight * i * _dpi, 30, format2[i]));
    }
  }

  if (tableTitle.isNotEmpty) {
    list.add(await _tscBitmapText(tableTitleX, tableTitleY, 30, tableTitle));
  }

  if (tableTitleTips.isNotEmpty) {
    list.add(await _tscBitmapText(
        tableTitleTipsX, tableTitleTipsY, 30, tableTitleTips));
  }

  if (tableSubTitle.isNotEmpty) {
    for (var i = 0; i < format1.length; ++i) {
      //行高
      var lineHeight = 4;
      list.add(await _tscBitmapText(tableSubTitleX,
          tableSubTitleY + lineHeight * i * _dpi, 30, format1[i]));
    }
  }

  if (table.isNotEmpty) {
    var boxY = (margin +
            padding +
            qrCodeWidth +
            tableTitleHeight +
            tableSubTitleHeight +
            1) *
        _dpi;
    for (var line in table) {
      var boxX = (1 + padding) * _dpi;
      var boxH = tableLineHeight * _dpi;
      if (line.isEmpty) {
        boxY += tableLineWrap * _dpi;
        boxH += tableLineWrap * _dpi;
      } else {
        int boxW;
        for (var i = 0; i < line.length; ++i) {
          boxW = i == 0 ? 22 * _dpi : 8 * _dpi;
          if (line[i].isNotEmpty) {
            list.add(
                await _tscBitmapText(boxX + _dpi, boxY + _dpi, 28, line[i]));
          }
          list.add(_tscBox(
              boxX, boxY + _halfDpi, boxW + boxX, boxH + boxY + _halfDpi,
              crude: 2));
          boxX += boxW;
        }
        boxY += tableLineHeight * _dpi;
        boxH += tableLineHeight * _dpi;
      }
    }
  }
  if (bottomLeftText1.isNotEmpty) {
    list.add(
        await _tscBitmapText(bLeftText1X, bLeftText1Y, 30, bottomLeftText1));
  }
  if (bottomLeftText2.isNotEmpty) {
    list.add(
        await _tscBitmapText(bLeftText2X, bLeftText2Y, 30, bottomLeftText2));
  }
  if (bottomRightText1.isNotEmpty) {
    list.add(
        await _tscBitmapText(bRightText1X, bRightText1Y, 30, bottomRightText1));
  }
  if (bottomRightText2.isNotEmpty) {
    list.add(
        await _tscBitmapText(bRightText2X, bRightText2Y, 30, bottomRightText2));
  }
  list.add(_tscLine(
      (padding + qrCodeWidth) * _dpi, margin * _dpi, 2, qrCodeWidth * _dpi));
  list.add(_tscLine(
      (padding + qrCodeWidth) * _dpi,
      (margin + qrCodeShowHeight) * _dpi,
      (width - qrCodeWidth - padding) * _dpi,
      2));
  list.add(_tscLine(
      (padding + qrCodeWidth) * _dpi,
      (margin + qrCodeShowHeight + titleTextHeight) * _dpi,
      (width - qrCodeWidth - padding) * _dpi,
      2));
  list.add(_tscLine(
      _dpi, (margin + qrCodeWidth) * _dpi, (width - padding) * _dpi, 2));
  list.add(_tscBox(_dpi, margin * _dpi, width * _dpi, (height - margin) * _dpi,
      crude: 2));

  //绘制底部裁切线 x坐标=0 y坐标=上边距 +固定区高度 + 动态物料高度 + 动态指令高度 + 页码高度 + 下边距 - 缩进1 width长度=标签宽度
  for (int i = 0; i <= width; i += 2) {
    list.add(_tscLine(i * _dpi, height * _dpi - 2, _dpi, 2));
  }

  list.add(_tscPrint());

  return list;
}

Future<Uint8List> labelImageResize(Uint8List image) async {
  var reImage = img.copyResize(
    img.decodeImage(image)!,
    width: 75 * 8,
    height: 45 * 8,
  );
  return Uint8List.fromList(img.encodePng(reImage));
}

List<Uint8List> testLabel() => [
      _tscClearBuffer(),
      _tscSetup(110, 50, sensorDistance: 0),
      _tscQrCode(10, 10, '1234567890'),
      _tscCutter(),
      _tscPrint(),
    ];

Future<List<Uint8List>> imageResizeToLabel(Map<String, dynamic> image) async =>
    await compute(_imageResizeToLabel, image);

Future<List<Uint8List>> _imageResizeToLabel(Map<String, dynamic> image) async {
  double pixelRatio = image['pixelRatio'] ?? 1;
  int speed = image['speed'] ?? 4;
  int density = image['density'] ?? 15;
  bool isDynamic = image['isDynamic'] ?? false;
  int width = ((image['width'] as int) / 5.5 / pixelRatio).toInt();
  int height = ((image['height'] as int) / 5.5 / pixelRatio).toInt();

  debugPrint(
    'pixelRatio=$pixelRatio speed=$speed density=$density isDynamic=$isDynamic width=$width height=$height'
  );
  // var wImage = img.decodeImage(image['image'])!;
  // for (int x = 0; x < wImage.width; x++) {
  //   for (int y = 0; y < wImage.height; y++) {
  //     var pixel = wImage.getPixel(x, y);
  //     // 判断是否为白色（可以允许一定的容差）
  //     if (pixel.r > 250 && pixel.g > 250 && pixel.b > 250) {
  //       wImage.setPixelRgba(x, y, 0, 0, 0, 0);
  //     }
  //   }
  // }
  debugPrint('--------image: ${(image['image']as Uint8List).lengthInBytes} ');

  var reImage = img.copyResize(
    img.decodeImage(image['image'])!,
    width: width * 8,
    height: height * 8,
    backgroundColor: img.ColorRgb8(0, 0, 0),
  );
  var imageUint8List = Uint8List.fromList(img.encodePng(reImage));
  debugPrint('imageUint8List: ${imageUint8List.lengthInBytes}');
  return [
    _tscClearBuffer(),
    _tscSetup(
      width,
      height,
      density: density,
      speed: speed,
      sensorDistance: isDynamic ? 0 : 2,
    ),
    await _tscBitmap(1, 1, imageUint8List),
    _tscCutter(),
    _tscPrint(),
  ];
}

