import 'dart:convert';

import 'package:finanzas_verdes/app/config/Global.dart';
import 'package:finanzas_verdes/controllers/RolController.dart';
import 'package:finanzas_verdes/controllers/UserController.dart';
import 'package:finanzas_verdes/main.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

Future<void> createConsumoApi({
  required String tipo,
  required int idMipyme,
  required int createdBy,

  String? proveedor,
  String? periodo,
  double? valor,
  double? consumo,
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

        // ✅ OBLIGATORIOS
        'tipo': tipo,
        'id_mipyme': idMipyme,
        'created_by': createdBy,

        // ✅ OPCIONALES
        if (proveedor != null) 'proveedor': proveedor,
        if (periodo != null) 'periodo': periodo,
        if (valor != null) 'valor': valor,
        if (consumo != null) 'consumo': consumo,
        if (unidad != null) 'unidad': unidad,
        if (observaciones != null) 'observaciones': observaciones,
      }),
    );

    if (response.statusCode == 201) {
      print("Consumo creado correctamente ✅");
      return;
    }

    if (response.statusCode == 401) {
      controller.logOut();
      return;
    }

    if (response.statusCode == 400 || response.statusCode == 404) {
      final data = jsonDecode(response.body);
      throw Exception(data['error'] ?? 'Error al crear consumo');
    }

    throw Exception('Error inesperado (${response.statusCode})');

  } catch (e) {
    print("ERROR CREATE CONSUMO: $e");
    rethrow;
  }
}

Future<void> updateConsumoApi({
  required int idConsumo,
  required int updatedBy,

  String? tipo,
  String? proveedor,
  String? periodo,
  double? valor,
  double? consumo,
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

        // ✅ SOLO LO QUE CAMBIA
        if (tipo != null) 'tipo': tipo,
        if (proveedor != null) 'proveedor': proveedor,
        if (periodo != null) 'periodo': periodo,
        if (valor != null) 'valor': valor,
        if (consumo != null) 'consumo': consumo,
        if (unidad != null) 'unidad': unidad,
        if (observaciones != null) 'observaciones': observaciones,
        if (estado != null) 'estado': estado,

        // ✅ SIEMPRE
        'updated_by': updatedBy,
      }),
    );

    if (response.statusCode == 200) {
      print("Consumo actualizado correctamente ✅");
      return;
    }

    if (response.statusCode == 401) {
      controller.logOut();
      return;
    }

    if (response.statusCode == 400 || response.statusCode == 404) {
      final data = jsonDecode(response.body);
      throw Exception(data['error'] ?? 'Error al actualizar consumo');
    }

    throw Exception('Error inesperado (${response.statusCode})');

  } catch (e) {
    print("ERROR UPDATE CONSUMO: $e");
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

      // ✅ retorna MAP directo
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