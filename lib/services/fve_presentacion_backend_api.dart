import 'dart:convert';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:finanzas_verdes/app/config/Global.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;

/// La generacion se realiza en Node.js. Flutter solo solicita, consulta estado y descarga.
class FvePresentacionBackendApi {
  FvePresentacionBackendApi._();

  static Map<String, String> _headers() {
    final token = GetStorage().read('token')?.toString() ?? '';
    if (token.isEmpty) throw StateError('Inicia sesion para generar la presentacion.');
    return {'Authorization': 'Bearer $token'};
  }

  static Map<String, dynamic> _leer(http.Response respuesta) {
    try {
      final raw = jsonDecode(utf8.decode(respuesta.bodyBytes));
      if (raw is Map) return Map<String, dynamic>.from(raw);
    } catch (_) {}
    return <String, dynamic>{};
  }

  static Future<String> _fallo(http.Response r, String etapa) async {
    final data = _leer(r);
    final mensaje = data['error']?.toString() ?? data['mensaje']?.toString();
    if (r.statusCode == 404) {
      return 'El exportador no esta disponible en la API. Verifica que el backend nuevo este publicado.';
    }
    if (r.statusCode == 401 || r.statusCode == 403) {
      return 'No hay acceso a esta empresa o la sesion ha expirado.';
    }
    return mensaje ?? '$etapa no disponible (HTTP ${r.statusCode}).';
  }

  /// Devuelve null si el usuario cancela el cuadro de guardar el archivo.
  static Future<int?> descargar({
    required int idMipyme,
    required String nombreEmpresa,
    void Function(String etapa)? onProgreso,
  }) async {
    if (idMipyme <= 0) throw StateError('No se encontro la empresa seleccionada.');
    final headers = _headers();
    final base = Global.baseUrl;
    onProgreso?.call('Solicitando presentación al servidor...');
    final inicio = await http.post(
      Uri.parse('${base}fve/mipymes/$idMipyme/presentacion'),
      headers: headers,
    ).timeout(const Duration(seconds: 25));
    if (inicio.statusCode != 202) throw StateError(await _fallo(inicio, 'Inicio'));
    final respuesta = _leer(inicio);
    final id = respuesta['id']?.toString() ?? '';
    if (!RegExp(r'^[a-f0-9-]{36}$').hasMatch(id)) {
      throw StateError('La API no devolvio un identificador de exportacion valido.');
    }

    Map<String, dynamic> estado = respuesta;
    var listo = false;
    for (var intento = 0; intento < 150; intento++) {
      await Future<void>.delayed(const Duration(seconds: 2));
      final r = await http.get(
        Uri.parse('${base}fve/presentaciones/$id'),
        headers: headers,
      ).timeout(const Duration(seconds: 20));
      if (r.statusCode != 200) throw StateError(await _fallo(r, 'Consulta de estado'));
      estado = _leer(r);
      final actual = estado['estado']?.toString() ?? '';
      onProgreso?.call(estado['etapa']?.toString() ?? 'Preparando archivo...');
      if (actual == 'listo') { listo = true; break; }
      if (actual == 'error') throw StateError(estado['etapa']?.toString() ?? 'No se pudo generar la presentación.');
    }
    if (!listo) throw StateError('La generacion excedio el tiempo permitido. Revisa el estado del backend.');

    onProgreso?.call('Descargando PowerPoint...');
    final r = await http.get(
      Uri.parse('${base}fve/presentaciones/$id/archivo'),
      headers: headers,
    ).timeout(const Duration(minutes: 2));
    if (r.statusCode != 200) throw StateError(await _fallo(r, 'Descarga'));
    final Uint8List bytes = r.bodyBytes;
    if (bytes.length < 100 || bytes.length > 60 * 1024 * 1024 ||
        bytes[0] != 0x50 || bytes[1] != 0x4b) {
      throw StateError('El servidor devolvio un archivo PowerPoint invalido.');
    }
    final seguro = nombreEmpresa.replaceAll(RegExp(r'[^A-Za-z0-9_-]+'), '_');
    final archivo = 'FVE_${seguro.length > 45 ? seguro.substring(0, 45) : seguro}_$idMipyme.pptx';
    final path = await FilePicker.saveFile(
      dialogTitle: 'Guardar presentacion de la empresa',
      fileName: archivo,
      bytes: bytes,
      mimeType: 'application/vnd.openxmlformats-officedocument.presentationml.presentation',
    );
    if (path == null) return null;
    final paginas = estado['diapositivas'];
    return paginas is int ? paginas : int.tryParse(paginas?.toString() ?? '') ?? 0;
  }
}
