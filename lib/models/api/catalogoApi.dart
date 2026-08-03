import 'dart:convert';

import 'package:camera/camera.dart';
import 'package:finanzas_verdes/app/config/Global.dart';
import 'package:finanzas_verdes/controllers/ProveedorController.dart';
import 'package:finanzas_verdes/main.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;

Future<bool> createItemApi({
  required String tipoItem,
  required String nombre,
  String? descripcion,
  Map<String, dynamic>? especificaciones,
  required double precioBase,
  bool disponible = true,
  required int idProveedor,
  required int createdBy,
}) async {

  try {
    final uri = Uri.parse("${Global.baseUrl}catalogo");
    final token = GetStorage().read("token");

    final response = await http.post(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        "tipo_item": tipoItem,
        "nombre": nombre,
        "descripcion": descripcion,
        "especificaciones": especificaciones,
        "precio_base": precioBase,
        "disponible": disponible,
        "id_proveedor": idProveedor,
        "created_by": createdBy,
      }),
    );

    print("CREATE ITEM STATUS: ${response.statusCode}");
    print("CREATE ITEM BODY: ${response.body}");

    if (response.statusCode == 201) {

      final data = jsonDecode(response.body);

      Get.snackbar(
        "Éxito",
        data["message"] ?? "Item creado correctamente",
        snackPosition: SnackPosition.BOTTOM,
        colorText: Colors.white,
        backgroundColor: Colors.green
      );

      return true;

    } else {

      final error = jsonDecode(response.body);

      Get.snackbar(
        "Error",
        error["error"] ?? "No se pudo crear el item",
        snackPosition: SnackPosition.BOTTOM,
        colorText: Colors.white,
        backgroundColor: Colors.red
      );

      return false;
    }

  } catch (e) {
    print("ERROR createItemApi: $e");

    Get.snackbar(
      "Error",
      "Error de conexión",
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.red,
      colorText: Colors.white,
    );

    return false;
  }
}

Future<void> getCatalogoProveedorApi({
  required ProveedorController proveedorController,
}) async {

  final uri = Uri.parse('${Global.baseUrl}catalogo');

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

      proveedorController.setCatalogo(
        List<Map<String, dynamic>>.from(data["items"]),
      );

      return;
    }

    if (response.statusCode == 401) {
      controller.logOut();
      throw Exception('Sesión expirada');
    }

    if (response.statusCode == 400 || response.statusCode == 404) {
      final data = jsonDecode(response.body);
      throw Exception(data['error'] ?? 'Error al obtener catálogo');
    }

    throw Exception('Error inesperado (${response.statusCode})');

  } catch (e) {
    print("ERROR GET CATALOGO: $e");
    rethrow;
  }
}

Future<Map> getItemById({
  required int id_item
}) async {

  final uri = Uri.parse('${Global.baseUrl}catalogo/$id_item');
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
      return data["item"];
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

Future<bool> updateItemApi({
  required int id,
  required String tipoItem,
  required String nombre,
  String? descripcion,
  Map<String, dynamic>? especificaciones,
  required double precioBase,
  bool disponible = true,
  required int idProveedor,
  required int updated_by,
}) async {

  try {
    final uri = Uri.parse("${Global.baseUrl}catalogo/$id");
    final token = GetStorage().read("token");

    final response = await http.patch(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        "tipo_item": tipoItem,
        "nombre": nombre,
        "descripcion": descripcion,
        "especificaciones": especificaciones,
        "precio_base": precioBase,
        "disponible": disponible,
        "id_proveedor": idProveedor,
        "updated_by": updated_by,
      }),
    );

    if (response.statusCode == 200) {

      final data = jsonDecode(response.body);

      Get.snackbar(
        "Éxito",
        data["message"] ?? "Item editado correctamente",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );

      return true;

    } else {

      final error = jsonDecode(response.body);

      Get.snackbar(
        "Error",
        error["error"] ?? "No se pudo editar el item",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );

      return false;
    }

  } catch (e) {
    print("ERROR editItemApi: $e");

    Get.snackbar(
      "Error",
      "Error de conexión",
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.red,
      colorText: Colors.white
    );

    return false;
  }
}

Future<void> uploadImagenItemApi({
  required int idItem,
  required int createdBy,
  required XFile image,
}) async {

  final uri = Uri.parse('${Global.baseUrl}catalogo/upload');
  final token = GetStorage().read("token");

  try {
    final request = http.MultipartRequest('POST', uri);

    request.headers['Authorization'] = 'Bearer $token';

    request.fields['id_item_catalogo'] = idItem.toString();
    request.fields['created_by'] = createdBy.toString();

    final bytes = await image.readAsBytes();

    request.files.add(
      http.MultipartFile.fromBytes(
        'image',
        bytes,
        filename: image.name,
      ),
    );

    final response = await request.send();

    if (response.statusCode == 201) {
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

Future<void> deleteImagenItem({
  required int idArchivo,
}) async {

  final uri = Uri.parse('${Global.baseUrl}catalogo/image/$idArchivo');
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