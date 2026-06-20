import 'dart:convert';

import 'package:finanzas_verdes/app/config/Global.dart';
import 'package:finanzas_verdes/controllers/UserController.dart';
import 'package:finanzas_verdes/main.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;

Future<void> newUserApi({
  required String documento,
  required String nombreUsuario,
  required String email,
  String? telefono,
  required String password,
  required int idRol,
  required int createdBy,
  required UserController userController,

  // ✅ OPCIONAL ASESOR
  String? nombreCargo,
  String? sede,

  // ✅ OPCIONAL PROVEEDOR
  String? razonSocial,
  String? nit,
  String? direccion,
  double? calificacion,

}) async {
  final uri = Uri.parse('${Global.baseUrl}user');
  final token = GetStorage().read("token");

  try {
    final response = await http.post(
      uri,
      headers: {
        'Content-Type': 'application/json',
        "Authorization": "Bearer $token"
      },
      body: jsonEncode({

        // ✅ USUARIO
        'documento': documento,
        'nombre_usuario': nombreUsuario,
        'email': email,
        'telefono': telefono,
        'password': password,
        'id_rol': idRol,
        'created_by': createdBy,

        // ✅ ASESOR (solo si viene)
        if (nombreCargo != null) 'nombre_cargo': nombreCargo,
        if (sede != null) 'sede': sede,

        // ✅ PROVEEDOR (solo si viene)
        if (razonSocial != null) 'razon_social': razonSocial,
        if (nit != null) 'nit': nit,
        if (direccion != null) 'direccion': direccion,
        if (calificacion != null) 'calificacion': calificacion,
      }),
    );

    if (response.statusCode == 201) {
      print("Usuario creado correctamente");
      await getUsersApi(userController: userController);
      return;
    }

    if (response.statusCode == 400 || response.statusCode == 409) {
      final data = jsonDecode(response.body);
      throw Exception(data['error'] ?? 'Error de validación');
    }

    if (response.statusCode == 401) {
      controller.logOut();
      return;
    }

    throw Exception('Error inesperado (${response.statusCode})');

  } catch (e) {
    print("ERROR AL CREAR USUARIO: $e");
    rethrow;
  }
}


Future<void> editUserApi({
  required int idUsuario,
  String? documento,
  String? nombreUsuario,
  String? email,
  String? telefono,
  int? idRol,
  String? estado,
  required int updatedBy,
  required UserController userController,

  // ✅ ASESOR
  String? nombreCargo,
  String? sede,

  // ✅ PROVEEDOR
  String? razonSocial,
  String? nit,
  String? direccion,
  double? calificacion,

}) async {
  final uri = Uri.parse('${Global.baseUrl}user/$idUsuario');
  final token = GetStorage().read("token");

  try {
    final response = await http.patch(
      uri,
      headers: {
        'Content-Type': 'application/json',
        "Authorization": "Bearer $token"
      },
      body: jsonEncode({

        // ✅ USUARIO
        if (documento != null) 'documento': documento,
        if (nombreUsuario != null) 'nombre_usuario': nombreUsuario,
        if (email != null) 'email': email,
        if (telefono != null) 'telefono': telefono,
        if (idRol != null) 'id_rol': idRol,
        if (estado != null) 'estado': estado,
        'updated_by': updatedBy,

        // ✅ ASESOR
        if (nombreCargo != null) 'nombre_cargo': nombreCargo,
        if (sede != null) 'sede': sede,

        // ✅ PROVEEDOR
        if (razonSocial != null) 'razon_social': razonSocial,
        if (nit != null) 'nit': nit,
        if (direccion != null) 'direccion': direccion,
        if (calificacion != null) 'calificacion': calificacion,
      }),
    );

    if (response.statusCode == 200) {
      await getUsersApi(userController: userController);
      return;
    }

    if (response.statusCode == 401) {
      controller.logOut();
      return;
    }

    if (response.statusCode == 400 ||
        response.statusCode == 404 ||
        response.statusCode == 409) {
      final data = jsonDecode(response.body);
      throw Exception(data['error'] ?? 'Error de validación');
    }

    throw Exception('Error inesperado (${response.statusCode})');

  } catch (e) {
    print('ERROR AL EDITAR USUARIO: $e');
    rethrow;
  }
}

Future<Map<String, dynamic>> getUserDetailApi({
  required int idUsuario,
}) async {
  final uri = Uri.parse('${Global.baseUrl}user/$idUsuario');
  final token = GetStorage().read("token");

  try {
    final response = await http.get(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    // ✅ OK
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      // 👇 Devuelve directamente el user como Map
      return data['user'] as Map<String, dynamic>;
    }

    // 🔐 Token inválido
    if (response.statusCode == 401) {
      controller.logOut();
      throw Exception('Token inválido');
    }

    // ⚠️ Errores controlados
    if (response.statusCode == 400 || response.statusCode == 404) {
      final data = jsonDecode(response.body);
      throw Exception(data['error'] ?? 'Error');
    }

    throw Exception('Error inesperado (${response.statusCode})');

  } catch (e) {
    print("ERROR GET USER DETAIL: $e");
    rethrow;
  }
}

Future<void> getUsersApi({
  required UserController userController
}) async {
  final uri = Uri.parse('${Global.baseUrl}user');
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
      userController.setUsers(data["users"]);
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
    print("ERROR ESPECIAL AL OBTENER LOS USUARIOS: $e");
    rethrow;
  }
}

Future<void> getUsersByRolApi({
  required UserController userController,
  required int idRol
}) async {
  final uri = Uri.parse('${Global.baseUrl}user/rol/$idRol');
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
      userController.setUsers(data["users"]);
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
    print("ERROR ESPECIAL AL OBTENER LOS USUARIOS: $e");
    rethrow;
  }
}

Future<void> loginUserApi({
  required String email,
  required String password,
}) async {
  final uri = Uri.parse('${Global.baseUrl}login/login');

  try {
    final response = await http.post(
      uri,
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'email': email,
        'password': password,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      controller.setUser(data["user"]);
      final box = GetStorage();
      box.write("token", data["token"]);
      controller.redirectToAndSave(data["user"]);
      return;
    }

    // ⚠️ Errores controlados del backend
    if (response.statusCode == 401 || response.statusCode == 409) {
      final data = jsonDecode(response.body);
      Get.snackbar("Usuario no encontrado", "Credenciales inválidas");
    }

    // ❌ Cualquier otro error inesperado
    throw Exception('Error inesperado (${response.statusCode})');

  } catch (e) {
    print("ERROR ESPECIAL AL INICIAR SESIÓN: $e");
    rethrow;
  }
}