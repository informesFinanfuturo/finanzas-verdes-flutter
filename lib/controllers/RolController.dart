import 'package:get/get.dart';

class RolController extends GetxController{
  final rols = [].obs;
  final rol = {}.obs;

  void setRols (List item){
    rols.value = item;
  }

  void setRol (Map item){
    rol.value = item;
  }

  List get Rols => rols.value;
  Map get Rol => rol.value;
}