import 'dart:convert';

import 'package:finanzas_verdes/controllers/ClientController.dart';
import 'package:finanzas_verdes/main.dart';
import 'package:http/http.dart' as http;
import 'package:finanzas_verdes/app/config/Global.dart';
import 'package:get_storage/get_storage.dart';

Future<void> createCalendarioApi({
  required String titulo,
  required DateTime fechaHora,
  String? direccion,
  String? descripcion,
  required List<int> usuarios,
}) async {

  final uri = Uri.parse(
    '${Global.baseUrl}calendario',
  );

  final token =
  GetStorage().read("token");

  try {
    final response = await http.post(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        "titulo": titulo,
        "fecha_hora": fechaHora.toIso8601String(),
        "direccion": direccion,
        "descripcion": descripcion,
        "usuarios": usuarios,
      }),
    );

    if (response.statusCode == 201) {
      print(
        "Calendario creado correctamente",
      );
      return;
    }
    if (response.statusCode == 401) {
      controller.logOut();
      return;
    }

    final data = jsonDecode(
      response.body,
    );

    throw Exception(data['error'] ?? 'Error al crear calendario',);

  } catch (e) {
    print("ERROR CREAR CALENDARIO: $e",);
    rethrow;
  }

}

Future<void> getClientsAgendaApi() async {

  final uri = Uri.parse(
    '${Global.baseUrl}calendario/today',
  );

  final token = GetStorage().read("token");

  try {
    final response = await http.get(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      print("Agenda obtenida correctamente",);
      final result = jsonDecode(response.body);
      controller.setAgenda(result["clients"]);
      return;
    }
    if (response.statusCode == 401) {
      controller.logOut();
      return;
    }

    final data = jsonDecode(
      response.body,
    );

    throw Exception(data['error'] ?? 'Error al crear calendario',);

  } catch (e) {
    print("ERROR CREAR CALENDARIO: $e",);
    rethrow;
  }

}

Future<void> eliminarCalendarioApi(int id) async {

  final uri = Uri.parse(
    '${Global.baseUrl}calendario/$id',
  );

  final token = GetStorage().read("token");

  try {
    final response = await http.delete(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      print("Agenda eliminada correctamente",);
      getClientsAgendaApi();
      return;
    }
    if (response.statusCode == 401) {
      controller.logOut();
      return;
    }

    final data = jsonDecode(
      response.body,
    );

    throw Exception(data['error'] ?? 'Error al eliminar calendario',);

  } catch (e) {
    print("ERROR ELIMINAR CALENDARIO: $e",);
    rethrow;
  }

}

Future<void> editarCalendarioApi({
  required int id,
  required String titulo,
  required DateTime fechaHora,
  String? direccion,
  String? descripcion,
  required List<int> usuarios,
}) async {

  final uri = Uri.parse(
    '${Global.baseUrl}calendario/$id',
  );

  final token =
  GetStorage().read("token");

  try {
    final response = await http.put(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        "titulo": titulo,
        "fecha_hora": fechaHora.toIso8601String(),
        "direccion": direccion,
        "descripcion": descripcion,
        "usuarios": usuarios,
      }),
    );

    if (response.statusCode == 200) {
      print(
        "Calendario editado correctamente",
      );
      getClientsAgendaApi();
      return;
    }
    if (response.statusCode == 401) {
      controller.logOut();
      return;
    }

    final data = jsonDecode(
      response.body,
    );

    throw Exception(data['error'] ?? 'Error al crear calendario',);

  } catch (e) {
    print("ERROR CREAR CALENDARIO: $e",);
    rethrow;
  }

}

Future<List<dynamic>> getClientsAgendaRangeApi({
  required DateTime fechaInicio,
  required DateTime fechaFin,
}) async {

  final uri = Uri.parse(
    '${Global.baseUrl}calendario/range',
  );

  final token =
  GetStorage().read("token");

  try {

    final response =
    await http.post(

      uri,

      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },

      body: jsonEncode({

        "fecha_inicio":
        fechaInicio
            .toIso8601String()
            .split('T')
            .first,

        "fecha_fin":
        fechaFin
            .toIso8601String()
            .split('T')
            .first,

      }),

    );

    if (response.statusCode == 200) {

      final result =
      jsonDecode(
        response.body,
      );
      return List<dynamic>.from(result["clients"] ?? [],);
    }
    if (response.statusCode == 401) {
      controller.logOut();
      return [];
    }
    final data = jsonDecode(response.body,);
    throw Exception(data['error'] ?? 'Error al obtener agenda');
  } catch (e) {
    print("ERROR OBTENER AGENDA RANGO: $e");
    rethrow;
  }
}