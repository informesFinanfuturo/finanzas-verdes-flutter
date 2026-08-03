import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:photo_view/photo_view.dart';

Future<void> viewOneImageAsesorCliente(XFile imageFile) async {
  await Get.dialog(
    Dialog(
      backgroundColor: Colors.black.withOpacity(0.6),

      insetPadding: EdgeInsets.zero,
      child: Stack(
        children: [

          Center(
            child: PhotoView(
              imageProvider: kIsWeb
                  ? NetworkImage(imageFile.path)
                  : FileImage(
                File(imageFile.path),
              ) as ImageProvider,

              backgroundDecoration: const BoxDecoration(
                color: Colors.transparent,
              ),

              minScale: PhotoViewComputedScale.contained,

              maxScale: PhotoViewComputedScale.covered * 8,
            ),
          ),

          /// ✅ BOTÓN CERRAR
          Positioned(
            top: 20,
            right: 20,
            child: InkWell(
              onTap: () => Get.back(),
              child: Container(
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.6),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.close, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}