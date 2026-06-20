import 'package:get/get.dart';

class PermissionController extends GetxController{
  final permissions = [].obs;
  final permission = {}.obs;

  void setPermissions (List item){
    permissions.value = item;
  }

  void setPermission (Map item){
    permission.value = item;
  }

  List get Permissions => permissions.value;
  Map get Permission => permission.value;
}