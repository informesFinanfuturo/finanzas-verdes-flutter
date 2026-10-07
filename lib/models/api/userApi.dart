import 'dart:convert';

import 'package:finanzas_verdes/app/config/Global.dart';
import 'package:finanzas_verdes/controllers/UserController.dart';
import 'package:finanzas_verdes/main.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;

Future<Map<String, dynamic>>
newUserApi({
  required String documento,
  required String nombreUsuario,
  required String email,
  String? telefono,
  required int idRol,
  required UserController
  userController,

  /*
   * Se conservan como opcionales para no
   * romper temporalmente el formulario
   * antiguo del superadministrador.
   * Ya no se envían al backend.
   */
  String? password,
  int? createdBy,

  // Asesor
  String? nombreCargo,
  String? sede,

  // Proveedor
  String? razonSocial,
  String? nit,
  String? direccion,
  double? calificacion,
  List<dynamic>? tiposProveedores,
}) async {
  final uri = Uri.parse(
    '${Global.baseUrl}user',
  );

  final token =
  GetStorage().read(
    'token',
  );

  try {
    final response =
    await http.post(
      uri,
      headers: {
        'Content-Type':
        'application/json',
        'Authorization':
        'Bearer $token',
      },
      body: jsonEncode({
        'documento':
        documento.trim(),
        'nombre_usuario':
        nombreUsuario.trim(),
        'email':
        email.trim(),
        'telefono':
        telefono?.trim(),
        'id_rol':
        idRol,

        if (nombreCargo != null)
          'nombre_cargo':
          nombreCargo.trim(),

        if (sede != null)
          'sede':
          sede.trim(),

        if (razonSocial != null)
          'razon_social':
          razonSocial.trim(),

        if (nit != null)
          'nit':
          nit.trim(),

        if (direccion != null)
          'direccion':
          direccion.trim(),

        if (calificacion != null)
          'calificacion':
          calificacion,

        if (tiposProveedores != null)
          'tipos_proveedor':
          tiposProveedores,
      }),
    );

    final dynamic decodedBody =
    response.body.isNotEmpty
        ? jsonDecode(
      response.body,
    )
        : <String, dynamic>{};

    final data =
    decodedBody is Map
        ? Map<String, dynamic>.from(
      decodedBody,
    )
        : <String, dynamic>{};

    if (response.statusCode == 201) {
      await getUsersApi(
        userController:
        userController,
      );

      return data;
    }

    if (response.statusCode == 401) {
      controller.logOut();

      throw Exception(
        'La sesión ha expirado',
      );
    }

    if (response.statusCode == 403) {
      throw Exception(
        data['error'] ??
            'No tienes permiso para crear usuarios',
      );
    }

    if (
    response.statusCode == 400 ||
        response.statusCode == 404 ||
        response.statusCode == 409
    ) {
      throw Exception(
        data['error'] ??
            'No fue posible crear el usuario',
      );
    }

    throw Exception(
      data['error'] ??
          'Error inesperado (${response.statusCode})',
    );
  } catch (error) {
    debugPrint(
      'ERROR AL CREAR USUARIO: $error',
    );

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
  List? tiposProveedores,

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
        if (tiposProveedores != null) 'tipos_proveedor': tiposProveedores,
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
  required UserController userController,

  String search = '',
  String estadoAcceso = 'todos',
  String estadoProceso = 'todos',
  int? idRol,
  String perfil = 'todos',
  String orden = 'recientes',
  int page = 1,
  int limit = 20,
}) async {
  final token = GetStorage().read("token");

  final queryParameters = <String, String>{
    'page': page.toString(),
    'limit': limit.toString(),
    'orden': orden,
  };

  final normalizedSearch = search.trim();

  if (normalizedSearch.isNotEmpty) {
    queryParameters['search'] = normalizedSearch;
  }

  if (estadoAcceso != 'todos') {
    queryParameters['estado_acceso'] = estadoAcceso;
  }

  if (estadoProceso != 'todos') {
    queryParameters['estado'] = estadoProceso;
  }

  if (idRol != null) {
    queryParameters['id_rol'] = idRol.toString();
  }

  if (perfil != 'todos') {
    queryParameters['perfil'] = perfil;
  }

  final uri = Uri.parse(
    '${Global.baseUrl}user',
  ).replace(
    queryParameters: queryParameters,
  );

  userController.setLoadingUsers(true);

  try {
    final response = await http.get(
      uri,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    final dynamic decodedBody =
    response.body.isNotEmpty
        ? jsonDecode(response.body)
        : <String, dynamic>{};

    final data =
    decodedBody is Map<String, dynamic>
        ? decodedBody
        : <String, dynamic>{};

    if (response.statusCode == 200) {
      final users =
      data['users'] is List
          ? data['users'] as List
          : <dynamic>[];

      userController.setUsers(users);

      userController.setSummary(
        data['summary'] is Map
            ? Map<String, dynamic>.from(
          data['summary'],
        )
            : null,
      );

      userController.setPagination(
        data['pagination'] is Map
            ? Map<String, dynamic>.from(
          data['pagination'],
        )
            : null,
      );

      userController.setFilters({
        'search': normalizedSearch,
        'estado_acceso': estadoAcceso,
        'estado': estadoProceso,
        'id_rol': idRol,
        'perfil': perfil,
        'orden': orden,
      });

      return;
    }

    if (response.statusCode == 401) {
      controller.logOut();
      return;
    }

    if (response.statusCode == 403) {
      throw Exception(
        data['error'] ??
            'No tienes permiso para consultar los usuarios',
      );
    }

    throw Exception(
      data['error'] ??
          'No fue posible obtener los usuarios '
              '(${response.statusCode})',
    );
  } catch (error) {
    debugPrint(
      'ERROR AL OBTENER LOS USUARIOS: $error',
    );

    rethrow;
  } finally {
    userController.setLoadingUsers(false);
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

Future<void> _refreshCurrentUsers({
  required UserController userController,
}) async {
  final currentFilters =
  Map<String, dynamic>.from(
    userController.Filters,
  );

  final currentPagination =
  Map<String, dynamic>.from(
    userController.Pagination,
  );

  final dynamic rawRole =
  currentFilters['id_rol'];

  final int? idRol =
  rawRole is int
      ? rawRole
      : int.tryParse(
    rawRole?.toString() ?? '',
  );

  final dynamic rawPage =
      currentPagination['page'] ??
          currentPagination['pagina_actual'];

  final dynamic rawLimit =
      currentPagination['limit'] ??
          currentPagination['limite'];

  await getUsersApi(
    userController: userController,
    search:
    currentFilters['search']
        ?.toString() ??
        '',
    estadoAcceso:
    currentFilters['estado_acceso']
        ?.toString() ??
        'todos',
    estadoProceso:
    currentFilters['estado']
        ?.toString() ??
        'todos',
    idRol: idRol,
    perfil:
    currentFilters['perfil']
        ?.toString() ??
        'todos',
    orden:
    currentFilters['orden']
        ?.toString() ??
        'recientes',
    page:
    int.tryParse(
      rawPage?.toString() ?? '',
    ) ??
        1,
    limit:
    int.tryParse(
      rawLimit?.toString() ?? '',
    ) ??
        20,
  );
}

/// Activa, inactiva, bloquea o desbloquea un usuario.
///
/// Para desbloquearlo se envía:
/// estadoAcceso: 'activo'
Future<void> changeUserAccessStatusApi({
  required int idUsuario,
  required String estadoAcceso,
  required String motivo,
  required UserController userController,
}) async {
  const allowedStatuses = {
    'activo',
    'inactivo',
    'bloqueado',
  };

  final normalizedStatus =
  estadoAcceso.trim().toLowerCase();

  final normalizedReason =
  motivo.trim();

  if (!allowedStatuses.contains(
    normalizedStatus,
  )) {
    throw Exception(
      'El estado de acceso no es válido',
    );
  }

  if (normalizedReason.length < 5) {
    throw Exception(
      'Debes indicar un motivo de al menos 5 caracteres',
    );
  }

  final uri = Uri.parse(
    '${Global.baseUrl}user/$idUsuario/status',
  );

  final token =
  GetStorage().read("token");

  try {
    final response =
    await http.patch(
      uri,
      headers: {
        'Content-Type':
        'application/json',
        'Authorization':
        'Bearer $token',
      },
      body: jsonEncode({
        'estado_acceso':
        normalizedStatus,
        'motivo':
        normalizedReason,
      }),
    );

    final dynamic decodedBody =
    response.body.isNotEmpty
        ? jsonDecode(
      response.body,
    )
        : <String, dynamic>{};

    final data =
    decodedBody is Map
        ? Map<String, dynamic>.from(
      decodedBody,
    )
        : <String, dynamic>{};

    if (response.statusCode == 200) {
      await _refreshCurrentUsers(
        userController:
        userController,
      );

      return;
    }

    if (response.statusCode == 401) {
      controller.logOut();
      return;
    }

    if (response.statusCode == 403) {
      throw Exception(
        data['error'] ??
            'No tienes permiso para cambiar el estado del usuario',
      );
    }

    if (response.statusCode == 404) {
      throw Exception(
        data['error'] ??
            'El usuario no existe',
      );
    }

    if (response.statusCode == 409) {
      throw Exception(
        data['error'] ??
            'No se puede realizar esta operación',
      );
    }

    throw Exception(
      data['error'] ??
          'No fue posible cambiar el estado del usuario '
              '(${response.statusCode})',
    );
  } catch (error) {
    debugPrint(
      'ERROR CAMBIANDO ESTADO DEL USUARIO: $error',
    );

    rethrow;
  }
}

/// Genera una contraseña temporal.
///
/// La contraseña se devuelve, pero no se almacena
/// en UserController porque solamente debe mostrarse una vez.
Future<String> resetUserPasswordApi({
  required int idUsuario,
  required String motivo,
}) async {
  final normalizedReason =
  motivo.trim();

  if (normalizedReason.length < 5) {
    throw Exception(
      'Debes indicar un motivo de al menos 5 caracteres',
    );
  }

  final uri = Uri.parse(
    '${Global.baseUrl}user/$idUsuario/reset-password',
  );

  final token =
  GetStorage().read("token");

  try {
    final response =
    await http.post(
      uri,
      headers: {
        'Content-Type':
        'application/json',
        'Authorization':
        'Bearer $token',
      },
      body: jsonEncode({
        'motivo':
        normalizedReason,
      }),
    );

    final dynamic decodedBody =
    response.body.isNotEmpty
        ? jsonDecode(
      response.body,
    )
        : <String, dynamic>{};

    final data =
    decodedBody is Map
        ? Map<String, dynamic>.from(
      decodedBody,
    )
        : <String, dynamic>{};

    if (response.statusCode == 200) {
      final temporaryPassword =
          data['temporary_password'] ??
              data['temporaryPassword'] ??
              data['password_temporal'];

      if (
      temporaryPassword == null ||
          temporaryPassword
              .toString()
              .isEmpty
      ) {
        throw Exception(
          'El servidor no devolvió la contraseña temporal',
        );
      }

      return temporaryPassword
          .toString();
    }

    if (response.statusCode == 401) {
      controller.logOut();

      throw Exception(
        'La sesión ha expirado',
      );
    }

    if (response.statusCode == 403) {
      throw Exception(
        data['error'] ??
            'No tienes permiso para restablecer contraseñas',
      );
    }

    if (response.statusCode == 404) {
      throw Exception(
        data['error'] ??
            'El usuario no existe',
      );
    }

    if (response.statusCode == 409) {
      throw Exception(
        data['error'] ??
            'No se puede restablecer la contraseña de este usuario',
      );
    }

    throw Exception(
      data['error'] ??
          'No fue posible restablecer la contraseña '
              '(${response.statusCode})',
    );
  } catch (error) {
    debugPrint(
      'ERROR RESTABLECIENDO CONTRASEÑA: $error',
    );

    rethrow;
  }
}

Future<void> getUserAuditApi({
  required int idUsuario,
  required UserController
  userController,
  int page = 1,
  int limit = 20,
  String? action,
}) async {
  final token =
  GetStorage().read(
    'token',
  );

  final queryParameters =
  <String, String>{
    'page':
    page.toString(),
    'limit':
    limit.toString(),
  };

  final normalizedAction =
      action?.trim() ?? '';

  if (
  normalizedAction.isNotEmpty
  ) {
    queryParameters['action'] =
        normalizedAction;
  }

  final uri = Uri.parse(
    '${Global.baseUrl}user/$idUsuario/audit',
  ).replace(
    queryParameters:
    queryParameters,
  );

  userController.setLoadingAudit(
    true,
  );

  try {
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

    final dynamic decodedBody =
    response.body.isNotEmpty
        ? jsonDecode(
      response.body,
    )
        : <String, dynamic>{};

    final data =
    decodedBody is Map
        ? Map<String, dynamic>.from(
      decodedBody,
    )
        : <String, dynamic>{};

    if (response.statusCode == 200) {
      final audit =
      data['audit'] is List
          ? data['audit'] as List
          : <dynamic>[];

      final pagination =
      data['pagination'] is Map
          ? Map<String, dynamic>.from(
        data['pagination'],
      )
          : <String, dynamic>{};

      userController.setUserAudit(
        audit,
      );

      userController
          .setAuditPagination(
        pagination,
      );

      return;
    }

    if (response.statusCode == 401) {
      controller.logOut();

      throw Exception(
        'La sesión ha expirado',
      );
    }

    if (response.statusCode == 403) {
      throw Exception(
        data['error'] ??
            'No tienes permiso para consultar la auditoría',
      );
    }

    if (response.statusCode == 404) {
      throw Exception(
        data['error'] ??
            'El usuario no existe',
      );
    }

    throw Exception(
      data['error'] ??
          'No fue posible consultar el historial '
              '(${response.statusCode})',
    );
  } catch (error) {
    debugPrint(
      'ERROR CONSULTANDO AUDITORÍA DEL USUARIO: $error',
    );

    rethrow;
  } finally {
    userController.setLoadingAudit(
      false,
    );
  }
}