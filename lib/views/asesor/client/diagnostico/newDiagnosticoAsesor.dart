import 'package:finanzas_verdes/app/routes/subrutes/adminRoutes.dart';
import 'package:finanzas_verdes/app/routes/subrutes/asesorRoutes.dart';
import 'package:finanzas_verdes/controllers/ClientController.dart';
import 'package:finanzas_verdes/controllers/ProveedorController.dart';
import 'package:finanzas_verdes/controllers/RolController.dart';
import 'package:finanzas_verdes/controllers/UserController.dart';
import 'package:finanzas_verdes/main.dart';
import 'package:finanzas_verdes/models/api/clientApi.dart';
import 'package:finanzas_verdes/models/api/consumoApi.dart';
import 'package:finanzas_verdes/models/api/diagnosticoApi.dart';
import 'package:finanzas_verdes/models/api/rolApi.dart';
import 'package:finanzas_verdes/models/api/userApi.dart';
import 'package:finanzas_verdes/app/config/Global.dart';
import 'package:finanzas_verdes/utils/WidgetsApp.dart';
import 'package:finanzas_verdes/utils/utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class Newdiagnosticoasesor extends StatefulWidget {
  const Newdiagnosticoasesor({super.key});

  @override
  State<Newdiagnosticoasesor> createState() => _NewdiagnosticoasesorState();
}

class _NewdiagnosticoasesorState extends State<Newdiagnosticoasesor> {

  bool loading = false;

  final clientController = Get.find<ClientController>();


  @override
  Widget build(BuildContext context) {
    return Obx(() => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            InkWell(
              onTap: () {
                controller.backPage();
              },
              borderRadius: BorderRadius.circular(15),
              child: const Padding(
                padding: EdgeInsets.all(8),
                child: Icon(CupertinoIcons.back),
              ),
            ),
            Text("Realizar diagnóstico", style: GoogleFonts.poppins(fontSize: 18)),
            MagicWrapper(
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 5, horizontal: 5),
                decoration: Wapp.ButtonDecorationGradient(Global.primary, Global.secondary),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("Generar diagnóstico", style: TextStyle(color: Colors.white),),
                    SizedBox(width: 5,),
                    Icon(Icons.auto_awesome, color: Colors.white,)
                  ],
                ),
              ),
              onTap: () async {
                print(clientController.Client);
                final response = await generarYSyncDiagnosticosApi(
                  idMipyme: clientController.Preview["mipyme"]["id_mipyme"],
                  empresa: clientController.Preview["mipyme"],
                  activos: clientController.activosVisible.value,
                  facturas: clientController.facturasVisible.value,
                  diagnosticos: clientController.Preview["diagnosticos"]
                );

                clientController.setClient(
                  await getClientDetailApi(
                    idUsuario: clientController.Client["user"]["id_usuario"],
                  ),
                );
                if(response["diagnostico"] != null) {
                  controller.backPage();
                }
              }
            ),
          ],
        ),

        SizedBox(height: 10),

        Expanded(
          child: SingleChildScrollView(
            child: Column(
              children: [
                Text("A continuación se realizará un diagnóstico sobre el estado de la empresa, elimina los datos que no quieras que estén dentro del diagnóstico."),

                SizedBox(height: 10),

                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    color: Global.container
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Información de la empresa", style: GoogleFonts.poppins(fontSize: 18),),
                      SizedBox(height: 10,),
                      _row("Nombre:", clientController.Client["mipyme"]["nombre_mipyme"]),
                      _row("NIT:", clientController.Client["mipyme"]["nit"]),
                      _row("Tipo de persona:", clientController.Client["mipyme"]["tipo_persona"]),
                      _row("Sector:", clientController.Client["mipyme"]["sector_economico"]),
                      _row("Dirección:", clientController.Client["mipyme"]["direccion"]),
                      _row("Departamento:", clientController.Client["mipyme"]["departamento"]),
                      _row("Municipio:", clientController.Client["mipyme"]["municipio"]),
                      _row("Barrio:", clientController.Client["mipyme"]["barrio"]),
                      _row("Estrato:", clientController.Client["mipyme"]["estrato"]),
                      _row("Descripción:", clientController.Client["mipyme"]["descripcion_empresa"]),
                      _row("Empleados:", clientController.Client["mipyme"]["cantidad_empleados"]?.toString()),
                      _row("Ingresos:", clientController.Client["mipyme"]["ingresos"]?.toString()),
                      _row("Egresos:", clientController.Client["mipyme"]["egresos"]?.toString()),
                      _row("Código CIIU:", clientController.Client["mipyme"]["codigo_ciiu"]),
                    ],
                  ),
                ),

                const SizedBox(height: 10),

                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    color: Global.container
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Activos", style: GoogleFonts.poppins(fontSize: 18),),
                      SizedBox(height: 10,),
                      ...clientController.activosVisible.value
                          .asMap()
                          .entries
                          .map<Widget>((entry) {
                        final index = entry.key;
                        final activo = entry.value;

                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Global.absolute,
                            borderRadius: BorderRadius.circular(12),

                            border: Border.all(
                              color: Global.primary.withOpacity(0.2),
                              width: 1,
                            ),

                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.25),
                                blurRadius: 12,
                                offset: Offset(0, 6),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [

                              // ✅ HEADER CLARO
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      activo["nombre"] ?? "Sin nombre",
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),

                                  Container(
                                    decoration: BoxDecoration(
                                      color: Colors.red.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: IconButton(
                                      icon: Icon(Icons.cancel, color: Colors.red, size: 20),
                                      onPressed: () {
                                        clientController.removeActivo(index);
                                      },
                                    ),
                                  )
                                ],
                              ),

                              SizedBox(height: 5),

                              Text("Tipo: ${activo["tipo"] ?? "Desconocido"}"),

                              SizedBox(height: 10),

                              /// ✅ IMÁGENES
                              SizedBox(
                                height: 120,
                                child: activo["imagenes"] == null || activo["imagenes"].isEmpty
                                    ? Center(
                                  child: Text(
                                    "Sin imágenes",
                                    style: TextStyle(color: Global.textSecondary),
                                  ),
                                )
                                    : ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  itemCount: activo["imagenes"].length,
                                  itemBuilder: (context, imgIndex) {
                                    final img = activo["imagenes"][imgIndex];
                                    final url = Utils.buildUrl(img);

                                    return Padding(
                                      padding: const EdgeInsets.only(right: 8),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(10),
                                        child: Image.network(
                                          url,
                                          width: 120,
                                          height: 120,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ],
                  ),
                ),

                const SizedBox(height: 10),

                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    color: Global.container
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Facturas", style: GoogleFonts.poppins(fontSize: 18),),
                      SizedBox(height: 10,),
                      ...
                      clientController.facturasVisible
                          .asMap()
                          .entries
                          .map<Widget>((entry) {

                        final index = entry.key;
                        final consumo = entry.value;

                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Global.absolute,
                            borderRadius: BorderRadius.circular(12),

                            border: Border.all(
                              color: Global.primary.withOpacity(0.2),
                              width: 1,
                            ),

                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.25),
                                blurRadius: 12,
                                offset: Offset(0, 6),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [

                              /// ✅ HEADER
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      consumo["tipo"] ?? "Sin tipo",
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),

                                  Container(
                                    decoration: BoxDecoration(
                                      color: Colors.red.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: IconButton(
                                      icon: Icon(Icons.cancel, color: Colors.red, size: 20),
                                      onPressed: () {
                                        clientController.removeFactura(index);
                                      },
                                    ),
                                  )
                                ],
                              ),

                              SizedBox(height: 5),

                              Text(
                                "Consumo: ${consumo["consumo"] ?? "Desconocido"}",
                                style: TextStyle(color: Global.text.withOpacity(0.7)),
                              ),

                              SizedBox(height: 10),

                              /// ✅ IMÁGENES (bien contenidas)
                              SizedBox(
                                height: 120,
                                child: consumo["imagenes"] == null ||
                                    consumo["imagenes"].isEmpty
                                    ? Center(
                                  child: Text(
                                    "Sin imágenes",
                                    style: TextStyle(color: Global.textSecondary),
                                  ),
                                )
                                    : ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  itemCount: consumo["imagenes"].length,
                                  itemBuilder: (context, imgIndex) {
                                    final img = consumo["imagenes"][imgIndex];
                                    final url = Utils.buildUrl(img);

                                    return Padding(
                                      padding: const EdgeInsets.only(right: 8),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(10),
                                        child: Image.network(
                                          url,
                                          width: 110,
                                          height: 110,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ],
                  ),
                ),
                SizedBox(height: 10,),
              ],
            ),
          ),
        ),
      ],
    ));
  }

  Widget _row(String label, dynamic value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "$label ",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Global.text,
            ),
          ),
          Expanded(
            child: Text(
              value != null && value.toString().isNotEmpty
                  ? value.toString()
                  : "No registrado",
              style: TextStyle(
                color: Global.text.withOpacity(0.7),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
