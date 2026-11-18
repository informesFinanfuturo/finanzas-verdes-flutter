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
  required List<Map<String, dynamic>> alternativasSeleccionadas,
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

        "alternativas_seleccionadas":
        alternativasSeleccionadas,

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

Future<Map<String, dynamic>>
getAlternativasActivoDiagnosticoApi({
  required int idDiagnostico,
  required int idActivo,
}) async {
  final uri = Uri.parse(
    '${Global.baseUrl}diagnostico/$idDiagnostico/activo/$idActivo/alternativas',
  );
  final token = GetStorage().read('token');
  try {
    final response = await http.get(
      uri,
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    ).timeout(const Duration(seconds: 25));

    // No ejecutar jsonDecode si el servidor devolvio HTML (404 de Express,
    // un proxy, una pagina de login o un servidor equivocado).
    Map<String, dynamic>? data;
    final tipo = response.headers['content-type']?.toLowerCase() ?? '';
    if (tipo.contains('application/json') && response.body.isNotEmpty) {
      try {
        final decoded = jsonDecode(response.body);
        if (decoded is Map) {
          data = Map<String, dynamic>.from(decoded);
        }
      } catch (_) {
        throw Exception('La API devolvio JSON invalido (HTTP ${response.statusCode}).');
      }
    }

    if (response.statusCode == 401) {
      controller.logOut();
      throw Exception('La sesion ha expirado. Inicia sesion nuevamente.');
    }

    if (response.statusCode == 200) {
      if (data == null) {
        throw Exception('La API devolvio una respuesta inesperada en vez de los productos del catalogo.');
      }
      if (data['activo'] is! Map || data['alternativas'] is! List) {
        throw Exception('La API no devolvio el formato de alternativas esperado.');
      }
      return data;
    }

    // Referencia historica no vinculada. Permitir al asesor resolverla
    // antes de elegir un producto; no tratarla como un error generico.
    if (response.statusCode == 409 &&
        data?['codigo'] == 'ACTIVO_SIN_VINCULO') {
      return data!;
    }

    if (data != null && data['error'] != null) {
      throw Exception(data['error'].toString());
    }
    if (response.statusCode == 404 && !tipo.contains('application/json')) {
      throw Exception(
        'La API no reconoce la ruta de alternativas (404). Comprueba que el backend local fue reiniciado y que Flutter utiliza su direccion.',
      );
    }
    throw Exception('No fue posible consultar alternativas (HTTP ${response.statusCode}).');
  } catch (error) {
    debugPrint('ERROR OBTENER ALTERNATIVAS DEL ACTIVO: $error');
    rethrow;
  }
}

// Vinculacion EXPLICITA, con confirmacion del asesor. Nunca se asigna un
// activo de otra empresa ni se crea un registro sin autorizacion.
Future<Map<String, dynamic>> vincularActivoDiagnosticoApi({
  required int idDiagnostico,
  required int idActivoOriginal,
  int? idActivoReal,
  bool crearDesdeDiagnostico = false,
}) async {
  final token = GetStorage().read('token');
  final uri = Uri.parse(
    '${Global.baseUrl}diagnostico/$idDiagnostico/activo/$idActivoOriginal/vincular',
  );
  final response = await http.post(uri,
    headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    },
    body: jsonEncode({
      if (idActivoReal != null) 'id_activo_real': idActivoReal,
      if (crearDesdeDiagnostico) 'crear_desde_diagnostico': true,
    }),
  ).timeout(const Duration(seconds: 25));
  Map<String,dynamic> data = {};
  try {
    final decoded=jsonDecode(response.body);
    if(decoded is Map) data=Map<String,dynamic>.from(decoded);
  } catch (_) {}
  if(response.statusCode==401) {
    controller.logOut();
    throw Exception('La sesion ha expirado.');
  }
  if(response.statusCode!=200) {
    throw Exception(data['error']?.toString() ??
      'No se pudo vincular el activo (HTTP ${response.statusCode}).');
  }
  return data;
}
