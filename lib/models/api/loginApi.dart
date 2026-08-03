import 'dart:convert';

import 'package:finanzas_verdes/main.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'package:finanzas_verdes/app/config/Global.dart';


Future<void> loginUserApi({
  required String email,
  required String password,
}) async {
  final uri = Uri.parse('${Global.baseUrl}login/login');

  try {
    final response = await http.post(
      uri,
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'email': email,
        'password': password,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      controller.setUser(data["user"]);
      final box = GetStorage();
      box.write("token", data["token"]);
      controller.redirectToAndSave(data["user"]);
      return;
    }

    // ⚠️ Errores controlados del backend
    if (response.statusCode == 401 || response.statusCode == 409) {
      final data = jsonDecode(response.body);
      Get.snackbar(
        "Usuario no encontrado",
        "Credenciales inválidas",
        colorText: Colors.white,
        backgroundColor: Colors.orange
      );
    }

    // ❌ Cualquier otro error inesperado
    throw Exception('Error inesperado (${response.statusCode})');

  } catch (e) {
    print("ERROR ESPECIAL AL INICIAR SESIÓN: $e");
    rethrow;
  }
}