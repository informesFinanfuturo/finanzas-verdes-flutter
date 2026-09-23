import 'package:finanzas_verdes/app/config/Global.dart';
import 'package:finanzas_verdes/app/routes/subrutes/asesorRoutes.dart';
import 'package:finanzas_verdes/controllers/ClientController.dart';
import 'package:finanzas_verdes/main.dart';
import 'package:finanzas_verdes/models/api/calendarioApi.dart';
import 'package:finanzas_verdes/models/api/clientApi.dart';
import 'package:finanzas_verdes/views/asesor/asesor/clientesTableAsesor.dart';
import 'package:finanzas_verdes/views/asesor/asesor/editCalendarioAsesor.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart';
import 'package:intl/intl.dart';

class ClienteAgendaCard extends StatelessWidget {

  final Map<String, dynamic> cliente;

  const ClienteAgendaCard({
    super.key,
    required this.cliente,
  });

  @override
  Widget build(BuildContext context) {
    final ClientController clientController = Get.find();

    final screenWidth = MediaQuery.sizeOf(context).width;

    final double cardWidth = (screenWidth - 44)
        .clamp(300.0, 380.0)
        .toDouble();

    return Container(
      width: cardWidth,
      height: 250,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Global.container,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Global.text.withOpacity(0.08),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.035),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: Global.primary.withOpacity(0.10),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.business_rounded,
                  size: 21,
                  color: Global.primary,
                ),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      cliente["nombre_usuario"]?.toString() ??
                          "Cliente sin nombre",
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Global.text,
                      ),
                    ),

                    const SizedBox(height: 2),

                    Text(
                      cliente["nombre_mipyme"]?.toString() ??
                          "Empresa no registrada",
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
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

          const SizedBox(height: 12),

          Row(
            children: [
              Expanded(
                child: _informationChip(
                  icon: Icons.badge_outlined,
                  text: cliente["documento"]?.toString() ??
                      "Sin documento",
                  color: Global.primary,
                ),
              ),

              if (cliente["fecha_hora"] != null) ...[
                const SizedBox(width: 8),

                Expanded(
                  flex: 2,
                  child: _informationChip(
                    icon: Icons.event_available_rounded,
                    text: _formatDate(
                      cliente["fecha_hora"]?.toString(),
                    ),
                    color: Global.primary,
                  ),
                ),
              ],
            ],
          ),

          const Spacer(),

          Divider(
            height: 1,
            color: Global.text.withOpacity(0.07),
          ),

          const SizedBox(height: 12),

          Row(
            children: [
              Expanded(
                child: _actionButton(
                  label: "Cancelar",
                  icon: Icons.close_rounded,
                  color: Colors.red,
                  onTap: () async {
                    await eliminarCalendarioApi(
                      cliente["id_calendario"],
                    );

                    await controller.loadRange(
                      controller.firstDate.value,
                      controller.endDate.value,
                    );

                    await getClientsAgendaApi();
                  },
                ),
              ),

              const SizedBox(width: 8),

              Expanded(
                child: _actionButton(
                  label: "Editar",
                  icon: Icons.edit_outlined,
                  color: Colors.orange.shade700,
                  onTap: () {
                    mostrarModalEditarCalendario(
                      context,
                      cliente,
                    );
                  },
                ),
              ),

              const SizedBox(width: 8),

              Expanded(
                child: SizedBox(
                  height: 40,
                  child: FilledButton.icon(
                    onPressed: () async {
                      if (cliente["estado"] == "activo") {
                        clientController.setClient(
                          await getClientDetailApi(
                            idUsuario: cliente["id_usuario"],
                          ),
                        );

                        controller.setPage(
                          AsesorRoutes.dashBoardClient,
                        );
                      } else if (cliente["estado"] == "nuevo") {
                        mostrarModalDecisionCliente(
                          context,
                          cliente,
                          clientController,
                        );
                      }
                    },
                    icon: const Icon(
                      Icons.play_arrow_rounded,
                      size: 17,
                    ),
                    label: const Text(
                      "Iniciar",
                      maxLines: 1,
                    ),
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                      ),
                      backgroundColor: Global.primary,
                      foregroundColor: Colors.white,
                      textStyle: const TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w600,
                      ),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _informationChip({
    required IconData icon,
    required String text,
    required Color color,
  }) {
    return Container(
      height: 40,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            size: 16,
            color: color,
          ),

          const SizedBox(width: 7),

          Expanded(
            child: Text(
              text,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w500,
                color: Global.text,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _actionButton({
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return SizedBox(
      height: 40,
      child: OutlinedButton.icon(
        onPressed: onTap,
        icon: Icon(
          icon,
          size: 16,
        ),
        label: Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(
            horizontal: 6,
          ),
          foregroundColor: color,
          side: BorderSide(
            color: color.withOpacity(0.45),
          ),
          textStyle: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w500,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
    );
  }

  String _formatDate(String? value) {
    if (value == null || value.isEmpty) {
      return "Sin fecha";
    }

    final date = DateTime.tryParse(value);

    if (date == null) {
      return "Fecha inválida";
    }

    return DateFormat(
      "dd/MM/yyyy • hh:mm a",
      "es",
    ).format(date);
  }
}

Future<void> mostrarModalDecisionCliente(BuildContext context, Map<String, dynamic> usuario, ClientController clientController,) async {

  String? decision;

  final motivoController =
  TextEditingController();

  DateTime? nuevaFecha;

  await showDialog(
    context: context,
    builder: (context) {

      return StatefulBuilder(
        builder: (
            context,
            setModalState,
            ) {

          return AlertDialog(

            shape: RoundedRectangleBorder(
              borderRadius:
              BorderRadius.circular(20),
            ),

            title: const Text(
              "Decisión del cliente",
            ),

            content: SizedBox(

              width: 500,

              child: SingleChildScrollView(

                child: Column(

                  mainAxisSize:
                  MainAxisSize.min,

                  crossAxisAlignment:
                  CrossAxisAlignment.start,

                  children: [

                    Text(
                      "Luego de comentar sobre el proyecto, registra la decisión tomada por el cliente.",
                      style: TextStyle(
                        color:
                        Colors.grey.shade700,
                      ),
                    ),

                    const SizedBox(
                      height: 20,
                    ),

                    _opcionDecision(
                      titulo:
                      "Confirmar proceso",
                      icon:
                      Icons.check_circle,
                      color: Colors.green,
                      seleccionado:
                      decision ==
                          "activo",
                      onTap: () {
                        setModalState(() {
                          decision =
                          "activo";
                        });
                      },
                    ),

                    const SizedBox(
                      height: 10,
                    ),

                    _opcionDecision(
                      titulo:
                      "Posponer visita",
                      icon:
                      Icons.pause_circle,
                      color:
                      Colors.orange,
                      seleccionado:
                      decision ==
                          "pospuesto",
                      onTap: () {
                        setModalState(() {
                          decision =
                          "pospuesto";
                        });
                      },
                    ),

                    const SizedBox(
                      height: 10,
                    ),

                    _opcionDecision(
                      titulo:
                      "Reprogramar visita",
                      icon:
                      Icons.calendar_month,
                      color:
                      Colors.blue,
                      seleccionado:
                      decision ==
                          "reprogramar",
                      onTap: () {
                        setModalState(() {
                          decision =
                          "reprogramar";
                        });
                      },
                    ),

                    const SizedBox(
                      height: 10,
                    ),

                    _opcionDecision(
                      titulo:
                      "No continuar con el proceso",
                      icon:
                      Icons.cancel,
                      color: Colors.red,
                      seleccionado:
                      decision ==
                          "desinteresado",
                      onTap: () {
                        setModalState(() {
                          decision =
                          "desinteresado";
                        });
                      },
                    ),

                    const SizedBox(
                      height: 20,
                    ),

                    if (decision ==
                        "pospuesto")
                      TextField(
                        controller:
                        motivoController,
                        maxLines: 3,
                        decoration:
                        const InputDecoration(
                          border:
                          OutlineInputBorder(),
                          labelText:
                          "Motivo del aplazamiento",
                          hintText:
                          "Ej. El cliente desea que lo contacten nuevamente en unos meses",
                        ),
                      ),

                    if (decision ==
                        "desinteresado")
                      TextField(
                        controller:
                        motivoController,
                        maxLines: 3,
                        decoration:
                        const InputDecoration(
                          border:
                          OutlineInputBorder(),
                          labelText:
                          "Motivo del rechazo",
                          hintText:
                          "Describe por qué no continuará",
                        ),
                      ),

                    // if (decision ==
                    //     "reprogramar")
                    //   Column(
                    //     children: [
                    //
                    //       ListTile(
                    //
                    //         shape:
                    //         RoundedRectangleBorder(
                    //           borderRadius:
                    //           BorderRadius.circular(
                    //             12,
                    //           ),
                    //           side:
                    //           BorderSide(
                    //             color:
                    //             Colors.blue,
                    //           ),
                    //         ),
                    //
                    //         leading:
                    //         const Icon(
                    //           Icons
                    //               .calendar_today,
                    //           color:
                    //           Colors.blue,
                    //         ),
                    //
                    //         title: Text(
                    //
                    //           nuevaFecha ==
                    //               null
                    //               ? "Seleccionar nueva fecha"
                    //               : "${nuevaFecha!.day}/${nuevaFecha!.month}/${nuevaFecha!.year}",
                    //
                    //         ),
                    //
                    //         trailing:
                    //         const Icon(
                    //           Icons.edit,
                    //         ),
                    //
                    //         onTap:
                    //             () async {
                    //
                    //           final fecha =
                    //           await showDatePicker(
                    //             context:
                    //             context,
                    //             initialDate:
                    //             DateTime
                    //                 .now(),
                    //             firstDate:
                    //             DateTime
                    //                 .now(),
                    //             lastDate:
                    //             DateTime(
                    //               2100,
                    //             ),
                    //           );
                    //
                    //           if (fecha !=
                    //               null) {
                    //             setModalState(
                    //                   () {
                    //                 nuevaFecha =
                    //                     fecha;
                    //               },
                    //             );
                    //           }
                    //
                    //         },
                    //
                    //       ),
                    //
                    //     ],
                    //   ),

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
                  "Cerrar",
                ),
              ),

              ElevatedButton(

                onPressed:
                decision == null
                    ? null
                    : () async {

                  if (
                  decision ==
                      "desinteresado" &&
                      motivoController
                          .text
                          .trim()
                          .isEmpty) {

                    Get.snackbar(
                      "Campo requerido",
                      "Debe indicar el motivo del rechazo",
                      backgroundColor: Colors.red,
                      colorText: Colors.white
                    );

                    return;
                  }

                  if (
                  decision ==
                      "pospuesto" &&
                      motivoController
                          .text
                          .trim()
                          .isEmpty) {

                    Get.snackbar(
                      "Campo requerido",
                      "Debe indicar el motivo del aplazamiento",
                      backgroundColor: Colors.red,
                      colorText: Colors.white
                    );

                    return;
                  }

                  // if (
                  // decision ==
                  //     "reprogramar" &&
                  //     nuevaFecha ==
                  //         null) {
                  //
                  //   Get.snackbar(
                  //     "Campo requerido",
                  //     "Debe seleccionar una fecha",
                  //   );
                  //
                  //   return;
                  // }

                  Navigator.pop(context,);

                  if (decision == "reprogramar") {

                    mostrarModalEditarCalendario(context, usuario);

                    return;
                  }

                  await editClientApi(
                    idUsuario:
                    usuario[
                    "id_usuario"],
                    updatedBy:
                    controller.User[
                    "id_usuario"],
                    clientController:
                    Get.find<
                        ClientController>(),
                    estado:
                    decision,
                    estado_observaciones:
                    motivoController
                        .text,
                  );

                  if (
                  decision ==
                      "activo") {

                    clientController
                        .setClient(
                      await getClientDetailApi(
                        idUsuario:
                        usuario[
                        "id_usuario"],
                      ),
                    );

                    controller
                        .setPage(
                      AsesorRoutes
                          .dashBoardClient,
                    );

                  }

                },

                child: const Text(
                  "Guardar decisión",
                ),

              ),

            ],

          );

        },
      );
    },
  );
}

Widget _opcionDecision({
  required String titulo,
  required IconData icon,
  required Color color,
  required bool seleccionado,
  required VoidCallback onTap,
}) {
  return InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(16),
    child: AnimatedContainer(
      duration: const Duration(
        milliseconds: 200,
      ),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: seleccionado
            ? color.withOpacity(.12)
            : Colors.transparent,
        borderRadius:
        BorderRadius.circular(16),
        border: Border.all(
          color: seleccionado
              ? color
              : Colors.grey.shade300,
          width:
          seleccionado ? 2 : 1,
        ),
      ),
      child: Row(
        children: [

          Icon(
            icon,
            color: color,
          ),

          const SizedBox(
            width: 12,
          ),

          Expanded(
            child: Text(
              titulo,
              style: const TextStyle(
                fontWeight:
                FontWeight.w600,
              ),
            ),
          ),

          if (seleccionado)
            Icon(
              Icons.check,
              color: color,
            ),

        ],
      ),
    ),
  );
}