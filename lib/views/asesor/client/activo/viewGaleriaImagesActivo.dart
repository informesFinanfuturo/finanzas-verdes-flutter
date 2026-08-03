import 'package:finanzas_verdes/controllers/ClientController.dart';
import 'package:finanzas_verdes/models/api/activoApi.dart';
import 'package:finanzas_verdes/models/api/consumoApi.dart';
import 'package:finanzas_verdes/utils/utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';

Future<void> openGaleriaActivo(List imagenes, int initialIndex) async {

  final pageController = PageController(initialPage: initialIndex);
  int currentIndex = initialIndex;

  await Get.dialog(
    StatefulBuilder(
      builder: (context, setState) {
        return Dialog(
          backgroundColor: Colors.black.withOpacity(0.8),
          insetPadding: EdgeInsets.zero,
          child: Stack(
            children: [

              PhotoViewGallery.builder(
                itemCount: imagenes.length,
                pageController: pageController,
                onPageChanged: (index) {
                  currentIndex = index;
                },
                builder: (context, index) {

                  final img = imagenes[index];
                  final url = Utils.buildUrl(img);

                  return PhotoViewGalleryPageOptions(
                    imageProvider: NetworkImage(url),
                    minScale: PhotoViewComputedScale.contained,
                    maxScale: PhotoViewComputedScale.covered * 4,
                  );
                },
              ),

              // BOTÓN CERRAR
              Positioned(
                top: 20,
                right: 20,
                child: _circleBtn(Icons.close, () => Get.back()),
              ),

              /// ✅ BOTÓN ELIMINAR
              Positioned(
                bottom: 20,
                right: 20,
                child: _circleBtn(Icons.delete, () async {

                  final img = imagenes[currentIndex];

                  final activo = Get.find<ClientController>().Activo;

                  await deleteImagenActivoApi(
                    idArchivo: img["id_archivo"],
                  );

                  final updated = await getActivoApi(
                    idActivo: activo["id_activo"],
                  );

                  Get.find<ClientController>().setActivo(updated);

                  /// 🔥 actualizar lista local
                  imagenes.removeAt(currentIndex);

                  if (imagenes.isEmpty) {
                    Get.back();
                    return;
                  }

                  setState(() {
                    if (currentIndex >= imagenes.length) {
                      currentIndex = imagenes.length - 1;
                    }
                    pageController.jumpToPage(currentIndex);
                  });

                }),
              ),

              /// ✅ FLECHA IZQUIERDA (web)
              Positioned(
                left: 10,
                top: 0,
                bottom: 0,
                child: Center(
                  child: _circleBtn(Icons.arrow_back, () {
                    if (currentIndex > 0) {
                      pageController.previousPage(
                        duration: Duration(milliseconds: 200),
                        curve: Curves.ease,
                      );
                    }
                  }),
                ),
              ),

              /// ✅ FLECHA DERECHA (web)
              Positioned(
                right: 10,
                top: 0,
                bottom: 0,
                child: Center(
                  child: _circleBtn(Icons.arrow_forward, () {
                    if (currentIndex < imagenes.length - 1) {
                      pageController.nextPage(
                        duration: Duration(milliseconds: 200),
                        curve: Curves.ease,
                      );
                    }
                  }),
                ),
              ),
            ],
          ),
        );
      },
    ),
  );
}

Widget _circleBtn(IconData icon, VoidCallback onTap) {
  return InkWell(
    onTap: onTap,
    child: Container(
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.6),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: Colors.white),
    ),
  );
}