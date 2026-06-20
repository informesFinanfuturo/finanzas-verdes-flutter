import 'package:finanzas_verdes/app/routes/subrutes/asesorRoutes.dart';
import 'package:finanzas_verdes/controllers/ClientController.dart';
import 'package:finanzas_verdes/main.dart';
import 'package:finanzas_verdes/models/api/activoApi.dart';
import 'package:finanzas_verdes/models/api/clientApi.dart';
import 'package:finanzas_verdes/models/api/consumoApi.dart';
import 'package:finanzas_verdes/models/api/rolApi.dart';
import 'package:finanzas_verdes/models/api/userApi.dart';
import 'package:finanzas_verdes/app/config/Global.dart';
import 'package:finanzas_verdes/utils/WidgetsApp.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class Dashboardclientasesor extends StatefulWidget {
  const Dashboardclientasesor({super.key});

  @override
  State<Dashboardclientasesor> createState() => _DashboardclientasesorState();
}

class _DashboardclientasesorState extends State<Dashboardclientasesor> {
  final ClientController clientController = Get.put(ClientController());

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {

        final isDesktop = constraints.maxWidth > 800;
        final cardWidth = isDesktop
            ? (constraints.maxWidth / 2) - 30
            : constraints.maxWidth;

        return Obx(() {
          final _ = controller.isDark;
          return Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  InkWell(
                    onTap: () => controller.setPage(AsesorRoutes.clients),
                    borderRadius: BorderRadius.circular(15),
                    child: const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Icon(CupertinoIcons.back),
                    ),
                  ),
                  Text(
                    "Dashboard del cliente",
                    style: GoogleFonts.poppins(fontSize: 18),
                  ),
                ],
              ),
              SizedBox(height: 10,),
              Expanded(
                child: SingleChildScrollView(
                  child: Wrap(
                    spacing: 20,
                    runSpacing: 20,
                    children: [

                      // 1. MIPYME
                      Container(
                        width: cardWidth,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Global.container,
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Información de la Mipyme",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Global.text)),
                            SizedBox(height: 10),
                            clientController.Client["mipyme"] == null ?
                            SizedBox(
                              height: 100,
                              child: Center(
                                child: InkWell(
                                  onTap: (){
                                    controller.setPage(AsesorRoutes.newMipyme);
                                  },
                                  borderRadius: BorderRadius.circular(15),
                                  child: Icon(Icons.add_circle, size: 70, color: Global.text.withOpacity(0.6),)
                                ),
                              ),
                            ) :

                            InkWell(
                              onTap: (){
                                controller.setPage(AsesorRoutes.editMipyme);
                              },
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [

                                  _row("Nombre:", clientController.Client["mipyme"]["nombre_mipyme"]),
                                  _row("NIT:", clientController.Client["mipyme"]["nit"]),
                                  _row("Sector:", clientController.Client["mipyme"]["sector_economico"]),
                                  _row("Dirección:", clientController.Client["mipyme"]["direccion"]),
                                  _row("Municipio:", clientController.Client["mipyme"]["municipio"]),
                                  _row("Descripción:", clientController.Client["mipyme"]["descripcion_empresa"]),
                                  _row("Empleados:", clientController.Client["mipyme"]["cantidad_empleados"]?.toString()),
                                  _row("Ingresos:", clientController.Client["mipyme"]["ingresos"]?.toString()),
                                  _row("Egresos:", clientController.Client["mipyme"]["egresos"]?.toString()),
                                  _row("Código CIIU:", clientController.Client["mipyme"]["codigo_ciiu"]),

                                ],
                              ),
                            )
                          ],
                        ),
                      ),

                      Container(
                        width: cardWidth,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Global.container,
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Activos",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Global.text)),
                            SizedBox(height: 10),
                            SizedBox(
                              height: 250,
                              child: SingleChildScrollView(
                                child: Wrap(
                                  spacing: 10,
                                  runSpacing: 10,
                                  children: [
                                    InkWell(
                                      onTap: () {
                                        controller.setPage(AsesorRoutes.newActivo);
                                      },
                                      borderRadius: BorderRadius.circular(15),
                                      child: Container(
                                        height: 100,
                                        width: 200,
                                        decoration: BoxDecoration(
                                          color: Global.primary,
                                          borderRadius: BorderRadius.circular(15),
                                        ),
                                        child: Center(
                                          child: Icon(
                                            Icons.add_circle,
                                            color: Colors.white.withOpacity(0.6),
                                            size: 50,
                                          ),
                                        ),
                                      ),
                                    ),

                                    // ✅ lista activos
                                    ...clientController.Client["activos"].map<Widget>((activo) {
                                      return InkWell(
                                        onTap: () async {
                                          clientController.setActivo(await getActivoApi(idActivo: activo["id_activo"]));
                                          controller.setPage(AsesorRoutes.editActivo);
                                        },
                                        child: Container(
                                          height: 100,
                                          width: 200,
                                          decoration: BoxDecoration(
                                            color: Global.primary,
                                            borderRadius: BorderRadius.circular(15),
                                          ),
                                          child: Column(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              Text(
                                                activo["nombre"] ?? '',
                                                style: GoogleFonts.poppins(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 18,
                                                  color: Colors.white.withOpacity(0.8),
                                                ),
                                              ),
                                              Text(
                                                activo["tipo"] ?? '',
                                                style: GoogleFonts.poppins(
                                                  fontSize: 14,
                                                  color: Colors.white.withOpacity(0.8),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    }).toList(),
                                  ],
                                ),
                              ),
                            )
                          ],
                        ),
                      ),

                      Container(
                        width: cardWidth,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Global.container,
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Facturas de consumo registradas",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Global.text)),
                            SizedBox(height: 10),
                            SizedBox(
                              height: 250,
                              child: SingleChildScrollView(
                                child: Wrap(
                                  spacing: 10,
                                  runSpacing: 10,
                                  children: [
                                    InkWell(
                                      onTap: () {
                                        controller.setPage(AsesorRoutes.newConsumo);
                                      },
                                      borderRadius: BorderRadius.circular(15),
                                      child: Container(
                                        height: 100,
                                        width: 200,
                                        decoration: BoxDecoration(
                                          color: Global.primary,
                                          borderRadius: BorderRadius.circular(15),
                                        ),
                                        child: Center(
                                          child: Icon(
                                            Icons.add_circle,
                                            color: Colors.white.withOpacity(0.6),
                                            size: 50,
                                          ),
                                        ),
                                      ),
                                    ),

                                    // ✅ lista activos
                                    ...clientController.Client["facturas"].map<Widget>((factura) {
                                      return InkWell(
                                        onTap: () async {
                                          clientController.setConsumo(await getConsumoApi(idConsumo: factura["id_consumo"]));
                                          controller.setPage(AsesorRoutes.editConsumo);
                                        },
                                        child: Container(
                                          height: 100,
                                          width: 200,
                                          decoration: BoxDecoration(
                                            color: Global.primary,
                                            borderRadius: BorderRadius.circular(15),
                                          ),
                                          child: Column(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              Text(
                                                factura["tipo"] ?? '',
                                                style: GoogleFonts.poppins(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 18,
                                                  color: Colors.white.withOpacity(0.8),
                                                ),
                                              ),
                                              factura["valor"] == null ? SizedBox() :
                                              Text(
                                                "\$${factura["valor"]}",
                                                style: GoogleFonts.poppins(
                                                  fontSize: 14,
                                                  color: Colors.white.withOpacity(0.8),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    }).toList(),
                                  ],
                                ),
                              ),
                            )
                          ],
                        ),
                      ),

                      // ✅ 3. PLANES
                      Container(
                        width: cardWidth,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Global.container,
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Planes de Trabajo",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Global.text)),
                            const SizedBox(height: 10),
                            Text("• Ahorro energético",
                                style: TextStyle(color: Global.text)),
                            Text("• Gestión residuos",
                                style: TextStyle(color: Global.text)),
                            Text("• Optimización logística",
                                style: TextStyle(color: Global.text)),
                          ],
                        ),
                      ),

                      // ✅ 4. REQUERIMIENTOS
                      Container(
                        width: cardWidth,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Global.container,
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Requerimientos a proveedores",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Global.text)),
                            const SizedBox(height: 10),
                            Text("Paneles solares",
                                style: TextStyle(color: Global.text)),
                            Text("Recolección residuos",
                                style: TextStyle(color: Global.text)),
                          ],
                        ),
                      ),

                      // ✅ 5. OFERTAS
                      Container(
                        width: cardWidth,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Global.container,
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Ofertas de proveedores",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Global.text)),
                            const SizedBox(height: 10),
                            Text("Proveedor A - \$5000",
                                style: TextStyle(color: Global.text)),
                            Text("Proveedor B - \$4800",
                                style: TextStyle(color: Global.text)),
                          ],
                        ),
                      ),

                      // ✅ 6. VISITAS
                      Container(
                        width: cardWidth,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Global.container,
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Visitas realizadas",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Global.text)),
                            const SizedBox(height: 10),
                            Text("12 Mayo - Diagnóstico",
                                style: TextStyle(color: Global.text)),
                            Text("20 Mayo - Seguimiento",
                                style: TextStyle(color: Global.text)),
                          ],
                        ),
                      ),

                      // ✅ 7. DISPOSICIÓN
                      Container(
                        width: cardWidth,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Global.container,
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Disposición de activos",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Global.text)),
                            const SizedBox(height: 10),
                            Text("Reciclado",
                                style: TextStyle(color: Global.text)),
                            Text("En proceso",
                                style: TextStyle(color: Global.text)),
                            Text("Pendiente",
                                style: TextStyle(color: Global.text)),
                          ],
                        ),
                      ),

                    ],
                  ),
                ),
              ),
            ],
          );
        });
      },
    );
  }
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