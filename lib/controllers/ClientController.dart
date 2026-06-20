import 'package:get/get.dart';

class ClientController extends GetxController{
  final clients = [].obs;
  final client = {}.obs;
  final activo = {}.obs;
  final consumo = {}.obs;

  void setClients (List item){
    clients.value = item;
  }

  void setClient (Map item){
    client.value = item;
  }

  void setActivo (Map item){
    activo.value = item;
  }

  void setConsumo (Map item){
    consumo.value = item;
  }

  List get Clients => clients.value;
  Map get Client => client.value;
  Map get Activo => activo.value;
  Map get Consumo => consumo.value;
}