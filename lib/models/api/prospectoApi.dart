import 'dart:convert';

import 'package:finanzas_verdes/app/config/Global.dart';
import 'package:finanzas_verdes/main.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;


Map<String, dynamic> _decodeMap(
    http.Response response,
    ) {

  if (response.body.trim().isEmpty) {
    return {};
  }

  final decoded =
  jsonDecode(
    response.body,
  );

  if (decoded is Map<String, dynamic>) {
    return decoded;
  }

  return {};
}


Future<Map<String, dynamic>>
consultarClienteExternoApi({
  required String documento,
}) async {

  final uri =
  Uri.parse(
    '${Global.baseUrl}prospecto/consulta',
  );


  final token =
  GetStorage()
      .read(
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

    body: jsonEncode({
      'documento':
      documento.trim(),
    }),
  );


  if (
  response.statusCode ==
      401
  ) {

    controller.logOut();

    throw Exception(
      'Sesión expirada',
    );

  }


  final data =
  _decodeMap(
    response,
  );


  if (
  response.statusCode ==
      200
  ) {

    return data;

  }


  throw Exception(
    data['error'] ??
        'No fue posible consultar el cliente',
  );
}


Future<void>
descartarConsultaClienteApi({
  required int idConsulta,
  required String motivoCodigo,
  required String motivo,
}) async {

  final uri =
  Uri.parse(
    '${Global.baseUrl}prospecto/consulta/$idConsulta/descartar',
  );


  final token =
  GetStorage()
      .read(
    'token',
  );


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

      'motivo_codigo':
      motivoCodigo,

      'motivo':
      motivo.trim(),

    }),
  );


  if (
  response.statusCode ==
      401
  ) {

    controller.logOut();

    return;

  }


  final data =
  _decodeMap(
    response,
  );


  if (
  response.statusCode !=
      200
  ) {

    throw Exception(
      data['error'] ??
          'No fue posible descartar el cliente',
    );

  }

}


Future<Map<String, dynamic>>
agendarProspectoApi({
  required int idConsulta,
  required DateTime fechaHora,
  required String titulo,
  String? direccion,
  String? descripcion,
}) async {

  final uri =
  Uri.parse(
    '${Global.baseUrl}prospecto/consulta/$idConsulta/agendar',
  );


  final token =
  GetStorage()
      .read(
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

    body: jsonEncode({

      'fecha_hora':
      fechaHora
          .toIso8601String(),

      'titulo':
      titulo.trim(),

      'direccion':
      direccion,

      'descripcion':
      descripcion,

    }),
  );


  if (
  response.statusCode ==
      401
  ) {

    controller.logOut();

    throw Exception(
      'Sesión expirada',
    );

  }


  final data =
  _decodeMap(
    response,
  );


  if (
  response.statusCode ==
      201
  ) {

    return data;

  }


  throw Exception(
    data['error'] ??
        'No fue posible agendar el prospecto',
  );
}


Future<void>
actualizarDecisionProspectoApi({
  required int idProspecto,
  required String decision,
  required String motivo,
}) async {

  final uri =
  Uri.parse(
    '${Global.baseUrl}prospecto/$idProspecto/decision',
  );


  final token =
  GetStorage()
      .read(
    'token',
  );


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

      'decision':
      decision,

      'motivo':
      motivo.trim(),

    }),
  );


  if (
  response.statusCode ==
      401
  ) {

    controller.logOut();

    return;

  }


  final data =
  _decodeMap(
    response,
  );


  if (
  response.statusCode !=
      200
  ) {

    throw Exception(
      data['error'] ??
          'No fue posible registrar la decisión',
    );

  }

}


Future<Map<String, dynamic>>
convertirProspectoApi({
  required int idProspecto,
  required String nombreMipyme,
}) async {

  final uri =
  Uri.parse(
    '${Global.baseUrl}prospecto/$idProspecto/convertir',
  );


  final token =
  GetStorage()
      .read(
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

    body: jsonEncode({
      'nombre_mipyme':
      nombreMipyme.trim(),
    }),
  );


  if (
  response.statusCode ==
      401
  ) {

    controller.logOut();

    throw Exception(
      'Sesión expirada',
    );

  }


  final data =
  _decodeMap(
    response,
  );


  if (
  response.statusCode ==
      200 ||
      response.statusCode ==
          201
  ) {

    return data;

  }


  throw Exception(
    data['error'] ??
        'No fue posible iniciar el proceso',
  );
}