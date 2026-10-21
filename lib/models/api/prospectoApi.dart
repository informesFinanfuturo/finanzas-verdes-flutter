import 'dart:convert';

import 'package:finanzas_verdes/app/config/Global.dart';
import 'package:finanzas_verdes/main.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;


Map<String, dynamic> _decodeMap(http.Response response) {
  final contentType =
  (response.headers['content-type'] ?? '').toLowerCase();

  final body = response.body.trim();

  final esJson =
      contentType.contains('application/json') ||
          contentType.contains('+json');

  if (!esJson) {
    if (response.statusCode == 404) {
      throw Exception(
          'El servicio de consulta corporativa todavía '
              'no está disponible en el servidor.'
      );
    }

    throw Exception(
        'El servidor devolvió una respuesta inesperada '
            '(HTTP ${response.statusCode}).'
    );
  }

  if (body.isEmpty) {
    throw Exception(
        'El servidor devolvió una respuesta vacía.'
    );
  }

  try {
    final decoded = jsonDecode(body);

    if (decoded is Map) {
      return Map<String, dynamic>.from(decoded);
    }

    throw Exception(
        'La respuesta del servidor no tiene '
            'el formato esperado.'
    );
  } on FormatException {
    throw Exception(
        'El servidor devolvió información JSON inválida.'
    );
  }
}


Future<Map<String, dynamic>> listarProspectosManualApi({
  int page = 1,
  int limit = 10,
  String search = '',
  String estado = '',
}) async {
  final uri = Uri.parse('${Global.baseUrl}prospecto').replace(
    queryParameters: {
      'page': '$page',
      'limit': '$limit',
      if (search.isNotEmpty) 'search': search,
      if (estado.isNotEmpty) 'estado': estado,
    },
  );

  final token = GetStorage().read('token');

  final response = await http.get(
    uri,
    headers: {
      'Authorization': 'Bearer $token',
    },
  );

  if (response.statusCode == 401) {
    controller.logOut();
    throw Exception('Sesión expirada');
  }

  final data = _decodeMap(response);

  if (response.statusCode != 200) {
    throw Exception(
      data['error'] ?? 'No fue posible listar prospectos',
    );
  }

  return data;
}

Future<Map<String, dynamic>> registrarProspectoManualApi({
  required Map<String, String> datos,
}) async {
  final uri = Uri.parse(
    '${Global.baseUrl}prospecto/manual',
  );

  final token = GetStorage().read('token');

  final response = await http.post(
    uri,
    headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    },
    body: jsonEncode(datos),
  );

  if (response.statusCode == 401) {
    controller.logOut();
    throw Exception('Sesión expirada');
  }

  final data = _decodeMap(response);

  if (response.statusCode != 201) {
    throw Exception(
      data['error'] ?? 'No fue posible registrar el prospecto',
    );
  }

  return data;
}

Future<Map<String, dynamic>> consultarClienteExternoApi({
  required String documento,
}) async {
  final uri = Uri.parse('${Global.baseUrl}prospecto/consulta');

  final token = GetStorage().read('token');

  final response = await http.post(
    uri,

    headers: {
      'Content-Type': 'application/json',

      'Authorization': 'Bearer $token',
    },

    body: jsonEncode({'documento': documento.trim()}),
  );

  if (response.statusCode == 401) {
    controller.logOut();

    throw Exception('Sesión expirada');
  }

  final data = _decodeMap(response);

  if (response.statusCode == 200) {
    return data;
  }

  throw Exception(data['error'] ?? 'No fue posible consultar el cliente');
}

Future<void> descartarConsultaClienteApi({
  required int idConsulta,
  required String motivoCodigo,
  required String motivo,
}) async {
  final uri = Uri.parse(
    '${Global.baseUrl}prospecto/consulta/$idConsulta/descartar',
  );

  final token = GetStorage().read('token');

  final response = await http.patch(
    uri,

    headers: {
      'Content-Type': 'application/json',

      'Authorization': 'Bearer $token',
    },

    body: jsonEncode({'motivo_codigo': motivoCodigo, 'motivo': motivo.trim()}),
  );

  if (response.statusCode == 401) {
    controller.logOut();

    return;
  }

  final data = _decodeMap(response);

  if (response.statusCode != 200) {
    throw Exception(data['error'] ?? 'No fue posible descartar el cliente');
  }
}

Future<Map<String, dynamic>> agendarProspectoApi({
  required int idConsulta,
  required DateTime fechaHora,
  required String titulo,
  String? direccion,
  String? descripcion,
}) async {
  final uri = Uri.parse(
    '${Global.baseUrl}prospecto/consulta/$idConsulta/agendar',
  );

  final token = GetStorage().read('token');

  final response = await http.post(
    uri,

    headers: {
      'Content-Type': 'application/json',

      'Authorization': 'Bearer $token',
    },

    body: jsonEncode({
      'fecha_hora': fechaHora.toUtc().toIso8601String(),

      'titulo': titulo.trim(),

      'direccion': direccion,

      'descripcion': descripcion,
    }),
  );

  if (response.statusCode == 401) {
    controller.logOut();

    throw Exception('Sesión expirada');
  }

  final data = _decodeMap(response);

  if (response.statusCode == 201) {
    return data;
  }

  throw Exception(data['error'] ?? 'No fue posible agendar el prospecto');
}

Future<void> actualizarDecisionProspectoApi({
  required int idProspecto,
  required String decision,
  required String motivo,
}) async {
  final uri = Uri.parse('${Global.baseUrl}prospecto/$idProspecto/decision');

  final token = GetStorage().read('token');

  final response = await http.patch(
    uri,

    headers: {
      'Content-Type': 'application/json',

      'Authorization': 'Bearer $token',
    },

    body: jsonEncode({'decision': decision, 'motivo': motivo.trim()}),
  );

  if (response.statusCode == 401) {
    controller.logOut();

    return;
  }

  final data = _decodeMap(response);

  if (response.statusCode != 200) {
    throw Exception(data['error'] ?? 'No fue posible registrar la decisión');
  }
}

Future<Map<String, dynamic>> convertirProspectoApi({
  required int idProspecto,
  required String nombreMipyme,
}) async {
  final uri = Uri.parse('${Global.baseUrl}prospecto/$idProspecto/convertir');

  final token = GetStorage().read('token');

  final response = await http.post(
    uri,

    headers: {
      'Content-Type': 'application/json',

      'Authorization': 'Bearer $token',
    },

    body: jsonEncode({'nombre_mipyme': nombreMipyme.trim()}),
  );

  if (response.statusCode == 401) {
    controller.logOut();

    throw Exception('Sesión expirada');
  }

  final data = _decodeMap(response);

  if (response.statusCode == 200 || response.statusCode == 201) {
    return data;
  }

  throw Exception(data['error'] ?? 'No fue posible iniciar el proceso');
}


Future<List<Map<String, dynamic>>>
obtenerHistorialProspectoApi({
  required int idProspecto,
}) async {
  final uri = Uri.parse(
    '${Global.baseUrl}prospecto/$idProspecto/historial',
  );

  final token = GetStorage().read('token');

  final response = await http.get(
    uri,
    headers: {
      'Authorization': 'Bearer $token',
    },
  );

  if (response.statusCode == 401) {
    controller.logOut();
    throw Exception('Sesión expirada');
  }

  final data = _decodeMap(response);

  if (response.statusCode != 200) {
    throw Exception(
      data['error'] ??
          'No fue posible cargar el historial',
    );
  }

  final eventos = data['eventos'];

  if (eventos is! List) {
    throw Exception(
      'El historial recibido no es válido',
    );
  }

  return eventos
      .map(
        (e) => Map<String, dynamic>.from(e as Map),
  )
      .toList();
}