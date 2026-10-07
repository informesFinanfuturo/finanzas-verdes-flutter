import 'package:get/get.dart';

class ProveedorController extends GetxController {

  final RxList<dynamic>tiposProveedores = <dynamic>[].obs;

  final RxList<dynamic>catalogo = <dynamic>[].obs;

  final RxMap<String, dynamic>item = <String, dynamic>{}.obs;

  final RxBool loading = false.obs;

  final RxMap<String, dynamic>catalogoAdmin = <String, dynamic>{}.obs;

  final RxList<Map<String, dynamic>>productosAdmin = <Map<String, dynamic>>[].obs;

  final RxMap<String, dynamic>resumenCatalogoAdmin = <String, dynamic>{}.obs;

  final RxMap<String, dynamic>paginacionCatalogoAdmin = <String, dynamic>{}.obs;

  final RxBool loadingCatalogoAdmin = false.obs;

  final RxString errorCatalogoAdmin = ''.obs;

  final RxList<Map<String, dynamic>> proveedoresAdmin =
      <Map<String, dynamic>>[].obs;

  final RxMap<String, dynamic> resumenProveedoresAdmin =
      <String, dynamic>{}.obs;

  final RxMap<String, dynamic> paginacionProveedoresAdmin =
      <String, dynamic>{}.obs;

  final RxMap<String, dynamic> proveedorDetalle =
      <String, dynamic>{}.obs;

  final RxBool loadingProveedoresAdmin = false.obs;
  final RxString errorProveedoresAdmin = ''.obs;

/*
 * Filtros del listado de proveedores.
 */
  final RxString busquedaProveedor = ''.obs;
  final RxString estadoProveedorFiltro = ''.obs;
  final RxString origenProveedorFiltro = ''.obs;
  final RxnInt tipoProveedorFiltroId = RxnInt();

  final RxInt paginaProveedores = 1.obs;
  final RxInt limiteProveedores = 20.obs;

  /*
   * Filtros administrativos.
   */
  final RxString
  busquedaCatalogo =
      ''.obs;

  final RxnInt
  proveedorSeleccionadoId =
  RxnInt();

  final RxString
  tipoItemSeleccionado =
      ''.obs;

  final RxString
  estadoCatalogo =
      ''.obs;

  final RxnBool
  disponibilidadSeleccionada =
  RxnBool();

  final RxInt paginaCatalogo =
      1.obs;

  final RxInt limiteCatalogo =
      24.obs;

  final RxMap<String, dynamic> sincronizacionActual = <String, dynamic>{}.obs;
  final RxList<Map<String, dynamic>> historialSincronizaciones = <Map<String, dynamic>>[].obs;

  final RxList<Map<String, dynamic>> logsSincronizacion = <Map<String, dynamic>>[].obs;
  final RxBool iniciandoSincronizacion = false.obs;
  final RxBool consultandoSincronizacion = false.obs;
  final RxBool cargandoHistorial = false.obs;
  final RxBool cargandoLogsSincronizacion = false.obs;

  final RxString errorSincronizacion = ''.obs;
  final RxString errorLogsSincronizacion = ''.obs;

  /*
   * Métodos conservados para compatibilidad
   * con las pantallas actuales.
   */
  void setTiposProveedores(
      List<dynamic> values,
      ) {
    tiposProveedores.assignAll(
      values,
    );
  }

  void setCatalogo(
      List<dynamic> values,
      ) {
    catalogo.assignAll(
      values,
    );
  }

  void setCatalogoAdmin(
      Map<dynamic, dynamic> value,
      ) {
    final normalized =
    Map<String, dynamic>.from(
      value,
    );

    catalogoAdmin.assignAll(
      normalized,
    );

    final rawProducts =
    normalized['productos'];

    productosAdmin.assignAll(
      rawProducts is List
          ? rawProducts
          .whereType<Map>()
          .map(
            (
            product,
            ) =>
        Map<String, dynamic>.from(
          product,
        ),
      )
          .toList()
          : <Map<String, dynamic>>[],
    );

    final rawSummary =
    normalized['summary'];

    resumenCatalogoAdmin.assignAll(
      rawSummary is Map
          ? Map<String, dynamic>.from(
        rawSummary,
      )
          : <String, dynamic>{},
    );

    final rawPagination =
    normalized['pagination'];

    paginacionCatalogoAdmin.assignAll(
      rawPagination is Map
          ? Map<String, dynamic>.from(
        rawPagination,
      )
          : <String, dynamic>{},
    );
  }

  void setItem(
      Map<dynamic, dynamic> value,
      ) {
    item.assignAll(
      Map<String, dynamic>.from(
        value,
      ),
    );
  }

  void setSincronizacionActual(
      Map<dynamic, dynamic> value,
      ) {
    sincronizacionActual.assignAll(
      Map<String, dynamic>.from(
        value,
      ),
    );
  }

  void setHistorialSincronizaciones(
      List<dynamic> values,
      ) {
    historialSincronizaciones.assignAll(
      values
          .whereType<Map>()
          .map(
            (
            value,
            ) =>
        Map<String, dynamic>.from(
          value,
        ),
      )
          .toList(),
    );
  }

  void setLogsSincronizacion(List<dynamic> values) {
    logsSincronizacion.assignAll(
      values.whereType<Map>().map((e) => Map<String, dynamic>.from(e)).toList(),
    );
  }

  void limpiarLogsSincronizacion() {
    logsSincronizacion.clear();
    errorLogsSincronizacion.value = '';
  }

  void limpiarErrorSincronizacion() {
    errorSincronizacion.value =
    '';
  }

  void limpiarFiltrosCatalogo() {
    busquedaCatalogo.value =
    '';

    proveedorSeleccionadoId.value =
    null;

    tipoItemSeleccionado.value =
    '';

    estadoCatalogo.value =
    '';

    disponibilidadSeleccionada.value =
    null;

    paginaCatalogo.value =
    1;
  }

  void setPaginaCatalogo(
      int page,
      ) {
    if (page > 0) {
      paginaCatalogo.value =
          page;
    }
  }

  bool get haySincronizacionActiva {
    final status =
    sincronizacionActual[
    'estado']
        ?.toString()
        .toLowerCase();

    return status ==
        'pendiente' ||
        status ==
            'procesando';
  }

  void setProveedoresAdmin(Map<dynamic, dynamic> response) {
    final data = Map<String, dynamic>.from(response);

    final rawProviders = data['proveedores'];
    proveedoresAdmin.assignAll(
      rawProviders is List
          ? rawProviders
          .whereType<Map>()
          .map((item) => Map<String, dynamic>.from(item))
          .toList()
          : <Map<String, dynamic>>[],
    );


    final rawSummary = data['summary'];
    resumenProveedoresAdmin.assignAll(
      rawSummary is Map
          ? Map<String, dynamic>.from(rawSummary)
          : <String, dynamic>{},
    );

    final rawPagination = data['pagination'];
    paginacionProveedoresAdmin.assignAll(
      rawPagination is Map
          ? Map<String, dynamic>.from(rawPagination)
          : <String, dynamic>{},
    );
  }

  void setProveedorDetalle(Map<dynamic, dynamic> value) {
    proveedorDetalle.assignAll(Map<String, dynamic>.from(value));
  }

  void limpiarFiltrosProveedores() {
    busquedaProveedor.value = '';
    estadoProveedorFiltro.value = '';
    origenProveedorFiltro.value = '';
    tipoProveedorFiltroId.value = null;
    paginaProveedores.value = 1;
  }

  void setPaginaProveedores(int page) {
    if (page > 0) paginaProveedores.value = page;
  }

  List<dynamic> get TiposProveedores => tiposProveedores;

  List<dynamic> get Catalogo => catalogo;

  Map<String, dynamic> get CatalogoAdmin => catalogoAdmin;
  Map<String, dynamic> get Item => item;
}