import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:finanzas_verdes/app/config/Global.dart';
import 'package:get_storage/get_storage.dart';

Future<bool> createRequerimientoApi({
  required String tipoRequerimiento,
  required String nombre,
  String? descripcion,
  Map<String, dynamic>? especificaciones,
  double? presupuestoEstimado,
  String? fechaLimite,
  required int createdBy,
}) async {

  try {
    final uri = Uri.parse(
      "${Global.baseUrl}requerimiento",
    );

    final token = GetStorage().read("token");

    final response = await http.post(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        "tipo_requerimiento": tipoRequerimiento,
        "nombre": nombre,
        "descripcion": descripcion,
        "especificaciones": especificaciones,
        "presupuesto_estimado": presupuestoEstimado,
        "fecha_limite": fechaLimite,
        "created_by": createdBy,
      }),
    );

    print("CREATE REQUERIMIENTO STATUS: ${response.statusCode}");
    print("CREATE REQUERIMIENTO BODY: ${response.body}");

    if (response.statusCode == 201) {

      final data = jsonDecode(response.body);

      Get.snackbar(
        "Éxito",
        data["message"] ?? "Requerimiento creado correctamente",
        snackPosition: SnackPosition.BOTTOM,
        colorText: Colors.white,
        backgroundColor: Colors.green
      );

      return true;

    } else {

      final error = jsonDecode(response.body);

      Get.snackbar(
        "Error",
        error["error"] ?? "No se pudo crear el requerimiento",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );

      return false;
    }

  } catch (e) {

    print("ERROR createRequerimientoApi: $e");

    Get.snackbar(
      "Error",
      "Error de conexión",
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.red,
      colorText: Colors.white,
    );

    return false;
  }
}