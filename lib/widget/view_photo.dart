import 'dart:io';

import 'package:flutter/material.dart';
import 'package:jd_flutter/widget/custom_widget.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';

class ViewFilePhoto extends StatefulWidget {
  const ViewFilePhoto({super.key, required this.photos});

  final List<File> photos;

  @override
  State<ViewFilePhoto> createState() => _ViewFilePhotoState();
}

class _ViewFilePhotoState extends State<ViewFilePhoto> {
  @override
  Widget build(BuildContext context) {
    return pageBody(
      title: '查看图片',
      body: PhotoViewGallery.builder(
        backgroundDecoration: const BoxDecoration(
          color: Colors.transparent,
        ),
        scrollPhysics: const BouncingScrollPhysics(),
        itemCount: widget.photos.length,
        builder: (c, i) {
          return PhotoViewGalleryPageOptions(
            imageProvider: FileImage(widget.photos[i]),
            heroAttributes: PhotoViewHeroAttributes(
              tag: widget.photos[i].path,
            ),
          );
        },
      ),
    );
  }
}

class ViewNetPhoto extends StatefulWidget {
  const ViewNetPhoto({super.key, required this.photos});

  final List<String> photos;

  @override
  State<ViewNetPhoto> createState() => _ViewNetPhotoState();
}

class _ViewNetPhotoState extends State<ViewNetPhoto> {
  @override
  Widget build(BuildContext context) {
    return pageBody(
      title: '查看图片',
      body: PhotoViewGallery.builder(
        backgroundDecoration: const BoxDecoration(
          color: Colors.transparent,
        ),
        scrollPhysics: const BouncingScrollPhysics(),
        itemCount: widget.photos.length,
        builder: (c, i) {
          return PhotoViewGalleryPageOptions(
            imageProvider: NetworkImage(widget.photos[i]),
            heroAttributes: PhotoViewHeroAttributes(
              tag: widget.photos[i],
            ),
          );
        },
        loadingBuilder: (context, event) {
          if (event == null) {
            return const Center(
              child: Text("Loading"),
            );
          }
          final value = event.cumulativeBytesLoaded /
              (event.expectedTotalBytes ?? event.cumulativeBytesLoaded);
          final percentage = (100 * value).floor();
          return Center(
            child: Text("$percentage%"),
          );
        },
      ),
    );
  }
}
