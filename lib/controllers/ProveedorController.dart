import 'package:get/get.dart';

class ProveedorController extends GetxController {
  final tiposProveedores = [].obs;
  final catalogo = [].obs;
  final catalogoAdmin = {}.obs;
  final item = {}.obs;
  final loading = false.obs;

  void setTiposProveedores (List item){
    tiposProveedores.value = item;
  }

  void setCatalogo (List item){
    catalogo.value = item;
  }

  void setCatalogoAdmin (Map item){
    catalogoAdmin.value = item;
  }

  void setItem (Map value){
    item.value = value;
  }

  List get TiposProveedores => tiposProveedores.value;
  List get Catalogo => catalogo.value;
  Map get CatalogoAdmin => catalogoAdmin.value;
  Map get Item => item.value;
}