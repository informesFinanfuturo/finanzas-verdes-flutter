import 'dart:convert';

import 'package:finanzas_verdes/app/config/Global.dart';
import 'package:finanzas_verdes/controllers/PermissionController.dart';
import 'package:finanzas_verdes/controllers/UserController.dart';
import 'package:finanzas_verdes/main.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;

Future<void> newPermissionApi({
  required String nombre,
  required PermissionController permissionController
}) async {
  final uri = Uri.parse('${Global.baseUrl}permission');
  final token = GetStorage().read("token");

  try {
    final response = await http.post(
      uri,
      headers: {
        'Content-Type': 'application/json',
        "Authorization" : "Bearer $token"
      },
      body: jsonEncode({
        'nombre': nombre,
      }),
    );

    if (response.statusCode == 201) {
      final data = jsonDecode(response.body);
      print("Permiso creado correctamente");
      getPermissionsApi(permissionController: permissionController);
      return;
    }

    if (response.statusCode == 401) {
      controller.logOut();
    }

    // ⚠️ Errores controlados del backend
    if (response.statusCode == 400 || response.statusCode == 409) {
      final data = jsonDecode(response.body);
      throw Exception(data['error'] ?? 'Error de validación');
    }

    // ❌ Cualquier otro error inesperado
    throw Exception('Error inesperado (${response.statusCode})');

  } catch (e) {
    print("ERROR ESPECIAL AL CREAR EL PERMISO: $e");
    rethrow;
  }
}


Future<void> editPermissionApi({
  required int id,
  required String nombre,
  required PermissionController permissionController,
}) async {
  final uri = Uri.parse('${Global.baseUrl}permission/$id');
  final token = GetStorage().read("token");

  try {
    final response = await http.patch(
      uri,
      headers: {
        'Content-Type': 'application/json',
        "Authorization" : "Bearer $token"
      },
      body: jsonEncode({
        'nombre': nombre,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      print("Permiso editado correctamente");
      getPermissionsApi(permissionController: permissionController);
      return;
    }

    // ⚠️ Errores controlados del backend
    if (response.statusCode == 400 || response.statusCode == 409) {
      final data = jsonDecode(response.body);
      throw Exception(data['error'] ?? 'Error de validación');
    }

    if (response.statusCode == 401) {
      controller.logOut();
    }

    // ❌ Cualquier otro error inesperado
    throw Exception('Error inesperado (${response.statusCode})');

  } catch (e) {
    print("ERROR ESPECIAL AL EDITAR EL PERMISO: $e");
    rethrow;
  }
}

Future<void> getPermissionsApi({
  required PermissionController permissionController
}) async {
  final uri = Uri.parse('${Global.baseUrl}permission');
  final token = GetStorage().read("token");

  try {
    final response = await http.get(
      uri,
      headers: {
        "Authorization" : "Bearer $token"
      }
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      permissionController.setPermissions(data["permissions"]);
      return;
    }

    // ⚠️ Errores controlados del backend
    if (response.statusCode == 400 || response.statusCode == 409) {
      final data = jsonDecode(response.body);
      throw Exception(data['error'] ?? 'Error de validación');
    }

    if (response.statusCode == 401) {
      controller.logOut();
    }

    // ❌ Cualquier otro error inesperado
    throw Exception('Error inesperado (${response.statusCode})');

  } catch (e) {
    print("ERROR ESPECIAL AL OBTENER LOS PERMISOS: $e");
    rethrow;
  }
}