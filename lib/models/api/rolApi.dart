import 'dart:async';
import 'dart:convert';

import 'package:finanzas_verdes/app/config/Global.dart';
import 'package:finanzas_verdes/controllers/RolController.dart';
import 'package:finanzas_verdes/controllers/UserController.dart';
import 'package:finanzas_verdes/main.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;

Future<void> getRolsApi({
  required RolController
  rolController,
}) async {
  final uri =
  Uri.parse(
    '${Global.baseUrl}rol',
  );

  final token =
  GetStorage()
      .read(
    'token',
  );

  rolController.setLoading(
    true,
  );

  try {
    final response =
    await http.get(
      uri,
      headers: {
        'Authorization':
        'Bearer $token',
        'Content-Type':
        'application/json',
      },
    );

    final dynamic decoded =
    response.body.isNotEmpty
        ? jsonDecode(
      response.body,
    )
        : <String, dynamic>{};

    final data =
    decoded
    is Map<String, dynamic>
        ? decoded
        : <String, dynamic>{};

    if (
    response.statusCode ==
        200
    ) {
      final roles =
      data['rols']
      is List
          ? data['rols']
      as List
          : <dynamic>[];

      rolController.setRols(
        roles,
      );

      rolController.setSummary(
        data['summary']
        is Map
            ? Map<String, dynamic>.from(
          data['summary'],
        )
            : null,
      );

      return;
    }

    if (
    response.statusCode ==
        401
    ) {
      controller.logOut();

      return;
    }

    if (
    response.statusCode ==
        403
    ) {
      throw Exception(
        data['error'] ??
            'No tienes permiso para consultar los roles',
      );
    }

    throw Exception(
      data['error'] ??
          'No fue posible obtener los roles (${response.statusCode})',
    );

  } catch (error) {
    print(
      'ERROR AL OBTENER ROLES: $error',
    );

    rethrow;

  } finally {
    rolController.setLoading(
      false,
    );
  }
}

Future<Map> getRolApi({
  required int id,
  required RolController rolController,
}) async {
  final uri = Uri.parse('${Global.baseUrl}rol/$id');
  final token = GetStorage().read("token");

  try {
    final response =
    await http
        .get(
      uri,
      headers: {
        'Authorization':
        'Bearer $token',
        'Content-Type':
        'application/json',
      },
    )
        .timeout(
      const Duration(
        seconds: 30,
      ),
      onTimeout: () {
        throw TimeoutException(
          'El servidor tardó demasiado en consultar los roles',
        );
      },
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

Future<Map<String, dynamic>> replaceRolePermissionsApi({
  required int idRol,
  required Iterable<int>
  permissionIds,
  required String motivo,
  required RolController
  rolController,
}) async {
  final uri =
  Uri.parse(
    '${Global.baseUrl}rol/$idRol/permissions',
  );

  final token =
  GetStorage()
      .read(
    'token',
  );

  rolController.setSaving(
    true,
  );

  try {
    final response =
    await http.put(
      uri,
      headers: {
        'Authorization':
        'Bearer $token',
        'Content-Type':
        'application/json',
      },
      body: jsonEncode({
        'permission_ids':
        permissionIds
            .toSet()
            .toList(),

        'motivo':
        motivo.trim(),
      }),
    );

    final dynamic decoded =
    response.body.isNotEmpty
        ? jsonDecode(
      response.body,
    )
        : <String, dynamic>{};

    final data =
    decoded
    is Map<String, dynamic>
        ? decoded
        : <String, dynamic>{};

    if (
    response.statusCode ==
        200
    ) {
      await getRolsApi(
        rolController:
        rolController,
      );

      return data;
    }

    if (
    response.statusCode ==
        401
    ) {
      controller.logOut();

      throw Exception(
        'La sesión ha expirado',
      );
    }

    if (
    response.statusCode ==
        400 ||
        response.statusCode ==
            403 ||
        response.statusCode ==
            404 ||
        response.statusCode ==
            409
    ) {
      throw Exception(
        data['error'] ??
            'No fue posible actualizar los permisos',
      );
    }

    throw Exception(
      data['error'] ??
          'Error inesperado (${response.statusCode})',
    );

  } catch (error) {
    print(
      'ERROR AL GUARDAR PERMISOS DEL ROL: $error',
    );

    rethrow;

  } finally {
    rolController.setSaving(
      false,
    );
  }
}