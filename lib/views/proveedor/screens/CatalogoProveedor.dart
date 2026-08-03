import 'package:finanzas_verdes/app/config/Global.dart';
import 'package:finanzas_verdes/app/routes/subrutes/adminRoutes.dart';
import 'package:finanzas_verdes/app/routes/subrutes/asesorRoutes.dart';
import 'package:finanzas_verdes/app/routes/subrutes/proveedorRoutes.dart';
import 'package:finanzas_verdes/controllers/ClientController.dart';
import 'package:finanzas_verdes/controllers/ProveedorController.dart';
import 'package:finanzas_verdes/controllers/UserController.dart';
import 'package:finanzas_verdes/main.dart';
import 'package:finanzas_verdes/models/api/catalogoApi.dart';
import 'package:finanzas_verdes/models/api/clientApi.dart';
import 'package:finanzas_verdes/models/api/proveedorApi.dart';
import 'package:finanzas_verdes/models/api/userApi.dart';
import 'package:finanzas_verdes/utils/WidgetsApp.dart';
import 'package:finanzas_verdes/utils/utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart';

class Catalogoproveedor extends StatefulWidget {
  const Catalogoproveedor({super.key});

  @override
  State<Catalogoproveedor> createState() => _CatalogoproveedorState();
}

class _CatalogoproveedorState extends State<Catalogoproveedor> {

  final ProveedorController proveedorController = Get.put(ProveedorController());

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getCatalogoProveedorApi(proveedorController: proveedorController);
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Obx(() {
          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: 15,
                  runSpacing: 15,
                  children: [

                    /// ✅ BOTÓN "CREAR ITEM" COMO CARD
                    InkWell(
                      onTap: () async {
                        final userController = Get.put(UserController());
                        await getTipoProveedoresApi(proveedorController: proveedorController);
                        userController.setUser(
                            await getUserDetailApi(idUsuario: controller.User["id_usuario"])
                        );
                        controller.setPage(ProveedorRoutes.newCatalogo);
                      },
                      child: Container(
                        width: constraints.maxWidth > 1000
                            ? 300
                            : constraints.maxWidth > 600
                            ? constraints.maxWidth / 2 - 20
                            : double.infinity,
                        height: 230,
                        decoration: BoxDecoration(
                          color: Global.container,
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(
                            color: Global.primary.withOpacity(0.3),
                            width: 1.5,
                          ),
                        ),
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.add_circle, size: 50, color: Global.primary),
                              SizedBox(height: 10),
                              Text(
                                "Nuevo item",
                                style: TextStyle(
                                  color: Global.primary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    /// ✅ LISTA DE ITEMS

                    ...proveedorController.Catalogo.map<Widget>((item) {
                      final imagenes = item["imagenes"] ?? [];

                      return Container(
                        width: constraints.maxWidth > 1000
                            ? 300
                            : constraints.maxWidth > 600
                            ? constraints.maxWidth / 2 - 20
                            : double.infinity,
                        decoration: BoxDecoration(
                          color: Global.container,
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(15),
                          onTap: () async {
                            proveedorController.setItem(
                              await getItemById(id_item: item["id_item"]),
                            );

                            final userController = Get.put<UserController>(UserController());

                            userController.setUser(
                              await getUserDetailApi(
                                idUsuario: controller.User["id_usuario"],
                              ),
                            );

                            controller.setPage(ProveedorRoutes.editCatalogo);
                          },
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [

                              /// ✅ GALERÍA IMÁGENES (tipo revista)
                              SizedBox(
                                height: 170,
                                child: imagenes.isEmpty
                                    ? Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.vertical(
                                      top: Radius.circular(15),
                                    ),
                                    color: Global.absolute,
                                  ),
                                  child: Center(
                                    child: Icon(
                                      Icons.image,
                                      size: 40,
                                      color: Global.textSecondary,
                                    ),
                                  ),
                                )
                                    : ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  itemCount: imagenes.length,
                                  itemBuilder: (context, index) {
                                    final img = imagenes[index];
                                    final url = Utils.buildUrl(img);

                                    return Padding(
                                      padding: EdgeInsets.only(
                                        right: 5,
                                        left: index == 0 ? 5 : 0,
                                      ),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(10),
                                        child: Image.network(
                                          url,
                                          width: 160,
                                          height: 170,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),

                              /// ✅ CONTENIDO
                              Padding(
                                padding: const EdgeInsets.all(12),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [

                                    /// 🔥 NOMBRE
                                    Text(
                                      item["nombre"] ?? '',
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),

                                    SizedBox(height: 5),

                                    /// 🔹 TIPO
                                    Text(
                                      "Tipo: ${item["tipo_item"]}",
                                      style: TextStyle(
                                        color: Global.text.withOpacity(0.7),
                                      ),
                                    ),

                                    SizedBox(height: 5),

                                    /// 💰 PRECIO
                                    Text(
                                      "\$${item["precio_base"]}",
                                      style: TextStyle(
                                        color: Global.primary,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                      ),
                                    ),

                                    SizedBox(height: 10),

                                    /// ✅ ESPECIFICACIONES (tipo chips)
                                    if (item["especificaciones"] != null)
                                      Wrap(
                                        spacing: 6,
                                        runSpacing: 6,
                                        children: (item["especificaciones"] as Map<String, dynamic>)
                                            .entries
                                            .map<Widget>((e) => Container(
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 8, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: Global.primary.withOpacity(0.08),
                                            borderRadius: BorderRadius.circular(10),
                                          ),
                                          child: Text(
                                            "${e.key}: ${e.value}",
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Global.text,
                                            ),
                                          ),
                                        ))
                                            .toList(),
                                      ),

                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ],
                ),
                SizedBox(height: 10,)
              ],
            )
          );
        });
      },
    );
  }
}
