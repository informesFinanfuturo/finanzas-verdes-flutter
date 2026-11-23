import 'dart:convert';
import 'dart:math' as math;
import 'dart:typed_data';

import 'package:archive/archive.dart';
import 'package:finanzas_verdes/app/config/Global.dart';
import 'package:finanzas_verdes/models/api/activoApi.dart';
import 'package:finanzas_verdes/models/api/ambientalApi.dart';
import 'package:finanzas_verdes/models/api/clientApi.dart';
import 'package:finanzas_verdes/models/api/consumoApi.dart';
import 'package:finanzas_verdes/models/api/fveInventarioApi.dart';
import 'package:flutter/services.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'package:image/image.dart' as img;

/// Exportador local de PowerPoint. Solo consulta APIs existentes (GET).
/// Conserva el diseño OOXML de la plantilla original del proyecto.
class FvePresentacionEmpresaService {
  FvePresentacionEmpresaService._();

  static const _assetPlantilla = 'assets/fve/plantilla_empresa_fve.pptx';
  static const _pptxMime =
      'application/vnd.openxmlformats-officedocument.presentationml.presentation';

  static Future<FvePresentacionExportada> generar({
    required int idUsuario,
    required int idMipyme,
    String? asesor,
  }) async {
    // Consultar datos actuales, no una fotografia antigua del estado de pantalla.
    final cliente = Map<String, dynamic>.from(
      await getClientDetailApi(idUsuario: idUsuario),
    );
    final mipyme = _map(cliente['mipyme']);
    if (_entero(mipyme['id_mipyme']) != idMipyme || idMipyme <= 0) {
      throw StateError('La empresa seleccionada no coincide con la consulta.');
    }

    final advertencias = <String>[];
    final activosLista = _listaMap(cliente['activos'])
        .where((e) => _entero(e['id_activo']) != null)
        .toList();
    final facturasLista = _listaMap(cliente['facturas'])
        .where((e) => _entero(e['id_consumo']) != null)
        .toList();

    final activos = await _cargarEnLotes(activosLista, 'id_activo', (id) async {
      final r = await getActivoApi(idActivo: id);
      if (_entero(r['id_mipyme']) != idMipyme) {
        throw StateError('Activo asociado a otra empresa.');
      }
      return r;
    }, advertencias);

    final facturas = await _cargarEnLotes(facturasLista, 'id_consumo', (id) async {
      // El endpoint de consumo no expone id_mipyme; solo consultamos IDs
      // recibidos en el detalle de cliente autorizado.
      return await getConsumoApi(idConsumo: id);
    }, advertencias);

    // Fichas técnicas confirmadas en el módulo FVE; complementan el registro
    // del activo sin convertir sugerencias de IA en datos medidos.
    final fichasTecnicas = <int, Map<String,dynamic>>{};
    try {
      final inventarioFve = await cargarInventarioFveApi(idMipyme);
      for (final f in inventarioFve) {
        final id = _entero(f['id_activo']);
        if (id != null) {
          fichasTecnicas[id] = _map(_map(f['caracterizacion'])['datos_tecnicos']);
        }
      }
    } catch (_) {
      advertencias.add('No se recuperaron las fichas técnicas del módulo FVE.');
    }

    Map<String, dynamic> evaluacion = {};
    final preguntas = <int, String>{};
    try {
      final listado = await AmbientalApi.listar(idMipyme);
      final registros = _listaMap(listado['evaluaciones']);
      registros.sort((a, b) => (_entero(b['id_evaluacion']) ?? 0)
          .compareTo(_entero(a['id_evaluacion']) ?? 0));
      if (registros.isNotEmpty) {
        final completados = registros.where((e) {
          final estado = _texto(e['estado']).toLowerCase();
          return estado.contains('finaliz') || estado.contains('complet');
        }).toList();
        final elegido = completados.isNotEmpty ? completados.first : registros.first;
        final id = _entero(elegido['id_evaluacion']);
        if (id != null) {
          final respuesta = await AmbientalApi.obtener(id);
          evaluacion = _map(respuesta['evaluacion']);
        }
        if (evaluacion.isEmpty) evaluacion = elegido;
        final codigo = _texto(evaluacion['version_formulario']);
        if (codigo != 'N/D') {
          try {
            final f = await AmbientalApi.formulario(codigo: codigo);
            for (final p in _listaMap(_map(f['formulario'])['preguntas'])) {
              final n = _entero(p['numero']);
              if (n != null) preguntas[n] = _texto(p['texto']);
            }
          } catch (_) {
            advertencias.add('No se recuperó el texto oficial del cuestionario.');
          }
        }
      }
    } catch (_) {
      advertencias.add('No se pudo consultar la evaluación ambiental.');
    }

    final diagnosticos = _listaMap(cliente['diagnosticos']);
    final nombre = _texto(mipyme['nombre_mipyme']);
    final slides = <_PaginaExportacion>[];
    final visitas = _listaMap(cliente['visitas']);
    final fecha = _fecha(evaluacion['fecha_visita'] ??
        (visitas.isEmpty ? null : visitas.first['fecha_hora']));
    final usuario = _map(cliente['user']);
    final horario = _map(mipyme['horario_operacion']);
    final dias = _map(horario['dias']);
    final diasNombre = {
      'lunes': 'Lun', 'martes': 'Mar', 'miercoles': 'Mié',
      'jueves': 'Jue', 'viernes': 'Vie', 'sabado': 'Sáb', 'domingo': 'Dom',
    };
    final horarios = <String>[];
    for (final entrada in diasNombre.entries) {
      final rango = _map(dias[entrada.key]);
      if (rango.isNotEmpty) {
        horarios.add('${entrada.value} ${_texto(rango['inicio'])}-${_texto(rango['fin'])}');
      }
    }
    slides.add(_PaginaExportacion(0, {
      'HEADER': '$nombre · FICHA DE REGISTRO Y VISITA',
      'M_NOMBRE': nombre,
      'M_RAZON': _texto(mipyme['razon_social']),
      'M_NIT': _texto(mipyme['nit']),
      'M_TIPO': _texto(mipyme['tipo_empresa']),
      'M_CIIU': _texto(mipyme['codigo_ciiu'] ?? mipyme['sector_economico']),
      'M_DEPARTAMENTO': _texto(mipyme['departamento']),
      'M_MUNICIPIO': _texto(mipyme['municipio']),
      'M_DIRECCION': _texto(mipyme['direccion']),
      'M_FECHA': fecha,
      'M_ASESOR': _texto(asesor),
      'M_ID': '${_texto(usuario['id_usuario'])} / ${_texto(mipyme['id_mipyme'])}',
      'M_CONTACTO': _texto(usuario['nombre_usuario']),
      'M_TELEFONO': '${_texto(usuario['telefono'])} / ${_texto(usuario['email'])}',
      'M_HORARIO': horarios.isEmpty ? 'N/D' : horarios.first,
      'M_DIAS': dias.isEmpty ? 'N/D' : diasNombre.entries
          .where((e) => dias.containsKey(e.key)).map((e) => e.value).join(', '),
      'M_FACTURA': _texto(mipyme['tipo_factura']),
      'M_OBS': _texto(mipyme['descripcion_empresa']),
    }));
    final datosAdicionales = [
      'Barrio: ${_texto(mipyme['barrio'])}',
      'Sector económico: ${_texto(mipyme['sector_economico'])}',
      'Tipo de persona: ${_texto(mipyme['tipo_persona'])}',
      'Estrato declarado: ${_texto(mipyme['estrato'])}',
      'Empleados: ${_texto(mipyme['cantidad_empleados'])}',
      'Ingresos registrados: ${_texto(mipyme['ingresos'])}',
      'Egresos registrados: ${_texto(mipyme['egresos'])}',
      'Descripción empresarial: ${_texto(mipyme['descripcion_empresa'])}',
      'Horario completo: ${horarios.isEmpty ? 'N/D' : horarios.join('; ')}',
    ].join(' | ');
    _agregarRespaldos(slides,fecha: fecha,
      identificador: _texto(mipyme['id_mipyme']),
      titulo: 'Información empresarial complementaria',
      detalle: datosAdicionales,
      fuentes: 'Datos guardados en el registro empresarial.',
      limitaciones: 'N/D indica que el dato no fue suministrado por la API.',
    );

    final energia = <Map<String, dynamic>>[];
    final agua = <Map<String, dynamic>>[];
    final otras = <Map<String, dynamic>>[];
    for (final f in facturas) {
      final tipo = _normalizar(_texto(f['tipo']));
      if (tipo.contains('energ') || tipo.contains('electr')) {
        energia.add(f);
      } else if (tipo.contains('agua') || tipo.contains('acueduc')) {
        agua.add(f);
      } else {
        otras.add(f);
      }
    }
    energia.sort(_fechaDesc);agua.sort(_fechaDesc);otras.sort(_fechaDesc);
    final pares = <List<Map<String, dynamic>?>>[];
    for (var i = 0; i < math.max(energia.length, agua.length); i++) {
      pares.add([i < energia.length ? energia[i] : null,
        i < agua.length ? agua[i] : null]);
    }
    for (var i = 0; i < otras.length; i += 2) {
      pares.add([otras[i], i + 1 < otras.length ? otras[i + 1] : null]);
    }
    if (pares.isEmpty) pares.add([null, null]);
    for (var i = 0; i < pares.length; i++) {
      final evidenciasIzquierda = _listaMap(pares[i][0]?['imagenes']);
      final evidenciasDerecha = _listaMap(pares[i][1]?['imagenes']);
      final fotosPaginas = math.max(1,
          math.max(evidenciasIzquierda.length, evidenciasDerecha.length));
      final valores = <String, String>{};
      _camposFactura(valores, 'B_E', pares[i][0]);
      _camposFactura(valores, 'B_W', pares[i][1]);
      for (var paginaFoto = 0; paginaFoto < fotosPaginas; paginaFoto++) {
        final fotos = <Uint8List?>[
          paginaFoto < evidenciasIzquierda.length
              ? await _descargarImagen(evidenciasIzquierda[paginaFoto], advertencias)
              : null,
          paginaFoto < evidenciasDerecha.length
              ? await _descargarImagen(evidenciasDerecha[paginaFoto], advertencias)
              : null,
        ];
        slides.add(_PaginaExportacion(1, valores,
          fotos: fotos,
          titulo: 'Facturas registradas (${i + 1}/${pares.length})'
              '${fotosPaginas > 1 ? ' · foto ${paginaFoto + 1}/$fotosPaginas' : ''}'));
      }
    }

    for (final factura in facturas) {
      final textoFactura = _unir([
        factura['observaciones'], factura['observacion_ia'],
      ]);
      if (textoFactura != 'N/D') {
        _agregarRespaldos(slides,
          fecha: _fecha(factura['periodo_fin']),
          identificador: _texto(factura['id_consumo']),
          titulo: 'Observaciones de factura ${_texto(factura['id_consumo'])}',
          detalle: textoFactura,
          fuentes: 'Factura registrada en la app y sus observaciones.',
          limitaciones: 'Los valores de IA no equivalen a lecturas verificadas.',
        );
      }
    }

    activos.sort((a, b) => (_entero(a['id_activo']) ?? 0)
        .compareTo(_entero(b['id_activo']) ?? 0));
    final paginasInventario = math.max(1, (activos.length / 8).ceil());
    for (var pag = 0; pag < paginasInventario; pag++) {
      final valores = <String, String>{};
      for (var fila = 0; fila < 8; fila++) {
        final ix = pag * 8 + fila;
        if (ix >= activos.length) continue;
        final a = activos[ix];
        final datos = {..._map(a['datos']), ...?fichasTecnicas[_entero(a['id_activo'])]};
        valores.addAll({
          'A${fila + 1}_ID': _texto(a['id_activo']),
          'A${fila + 1}_NOMBRE': '${_texto(a['nombre'])} / ${_texto(a['tipo'])}',
          'A${fila + 1}_MARCA': '${_texto(a['marca'])} ${_texto(a['modelo'])}',
          'A${fila + 1}_ANO': _datoTecnico(datos, ['anio_equipo','anio','año','capacidad']),
          'A${fila + 1}_USO': _modoUso(datos),
          'A${fila + 1}_FOTOS': '${_listaMap(a['imagenes']).length}',
          'A${fila + 1}_IA': _texto(a['observacion_ia']) == 'N/D'
              ? 'Pendiente / N/D' : 'Con análisis',
        });
      }
      slides.add(_PaginaExportacion(2, valores,
        titulo: 'Inventario de activos (${pag + 1}/$paginasInventario)'));
    }

    for (final a in activos) {
      final fotoInfo = _listaMap(a['imagenes']);
      final datos = {..._map(a['datos']), ...?fichasTecnicas[_entero(a['id_activo'])]};
      final fotos = <Uint8List?>[];
      // La descarga es de solo lectura y no modifica el activo.
      for (final info in fotoInfo) {
        fotos.add(await _descargarImagen(info, advertencias));
      }
      final paginasFotos = math.max(1, (fotos.length / 2).ceil());
      for (var i = 0; i < paginasFotos; i++) {
        final v = <String, String>{
          'ACT_ID': _texto(a['id_activo']),
          'ACT_NOMBRE': '${_texto(a['nombre'])} / ${_texto(a['tipo'])}',
          'ACT_MARCA': '${_texto(a['marca'])} ${_texto(a['modelo'])}',
          'ACT_ANO': _datoTecnico(datos, ['anio_equipo','anio','año']),
          'ACT_CAPACIDAD': _datoTecnico(datos, ['capacidad','capacidad_actual','potencia']),
          'ACT_CONSUMO': _datoTecnico(datos, ['consumo_actual','consumo','consumo_kwh_mes']),
          'ACT_USO': _modoUso(datos),
          'ACT_FOTOS': '${fotoInfo.length} asociadas; '
              '${fotos.where((e) => e != null).length} incrustadas',
          'ACT_MEDICION': _mediciones(datos),
          'ACT_IA': _texto(a['observacion_ia']) == 'N/D'
              ? 'Sin resultado de IA disponible' : 'Análisis disponible (ver respaldo)',
        };
        slides.add(_PaginaExportacion(3, v,
          titulo: 'Activo ${_texto(a['id_activo'])}: ${_texto(a['nombre'])}'
              '${paginasFotos > 1 ? ' (${i + 1}/$paginasFotos)' : ''}',
          fotos: [i * 2 < fotos.length ? fotos[i * 2] : null,
            i * 2 + 1 < fotos.length ? fotos[i * 2 + 1] : null]));
      }
    }

    final respuestas = _map(evaluacion['respuestas']);
    final puntajes = _map(evaluacion['puntajes']);
    for (final desde in [1, 9]) {
      final v = <String, String>{};
      for (var n = desde; n < desde + 8; n++) {
        final r = _map(respuestas['$n']);
        v['Q${n}_TEXTO'] = preguntas[n] ?? 'Pregunta $n (texto no disponible)';
        v['Q${n}_RESP'] = _texto(r['valor']);
        v['Q${n}_OBS'] = _texto(r['observacion']);
      }
      if (desde == 9) {
        for (final n in [1, 3, 4, 5]) {
          v['S$n'] = _texto(puntajes['$n']);
        }
        v['AD07'] = _texto(evaluacion['indice_ad07']);
      }
      slides.add(_PaginaExportacion(desde == 1 ? 4 : 5, v,
        titulo: 'Evaluación ambiental (${desde == 1 ? '1/2' : '2/2'})'));
    }

    for (var n = 1; n <= 16; n++) {
      final pregunta = preguntas[n] ?? 'Pregunta $n (texto no disponible)';
      final respuesta = _map(respuestas['$n']);
      final observacion = _texto(respuesta['observacion']);
      if (pregunta.length > 90 || observacion.length > 70 ||
          _texto(respuesta['valor']).length > 52) {
        _agregarRespaldos(slides,
          fecha: _fecha(evaluacion['fecha_visita']),
          identificador: '$n',
          titulo: 'Detalle de pregunta ambiental $n',
          detalle: 'Pregunta: $pregunta | Respuesta: ${_texto(respuesta['valor'])} '
              '| Observación: $observacion',
          fuentes: 'Cuestionario ambiental guardado en la aplicación.',
          limitaciones: 'No se han agregado respuestas no registradas.',
        );
      }
    }

    if (diagnosticos.isEmpty) {
      slides.add(_PaginaExportacion(6, {
        'D_PROB': 'No hay diagnóstico de IA guardado en la empresa.',
        'D_BEN': 'N/D', 'D_CONS': _consumosResumen(facturas),
        'D_ALT': 'N/D',
      }, titulo: 'Diagnóstico IA · sin datos'));
    }
    for (var j = 0; j < diagnosticos.length; j++) {
      final diag = diagnosticos[j];
      final problema = _map(diag['problema']);
      final beneficios = _map(diag['beneficios']);
      final m = _map(diag['metricas']);
      final textos = {
        'D_PROB': _unir([problema['resumen'], problema['detalle']]),
        'D_BEN': _unir([beneficios['resumen'], beneficios['detalle']]),
        'D_CONS': _consumosResumen(facturas),
        'D_ALT': _alternativas(m),
      };
      final bloques = <String, List<String>>{};
      var maxPaginas = 1;
      for (final entrada in textos.entries) {
        bloques[entrada.key] = _fragmentar(entrada.value, 330);
        maxPaginas = math.max(maxPaginas, bloques[entrada.key]!.length);
      }
      for (var k = 0; k < maxPaginas; k++) {
        slides.add(_PaginaExportacion(6, {
          for (final key in textos.keys)
            key: k < bloques[key]!.length ? bloques[key]![k] : ' ',
        }, titulo: 'Diagnóstico IA ${j + 1}/${diagnosticos.length}'
            '${maxPaginas > 1 ? ' · ${k + 1}/$maxPaginas' : ''}'));
      }
      _agregarRespaldos(slides,
        fecha: _fecha(diag['created_at']),
        identificador: _texto(diag['id_diagnostico']),
        titulo: 'Diagnóstico ${j + 1}: respaldo IA',
        detalle: _unir([problema['detalle'],beneficios['detalle']]),
        fuentes: _texto(diag['evidencia_catalogo']),
        limitaciones: 'Resultados de IA sujetos a revisión y verificación.',
      );
    }

    // Detalle completo de campos técnicos y observaciones de IA por activo.
    for (final a in activos) {
      final obs = _texto(a['observacion_ia']);
      final tech = fichasTecnicas[_entero(a['id_activo'])] ?? {};
      final datos = _map(a['datos']);
      final detalle = _unir([
        tech.isEmpty ? null : 'Ficha FVE confirmada: ${_texto(tech)}',
        datos.isEmpty ? null : 'Otros datos registrados: ${_texto(datos)}',
        obs == 'N/D' ? null : 'Observación IA: $obs',
      ]);
      if (detalle == 'N/D') continue;
      _agregarRespaldos(slides,
        fecha: _fecha(a['updated_at'] ?? a['created_at']),
        identificador: _texto(a['id_activo']),
        titulo: 'Ficha y análisis del activo ${_texto(a['id_activo'])}',
        detalle: detalle,
        fuentes: 'Datos guardados en la ficha del activo y resultados IA.',
        limitaciones: 'La identificación por IA no sustituye una ficha técnica validada.',
      );
    }

    final template = await rootBundle.load(_assetPlantilla);
    final bytes = _componer(template.buffer.asUint8List(
      template.offsetInBytes, template.lengthInBytes), slides);
    return FvePresentacionExportada(
      bytes: bytes,
      nombreArchivo: 'FVE_${_seguroNombre(nombre)}_${idMipyme}.pptx',
      mimeType: _pptxMime,
      paginas: slides.length,
      advertencias: advertencias.toSet().toList(),
    );
  }

  static Future<List<Map<String, dynamic>>> _cargarEnLotes(
      List<Map<String, dynamic>> registros,
      String clave,
      Future<Map<String, dynamic>> Function(int) obtener,
      List<String> advertencias) async {
    final result = <Map<String, dynamic>>[];
    for (var i = 0; i < registros.length; i += 5) {
      final lote = registros.skip(i).take(5).toList();
      final futures = lote.map((e) async {
        final id = _entero(e[clave]);
        if (id == null) return e;
        try {
          return await obtener(id);
        } catch (_) {
          advertencias.add('No se consultó el detalle de ${clave == 'id_activo' ? 'activo' : 'factura'} $id; se utiliza el resumen.');
          return e;
        }
      });
      result.addAll(await Future.wait(futures));
    }
    return result;
  }

  // FVE_PPTX_FOTO_V1_1: recorte centrado compatible con image 4.10.2.
  static img.Image _ajustarFotografia(img.Image original) {
    const anchoDestino = 840;
    const altoDestino = 520;

    final esMasAncha =
        original.width * altoDestino > original.height * anchoDestino;
    final anchoRecorte = esMasAncha
        ? math.max(1, (original.height * anchoDestino / altoDestino).floor())
        : original.width;
    final altoRecorte = esMasAncha
        ? original.height
        : math.max(1, (original.width * altoDestino / anchoDestino).floor());

    final recortada = img.copyCrop(
      original,
      x: (original.width - anchoRecorte) ~/ 2,
      y: (original.height - altoRecorte) ~/ 2,
      width: anchoRecorte,
      height: altoRecorte,
    );
    return img.copyResize(
      recortada,
      width: anchoDestino,
      height: altoDestino,
      interpolation: img.Interpolation.linear,
    );
  }

  static Future<Uint8List?> _descargarImagen(Map<String, dynamic> info,
      List<String> advertencias) async {
    final ubicacion = _texto(info['ubicacion']);
    if (ubicacion == 'N/D') return null;
    final nombre = ubicacion.replaceAll('\\', '/').split('/').last;
    if (nombre.isEmpty || nombre == '.' || nombre == '..' ||
        !RegExp(r'^[A-Za-z0-9_.-]+$').hasMatch(nombre)) return null;
    final token = GetStorage().read('token');
    final base = Uri.parse(Global.baseUrl);
    final u1 = base.resolve('uploads/${Uri.encodeComponent(nombre)}');
    final u2 = base.replace(path: '/uploads/${Uri.encodeComponent(nombre)}');
    for (final uri in [u1, u2]) {
      try {
        final r = await http.get(uri, headers: {
          'Authorization': 'Bearer $token',
        }).timeout(const Duration(seconds: 12));
        if (r.statusCode != 200 || r.bodyBytes.length > 8 * 1024 * 1024) {
          continue;
        }
        final contentType = (r.headers['content-type'] ?? '').toLowerCase();
        if (!contentType.startsWith('image/') &&
            !RegExp(r'\.(png|jpg|jpeg|webp)$',caseSensitive: false).hasMatch(nombre)) {
          continue;
        }
        final original = img.decodeImage(r.bodyBytes);
        if (original == null) continue;
        // Formato único PNG: compatible con las relaciones de la plantilla.
        return Uint8List.fromList(img.encodePng(
          _ajustarFotografia(original),
        ));
      } catch (_) {
        // La evidencia puede estar en otra instalación o protegida por una ruta distinta.
      }
    }
    advertencias.add('Fotografía $nombre no disponible para incrustar.');
    return null;
  }

  static void _camposFactura(Map<String, String> values, String prefix,
      Map<String, dynamic>? factura) {
    values['${prefix}_TIPO'] = factura == null
        ? 'Sin factura registrada' : 'Factura de ${_texto(factura['tipo'])}';
    values['${prefix}_PROV'] = _texto(factura?['proveedor']);
    values['${prefix}_NUM'] = _texto(factura?['numero_factura']);
    values['${prefix}_PER'] = '${_fecha(factura?['periodo_inicio'])} a ${_fecha(factura?['periodo_fin'])}';
    values['${prefix}_FECHA'] = _fecha(factura?['fecha_factura']);
    values['${prefix}_CONS'] = factura?['consumo'] == null ? 'N/D'
      : '${_texto(factura?['consumo'])} ${_texto(factura?['unidad'])}';
    values['${prefix}_VALOR'] = factura?['valor'] == null ? 'N/D' : '\$ ${_texto(factura?['valor'])}';
    values['${prefix}_TARIFA'] = _texto(factura?['costo_unitario']);
  }

  static String _consumosResumen(List<Map<String, dynamic>> f) {
    if (f.isEmpty) return 'No hay facturas registradas.';
    return f.take(10).map((e) => '${_texto(e['tipo'])}: '
      '${_texto(e['consumo'])} ${_texto(e['unidad'])}; '
      'valor \$${_texto(e['valor'])}; período ${_fecha(e['periodo_fin'])} (factura)').join(' | ');
  }

  static String _alternativas(Map<String, dynamic> metricas) {
    final entradas = _listaMap(metricas['alternativas_seleccionadas']);
    if (entradas.isEmpty) return 'No hay alternativas seleccionadas o documentadas.';
    return entradas.map((e) => [e['nombre'],e['producto'],e['id_item'],e['id_activo']]
      .where((v) => v != null && v.toString().trim().isNotEmpty)
      .map((v) => v.toString()).join(' · ')).join(' | ');
  }

  static void _agregarRespaldos(List<_PaginaExportacion> slides, {
    required String fecha, required String identificador,required String titulo,
    required String detalle,required String fuentes,required String limitaciones,
  }) {
    final trozos = _fragmentar(detalle, 620);
    for (var i = 0; i < trozos.length; i++) {
      slides.add(_PaginaExportacion(7, {
        'R_FECHA': fecha,
        'R_ACTIVOS': identificador,
        'R_ESTADO': 'Generado por IA · requiere revisión',
        'R_TEXTO': trozos[i],
        'R_FUENTES': fuentes,
        'R_LIMIT': limitaciones,
        'R_SEGUIM': 'Verificar datos y evidencias antes de socializar.',
      }, titulo: '$titulo${trozos.length > 1 ? ' (${i + 1}/${trozos.length})' : ''}'));
    }
  }

  static Uint8List _componer(Uint8List plantilla, List<_PaginaExportacion> paginas) {
    final original = ZipDecoder().decodeBytes(plantilla);
    final archivos = <String, Uint8List>{};
    for (final file in original) {
      if (file.isFile) {
        final bytes = file.readBytes();
        if (bytes != null) archivos[file.name] = bytes;
      }
    }
    const sourceSlides = [8, 9, 10, 11, 12, 13, 14, 15];
    final output = <String, Uint8List>{};
    for (final entry in archivos.entries) {
      if (RegExp(r'^ppt/slides/slide\d+\.xml$').hasMatch(entry.key) ||
          RegExp(r'^ppt/slides/_rels/slide\d+\.xml\.rels$').hasMatch(entry.key)) {
        continue;
      }
      output[entry.key] = entry.value;
    }
    final slidesXml = <String>[];
    final relsNuevos = <String>[];
    final tiposNuevos = <String>[];
    for (var i = 0; i < paginas.length; i++) {
      final pagina = paginas[i];
      final indice = i + 1;
      final fuente = sourceSlides[pagina.plantilla];
      final xmlOrigen = 'ppt/slides/slide$fuente.xml';
      final relsOrigen = 'ppt/slides/_rels/slide$fuente.xml.rels';
      final relsDestino = 'ppt/slides/_rels/slide$indice.xml.rels';
      final texto = utf8.decode(archivos[xmlOrigen]!);
      final valores = <String,String>{
        ...pagina.valores,
        'TITLE': pagina.titulo ?? 'Informe de visita · Finanzas Verdes',
        'PAGE': '$indice',
      };
      final xml = texto.replaceAllMapped(
          RegExp(r'\{\{([A-Z0-9_]+)\}\}'),
          (m) => _xml(_recortarCampo(valores[m.group(1)] ?? 'N/D',m.group(1) ?? '')));
      output['ppt/slides/slide$indice.xml'] = Uint8List.fromList(utf8.encode(xml));
      var relaciones = utf8.decode(archivos[relsOrigen]!);
      for (var n = 0; n < math.min(2, pagina.fotos.length); n++) {
        final foto = pagina.fotos[n];
        if (foto == null) continue;
        final antiguo = '../media/image${n + 2}.png';
        final nuevo = 'fve_export_${indice}_${n + 1}.png';
        // image2 / image3 son dos placeholders distintos en las páginas con fotos.
        if (!relaciones.contains(antiguo)) continue;
        relaciones = relaciones.replaceFirst(antiguo, '../media/$nuevo');
        output['ppt/media/$nuevo'] = foto;
      }
      output[relsDestino] = Uint8List.fromList(utf8.encode(relaciones));
      slidesXml.add('<p:sldId id="${256 + i}" r:id="rId${500 + i}"/>');
      relsNuevos.add('<Relationship Id="rId${500 + i}" '
          'Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/slide" '
          'Target="slides/slide$indice.xml"/>');
      tiposNuevos.add('<Override PartName="/ppt/slides/slide$indice.xml" '
          'ContentType="application/vnd.openxmlformats-officedocument.presentationml.slide+xml"/>');
    }
    var pres = utf8.decode(archivos['ppt/presentation.xml']!);
    pres = pres.replaceFirst(RegExp(r'<p:sldIdLst>[\s\S]*?</p:sldIdLst>'),
      '<p:sldIdLst>${slidesXml.join()}</p:sldIdLst>');
    if (!pres.contains('rId500')) throw StateError('La plantilla PPTX cambió: no se encontró la lista de diapositivas.');
    output['ppt/presentation.xml'] = Uint8List.fromList(utf8.encode(pres));
    var rels = utf8.decode(archivos['ppt/_rels/presentation.xml.rels']!);
    rels = rels.replaceAll(RegExp(
      r'<Relationship\b(?=[^>]*Type="http://schemas\.openxmlformats\.org/officeDocument/2006/relationships/slide")[^>]*/>'), '');
    rels = rels.replaceFirst('</Relationships>', '${relsNuevos.join()}</Relationships>');
    output['ppt/_rels/presentation.xml.rels'] = Uint8List.fromList(utf8.encode(rels));
    var tipos = utf8.decode(archivos['[Content_Types].xml']!);
    tipos = tipos.replaceAll(RegExp(r'<Override\b[^>]*PartName="/ppt/slides/slide\d+\.xml"[^>]*/>'), '');
    tipos = tipos.replaceFirst('</Types>', '${tiposNuevos.join()}</Types>');
    output['[Content_Types].xml'] = Uint8List.fromList(utf8.encode(tipos));
    if (output.containsKey('docProps/app.xml')) {
      var app = utf8.decode(output['docProps/app.xml']!);
      app = app.replaceFirst(RegExp(r'<Slides>\d+</Slides>'), '<Slides>${paginas.length}</Slides>');
      output['docProps/app.xml'] = Uint8List.fromList(utf8.encode(app));
    }
    final zip = Archive();
    for (final e in output.entries) {
      zip.addFile(ArchiveFile(e.key, e.value.length, e.value));
    }
    return ZipEncoder().encodeBytes(zip);
  }

  static String _recortarCampo(String texto, String clave) {
    // El texto largo continúa en páginas adicionales; solo campos de una línea
    // se acotan por la geometría fija de la plantilla.
    final max = clave.startsWith('Q') && clave.endsWith('_TEXTO') ? 90
      : clave.startsWith('Q') && clave.endsWith('_OBS') ? 70
      : clave.startsWith('Q') && clave.endsWith('_RESP') ? 52
      : clave.startsWith('A') && !clave.startsWith('ACT') ? 44
      : clave.startsWith('D_') ? 335
      : clave == 'R_TEXTO' ? 650
      : clave.startsWith('R_') ? 180
      : clave == 'M_OBS' ? 140
      : clave == 'TITLE' ? 90
      : 80;
    if (texto.length <= max) return texto;
    return '${texto.substring(0, max - 1)}…';
  }

  static String _xml(String s) => s.replaceAll('&', '&amp;')
      .replaceAll('<', '&lt;').replaceAll('>', '&gt;')
      .replaceAll('"', '&quot;').replaceAll("'", '&apos;')
      .replaceAll(RegExp(r'[\u0000-\u001F]'), ' ');

  static String _seguroNombre(String s) {
    final v = _normalizar(s).replaceAll(RegExp(r'[^a-z0-9_-]+'), '_');
    return v.length > 44 ? v.substring(0, 44) : (v.isEmpty ? 'empresa' : v);
  }

  static String _normalizar(String s) => s.toLowerCase()
    .replaceAll('á','a').replaceAll('é','e').replaceAll('í','i')
    .replaceAll('ó','o').replaceAll('ú','u').replaceAll('ñ','n');
  static int? _entero(dynamic v) => int.tryParse(v?.toString() ?? '');
  static Map<String, dynamic> _map(dynamic value) => value is Map
      ? Map<String, dynamic>.from(value) : <String, dynamic>{};
  static List<Map<String, dynamic>> _listaMap(dynamic value) => value is List
      ? value.whereType<Map>().map((e) => Map<String,dynamic>.from(e)).toList()
      : <Map<String,dynamic>>[];
  static String _texto(dynamic value) {
    if (value == null) return 'N/D';
    if (value is List) return value.isEmpty ? 'N/D' : value.map(_texto).join(', ');
    if (value is Map) return value.isEmpty ? 'N/D' : value.entries
        .map((e) => '${e.key}: ${_texto(e.value)}').join('; ');
    final s = value.toString().trim();
    return s.isEmpty || s.toLowerCase() == 'null' ? 'N/D' : s;
  }
  static String _fecha(dynamic val) {
    final txt = _texto(val);
    final match = RegExp(r'^(\d{4})-(\d{2})-(\d{2})').firstMatch(txt);
    if (match == null) return txt;
    return '${match.group(3)}/${match.group(2)}/${match.group(1)}';
  }
  static int _fechaDesc(Map<String,dynamic> a, Map<String,dynamic> b) =>
    _texto(b['periodo_fin']).compareTo(_texto(a['periodo_fin']));
  static String _unir(List<dynamic> valores) {
    final items = valores.map(_texto).where((t) => t != 'N/D').toList();
    return items.isEmpty ? 'N/D' : items.toSet().join(' | ');
  }
  static List<String> _fragmentar(String texto,int max) {
    final limpio = texto.replaceAll(RegExp(r'\s+'), ' ').trim();
    if (limpio.isEmpty) return ['N/D'];
    final partes = <String>[];
    var restante = limpio;
    while (restante.length > max) {
      var corte = restante.lastIndexOf(' ', max);
      if (corte < max ~/ 2) corte = max;
      partes.add(restante.substring(0,corte).trim());
      restante = restante.substring(corte).trimLeft();
    }
    partes.add(restante);
    return partes;
  }
  static String _datoTecnico(Map<String,dynamic> datos,List<String> claves) {
    for (final k in claves) {
      final v = datos[k];
      if (v != null && _texto(v) != 'N/D') return _texto(v);
    }
    return 'N/D';
  }
  static String _modoUso(Map<String,dynamic> datos) {
    final perfil = _map(datos['fve_perfil_uso']);
    final modo = _texto(perfil['modo'] ?? perfil['comportamiento']);
    const titulos = {
      'continuo':'Continuo','apagado':'Apagado al cierre',
      'parcial':'Parcial','espera':'En espera',
      'sin_uso':'Sin uso al cierre','uso_fuera':'Uso fuera del horario',
      'desconocido':'No se conoce',
    };
    return titulos[modo] ?? modo;
  }
  static String _mediciones(Map<String,dynamic> datos) {
    final perfil = _map(datos['fve_perfil_uso']);
    final mediciones = _map(perfil['mediciones']);
    return mediciones.isEmpty ? 'No hay mediciones declaradas disponibles.'
      : mediciones.entries.map((e) => '${e.key}: ${_texto(e.value)}').join(' · ');
  }
}

class FvePresentacionExportada {
  final Uint8List bytes;
  final String nombreArchivo;
  final String mimeType;
  final int paginas;
  final List<String> advertencias;
  const FvePresentacionExportada({
    required this.bytes,required this.nombreArchivo,
    required this.mimeType,required this.paginas,
    required this.advertencias,
  });
}

class _PaginaExportacion {
  final int plantilla;
  final Map<String, String> valores;
  final List<Uint8List?> fotos;
  final String? titulo;
  const _PaginaExportacion(this.plantilla,this.valores,{
    this.fotos = const [],this.titulo,
  });
}
