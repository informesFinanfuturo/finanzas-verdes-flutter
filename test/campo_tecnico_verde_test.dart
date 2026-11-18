import 'package:finanzas_verdes/views/asesor/client/activo/campoTecnicoVerde.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final campoAnio = <String, dynamic>{
    'codigo': 'anio_equipo_anterior', 'etiqueta': 'Año del equipo', 'tipo': 'entero',
  };
  final campoConsumo = <String, dynamic>{
    'codigo': 'consumo_actual_kwh_mes', 'etiqueta': 'Consumo actual (kWh/mes)', 'tipo': 'numero',
  };
  final campoLitros = <String, dynamic>{
    'codigo': 'capacidad_actual_l', 'etiqueta': 'Capacidad actual (litros)', 'tipo': 'numero',
  };

  test('el año se valida como entero dentro del rango permitido', () {
    expect(CampoTecnicoVerde.validar(campoAnio, 'texto'), isNotNull);
    expect(CampoTecnicoVerde.validar(campoAnio, '1800'), isNotNull);
    expect(CampoTecnicoVerde.validar(campoAnio, '2020.5'), isNotNull);
    expect(CampoTecnicoVerde.validar(campoAnio, '2020'), isNull);
    expect(CampoTecnicoVerde.validar(campoAnio, ''), isNull);
  });

  test('los decimales aceptan coma y punto, pero no texto', () {
    for (final campo in [campoConsumo, campoLitros]) {
      expect(CampoTecnicoVerde.validar(campo, '13,5'), isNull);
      expect(CampoTecnicoVerde.validar(campo, '13.5'), isNull);
      expect(CampoTecnicoVerde.validar(campo, 'trece'), isNotNull);
      expect(CampoTecnicoVerde.validar(campo, '-5'), isNotNull);
      expect(CampoTecnicoVerde.valorParaGuardar(campo, '13,5'), 13.5);
    }
  });

  test('solo son obligatorios al evaluar reemplazo', () {
    expect(CampoTecnicoVerde.validar(campoConsumo, ''), isNull);
    expect(CampoTecnicoVerde.validar(campoConsumo, '', obligatorio: true), isNotNull);
  });

  testWidgets('el campo año impide introducir letras', (tester) async {
    final control = TextEditingController();
    addTearDown(control.dispose);
    await tester.pumpWidget(MaterialApp(home: Scaffold(body: Form(
      child: CampoTecnicoVerde(campo: campoAnio, controller: control),
    ))));
    await tester.enterText(find.byType(TextFormField), '2022');
    expect(control.text, '2022');
    await tester.enterText(find.byType(TextFormField), '2022abc');
    expect(control.text, '2022');
  });

  testWidgets('el campo consumo admite decimales y rechaza letras', (tester) async {
    final control = TextEditingController();
    addTearDown(control.dispose);
    await tester.pumpWidget(MaterialApp(home: Scaffold(body: Form(
      child: CampoTecnicoVerde(campo: campoConsumo, controller: control),
    ))));
    await tester.enterText(find.byType(TextFormField), '10,5');
    expect(control.text, '10,5');
    await tester.enterText(find.byType(TextFormField), '10,5xyz');
    expect(control.text, '10,5');
  });
}
