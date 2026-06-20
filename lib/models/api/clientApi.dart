import 'dart:convert';

import 'package:finanzas_verdes/app/config/Global.dart';
import 'package:finanzas_verdes/controllers/ClientController.dart';
import 'package:finanzas_verdes/controllers/UserController.dart';
import 'package:finanzas_verdes/main.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;

Future<void> createClientApi({
  required String documento,
  required String nombreUsuario,
  required String email,
  String? telefono,
  required String password,
  required int createdBy,
  required ClientController clientController,
}) async {
  final uri = Uri.parse('${Global.baseUrl}client'); // ✅ endpoint de cliente
  final token = GetStorage().read("token");

  try {
    final response = await http.post(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'documento': documento,
        'nombre_usuario': nombreUsuario,
        'email': email,
        'telefono': telefono,
        'password': password,
        'created_by': createdBy,
      }),
    );

    if (response.statusCode == 201) {
      // ✅ Éxito
      await getClientApi(clientController: clientController);
      return;
    }

    // ⚠️ Errores controlados
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
    print("ERROR AL CREAR CLIENTE: $e");
    rethrow;
  }
}


Future<void> editClientApi({
  required int idUsuario,                     // id del cliente
  String? documento,
  String? nombreUsuario,
  String? email,
  String? telefono,
  String? estado,
  required int updatedBy,                     // auditoría
  required ClientController clientController, // refrescar lista
}) async {
  final uri = Uri.parse('${Global.baseUrl}client/$idUsuario'); // ✅ endpoint correcto
  final token = GetStorage().read("token");

  try {
    final response = await http.patch(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        if (documento != null) 'documento': documento,
        if (nombreUsuario != null) 'nombre_usuario': nombreUsuario,
        if (email != null) 'email': email,
        if (telefono != null) 'telefono': telefono,
        if (estado != null) 'estado': estado,
        'updated_by': updatedBy, // ✅ SIEMPRE
      }),
    );

    if (response.statusCode == 200) {
      // ✅ Éxito
      await getClientApi(clientController: clientController);
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
    print('ERROR AL EDITAR CLIENTE: $e');
    rethrow;
  }
}

Future<void> getClientApi({
  required ClientController clientController
}) async {
  final uri = Uri.parse('${Global.baseUrl}client');
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
      clientController.setClients(data["clients"]);
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
    print("ERROR ESPECIAL AL OBTENER LOS CLIENTES: $e");
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

Future<Map<String, dynamic>> getClientDetailApi({
  required int idUsuario,
}) async {
  final uri = Uri.parse('${Global.baseUrl}client/$idUsuario');
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
      return data as Map<String, dynamic>;
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

Future<void> createMipymeApi({
  required int idUsuario,
  required int createdBy,

  String? nombreMipyme,
  String? nit,
  String? sectorEconomico,
  String? direccion,
  String? municipio,
  String? descripcionEmpresa,
  int? cantidadEmpleados,
  double? ingresos,
  double? egresos,
  String? codigoCiiu,

}) async {

  final uri = Uri.parse('${Global.baseUrl}client/mipyme');
  final token = GetStorage().read("token");

  try {
    final response = await http.post(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({

        // OBLIGATORIOS
        'id_usuario': idUsuario,
        'created_by': createdBy,

        // ✅ OPCIONALES (solo si vienen)
        if (nombreMipyme != null) 'nombre_mipyme': nombreMipyme,
        if (nit != null) 'nit': nit,
        if (sectorEconomico != null) 'sector_economico': sectorEconomico,
        if (direccion != null) 'direccion': direccion,
        if (municipio != null) 'municipio': municipio,
        if (descripcionEmpresa != null) 'descripcion_empresa': descripcionEmpresa,
        if (cantidadEmpleados != null) 'cantidad_empleados': cantidadEmpleados,
        if (ingresos != null) 'ingresos': ingresos,
        if (egresos != null) 'egresos': egresos,
        if (codigoCiiu != null) 'codigo_ciiu': codigoCiiu,
      }),
    );

    if (response.statusCode == 201) {
      // Éxito
      print("Mipyme creada correctamente");
      return;
    }

    if (response.statusCode == 401) {
      controller.logOut();
      return;
    }

    if (response.statusCode == 400 || response.statusCode == 404) {
      final data = jsonDecode(response.body);
      throw Exception(data['error'] ?? 'Error de validación');
    }

    throw Exception('Error inesperado (${response.statusCode})');

  } catch (e) {
    print("ERROR CREATE MIPYME: $e");
    rethrow;
  }
}

Future<void> updateMipymeApi({
  required int idMipyme,
  required int updatedBy,

  // ✅ OPCIONALES
  String? nombreMipyme,
  String? nit,
  String? sectorEconomico,
  String? direccion,
  String? municipio,
  String? descripcionEmpresa,
  int? cantidadEmpleados,
  double? ingresos,
  double? egresos,
  String? codigoCiiu,
  String? estado,

}) async {

  final uri = Uri.parse('${Global.baseUrl}client/mipyme/$idMipyme');
  final token = GetStorage().read("token");

  try {
    final response = await http.patch(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({

        // ✅ solo enviamos lo que cambia
        if (nombreMipyme != null) 'nombre_mipyme': nombreMipyme,
        if (nit != null) 'nit': nit,
        if (sectorEconomico != null) 'sector_economico': sectorEconomico,
        if (direccion != null) 'direccion': direccion,
        if (municipio != null) 'municipio': municipio,
        if (descripcionEmpresa != null) 'descripcion_empresa': descripcionEmpresa,
        if (cantidadEmpleados != null) 'cantidad_empleados': cantidadEmpleados,
        if (ingresos != null) 'ingresos': ingresos,
        if (egresos != null) 'egresos': egresos,
        if (codigoCiiu != null) 'codigo_ciiu': codigoCiiu,
        if (estado != null) 'estado': estado,

        // ✅ obligatorio
        'updated_by': updatedBy,
      }),
    );

    if (response.statusCode == 200) {
      print("Mipyme actualizada correctamente");
      return;
    }

    if (response.statusCode == 401) {
      controller.logOut();
      return;
    }

    if (response.statusCode == 400 || response.statusCode == 404) {
      final data = jsonDecode(response.body);
      throw Exception(data['error'] ?? 'Error al actualizar mipyme');
    }

    throw Exception('Error inesperado (${response.statusCode})');

  } catch (e) {
    print("ERROR UPDATE MIPYME: $e");
    rethrow;
  }
}