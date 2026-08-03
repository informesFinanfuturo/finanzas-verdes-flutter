import 'dart:convert';

import 'package:finanzas_verdes/app/config/Global.dart';
import 'package:finanzas_verdes/controllers/RolController.dart';
import 'package:finanzas_verdes/controllers/UserController.dart';
import 'package:finanzas_verdes/main.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;

Future<List<Map<String, dynamic>>> searchCiiuApi({
  required String query,
}) async {
  final uri = Uri.parse(
    '${Global.baseUrl}services/ciiu/search?q=${Uri.encodeQueryComponent(query)}',
  );

  final token = GetStorage().read("token");

  try {
    final response = await http.get(
      uri,
      headers: {
        "Authorization": "Bearer $token",
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return List<Map<String, dynamic>>.from(data["results"] ?? []);
    }

    if (response.statusCode == 400) {
      final data = jsonDecode(response.body);
      throw Exception(data['error'] ?? 'Error en búsqueda CIIU');
    }

    throw Exception('Error inesperado (${response.statusCode})');
  } catch (e) {
    print("ERROR SEARCH CIIU: $e");
    rethrow;
  }
}