import 'package:finanzas_verdes/app/config/Global.dart';
import 'package:finanzas_verdes/app/routes/subrutes/asesorRoutes.dart';
import 'package:finanzas_verdes/controllers/ClientController.dart';
import 'package:finanzas_verdes/main.dart';
import 'package:finanzas_verdes/models/api/calendarioApi.dart';
import 'package:finanzas_verdes/models/api/clientApi.dart';
import 'package:finanzas_verdes/views/asesor/asesor/clientesTableAsesor.dart';
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

    ClientController clientController = Get.find();

    return Container(
      width: 400,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Global.container,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Global.primary.withOpacity(.15),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [

          Row(
            children: [

              CircleAvatar(
                radius: 24,
                backgroundColor:
                Global.primary.withOpacity(.12),
                child: Icon(
                  Icons.business,
                  color: Global.primary,
                ),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,
                  children: [

                    Text(
                      cliente["nombre_usuario"] ?? "",
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                      ),
                    ),

                    Text(
                      cliente["nombre_mipyme"] ?? "",
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.grey.shade600,
                      ),
                    ),

                  ],
                ),
              ),

            ],
          ),

          const SizedBox(height: 18),

          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Global.primary.withOpacity(.05),
              borderRadius:
              BorderRadius.circular(12),
            ),
            child: Row(
              children: [

                Icon(
                  Icons.badge_outlined,
                  color: Global.primary,
                  size: 18,
                ),

                const SizedBox(width: 8),

                Expanded(
                  child: Text(
                    cliente["documento"]
                        .toString(),
                    style: const TextStyle(
                      fontWeight:
                      FontWeight.w600,
                    ),
                  ),
                ),

              ],
            ),
          ),

          const SizedBox(height: 12),

          if (cliente["fecha_hora"] != null)
            Container(
              padding:
              const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 10,
              ),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius:
                BorderRadius.circular(12),
              ),
              child: Row(
                children: [

                  Icon(
                    Icons.event_available,
                    color: Colors.green.shade700,
                    size: 18,
                  ),

                  const SizedBox(width: 8),

                  Expanded(
                    child: Text(
                      DateFormat(
                        'dd/MM/yyyy • hh:mm a',
                      ).format(
                        DateTime.parse(
                          cliente["fecha_hora"],
                        ),
                      ),
                      style: TextStyle(
                        color:
                        Colors.green.shade800,
                        fontWeight:
                        FontWeight.w600,
                      ),
                    ),
                  ),

                ],
              ),
            ),

          const SizedBox(height: 18),

          Row(
            children: [

              /// CANCELAR
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    eliminarCalendarioApi(cliente["id_calendario"]);
                  },
                  icon: const Icon(
                    Icons.close,
                    size: 18,
                  ),
                  label: const Text(
                    "Cancelar",
                  ),
                  style: OutlinedButton.styleFrom(
                    padding: EdgeInsets.zero,
                    foregroundColor: Colors.red,
                    side: BorderSide(
                      color: Colors.red.shade300,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 8),

              /// EDITAR
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    mostrarModalEditarCalendario(
                      context,
                      cliente,
                    );
                  },
                  icon: const Icon(
                    Icons.edit_outlined,
                    size: 18,
                  ),
                  label: const Text(
                    "Editar",
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor:
                    Colors.orange.shade700,
                    side: BorderSide(
                      color:
                      Colors.orange.shade300,
                    ),
                    shape:
                    RoundedRectangleBorder(
                      borderRadius:
                      BorderRadius.circular(
                        12,
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 8),

              /// INICIAR
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () async {
                    if(cliente["estado"] == "activo"){
                      clientController.setClient(await getClientDetailApi(idUsuario: cliente["id_usuario"]));
                      controller.setPage(AsesorRoutes.dashBoardClient);
                    }else if(cliente["estado"] == "nuevo"){
                      mostrarModalDecisionCliente(context, cliente, clientController);
                    }
                  },
                  icon: const Icon(
                    Icons.play_arrow,
                    size: 18,
                  ),
                  label: const Text(
                    "Iniciar",
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                    Global.primary,
                    foregroundColor:
                    Colors.white,
                    shape:
                    RoundedRectangleBorder(
                      borderRadius:
                      BorderRadius.circular(
                        12,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          )

        ],
      ),
    );

  }
}

Future<void> mostrarModalDecisionCliente(BuildContext context, Map usuario, ClientController clientController) async {

  String? decision;

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
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Luego de comentar sobre el proyecto, ingresa la decisión que tomó el cliente.",
                    style: TextStyle(
                      color: Colors.grey.shade700,
                    ),
                  ),
                  const SizedBox(height: 20),
                  _opcionDecision(
                    titulo:
                    "Confirmar proceso",
                    icon: Icons.check_circle,
                    color: Colors.green,
                    seleccionado: decision == "activo",
                    onTap: () {
                      setModalState(() {
                        decision = "activo";
                      });
                    },
                  ),

                  const SizedBox(height: 10),

                  _opcionDecision(
                    titulo:
                    "Posponer proceso",
                    icon:
                    Icons.schedule,
                    color:
                    Colors.orange,
                    seleccionado: decision == "nuevo",
                    onTap: () {
                      setModalState(() {
                        decision = "nuevo";
                      });
                    },
                  ),

                  const SizedBox(height: 10),

                  _opcionDecision(
                    titulo:
                    "No continuar con el proceso",
                    icon:
                    Icons.cancel,
                    color:
                    Colors.red,
                    seleccionado:
                    decision ==
                        "desinteresado",
                    onTap: () {
                      setModalState(() {
                        decision = "desinteresado";
                      });
                    },
                  ),

                ],

              ),

            ),

            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context,);
                  },
                child: const Text(
                  "Cerrar",
                ),
              ),

              ElevatedButton(
                onPressed: decision == null
                    ? null
                    : () async {
                  Navigator.pop(context,);
                  await editClientApi(
                      idUsuario: usuario["id_usuario"],
                      updatedBy: controller.User["id_usuario"],
                      clientController: Get.find<ClientController>(),
                      estado: decision
                  );
                  if(decision == "activo"){
                    clientController.setClient(await getClientDetailApi(idUsuario: usuario["id_usuario"]));
                    controller.setPage(AsesorRoutes.dashBoardClient);
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

    borderRadius:
    BorderRadius.circular(16),

    child: AnimatedContainer(

      duration:
      const Duration(
        milliseconds: 200,
      ),

      padding:
      const EdgeInsets.all(
        16,
      ),

      decoration: BoxDecoration(

        color: seleccionado
            ? color.withOpacity(
          .12,
        )
            : Colors.transparent,

        borderRadius:
        BorderRadius.circular(
          16,
        ),

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
              style:
              const TextStyle(
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