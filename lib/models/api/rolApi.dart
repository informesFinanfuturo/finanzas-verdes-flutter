import 'dart:convert';

import 'package:finanzas_verdes/app/config/Global.dart';
import 'package:finanzas_verdes/controllers/RolController.dart';
import 'package:finanzas_verdes/controllers/UserController.dart';
import 'package:finanzas_verdes/main.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;

Future<void> getRolsApi({
  required RolController rolController
}) async {
  final uri = Uri.parse('${Global.baseUrl}rol');
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
      rolController.setRols(data["rols"]);
      return;
    }

    // ⚠️ Errores controlados del backend
    if (response.statusCode == 400 || response.statusCode == 409) {
      final data = jsonDecode(response.body);
      throw Exception(data['error'] ?? 'Error de validación');
    }

    // ❌ Cualquier otro error inesperado
    throw Exception('Error inesperado (${response.statusCode})');

  } catch (e) {
    print("ERROR ESPECIAL AL OBTENER LOS ROLES: $e");
    rethrow;
  }
}

Future<Map> getRolApi({
  required int id,
  required RolController rolController,
}) async {
  final uri = Uri.parse('${Global.baseUrl}rol/$id');
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
      return data["rol"];
    }

    // ⚠️ Errores controlados del backend
    if (response.statusCode == 400 || response.statusCode == 409) {
      final data = jsonDecode(response.body);
      throw Exception(data['error'] ?? 'Error de validación');
    }

    // ❌ Cualquier otro error inesperado
    throw Exception('Error inesperado (${response.statusCode})');

  } catch (e) {
    print("ERROR ESPECIAL AL OBTENER LOS ROLES: $e");
    rethrow;
  }
}

Future<void> editRolApi({
  required int id,
  required String nombre,
  required RolController rolController,
}) async {
  final uri = Uri.parse('${Global.baseUrl}rol/$id');
  final token = GetStorage().read("token");

  try {
    final response = await http.patch(
      uri,
      headers: {
        'Content-Type': 'application/json',
        "Authorization" : "Bearer $token"
      },
      body: jsonEncode({
        'nombre_rol': nombre,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      print("Rol editado correctamente");
      getRolsApi(rolController: rolController);
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
      print("ERROR ESPECIAL AL EDITAR EL ROL: $e");
    rethrow;
  }
}

Future<void> newRolApi({
  required String nombre,
  required RolController rolController
}) async {
  final uri = Uri.parse('${Global.baseUrl}rol');
  final token = GetStorage().read("token");

  try {
    final response = await http.post(
      uri,
      headers: {
        'Content-Type': 'application/json',
        "Authorization" : "Bearer $token"
      },
      body: jsonEncode({
        'nombre_rol': nombre,
      }),
    );

    if (response.statusCode == 201) {
      final data = jsonDecode(response.body);
      print("Rol creado correctamente");
      getRolsApi(rolController: rolController);
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
    print("ERROR ESPECIAL AL CREAR EL ROL: $e");
    rethrow;
  }
}

Future<void> toggleRolPermissionApi({
  required int id_permission,
  required int id_rol,
  required RolController rolController,
}) async {
  final uri = Uri.parse('${Global.baseUrl}rol/permission');
  final token = GetStorage().read("token");

  try {
    final response = await http.patch(
      uri,
      headers: {
        'Content-Type': 'application/json',
        "Authorization" : "Bearer $token"
      },
      body: jsonEncode({
        "id_permiso" : id_permission,
        "id_rol" : id_rol
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      getRolsApi(rolController: rolController);
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
    print("ERROR ESPECIAL AL INSERTAR EL PERMISO: $e");
    rethrow;
  }
}