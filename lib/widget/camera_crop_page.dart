import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image/image.dart' as img;
import 'package:jd_flutter/widget/combination_button_widget.dart';

/// 带框选裁剪的相机拍照页面
class CameraCropPage extends StatelessWidget {
  final double frameWidth;
  final double frameHeight;
  final int quality;
  final String? hintText;

  const CameraCropPage({
    super.key,
    this.frameWidth = 560,
    this.frameHeight = 160,
    this.quality = 85,
    this.hintText,
  });

  @override
  Widget build(BuildContext context) {
    return GetBuilder<CameraCropController>(
      init: CameraCropController(
        frameWidth: frameWidth,
        frameHeight: frameHeight,
        quality: quality,
      ),
      builder: (ctrl) => Scaffold(
        backgroundColor: Colors.black,
        body: Stack(
          fit: StackFit.expand,
          children: [
            // 相机预览
            Obx(() {
              if (ctrl.isInitialized.value && ctrl.controller != null) {
                return CameraPreview(ctrl.controller!);
              }
              return const Center(child: CircularProgressIndicator());
            }),

            // 半透明遮罩 + 框选区域
            _CameraOverlay(
              frameWidth: frameWidth,
              frameHeight: frameHeight,
            ),

            // 顶部提示文字
            Positioned(
              top: 60,
              left: 0,
              right: 0,
              child: Column(
                children: [
                  Text(
                    hintText ?? '拍照识别',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    '请将目标内容对准框内',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                ],
              ),
            ),

            // 框内提示文字
            Positioned(
              left: (MediaQuery.of(context).size.width - frameWidth) / 2,
              top: (MediaQuery.of(context).size.height - frameHeight) / 2,
              width: frameWidth,
              height: frameHeight,
              child: const Center(
                child: Text(
                  '此区域将被裁剪识别',
                  style: TextStyle(color: Colors.white54, fontSize: 14),
                ),
              ),
            ),

            // 操作按钮
            Positioned(
              bottom: 60,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // 取消按钮
                  IconButton(
                    onPressed: () => Get.back(),
                    icon:
                        const Icon(Icons.close, color: Colors.white, size: 36),
                  ),
                  // 拍照按钮
                  Obx(() => GestureDetector(
                        onTap: ctrl.isCapturing.value
                            ? null
                            : ctrl.takePhotoAndCrop,
                        child: Container(
                          width: 72,
                          height: 72,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 4),
                          ),
                          child: Center(
                            child: ctrl.isCapturing.value
                                ? const CircularProgressIndicator(
                                    color: Colors.white)
                                : Container(
                                    width: 58,
                                    height: 58,
                                    decoration: const BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Colors.white,
                                    ),
                                  ),
                          ),
                        ),
                      )),
                  const SizedBox(width: 48),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Getx 控制器
class CameraCropController extends GetxController {
  final double frameWidth;
  final double frameHeight;
  final int quality;

  CameraController? controller;
  final isInitialized = false.obs;
  final isCapturing = false.obs;

  CameraCropController({
    required this.frameWidth,
    required this.frameHeight,
    required this.quality,
  });

  @override
  void onInit() {
    super.onInit();
    _initCamera();
  }

  @override
  void onClose() {
    controller?.dispose();
    super.onClose();
  }

  Future<void> _initCamera() async {
    final cameras = await availableCameras();
    if (cameras.isEmpty) return;

    controller = CameraController(
      cameras.first,
      ResolutionPreset.high,
      enableAudio: false,
      imageFormatGroup:
          Platform.isIOS ? ImageFormatGroup.bgra8888 : ImageFormatGroup.yuv420,
    );

    await controller!.initialize();
    isInitialized.value = true;
  }

  /// 拍照并裁剪框内内容
  Future<void> takePhotoAndCrop() async {
    if (controller == null ||
        !controller!.value.isInitialized ||
        isCapturing.value) {
      return;
    }

    isCapturing.value = true;

    try {
      final file = await controller!.takePicture();
      final imageBytes = await file.readAsBytes();

      // 解码图片
      final codec = await ui.instantiateImageCodec(imageBytes);
      final frameInfo = await codec.getNextFrame();
      final fullImage = frameInfo.image;

      // 计算裁剪区域
      final imageSize =
          Size(fullImage.width.toDouble(), fullImage.height.toDouble());
      final cropRect = _calculateCropRect(imageSize);

      // 裁剪图片
      final croppedBytes = await _cropImage(fullImage, cropRect);

      // 压缩图片
      final compressedBytes = await _compressImage(croppedBytes);

      // 返回结果
      Get.back(result: compressedBytes);
    } catch (e) {
      debugPrint('拍照失败: $e');
      Get.snackbar(
        '提示',
        '拍照失败，请重试',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.black54,
        colorText: Colors.white,
      );
    } finally {
      isCapturing.value = false;
    }
  }

  /// 计算裁剪区域
  Rect _calculateCropRect(Size imageSize) {
    final screenSize = MediaQuery.of(Get.context!).size;

    final previewAspectRatio = imageSize.width / imageSize.height;
    final screenAspectRatio = screenSize.width / screenSize.height;

    double previewDisplayWidth;
    double previewDisplayHeight;

    if (previewAspectRatio > screenAspectRatio) {
      previewDisplayWidth = screenSize.width;
      previewDisplayHeight = screenSize.width / previewAspectRatio;
    } else {
      previewDisplayHeight = screenSize.height;
      previewDisplayWidth = screenSize.height * previewAspectRatio;
    }

    final offsetX = (screenSize.width - previewDisplayWidth) / 2;
    final offsetY = (screenSize.height - previewDisplayHeight) / 2;

    final frameLeft = (screenSize.width - frameWidth) / 2;
    final frameTop = (screenSize.height - frameHeight) / 2;

    final scaleX = imageSize.width / previewDisplayWidth;
    final scaleY = imageSize.height / previewDisplayHeight;

    final cropLeft = (frameLeft - offsetX) * scaleX;
    final cropTop = (frameTop - offsetY) * scaleY;
    final cropWidth = frameWidth * scaleX;
    final cropHeight = frameHeight * scaleY;

    return Rect.fromLTWH(
      cropLeft.clamp(0, imageSize.width - cropWidth),
      cropTop.clamp(0, imageSize.height - cropHeight),
      cropWidth,
      cropHeight,
    );
  }

  /// 裁剪图片
  Future<Uint8List> _cropImage(ui.Image image, Rect cropRect) async {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);

    canvas.drawImageRect(
      image,
      Rect.fromLTWH(
          cropRect.left, cropRect.top, cropRect.width, cropRect.height),
      Rect.fromLTWH(0, 0, cropRect.width, cropRect.height),
      Paint(),
    );

    final croppedImage = await recorder.endRecording().toImage(
          cropRect.width.round(),
          cropRect.height.round(),
        );
    final byteData =
        await croppedImage.toByteData(format: ui.ImageByteFormat.png);

    return byteData!.buffer.asUint8List();
  }

  /// 压缩图片
  Future<Uint8List> _compressImage(Uint8List imageBytes) async {
    final image = img.decodeImage(imageBytes);
    if (image == null) return imageBytes;

    const targetWidth = 800;
    final targetHeight = (targetWidth * frameHeight / frameWidth).round();
    final resized =
        img.copyResize(image, width: targetWidth, height: targetHeight);

    return Uint8List.fromList(img.encodeJpg(resized, quality: quality));
  }
}

/// 半透明遮罩组件
class _CameraOverlay extends StatelessWidget {
  final double frameWidth;
  final double frameHeight;

  const _CameraOverlay({
    required this.frameWidth,
    required this.frameHeight,
  });

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final frameLeft = (screenSize.width - frameWidth) / 2;
    final frameTop = (screenSize.height - frameHeight) / 2;

    return Stack(
      children: [
        // 顶部遮罩
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          height: frameTop,
          child: Container(color: Colors.black54),
        ),
        // 底部遮罩
        Positioned(
          top: frameTop + frameHeight,
          left: 0,
          right: 0,
          bottom: 0,
          child: Container(color: Colors.black54),
        ),
        // 左侧遮罩
        Positioned(
          top: frameTop,
          left: 0,
          width: frameLeft,
          height: frameHeight,
          child: Container(color: Colors.black54),
        ),
        // 右侧遮罩
        Positioned(
          top: frameTop,
          left: frameLeft + frameWidth,
          right: 0,
          height: frameHeight,
          child: Container(color: Colors.black54),
        ),

        // 框选区域边框
        Positioned(
          left: frameLeft,
          top: frameTop,
          width: frameWidth,
          height: frameHeight,
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.orange, width: 2),
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ),

        // 四角装饰
        _CornerDecorations(
            left: frameLeft,
            top: frameTop,
            frameWidth: frameWidth,
            frameHeight: frameHeight),
      ],
    );
  }
}

/// 四角装饰
class _CornerDecorations extends StatelessWidget {
  final double left;
  final double top;
  final double frameWidth;
  final double frameHeight;

  const _CornerDecorations({
    required this.left,
    required this.top,
    required this.frameWidth,
    required this.frameHeight,
  });

  @override
  Widget build(BuildContext context) {
    const cornerSize = 20.0;
    const cornerThickness = 3.0;
    const cornerColor = Colors.orange;

    return Stack(
      children: [
        // 左上角
        Positioned(
          left: left - 1,
          top: top - 1,
          child: Container(
            width: cornerSize,
            height: cornerSize,
            decoration: const BoxDecoration(
              border: Border(
                left: BorderSide(color: cornerColor, width: cornerThickness),
                top: BorderSide(color: cornerColor, width: cornerThickness),
              ),
            ),
          ),
        ),
        // 右上角
        Positioned(
          left: left + frameWidth - cornerSize + 1,
          top: top - 1,
          child: Container(
            width: cornerSize,
            height: cornerSize,
            decoration: const BoxDecoration(
              border: Border(
                right: BorderSide(color: cornerColor, width: cornerThickness),
                top: BorderSide(color: cornerColor, width: cornerThickness),
              ),
            ),
          ),
        ),
        // 左下角
        Positioned(
          left: left - 1,
          top: top + frameHeight - cornerSize + 1,
          child: Container(
            width: cornerSize,
            height: cornerSize,
            decoration: const BoxDecoration(
              border: Border(
                left: BorderSide(color: cornerColor, width: cornerThickness),
                bottom: BorderSide(color: cornerColor, width: cornerThickness),
              ),
            ),
          ),
        ),
        // 右下角
        Positioned(
          left: left + frameWidth - cornerSize + 1,
          top: top + frameHeight - cornerSize + 1,
          child: Container(
            width: cornerSize,
            height: cornerSize,
            decoration: const BoxDecoration(
              border: Border(
                right: BorderSide(color: cornerColor, width: cornerThickness),
                bottom: BorderSide(color: cornerColor, width: cornerThickness),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

void cameraCropResultDialog({
  required Uint8List imageBytes,
  required Function() retake,
  required Function() identify,
}) {
  final sizeKB = (imageBytes.length / 1024).toStringAsFixed(1);
  Get.dialog(
    Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 400),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(12)),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.photo_camera,
                    size: 20,
                    color: Colors.orange,
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    '拍照结果',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    icon: const Icon(Icons.close, size: 20),
                    onPressed: () => Get.back(),
                  ),
                ],
              ),
            ),
            Flexible(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    // 图片
                    Container(
                      constraints: const BoxConstraints(maxHeight: 400),
                      margin: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.memory(
                          imageBytes,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            size: 14,
                            color: Colors.grey.shade600,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '图片大小: $sizeKB KB',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Row(
                      children: [
                        Expanded(child: CombinationButton(
                          text: '重拍',
                          combination: Combination.left,
                          backgroundColor: Colors.orange,
                          click: () {
                            Get.back();
                            retake.call();
                          },
                        )),
                        Expanded(child: CombinationButton(
                          text: '识别',
                          combination: Combination.right,
                          click: () {
                            Get.back();
                            identify.call();
                          },
                        )),
                      ],
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    ),
    barrierDismissible: false,
  );
}
