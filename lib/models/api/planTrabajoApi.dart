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

Future<Map<String, dynamic>?> createPlanTrabajoApi({
  required String nombrePlanTrabajo,
  String? descripcion,
  String? fechaFin,
  required int idMipyme,
  required int createdBy,
  required List<Map<String, dynamic>> tareas,
}) async {

  final uri = Uri.parse('${Global.baseUrl}plantrabajo');
  final token = GetStorage().read("token");

  try {
    final response = await http.post(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'nombre_plan_trabajo': nombrePlanTrabajo,
        'descripcion': descripcion,
        'fecha_fin': fechaFin,
        'id_mipyme': idMipyme,
        'created_by': createdBy,
        'tareas': tareas,
      }),
    );

    final data = jsonDecode(response.body);

    // ✅ ÉXITO
    if (response.statusCode == 201) {

      Get.snackbar(
        "Éxito",
        data["message"] ?? "Plan creado correctamente",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );

      return data;
    }

    // ✅ SESIÓN EXPIRADA
    if (response.statusCode == 401) {
      controller.logOut();
      return null;
    }

    // ✅ ERRORES CONTROLADOS
    if (response.statusCode == 400 || response.statusCode == 404) {

      Get.snackbar(
        "Error",
        data["error"] ?? "No se pudo crear el plan",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );

      return null;
    }

    throw Exception('Error inesperado (${response.statusCode})');

  } catch (e) {
    print("ERROR CREATE PLAN TRABAJO: $e");

    Get.snackbar(
      "Error",
      "Error de conexión",
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.red,
      colorText: Colors.white,
    );

    rethrow;
  }
}

Future<Map<String, dynamic>?> editPlanTrabajoApi({
  required int idPlanTrabajo,
  required String nombrePlanTrabajo,
  String? descripcion,
  String? fechaFin,
  required int updatedBy,
  required List tareas,
}) async {

  final uri = Uri.parse('${Global.baseUrl}plantrabajo/$idPlanTrabajo');
  final token = GetStorage().read("token");

  try {
    final response = await http.patch(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'nombre_plan_trabajo': nombrePlanTrabajo,
        'descripcion': descripcion,
        'fecha_fin': fechaFin,
        'updated_by': updatedBy,
        'tareas': tareas,
      }),
    );

    final data = jsonDecode(response.body);

    // ✅ ÉXITO
    if (response.statusCode == 200) {
      return data;
    }

    // ✅ SESIÓN EXPIRADA
    if (response.statusCode == 401) {
      controller.logOut();
      return null;
    }

    // ✅ ERRORES CONTROLADOS
    if (response.statusCode == 400 || response.statusCode == 404) {

      Get.snackbar(
        "Error",
        data["error"] ?? "No se pudo editar el plan",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );

      return null;
    }

    throw Exception('Error inesperado (${response.statusCode})');

  } catch (e) {
    print("ERROR UPDATE PLAN TRABAJO: $e");

    Get.snackbar(
      "Error",
      "Error de conexión",
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.red,
      colorText: Colors.white,
    );

    rethrow;
  }
}

Future<Map> toggleTareaApi({
  required int idTarea,
  required int updatedBy,
}) async {

  final uri = Uri.parse('${Global.baseUrl}plantrabajo/tarea/$idTarea/toggle');
  final token = GetStorage().read("token");

  try {
    final response = await http.patch(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        "updated_by": updatedBy,
      }),
    );

    final data = jsonDecode(response.body);

    // ✅ ÉXITO
    if (response.statusCode == 200) {
      return data["plan_trabajo"];
    }

    // ✅ TOKEN
    if (response.statusCode == 401) {
      controller.logOut();
      return {};
    }

    // ✅ ERROR CONTROLADO
    if (response.statusCode == 400 || response.statusCode == 404) {
      Get.snackbar(
        "Error",
        data["error"] ?? "No se pudo actualizar la tarea",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return {};
    }

    throw Exception("Error inesperado (${response.statusCode})");

  } catch (e) {
    print("ERROR TOGGLE TAREA: $e");

    Get.snackbar(
      "Error",
      "Error de conexión",
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.red,
      colorText: Colors.white,
    );

    rethrow;
  }
}