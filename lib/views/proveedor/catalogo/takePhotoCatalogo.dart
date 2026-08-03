import 'package:camera/camera.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Takephotocatalogo extends StatefulWidget {
  @override
  _TakephotocatalogoState createState() => _TakephotocatalogoState();
}

class _TakephotocatalogoState extends State<Takephotocatalogo> {
  CameraController? controller;

  @override
  void initState() {
    super.initState();
    initCamera();
  }

  Future<void> initCamera() async {
    final cameras = await availableCameras();
    controller = CameraController(
      cameras[0],
      ResolutionPreset.max,
    );
    await controller!.initialize();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    if (controller == null || !controller!.value.isInitialized) {
      return Center(child: CircularProgressIndicator());
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

          OverlayCamera(),

          // 🔥 TEXTO
          Positioned(
            top: 80,
            left: 20,
            right: 20,
            child: Text(
              "Ubica el ítem dentro del recuadro\nEvita sombras",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
          ),

          // 📸 BOTÓN
          Positioned(
            bottom: 10,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Center(
                child: FloatingActionButton(
                  onPressed: () async {
                    final image = await controller!.takePicture();

                    Navigator.pop(context, image);
                  },
                  child: Icon(Icons.camera),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class OverlayCamera extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ClipPath(
      clipper: HoleClipper(),
      child: Container(
        color: Colors.black.withOpacity(0.6),
      ),
    );
  }
}

class HoleClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path()..addRect(Rect.fromLTWH(0, 0, size.width, size.height));

    final hole = Path()
      ..addRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(
            center: Offset(size.width / 2, size.height / 2),
            width: 350,
            height: 550,
          ),
          Radius.circular(12),
        ),
      );

    return Path.combine(PathOperation.difference, path, hole);
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}