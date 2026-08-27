import 'dart:io';
import 'dart:ui' as ui;

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image/image.dart' as img;
import 'package:permission_handler/permission_handler.dart';

import 'package:jd_flutter/widget/camera_text_scanner.dart'
    show correctOcrLine, splitOcrLines;

/// 相机预览状态：未开启 / 初始化中 / 就绪 / 出错。
enum CameraStatus { stopped, initializing, ready, error }

/// 轻量代理：仅镜像 [CameraPreviewView] 的状态（[status]）并转发
/// start/stop/recognize 命令给 View。不含任何相机 / UI 逻辑、不继承 ChangeNotifier。
class CameraPreviewController {
  CameraStatus status = CameraStatus.stopped;

  /// 错误回调：与 [CameraPreviewView.onError] 同源，控制器在识别前校验失败时使用。
  ValueChanged<Object>? onError;

  void Function()? _start, _stop;
  Future<List<String>> Function()? _recognize;

  void _attach(
    void Function() start,
    void Function() stop,
    Future<List<String>> Function() recognize,
  ) {
    _start = start;
    _stop = stop;
    _recognize = recognize;
  }

  void start() => _start?.call();
  void stop() => _stop?.call();
  Future<List<String>> recognize() {
    if (_recognize == null) {
      onError?.call(Exception('预览尚未初始化'));
      return Future.value(<String>[]);
    }
    return _recognize!();
  }

  void dispose() {
    _stop?.call();
    _start = _stop = null;
    _recognize = null;
  }
}

/// 相机预览控件：1:1 正方形预览 + 校准框 + 框内 OCR（相机 / UI 逻辑全部在此）。
///
/// - 自身强制 [AspectRatio(aspectRatio: 1)]，不随父布局变形。
/// - [frame] 在初始化时传入，归一化于正方形预览内，绘制与裁剪共用，保证一致。
/// - 挂载即自动开预览；[showResult] 为 true 时在左上角展示识别结果；
///   [onStatusChanged] 把状态变化抛回调用方（无需调用方监听控制器）。
class CameraPreviewView extends StatefulWidget {
  final CameraPreviewController? controller;
  final ui.Rect frame;
  final Color frameColor;
  final double frameStrokeWidth;
  final Color dimColor;
  final bool showResult;
  final ValueChanged<CameraStatus>? onStatusChanged;

  /// 错误回调：控件内部的全部异常（权限/相机初始化/拍照/OCR）均经此抛出，
  /// 控件自身不弹窗、不提示，由调用方决定如何展示（如弹窗、Toast）。
  final ValueChanged<Object>? onError;

  const CameraPreviewView({
    super.key,
    this.controller,
    this.frame = const ui.Rect.fromLTRB(0.1, 0.1, 0.9, 0.9),
    this.frameColor = Colors.white,
    this.frameStrokeWidth = 2.5,
    this.dimColor = const Color(0x80000000),
    this.showResult = false,
    this.onStatusChanged,
    this.onError,
  });

  @override
  State<CameraPreviewView> createState() => _CameraPreviewViewState();
}

class _CameraPreviewViewState extends State<CameraPreviewView> {
  late CameraPreviewController _effective;
  late final bool _ownsController;

  CameraStatus _status = CameraStatus.stopped;
  List<String>? _result;
  bool _busy = false;
  CameraController? _cameraController;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _effective = widget.controller ?? CameraPreviewController();
    _ownsController = widget.controller == null;
    _effective._attach(_start, _stop, _recognize);
    _effective.onError = widget.onError;
    // 延后到首帧再开预览：避免 initState 期间触发父级 onStatusChanged→setState
    WidgetsBinding.instance.addPostFrameCallback((_) => _start());
  }

  @override
  void didUpdateWidget(covariant CameraPreviewView old) {
    if (old.controller != widget.controller) {
      if (_ownsController) _effective.dispose();
      _effective = widget.controller ?? CameraPreviewController();
      _ownsController = widget.controller == null;
      _effective._attach(_start, _stop, _recognize);
      _effective.onError = widget.onError;
      WidgetsBinding.instance.addPostFrameCallback((_) => _start());
    }
    super.didUpdateWidget(old);
  }

  @override
  void dispose() {
    if (_ownsController) _effective.dispose();
    _stop();
    super.dispose();
  }

  /// 统一更新状态：写本地 + 镜像到控制器 + 抛回调 + 重建（去重同一状态）。
  void _setStatus(CameraStatus s) {
    if (_status == s) return;
    _status = s;
    _effective.status = s;
    widget.onStatusChanged?.call(s);
    if (mounted) setState(() {});
  }

  /// 统一失败处理：记错误文案 + 抛 [onError] + 进入 error 态（不向上抛异常）。
  void _fail(Object e) {
    _errorMessage = e.toString();
    widget.onError?.call(e);
    _setStatus(CameraStatus.error);
  }

  /// 打开预览：请求权限 → 选后置摄像头 → 初始化。
  Future<void> _start() async {
    if (_status == CameraStatus.ready || _status == CameraStatus.initializing) {
      return;
    }
    _setStatus(CameraStatus.initializing);
    _errorMessage = null;
    final perm = await Permission.camera.request();
    if (!perm.isGranted) return _fail(Exception('未授予相机权限，无法使用拍照识别'));
    final cameras = await availableCameras();
    if (cameras.isEmpty) return _fail(Exception('未检测到相机设备'));
    final camera = cameras.firstWhere(
      (c) => c.lensDirection == CameraLensDirection.back,
      orElse: () => cameras.first,
    );
    _cameraController = CameraController(
      camera,
      ResolutionPreset.high,
      enableAudio: false,
    );
    try {
      await _cameraController!.initialize();
    } catch (e) {
      return _fail(e);
    }
    _setStatus(CameraStatus.ready);
  }

  /// 关闭预览、释放相机资源。
  Future<void> _stop() async {
    if (_cameraController != null) {
      await _cameraController!.dispose();
      _cameraController = null;
    }
    _setStatus(CameraStatus.stopped);
  }

  /// 拍照 → 仅裁剪 [widget.frame] 框内 → OCR → 按行文本。
  /// 任何异常均经 [onError] 抛出，不向上抛；识别失败时返回空列表。
  Future<List<String>> _recognize() async {
    final cam = _cameraController;
    if (cam == null || !cam.value.isInitialized) {
      _fail(Exception('相机尚未初始化，请先开启预览'));
      return const <String>[];
    }
    _busy = true;
    if (mounted) setState(() {});
    try {
      final bytes = await (await cam.takePicture()).readAsBytes();
      final decoded = img.bakeOrientation(img.decodeImage(bytes)!);
      final crop =
          _cropRectForFrame(decoded.width, decoded.height, widget.frame);
      final cropped = img.copyCrop(
        decoded,
        x: crop.left.toInt(),
        y: crop.top.toInt(),
        width: crop.width.toInt(),
        height: crop.height.toInt(),
      );
      final temp = File(
        '${Directory.systemTemp.path}/ocr_'
        '${DateTime.now().microsecondsSinceEpoch}.png',
      );
      await temp.writeAsBytes(img.encodePng(cropped));
      final recognizer = TextRecognizer(script: TextRecognitionScript.chinese);
      try {
        final text = (await recognizer.processImage(
          InputImage.fromFilePath(temp.path),
        )).text;
        final lines =
            splitOcrLines(text.split('\n').map(correctOcrLine).join('\n'));
        _result = lines;
        return lines;
      } finally {
        await recognizer.close();
        if (await temp.exists()) await temp.delete();
      }
    } catch (e) {
      // 拍照 / 解码 / OCR 异常统一经 onError 抛出，控件内部不弹窗、不向上抛
      widget.onError?.call(e);
      return const <String>[];
    } finally {
      _busy = false;
      if (mounted) setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_status == CameraStatus.error) {
      return AspectRatio(aspectRatio: 1, child: _buildError());
    }
    if (_status == CameraStatus.stopped) {
      return AspectRatio(aspectRatio: 1, child: _buildStopped());
    }

    // 强制 1:1 正方形
    return AspectRatio(
      aspectRatio: 1,
      child: ClipRect(
        child: Stack(
          fit: StackFit.expand,
          children: [
            _buildPreview(),
            if (_busy) const Center(child: CircularProgressIndicator()),
            CustomPaint(
              size: ui.Size.infinite,
              painter: _FramePainter(
                frame: widget.frame,
                color: widget.frameColor,
                stroke: widget.frameStrokeWidth,
                dim: widget.dimColor,
              ),
            ),
            if (widget.showResult && _result != null)
              _buildResultOverlay(_result!),
          ],
        ),
      ),
    );
  }

  Widget _buildError() => Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            _errorMessage ?? '相机初始化失败',
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.red),
          ),
        ),
      );

  Widget _buildStopped() => Center(
        child: ElevatedButton.icon(
          onPressed: _start,
          icon: const Icon(Icons.play_arrow),
          label: const Text('开启预览'),
        ),
      );

  /// 预览左上角的识别结果卡片。
  Widget _buildResultOverlay(List<String> lines) {
    final topPad = MediaQuery.of(context).padding.top;
    return Positioned(
      top: topPad + 8,
      left: 8,
      right: 8,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.black54,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              '识别结果',
              style: TextStyle(color: Colors.white70, fontSize: 11),
            ),
            const SizedBox(height: 4),
            ...lines.map(
              (l) => Text(
                l.isEmpty ? '(空行)' : l,
                style: const TextStyle(
                  color: Colors.white,
                  fontFamily: 'monospace',
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPreview() {
    final cam = _cameraController;
    if (cam == null || !cam.value.isInitialized) {
      return const Center(child: CircularProgressIndicator());
    }
    // CameraPlugin 的 previewSize 为传感器原始尺寸（横屏，宽>高）；
    // 竖屏显示需交换宽高，再用 FittedBox.cover 填满正方形（裁掉溢出，不变形）。
    final w = cam.value.previewSize?.height ?? 1.0;
    final h = cam.value.previewSize?.width ?? 1.0;
    return FittedBox(
      fit: BoxFit.cover,
      child: SizedBox(
        width: w,
        height: h,
        child: CameraPreview(cam),
      ),
    );
  }
}

/// 校准框绘制：框外半透明变暗 + 高亮框线 + 四角装饰。
class _FramePainter extends CustomPainter {
  final ui.Rect frame;
  final Color color;
  final double stroke;
  final Color dim;

  _FramePainter({
    required this.frame,
    required this.color,
    required this.stroke,
    required this.dim,
  });

  @override
  void paint(Canvas canvas, ui.Size size) {
    final rect = ui.Rect.fromLTRB(
      frame.left * size.width,
      frame.top * size.height,
      frame.right * size.width,
      frame.bottom * size.height,
    );

    // 框外变暗：整屏矩形与框内矩形取差集
    final outer = ui.Path()..addRect(ui.Rect.fromLTWH(0, 0, size.width, size.height));
    final inner = ui.Path()..addRect(rect);
    canvas.drawPath(
      ui.Path.combine(ui.PathOperation.difference, outer, inner),
      Paint()..color = dim,
    );

    // 高亮框线
    canvas.drawRect(
      rect,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke,
    );

    // 四角装饰
    final corner = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke * 2;
    const d = 16.0;
    final pts = [
      (rect.topLeft, [const Offset(d, 0), const Offset(0, d)]),
      (rect.topRight, [const Offset(-d, 0), const Offset(0, d)]),
      (rect.bottomLeft, [const Offset(d, 0), const Offset(0, -d)]),
      (rect.bottomRight, [const Offset(-d, 0), const Offset(0, -d)]),
    ];
    for (final (p, offsets) in pts) {
      for (final o in offsets) {
        canvas.drawLine(p, p + o, corner);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _FramePainter old) =>
      old.frame != frame ||
      old.color != color ||
      old.stroke != stroke ||
      old.dim != dim;
}

/// 将“正方形预览内归一化的校准框”映射到“照片像素坐标系”的裁剪矩形。
///
/// 预览采用 cover 填满正方形；照片经 [img.bakeOrientation] 后即为显示方向，
/// 二者宽高比一致，故以下 cover 映射对二者通用（全部以归一化正方形为基准）。
ui.Rect _cropRectForFrame(int imgW, int imgH, ui.Rect frame) {
  final scale = 1.0 / (imgW < imgH ? imgW : imgH);
  final offsetX = (1 - imgW * scale) / 2;
  final offsetY = (1 - imgH * scale) / 2;

  final x = ((frame.left - offsetX) / scale).round().clamp(0, imgW - 1);
  final y = ((frame.top - offsetY) / scale).round().clamp(0, imgH - 1);
  final w = (frame.width / scale).round().clamp(1, imgW - x);
  final h = (frame.height / scale).round().clamp(1, imgH - y);

  return ui.Rect.fromLTWH(
    x.toDouble(),
    y.toDouble(),
    w.toDouble(),
    h.toDouble(),
  );
}
