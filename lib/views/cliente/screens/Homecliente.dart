import 'package:finanzas_verdes/app/config/Global.dart';
import 'package:finanzas_verdes/app/routes/subrutes/adminRoutes.dart';
import 'package:finanzas_verdes/app/routes/subrutes/asesorRoutes.dart';
import 'package:finanzas_verdes/controllers/ClientController.dart';
import 'package:finanzas_verdes/controllers/UserController.dart';
import 'package:finanzas_verdes/main.dart';
import 'package:finanzas_verdes/models/api/clientApi.dart';
import 'package:finanzas_verdes/models/api/userApi.dart';
import 'package:finanzas_verdes/utils/WidgetsApp.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart';

class Homecliente extends StatefulWidget {
  const Homecliente({super.key});

  @override
  State<Homecliente> createState() => _HomeclienteState();
}

class _HomeclienteState extends State<Homecliente> {
  final ClientController clientController = Get.put(ClientController());

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getClienteMipymeApi(
      idUsuario: controller.User["id_usuario"],
      clientController: clientController
    );
    getPlanesTrabajoByUsuario(clientController: clientController);
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Obx(() {
          if (clientController.InfoCliente["nombre_mipyme"] == null) {
            return Center(child: Text("No hay información de la mipyme"));
          }else{
            return SingleChildScrollView(
              child: Column(
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Global.container,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Información de la empresa",
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 15),

                        _row("Nombre:", clientController.InfoCliente["nombre_mipyme"]),
                        _row("NIT:", clientController.InfoCliente["nit"]),
                        _row("Sector:", clientController.InfoCliente["sector_economico"]),
                        _row("Dirección:", clientController.InfoCliente["direccion"]),
                        _row("Municipio:", clientController.InfoCliente["municipio"]),
                        _row("Descripción:", clientController.InfoCliente["descripcion_empresa"]),
                        _row("Empleados:", clientController.InfoCliente["cantidad_empleados"]?.toString()),
                        _row("Ingresos:", clientController.InfoCliente["ingresos"]?.toString()),
                        _row("Egresos:", clientController.InfoCliente["egresos"]?.toString()),
                        _row("Código CIIU:", clientController.InfoCliente["codigo_ciiu"]),

                      ],
                    ),
                  ),
                  SizedBox(height: 10,),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Global.container,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Planes de trabajo", style: TextStyle(fontWeight: FontWeight.bold, color: Global.text)),
                        SizedBox(height: 10),
                        clientController.PlanesTrabajo.length == 0 ?
                        SizedBox(
                          height: 230,
                          child: Center(
                            child: Text("No hay planes de trabajo realizados"),
                          ),
                        ):
                        ListView.builder(
                            itemCount: clientController.PlanesTrabajo.length,
                            shrinkWrap: true,
                            itemBuilder: (context, i) {

                              final plan = clientController.PlanesTrabajo[i];

                              final porcentaje = double.tryParse(
                                  (plan["porcentaje_completado"] ?? "0").toString()
                              ) ?? 0;

                              final total = int.tryParse((plan["total_tareas"] ?? "0").toString()) ?? 0;
                              final completadas = int.tryParse((plan["tareas_completadas"] ?? "0").toString()) ?? 0;

                              return Container(
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
                                    Text(
                                      plan["nombre_plan_trabajo"] ?? "",
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
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
                                      ],
                                    ),
                                    SizedBox(height: 10,),
                                    /// ✅ TAREAS (SOLO INFORMATIVO)
                                    if (plan["tareas"] != null && plan["tareas"].isNotEmpty) ...[

                                      Divider(height: 20),

                                      Text(
                                        "Tareas",
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 13,
                                          color: Global.text,
                                        ),
                                      ),

                                      const SizedBox(height: 6),

                                      Column(
                                        children: (plan["tareas"] as List)
                                            .take(3) // 🔥 máximo 3 para no romper la card
                                            .map<Widget>((t) {

                                          final isDone = t["estado"] == "completada";

                                          return Padding(
                                            padding: const EdgeInsets.symmetric(vertical: 2),
                                            child: Row(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [

                                                /// ✅ ICONO ESTADO (NO INTERACTIVO)
                                                Icon(
                                                  isDone ? Icons.check_circle : Icons.radio_button_unchecked,
                                                  size: 16,
                                                  color: isDone ? Colors.green : Colors.grey,
                                                ),

                                                const SizedBox(width: 6),

                                                /// ✅ TEXTO
                                                Expanded(
                                                  child: Text(
                                                    t["nombre_tarea"] ?? "",
                                                    maxLines: 1,
                                                    overflow: TextOverflow.ellipsis,
                                                    style: TextStyle(
                                                      fontSize: 12,
                                                      decoration:
                                                      isDone ? TextDecoration.lineThrough : null,
                                                      color: isDone
                                                          ? Global.textSecondary
                                                          : Global.text,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          );
                                        }).toList(),
                                      ),

                                      /// ✅ MÁS TAREAS
                                      if ((plan["tareas"] as List).length > 3)
                                        Padding(
                                          padding: const EdgeInsets.only(top: 4),
                                          child: Text(
                                            "+${plan["tareas"].length - 3} tareas más",
                                            style: TextStyle(
                                              fontSize: 11,
                                              color: Global.textSecondary,
                                            ),
                                          ),
                                        ),
                                    ],
                                  ],
                                ),
                              );
                            }
                        )
                      ],
                    ),
                  ),
                ],
              ),
            );
          }
        });
      },
    );
  }

  Widget _row(String label, dynamic value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
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
