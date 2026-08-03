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
import 'package:finanzas_verdes/utils/utils.dart';
import 'package:finanzas_verdes/views/asesor/client/requerimiento/selectActivoAsesor.dart';
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
                    onTap: () => controller.backPage(),
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
                                  _row("Tipo de persona:", clientController.Client["mipyme"]["tipo_persona"]),
                                  _row("Tipo de empresa:", clientController.Client["mipyme"]["tipo_empresa"]),
                                  _row("Sector:", clientController.Client["mipyme"]["sector_economico"]),
                                  _row("Dirección:", clientController.Client["mipyme"]["direccion"]),
                                  _row("Departamento:", clientController.Client["mipyme"]["departamento"]),
                                  _row("Municipio:", clientController.Client["mipyme"]["municipio"]),
                                  _row("Barrio:", clientController.Client["mipyme"]["barrio"]),
                                  _row("Estrato:", clientController.Client["mipyme"]["estrato"]),
                                  _rowArea("Descripción:", clientController.Client["mipyme"]["descripcion_empresa"]),
                                  _row("Empleados:", clientController.Client["mipyme"]["cantidad_empleados"]?.toString()),
                                  _rowMoney("Ingresos:", clientController.Client["mipyme"]["ingresos"]?.toString()),
                                  _rowMoney("Egresos:", clientController.Client["mipyme"]["egresos"]?.toString()),
                                  _row("Código CIIU:", clientController.Client["mipyme"]["codigo_ciiu"]),

                                ],
                              ),
                            )
                          ],
                        ),
                      ),

                      // 1. CONSUMOS
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
                            Text("Facturas de consumo",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Global.text)),
                            SizedBox(height: 10),
                            SizedBox(
                              height: 250,
                              child: SingleChildScrollView(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    SingleChildScrollView(
                                      scrollDirection: Axis.horizontal,
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        children: [
                                          Text("Crear nueva factura de:"),
                                          SizedBox(width: 5,),
                                          TextButton(
                                            onPressed: () async {
                                              final idConsumo = await createConsumoApi(tipo: "Energía", idMipyme: clientController.Client["mipyme"]["id_mipyme"], createdBy: controller.User["id_usuario"]);
                                              clientController.setConsumo(await getConsumoApi(idConsumo: idConsumo));
                                              controller.setPage(AsesorRoutes.editConsumo);
                                              clientController.refreshClient();
                                            },
                                            style: TextButton.styleFrom(
                                              foregroundColor: Colors.white,
                                              backgroundColor: Global.primary,
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(12),
                                              ),
                                            ),
                                            child: Text("energía +", style: TextStyle(fontSize: 18),),
                                          ),
                                          SizedBox(width: 5,),
                                          TextButton(
                                            onPressed: () async {
                                              final idConsumo = await createConsumoApi(tipo: "Agua", idMipyme: clientController.Client["mipyme"]["id_mipyme"], createdBy: controller.User["id_usuario"]);
                                              clientController.setConsumo(await getConsumoApi(idConsumo: idConsumo));
                                              controller.setPage(AsesorRoutes.editConsumo);
                                              clientController.refreshClient();
                                            },
                                            style: TextButton.styleFrom(
                                              foregroundColor: Colors.white,
                                              backgroundColor: Global.primary,
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(12),
                                              ),
                                            ),
                                            child: Text("agua +", style: TextStyle(fontSize: 18),),
                                          ),
                                          // SizedBox(width: 5,),
                                          // TextButton(
                                          //   onPressed: () async {
                                          //     final idConsumo = await createConsumoApi(tipo: "Gas", idMipyme: clientController.Client["mipyme"]["id_mipyme"], createdBy: controller.User["id_usuario"]);
                                          //     clientController.setConsumo(await getConsumoApi(idConsumo: idConsumo));
                                          //     controller.setPage(AsesorRoutes.editConsumo);
                                          //     clientController.refreshClient();
                                          //   },
                                          //   style: TextButton.styleFrom(
                                          //     foregroundColor: Colors.white,
                                            //     backgroundColor: Global.primary,
                                          //     shape: RoundedRectangleBorder(
                                          //       borderRadius: BorderRadius.circular(12),
                                          //     ),
                                          //   ),
                                          //   child: Text("gas +", style: TextStyle(fontSize: 18),),
                                          // ),
                                        ],
                                      ),
                                    ),
                                    SizedBox(height: 5,),
                                    clientController.Client["facturas"].length == 0 ?
                                    SizedBox(
                                      height: 200,
                                      child: Center(
                                        child: Text("No hay consumos registrados"),
                                      ),
                                    ) :
                                    Wrap(
                                      spacing: 10,
                                      runSpacing: 10,
                                      children: clientController.Client["facturas"].map<Widget>((factura) {
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
                                                    factura["periodo_inicio"] ?? "Sin fecha",
                                                    style: GoogleFonts.poppins(
                                                      fontWeight: FontWeight.bold,
                                                      fontSize: 18,
                                                      color: Colors.white.withOpacity(0.8),
                                                    ),
                                                  ),
                                                  factura["tipo"] == null ? SizedBox() :
                                                  Text(
                                                    "${factura["tipo"]}",
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
                                    ),
                                  ],
                                ),
                              ),
                            )
                          ],
                        ),
                      ),

                      // 2. ACTIVOS
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
                                                textAlign: TextAlign.center,
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

                      // 3. DIAGNÓSTICOS
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
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text("Diagnósticos realizados", style: TextStyle(fontWeight: FontWeight.bold, color: Global.text)),
                                IconButton(
                                  onPressed: () async {
                                    clientController.setPreview(await getClientFullImagesApi(idUsuario: clientController.Client["user"]["id_usuario"]));
                                    controller.setPage(AsesorRoutes.newDiagnostico);
                                  },
                                  icon: Icon(Icons.add_circle)
                                )
                              ],
                            ),
                            SizedBox(height: 10),
                            clientController.Client["diagnosticos"].length == 0 ?
                            SizedBox(
                              height: 230,
                              child: Center(
                                child: Text("No hay diagnósticos realizados"),
                              ),
                            ):
                            SizedBox(
                              height: 230,
                              child: ListView.builder(
                                itemCount: clientController.Client["diagnosticos"].length,
                                itemBuilder: (context, i){
                                  final diagnostico = clientController.Client["diagnosticos"][i];
                                  return ListTile(
                                    onTap: (){
                                      clientController.setDiagnostico(diagnostico);
                                      controller.setPage(AsesorRoutes.viewDiagnostico);
                                    },
                                    title: Text(diagnostico["titulo"]),
                                    subtitle: diagnostico["problema"]["resumen"] == null ? SizedBox() : Text(diagnostico["problema"]["resumen"]),
                                    trailing: Icon(Icons.navigate_next),
                                  );
                                },
                              ),
                            )
                          ],
                        ),
                      ),

                      // 4. REQUERIMIENTOS
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
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text("Solicitudes enviadas a proveedores", style: TextStyle(fontWeight: FontWeight.bold, color: Global.text)),
                                IconButton(
                                    onPressed: () async {
                                      clientController.setActivo(await openSelectActivoAsesor(clientController.Client["activos"], controller) ?? {});
                                    },
                                    icon: Icon(Icons.add_circle)
                                ),
                              ],
                            ),
                            SizedBox(height: 10,),
                            SizedBox(height: 250,)
                          ],
                        ),
                      ),

                      // 5. PLANES DE TRABAJO
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
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text("Planes de trabajo", style: TextStyle(fontWeight: FontWeight.bold, color: Global.text)),
                                IconButton(
                                  onPressed: () async {
                                    controller.setPage(AsesorRoutes.newPlanTrabajo);
                                  },
                                  icon: Icon(Icons.add_circle)
                                )
                              ],
                            ),
                            SizedBox(height: 10),
                            clientController.Client["planes_trabajo"].length == 0 ?
                            SizedBox(
                              height: 230,
                              child: Center(
                                child: Text("No hay planes de trabajo realizados"),
                              ),
                            ):
                            SizedBox(
                              height: 230,
                              child: ListView.builder(
                                itemCount: clientController.Client["planes_trabajo"].length,
                                  itemBuilder: (context, i) {

                                    final plan = clientController.Client["planes_trabajo"][i];

                                    final porcentaje = double.tryParse(
                                        (plan["porcentaje_completado"] ?? "0").toString()
                                    ) ?? 0;

                                    final total = int.tryParse((plan["total_tareas"] ?? "0").toString()) ?? 0;
                                    final completadas = int.tryParse((plan["tareas_completadas"] ?? "0").toString()) ?? 0;

                                    return InkWell(
                                      onTap: () {
                                        clientController.setPlanTrabajo(plan);
                                        controller.setPage(AsesorRoutes.viewPlanTrabajo);
                                      },
                                      child: Container(
                                        margin: const EdgeInsets.only(bottom: 12),
                                        padding: const EdgeInsets.all(14),
                                        decoration: BoxDecoration(
                                          color: Global.container,
                                          borderRadius: BorderRadius.circular(15),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black.withOpacity(0.2),
                                              blurRadius: 10,
                                              offset: Offset(0, 5),
                                            )
                                          ],
                                        ),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [

                                            /// ✅ NOMBRE
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                Text(
                                                  plan["nombre_plan_trabajo"] ?? "",
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 16,
                                                  ),
                                                ),
                                                IconButton(
                                                  onPressed: (){
                                                    clientController.setPlanTrabajo(plan);
                                                    controller.setPage(AsesorRoutes.editPlanTrabajo);
                                                  },
                                                  icon: Icon(Icons.edit)
                                                )
                                              ],
                                            ),

                                            const SizedBox(height: 5),

                                            /// ✅ DESCRIPCIÓN
                                            if ((plan["descripcion"] ?? "").toString().isNotEmpty)
                                              Text(
                                                plan["descripcion"],
                                                style: TextStyle(
                                                  color: Global.textSecondary,
                                                  fontSize: 13,
                                                ),
                                              ),

                                            const SizedBox(height: 10),

                                            if ((plan["fecha_fin"] ?? "").toString().isNotEmpty)
                                              Padding(
                                                padding: const EdgeInsets.only(top: 6),
                                                child: Row(
                                                  children: [
                                                    Icon(
                                                      Icons.calendar_month,
                                                      size: 16,
                                                      color: Colors.orange,
                                                    ),
                                                    const SizedBox(width: 6),
                                                    Text(
                                                      "Finaliza: ${Utils.formatFechaCorta(plan["fecha_fin"])}",
                                                      style: TextStyle(
                                                        fontSize: 12,
                                                        color: Global.textSecondary,
                                                        fontWeight: FontWeight.w500,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),

                                            SizedBox(height: 10,),

                                            /// ✅ PROGRESO NUMÉRICO
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                Text(
                                                  "$completadas / $total tareas",
                                                  style: TextStyle(fontSize: 13),
                                                ),
                                                Text(
                                                  "$porcentaje%",
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    color: Global.primary,
                                                  ),
                                                ),
                                              ],
                                            ),

                                            const SizedBox(height: 8),

                                            /// ✅ BARRA DE PROGRESO
                                            ClipRRect(
                                              borderRadius: BorderRadius.circular(10),
                                              child: LinearProgressIndicator(
                                                value: porcentaje / 100,
                                                minHeight: 8,
                                                backgroundColor: Colors.white.withOpacity(0.1),
                                                valueColor: AlwaysStoppedAnimation(Global.primary),
                                              ),
                                            ),

                                            const SizedBox(height: 10),

                                            /// ✅ ESTADO + ICONO
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [

                                                Container(
                                                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                                  decoration: BoxDecoration(
                                                    color: porcentaje == 100
                                                        ? Colors.green.withOpacity(0.2)
                                                        : Colors.orange.withOpacity(0.2),
                                                    borderRadius: BorderRadius.circular(8),
                                                  ),
                                                  child: Text(
                                                    porcentaje == 100 ? "Completado" : "En progreso",
                                                    style: TextStyle(
                                                      fontSize: 12,
                                                      color: porcentaje == 100
                                                          ? Colors.green
                                                          : Colors.orange,
                                                    ),
                                                  ),
                                                ),

                                                Icon(
                                                  Icons.arrow_forward_ios,
                                                  size: 14,
                                                  color: Global.textSecondary,
                                                )
                                              ],
                                            )
                                          ],
                                        ),
                                      ),
                                    );
                                  }
                              ),
                            )
                          ],
                        ),
                      ),

                      // 6. OFERTAS
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
                        margin: EdgeInsets.only(bottom: 10),
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

Widget _rowArea(String label, dynamic value) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 3),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Global.text,
          ),
        ),

        const SizedBox(height: 4),

        Text(
          value != null &&
              value.toString().trim().isNotEmpty
              ? value.toString()
              : "No registrado",
          maxLines: 4,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: Global.text.withOpacity(0.7),
          ),
        ),
      ],
    ),
  );
}

Widget _rowMoney(String label, dynamic value) {
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
                ? "\$${Utils.formatMiles(value.toString())}"
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