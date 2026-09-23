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
    showLoadingDialog();
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

    hideLoadingDialog();

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
    hideLoadingDialog();
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

void showLoadingDialog() {
  Get.dialog(
    PopScope(
      canPop: false,
      child: Dialog(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: const [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text(
                "Generando análisis con IA",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8),
              Text(
                "Estamos analizando activos, facturas y extrayendo datos.",
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    ),
    barrierDismissible: false,
  );
}

void hideLoadingDialog() {
  if (Get.isDialogOpen ?? false) {
    Get.close(1);
  }
}

Future<Map> guardarSeleccionActivosDiagnosticoApi({
  required int idDiagnostico,
  required List<int> activosSeleccionados,
  required Map<String, dynamic> resumenSeleccionado,
}) async {

  final uri = Uri.parse(
    '${Global.baseUrl}diagnostico/$idDiagnostico/seleccion-activos',
  );

  final token = GetStorage().read("token");

  try {

    showLoadingDialog();

    final response = await http.patch(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        "activos_seleccionados":
        activosSeleccionados,

        "resumen_seleccionado":
        resumenSeleccionado,
      }),
    );

    hideLoadingDialog();

    final data =
    jsonDecode(response.body);

    if (response.statusCode == 200) {

      Get.snackbar(
        "Éxito",
        data["message"] ??
            "Selección guardada correctamente",
        snackPosition:
        SnackPosition.BOTTOM,
        backgroundColor:
        Colors.green,
        colorText:
        Colors.white,
      );

      return data;
    }

    if (response.statusCode == 401) {

      controller.logOut();

      return {};
    }

    if (response.statusCode == 404) {

      Get.snackbar(
        "Error",
        data["error"] ??
            "Diagnóstico no encontrado",
        snackPosition:
        SnackPosition.BOTTOM,
        backgroundColor:
        Colors.red,
        colorText:
        Colors.white,
      );

      return {};
    }

    throw Exception(
      data["error"] ??
          "Error inesperado",
    );

  } catch (e) {

    hideLoadingDialog();

    print(
        "ERROR GUARDAR SELECCION ACTIVOS: $e"
    );

    Get.snackbar(
      "Error",
      "No fue posible guardar la selección",
      snackPosition:
      SnackPosition.BOTTOM,
      backgroundColor:
      Colors.red,
      colorText:
      Colors.white,
    );

    rethrow;
  }
}