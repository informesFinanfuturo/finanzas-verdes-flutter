import 'package:finanzas_verdes/models/api/clientApi.dart';
import 'package:finanzas_verdes/models/api/consumoApi.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class ClientController extends GetxController{
  final clients = [].obs;
  final client = {}.obs;
  final activo = {}.obs;
  final activos = [].obs;
  final consumos = [].obs;
  final consumo = {}.obs;
  final preview = {}.obs;
  final planTrabajo = {}.obs;
  final planesTrabajo = [].obs;
  var activosVisible = [].obs;
  var facturasVisible = [].obs;
  final infoCliente = {}.obs;
  final diagnosticos = [].obs;
  final diagnostico = {}.obs;
  final selectedClientSection = 0.obs;


  void setClients (List item){
    clients.value = item;
  }

  void setClient (Map item){
    client.value = item;
  }

  Future<void> refreshClient () async {
    client.value = await getClientDetailApi(idUsuario: client.value["user"]["id_usuario"]);
  }

  void setActivo (Map item){
    activo.value = item;
  }

  void setConsumo (Map item){
    consumo.value = item;
  }

  Future<void> refreshConsumo () async {
    consumo.value = await getConsumoApi(idConsumo: consumo.value["id_consumo"]);
  }

  void setPreview(Map<String, dynamic> data) {
    preview.value = data;
    activosVisible.value = List.from(data["activos"] ?? []);
    facturasVisible.value = List.from(data["facturas"] ?? []);
  }

  void removeActivo(int index) {
    activosVisible.removeAt(index);
  }

  void removeFactura(int index) {
    facturasVisible.removeAt(index);
  }

  void setInfoCliente (Map item) {
    infoCliente.value = item;
  }

  void setActivos (List item) {
    activos.value = item;
  }

  void setConsumos (List item) {
    consumos.value = item;
  }

  void setPlanTrabajo (Map item) {
    planTrabajo.value = item;
  }

  void setPlanesTrabajo (List item) {
    planesTrabajo.value = item;
  }

  void setDiagnosticos (List item) {
    diagnosticos.value = item;
  }

  void setDiagnostico (Map item){
    diagnostico.value = item;
  }

  void setSelectedClientSection(int index) {
    selectedClientSection.value = index;
  }

  List get Clients => clients.value;
  Map get Client => client.value;
  Map get Activo => activo.value;
  Map get Consumo => consumo.value;
  Map get Preview => preview.value;
  Map get InfoCliente => infoCliente.value;
  List get Activos => activos.value;
  List get Consumos => consumos.value;
  Map get PlanTrabajo => planTrabajo.value;
  List get PlanesTrabajo => planesTrabajo.value;
  List get Diagnosticos => diagnosticos.value;
  Map get Diagnostico => diagnostico.value;
}