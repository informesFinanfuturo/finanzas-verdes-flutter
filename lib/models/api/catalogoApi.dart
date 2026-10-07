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

void closeLoader() {
  if (Get.isDialogOpen == true) {
    Get.back(closeOverlays: true);
  }
}

String _catalogApiErrorMessage(
    http.Response response,
    ) {
  try {
    final decoded =
    jsonDecode(
      response.body,
    );

    if (decoded is Map) {
      return decoded['error']
          ?.toString() ??
          decoded['message']
              ?.toString() ??
          'Error inesperado';
    }
  } catch (_) {
    // La respuesta no contiene JSON válido.
  }

  return 'Error inesperado '
      '(${response.statusCode})';
}

Future<void>
getCatalogoAdminApi({
  required ProveedorController
  proveedorController,

  String? buscar,
  int? idProveedor,
  String? tipoItem,
  String? estado,
  bool? disponible,
  int pagina = 1,
  int limite = 24,
}) async {
  proveedorController
      .loadingCatalogoAdmin
      .value = true;

  proveedorController
      .errorCatalogoAdmin
      .value = '';

  try {
    final queryParameters =
    <String, String>{
      'pagina':
      pagina.toString(),

      'limite':
      limite.toString(),
    };

    if (
    buscar != null &&
        buscar.trim().isNotEmpty
    ) {
      queryParameters['buscar'] =
          buscar.trim();
    }

    if (idProveedor != null) {
      queryParameters[
      'id_proveedor'] =
          idProveedor.toString();
    }

    if (
    tipoItem != null &&
        tipoItem.trim().isNotEmpty
    ) {
      queryParameters['tipo_item'] =
          tipoItem.trim();
    }

    if (
    estado != null &&
        estado.trim().isNotEmpty
    ) {
      queryParameters['estado'] =
          estado.trim();
    }

    if (disponible != null) {
      queryParameters['disponible'] =
          disponible.toString();
    }

    final uri = Uri.parse(
      '${Global.baseUrl}'
          'catalogo/admin',
    ).replace(
      queryParameters:
      queryParameters,
    );

    final token =
    GetStorage().read(
      'token',
    );

    final response =
    await http.get(
      uri,
      headers: {
        'Content-Type':
        'application/json',

        'Authorization':
        'Bearer $token',
      },
    );

    if (
    response.statusCode ==
        200
    ) {
      final data =
      jsonDecode(
        response.body,
      );

      if (data is! Map) {
        throw Exception(
          'La respuesta del catálogo '
              'no es válida',
        );
      }

      proveedorController
          .setCatalogoAdmin(
        data,
      );

      return;
    }

    if (
    response.statusCode ==
        401
    ) {
      controller.logOut();

      throw Exception(
        'Sesión expirada',
      );
    }

    throw Exception(
      _catalogApiErrorMessage(
        response,
      ),
    );
  } catch (error) {
    final message =
    error
        .toString()
        .replaceFirst(
      'Exception: ',
      '',
    );

    proveedorController
        .errorCatalogoAdmin
        .value = message;

    rethrow;
  } finally {
    proveedorController
        .loadingCatalogoAdmin
        .value = false;
  }
}

Future<int>
iniciarSincronizacionCatalogoApi({
  required ProveedorController
  proveedorController,
}) async {
  proveedorController
      .iniciandoSincronizacion
      .value = true;

  proveedorController
      .errorSincronizacion
      .value = '';

  try {
    final uri = Uri.parse(
      '${Global.baseUrl}'
          'catalogo/sync',
    );

    final token =
    GetStorage().read(
      'token',
    );

    final response =
    await http.post(
      uri,
      headers: {
        'Content-Type':
        'application/json',

        'Authorization':
        'Bearer $token',
      },
    );

    if (
    response.statusCode ==
        202
    ) {
      final data =
      jsonDecode(
        response.body,
      );

      final rawSync =
      data['sincronizacion'];

      if (rawSync is! Map) {
        throw Exception(
          'El servidor no devolvió '
              'la sincronización creada',
        );
      }

      final sync =
      Map<String, dynamic>.from(
        rawSync,
      );

      proveedorController
          .setSincronizacionActual(
        sync,
      );

      final id =
      int.tryParse(
        sync['id_sincronizacion']
            .toString(),
      );

      if (id == null) {
        throw Exception(
          'El identificador de la '
              'sincronización no es válido',
        );
      }

      return id;
    }

    /*
     * Ya hay una ejecución activa.
     */
    if (
    response.statusCode ==
        409
    ) {
      final data =
      jsonDecode(
        response.body,
      );

      final rawSync =
      data['sincronizacion'];

      if (rawSync is Map) {
        proveedorController
            .setSincronizacionActual(
          rawSync,
        );
      }

      throw Exception(
        data['error'] ??
            'Ya existe una '
                'sincronización en curso',
      );
    }

    if (
    response.statusCode ==
        401
    ) {
      controller.logOut();

      throw Exception(
        'Sesión expirada',
      );
    }

    throw Exception(
      _catalogApiErrorMessage(
        response,
      ),
    );
  } catch (error) {
    final message =
    error
        .toString()
        .replaceFirst(
      'Exception: ',
      '',
    );

    proveedorController
        .errorSincronizacion
        .value = message;

    rethrow;
  } finally {
    proveedorController
        .iniciandoSincronizacion
        .value = false;
  }
}

Future<Map<String, dynamic>>
getSincronizacionCatalogoApi({
  required int
  idSincronizacion,

  required ProveedorController
  proveedorController,
}) async {
  proveedorController
      .consultandoSincronizacion
      .value = true;

  try {
    final uri = Uri.parse(
      '${Global.baseUrl}'
          'catalogo/sync/'
          '$idSincronizacion',
    );

    final token =
    GetStorage().read(
      'token',
    );

    final response =
    await http.get(
      uri,
      headers: {
        'Content-Type':
        'application/json',

        'Authorization':
        'Bearer $token',
      },
    );

    if (
    response.statusCode ==
        200
    ) {
      final data =
      jsonDecode(
        response.body,
      );

      final rawSync =
      data['sincronizacion'];

      if (rawSync is! Map) {
        throw Exception(
          'La respuesta de la '
              'sincronización no es válida',
        );
      }

      final sync =
      Map<String, dynamic>.from(
        rawSync,
      );

      proveedorController
          .setSincronizacionActual(
        sync,
      );

      return sync;
    }

    if (
    response.statusCode ==
        401
    ) {
      controller.logOut();

      throw Exception(
        'Sesión expirada',
      );
    }

    throw Exception(
      _catalogApiErrorMessage(
        response,
      ),
    );
  } catch (error) {
    proveedorController
        .errorSincronizacion
        .value = error
        .toString()
        .replaceFirst(
      'Exception: ',
      '',
    );

    rethrow;
  } finally {
    proveedorController
        .consultandoSincronizacion
        .value = false;
  }
}

Future<void>
getHistorialSincronizacionesApi({
  required ProveedorController
  proveedorController,

  int limite = 20,
}) async {
  proveedorController
      .cargandoHistorial
      .value = true;

  try {
    final uri = Uri.parse(
      '${Global.baseUrl}'
          'catalogo/sync/history',
    ).replace(
      queryParameters: {
        'limite':
        limite.toString(),
      },
    );

    final token =
    GetStorage().read(
      'token',
    );

    final response =
    await http.get(
      uri,
      headers: {
        'Content-Type':
        'application/json',

        'Authorization':
        'Bearer $token',
      },
    );

    if (
    response.statusCode ==
        200
    ) {
      final data =
      jsonDecode(
        response.body,
      );

      proveedorController
          .setHistorialSincronizaciones(
        data[
        'sincronizaciones']
        as List? ??
            <dynamic>[],
      );

      /*
       * La primera ejecución es la más
       * reciente y se conserva como actual.
       */
      if (
      proveedorController
          .historialSincronizaciones
          .isNotEmpty
      ) {
        proveedorController
            .setSincronizacionActual(
          proveedorController
              .historialSincronizaciones
              .first,
        );
      }

      return;
    }

    if (
    response.statusCode ==
        401
    ) {
      controller.logOut();

      throw Exception(
        'Sesión expirada',
      );
    }

    throw Exception(
      _catalogApiErrorMessage(
        response,
      ),
    );
  } catch (error) {
    proveedorController
        .errorSincronizacion
        .value = error
        .toString()
        .replaceFirst(
      'Exception: ',
      '',
    );

    rethrow;
  } finally {
    proveedorController
        .cargandoHistorial
        .value = false;
  }
}

Future<void>
cargarCatalogoAdminApi({
  required ProveedorController
  proveedorController,
}) {
  return getCatalogoAdminApi(
    proveedorController: proveedorController,
    buscar: proveedorController.busquedaCatalogo.value,
    idProveedor: proveedorController.proveedorSeleccionadoId.value,
    tipoItem: proveedorController.tipoItemSeleccionado.value,
    estado: proveedorController.estadoCatalogo.value,
    disponible: proveedorController.disponibilidadSeleccionada.value,
    pagina: proveedorController.paginaCatalogo.value,
    limite: proveedorController.limiteCatalogo.value,
  );
}

Future<List<Map<String, dynamic>>> getLogsSincronizacionCatalogoApi({
  required int idSincronizacion,
  required ProveedorController proveedorController,
}) async {
  proveedorController.cargandoLogsSincronizacion.value = true;
  proveedorController.errorLogsSincronizacion.value = '';

  try {
    final uri = Uri.parse('${Global.baseUrl}catalogo/sync/$idSincronizacion/logs');
    final token = GetStorage().read('token');

    final response = await http.get(uri, headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    });

    final data = response.body.isNotEmpty
        ? jsonDecode(response.body)
        : <String, dynamic>{};

    if (response.statusCode == 200) {
      final logs = data['logs'] is List
          ? List<Map<String, dynamic>>.from(
        (data['logs'] as List).whereType<Map>().map((e) => Map<String, dynamic>.from(e)),
      )
          : <Map<String, dynamic>>[];

      proveedorController.setLogsSincronizacion(logs);
      return logs;
    }

    if (response.statusCode == 401) {
      controller.logOut();
      throw Exception('Sesión expirada');
    }

    throw Exception(
      data is Map && data['error'] != null
          ? data['error'].toString()
          : 'No fue posible consultar el registro técnico',
    );
  } catch (error) {
    proveedorController.errorLogsSincronizacion.value =
        error.toString().replaceFirst('Exception: ', '');
    rethrow;
  } finally {
    proveedorController.cargandoLogsSincronizacion.value = false;
  }
}