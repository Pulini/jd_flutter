import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:get/get.dart';

//控件转图片byte
class WidgetsToImage extends StatefulWidget {
  final Widget child;
  final bool isRotate90;
  final Function(Map<String, dynamic>) image;

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
  double pixelRatio = 1;

  Future<Uint8List> capture(GlobalKey key) async {
    try {
      //获取图片
      final boundary =
          key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
      if (boundary.debugNeedsPaint) {
        await Future.delayed(const Duration(milliseconds: 30));
        return capture(key); // 递归调用直到组件绘制完成
      }
      ui.Image image = await boundary.toImage(pixelRatio: pixelRatio);

      ByteData? byte;
      if (widget.isRotate90) {
        //旋转图片
        ui.Image rotatedImage = await rotateImage(image);
        byte = await rotatedImage.toByteData(format: ui.ImageByteFormat.png);
      } else {
        byte = await image.toByteData(format: ui.ImageByteFormat.png);
      }
      width = image.width;
      height = image.height;
      return byte!.buffer.asUint8List();
    } catch (e) {
      await Future.delayed(const Duration(milliseconds: 30));
      return captureFormError(key);
    }
  }

  Future<Uint8List> captureFormError(GlobalKey key) async {
    try {
      //获取图片
      final boundary =
          key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
      ui.Image image = boundary.toImageSync(pixelRatio: pixelRatio);
      ByteData? byte;
      if (widget.isRotate90) {
        //旋转图片
        ui.Image rotatedImage = await rotateImage(image);
        byte = await rotatedImage.toByteData(format: ui.ImageByteFormat.png);
      } else {
        byte = await image.toByteData(format: ui.ImageByteFormat.png);
      }
      width = image.width;
      height = image.height;
      return byte!.buffer.asUint8List();
    } catch (e) {
      await Future.delayed(const Duration(milliseconds: 30));
     return captureFormError(key);
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
      ..translateByDouble(-rotatedSize.height / 2, -rotatedSize.width / 2, 0, 1.0);

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
      pixelRatio = MediaQuery.of(context).devicePixelRatio;
      widget.image.call({
        "image": await capture(containerKey),
        "width": width,
        "height": height,
        "pixelRatio": pixelRatio,
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

/// 离屏把标签控件渲染成图片（不跳转预览页，用于「不显示预览」时直接下发打印）。
///
/// 原理：借助 Overlay 把控件挂载到可视区域之外，它仍会正常参与布局与绘制，
/// 等 [WidgetsToImage] 内部的 RepaintBoundary 绘制完成拿到图片后再移除。
/// 返回值与 [WidgetsToImage] 的回调完全一致：{'image','width','height','pixelRatio'}
///
/// [width] 标签宽度，110mm 模板为 110 * 5.5。
Future<Map<String, dynamic>> captureWidgetOffScreen(
  Widget child, {
  double width = 100 * 5.5,
  double height = 160 * 5.5,
}) {
  var completer = Completer<Map<String, dynamic>>();
  late OverlayEntry entry;
  entry = OverlayEntry(
    builder: (_) => Positioned(
      //移到可视区域外，不干扰界面，但依然会被布局和绘制
      left: -(width + 100),
      top: 0,
      child: Material(
        color: Colors.white,
        child: SizedBox(
          width: width,
          height: height,
          child: WidgetsToImage(
            image: (map) {
              if (!completer.isCompleted) completer.complete(map);
            },
            child: child,
          ),
        ),
      ),
    ),
  );
  //多重策略获取 Overlay（Get.overlayContext 在异步回调链中可能失效，报 No Overlay widget found）
  OverlayState? overlayState;
  //策略1：从当前路由上下文取 Navigator.overlay（最可靠，不依赖 overlayContext）
  try {
    final ctx = Get.context;
    if (ctx != null) overlayState = Navigator.of(ctx).overlay;
  } catch (_) {}
  //策略2：兜底用 Get.overlayContext（同步调用场景可用）
  if (overlayState == null) {
    try {
      final ctx = Get.overlayContext;
      if (ctx != null) overlayState = Overlay.of(ctx);
    } catch (_) {}
  }
  if (overlayState == null) {
    completer.completeError(StateError('No Overlay available'));
    return completer.future;
  }
  overlayState.insert(entry);
  return completer.future.whenComplete(() {
    //延后一帧移除，避免在绘制过程中卸载导致异常
    WidgetsBinding.instance.addPostFrameCallback((_) {
      try {
        entry.remove();
      } catch (_) {}
    });
  });
}
