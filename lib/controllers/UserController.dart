import 'package:get/get.dart';

class UserController extends GetxController{
  final users = [].obs;
  final user = {}.obs;
  final tiposProveedor = [].obs;

  void setUsers (List item){
    users.value = item;
  }

  void setUser (Map item){
    user.value = item;
  }

  void setTiposProveedor (List item){
    tiposProveedor.value = item;
  }

  List get Users => users.value;
  Map get User => user.value;
  List get TiposProveedor => tiposProveedor.value;
}