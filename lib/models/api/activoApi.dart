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

Future<Map> createActivoApi({
  required String nombre,
  required String tipo,
  required int idMipyme,
  required String marca,
  String? modelo,
  String? descripcion,
  Map<String, dynamic>? datos,
  Map<String, dynamic>? perfilUso,
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
        'marca': marca,
        'id_mipyme': idMipyme,

        // ✅ OPCIONALES
        if (descripcion != null) 'descripcion': descripcion,
        if (datos != null || perfilUso != null) 'datos': {
          ...?datos,
          if (perfilUso != null) 'fve_perfil_uso': perfilUso,
        },
        if (modelo != null) 'modelo': modelo,
      }),
    );

    if (response.statusCode == 201) {
      print("Activo creado correctamente");
      final result = jsonDecode(response.body);
      return result["activo"];
    }

    if (response.statusCode == 401) {
      await controller.requestLogOut();
      return {};
    }

    if (response.statusCode == 403) {
      final data = jsonDecode(response.body);
      throw Exception('Acceso denegado al crear el activo: ${data['error'] ?? 'No autorizado'}. Revisa la relacion entre asesor y empresa.');
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

    if (response.statusCode == 403) {
      final data = jsonDecode(response.body);
      throw Exception('Acceso denegado al consultar el activo: ${data['error'] ?? 'No autorizado'}. Comprueba el permiso Obtener activo.');
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
  String? modelo,
  String? marca,
  int? cantidad,
  Map<String, dynamic>? datos,
  Map<String, dynamic>? perfilUso,
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

        'nombre': nombre,
        'tipo': tipo,
        'descripcion': descripcion,
        'datos': datos,
        if (perfilUso != null) 'perfil_uso': perfilUso,
        if(estadoActivo != null) 'estado_activo': estadoActivo,
        'modelo': modelo,
        'marca': marca,
        'cantidad': cantidad,

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

    if (response.statusCode == 403) {
      final data = jsonDecode(response.body);
      throw Exception('Acceso denegado al editar el activo: ${data['error'] ?? 'No autorizado'}. Comprueba el permiso Editar activo.');
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
    if (response.statusCode == 403) {
      String mensaje = 'Acceso denegado al subir imagen';
      try {
        final cuerpo = jsonDecode(respStr);
        if (cuerpo is Map && cuerpo['error'] != null) {
          mensaje = cuerpo['error'].toString();
        }
      } catch (_) {}
      throw Exception('$mensaje (403)');
    }

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

Future<void> analizarActivoApi({
  required int idActivo,
}) async {
  final uri = Uri.parse('${Global.baseUrl}activo/analizar/$idActivo');
  final token = GetStorage().read('token');
  showLoadingDialog();
  try {
    final response = await http.post(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
    Map<String, dynamic> data = {};
    if (response.body.isNotEmpty) {
      try {
        final decoded = jsonDecode(response.body);
        if (decoded is Map) {
          data = Map<String, dynamic>.from(decoded);
        }
      } catch (_) {
        // Respuesta sin JSON: se mostrara el codigo HTTP.
      }
    }
    if (response.statusCode == 200) {
      final faltantes = data['imagenes_no_disponibles'];
      if (faltantes is num && faltantes > 0) {
        Get.snackbar(
          'Evidencias incompletas',
          'El analisis omitio $faltantes imagenes ausentes del servidor.',
          backgroundColor: Colors.orange,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
        );
      }
      return;
    }
    if (response.statusCode == 401) {
      controller.logOut();
      throw Exception('Tu sesion vencio. Vuelve a iniciar sesion.');
    }
    final errorIA = data['ai_error'];
    final mensajeIA = errorIA is Map ? errorIA['message_user']?.toString() : null;
    final mensaje = mensajeIA ?? data['error']?.toString() ?? 'Error HTTP ${response.statusCode}';
    throw Exception(mensaje);
  } finally {
    hideLoadingDialog();
  }
}
Future<void> deleteActivoApi({
  required int idActivo,
}) async {

  final uri = Uri.parse('${Global.baseUrl}activo/$idActivo');
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
      print("Activo eliminado correctamente");
      return;
    }

    if (response.statusCode == 401) {
      controller.logOut();
      return;
    }

    if (response.statusCode == 400 || response.statusCode == 404) {
      final data = jsonDecode(response.body);
      throw Exception(data['error'] ?? 'Error al eliminar activo');
    }

    throw Exception('Error inesperado (${response.statusCode})');

  } catch (e) {
    print("ERROR ELIMINAR ACTIVO : $e");
    rethrow;
  }
}

void showLoadingDialog() {
  Get.dialog(
    PopScope(
      canPop: false,
      child: Dialog(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: const [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text(
                "Generando análisis con IA",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8),
              Text(
                "Estamos analizando imágenes y extrayendo datos.",
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    ),
    barrierDismissible: false,
  );
}

void hideLoadingDialog() {
  if (Get.isDialogOpen ?? false) {
    Get.close(1);
  }
}


// Informacion de referencia separada del inventario tecnico certificado.
Future<Map<String, dynamic>> obtenerEstadoEstimacionesIA(int idActivo) async {
  final token = GetStorage().read('token');
  final r = await http.get(Uri.parse('${Global.baseUrl}activo/$idActivo/estimaciones'),
    headers: {'Authorization':'Bearer $token'}).timeout(const Duration(seconds: 25));
  final json = jsonDecode(r.body);
  if (r.statusCode != 200 || json is! Map) {
    throw Exception(json is Map ? json['error'] ?? 'No se pudo consultar el estado' : 'HTTP ${r.statusCode}');
  }
  return Map<String, dynamic>.from(json);
}
Future<Map<String, dynamic>> investigarReferenciasActivoIA(int idActivo) async {
  final token = GetStorage().read('token');
  final r = await http.post(Uri.parse('${Global.baseUrl}activo/$idActivo/estimaciones/investigar'),
    headers: {'Authorization':'Bearer $token'}).timeout(const Duration(seconds: 150));
  final json = jsonDecode(r.body);
  if (r.statusCode != 200 || json is! Map) {
    throw Exception(json is Map ? json['error'] ?? 'No se pudo buscar' : 'HTTP ${r.statusCode}');
  }
  return Map<String, dynamic>.from(json);
}
