import 'dart:convert';

import 'package:finanzas_verdes/app/config/Global.dart';
import 'package:finanzas_verdes/controllers/ProveedorController.dart';
import 'package:finanzas_verdes/main.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;

Future<Map<String, dynamic>> createTipoProveedorApi({
  required String nombreTipo,
  String? descripcion,
}) async {

  final uri = Uri.parse('${Global.baseUrl}proveedor/tipo');
  final token = GetStorage().read("token");

  try {
    final response = await http.post(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({

        // ✅ OBLIGATORIO
        'nombre_tipo': nombreTipo,

        // ✅ OPCIONAL
        if (descripcion != null) 'descripcion': descripcion,
      }),
    );

    if (response.statusCode == 201) {
      final data = jsonDecode(response.body);

      print("Tipo de proveedor creado ✅");

      return data['tipo_proveedor'] as Map<String, dynamic>;
    }

    if (response.statusCode == 401) {
      controller.logOut();
      throw Exception('Sesión expirada');
    }

    if (response.statusCode == 400 || response.statusCode == 404) {
      final data = jsonDecode(response.body);
      throw Exception(data['error'] ?? 'Error al crear tipo de proveedor');
    }

    throw Exception('Error inesperado (${response.statusCode})');

  } catch (e) {
    print("ERROR CREATE TIPO PROVEEDOR: $e");
    rethrow;
  }
}

Future<void> getTipoProveedoresApi({
  required ProveedorController proveedorController
}) async {

  final uri = Uri.parse('${Global.baseUrl}proveedor/tipo');
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
      proveedorController.setTiposProveedores(data["tipos_proveedor"]);
      return;
    }

    if (response.statusCode == 401) {
      controller.logOut();
      throw Exception('Sesión expirada');
    }

    if (response.statusCode == 400 || response.statusCode == 404) {
      final data = jsonDecode(response.body);
      throw Exception(data['error'] ?? 'Error al obtener tipos de proveedor');
    }

    throw Exception('Error inesperado (${response.statusCode})');

  } catch (e) {
    print("ERROR GET TIPOS PROVEEDOR: $e");
    rethrow;
  }
}