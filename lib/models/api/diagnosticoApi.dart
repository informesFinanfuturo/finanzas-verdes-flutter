import 'dart:convert';

import 'package:finanzas_verdes/app/config/Global.dart';
import 'package:finanzas_verdes/controllers/ClientController.dart';
import 'package:finanzas_verdes/main.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;

Future<Map> generarYSyncDiagnosticosApi({
  required int idMipyme,
  Map<String, dynamic>? empresa,
  List<dynamic>? activos,
  List<dynamic>? facturas,
  List<dynamic>? diagnosticos,
}) async {
  final uri = Uri.parse('${Global.baseUrl}diagnostico/generar');
  final token = GetStorage().read("token");

  try {
    final response = await http.post(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'id_mipyme': idMipyme,

        // ✅ TODO OPCIONAL
        if (empresa != null) 'empresa': empresa,
        if (activos != null) 'activos': activos,
        if (facturas != null) 'facturas': facturas,
        if (diagnosticos != null) 'diagnosticos': diagnosticos,
      }),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      // ✅ warnings opcionales
      if (data["warnings"] != null &&
          data["warnings"] is List &&
          data["warnings"].isNotEmpty) {
        Get.snackbar(
          "Aviso",
          (data["warnings"] as List).join("\n"),
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
          duration: const Duration(seconds: 5),
          margin: const EdgeInsets.all(12),
        );
      } else {
        Get.snackbar(
          "Éxito",
          data["message"] ?? "Diagnósticos generados correctamente",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
          duration: const Duration(seconds: 4),
          margin: const EdgeInsets.all(12),
        );
      }

      return data;
    }

    if (response.statusCode == 401) {
      controller.logOut();
      return {};
    }

    if (response.statusCode == 400) {
      final detalles = data["detalles"] is List
          ? (data["detalles"] as List).join("\n")
          : null;

      final mensaje = detalles ??
          data["error"] ??
          "No se pudo generar el diagnóstico";

      Get.snackbar(
        "Validación",
        mensaje,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 6),
        margin: const EdgeInsets.all(12),
      );

      return {};
    }

    if (response.statusCode == 404) {
      Get.snackbar(
        "Error",
        data["error"] ?? "Mipyme no encontrada",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 5),
        margin: const EdgeInsets.all(12),
      );

      return {};
    }

    throw Exception(data["error"] ?? 'Error inesperado (${response.statusCode})');
  } catch (e) {
    print("ERROR GENERAR SYNC DIAGNOSTICOS: $e");

    Get.snackbar(
      "Error",
      "No fue posible generar el diagnóstico",
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.red,
      colorText: Colors.white,
      duration: const Duration(seconds: 5),
      margin: const EdgeInsets.all(12),
    );

    rethrow;
  }
}