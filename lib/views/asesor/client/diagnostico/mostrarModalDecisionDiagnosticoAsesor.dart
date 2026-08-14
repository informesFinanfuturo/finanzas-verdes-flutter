import 'package:flutter/material.dart';

void mostrarModalDecision(String estado, context) {

  showDialog(
    context: context,
    builder: (_) {
      return AlertDialog(
        title: const Text("Confirmar decisión",),
        content: Text("¿Deseas registrar esta decisión del cliente?"),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text("Cancelar",),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              // TODO:
              // await actualizarEstadoCliente(...);

            },
            child: const Text(
              "Guardar",
            ),
          ),
        ],
      );
    },
  );
}