import 'package:finanzas_verdes/app/config/Global.dart';
import 'package:finanzas_verdes/app/routes/subrutes/adminRoutes.dart';
import 'package:finanzas_verdes/app/routes/subrutes/asesorRoutes.dart';
import 'package:finanzas_verdes/controllers/ClientController.dart';
import 'package:finanzas_verdes/controllers/UserController.dart';
import 'package:finanzas_verdes/main.dart';
import 'package:finanzas_verdes/models/api/clientApi.dart';
import 'package:finanzas_verdes/models/api/userApi.dart';
import 'package:finanzas_verdes/utils/WidgetsApp.dart';
import 'package:finanzas_verdes/utils/utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart';

class Activoscliente extends StatefulWidget {
  const Activoscliente({super.key});

  @override
  State<Activoscliente> createState() => _ActivosclienteState();
}

class _ActivosclienteState extends State<Activoscliente> {
  final ClientController clientController = Get.put(ClientController());

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getActivosByUsuarioApi(
      idUsuario: controller.User["id_usuario"],
      clientController: clientController
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Obx(() {
          final activos = clientController.Activos;

          return SingleChildScrollView(
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Global.container,
                borderRadius: BorderRadius.circular(20),
              ),
              child:
              (activos == null || activos.isEmpty) ?
              Center(child: Text("No hay activos registrados")) :

              Wrap(
                spacing: 15,
                runSpacing: 15,
                children: activos.map<Widget>((activo) {

                  final imagenes = activo["imagenes"] ?? [];

                  return Container(
                    width: 300,
                    decoration: BoxDecoration(
                      color: Global.absolute,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [

                        SizedBox(
                          height: 150,
                          child: imagenes.isEmpty
                              ? Center(
                            child: Icon(Icons.image, size: 50, color: Global.textSecondary),
                          )
                              : ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: imagenes.length,
                            itemBuilder: (context, index) {
                              final img = imagenes[index];
                              final url = Utils.buildUrl(img);

                              return Padding(
                                padding: const EdgeInsets.only(right: 5),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: Image.network(
                                    url,
                                    width: 150,
                                    height: 150,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),

                        Padding(
                          padding: const EdgeInsets.all(10),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [

                              Text(
                                activo["nombre"] ?? "Sin nombre",
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),

                              SizedBox(height: 5),

                              Text(
                                "Tipo: ${activo["tipo"] ?? "Desconocido"}",
                                style: TextStyle(color: Global.text.withOpacity(0.7), fontSize: 18),
                              ),

                              SizedBox(height: 5),

                              Text(
                                activo["descripcion"] ?? "Sin descripción",
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(color: Global.textSecondary, fontSize: 16),
                              ),

                              SizedBox(height: 10),

                              // 🔥 contador de imágenes
                              Row(
                                children: [
                                  Icon(Icons.image, size: 16, color: Global.contrast),
                                  SizedBox(width: 5),
                                  Text("${imagenes.length} ${imagenes.length == 1 ? "imágen" : "imágenes"}",
                                      style: TextStyle(color: Global.contrast)),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              )
            ),
          );
        });
      },
    );
  }
}
