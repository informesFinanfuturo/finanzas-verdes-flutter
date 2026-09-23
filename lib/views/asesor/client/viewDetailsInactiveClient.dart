import 'package:finanzas_verdes/app/config/Global.dart';
import 'package:finanzas_verdes/controllers/ClientController.dart';
import 'package:finanzas_verdes/main.dart';
import 'package:finanzas_verdes/models/api/clientApi.dart';
import 'package:finanzas_verdes/views/asesor/asesor/createCalendarioAsesor.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

void viewDetailsInactiveClient({
  required String nombreCliente,
  required int idUsuario,
  String? nombreEmpresa,
  String? telefono,
  required String email,
  required String estado,
  String? observacionesEstado,
  required context
}) {
  Get.dialog(
    AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      title: Row(
        children: [
          Icon(
            Icons.person_off,
            color: Colors.red.shade600,
          ),
          const SizedBox(width: 10),
          const Expanded(
            child: Text(
              'Detalle del cliente inactivo',
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _detailItem(
              icon: Icons.person,
              title: 'Nombre del cliente',
              value: nombreCliente,
            ),

            if (nombreEmpresa != null && nombreEmpresa.isNotEmpty)
              _detailItem(
                icon: Icons.business,
                title: 'Empresa',
                value: nombreEmpresa,
              ),

            if (telefono != null && telefono.isNotEmpty)
              _detailItem(
                icon: Icons.phone,
                title: 'Teléfono',
                value: telefono,
              ),

            _detailItem(
              icon: Icons.email,
              title: 'Correo electrónico',
              value: email,
            ),

            _detailItem(
              icon: Icons.flag,
              title: 'Estado',
              value: estado,
              valueColor: Colors.red.shade700,
            ),

            if (observacionesEstado != null && observacionesEstado.isNotEmpty)
            _detailItem(
              icon: Icons.note_alt,
              title: 'Observaciones',
              value: observacionesEstado,
            ),
          ],
        ),
      ),
      actions: [
        ElevatedButton.icon(
          onPressed: () => Get.back(),
          icon: const Icon(Icons.close),
          label: const Text('Cerrar'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red.shade600,
            foregroundColor: Colors.white,
          ),
        ),
        ElevatedButton.icon(
          onPressed: () async {
            final result = await mostrarModalCrearCalendario(
                context,
                {
                  "nombre_usuario" : nombreCliente,
                  "nombre_mipyme" : nombreEmpresa,
                  "email" : email,
                  "id_usuario" : idUsuario,
                },
                "Visita de reapertura de proceso"
            );
            if(result){

              final clientController = Get.put(ClientController());
              getClientsByEstadoApi(clientController: clientController, estado: estado);
              editClientApi(idUsuario: idUsuario, updatedBy: controller.User["id_usuario"], clientController: clientController, estado: "nuevo");
            }
          },
          icon: const Icon(Icons.calendar_month),
          label: const Text('Reagendar'),
          style: ElevatedButton.styleFrom(

            foregroundColor: Global.primary,
          ),
        ),
      ],
    ),
    barrierDismissible: true,
  );
}

/// Widget auxiliar
Widget _detailItem({
  required IconData icon,
  required String title,
  required String value,
  Color? valueColor,
}) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 15),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 20,
          color: Colors.grey.shade700,
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                value,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: valueColor,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}