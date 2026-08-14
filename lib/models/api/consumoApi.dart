import 'dart:convert';

import 'package:finanzas_verdes/app/config/Global.dart';
import 'package:finanzas_verdes/controllers/RolController.dart';
import 'package:finanzas_verdes/controllers/UserController.dart';
import 'package:finanzas_verdes/main.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

Future<int> createConsumoApi({
  required String tipo,
  required int idMipyme,
  required int createdBy,

  String? proveedor,
  String? periodo_inicio,
  String? periodo_fin,
  double? valor,

  // ✅ NUEVO
  int? consumoActual,
  int? consumoPromedio,
  List<int>? consumoAnteriores,

  String? unidad,
  String? observaciones,
}) async {

  final uri = Uri.parse('${Global.baseUrl}consumo');
  final token = GetStorage().read("token");

  try {
    final response = await http.post(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({

        /// ✅ OBLIGATORIOS
        'tipo': tipo,
        'id_mipyme': idMipyme,
        'created_by': createdBy,

        /// ✅ OPCIONALES
        if (proveedor != null) 'proveedor': proveedor,
        if (periodo_inicio != null) 'periodo_inicio': periodo_inicio,
        if (periodo_fin != null) 'periodo_fin': periodo_fin,
        if (valor != null) 'valor': valor,

        /// ✅ NUEVO CONSUMO JSON
        if (consumoActual != null) 'consumo_actual': consumoActual,
        if (consumoPromedio != null) 'consumo_promedio': consumoPromedio,
        if (consumoAnteriores != null) 'consumo_anteriores': consumoAnteriores,

        if (unidad != null) 'unidad': unidad,
        if (observaciones != null) 'observaciones': observaciones,
      }),
    );

    final data = jsonDecode(response.body);

    /// ✅ ÉXITO
    if (response.statusCode == 201) {
      return data["id_consumo"];
    }

    /// ✅ AUTH
    if (response.statusCode == 401) {
      controller.logOut();
      return 0;
    }

    /// ✅ ERRORES
    if (response.statusCode == 400 || response.statusCode == 404) {
      throw Exception(data['error'] ?? 'Error al crear consumo');
    }

    throw Exception('Error inesperado (${response.statusCode})');

  } catch (e) {
    print("ERROR CREATE CONSUMO: $e");

    Get.snackbar(
      "Error",
      e.toString(),
      backgroundColor: Colors.red,
      colorText: Colors.white,
    );

    rethrow;
  }
}

Future<void> updateConsumoApi({
  required int idConsumo,
  required int updatedBy,

  String? tipo,
  String? proveedor,
  String? periodo_inicio,
  String? periodo_fin,
  double? valor,

  int? consumoActual,
  int? consumoPromedio,
  List<int>? consumoAnteriores,

  String? unidad,
  String? observaciones,
  String? estado,
}) async {

  final uri = Uri.parse('${Global.baseUrl}consumo/$idConsumo');
  final token = GetStorage().read("token");

  try {
    final response = await http.patch(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'tipo': tipo,
        'proveedor': proveedor,
        'periodo_inicio': periodo_inicio,
        'periodo_fin': periodo_fin,
        'valor': valor,

        'consumo_actual': consumoActual,
        'consumo_promedio': consumoPromedio,
        'consumo_anteriores': consumoAnteriores,

        'unidad': unidad,
        'observaciones': observaciones,
        'estado': estado,

        'updated_by': updatedBy,
      }),
    );

    final data = jsonDecode(response.body);

    /// ✅ ÉXITO
    if (response.statusCode == 200) {
      print("Consumo actualizado correctamente ✅");

      Get.snackbar(
        "Éxito",
        "Consumo actualizado",
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );

      return;
    }

    /// ✅ AUTH
    if (response.statusCode == 401) {
      controller.logOut();
      return;
    }

    /// ✅ ERROR IA (si lo usas aquí también)
    if (response.statusCode == 422) {
      Get.snackbar(
        "IA",
        data["ai_error"]?["message_user"] ?? "Error al procesar datos",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    /// ✅ ERRORES NORMALES
    if (response.statusCode == 400 || response.statusCode == 404) {
      throw Exception(data['error'] ?? 'Error al actualizar consumo');
    }

    throw Exception('Error inesperado (${response.statusCode})');

  } catch (e) {
    print("ERROR UPDATE CONSUMO: $e");

    Get.snackbar(
      "Error",
      e.toString(),
      backgroundColor: Colors.red,
      colorText: Colors.white,
    );

    rethrow;
  }
}

Future<Map<String, dynamic>> getConsumoApi({
  required int idConsumo,
}) async {

  final uri = Uri.parse('${Global.baseUrl}consumo/$idConsumo');
  final token = GetStorage().read("token");

  try {
    final response = await http.get(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      return data['consumo'] as Map<String, dynamic>;
    }

    if (response.statusCode == 401) {
      controller.logOut();
      throw Exception('Sesión expirada');
    }

    if (response.statusCode == 400 || response.statusCode == 404) {
      final data = jsonDecode(response.body);
      throw Exception(data['error'] ?? 'Error al obtener consumo');
    }

    throw Exception('Error inesperado (${response.statusCode})');

  } catch (e) {
    print("ERROR GET CONSUMO: $e");
    rethrow;
  }
}

Future<void> uploadImagenConsumoApi({
  required int idConsumo,
  required int createdBy,
  required XFile image,
}) async {

  final uri = Uri.parse('${Global.baseUrl}consumo/upload');
  final token = GetStorage().read("token");

  try {
    final request = http.MultipartRequest('POST', uri);

    // ✅ headers
    request.headers['Authorization'] = 'Bearer $token';

    // ✅ campos
    request.fields['id_consumo'] = idConsumo.toString();
    request.fields['created_by'] = createdBy.toString();

    // ✅ 👇 ESTE ES EL FIX IMPORTANTE
    final bytes = await image.readAsBytes();

    request.files.add(
      http.MultipartFile.fromBytes(
        'image', // 🔥 DEBE SER EXACTO
        bytes,
        filename: image.name,
      ),
    );

    final response = await request.send();

    if (response.statusCode == 201) {
      print("Imagen subida ✅");
      return;
    }

    final respStr = await response.stream.bytesToString();
    print(respStr);

    throw Exception("Error upload (${response.statusCode})");

  } catch (e) {
    print("ERROR UPLOAD IMAGEN: $e");
    rethrow;
  }
}

Future<void> deleteImagenConsumoApi({
  required int idArchivo,
}) async {

  final uri = Uri.parse('${Global.baseUrl}consumo/image/$idArchivo');
  final token = GetStorage().read("token");

  try {
    final response = await http.delete(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      print("Imagen eliminada correctamente ✅");
      return;
    }

    if (response.statusCode == 401) {
      controller.logOut();
      return;
    }

    if (response.statusCode == 400 || response.statusCode == 404) {
      final data = jsonDecode(response.body);
      throw Exception(data['error'] ?? 'Error al eliminar imagen');
    }

    throw Exception('Error inesperado (${response.statusCode})');

  } catch (e) {
    print("ERROR DELETE IMAGEN: $e");
    rethrow;
  }
}

Future<void> analizarConsumoApi({
  required int idConsumo,
}) async {

  final uri = Uri.parse('${Global.baseUrl}consumo/analizar/$idConsumo');
  final token = GetStorage().read("token");

  try {
    showLoadingDialog();
    final response = await http.post(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    hideLoadingDialog();

    final data = jsonDecode(response.body);

    /// ✅ ÉXITO
    if (response.statusCode == 200) {

      Get.snackbar(
        "IA",
        "Factura analizada correctamente ✅",
        backgroundColor: Colors.green,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );

      return;
    }

    /// ✅ AUTH
    if (response.statusCode == 401) {
      controller.logOut();
      return;
    }

    /// ✅ ERROR ESPECÍFICO DE IA 🔥
    if (response.statusCode == 422) {

      final mensaje = data["ai_error"]?["message_user"] ??
          "La IA no pudo analizar la factura";

      Get.snackbar(
        "IA",
        mensaje,
        backgroundColor: Colors.red, // 🔥 rojo sólido
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 4),
      );

      return;
    }

    /// ✅ ERRORES DE BACKEND NORMALES
    if (response.statusCode == 400 || response.statusCode == 404) {
      throw Exception(data['error'] ?? 'Error al analizar consumo');
    }

    throw Exception('Error inesperado (${response.statusCode})');

  } catch (e) {
    hideLoadingDialog();

    print("ERROR ANALIZAR CONSUMO : $e");

    Get.snackbar(
      "Error",
      e.toString(),
      backgroundColor: Colors.red,
      colorText: Colors.white,
      snackPosition: SnackPosition.BOTTOM,
    );

    rethrow;
  }
}

Future<void> deleteConsumoApi ({
  required int idConsumo,
}) async {

  final uri = Uri.parse('${Global.baseUrl}consumo/$idConsumo');
  final token = GetStorage().read("token");

  try {
    final response = await http.delete(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      print("Consumo eliminado correctamente");
      return;
    }

    if (response.statusCode == 401) {
      controller.logOut();
      return;
    }

    if (response.statusCode == 400 || response.statusCode == 404) {
      final data = jsonDecode(response.body);
      throw Exception(data['error'] ?? 'Error al analizar consumo');
    }

    throw Exception('Error inesperado (${response.statusCode})');

  } catch (e) {
    print("ERROR ANALIZAR CONSUMO : $e");
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
                "Estamos analizando imágenes y extrayendo datos.",
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