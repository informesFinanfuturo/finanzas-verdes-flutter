  import 'package:finanzas_verdes/app/config/Global.dart';
  import 'package:finanzas_verdes/controllers/ProveedorController.dart';
  import 'package:finanzas_verdes/main.dart';
  import 'package:finanzas_verdes/models/api/catalogoApi.dart';
  import 'package:finanzas_verdes/utils/WidgetsApp.dart';
  import 'package:flutter/cupertino.dart';
  import 'package:flutter/material.dart';
  import 'package:get/get.dart';
  import 'package:intl/intl.dart';

  class Proveedoresadmin extends StatefulWidget {
    const Proveedoresadmin({super.key});

    @override
    State<Proveedoresadmin> createState() => _ProveedoresadminState();
  }

  class _ProveedoresadminState extends State<Proveedoresadmin> {
    Map<String, dynamic> catalogo = {};
    ProveedorController proveedorController = Get.put(ProveedorController());
    @override
    Widget build(BuildContext context) {
      return Obx(() {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            proveedorController.CatalogoAdmin["productos"] == null ? Center(child: Column(
              children: [
                Text("No hay productos"),
                SizedBox(height: 10,),
                InkWell(
                  onTap: proveedorController.loading.value
                      ? null
                      : () async {
                    await cargarCatalogo();
                  },
                  child: Container(
                    height: 40,
                    width: 180,
                    decoration: Wapp.ButtonDecorationGradient(
                      Global.primary,
                      Global.secondary,
                    ),
                    child: Center(
                      child: proveedorController.loading.value
                          ? const SizedBox(
                        height: 22,
                        width: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                          : const Text(
                        "Obtener Productos",
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
              ],
            ),) :
            Expanded(child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center ,
                  children: [
                    InkWell(
                      onTap: proveedorController.loading.value
                          ? null
                          : () async {
                        await cargarCatalogo();
                      },
                      child: Container(
                        height: 40,
                        width: 150,
                        decoration: Wapp.ButtonDecorationGradient(Global.primary, Global.secondary),
                        child: Center(
                          child: proveedorController.loading.value
                              ? const SizedBox(
                            height: 22,
                            width: 22,
                            child:
                            CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                              : Text(
                            "Obtener productos",
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10,),
                Expanded(child: CatalogoView(catalogo: proveedorController.CatalogoAdmin)),
              ],
            )),
          ],
        );
      });
    }
    Future<void> cargarCatalogo() async {

      proveedorController.loading.value =
      true;

      try {

        final response =
        await testCatalogCrawler();

        proveedorController
            .setCatalogoAdmin(response);

      } catch (e) {

        debugPrint(e.toString());

      } finally {

        proveedorController
            .loading
            .value = false;

      }

    }
  }

  class CatalogoView extends StatelessWidget {
    final Map catalogo;

    const CatalogoView({
      super.key,
      required this.catalogo,
    });

    @override
    Widget build(BuildContext context) {
      final productos =
          (catalogo["productos"] as List?) ?? [];
      final moneyFormat = NumberFormat.currency(
        //locale: 'es_CO',
        symbol: r'$ ',
        decimalDigits: 0,
      );

      return ListView.builder(
        //padding: const EdgeInsets.all(16),
        itemCount: productos.length,
        itemBuilder: (context, index) {
          final producto =
          productos[index] as Map<String, dynamic>;

          final specs =
              producto["especificaciones"]
              as Map<String, dynamic>? ??
                  {};

          return Card(
            margin: const EdgeInsets.only(bottom: 16),
            elevation: 3,
            shape: RoundedRectangleBorder(
              borderRadius:
              BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment:
                CrossAxisAlignment.start,
                children: [

                  /// NOMBRE
                  Text(
                    producto["nombre"] ?? "",
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 8),

                  /// CATEGORIA
                  Chip(
                    label: Text(
                      producto["categoria"] ?? "",
                    ),
                  ),

                  const SizedBox(height: 12),

                  /// PRECIO
                  Text(
                    producto["precio"] == null
                        ? "Agotado"
                        : moneyFormat.format(
                      producto["precio"],
                    ),
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: producto["precio"] == null
                          ? Colors.red
                          : Colors.green,
                    ),
                  ),


                  const SizedBox(height: 12),

                  /// URL
                  SelectableText(
                    producto["url"] ?? "",
                    style: const TextStyle(
                      color: Colors.blue,
                    ),
                  ),

                  const SizedBox(height: 12),

                  /// DESCRIPCION
                  ExpansionTile(
                    tilePadding:
                    EdgeInsets.zero,
                    title: const Text(
                      "Descripción",
                    ),
                    children: [
                      Padding(
                        padding:
                        const EdgeInsets.only(
                          bottom: 12,
                        ),
                        child: Text(
                          producto["descripcion"] ??
                              "",
                        ),
                      ),
                    ],
                  ),

                  /// ESPECIFICACIONES
                  if (specs.isNotEmpty)
                    ExpansionTile(
                      tilePadding:
                      EdgeInsets.zero,
                      title: const Text(
                        "Especificaciones",
                      ),
                      children: [
                        ...specs.entries.map(
                              (e) => ListTile(
                            dense: true,
                            title: Text(
                              e.key,
                              style:
                              const TextStyle(
                                fontWeight:
                                FontWeight
                                    .bold,
                              ),
                            ),
                            subtitle: Text(
                              e.value
                                  .toString(),
                            ),
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          );
        },
      );
    }
  }
