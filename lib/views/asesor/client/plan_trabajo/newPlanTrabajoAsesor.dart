import 'package:finanzas_verdes/app/routes/subrutes/adminRoutes.dart';
import 'package:finanzas_verdes/app/routes/subrutes/asesorRoutes.dart';
import 'package:finanzas_verdes/controllers/ClientController.dart';
import 'package:finanzas_verdes/controllers/RolController.dart';
import 'package:finanzas_verdes/controllers/UserController.dart';
import 'package:finanzas_verdes/main.dart';
import 'package:finanzas_verdes/models/api/clientApi.dart';
import 'package:finanzas_verdes/models/api/consumoApi.dart';
import 'package:finanzas_verdes/models/api/planTrabajoApi.dart';
import 'package:finanzas_verdes/models/api/rolApi.dart';
import 'package:finanzas_verdes/models/api/userApi.dart';
import 'package:finanzas_verdes/app/config/Global.dart';
import 'package:finanzas_verdes/utils/WidgetsApp.dart';
import 'package:finanzas_verdes/utils/utils.dart';
import 'package:finanzas_verdes/views/asesor/client/plan_trabajo/newTareaAsesor.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class Newplantrabajoasesor extends StatefulWidget {
  const Newplantrabajoasesor({super.key});

  @override
  State<Newplantrabajoasesor> createState() => _NewplantrabajoasesorState();
}

class _NewplantrabajoasesorState extends State<Newplantrabajoasesor> {

  final _formKey = GlobalKey<FormState>();

  final nombreCtrl = TextEditingController();
  final descripcionCtrl = TextEditingController();
  final fechaFinCtrl = TextEditingController();

  DateTime? fechaFin;

  List<Map<String, dynamic>> tareas = [];

  bool loading = false;


  @override
  void dispose() {
    nombreCtrl.dispose();
    descripcionCtrl.dispose();
    super.dispose();
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
              Text("Crear plan de trabajo", style: GoogleFonts.poppins(fontSize: 18)),
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

      await createPlanTrabajoApi(
        nombrePlanTrabajo: nombreCtrl.text,
        descripcion: descripcionCtrl.text,
        idMipyme: clientController.Client["mipyme"]["id_mipyme"],
        createdBy: controller.User["id_usuario"],
        tareas: tareas,
      );

      // ✅ refrescar cliente
      clientController.setClient(
        await getClientDetailApi(
          idUsuario: clientController.Client["user"]["id_usuario"],
        ),
      );

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