import 'package:finanzas_verdes/app/config/Global.dart';
import 'package:finanzas_verdes/main.dart';
import 'package:finanzas_verdes/models/api/calendarioApi.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

Future<bool?> mostrarModalEditarCalendario (BuildContext context, Map<String, dynamic> cliente,) async {

  final tituloController = TextEditingController(text: cliente["titulo"] ?? "",);

  final descripcionController = TextEditingController(text: cliente["descripcion"] ?? "",);

  final fechaOriginal = DateTime.parse(cliente["fecha_hora"],);

  DateTime fechaSeleccionada = fechaOriginal;

  TimeOfDay horaSeleccionada = TimeOfDay(
    hour: fechaOriginal.hour,
    minute: fechaOriginal.minute,
  );

  await showDialog(
    context: context,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setModalState,) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20,),
            ),

            title: Text("Editar visita",),

            content: SizedBox(
              width: 500,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Global.container,
                        borderRadius: BorderRadius.circular(12),
                      ),

                      child: Row(

                        children: [
                          Icon(Icons.person,),
                          SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(cliente["nombre_usuario"] ?? "",
                                  style: const TextStyle(fontWeight: FontWeight.bold,),
                                ),
                                Text(cliente["nombre_mipyme"] ?? "",),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 20,),
                    TextField(
                      controller: tituloController,
                      decoration: InputDecoration(
                        labelText: "Título",
                        border: OutlineInputBorder(),
                      ),
                    ),

                    SizedBox(height: 15,),
                    TextField(
                      controller: descripcionController,
                      maxLines: 4,
                      decoration: InputDecoration(
                        labelText: "Descripción",
                        border: OutlineInputBorder(),
                      ),
                    ),

                    SizedBox(height: 15,),

                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            icon: const Icon(Icons.calendar_month,),

                            label: Text("${fechaSeleccionada.day}/${fechaSeleccionada.month}/${fechaSeleccionada.year}",),

                            onPressed:
                                () async {
                              final fecha =
                              await showDatePicker(
                                context: context,
                                initialDate: fechaSeleccionada,
                                firstDate: DateTime.now(),
                                lastDate: DateTime(2100,),
                              );

                              if (fecha != null) {
                                setModalState(() {
                                  fechaSeleccionada = fecha;
                                },
                                );
                              }

                            },

                          ),

                        ),

                        const SizedBox(
                          width: 10,
                        ),

                        Expanded(

                          child:
                          OutlinedButton.icon(

                            icon: const Icon(
                              Icons
                                  .access_time,
                            ),

                            label: Text(
                              horaSeleccionada
                                  .format(
                                context,
                              ),
                            ),

                            onPressed:
                                () async {

                              final hora =
                              await showTimePicker(

                                context:
                                context,

                                initialTime:
                                horaSeleccionada,

                              );

                              if (hora != null) {
                                setModalState(() {horaSeleccionada = hora;},);
                              }

                            },

                          ),

                        ),

                      ],

                    ),

                  ],

                ),

              ),

            ),

            actions: [

              TextButton(
                onPressed: () {
                  Navigator.pop(
                    context,
                    false
                  );
                },
                child: const Text(
                  "Cancelar",
                ),
              ),
              ElevatedButton.icon(
                icon: const Icon(
                  Icons.save,
                ),
                label: const Text(
                  "Guardar cambios",
                ),
                onPressed: () async {
                  final fechaHora =
                  DateTime(
                    fechaSeleccionada.year,
                    fechaSeleccionada.month,
                    fechaSeleccionada.day,
                    horaSeleccionada.hour,
                    horaSeleccionada.minute,
                  );

                  try {
                    await editarCalendarioApi(
                      id: cliente["id_calendario"],
                      titulo: tituloController.text,
                      fechaHora: fechaHora,
                      descripcion: descripcionController.text,
                      direccion: cliente["direccion"] ?? "",
                      usuarios: [cliente["id_usuario"], controller.User["id_usuario"],],
                    );

                    controller.loadRange(controller.firstDate.value, controller.endDate.value);

                    Navigator.pop(
                      context,
                      true
                    );

                    Get.snackbar(
                      "Éxito",
                      "Visita actualizada correctamente",
                    );

                  } catch (e) {

                    Get.snackbar(
                      "Error",
                      e.toString(),
                    );

                  }

                },

              ),

            ],

          );

        },

      );

    },

  );

}