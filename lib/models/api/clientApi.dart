import 'dart:convert';

import 'package:finanzas_verdes/app/config/Global.dart';
import 'package:finanzas_verdes/controllers/ClientController.dart';
import 'package:finanzas_verdes/controllers/UserController.dart';
import 'package:finanzas_verdes/main.dart';
import 'package:flutter/material.dart';
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
  final uri = Uri.parse('${Global.baseUrl}client');
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
      await getClientApi(clientController: clientController);
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
    print("ERROR AL CREAR CLIENTE: $e");
    rethrow;
  }
}


Future<void> editClientApi({
  required int idUsuario,
  String? documento,
  String? nombreUsuario,
  String? email,
  String? telefono,
  String? estado,
  required int updatedBy,
  required ClientController clientController,
}) async {
  final uri = Uri.parse('${Global.baseUrl}client/$idUsuario');
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
        'updated_by': updatedBy,
      }),
    );

    if (response.statusCode == 200) {
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

    if (response.statusCode == 400 || response.statusCode == 409) {
      final data = jsonDecode(response.body);
      throw Exception(data['error'] ?? 'Error de validación');
    }

    if (response.statusCode == 401) {
      controller.logOut();
    }

    throw Exception('Error inesperado (${response.statusCode})');

  } catch (e) {
    print("ERROR ESPECIAL AL OBTENER LOS CLIENTES: $e");
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

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      return data as Map<String, dynamic>;
    }

    if (response.statusCode == 401) {
      controller.logOut();
      throw Exception('Token inválido');
    }

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

        // OPCIONALES
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


Future<Map<String, dynamic>> getClientFullImagesApi({
  required int idUsuario,
}) async {
  final uri = Uri.parse('${Global.baseUrl}client/images/$idUsuario');
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

Future<void> getClienteMipymeApi ({
  required int idUsuario,
  required ClientController clientController
}) async {
  final uri = Uri.parse('${Global.baseUrl}client/mipyme/$idUsuario');
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

      clientController.setInfoCliente(data["mipyme"]);
      return;
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

Future<void> getActivosByUsuarioApi({
  required int idUsuario,
  required ClientController clientController
}) async {

  final uri = Uri.parse('${Global.baseUrl}client/activo/$idUsuario');
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

      clientController.setActivos(data["activos"]);
      return;
    }

    if (response.statusCode == 401) {
      controller.logOut();
      throw Exception('Sesión expirada');
    }

    if (response.statusCode == 400 || response.statusCode == 404) {
      final data = jsonDecode(response.body);
      throw Exception(data['error'] ?? 'Error al obtener activos');
    }

    throw Exception('Error inesperado (${response.statusCode})');

  } catch (e) {
    print("ERROR GET ACTIVOS: $e");
    rethrow;
  }
}

Future<void> getConsumosByUsuarioApi({
  required int idUsuario,
  required ClientController clientController
}) async {

  final uri = Uri.parse('${Global.baseUrl}client/consumo/$idUsuario');
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

      clientController.setConsumos(data["consumos"]);
      return;
    }

    if (response.statusCode == 401) {
      controller.logOut();
      throw Exception('Sesión expirada');
    }

    if (response.statusCode == 400 || response.statusCode == 404) {
      final data = jsonDecode(response.body);
      throw Exception(data['error'] ?? 'Error al obtener consumos');
    }

    throw Exception('Error inesperado (${response.statusCode})');

  } catch (e) {
    print("ERROR GET CONSUMOS: $e");
    rethrow;
  }
}

Future<void> getDiagnosticosByUsuario ({
  required ClientController clientController
}) async {

  final uri = Uri.parse('${Global.baseUrl}diagnostico');
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

      clientController.setDiagnosticos(data["diagnosticos"]);
      return;
    }

    if (response.statusCode == 401) {
      controller.logOut();
      throw Exception('Sesión expirada');
    }

    if (response.statusCode == 400 || response.statusCode == 404) {
      final data = jsonDecode(response.body);
      throw Exception(data['error'] ?? 'Error al obtener diagnosticos');
    }

    throw Exception('Error inesperado (${response.statusCode})');

  } catch (e) {
    print("ERROR GET DIAGNOSTICOS: $e");
    rethrow;
  }
}

Future<void> getPlanesTrabajoByUsuario ({
  required ClientController clientController
}) async {

  final uri = Uri.parse('${Global.baseUrl}plantrabajo');
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
      print(data);
      clientController.setPlanesTrabajo(data["planes_trabajo"]);
      return;
    }

    if (response.statusCode == 401) {
      controller.logOut();
      throw Exception('Sesión expirada');
    }

    if (response.statusCode == 400 || response.statusCode == 404) {
      final data = jsonDecode(response.body);
      throw Exception(data['error'] ?? 'Error al obtener los planes de trabajo');
    }

    throw Exception('Error inesperado (${response.statusCode})');

  } catch (e) {
    print("ERROR GET PLANES TRABAJO: $e");
    rethrow;
  }
}

Future<void> createClientWithMipymeApi({
  // ✅ CLIENTE
  required String documento,
  required String nombreUsuario,
  required String email,
  String? telefono,

  // ✅ MIPYME
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
  String? departamento,
  String? barrio,
  String? tipo_persona,
  String? tipo_empresa,
  int? estrato,

  // ✅ EXTRA
  String? tipoRelacion,

  required int createdBy,
  required ClientController clientController,
}) async {

  final uri = Uri.parse('${Global.baseUrl}client/client-mipyme'); // ✅ ENDPOINT NUEVO
  final token = GetStorage().read("token");

  try {
    final response = await http.post(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({

        // CLIENTE
        'documento': documento,
        'nombre_usuario': nombreUsuario,
        'email': email,
        'telefono': telefono,
        'created_by': createdBy,

        // MIPYME
        'nombre_mipyme': nombreMipyme,
        'nit': nit,
        'sector_economico': sectorEconomico,
        'direccion': direccion,
        'municipio': municipio,
        'descripcion_empresa': descripcionEmpresa,
        'cantidad_empleados': cantidadEmpleados,
        'ingresos': ingresos,
        'egresos': egresos,
        'codigo_ciiu': codigoCiiu,
        'departamento': departamento,
        'barrio': barrio,
        'estrato' : estrato,
        'tipo_persona' : tipo_persona,
        'tipo_empresa' : tipo_empresa,

        /// ✅ RELACIÓN
        'tipo_relacion': tipoRelacion ?? 'propietario',
      }),
    );

    final data = jsonDecode(response.body);

    /// ✅ ÉXITO
    if (response.statusCode == 201) {

      Get.snackbar(
        "Éxito",
        data["message"] ?? "Cliente y mipyme creados",
        snackPosition: SnackPosition.BOTTOM,
        colorText: Colors.white,
        backgroundColor: Colors.green
      );

      await getClientApi(clientController: clientController);
      return;
    }

    /// ✅ ERRORES CONTROLADOS
    if (response.statusCode == 400 || response.statusCode == 409) {
      throw Exception(data["error"] ?? "Error de validación");
    }

    /// ✅ TOKEN
    if (response.statusCode == 401) {
      controller.logOut();
      return;
    }

    /// ✅ OTROS
    throw Exception(data["error"] ?? 'Error inesperado (${response.statusCode})');

  } catch (e) {
    print("ERROR CREATE CLIENT + MIPYME: $e");

    Get.snackbar(
      "Error",
      e.toString(),
      snackPosition: SnackPosition.BOTTOM,
      colorText: Colors.white,
      backgroundColor: Colors.red
    );

    rethrow;
  }
}
Future<void> updateMipymeApi({
  required int idMipyme,
  required int updatedBy,

  String? nombreMipyme,
  String? nit,
  String? sectorEconomico,

  String? departamento,
  String? municipio,
  String? barrio,
  String? direccion,

  String? descripcionEmpresa,
  int? cantidadEmpleados,
  double? ingresos,
  double? egresos,
  String? codigoCiiu,
  String? tipo_persona,
  String? tipo_empresa,
  int? estrato,
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

        'nombre_mipyme': nombreMipyme,
        'nit': nit,
        'sector_economico': sectorEconomico,

        'departamento': departamento,
        'municipio': municipio,
        'barrio': barrio,
        'direccion': direccion,

        'descripcion_empresa': descripcionEmpresa,
        'cantidad_empleados': cantidadEmpleados,
        'ingresos': ingresos,
        'egresos': egresos,
        'codigo_ciiu': codigoCiiu,
        'tipo_persona': tipo_persona,
        'tipo_empresa': tipo_empresa,

        'estrato': estrato,

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

Future<void> inactiveClientApi ({
  required int idClient,
}) async {

  final uri = Uri.parse('${Global.baseUrl}client/$idClient');
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
      print("Cliente desactivado correctamente");
      return;
    }

    if (response.statusCode == 401) {
      controller.logOut();
      return;
    }

    if (response.statusCode == 400 || response.statusCode == 404) {
      final data = jsonDecode(response.body);
      throw Exception(data['error'] ?? 'Error al desactivar cliente');
    }

    throw Exception('Error inesperado (${response.statusCode})');

  } catch (e) {
    print("ERROR INACTIVAR ACTIVO : $e");
    rethrow;
  }
}

Future<Map<String, dynamic>> searchClient({
  required String query,
}) async {

  final uri = Uri.parse(
    '${Global.baseUrl}client/search?nro=${Uri.encodeComponent(query)}',
  );

  final token = GetStorage().read("token");

  try {

    final response = await http.get(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return data["cliente"];
    }

    if (response.statusCode == 401) {
      controller.logOut();
      throw Exception('Sesión expirada');
    }

    if (
    response.statusCode == 400 ||
        response.statusCode == 404
    ) {
      throw Exception(
        data['error'] ??
            'Cliente no encontrado',
      );
    }

    throw Exception(
      'Error inesperado (${response.statusCode})',
    );

  } catch (e) {

    print(
      "ERROR SEARCH CLIENT: $e",
    );

    rethrow;
  }
}