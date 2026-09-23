import 'package:finanzas_verdes/app/config/Global.dart';
import 'package:finanzas_verdes/main.dart';
import 'package:finanzas_verdes/models/api/calendarioApi.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';


Future<bool> mostrarModalCrearCalendario(BuildContext context, Map<String, dynamic> cliente, String titulo) async {

  final tituloController =
  TextEditingController(
    text: titulo,
  );

  final descripcionController =
  TextEditingController();

  DateTime fechaSeleccionada =
  DateTime.now();

  TimeOfDay horaSeleccionada =
  TimeOfDay.now();

  bool isLoading = false;

  final result = await showDialog(

    context: context,

    builder: (context) {

      return StatefulBuilder(

        builder: (
            context,
            setModalState,
            ) {

          return AlertDialog(

            shape:
            RoundedRectangleBorder(
              borderRadius:
              BorderRadius.circular(
                20,
              ),
            ),

            title: const Text(
              "Agendar visita",
            ),

            content: SizedBox(

              width: 450,

              child: SingleChildScrollView(

                child: Column(

                  mainAxisSize:
                  MainAxisSize.min,

                  children: [

                    Container(
                      padding:
                      const EdgeInsets.all(
                        12,
                      ),
                      decoration:
                      BoxDecoration(
                        color: Global.container,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [

                          const Icon(
                            Icons.person,
                          ),

                          const SizedBox(
                            width: 10,
                          ),

                          Expanded(
                            child: Column(
                              crossAxisAlignment:
                              CrossAxisAlignment
                                  .start,
                              children: [

                                Text(
                                  cliente[
                                  "nombre_usuario"] ??
                                      "",
                                  style:
                                  const TextStyle(
                                    fontWeight:
                                    FontWeight
                                        .bold,
                                  ),
                                ),

                                Text(
                                  cliente[
                                  "nombre_mipyme"] ??
                                      "",
                                ),

                                Text(
                                  cliente[
                                  "email"] ??
                                      "",
                                ),

                              ],
                            ),
                          ),

                        ],
                      ),
                    ),

                    const SizedBox(
                      height: 20,
                    ),

                    TextField(
                      controller:
                      tituloController,
                      decoration:
                      const InputDecoration(
                        labelText:
                        "Título",
                        border:
                        OutlineInputBorder(),
                      ),
                    ),

                    const SizedBox(
                      height: 15,
                    ),

                    TextField(
                      controller:
                      descripcionController,
                      maxLines: 4,
                      decoration:
                      const InputDecoration(
                        labelText:
                        "Descripción",
                        border:
                        OutlineInputBorder(),
                      ),
                    ),

                    const SizedBox(
                      height: 15,
                    ),

                    Row(
                      children: [

                        Expanded(
                          child: OutlinedButton.icon(

                            icon: const Icon(
                              Icons.calendar_month,
                            ),

                            label: Text(
                              "${fechaSeleccionada.day}/${fechaSeleccionada.month}/${fechaSeleccionada.year}",
                            ),

                            onPressed:
                                () async {

                              final fecha =
                              await showDatePicker(
                                context:
                                context,
                                initialDate:
                                fechaSeleccionada,
                                firstDate:
                                DateTime.now(),
                                lastDate:
                                DateTime(
                                  2100,
                                ),
                              );

                              if (fecha != null) {
                                setModalState(() {fechaSeleccionada = fecha;},);
                              }
                            },
                          ),
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        Expanded(
                          child: OutlinedButton.icon(

                            icon: const Icon(
                              Icons.access_time,
                            ),

                            label: Text(horaSeleccionada.format(context,),),

                            onPressed:
                                () async {

                              final hora =
                              await showTimePicker(
                                context:
                                context,
                                initialTime:
                                horaSeleccionada,
                              );

                              if (hora !=
                                  null) {

                                setModalState(
                                      () {
                                    horaSeleccionada =
                                        hora;
                                  },
                                );

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
                icon: isLoading
                    ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
                    : const Icon(Icons.event_available),
                label: Text(
                  isLoading ? "Creando..." : "Crear cita",
                ),
                onPressed: isLoading
                    ? null
                    : () async {

                  setModalState(() {
                    isLoading = true;
                  });

                  try {

                    final fechaHora = DateTime(
                      fechaSeleccionada.year,
                      fechaSeleccionada.month,
                      fechaSeleccionada.day,
                      horaSeleccionada.hour,
                      horaSeleccionada.minute,
                    );

                    await createCalendarioApi(
                      titulo: tituloController.text,
                      fechaHora: fechaHora,
                      descripcion: descripcionController.text,
                      direccion: "",
                      usuarios: [
                        cliente["id_usuario"],
                        controller.User["id_usuario"],
                      ],
                    );

                    controller.loadRange(controller.firstDate.value, controller.endDate.value);

                    Navigator.pop(context, true);

                    Get.snackbar(
                      "Éxito",
                      "Cita creada correctamente",
                    );

                    getClientsAgendaApi();

                  } catch (e) {

                    setModalState(() {
                      isLoading = false;
                    });

                    Get.snackbar(
                      "Error",
                      e.toString(),
                    );
                  }
                },
              )
            ],
          );
        },
      );
    },
  );

  return result ?? false;
}