import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/rendering.dart';

///控件转图片byte
class WidgetsToImage extends StatefulWidget {
  final Widget child;
  final Function(Uint8List) image;

  const WidgetsToImage({super.key, required this.child, required this.image});

  @override
  State<WidgetsToImage> createState() => _WidgetsToImageState();
}

class _WidgetsToImageState extends State<WidgetsToImage> {
  final GlobalKey containerKey = GlobalKey();

  Future<Uint8List> capture() async {
    try {
      final boundary = containerKey.currentContext!.findRenderObject()!
      as RenderRepaintBoundary;
      if (boundary.debugNeedsPaint) {
        await Future.delayed(const Duration(milliseconds: 20));
        return capture(); // 递归调用直到组件绘制完成
      }
      final image = await boundary.toImage(pixelRatio: 3);
      final byteData = await image.toByteData(format: ImageByteFormat.png);
      final pngBytes = byteData!.buffer.asUint8List();
      return pngBytes;
    } catch (e) {
      rethrow;
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      capture().then((v) => widget.image.call(v));
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
