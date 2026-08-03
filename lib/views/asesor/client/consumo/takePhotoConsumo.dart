import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'package:path/path.dart' as p;

class Takephotoconsumo extends StatefulWidget {
  const Takephotoconsumo({super.key});

  @override
  State<Takephotoconsumo> createState() => _TakephotoconsumoState();
}

class _TakephotoconsumoState extends State<Takephotoconsumo> {
  CameraController? controller;
  bool takingPhoto = false;

  static const double overlayWidth = 350;
  static const double overlayHeight = 550;
  static const double overlayRadius = 12;

  @override
  void initState() {
    super.initState();
    initCamera();
  }

  Future<void> initCamera() async {
    final cameras = await availableCameras();

    final camera = cameras.firstWhere(
          (c) => c.lensDirection == CameraLensDirection.back,
      orElse: () => cameras.first,
    );

    controller = CameraController(
      camera,
      ResolutionPreset.max,
      enableAudio: false,
    );

    await controller!.initialize();

    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _takeAndCrop() async {
    if (controller == null || !controller!.value.isInitialized || takingPhoto) {
      return;
    }

    try {
      setState(() => takingPhoto = true);

      final originalFile = await controller!.takePicture();
      final croppedFile = await _cropToOverlay(originalFile);

      if (!mounted) return;
      Navigator.pop(context, croppedFile);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error tomando foto: $e')),
      );
    } finally {
      if (mounted) {
        setState(() => takingPhoto = false);
      }
    }
  }

  Future<XFile> _cropToOverlay(XFile originalFile) async {
    final bytes = await File(originalFile.path).readAsBytes();
    final decoded = img.decodeImage(bytes);

    if (decoded == null) {
      throw Exception('No se pudo decodificar la imagen');
    }

    final screenSize = MediaQuery.of(context).size;
    final previewSize = controller!.value.previewSize!;

    // Como en tu preview:
    // width: previewSize.height
    // height: previewSize.width
    final sourceW = previewSize.height;
    final sourceH = previewSize.width;

    final scale = _coverScale(
      srcW: sourceW,
      srcH: sourceH,
      dstW: screenSize.width,
      dstH: screenSize.height,
    );

    final displayedW = sourceW * scale;
    final displayedH = sourceH * scale;

    final cropOffsetX = (displayedW - screenSize.width) / 2;
    final cropOffsetY = (displayedH - screenSize.height) / 2;

    final overlayLeft = (screenSize.width - overlayWidth) / 2;
    final overlayTop = (screenSize.height - overlayHeight) / 2;

    final previewRectLeft = (overlayLeft + cropOffsetX) / scale;
    final previewRectTop = (overlayTop + cropOffsetY) / scale;
    final previewRectWidth = overlayWidth / scale;
    final previewRectHeight = overlayHeight / scale;

    final ratioX = decoded.width / sourceW;
    final ratioY = decoded.height / sourceH;

    int x = (previewRectLeft * ratioX).round();
    int y = (previewRectTop * ratioY).round();
    int w = (previewRectWidth * ratioX).round();
    int h = (previewRectHeight * ratioY).round();

    x = x.clamp(0, decoded.width - 1);
    y = y.clamp(0, decoded.height - 1);
    w = w.clamp(1, decoded.width - x);
    h = h.clamp(1, decoded.height - y);

    final cropped = img.copyCrop(
      decoded,
      x: x,
      y: y,
      width: w,
      height: h,
    );

    final croppedPath = p.join(
      p.dirname(originalFile.path),
      '${p.basenameWithoutExtension(originalFile.path)}_cropped.jpg',
    );

    await File(croppedPath).writeAsBytes(
      img.encodeJpg(cropped, quality: 95),
    );

    return XFile(croppedPath);
  }

  double _coverScale({
    required double srcW,
    required double srcH,
    required double dstW,
    required double dstH,
  }) {
    final scaleX = dstW / srcW;
    final scaleY = dstH / srcH;
    return scaleX > scaleY ? scaleX : scaleY;
  }

  @override
  Widget build(BuildContext context) {
    if (controller == null || !controller!.value.isInitialized) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      body: Stack(
        children: [
          SizedBox.expand(
            child: FittedBox(
              fit: BoxFit.cover,
              child: SizedBox(
                width: controller!.value.previewSize!.height,
                height: controller!.value.previewSize!.width,
                child: CameraPreview(controller!),
              ),
            ),
          ),

          const OverlayCameraConsumo(
            overlayWidth: overlayWidth,
            overlayHeight: overlayHeight,
            radius: overlayRadius,
          ),

          Positioned(
            top: 80,
            left: 20,
            right: 20,
            child: const Text(
              "Ubica la factura dentro del recuadro\nEvita sombras",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
          ),

          Positioned(
            bottom: 10,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Center(
                child: FloatingActionButton(
                  onPressed: takingPhoto ? null : _takeAndCrop,
                  child: takingPhoto
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Icon(Icons.camera),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }
}

class OverlayCameraConsumo extends StatelessWidget {
  final double overlayWidth;
  final double overlayHeight;
  final double radius;

  const OverlayCameraConsumo({
    super.key,
    required this.overlayWidth,
    required this.overlayHeight,
    required this.radius,
  });

  @override
  Widget build(BuildContext context) {
    return ClipPath(
      clipper: HoleClipperConsumo(
        overlayWidth: overlayWidth,
        overlayHeight: overlayHeight,
        radius: radius,
      ),
      child: Container(
        color: Colors.black.withOpacity(0.6),
      ),
    );
  }
}

class HoleClipperConsumo extends CustomClipper<Path> {
  final double overlayWidth;
  final double overlayHeight;
  final double radius;

  HoleClipperConsumo({
    required this.overlayWidth,
    required this.overlayHeight,
    required this.radius,
  });

  @override
  Path getClip(Size size) {
    final path = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height));

    final hole = Path()
      ..addRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(
            center: Offset(size.width / 2, size.height / 2),
            width: overlayWidth,
            height: overlayHeight,
          ),
          Radius.circular(radius),
        ),
      );

    return Path.combine(PathOperation.difference, path, hole);
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}