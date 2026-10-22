import 'package:finanzas_verdes/app/config/Global.dart';
import 'package:finanzas_verdes/main.dart';
import 'package:finanzas_verdes/models/api/calendarioApi.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

Future<bool?> mostrarModalEditarCalendario(
  BuildContext context,
  Map<String, dynamic> cliente,
) async {
  final tituloController = TextEditingController(text: cliente["titulo"] ?? "");

  final descripcionController = TextEditingController(
    text: cliente["descripcion"] ?? "",
  );

  final fechaOriginal = DateTime.parse(
    cliente["fecha_hora"].toString(),
  ).toLocal();

  DateTime fechaSeleccionada = fechaOriginal;

  TimeOfDay horaSeleccionada = TimeOfDay(
    hour: fechaOriginal.hour,
    minute: fechaOriginal.minute,
  );

  return await showDialog<bool>(
    context: context,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setModalState) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),

            title: Text("Editar visita"),

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
                          Icon(Icons.person),
                          SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  cliente["nombre_usuario"] ?? "",
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(cliente["nombre_mipyme"] ?? ""),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 20),
                    TextField(
                      controller: tituloController,
                      decoration: InputDecoration(
                        labelText: "Título",
                        border: OutlineInputBorder(),
                      ),
                    ),

                    SizedBox(height: 15),
                    TextField(
                      controller: descripcionController,
                      maxLines: 4,
                      decoration: InputDecoration(
                        labelText: "Descripción",
                        border: OutlineInputBorder(),
                      ),
                    ),

                    SizedBox(height: 15),

                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            icon: const Icon(Icons.calendar_month),

                            label: Text(
                              "${fechaSeleccionada.day}/${fechaSeleccionada.month}/${fechaSeleccionada.year}",
                            ),

                            onPressed: () async {
                              final fecha = await showDatePicker(
                                context: context,
                                initialDate: fechaSeleccionada,
                                firstDate: DateTime.now(),
                                lastDate: DateTime(2100),
                              );

                              if (fecha != null) {
                                setModalState(() {
                                  fechaSeleccionada = fecha;
                                });
                              }
                            },
                          ),
                        ),

                        const SizedBox(width: 10),

                        Expanded(
                          child: OutlinedButton.icon(
                            icon: const Icon(Icons.access_time),

                            label: Text(horaSeleccionada.format(context)),

                            onPressed: () async {
                              final hora = await showTimePicker(
                                context: context,

                                initialTime: horaSeleccionada,
                              );

                              if (hora != null) {
                                setModalState(() {
                                  horaSeleccionada = hora;
                                });
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
              TextButton.icon(
                icon: const Icon(Icons.event_busy_outlined),
                label: const Text("Cancelar visita"),
                style: TextButton.styleFrom(
                  foregroundColor: Colors.red,
                ),
                onPressed: () async {
                  final idCalendario = int.tryParse(
                    '${cliente["id_calendario"]}',
                  );

                  if (idCalendario == null) {
                    Get.snackbar(
                      "Error",
                      "No se encontró el identificador de la visita.",
                    );
                    return;
                  }

                  final confirmar = await showDialog<bool>(
                    context: context,
                    builder: (confirmContext) => AlertDialog(
                      title: const Text("Cancelar visita"),
                      content: const Text(
                        "¿Estás seguro de cancelar esta visita? "
                            "La cita dejará de aparecer como activa "
                            "en el calendario.",
                      ),
                      actions: [
                        TextButton(
                          onPressed: () =>
                              Navigator.pop(confirmContext, false),
                          child: const Text("Volver"),
                        ),
                        FilledButton(
                          style: FilledButton.styleFrom(
                            backgroundColor: Colors.red,
                          ),
                          onPressed: () =>
                              Navigator.pop(confirmContext, true),
                          child: const Text("Sí, cancelar visita"),
                        ),
                      ],
                    ),
                  );

                  if (confirmar != true || !context.mounted) {
                    return;
                  }

                  try {
                    await eliminarCalendarioApi(idCalendario);

                    if (!context.mounted) return;

                    // La cancelación fue aceptada.
                    Navigator.pop(context, true);

                    Get.snackbar(
                      "Visita cancelada",
                      "La cita fue cancelada correctamente.",
                    );

                    // Refrescar agenda y calendario.
                    await controller.loadRange(
                      controller.firstDate.value,
                      controller.endDate.value,
                    );

                    await getClientsAgendaApi();
                  } catch (e) {
                    Get.snackbar(
                      "Error al cancelar",
                      e.toString().replaceFirst(
                        "Exception: ",
                        "",
                      ),
                    );
                  }
                },
              ),

              TextButton(
                onPressed: () {
                  Navigator.pop(context, false);
                },
                child: const Text("Cerrar"),
              ),
              ElevatedButton.icon(
                icon: const Icon(Icons.save),
                label: const Text("Guardar cambios"),
                onPressed: () async {
                  final tituloLimpio = tituloController.text.trim();
                  final fechaHora = DateTime(
                    fechaSeleccionada.year,
                    fechaSeleccionada.month,
                    fechaSeleccionada.day,
                    horaSeleccionada.hour,
                    horaSeleccionada.minute,
                  );

                  if (tituloLimpio.isEmpty) {
                    Get.snackbar(
                      'Título requerido',
                      'Debes registrar un título para la visita.',
                    );
                    return;
                  }

                  if (!fechaHora.isAfter(DateTime.now())) {
                    Get.snackbar(
                      'Fecha inválida',
                      'La visita debe quedar programada para una fecha y hora futura.',
                    );
                    return;
                  }

                  try {
                    await editarCalendarioApi(
                      id: cliente["id_calendario"],
                      titulo: tituloLimpio,
                      fechaHora: fechaHora,
                      descripcion: descripcionController.text,
                      direccion: cliente["direccion"] ?? "",
                    );

                    controller.loadRange(
                      controller.firstDate.value,
                      controller.endDate.value,
                    );

                    Navigator.pop(context, true);

                    Get.snackbar("Éxito", "Visita actualizada correctamente");
                  } catch (e) {
                    Get.snackbar("Error", e.toString());
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
