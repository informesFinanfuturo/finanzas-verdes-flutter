import 'dart:convert';
import 'dart:typed_data';
import 'package:finanzas_verdes/app/config/Global.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;

class FveNegociacionException implements Exception {
  final String mensaje;
  FveNegociacionException(this.mensaje);
  @override String toString() => mensaje;
}

class FveNegociacionApi {
  static Future<Map<String, dynamic>> solicitud(
      int idProceso, String metodo, String ruta,
      [Map<String, dynamic>? datos]) async {
    final token = GetStorage().read('token');
    final uri = Uri.parse('${Global.baseUrl}fve/procesos/$idProceso/negociacion$ruta');
    final headers = {'Authorization':'Bearer $token', 'Content-Type':'application/json'};
    late http.Response r;
    try {
      if(metodo == 'POST') {
        r = await http.post(uri,headers:headers,body:jsonEncode(datos ?? {}))
            .timeout(const Duration(seconds:45));
      } else {
        r = await http.get(uri,headers:headers).timeout(const Duration(seconds:45));
      }
    } catch(e) {
      throw FveNegociacionException('No hay conexion con FVE. Verifica internet e intentalo de nuevo.');
    }
    dynamic parsed;
    try { parsed=jsonDecode(r.body); } catch(_) { parsed={}; }
    final resp=parsed is Map ? Map<String,dynamic>.from(parsed):<String,dynamic>{};
    if(r.statusCode == 401) throw FveNegociacionException('Sesion caducada. Inicia sesion de nuevo.');
    if(r.statusCode < 200 || r.statusCode >= 300) {
      throw FveNegociacionException('${resp['error'] ?? 'Error HTTP ${r.statusCode}'}');
    }
    return resp;
  }
  static Future<Uint8List> pdf(int idProceso, int idPropuesta) async {
    final token=GetStorage().read('token');
    late http.Response r;
    try {
      r=await http.get(Uri.parse('${Global.baseUrl}fve/procesos/$idProceso/negociacion/propuestas/$idPropuesta/pdf'),
        headers:{'Authorization':'Bearer $token'}).timeout(const Duration(seconds:45));
    }catch(_){throw FveNegociacionException('No se pudo descargar el PDF. Comprueba la conexion.');}
    if(r.statusCode != 200) throw FveNegociacionException('No se pudo descargar el PDF (${r.statusCode}).');
    if(r.bodyBytes.length < 8 || !utf8.decode(r.bodyBytes.take(4).toList(),allowMalformed:true).startsWith('%PDF')) {
      throw FveNegociacionException('El servidor no devolvio un documento PDF valido.');
    }
    return r.bodyBytes;
  }
}
