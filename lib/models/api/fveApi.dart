import 'dart:convert';

import 'package:finanzas_verdes/app/config/Global.dart';
import 'package:finanzas_verdes/main.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;

class FveApiException implements Exception {
  final String message;
  FveApiException(this.message);

  @override
  String toString() => message;
}

Map<String, dynamic> _decodeFveResponse(http.Response response) {
  Map<String, dynamic> data = {};
  try {
    final decoded = jsonDecode(response.body);
    if (decoded is Map) {
      data = Map<String, dynamic>.from(decoded);
    }
  } catch (_) {
    // Error response is not JSON.
  }

  if (response.statusCode == 401) {
    controller.logOut();
    throw FveApiException('Tu sesi\u00f3n ha expirado.');
  }
  if (response.statusCode < 200 || response.statusCode >= 300) {
    throw FveApiException(
      data['error']?.toString() ??
          'No se pudo completar la solicitud FVE (${response.statusCode}).',
    );
  }
  return data;
}

Future<Map<String, dynamic>> iniciarProcesoFveApi({
  required int idDiagnostico,
}) async {
  final token = GetStorage().read('token');
  final uri = Uri.parse('${Global.baseUrl}fve/procesos');
  final response = await http.post(
    uri,
    headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    },
    body: jsonEncode({'id_diagnostico': idDiagnostico}),
  );
  return _decodeFveResponse(response);
}

Future<Map<String, dynamic>> obtenerProcesoFveApi({
  required int idProceso,
}) async {
  final token = GetStorage().read('token');
  final uri = Uri.parse('${Global.baseUrl}fve/procesos/$idProceso');
  final response = await http.get(
    uri,
    headers: {'Authorization': 'Bearer $token'},
  );
  final data = _decodeFveResponse(response);
  return Map<String, dynamic>.from(data['proceso'] as Map);
}


Future<List<Map<String, dynamic>>> listarProcesosFveApi({
  required int idMipyme,
}) async {
  final token = GetStorage().read('token');

  final uri = Uri.parse(
    '${Global.baseUrl}fve/procesos/mipyme/$idMipyme',
  );

  final response = await http.get(
    uri,
    headers: {
      'Authorization': 'Bearer $token',
    },
  );

  final data = _decodeFveResponse(response);

  return (
      data['procesos'] as List<dynamic>? ?? []
  ).map(
        (e) => Map<String, dynamic>.from(e as Map),
  ).toList();
}

// Agregar al final de lib/models/api/fveApi.dart
Future<Map<String, dynamic>> obtenerSeleccionFveApi({required int idProceso}) async {
  final token = GetStorage().read('token');
  final response = await http.get(
    Uri.parse('${Global.baseUrl}fve/procesos/$idProceso/seleccion'),
    headers: {'Authorization': 'Bearer $token'},
  );
  return _decodeFveResponse(response);
}

Future<Map<String, dynamic>> guardarSeleccionFveApi({
  required int idProceso, required List<Map<String, dynamic>> lineas,
}) async {
  final token = GetStorage().read('token');
  final response = await http.put(
    Uri.parse('${Global.baseUrl}fve/procesos/$idProceso/seleccion'),
    headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'},
    body: jsonEncode({'lineas': lineas}),
  );
  return _decodeFveResponse(response);
}

Future<Map<String, dynamic>> confirmarSeleccionFveApi({
  required int idProceso, required List<Map<String, dynamic>> lineas,
}) async {
  final token = GetStorage().read('token');
  final response = await http.post(
    Uri.parse('${Global.baseUrl}fve/procesos/$idProceso/confirmar-seleccion'),
    headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'},
    body: jsonEncode({'lineas': lineas}),
  );
  return _decodeFveResponse(response);
}
// FVE_ORIGEN_API: leer el diagnostico vivo, no una copia incompleta.
Future<Map<String, dynamic>> obtenerDiagnosticoOrigenFveApi({required int idProceso}) async {
  final token = GetStorage().read('token');
  final response = await http.get(
    Uri.parse('${Global.baseUrl}fve/procesos/$idProceso/diagnostico-origen'),
    headers: {'Authorization': 'Bearer $token'},
  );
  return _decodeFveResponse(response);
}
