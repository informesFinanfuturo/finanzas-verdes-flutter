import 'dart:convert';

import 'package:finanzas_verdes/app/config/Global.dart';
import 'package:finanzas_verdes/controllers/RolController.dart';
import 'package:finanzas_verdes/controllers/UserController.dart';
import 'package:finanzas_verdes/main.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

Future<void> createActivoApi({
  required String nombre,
  required String tipo,
  required int idMipyme,
  required int createdBy,

  String? descripcion,
  Map<String, dynamic>? datos,
}) async {

  final uri = Uri.parse('${Global.baseUrl}activo');
  final token = GetStorage().read("token");

  try {
    final response = await http.post(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({

        // ✅ OBLIGATORIOS
        'nombre': nombre,
        'tipo': tipo,
        'id_mipyme': idMipyme,
        'created_by': createdBy,

        // ✅ OPCIONALES
        if (descripcion != null) 'descripcion': descripcion,
        if (datos != null) 'datos': datos,
      }),
    );

    if (response.statusCode == 201) {
      print("Activo creado correctamente");
      return;
    }

    if (response.statusCode == 401) {
      controller.logOut();
      return;
    }

    if (response.statusCode == 400 || response.statusCode == 404) {
      final data = jsonDecode(response.body);
      throw Exception(data['error'] ?? 'Error al crear activo');
    }

    throw Exception('Error inesperado (${response.statusCode})');

  } catch (e) {
    print("ERROR CREATE ACTIVO: $e");
    rethrow;
  }
}

Future<Map<String, dynamic>> getActivoApi({
  required int idActivo,
}) async {

  final uri = Uri.parse('${Global.baseUrl}activo/$idActivo');
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

      // ✅ retorna el MAP directamente
      return data['activo'] as Map<String, dynamic>;
    }

    if (response.statusCode == 401) {
      controller.logOut();
      throw Exception('Sesión expirada');
    }

    if (response.statusCode == 400 || response.statusCode == 404) {
      final data = jsonDecode(response.body);
      throw Exception(data['error'] ?? 'Error al obtener activo');
    }

    throw Exception('Error inesperado (${response.statusCode})');

  } catch (e) {
    print("ERROR GET ACTIVO: $e");
    rethrow;
  }
}

Future<void> updateActivoApi({
  required int idActivo,
  required int updatedBy,

  String? nombre,
  String? tipo,
  String? descripcion,
  Map<String, dynamic>? datos,
  String? estadoActivo,
}) async {

  final uri = Uri.parse('${Global.baseUrl}activo/$idActivo');
  final token = GetStorage().read("token");

  try {
    final response = await http.patch(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({

        // ✅ SOLO LO QUE CAMBIA
        if (nombre != null) 'nombre': nombre,
        if (tipo != null) 'tipo': tipo,
        if (descripcion != null) 'descripcion': descripcion,
        if (datos != null) 'datos': datos,
        if (estadoActivo != null) 'estado_activo': estadoActivo,

        // ✅ SIEMPRE
        'updated_by': updatedBy,
      }),
    );

    if (response.statusCode == 200) {
      print("Activo actualizado correctamente");
      return;
    }

    if (response.statusCode == 401) {
      controller.logOut();
      return;
    }

    if (response.statusCode == 400 || response.statusCode == 404) {
      final data = jsonDecode(response.body);
      throw Exception(data['error'] ?? 'Error al actualizar activo');
    }

    throw Exception('Error inesperado (${response.statusCode})');

  } catch (e) {
    print("ERROR UPDATE ACTIVO: $e");
    rethrow;
  }
}

Future<void> uploadImagenActivoApi({
  required int idActivo,
  required int createdBy,
  required XFile image,
}) async {

  final uri = Uri.parse('${Global.baseUrl}activo/upload');
  final token = GetStorage().read("token");

  try {
    final request = http.MultipartRequest('POST', uri);

    // ✅ headers
    request.headers['Authorization'] = 'Bearer $token';

    // ✅ campos
    request.fields['id_activo'] = idActivo.toString();
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

Future<void> deleteImagenActivoApi({
  required int idArchivo,
}) async {

  final uri = Uri.parse('${Global.baseUrl}activo/image/$idArchivo');
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