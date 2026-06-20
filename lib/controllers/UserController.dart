import 'package:get/get.dart';

class UserController extends GetxController{
  final users = [].obs;
  final user = {}.obs;

  void setUsers (List item){
    users.value = item;
  }

  void setUser (Map item){
    user.value = item;
  }

  List get Users => users.value;
  Map get User => user.value;
}