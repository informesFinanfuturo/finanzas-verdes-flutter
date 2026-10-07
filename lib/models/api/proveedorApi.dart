import 'dart:convert';

import 'package:finanzas_verdes/app/config/Global.dart';
import 'package:finanzas_verdes/controllers/ProveedorController.dart';
import 'package:finanzas_verdes/main.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;

Future<Map<String, dynamic>> createTipoProveedorApi({
  required String nombreTipo,
  String? descripcion,
}) async {

  final uri = Uri.parse('${Global.baseUrl}proveedor/tipo');
  final token = GetStorage().read("token");

  try {
    final response = await http.post(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({

        // ✅ OBLIGATORIO
        'nombre_tipo': nombreTipo,

        // ✅ OPCIONAL
        if (descripcion != null) 'descripcion': descripcion,
      }),
    );

    if (response.statusCode == 201) {
      final data = jsonDecode(response.body);

      print("Tipo de proveedor creado ✅");

      return data['tipo_proveedor'] as Map<String, dynamic>;
    }

    if (response.statusCode == 401) {
      controller.logOut();
      throw Exception('Sesión expirada');
    }

    if (response.statusCode == 400 || response.statusCode == 404) {
      final data = jsonDecode(response.body);
      throw Exception(data['error'] ?? 'Error al crear tipo de proveedor');
    }

    throw Exception('Error inesperado (${response.statusCode})');

  } catch (e) {
    print("ERROR CREATE TIPO PROVEEDOR: $e");
    rethrow;
  }
}

Future<void> getTipoProveedoresApi({
  required ProveedorController proveedorController
}) async {

  final uri = Uri.parse('${Global.baseUrl}proveedor/tipo');
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
      final data = jsonDecode(response.body);
      proveedorController.setTiposProveedores(data["tipos_proveedor"]);
      return;
    }

    if (response.statusCode == 401) {
      controller.logOut();
      throw Exception('Sesión expirada');
    }

    if (response.statusCode == 400 || response.statusCode == 404) {
      final data = jsonDecode(response.body);
      throw Exception(data['error'] ?? 'Error al obtener tipos de proveedor');
    }

    throw Exception('Error inesperado (${response.statusCode})');

  } catch (e) {
    print("ERROR GET TIPOS PROVEEDOR: $e");
    rethrow;
  }
}

String _proveedorApiError(http.Response response) {
  try {
    final data = jsonDecode(response.body);

    if (data is Map) {
      return data['error']?.toString() ??
          data['message']?.toString() ??
          'Error inesperado';
    }
  } catch (_) {}

  return 'Error inesperado (${response.statusCode})';
}

Future<void> getProveedoresAdminApi({
  required ProveedorController proveedorController,
  String? buscar,
  String? estado,
  int? idTipoProveedor,
  String? origen,
  int pagina = 1,
  int limite = 20,
}) async {
  proveedorController.loadingProveedoresAdmin.value = true;
  proveedorController.errorProveedoresAdmin.value = '';

  try {
    final query = <String, String>{
      'pagina': pagina.toString(),
      'limite': limite.toString(),
    };

    if (buscar?.trim().isNotEmpty == true) {
      query['buscar'] = buscar!.trim();
    }

    if (estado?.trim().isNotEmpty == true) {
      query['estado'] = estado!.trim();
    }

    if (idTipoProveedor != null) {
      query['id_tipo_proveedor'] = idTipoProveedor.toString();
    }

    if (origen?.trim().isNotEmpty == true) {
      query['origen'] = origen!.trim();
    }

    final uri = Uri.parse(
      '${Global.baseUrl}proveedor/admin',
    ).replace(queryParameters: query);

    final token = GetStorage().read('token');

    final response = await http.get(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      if (data is! Map) {
        throw Exception('La respuesta de proveedores no es válida');
      }

      proveedorController.setProveedoresAdmin(data);
      return;
    }

    if (response.statusCode == 401) {
      controller.logOut();
      throw Exception('Sesión expirada');
    }

    throw Exception(_proveedorApiError(response));
  } catch (error) {
    proveedorController.errorProveedoresAdmin.value = error
        .toString()
        .replaceFirst('Exception: ', '');

    rethrow;
  } finally {
    proveedorController.loadingProveedoresAdmin.value = false;
  }
}

Future<void> cargarProveedoresAdminApi({
  required ProveedorController proveedorController,
}) {
  return getProveedoresAdminApi(
    proveedorController: proveedorController,
    buscar: proveedorController.busquedaProveedor.value,
    estado: proveedorController.estadoProveedorFiltro.value,
    idTipoProveedor: proveedorController.tipoProveedorFiltroId.value,
    origen: proveedorController.origenProveedorFiltro.value,
    pagina: proveedorController.paginaProveedores.value,
    limite: proveedorController.limiteProveedores.value,
  );
}