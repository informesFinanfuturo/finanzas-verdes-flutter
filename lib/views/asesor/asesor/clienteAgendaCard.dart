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
import 'package:finanzas_verdes/models/api/prospectoApi.dart';

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

    final double cardWidth = (screenWidth - 44).clamp(300.0, 380.0).toDouble();
    final bool isProspect = cliente["tipo_entidad"] == "prospecto";

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
                      isProspect
                          ? "Prospecto corporativo"
                          : cliente["nombre_mipyme"]
                          ?.toString() ??
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

                      final tipoEntidad =
                          cliente[
                          "tipo_entidad"] ??
                              "cliente";


                      /*
   * ==================================
   * PROSPECTO
   * ==================================
   */
                      if (
                      tipoEntidad ==
                          "prospecto"
                      ) {

                        /*
     * Ya fue convertido.
     */
                        if (
                        cliente[
                        "estado"] ==
                            "convertido" &&
                            cliente[
                            "id_usuario"] !=
                                null
                        ) {

                          clientController.setClient(

                            await getClientDetailApi(

                              idUsuario:
                              cliente[
                              "id_usuario"],

                            ),

                          );


                          controller.setPage(
                            AsesorRoutes
                                .dashBoardClient,
                          );


                          return;

                        }


                        await mostrarModalDecisionCliente(

                          context,

                          cliente,

                          clientController,

                        );


                        return;

                      }


                      /*
   * ==================================
   * CLIENTE FV TRADICIONAL
   * ==================================
   */
                      if (
                      cliente[
                      "estado"] ==
                          "activo"
                      ) {

                        clientController.setClient(

                          await getClientDetailApi(

                            idUsuario:
                            cliente[
                            "id_usuario"],

                          ),

                        );


                        controller.setPage(
                          AsesorRoutes
                              .dashBoardClient,
                        );

                      } else if (
                      cliente[
                      "estado"] ==
                          "nuevo"
                      ) {

                        await mostrarModalDecisionCliente(

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

Future<void>
mostrarModalDecisionCliente(
    BuildContext context,
    Map<String, dynamic> usuario,
    ClientController clientController,
    ) async {

  String? decision;


  final motivoController =
  TextEditingController();


  final nombreMipymeController =
  TextEditingController();


  final bool isProspect =
      usuario[
      "tipo_entidad"] ==
          "prospecto";


  await showDialog(

    context:
    context,

    builder:
        (context) {

      return StatefulBuilder(

        builder:
            (
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

            title:
            const Text(
              "Decisión del cliente",
            ),

            content:
            SizedBox(

              width:
              500,

              child:
              SingleChildScrollView(

                child:
                Column(

                  mainAxisSize:
                  MainAxisSize
                      .min,

                  crossAxisAlignment:
                  CrossAxisAlignment
                      .start,

                  children: [

                    Text(

                      "Luego de presentar el proyecto, registra la decisión tomada por el cliente.",

                      style:
                      TextStyle(
                        color:
                        Colors.grey
                            .shade700,
                      ),

                    ),

                    const SizedBox(
                      height:
                      20,
                    ),


                    _opcionDecision(

                      titulo:
                      "Confirmar proceso",

                      icon:
                      Icons
                          .check_circle,

                      color:
                      Colors.green,

                      seleccionado:
                      decision ==
                          "activo",

                      onTap:
                          () {

                        setModalState(
                              () {

                            decision =
                            "activo";

                          },
                        );

                      },

                    ),


                    const SizedBox(
                      height:
                      10,
                    ),


                    _opcionDecision(

                      titulo:
                      "Posponer visita",

                      icon:
                      Icons
                          .schedule_rounded,

                      color:
                      Colors.orange,

                      seleccionado:
                      decision ==
                          "pospuesto",

                      onTap:
                          () {

                        setModalState(
                              () {

                            decision =
                            "pospuesto";

                          },
                        );

                      },

                    ),


                    const SizedBox(
                      height:
                      10,
                    ),


                    _opcionDecision(

                      titulo:
                      "Reprogramar visita",

                      icon:
                      Icons
                          .event_repeat_rounded,

                      color:
                      Colors.blue,

                      seleccionado:
                      decision ==
                          "reprogramar",

                      onTap:
                          () {

                        setModalState(
                              () {

                            decision =
                            "reprogramar";

                          },
                        );

                      },

                    ),


                    const SizedBox(
                      height:
                      10,
                    ),


                    _opcionDecision(

                      titulo:
                      "No continuar",

                      icon:
                      Icons
                          .cancel_outlined,

                      color:
                      Colors.red,

                      seleccionado:
                      decision ==
                          "desinteresado",

                      onTap:
                          () {

                        setModalState(
                              () {

                            decision =
                            "desinteresado";

                          },
                        );

                      },

                    ),


                    /*
                     * Solo necesitamos pedir
                     * el nombre del negocio
                     * al convertir un prospecto.
                     */
                    if (
                    isProspect &&
                        decision ==
                            "activo"
                    ) ...[

                      const SizedBox(
                        height:
                        18,
                      ),

                      TextField(

                        controller:
                        nombreMipymeController,

                        decoration:
                        const InputDecoration(

                          labelText:
                          "Nombre del negocio",

                          hintText:
                          "Nombre comercial o razón social",

                          prefixIcon:
                          Icon(
                            Icons
                                .storefront_outlined,
                          ),

                          border:
                          OutlineInputBorder(),

                        ),

                      ),

                    ],


                    if (
                    decision ==
                        "pospuesto" ||
                        decision ==
                            "desinteresado"
                    ) ...[

                      const SizedBox(
                        height:
                        18,
                      ),

                      TextField(

                        controller:
                        motivoController,

                        maxLines:
                        3,

                        decoration:
                        InputDecoration(

                          labelText:
                          decision ==
                              "pospuesto"
                              ? "Motivo del aplazamiento"
                              : "Motivo por el cual no continúa",

                          border:
                          const OutlineInputBorder(),

                        ),

                      ),

                    ],

                  ],

                ),

              ),

            ),

            actions:
            [

              TextButton(

                onPressed:
                    () =>
                    Navigator.pop(
                      context,
                    ),

                child:
                const Text(
                  "Cancelar",
                ),

              ),


              ElevatedButton(

                onPressed:
                decision ==
                    null
                    ? null
                    : () async {

                  final motivo =
                  motivoController
                      .text
                      .trim();


                  if (
                  (
                      decision ==
                          "desinteresado" ||
                          decision ==
                              "pospuesto"
                  ) &&
                      motivo.isEmpty
                  ) {

                    Get.snackbar(
                      "Campo requerido",
                      "Debe indicar el motivo.",
                      backgroundColor:
                      Colors.red,
                      colorText:
                      Colors.white,
                    );

                    return;

                  }


                  if (
                  isProspect &&
                      decision ==
                          "activo" &&
                      nombreMipymeController
                          .text
                          .trim()
                          .isEmpty
                  ) {

                    Get.snackbar(
                      "Campo requerido",
                      "Debe indicar el nombre del negocio.",
                      backgroundColor:
                      Colors.red,
                      colorText:
                      Colors.white,
                    );

                    return;

                  }


                  Navigator.pop(
                    context,
                  );


                  /*
                     * ==========================
                     * REPROGRAMAR
                     * ==========================
                     */
                  if (
                  decision ==
                      "reprogramar"
                  ) {

                    await mostrarModalEditarCalendario(
                      context,
                      usuario,
                    );


                    await controller.loadRange(
                      controller
                          .firstDate
                          .value,

                      controller
                          .endDate
                          .value,
                    );


                    await getClientsAgendaApi();


                    return;

                  }


                  /*
                     * ==========================
                     * PROSPECTO
                     * ==========================
                     */
                  if (
                  isProspect
                  ) {

                    final idProspecto =
                    usuario[
                    "id_prospecto"];


                    if (
                    idProspecto ==
                        null
                    ) {

                      Get.snackbar(
                        "Error",
                        "No se encontró el identificador del prospecto.",
                      );

                      return;

                    }


                    try {

                      /*
                         * ACEPTÓ.
                         */
                      if (
                      decision ==
                          "activo"
                      ) {

                        final response =
                        await convertirProspectoApi(

                          idProspecto:
                          idProspecto,

                          nombreMipyme:
                          nombreMipymeController
                              .text
                              .trim(),

                        );


                        final newUser =
                        response[
                        "usuario"]
                        as Map<String, dynamic>?;


                        final idUsuario =
                            newUser?[
                            "id_usuario"] ??
                                response[
                                "id_usuario"];


                        if (
                        idUsuario ==
                            null
                        ) {

                          throw Exception(
                            "No se recibió el usuario creado",
                          );

                        }


                        clientController.setClient(

                          await getClientDetailApi(

                            idUsuario:
                            idUsuario,

                          ),

                        );


                        controller.setPage(

                          AsesorRoutes
                              .dashBoardClient,

                        );

                      }

                      /*
                         * POSPUSO / NO CONTINÚA.
                         */
                      else {

                        await actualizarDecisionProspectoApi(

                          idProspecto:
                          idProspecto,

                          decision:
                          decision!,

                          motivo:
                          motivo,

                        );

                      }


                      await controller.loadRange(

                        controller
                            .firstDate
                            .value,

                        controller
                            .endDate
                            .value,

                      );


                      await getClientsAgendaApi();


                    } catch (e) {

                      Get.snackbar(

                        "Error",

                        e
                            .toString()
                            .replaceFirst(
                          "Exception: ",
                          "",
                        ),

                        backgroundColor:
                        Colors.red,

                        colorText:
                        Colors.white,

                      );

                    }


                    return;

                  }


                  /*
                     * ==========================
                     * CLIENTE FV EXISTENTE
                     * ==========================
                     */

                  await editClientApi(

                    idUsuario:
                    usuario[
                    "id_usuario"],

                    updatedBy:
                    controller
                        .User[
                    "id_usuario"],

                    clientController:
                    clientController,

                    estado:
                    decision,

                    estado_observaciones:
                    motivo,

                  );


                  if (
                  decision ==
                      "activo"
                  ) {

                    clientController.setClient(

                      await getClientDetailApi(

                        idUsuario:
                        usuario[
                        "id_usuario"],

                      ),

                    );


                    controller.setPage(

                      AsesorRoutes
                          .dashBoardClient,

                    );

                  }


                  await controller.loadRange(

                    controller
                        .firstDate
                        .value,

                    controller
                        .endDate
                        .value,

                  );


                  await getClientsAgendaApi();

                },

                child:
                const Text(
                  "Guardar decisión",
                ),

              ),

            ],

          );

        },
      );

    },

  );


  motivoController
      .dispose();


  nombreMipymeController
      .dispose();

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