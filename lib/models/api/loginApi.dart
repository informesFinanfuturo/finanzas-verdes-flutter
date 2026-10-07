import 'dart:convert';

import 'package:finanzas_verdes/app/config/Global.dart';
import 'package:finanzas_verdes/app/routes/routeNames.dart';
import 'package:finanzas_verdes/main.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;

Future<void> loginUserApi({
  required String email,
  required String password,
}) async {
  final uri = Uri.parse(
    '${Global.baseUrl}login/login',
  );

  try {
    final response = await http.post(
      uri,
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'email': email.trim(),
        'password': password,
      }),
    );

    final dynamic decodedBody =
    response.body.isNotEmpty
        ? jsonDecode(response.body)
        : <String, dynamic>{};

    final data =
    decodedBody is Map
        ? Map<String, dynamic>.from(
      decodedBody,
    )
        : <String, dynamic>{};

    if (response.statusCode == 200) {
      final user =
      Map<String, dynamic>.from(
        data['user'],
      );

      final mustChangePassword =
          data['must_change_password'] ==
              true;

      final box = GetStorage();

      controller.setUser(user);

      await box.write(
        'token',
        data['token'],
      );

      await box.write(
        'user',
        user,
      );

      await box.write(
        'must_change_password',
        mustChangePassword,
      );

      if (mustChangePassword) {
        Get.offAllNamed(
          Routes.changeRequiredPassword,
        );

        return;
      }

      controller.redirectToAndSave(
        user,
      );

      return;
    }

    final message =
        data['error']?.toString() ??
            'No fue posible iniciar sesión';

    Color notificationColor =
        Colors.red;

    if (response.statusCode == 423) {
      notificationColor =
          Colors.orange;
    }

    Get.snackbar(
      'Inicio de sesión',
      message,
      colorText: Colors.white,
      backgroundColor:
      notificationColor,
      snackPosition:
      SnackPosition.BOTTOM,
      margin:
      const EdgeInsets.all(16),
    );
  } catch (error) {
    debugPrint(
      'ERROR AL INICIAR SESIÓN: $error',
    );

    Get.snackbar(
      'Error de conexión',
      'No fue posible comunicarse con el servidor',
      colorText: Colors.white,
      backgroundColor: Colors.red,
      snackPosition:
      SnackPosition.BOTTOM,
      margin:
      const EdgeInsets.all(16),
    );
  }
}

Future<void> changeOwnPasswordApi({
  required String currentPassword,
  required String newPassword,
}) async {
  final uri = Uri.parse(
    '${Global.baseUrl}user/me/password',
  );

  final token =
  GetStorage().read('token');

  final response = await http.put(
    uri,
    headers: {
      'Content-Type': 'application/json',
      'Authorization':
      'Bearer $token',
    },
    body: jsonEncode({
      'current_password':
      currentPassword,
      'new_password':
      newPassword,
    }),
  );

  final dynamic decodedBody =
  response.body.isNotEmpty
      ? jsonDecode(response.body)
      : <String, dynamic>{};

  final data =
  decodedBody is Map
      ? Map<String, dynamic>.from(
    decodedBody,
  )
      : <String, dynamic>{};

  if (response.statusCode == 200) {
    return;
  }

  if (response.statusCode == 401) {
    throw Exception(
      data['error'] ??
          'La contraseña actual no es correcta',
    );
  }

  if (response.statusCode == 400) {
    throw Exception(
      data['error'] ??
          'La nueva contraseña no cumple los requisitos',
    );
  }

  if (response.statusCode == 403) {
    throw Exception(
      data['error'] ??
          'No puedes realizar esta operación',
    );
  }

  throw Exception(
    data['error'] ??
        'No fue posible cambiar la contraseña',
  );
}