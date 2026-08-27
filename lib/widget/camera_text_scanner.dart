import 'dart:async';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:permission_handler/permission_handler.dart';

/// ============================================================================
/// 纯 OCR 辅助函数（无 Flutter 依赖，便于单测与复用）
/// ============================================================================

/// OCR 易错字符纠错映射表（字母 -> 实际数字）。
/// 仅在数字字段生效：把“被误识别成字母的数字”还原，避免 OCR 把 0/O、1/I 等混淆。
const Map<String, String> ocrCharToDigit = {
  // 0 易被读成
  'O': '0', 'o': '0', 'D': '0', 'Q': '0',
  // 1
  'I': '1', 'l': '1', 'i': '1', 'L': '1', '|': '1',
  // 2
  'Z': '2', 'z': '2',
  // 3
  'E': '3', 'e': '3',
  // 4
  'A': '4', 'a': '4',
  // 5
  'S': '5', 's': '5',
  // 6
  'G': '6', 'g': '6',
  // 7
  'T': '7', 't': '7',
  // 8
  'B': '8', 'b': '8',
  // 9
  'q': '9',
};

/// 仅对“含数字”的连续片段做纠错：把片段内混入的易错字母还原为数字，
/// 纯文本片段（如 MADE IN CHINA、TOTAL CTNS）不含数字，保持原样，避免误伤英文单词。
///
/// 例：
/// - '59586941O002' -> '595869410002'（O 夹在数字间被还原）
/// - 'TOTAL CTNS:3l2' -> 'TOTAL CTNS:312'（仅数字段内的 l 被还原，TOTAL 不变）
/// - 'MADE IN CHINA' -> 'MADE IN CHINA'（无数字，不纠错）
String correctOcrLine(String line) {
  return line.replaceAllMapped(
    RegExp(
      r'(?=[0-9OoDQIilL|ZzSsBbEeAaGgTtq]*[0-9])[0-9OoDQIilL|ZzSsBbEeAaGgTtq]+',
    ),
    (m) => m.group(0)!.replaceAllMapped(
      RegExp(r'[OoDQIilL|ZzSsBbEeAaGgTtq]'),
      (c) => ocrCharToDigit[c.group(0)]!,
    ),
  );
}

/// 将 OCR 原始文本按行拆分（trim + 过滤空行），返回按行放入的字符列表。
List<String> splitOcrLines(String rawText) {
  return rawText
      .split(RegExp(r'\r?\n'))
      .map((l) => l.trim())
      .where((l) => l.isNotEmpty)
      .toList();
}

/// 拍照识别 OCR 工具类控件（全屏页）。
///
/// 识别完成后通过 [Navigator.pop] 返回**按行拆分的文本列表 `List<String>`**，
/// 取消则返回 null；若相机权限不足或初始化失败，则通过 [onError] / `.then` 的
/// `onError` 回调抛出错误信息，而非停留在报错页。
///
/// 用法：
/// ```dart
/// CameraTextScanner.scan(context).then((data) {
///   // data 为 List<String>，取消时为 null
/// }, onError: (e) {
///   // e 为错误信息（如未授予相机权限）
/// });
/// ```
class CameraTextScanner extends StatefulWidget {
  /// 打开识别页并返回结果。
  ///
  /// [enableCorrection] 控制是否对识别文本做 OCR 易错字符纠错（0/O、1/I 等），
  /// 默认开启。其余参数与构造一致。
  static Future<List<String>?> scan(
    BuildContext context, {
    TextRecognitionScript script = TextRecognitionScript.chinese,
    ResolutionPreset resolutionPreset = ResolutionPreset.high,
    bool enableCorrection = true,
    double previewScale = 0.9,
  }) {
    final completer = Completer<List<String>?>();
    Navigator.push<List<String>?>(
      context,
      MaterialPageRoute(
        builder: (_) => CameraTextScanner(
          script: script,
          resolutionPreset: resolutionPreset,
          enableCorrection: enableCorrection,
          previewScale: previewScale,
          onResult: completer.complete,
          onError: completer.completeError,
        ),
      ),
    ).whenComplete(() {
      // 用户主动关闭页面（非结果、非错误）时按"取消"处理
      if (!completer.isCompleted) completer.complete(null);
    });
    return completer.future;
  }

  /// 识别语言脚本，默认中文。
  final TextRecognitionScript script;

  /// 相机分辨率，默认 high；PDA 内存吃紧可降为 medium。
  final ResolutionPreset resolutionPreset;

  /// 是否开启 OCR 易错字符纠错（0/O、1/I、5/S 等），默认开启。
  final bool enableCorrection;

  /// 预览整体缩放比例（基于满铺尺寸），默认 0.8。
  /// 仅在“不变形、不裁边”的前提下等比缩小预览，便于在四周留出操作/提示空间。
  final double previewScale;

  /// 识别成功回调，返回按行拆分的 `List<String>`。
  final void Function(List<String> lines)? onResult;

  /// 失败回调（无相机权限 / 初始化失败 / 识别异常），返回错误信息。
  final void Function(String error)? onError;

  const CameraTextScanner({
    super.key,
    this.script = TextRecognitionScript.chinese,
    this.resolutionPreset = ResolutionPreset.high,
    this.enableCorrection = true,
    this.previewScale = 0.8,
    this.onResult,
    this.onError,
  });

  @override
  State<CameraTextScanner> createState() => _CameraTextScannerState();
}

class _CameraTextScannerState extends State<CameraTextScanner> {
  CameraController? _controller;
  late final TextRecognizer _recognizer =
      TextRecognizer(script: widget.script);

  bool _isInitializing = true;
  bool _isBusy = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _initCamera();
  }

  Future<void> _initCamera() async {
    final status = await Permission.camera.request();
    if (!status.isGranted) {
      _fail('未授予相机权限，无法使用拍照识别');
      return;
    }
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        _fail('未检测到相机设备');
        return;
      }
      final camera = cameras.firstWhere(
        (c) => c.lensDirection == CameraLensDirection.back,
        orElse: () => cameras.first,
      );
      // 按屏幕比例挑选最接近的后置分辨率，使 letterbox 留白最小（不裁边）
      _controller = CameraController(
        camera,
        await _pickBestPreset(camera),
        enableAudio: false,
      );
      await _controller!.initialize();
    } catch (e) {
      _fail('相机初始化失败: $e');
      return;
    }
    if (mounted) setState(() => _isInitializing = false);
  }

  /// 从候选分辨率里选出“传感器比例最接近当前屏幕宽高比”的，
  /// 让铺满时的 letterbox 留白最小。手机屏幕普遍比相机宽，只能最小化、无法消除留白
  /// （这是“不裁掉边缘”的几何代价）。
  ///
  /// 注：竖屏时 CameraPreview 会自动对比例取倒数，因此无论横竖屏，
  /// 都直接比较“传感器比例”与“屏幕 宽/高”即可对齐。
  Future<ResolutionPreset> _pickBestPreset(CameraDescription camera) async {
    final screenRatio = MediaQuery.of(context).size.width /
        MediaQuery.of(context).size.height;
    // 从最宽到最方尝试，优先更宽的比例（更贴近宽屏手机）
    final candidates = <ResolutionPreset>{
      widget.resolutionPreset,
      ResolutionPreset.max,
      ResolutionPreset.ultraHigh,
      ResolutionPreset.veryHigh,
      ResolutionPreset.high,
      ResolutionPreset.medium,
    }.toList();

    ResolutionPreset best = widget.resolutionPreset;
    double bestDiff = double.infinity;
    // 限制初始化次数以控制首屏耗时，最多试前 3 个
    for (final p in candidates.take(3)) {
      final c = CameraController(camera, p, enableAudio: false);
      try {
        await c.initialize();
        final diff = (c.value.aspectRatio - screenRatio).abs();
        if (diff < bestDiff) {
          bestDiff = diff;
          best = p;
        }
      } catch (_) {
        // 该分辨率不可用，跳过
      } finally {
        await c.dispose();
      }
    }
    return best;
  }

  /// 失败统一出口：触发 onError 后关闭页面。
  void _fail(String msg) {
    if (!mounted) return;
    _error = msg;
    widget.onError?.call(msg);
    Navigator.pop(context);
  }

  /// 拍照 -> OCR -> 按行拆分 -> 返回 `List<String>`
  Future<void> _captureAndRecognize() async {
    if (_controller == null || !_controller!.value.isInitialized) return;
    if (_isBusy) return;
    setState(() => _isBusy = true);
    try {
      final file = await _controller!.takePicture();
      final text = await _recognizer.processImage(
        InputImage.fromFilePath(file.path),
      );
      var raw = text.text;
      // 开启纠错时，仅对“含数字的片段”还原易错字母（不误伤英文单词）
      if (widget.enableCorrection) {
        raw = raw
            .split('\n')
            .map((l) => correctOcrLine(l))
            .join('\n');
      }
      final lines = splitOcrLines(raw);
      if (mounted) {
        widget.onResult?.call(lines);
        Navigator.pop(context, lines);
      }
    } catch (e) {
      if (mounted) _fail('识别失败: $e');
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    _recognizer.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          // 预览区域：铺满整屏，内部 CameraPreview 按相机原生比例居中（letterbox，无变形）
          Positioned.fill(child: _buildPreview()),
          // 顶部行：左上角返回键 + 其右侧的操作提示条
          Positioned(
            top: MediaQuery.of(context).padding.top + 8,
            left: 12,
            right: 12,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _buildCloseButton(),
                const SizedBox(width: 12),
                Expanded(child: _buildHintBar()),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: _buildCaptureButton(),
    );
  }

  /// 左上角返回键（圆形半透明底 + 关闭图标）
  Widget _buildCloseButton() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black54,
        shape: BoxShape.circle,
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: IconButton(
        icon: const Icon(Icons.close, color: Colors.white),
        tooltip: '返回',
        onPressed: () => Navigator.pop(context),
      ),
    );
  }

  /// 拍照按钮（美化：圆形快门风格 + 阴影 + 加载态）
  Widget _buildCaptureButton() {
    return FloatingActionButton(
      onPressed: _isBusy ? null : _captureAndRecognize,
      backgroundColor: _isBusy ? Colors.grey : Colors.indigo,
      foregroundColor: Colors.white,
      elevation: 8,
      tooltip: '拍照识别',
      child: _isBusy
          ? const SizedBox(
              width: 26,
              height: 26,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                color: Colors.white,
              ),
            )
          : const Icon(Icons.camera_alt, size: 30),
    );
  }

  /// 底部操作提示条（美化：圆角卡片 + 提示图标 + 半透明底）
  Widget _buildHintBar() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
      decoration: BoxDecoration(
        color: Colors.black54,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white24),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: const Row(
        children: [
          Icon(Icons.tips_and_updates_outlined,
              color: Colors.white70, size: 18),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              '将纸箱对准取景框，确保第 1 / 2 / 4 行数字清晰，点击右下角拍照识别',
              style: TextStyle(color: Colors.white, fontSize: 13, height: 1.3),
            ),
          ),
        ],
      ),
    );
  }

  /// 预览按相机传感器原始比例渲染，避免被拉伸变形。
  Widget _buildPreview() {
    if (_isInitializing) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null ||
        _controller == null ||
        !_controller!.value.isInitialized) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.camera_alt_outlined, size: 48, color: Colors.grey[600]),
            const SizedBox(height: 12),
            Text(_error ?? '相机不可用', textAlign: TextAlign.center),
          ],
        ),
      );
    }
    // CameraPreview 内部已按设备方向用 AspectRatio 保持比例（不变形、不裁边）；
    // 外层用 Center 居中后，再用 Transform.scale 整体等比缩放到 previewScale，
    // 预览内容完整保留、不变形，仅在四周留出更多空间（便于放置提示/返回键）。
    return Transform.scale(
      scale: widget.previewScale,
      child: Center(child: CameraPreview(_controller!)),
    );
  }
}
