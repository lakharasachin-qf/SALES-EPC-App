import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:photo_view/photo_view.dart';
import 'package:sales_app/configs/colors_constant.dart';

class FullScreenImage extends StatelessWidget {
  final String imageUrl;
  final String title;
  final bool isLocalFile; // New parameter to indicate if the image is local

  const FullScreenImage({
    super.key,
    required this.imageUrl,
    required this.title,
    this.isLocalFile = false, // Default to false (network image)
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Scaffold(
        backgroundColor: black,
        body: Column(
          children: [
            AppBar(
              backgroundColor: transparent,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back, color: white),
                onPressed: () => Get.back(),
              ),
              title: Text(title, style: const TextStyle(color: white)),
              centerTitle: true,
              elevation: 0,
            ),
            Expanded(
              child: Center(
                child: PhotoView(
                  imageProvider: isLocalFile
                      ? FileImage(
                          File(imageUrl),
                        ) // Use FileImage for local files
                      : NetworkImage(imageUrl), // Use NetworkImage for URLs
                  backgroundDecoration: const BoxDecoration(
                    color: Colors.black,
                  ),
                  errorBuilder: (context, error, stackTrace) {
                    return const Center(
                      child: Text(
                        'Failed to load image',
                        style: TextStyle(color: Colors.white),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
