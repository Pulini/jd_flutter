import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';

//控件转图片byte
class WidgetsToImage extends StatefulWidget {
  final Widget child;
  final Function(Uint8List) image;

  const WidgetsToImage({super.key, required this.child, required this.image});

  @override
  State<WidgetsToImage> createState() => _WidgetsToImageState();
}

class _WidgetsToImageState extends State<WidgetsToImage> {
  final GlobalKey containerKey = GlobalKey();

  Future<Uint8List> capture(GlobalKey key) async {
    try {
      final boundary =
          key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
      if (boundary.debugNeedsPaint) {
        await Future.delayed(const Duration(milliseconds: 30));
        return capture(key); // 递归调用直到组件绘制完成
      }
      ui.Image image = boundary.toImageSync(pixelRatio: 2);
      ui.Image rotatedImage = await rotateImage(image);
      var byte = await rotatedImage.toByteData(format: ui.ImageByteFormat.png);
      return byte!.buffer.asUint8List();
    } catch (e) {
      rethrow;
    }
  }

  Future<ui.Image> rotateImage(ui.Image image) async {
    final recorder = ui.PictureRecorder();
    final canvas = ui.Canvas(recorder);
    final size = Size(image.width.toDouble(), image.height.toDouble());

    // 计算旋转后的尺寸
    final rotatedSize = Size(
      size.height,
      size.width,
    );

    // 创建一个新的 PictureRecorder 和 Canvas
    final paint = ui.Paint();

    final matrix = Matrix4.rotationZ(1.5708) //90度=pi / 2 弧度
      ..translate(
        -rotatedSize.height / 2,
        -rotatedSize.width / 2,
      );

    // 设置画布大小
    canvas.translate(rotatedSize.width / 2, rotatedSize.height / 2);
    canvas.transform(matrix.storage);
    canvas.drawImage(image, Offset.zero, paint);

    // 结束绘制并获取 Picture
    final picture = recorder.endRecording();
    final img = await picture.toImage(
        rotatedSize.width.toInt(), rotatedSize.height.toInt());
    return img;
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      capture(containerKey).then((v) => widget.image.call(v));
    });
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      key: containerKey,
      child: widget.child,
    );
  }
}
