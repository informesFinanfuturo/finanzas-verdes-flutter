import 'package:finanzas_verdes/app/config/Global.dart';
import 'package:finanzas_verdes/controllers/ClientController.dart';
import 'package:finanzas_verdes/main.dart';
import 'package:finanzas_verdes/models/api/calendarioApi.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ClientesTable extends StatefulWidget {
  const ClientesTable({super.key});

  @override
  State<ClientesTable> createState() =>
      _ClientesTableState();
}

class _ClientesTableState
    extends State<ClientesTable> {

  String search = '';
  ClientController clientController = Get.find();

  @override
  Widget build(BuildContext context) {

    final clientes = clientController.clients
        .where((c) {

      final nombre =
      (c["nombre_usuario"] ?? "")
          .toString()
          .toLowerCase();

      final empresa =
      (c["nombre_mipyme"] ?? "")
          .toString()
          .toLowerCase();

      final documento =
      (c["documento"] ?? "")
          .toString()
          .toLowerCase();

      final query =
      search.toLowerCase();

      return nombre.contains(query) ||
          empresa.contains(query) ||
          documento.contains(query);

    }).toList();

    return Column(
      children: [

        /// BUSCADOR
        TextField(
          decoration: InputDecoration(
            hintText:
            "Buscar cliente...",
            prefixIcon:
            const Icon(Icons.search),
            border:
            OutlineInputBorder(
              borderRadius:
              BorderRadius.circular(12),
            ),
          ),
          onChanged: (value) {
            setState(() {
              search = value;
            });
          },
        ),

        const SizedBox(height: 15),

        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) {

              /// MOBILE
              if (constraints.maxWidth < 800) {

                return ListView.builder(
                  itemCount:
                  clientes.length,
                  itemBuilder:
                      (_, index) {

                    final cliente =
                    clientes[index];

                    return Card(
                      margin:
                      const EdgeInsets
                          .only(
                        bottom: 10,
                      ),
                      child: ListTile(
                        title: Text(
                          cliente[
                          "nombre_usuario"] ??
                              "",
                        ),
                        subtitle: Column(
                          crossAxisAlignment:
                          CrossAxisAlignment
                              .start,
                          children: [

                            Text(
                              cliente[
                              "nombre_mipyme"] ??
                                  "",
                            ),

                            Text(
                              cliente[
                              "documento"]
                                  .toString(),
                            ),

                          ],
                        ),
                        trailing: IconButton(
                          icon: const Icon(
                            Icons.calendar_month,
                          ),
                          onPressed: () {
                            mostrarModalCrearCalendario(context, cliente);
                          },
                        ),
                      ),
                    );
                  },
                );
              }

              /// DESKTOP
              return SingleChildScrollView(
                scrollDirection:
                Axis.horizontal,
                child: DataTable(

                  columns: const [

                    DataColumn(
                      label: Text(
                        "Usuario",
                      ),
                    ),

                    DataColumn(
                      label: Text(
                        "Mipyme",
                      ),
                    ),

                    DataColumn(
                      label: Text(
                        "Documento",
                      ),
                    ),

                    DataColumn(
                      label: Text(
                        "Acciones",
                      ),
                    ),

                  ],

                  rows:
                  clientes.map((c) {

                    return DataRow(

                      cells: [

                        DataCell(
                          Text(
                            c["nombre_usuario"] ??
                                "",
                          ),
                        ),

                        DataCell(
                          Text(
                            c["nombre_mipyme"] ??
                                "",
                          ),
                        ),

                        DataCell(
                          Text(
                            c["documento"]
                                .toString(),
                          ),
                        ),

                        DataCell(
                          ElevatedButton.icon(
                            onPressed: () {
                              mostrarModalCrearCalendario(context, c);
                            },
                            icon: const Icon(
                              Icons.calendar_month,
                              size: 18,
                            ),
                            label: const Text(
                              "Agendar",
                            ),
                          ),
                        ),

                      ],

                    );

                  }).toList(),

                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

Future<void> mostrarModalCrearCalendario(BuildContext context, Map<String, dynamic> cliente,) async {

  final tituloController =
  TextEditingController(
    text: "Visita inicial",
  );

  final descripcionController =
  TextEditingController();

  DateTime fechaSeleccionada =
  DateTime.now();

  TimeOfDay horaSeleccionada =
  TimeOfDay.now();

  await showDialog(

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
                  );
                },
                child: const Text(
                  "Cancelar",
                ),
              ),
              ElevatedButton.icon(
                icon: const Icon(
                  Icons.event_available,
                ),
                label: const Text("Crear cita",),
                onPressed: () async {
                  final fechaHora = DateTime(
                    fechaSeleccionada.year,
                    fechaSeleccionada.month,
                    fechaSeleccionada.day,
                    horaSeleccionada.hour,
                    horaSeleccionada.minute,
                  );
                  try {
                    await createCalendarioApi(
                      titulo: tituloController.text,
                      fechaHora: fechaHora,
                      descripcion: descripcionController.text,
                      direccion: "",
                      usuarios: [cliente["id_usuario"], controller.User["id_usuario"]],
                    );
                    Navigator.pop(context);
                    Get.snackbar(
                      "Éxito",
                      "Cita creada correctamente",
                    );
                    getClientsAgendaApi();
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

Future<void> mostrarModalEditarCalendario(BuildContext context, Map<String, dynamic> cliente,) async {

  final tituloController =
  TextEditingController(
    text: cliente["titulo"] ?? "",
  );

  final descripcionController =
  TextEditingController(
    text: cliente["descripcion"] ?? "",
  );

  final fechaOriginal =
  DateTime.parse(
    cliente["fecha_hora"],
  );

  DateTime fechaSeleccionada =
      fechaOriginal;

  TimeOfDay horaSeleccionada =
  TimeOfDay(
    hour: fechaOriginal.hour,
    minute: fechaOriginal.minute,
  );

  await showDialog(

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
              "Editar visita",
            ),

            content: SizedBox(

              width: 500,

              child:
              SingleChildScrollView(

                child: Column(

                  mainAxisSize:
                  MainAxisSize.min,

                  children: [

                    Container(

                      padding:
                      const EdgeInsets
                          .all(12),

                      decoration:
                      BoxDecoration(
                        color:
                        Global.container,
                        borderRadius:
                        BorderRadius
                            .circular(
                          12,
                        ),
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

                          child:
                          OutlinedButton.icon(

                            icon: const Icon(
                              Icons
                                  .calendar_month,
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

                              if (fecha !=
                                  null) {

                                setModalState(
                                      () {
                                    fechaSeleccionada =
                                        fecha;
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

                    Navigator.pop(
                      context,
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