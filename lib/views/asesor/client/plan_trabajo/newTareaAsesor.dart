import 'package:finanzas_verdes/utils/utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

Future<Map<String, dynamic>?> openAddTareaModal() async {

  final nombreCtrl = TextEditingController();
  final descripcionCtrl = TextEditingController();
  final fechaFinCtrl = TextEditingController();

  DateTime? fechaFin;

  return await Get.dialog<Map<String, dynamic>>(
    AlertDialog(
      title: Text("Nueva tarea"),

      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [

          TextField(
            controller: nombreCtrl,
            decoration: InputDecoration(
              labelText: "Nombre de la tarea",
            ),
          ),

          SizedBox(height: 10),

          TextField(
            controller: descripcionCtrl,
            decoration: InputDecoration(
              labelText: "Descripción",
            ),
          ),

          SizedBox(height: 10),

          TextField(
            controller: fechaFinCtrl,
            readOnly: true,
            decoration: const InputDecoration(
              labelText: "Fecha límite",
              suffixIcon: Icon(Icons.calendar_month),
            ),
            onTap: () async {

              final selected = await showDatePicker(
                context: Get.context!,
                initialDate: fechaFin ?? DateTime.now(),
                firstDate: DateTime(2020),
                lastDate: DateTime(2100),
              );

              if (selected == null) return;

              fechaFin = selected;

              fechaFinCtrl.text =
              "${selected.day.toString().padLeft(2, '0')}/"
                  "${selected.month.toString().padLeft(2, '0')}/"
                  "${selected.year}";
            },
          ),
        ],
      ),

      actions: [

        TextButton(
          onPressed: () {
            Get.back();
          },
          child: Text("Cancelar"),
        ),

        ElevatedButton(
          onPressed: () {
            if (nombreCtrl.text.trim().isEmpty) {
              Get.snackbar("Error", "El nombre es obligatorio");
              return;
            }

            final tarea = {
              "nombre_tarea": nombreCtrl.text.trim(),

              "descripcion":
              descripcionCtrl.text.trim().isEmpty
                  ? null
                  : descripcionCtrl.text.trim(),

              "fecha_fin":
              fechaFin == null
                  ? null
                  : Utils.fechaBackend(fechaFin),

              "estado": "pendiente",
            };

            Get.back(result: tarea);
          },
          child: Text("Guardar"),
        ),
      ],
    ),
  );
}