import 'dart:convert';
import 'package:finanzas_verdes/app/config/Global.dart';
import 'package:finanzas_verdes/main.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;

class FveInventarioApiException implements Exception {
  final String mensaje;
  FveInventarioApiException(this.mensaje);
  @override
  String toString() => mensaje;
}

Map<String, dynamic> _decodificar(http.Response r) {
  Map<String, dynamic> data = {};
  try {
    final decoded = jsonDecode(r.body);
    if (decoded is Map) data = Map<String, dynamic>.from(decoded);
  } catch (_) {}
  if (r.statusCode == 401) {
    controller.logOut();
    throw FveInventarioApiException('La sesión ha expirado.');
  }
  if (r.statusCode < 200 || r.statusCode >= 300) {
    throw FveInventarioApiException('${data['error'] ?? 'Error consultando inventario'} (${r.statusCode})');
  }
  return data;
}

Map<String, String> _headers() => {
  'Content-Type': 'application/json',
  'Authorization': 'Bearer ${GetStorage().read('token')}',
};

Future<List<Map<String, dynamic>>> cargarTaxonomiaFveApi() async {
  final r = await http.get(Uri.parse('${Global.baseUrl}fve/taxonomia'), headers: _headers());
  return ((_decodificar(r)['taxonomia'] as List<dynamic>?) ?? [])
      .map((e) => Map<String, dynamic>.from(e as Map)).toList();
}

Future<List<Map<String, dynamic>>> cargarInventarioFveApi(int idMipyme) async {
  final r = await http.get(
    Uri.parse('${Global.baseUrl}fve/inventario/mipyme/$idMipyme'), headers: _headers());
  return ((_decodificar(r)['activos'] as List<dynamic>?) ?? [])
      .map((e) => Map<String, dynamic>.from(e as Map)).toList();
}

Future<Map<String, dynamic>> clasificarActivoFveApi({required String tipo, required String nombre}) async {
  final uri = Uri.parse('${Global.baseUrl}fve/inventario/clasificar').replace(
    queryParameters: {'tipo': tipo, 'nombre': nombre});
  final r = await http.get(uri, headers: _headers());
  return Map<String, dynamic>.from(_decodificar(r)['ficha'] as Map);
}

Future<Map<String, dynamic>> consultarFichaActivoFveApi(int idActivo) async {
  final r = await http.get(Uri.parse('${Global.baseUrl}fve/inventario/activos/$idActivo'), headers: _headers());
  return Map<String, dynamic>.from(_decodificar(r)['ficha'] as Map);
}

Future<Map<String, dynamic>> validarReemplazoFveApi(int idActivo) async {
  final r = await http.get(Uri.parse('${Global.baseUrl}fve/inventario/activos/$idActivo/reemplazo'), headers: _headers());
  return _decodificar(r);
}

Future<Map<String, dynamic>> guardarInventarioFveApi({
  required int idActivo,
  required Map<String, dynamic> datosTecnicos,
  String observaciones = '',
  // Compatibilidad con llamadas de la primera versión; el servidor clasifica.
  String? codigoTaxonomia,
  String? tipoIntervencion,
}) async {
  final r = await http.put(
    Uri.parse('${Global.baseUrl}fve/inventario/activos/$idActivo'),
    headers: _headers(),
    body: jsonEncode({'datos_tecnicos': datosTecnicos, 'observaciones': observaciones}),
  );
  return _decodificar(r);
}
