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

class Editplantrabajoasesor extends StatefulWidget {
  const Editplantrabajoasesor({super.key});

  @override
  State<Editplantrabajoasesor> createState() => _EditplantrabajoasesorState();
}

class _EditplantrabajoasesorState extends State<Editplantrabajoasesor> {

  final _formKey = GlobalKey<FormState>();

  final nombreCtrl = TextEditingController();
  final descripcionCtrl = TextEditingController();
  final fechaFinCtrl = TextEditingController();

  DateTime? fechaFin;

  bool loading = false;

  List tareas = [];

  ClientController clientController = Get.find<ClientController>();


  @override
  void dispose() {
    nombreCtrl.dispose();
    descripcionCtrl.dispose();
    fechaFinCtrl.dispose();
    super.dispose();
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    if (clientController.PlanTrabajo != null) {
      nombreCtrl.text = clientController.PlanTrabajo["nombre_plan_trabajo"] ?? '';
      descripcionCtrl.text = clientController.PlanTrabajo["descripcion"] ?? '';
      tareas = List.from(clientController.PlanTrabajo["tareas"]);
      final fecha = clientController.PlanTrabajo["fecha_fin"];

      if (fecha != null &&
          fecha.toString().isNotEmpty) {

        fechaFin = DateTime.tryParse(fecha);

        fechaFinCtrl.text =
            Utils.formatFechaBonita(fecha);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() => SingleChildScrollView(
      child: Column(
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
              Text("Editar plan de trabajo", style: GoogleFonts.poppins(fontSize: 18)),
              TextButton(
                onPressed: () async {
                  loading ? null : await _submit();
                },
                child: Center(
                  child: loading
                      ? CircularProgressIndicator(
                    color: Global.primary,
                  )
                      : Text(
                    'Guardar',
                    style: TextStyle(
                      color: Global.text,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Global.container,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [

                    Wapp.input(nombreCtrl, "Nombre del plan", Icons.assignment),
                    const SizedBox(height: 12),

                    Wapp.inputArea(
                      descripcionCtrl,
                      "Descripción",
                      Icons.description,
                      required: false,
                    ),
                    
                    SizedBox(height: 10,),
                    Wapp.dateField(
                      context: context,
                      controller: fechaFinCtrl,
                      label: "Fecha límite",
                      initialDate: fechaFin,
                      onChanged: (date) {
                        fechaFin = date;
                      },
                    ),
                  ],
                ),
              )
          ),
          SizedBox(height: 10,),
          InkWell(
            onTap: () async {
              final tarea = await openAddTareaModal();

              if (tarea != null) {
                setState(() {
                  tareas.add(tarea);
                });
              }
            },
            child: Container(
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                border: Border.all(color: Global.primary),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  Icon(Icons.add),
                  SizedBox(width: 5),
                  Text("Agregar tarea"),
                ],
              ),
            ),
          ),
          SizedBox(height: 10,),
          Column(
            children: tareas.map((t) {
              return Container(
                margin: EdgeInsets.symmetric(vertical: 5),
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Global.container,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(t["nombre_tarea"], style: TextStyle(fontWeight: FontWeight.bold)),
                          if (t["descripcion"] != null)
                            Text(t["descripcion"]),
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
                    IconButton(
                      icon: Icon(Icons.delete, color: Colors.red),
                      onPressed: () {
                        setState(() {
                          tareas.remove(t);
                        });
                      },
                    )
                  ],
                ),
              );
            }).toList(),
          )
        ],
      ),
    ));
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => loading = true);

    try {
      final clientController = Get.find<ClientController>();

      await editPlanTrabajoApi(
        idPlanTrabajo:
        clientController.PlanTrabajo[
        "id_plan_trabajo"],

        nombrePlanTrabajo:
        nombreCtrl.text,

        descripcion:
        descripcionCtrl.text,

        fechaFin: Utils.fechaBackend(fechaFin),

        updatedBy:
        controller.User[
        "id_usuario"],

        tareas: tareas,
      );

      await clientController.refreshClient();

      controller.backPage();

    } catch (e) {
      Get.snackbar(
        'Error',
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      setState(() => loading = false);
    }
  }
}