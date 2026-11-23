import 'dart:typed_data';

import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class DiagnosticoPdfService {
  static const _verde = PdfColor(0.188, 0.400, 0.290);
  static const _verdeClaro = PdfColor(0.930, 0.965, 0.941);
  static const _texto = PdfColor(0.139, 0.173, 0.157);
  static const _secundario = PdfColor(0.430, 0.475, 0.448);
  static const _borde = PdfColor(0.862, 0.898, 0.872);
  static const _fondo = PdfColor(0.975, 0.983, 0.978);
  static const _naranja = PdfColor(0.898, 0.541, 0.122);
  static const _verdeAhorro = PdfColor(0.086, 0.514, 0.365);
  static const _azul = PdfColor(0.196, 0.463, 0.765);
  static const _morado = PdfColor(0.467, 0.337, 0.788);

  static Future<void> exportar({
    required Map<String, dynamic> diagnostico,
    required Map<String, dynamic> resumenSeleccion,
    required List<Map<String, dynamic>> activos,
  }) async {
    final ahora = DateTime.now();
    final titulo = _valor(diagnostico['titulo'], 'Diagnóstico de sostenibilidad');
    final idDiagnostico = _valor(diagnostico['id_diagnostico'], 'sin_id');
    final problem = _map(diagnostico['problema']);
    final beneficios = _map(diagnostico['beneficios']);
    final metadatos = _map(diagnostico['metricas']);
    pw.MemoryImage? logo;

    try {
      final asset = await rootBundle.load('lib/assets/finanfuturo/logo.png');
      logo = pw.MemoryImage(asset.buffer.asUint8List());
    } catch (_) {
      logo = null;
    }

    final documento = pw.Document(
      title: 'Diagnóstico de sostenibilidad - $titulo',
      author: 'Finanfuturo',
      subject: 'Resumen del diagnóstico y simulación de activos',
    );
    final contenido = <pw.Widget>[
      _portadaCompacta(titulo, activos.length, idDiagnostico),
      pw.SizedBox(height: 13),
      _encabezadoSeccion('Resumen ejecutivo',
          'Principales conclusiones obtenidas del análisis.'),
      ..._parrafos(_valor(problem['resumen'])),
      pw.SizedBox(height: 15),
      _encabezadoSeccion('Simulador de propuesta',
          'Indicadores correspondientes a los activos incluidos en esta simulación.'),
      pw.SizedBox(height: 8),
      ..._cuadriculaMetricas(resumenSeleccion, activos.length),
      pw.SizedBox(height: 12),
      if (metadatos['contiene_estimaciones_ia'] == true) ...[
        _aviso('Este diagnóstico incluye escenarios aproximados generados por IA. '
            'No representan consumos medidos, beneficios certificados ni una decisión '
            'de elegibilidad verde.'),
        pw.SizedBox(height: 12),
      ],
      _encabezadoSeccion('Activos recomendados',
          'Detalle del diagnóstico, con las selecciones visibles en la aplicación.'),
      pw.SizedBox(height: 7),
      if (activos.isEmpty)
        _textoSimple('No hay activos para mostrar.')
      else
        for (final activo in activos) ...[
          _tarjetaActivo(activo),
          pw.SizedBox(height: 10),
        ],
      pw.SizedBox(height: 6),
      _encabezadoSeccion('Problema identificado',
          'Situación actual que requiere atención.'),
      ..._parrafos(_valor(problem['detalle'])),
      pw.SizedBox(height: 13),
      _encabezadoSeccion('Beneficio y oportunidad',
          'Impacto esperado al implementar la propuesta.'),
      ..._parrafos(_valor(beneficios['detalle'])),
      pw.SizedBox(height: 12),
      _aviso('Documento informativo generado desde el diagnóstico. '
          'La selección mostrada puede ser una simulación no guardada. '
          'No constituye una propuesta comercial presentada, aprobación de crédito '
          'ni certificación de ahorros.'),
    ];

    documento.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.fromLTRB(36, 45, 36, 45),
        maxPages: 100,
        theme: pw.ThemeData.withFont(
          base: pw.Font.helvetica(),
          bold: pw.Font.helveticaBold(),
          italic: pw.Font.helveticaOblique(),
        ),
        header: (context) => _encabezadoPagina(logo),
        footer: (context) => _piePagina(context, ahora),
        build: (context) => contenido,
      ),
    );

    final Uint8List bytes = await documento.save();
    final nombre = 'diagnostico_${_archivoSeguro(idDiagnostico)}_'
        '${DateFormat('yyyyMMdd_HHmm').format(ahora)}.pdf';
    await Printing.sharePdf(bytes: bytes, filename: nombre);
  }

  static pw.Widget _encabezadoPagina(pw.MemoryImage? logo) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 12),
      child: pw.Column(
        children: [
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            crossAxisAlignment: pw.CrossAxisAlignment.center,
            children: [
              if (logo != null)
                pw.SizedBox(
                  width: 112,
                  height: 31,
                  child: pw.Image(logo, fit: pw.BoxFit.contain),
                )
              else
                pw.Text('Finanfuturo',
                    style: pw.TextStyle(
                        color: _verde,
                        fontSize: 15,
                        fontWeight: pw.FontWeight.bold)),
              pw.Text('FINANZAS VERDES  /  DIAGNÓSTICO',
                  style: const pw.TextStyle(
                      color: _secundario, fontSize: 8, letterSpacing: 0.5)),
            ],
          ),
          pw.SizedBox(height: 9),
          pw.Container(height: 1, color: _borde),
        ],
      ),
    );
  }

  static pw.Widget _piePagina(pw.Context contexto, DateTime ahora) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(top: 9),
      child: pw.Column(
        children: [
          pw.Container(height: 1, color: _borde),
          pw.SizedBox(height: 6),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text('Generado: ${DateFormat('dd/MM/yyyy HH:mm').format(ahora)}',
                  style: const pw.TextStyle(color: _secundario, fontSize: 8)),
              pw.Text('Página ${contexto.pageNumber} de ${contexto.pagesCount}',
                  style: const pw.TextStyle(color: _secundario, fontSize: 8)),
            ],
          ),
        ],
      ),
    );
  }

  static pw.Widget _portadaCompacta(String titulo, int cantidad, String id) {
    return pw.Container(
      width: double.infinity,
      padding: const pw.EdgeInsets.all(22),
      decoration: pw.BoxDecoration(
        color: _verde,
        borderRadius: pw.BorderRadius.circular(14),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text('RESULTADO DEL DIAGNÓSTICO',
              style: const pw.TextStyle(
                  color: PdfColor(0.81, 0.91, 0.85),
                  fontSize: 9,
                  letterSpacing: 0.7)),
          pw.SizedBox(height: 7),
          pw.Text(titulo,
              style: pw.TextStyle(
                  color: PdfColors.white,
                  fontSize: 19,
                  fontWeight: pw.FontWeight.bold,
                  lineSpacing: 2)),
          pw.SizedBox(height: 12),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text('$cantidad activos analizados',
                  style: const pw.TextStyle(color: PdfColors.white, fontSize: 10)),
              pw.Text('ID $id',
                  style: const pw.TextStyle(
                      color: PdfColor(0.81, 0.91, 0.85), fontSize: 9)),
            ],
          ),
        ],
      ),
    );
  }

  static pw.Widget _encabezadoSeccion(String titulo, String subtitulo) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(top: 4, bottom: 6),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(titulo,
              style: pw.TextStyle(
                  fontSize: 14,
                  color: _texto,
                  fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 3),
          pw.Text(subtitulo,
              style: const pw.TextStyle(fontSize: 9, color: _secundario)),
        ],
      ),
    );
  }

  static List<pw.Widget> _parrafos(String texto) {
    final normalizado = texto.trim().isEmpty ? 'Sin información disponible.' : texto.trim();
    final piezas = <String>[];
    for (final parrafo in normalizado.split(RegExp(r'\n\s*\n|\n'))) {
      var restante = parrafo.trim();
      while (restante.length > 850) {
        var corte = restante.lastIndexOf(' ', 850);
        if (corte < 300) corte = 850;
        piezas.add(restante.substring(0, corte).trim());
        restante = restante.substring(corte).trimLeft();
      }
      if (restante.isNotEmpty) piezas.add(restante);
    }
    return piezas
        .map((parte) => pw.Padding(
              padding: const pw.EdgeInsets.only(bottom: 6),
              child: pw.Text(parte,
                  style: const pw.TextStyle(
                      color: _texto, fontSize: 10.3, lineSpacing: 3)),
            ))
        .toList();
  }

  static List<pw.Widget> _cuadriculaMetricas(
      Map<String, dynamic> resumen, int cantidadTotal) {
    final valores = <_MetricaPdf>[
      _MetricaPdf('Ahorro mensual', _dinero(resumen['ahorro']), _verdeAhorro),
      _MetricaPdf('Inversión requerida', _dinero(resumen['inversion']), _naranja),
      _MetricaPdf('ROI a 5 años', _porcentaje(resumen['roi']), _morado),
      _MetricaPdf('Retorno de inversión', _meses(resumen['payback']), _azul),
      _MetricaPdf('Energía reducida', _medida(resumen['energia'], 'kWh'), _naranja),
      _MetricaPdf('Agua reducida', _medida(resumen['agua'], 'm³'), _azul),
      _MetricaPdf('CO2 evitado', _medida(resumen['carbono'], 'kg'), _verdeAhorro),
      _MetricaPdf('Activos incluidos', '${_valor(resumen['cantidad'], '0')} de $cantidadTotal', _verde),
    ];
    final resultado = <pw.Widget>[];
    for (var i = 0; i < valores.length; i += 2) {
      resultado.add(pw.Row(children: [
        pw.Expanded(child: _tarjetaMetrica(valores[i])),
        pw.SizedBox(width: 9),
        pw.Expanded(child: _tarjetaMetrica(valores[i + 1])),
      ]));
      resultado.add(pw.SizedBox(height: 9));
    }
    return resultado;
  }

  static pw.Widget _tarjetaMetrica(_MetricaPdf metrica) {
    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(horizontal: 12, vertical: 13),
      decoration: pw.BoxDecoration(
        color: _fondo,
        borderRadius: pw.BorderRadius.circular(10),
        border: pw.Border.all(color: _borde, width: 0.8),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Container(width: 25, height: 3, color: metrica.color),
          pw.SizedBox(height: 8),
          pw.Text(metrica.valor,
              style: pw.TextStyle(
                  fontSize: 13, color: _texto, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 4),
          pw.Text(metrica.etiqueta,
              style: const pw.TextStyle(fontSize: 8.5, color: _secundario)),
        ],
      ),
    );
  }

  static pw.Widget _tarjetaActivo(Map<String, dynamic> activo) {
    final metricas = _map(activo['metricas']);
    final confianza = _map(activo['confianza']);
    final alternativa = _map(activo['alternativa']);
    final incluido = activo['incluido'] == true;
    final colorEstado = incluido ? _verde : _secundario;
    final estado = incluido ? 'INCLUIDO EN SIMULACIÓN' : 'NO INCLUIDO';
    final ahorro = _dinero(metricas['ahorro_economico_mensual']);
    final inversion = _dinero(metricas['inversion_total_requerida']);
    final roi = _porcentaje(metricas['roi_5_anios']);
    final ahorroBase = _numero(metricas['ahorro_economico_mensual']);

    return pw.Container(
      width: double.infinity,
      padding: const pw.EdgeInsets.all(14),
      decoration: pw.BoxDecoration(
        color: PdfColors.white,
        borderRadius: pw.BorderRadius.circular(10),
        border: pw.Border.all(color: incluido ? _borde : _fondo, width: 1.1),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Expanded(
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(_valor(activo['nombre_activo'], 'Activo'),
                        style: pw.TextStyle(
                            fontSize: 12, color: _texto, fontWeight: pw.FontWeight.bold)),
                    pw.SizedBox(height: 4),
                    pw.Text('Prioridad ${_valor(activo['prioridad'], '-')}',
                        style: const pw.TextStyle(fontSize: 9, color: _secundario)),
                  ],
                ),
              ),
              pw.SizedBox(width: 8),
              pw.Text(estado,
                  style: pw.TextStyle(
                      fontSize: 7.3, color: colorEstado, fontWeight: pw.FontWeight.bold)),
            ],
          ),
          pw.SizedBox(height: 10),
          pw.Container(
            width: double.infinity,
            padding: const pw.EdgeInsets.symmetric(horizontal: 11, vertical: 9),
            decoration: pw.BoxDecoration(
                color: _verdeClaro, borderRadius: pw.BorderRadius.circular(7)),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text('Ahorro mensual estimado',
                    style: const pw.TextStyle(fontSize: 8, color: _secundario)),
                pw.SizedBox(height: 3),
                pw.Text(ahorro,
                    style: pw.TextStyle(
                        fontSize: 12,
                        color: _verdeAhorro,
                        fontWeight: pw.FontWeight.bold)),
              ],
            ),
          ),
          pw.SizedBox(height: 9),
          _filaDatos('Inversión', inversion, 'ROI a 5 años',
              ahorroBase == 0 ? 'No disponible' : roi),
          _filaDatos('Energía reducida', _medida(metricas['reduccion_energia'], 'kWh'),
              'Agua reducida', _medida(metricas['reduccion_agua'], 'm³')),
          _filaDatos('CO2 evitado', _medida(metricas['reduccion_carbono'], 'kg'),
              'Consumo proyectado IA',
              _medida(metricas['consumo_energia_proyectado_mes'], 'kWh/mes')),
          if (confianza.isNotEmpty) ...[
            pw.SizedBox(height: 8),
            pw.Text('Confianza: ${_valor(confianza['nivel'], 'Sin dato')}',
                style: const pw.TextStyle(fontSize: 8.6, color: _secundario)),
            if (_valor(confianza['motivo']).isNotEmpty)
              pw.Text(_valor(confianza['motivo']),
                  style: const pw.TextStyle(fontSize: 8.4, color: _secundario)),
          ],
          if (alternativa.isNotEmpty) ...[
            pw.SizedBox(height: 8),
            pw.Container(height: 1, color: _borde),
            pw.SizedBox(height: 7),
            pw.Text(
              alternativa['fuente']?.toString().toLowerCase() == 'ia'
                  ? 'Recomendación de la IA'
                  : 'Alternativa elegida por el usuario',
              style: pw.TextStyle(
                  fontSize: 9, color: _verde, fontWeight: pw.FontWeight.bold),
            ),
            pw.Text(_valor(alternativa['nombre'], 'Producto seleccionado'),
                style: const pw.TextStyle(color: _texto, fontSize: 9)),
            if (_map(alternativa['proveedor']).isNotEmpty)
              pw.Text('Proveedor: ${_valor(_map(alternativa['proveedor'])['nombre'], 'No disponible')}',
                  style: const pw.TextStyle(color: _secundario, fontSize: 8.3)),
            pw.Text('Precio unitario: ${_dinero(alternativa['precio_base'])}',
                style: const pw.TextStyle(color: _secundario, fontSize: 8.3)),
          ],
        ],
      ),
    );
  }

  static pw.Widget _filaDatos(
      String etiqueta1, String valor1, String etiqueta2, String valor2) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 5),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Expanded(child: _dato(etiqueta1, valor1)),
          pw.SizedBox(width: 12),
          pw.Expanded(child: _dato(etiqueta2, valor2)),
        ],
      ),
    );
  }

  static pw.Widget _dato(String etiqueta, String valor) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(etiqueta,
            style: const pw.TextStyle(fontSize: 8, color: _secundario)),
        pw.SizedBox(height: 2),
        pw.Text(valor,
            style: pw.TextStyle(
                fontSize: 9, color: _texto, fontWeight: pw.FontWeight.bold)),
      ],
    );
  }

  static pw.Widget _aviso(String texto) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(11),
      decoration: pw.BoxDecoration(
        color: const PdfColor(1.0, 0.974, 0.917),
        borderRadius: pw.BorderRadius.circular(8),
        border: pw.Border.all(color: const PdfColor(0.94, 0.82, 0.65)),
      ),
      child: pw.Text(texto,
          style: const pw.TextStyle(fontSize: 8.6, color: _texto, lineSpacing: 2)),
    );
  }

  static pw.Widget _textoSimple(String texto) => pw.Text(texto,
      style: const pw.TextStyle(color: _texto, fontSize: 10));

  static Map<String, dynamic> _map(dynamic dato) {
    if (dato is Map) return Map<String, dynamic>.from(dato);
    return <String, dynamic>{};
  }

  static String _valor(dynamic dato, [String alterno = '']) {
    final texto = (dato?.toString().trim() ?? '')
        .replaceAll('\u00a0', ' ')
        .replaceAll('•', '-')
        .replaceAll('→', '->')
        .replaceAll('—', '-')
        .replaceAll('–', '-')
        .replaceAll('“', '"')
        .replaceAll('”', '"')
        .replaceAll('’', "'")
        .replaceAll('₂', '2');
    return texto.isEmpty ? alterno : texto;
  }

  static double? _numero(dynamic dato) {
    if (dato == null || dato.toString().trim().isEmpty) return null;
    if (dato is num) return dato.toDouble().isFinite ? dato.toDouble() : null;
    var texto = dato.toString().trim().replaceAll(RegExp(r'[^\d,.-]'), '');
    if (texto.contains('.') && texto.contains(',')) {
      texto = texto.replaceAll('.', '').replaceAll(',', '.');
    } else if (RegExp(r'^\d{1,3}(\.\d{3})+$').hasMatch(texto)) {
      texto = texto.replaceAll('.', '');
    } else {
      texto = texto.replaceAll(',', '.');
    }
    final n = double.tryParse(texto);
    return (n != null && n.isFinite) ? n : null;
  }

  static String _dinero(dynamic dato) {
    final valor = _numero(dato);
    if (valor == null) return 'No disponible';
    return '\$${NumberFormat.decimalPatternDigits(locale: 'es_CO', decimalDigits: 0).format(valor)}';
  }

  static String _porcentaje(dynamic dato) {
    final valor = _numero(dato);
    if (valor == null) return 'No disponible';
    return '${valor.toStringAsFixed(1)}%';
  }

  static String _meses(dynamic dato) {
    final valor = _numero(dato);
    if (valor == null) return 'No disponible';
    return '${valor.toStringAsFixed(1)} meses';
  }

  static String _medida(dynamic dato, String unidad) {
    final valor = _numero(dato);
    if (valor == null) return 'No disponible';
    return '${valor.toStringAsFixed(1)} $unidad';
  }

  static String _archivoSeguro(String id) =>
      id.replaceAll(RegExp(r'[^a-zA-Z0-9_-]'), '_');
}

class _MetricaPdf {
  final String etiqueta;
  final String valor;
  final PdfColor color;

  const _MetricaPdf(this.etiqueta, this.valor, this.color);
}
