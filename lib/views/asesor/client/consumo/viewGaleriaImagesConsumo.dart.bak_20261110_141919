import 'package:finanzas_verdes/controllers/ClientController.dart';
import 'package:finanzas_verdes/models/api/consumoApi.dart';
import 'package:finanzas_verdes/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';

Future<bool> openGaleriaConsumo(
    List imagenes,
    int initialIndex,
    ) async {
  final localImages = List<Map<String, dynamic>>.from(
    imagenes,
  );

  if (localImages.isEmpty) {
    return false;
  }

  final int safeInitialIndex = initialIndex.clamp(
    0,
    localImages.length - 1,
  );

  final pageController = PageController(
    initialPage: safeInitialIndex,
  );

  int currentIndex = safeInitialIndex;
  bool changed = false;
  bool deleting = false;

  final bool? result = await Get.dialog<bool>(
    StatefulBuilder(
      builder: (context, setModalState) {
        return Dialog(
          backgroundColor: Colors.black.withOpacity(0.92),
          insetPadding: EdgeInsets.zero,
          child: Stack(
            children: [
              // Galería
              PhotoViewGallery.builder(
                itemCount: localImages.length,
                pageController: pageController,
                backgroundDecoration:
                const BoxDecoration(
                  color: Colors.transparent,
                ),
                loadingBuilder: (context, event) {
                  return const Center(
                    child: CircularProgressIndicator(
                      color: Colors.white,
                    ),
                  );
                },
                onPageChanged: (index) {
                  setModalState(() {
                    currentIndex = index;
                  });
                },
                builder: (context, index) {
                  final image = localImages[index];
                  final url = Utils.buildUrl(image);

                  return PhotoViewGalleryPageOptions(
                    imageProvider: NetworkImage(url),
                    minScale:
                    PhotoViewComputedScale.contained,
                    maxScale:
                    PhotoViewComputedScale.covered * 8,
                    heroAttributes:
                    PhotoViewHeroAttributes(
                      tag:
                      'consumo-image-${image["id_archivo"] ?? index}',
                    ),
                  );
                },
              ),

              // Botón cerrar
              Positioned(
                top: 20,
                right: 20,
                child: SafeArea(
                  child: _circleBtn(
                    icon: Icons.close_rounded,
                    tooltip: 'Cerrar',
                    onTap: deleting
                        ? null
                        : () {
                      Get.back(
                        result: changed,
                      );
                    },
                  ),
                ),
              ),

              // Botón eliminar
              Positioned(
                bottom: 20,
                right: 20,
                child: SafeArea(
                  child: _circleBtn(
                    icon: deleting
                        ? Icons.hourglass_top_rounded
                        : Icons.delete_outline_rounded,
                    tooltip: deleting
                        ? 'Eliminando...'
                        : 'Eliminar imagen',
                    color: Colors.red,
                    onTap: deleting
                        ? null
                        : () async {
                      final image =
                      localImages[currentIndex];

                      final consumoController =
                      Get.find<ClientController>();

                      final consumo =
                          consumoController.Consumo;

                      final idConsumo =
                      consumo["id_consumo"];

                      if (idConsumo == null) {
                        Get.snackbar(
                          'Error',
                          'No se encontró el consumo relacionado.',
                          snackPosition:
                          SnackPosition.BOTTOM,
                        );
                        return;
                      }

                      setModalState(() {
                        deleting = true;
                      });

                      try {
                        await deleteImagenConsumoApi(
                          idArchivo:
                          image["id_archivo"],
                        );

                        changed = true;

                        // Elimina la imagen de la caché.
                        final url =
                        Utils.buildUrl(image);

                        await NetworkImage(url)
                            .evict();

                        // Actualiza inmediatamente
                        // la galería local.
                        localImages.removeAt(
                          currentIndex,
                        );

                        // Actualiza el consumo global.
                        final updated =
                        await getConsumoApi(
                          idConsumo: idConsumo,
                        );

                        consumoController.setConsumo(
                          updated,
                        );

                        if (localImages.isEmpty) {
                          Get.back(
                            result: true,
                          );
                          return;
                        }

                        if (currentIndex >=
                            localImages.length) {
                          currentIndex =
                              localImages.length - 1;
                        }

                        setModalState(() {
                          deleting = false;
                        });

                        WidgetsBinding.instance
                            .addPostFrameCallback((_) {
                          if (pageController
                              .hasClients) {
                            pageController.jumpToPage(
                              currentIndex,
                            );
                          }
                        });

                        Get.snackbar(
                          'Imagen eliminada',
                          'La imagen fue eliminada correctamente.',
                          snackPosition:
                          SnackPosition.BOTTOM,
                        );
                      } catch (error) {
                        setModalState(() {
                          deleting = false;
                        });

                        Get.snackbar(
                          'Error',
                          'No fue posible eliminar la imagen.',
                          snackPosition:
                          SnackPosition.BOTTOM,
                        );
                      }
                    },
                  ),
                ),
              ),

              // Flecha izquierda
              if (localImages.length > 1)
                Positioned(
                  left: 10,
                  top: 0,
                  bottom: 0,
                  child: Center(
                    child: _circleBtn(
                      icon:
                      Icons.arrow_back_ios_new_rounded,
                      tooltip: 'Imagen anterior',
                      onTap: deleting
                          ? null
                          : () {
                        if (currentIndex > 0) {
                          pageController.previousPage(
                            duration:
                            const Duration(
                              milliseconds: 220,
                            ),
                            curve: Curves.easeOut,
                          );
                        }
                      },
                    ),
                  ),
                ),

              // Flecha derecha
              if (localImages.length > 1)
                Positioned(
                  right: 10,
                  top: 0,
                  bottom: 0,
                  child: Center(
                    child: _circleBtn(
                      icon:
                      Icons.arrow_forward_ios_rounded,
                      tooltip: 'Imagen siguiente',
                      onTap: deleting
                          ? null
                          : () {
                        if (currentIndex <
                            localImages.length - 1) {
                          pageController.nextPage(
                            duration:
                            const Duration(
                              milliseconds: 220,
                            ),
                            curve: Curves.easeOut,
                          );
                        }
                      },
                    ),
                  ),
                ),

              // Contador
              Positioned(
                left: 20,
                bottom: 20,
                child: SafeArea(
                  child: Container(
                    padding:
                    const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color:
                      Colors.black.withOpacity(0.62),
                      borderRadius:
                      BorderRadius.circular(20),
                      border: Border.all(
                        color:
                        Colors.white.withOpacity(0.12),
                      ),
                    ),
                    child: Text(
                      '${currentIndex + 1} de ${localImages.length}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    ),
    barrierDismissible: false,
  );

  // Evita destruir el PageController durante
  // la animación de cierre del diálogo.
  await Future<void>.delayed(
    const Duration(milliseconds: 350),
  );

  pageController.dispose();

  return result ?? changed;
}

Widget _circleBtn({
  required IconData icon,
  required String tooltip,
  required VoidCallback? onTap,
  Color color = Colors.black,
}) {
  return Tooltip(
    message: tooltip,
    child: Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: AnimatedOpacity(
          duration: const Duration(
            milliseconds: 160,
          ),
          opacity: onTap == null ? 0.45 : 1,
          child: Container(
            padding: const EdgeInsets.all(11),
            decoration: BoxDecoration(
              color: color.withOpacity(0.72),
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white.withOpacity(0.14),
              ),
            ),
            child: Icon(
              icon,
              color: Colors.white,
              size: 21,
            ),
          ),
        ),
      ),
    ),
  );
}