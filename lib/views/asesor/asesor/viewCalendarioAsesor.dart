import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

Future<void> mostrarModalDetalleCalendario(BuildContext context, Map<String, dynamic> cliente,) async {

  await showDialog(

    context: context,

    builder: (_) => AlertDialog(

      title: Text(
        cliente["titulo"] ?? "",
      ),

      content: Column(

        mainAxisSize:
        MainAxisSize.min,

        crossAxisAlignment:
        CrossAxisAlignment.start,

        children: [

          Text(
            "Cliente: "
                "${cliente["nombre_usuario"]}",
          ),

          const SizedBox(
            height: 10,
          ),

          Text(
            "Empresa: "
                "${cliente["nombre_mipyme"]}",
          ),

          const SizedBox(
            height: 10,
          ),

          Text(
            "Descripción: "
                "${cliente["descripcion"] ?? ''}",
          ),

        ],

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

      ],

    ),

  );

}