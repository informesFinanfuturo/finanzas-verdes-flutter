
import 'dart:convert';

import 'package:finanzas_verdes/app/config/Global.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;

class AmbientalApi {
  static Future<Map<String, dynamic>> _request(
      String metodo,
      String ruta, [
        Map<String, dynamic>? cuerpo,
      ]) async {
    final token = GetStorage().read('token');
    final uri = Uri.parse('${Global.baseUrl}$ruta');

    final headers = {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    };

    late http.Response r;

    if (metodo == 'POST') {
      r = await http
          .post(
        uri,
        headers: headers,
        body: jsonEncode(cuerpo),
      )
          .timeout(const Duration(seconds: 30));
    } else if (metodo == 'PATCH') {
      r = await http
          .patch(
        uri,
        headers: headers,
        body: jsonEncode(cuerpo),
      )
          .timeout(const Duration(seconds: 30));
    } else {
      r = await http
          .get(uri, headers: headers)
          .timeout(const Duration(seconds: 30));
    }

    final Map<String, dynamic> datos;

    try {
      datos = Map<String, dynamic>.from(
        jsonDecode(r.body) as Map,
      );
    } catch (_) {
      throw Exception(
        'Respuesta inesperada (HTTP ${r.statusCode})',
      );
    }

    if (
    r.statusCode < 200 ||
        r.statusCode >= 300
    ) {
      throw Exception(
        datos['error'] ??
            'Error HTTP ${r.statusCode}',
      );
    }

    return datos;
  }

  static Future<Map<String, dynamic>> formulario({
    String? codigo,
  }) =>
      _request(
        'GET',
        codigo == null
            ? 'ambiental/formulario'
            : 'ambiental/formulario/${Uri.encodeComponent(codigo)}',
      );

  static Future<Map<String, dynamic>> listar(
      int idMipyme,
      ) =>
      _request(
        'GET',
        'ambiental/mipymes/$idMipyme/evaluaciones',
      );

  static Future<Map<String, dynamic>> obtener(
      int idEvaluacion,
      ) =>
      _request(
        'GET',
        'ambiental/evaluaciones/$idEvaluacion',
      );

  static Future<Map<String, dynamic>> guardar({
    required int idMipyme,
    int? idEvaluacion,
    required Map<String, dynamic> respuestas,
    required Map<String, int> puntajes,
    required String observacion,
    required bool finalizar,
  }) {
    final cuerpo = {
      'respuestas': respuestas,
      'puntajes': puntajes,
      'observacion_general': observacion,
      'finalizar': finalizar,
    };

    return idEvaluacion == null
        ? _request(
      'POST',
      'ambiental/mipymes/$idMipyme/evaluaciones',
      cuerpo,
    )
        : _request(
      'PATCH',
      'ambiental/evaluaciones/$idEvaluacion',
      cuerpo,
    );
  }
}
