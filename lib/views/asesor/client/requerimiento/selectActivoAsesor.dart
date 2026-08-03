import 'package:finanzas_verdes/app/config/Global.dart';
import 'package:finanzas_verdes/app/routes/subrutes/asesorRoutes.dart';
import 'package:finanzas_verdes/controllers/ClientController.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

Future<Map?> openSelectActivoAsesor (List activos, controller) async {

  return await Get.dialog<Map<String, dynamic>>(
    AlertDialog(
      title: Text("Selecciona un activo para cambiar"),
      content: SizedBox(
        width: double.maxFinite,
        height: 300,
        child: activos.isEmpty
            ? Center(child: Text("No hay activos disponibles para seleccionar"))
            : ListView.builder(
          itemCount: activos.length,
          itemBuilder: (context, i) {
            final d = activos[i];

            return InkWell(
              onTap: () {
                Get.back(result: d);
                controller.setPage(AsesorRoutes.newRequerimiento);
              },
              child: Container(
                margin: EdgeInsets.symmetric(vertical: 5),
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Global.container,
                ),
                child: Row(
                  children: [
                    Icon(Icons.psychology, color: Global.primary),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        d["nombre"] ?? "",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    Icon(Icons.arrow_forward_ios, size: 14)
                  ],
                ),
              ),
            );
          },
        ),
      ),

      actions: [
        TextButton(
          onPressed: () => Get.back(), // ✅ retorna null
          child: Text("Cancelar"),
        )
      ],
    ),
  );
}
