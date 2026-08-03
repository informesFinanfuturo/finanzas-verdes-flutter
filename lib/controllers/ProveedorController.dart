import 'package:get/get.dart';

class ProveedorController extends GetxController {
  final tiposProveedores = [].obs;
  final catalogo = [].obs;
  final item = {}.obs;

  void setTiposProveedores (List item){
    tiposProveedores.value = item;
  }

  void setCatalogo (List item){
    catalogo.value = item;
  }

  void setItem (Map value){
    item.value = value;
  }

  List get TiposProveedores => tiposProveedores.value;
  List get Catalogo => catalogo.value;
  Map get Item => item.value;
}