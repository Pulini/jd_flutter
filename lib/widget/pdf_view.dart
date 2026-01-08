import 'package:flutter/material.dart';
import 'package:flutter_cached_pdfview/flutter_cached_pdfview.dart';
import 'package:jd_flutter/utils/utils.dart';
import 'package:jd_flutter/utils/web_api.dart';
import 'package:jd_flutter/widget/water_mark.dart';

class PDFViewerFromUrl extends StatelessWidget {
  const PDFViewerFromUrl({
    super.key,
    required this.title,
    required this.url,
  });

  final String title;
  final String url;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: Stack(
        children: [
          const PDF().fromUrl(
            url,
            placeholder: (progress) => Center(child: Text('$progress %')),
            errorWidget: (error) => Center(child: Text(error.toString())),
          ),
          IgnorePointer(
            child: WaterMark(
              painter: TextWaterMarkPainter(
                text: '${userInfo?.number} ${userInfo?.name}',
                padding: const EdgeInsets.all(18),
                textStyle: const TextStyle(
                  color: Colors.black12,
                ),
                rotate: -10,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class PDFViewerCachedFromUrl extends StatelessWidget {
  const PDFViewerCachedFromUrl({
    super.key,
    required this.title,
    required this.url,
  });

  final String title;
  final String url;

  @override
  Widget build(BuildContext context) {
    logger.f('跳转到看pfd--------');
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: Stack(
        children: [
          const PDF().cachedFromUrl(
            url,
            placeholder: (progress) => Center(child: Text('$progress %')),
            errorWidget: (error) => Center(child: Text(error.toString())),
          ),
          IgnorePointer(
            child: WaterMark(
              painter: TextWaterMarkPainter(
                text: '${userInfo?.number} ${userInfo?.name}',
                padding: const EdgeInsets.all(18),
                textStyle: const TextStyle(
                  color: Colors.black12,
                ),
                rotate: -10,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
