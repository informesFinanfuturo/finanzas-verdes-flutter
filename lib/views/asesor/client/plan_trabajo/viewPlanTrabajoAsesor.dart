import 'dart:io';

import 'package:finanzas_verdes/app/routes/subrutes/adminRoutes.dart';
import 'package:finanzas_verdes/app/routes/subrutes/asesorRoutes.dart';
import 'package:finanzas_verdes/controllers/ClientController.dart';
import 'package:finanzas_verdes/controllers/RolController.dart';
import 'package:finanzas_verdes/main.dart';
import 'package:finanzas_verdes/models/api/clientApi.dart';
import 'package:finanzas_verdes/models/api/consumoApi.dart';
import 'package:finanzas_verdes/models/api/planTrabajoApi.dart';
import 'package:finanzas_verdes/models/api/rolApi.dart';
import 'package:finanzas_verdes/models/api/userApi.dart';
import 'package:finanzas_verdes/app/config/Global.dart';
import 'package:finanzas_verdes/utils/WidgetsApp.dart';
import 'package:finanzas_verdes/utils/utils.dart';
import 'package:finanzas_verdes/views/asesor/client/consumo/takePhotoConsumo.dart';
import 'package:finanzas_verdes/views/asesor/client/plan_trabajo/newTareaAsesor.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';

class Viewplantrabajoasesor extends StatefulWidget {
  const Viewplantrabajoasesor({super.key});

  @override
  State<Viewplantrabajoasesor> createState() => _ViewplantrabajoasesorState();
}

class _ViewplantrabajoasesorState extends State<Viewplantrabajoasesor> {

  ClientController clientController = Get.find();

  @override
  Widget build(BuildContext context) {
    return Obx(() => SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          /// ✅ HEADER
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
              Text("Detalle del plan de trabajo",
                  style: GoogleFonts.poppins(fontSize: 18)),
            ],
          ),

          const SizedBox(height: 10),

          /// ✅ PROGRESO DEL PLAN
          Container(
            padding: EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: Global.container,
              borderRadius: BorderRadius.circular(15),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                Text("Progreso",
                    style: TextStyle(fontWeight: FontWeight.bold)),

                SizedBox(height: 8),

                Builder(builder: (context) {
                  final plan = clientController.PlanTrabajo;

                  final porcentaje = double.tryParse(
                      (plan["porcentaje_completado"] ?? "0").toString()
                  ) ?? 0;

                  final total = int.tryParse((plan["total_tareas"] ?? "0").toString()) ?? 0;
                  final completadas = int.tryParse((plan["tareas_completadas"] ?? "0").toString()) ?? 0;

                  return Column(
                    children: [

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("$completadas / $total tareas"),
                          Text("$porcentaje%"),
                        ],
                      ),

                      SizedBox(height: 8),

                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: LinearProgressIndicator(
                          value: (porcentaje / 100),
                          minHeight: 8,
                        ),
                      ),
                    ],
                  );
                }),
              ],
            ),
          ),

          const SizedBox(height: 10),

          /// ✅ INFO DEL PLAN
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Global.container,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                /// 🔹 NOMBRE
                Text(
                  clientController.PlanTrabajo["nombre_plan_trabajo"],
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 5),

                /// 🔹 DESCRIPCIÓN
                if (clientController.PlanTrabajo["descripcion"].isNotEmpty)
                  Text(
                    clientController.PlanTrabajo["descripcion"],
                    style: TextStyle(color: Global.textSecondary),
                  ),
                if (clientController.PlanTrabajo["fecha_fin"] != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.calendar_month,
                          size: 16,
                          color: Colors.orange,
                        ),

                        const SizedBox(width: 6),

                        Text(
                          "Fecha límite: ${Utils.formatFechaBonita(
                            clientController.PlanTrabajo["fecha_fin"],
                          )}",
                          style: TextStyle(
                            color: Global.textSecondary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),

          const SizedBox(height: 15),

          /// ✅ TÍTULO TAREAS
          Text(
            "Tareas",
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 10),

          /// ✅ LISTA DE TAREAS (CHECKLIST)
          Column(
            children: clientController.PlanTrabajo["tareas"].map<Widget>((t) {

              final isDone = t["estado"] == "completada";

              return Container(
                margin: EdgeInsets.symmetric(vertical: 5),
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Global.container,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    Checkbox(
                      value: isDone,
                      onChanged: (v) async {
                        clientController.setPlanTrabajo(await toggleTareaApi(idTarea: t["id_tarea"], updatedBy: controller.User["id_usuario"]));
                        clientController.refreshClient();
                      },
                    ),

                    /// ✅ INFO
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [

                          Text(
                            t["nombre_tarea"],
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              decoration: isDone
                                  ? TextDecoration.lineThrough
                                  : null,
                            ),
                          ),

                          if (t["descripcion"] != null)
                            Text(
                              t["descripcion"],
                              style: TextStyle(
                                fontSize: 12,
                                color: Global.textSecondary,
                              ),
                            ),
                          if (t["fecha_fin"] != null)
                            Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: Row(
                                children: [

                                  const Icon(
                                    Icons.calendar_month,
                                    size: 14,
                                    color: Colors.orange,
                                  ),

                                  const SizedBox(width: 4),

                                  Text(
                                    Utils.formatFechaBonita(
                                      t["fecha_fin"],
                                    ),
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Global.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ),

                    /// ✅ ESTADO VISUAL
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: isDone
                            ? Colors.green.withOpacity(0.2)
                            : Colors.orange.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        isDone ? "Completada" : "Pendiente",
                        style: TextStyle(
                          fontSize: 11,
                          color: isDone ? Colors.green : Colors.orange,
                        ),
                      ),
                    )
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    ));
  }
}