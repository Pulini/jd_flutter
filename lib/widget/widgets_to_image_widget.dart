import 'dart:ui' as ui;

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';

//控件转图片byte
class WidgetsToImage extends StatefulWidget {
  final Widget child;
  final bool isRotate90;
  final Function(Map<String,dynamic>) image;

  const WidgetsToImage({
    super.key,
    required this.child,
    required this.image,
    this.isRotate90 = false,
  });

  @override
  State<WidgetsToImage> createState() => _WidgetsToImageState();
}

class _WidgetsToImageState extends State<WidgetsToImage> {
  final GlobalKey containerKey = GlobalKey();
  int width = 0;
  int height = 0;

  Future<Uint8List> capture(GlobalKey key) async {
    try {
      //获取图片
      final boundary =
          key.currentContext!.findRenderObject()! as RenderRepaintBoundary;

      if (boundary.debugNeedsPaint) {
        await Future.delayed(const Duration(milliseconds: 30));
        return capture(key); // 递归调用直到组件绘制完成
      }
      ui.Image image = boundary.toImageSync();
      ByteData? byte;
      if (widget.isRotate90) {
        //旋转图片
        ui.Image rotatedImage = await rotateImage(image);
        byte = await rotatedImage.toByteData(format: ui.ImageByteFormat.png);
      } else {
        byte = await image.toByteData(format: ui.ImageByteFormat.png);
      }
      width=image.width;
      height=image.height;
      return byte!.buffer.asUint8List();
    } catch (e) {
      return captureFormError(key);
    }
  }

  Future<Uint8List> captureFormError(GlobalKey key) async {
    try {
      //获取图片
      final boundary =
          key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
      ui.Image image = boundary.toImageSync();
      //旋转图片
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
    final rotatedSize = Size(size.height, size.width);

    // 创建一个新的 PictureRecorder 和 Canvas
    final paint = ui.Paint();

    final matrix = Matrix4.rotationZ(1.5708) //90度=pi / 2 弧度
      ..translate(-rotatedSize.height / 2, -rotatedSize.width / 2);

    // 设置画布大小
    canvas.translate(rotatedSize.width / 2, rotatedSize.height / 2);
    canvas.transform(matrix.storage);
    canvas.drawImage(image, Offset.zero, paint);

    // 结束绘制并获取 Picture
    final picture = recorder.endRecording();
    final img = await picture.toImage(
      rotatedSize.width.toInt(),
      rotatedSize.height.toInt(),
    );
    return img;
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      widget.image.call({
        "image": await capture(containerKey),
        "width": width,
        "height": height,
      });
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
