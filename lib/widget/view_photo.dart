import 'dart:io';

import 'package:flutter/material.dart';
import 'package:jd_flutter/widget/custom_widget.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';

class ViewFilePhoto extends StatelessWidget {
  const ViewFilePhoto({super.key, required this.photos});

  final List<File> photos;

  @override
  Widget build(BuildContext context) {
    return pageBody(
      title: '查看图片',
      body: PhotoViewGallery.builder(
        backgroundDecoration: const BoxDecoration(
          color: Colors.transparent,
        ),
        scrollPhysics: const BouncingScrollPhysics(),
        itemCount: photos.length,
        builder: (c, i) {
          return PhotoViewGalleryPageOptions(
            imageProvider: FileImage(photos[i]),
            heroAttributes: PhotoViewHeroAttributes(
              tag: photos[i].path,
            ),
          );
        },
      ),
    );
  }
}

class ViewNetPhoto extends StatelessWidget {
  const ViewNetPhoto({super.key, required this.photos});

  final List<String> photos;

  @override
  Widget build(BuildContext context) {
    return pageBody(
      title: '查看图片',
      body: PhotoViewGallery.builder(
        backgroundDecoration: const BoxDecoration(
          color: Colors.transparent,
        ),
        scrollPhysics: const BouncingScrollPhysics(),
        itemCount: photos.length,
        builder: (c, i) {
          return PhotoViewGalleryPageOptions(
            imageProvider: NetworkImage(photos[i]),
            heroAttributes: PhotoViewHeroAttributes(
              tag: photos[i],
            ),
          );
        },
        loadingBuilder: (context, event) {
          if (event == null) {
            return const Center(
              child: Text('Loading'),
            );
          }
          final value = event.cumulativeBytesLoaded /
              (event.expectedTotalBytes ?? event.cumulativeBytesLoaded);
          final percentage = (100 * value).floor();
          return Center(
            child: Text('$percentage%'),
          );
        },
      ),
    );
  }
}
