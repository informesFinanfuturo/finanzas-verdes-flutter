import 'package:get/get.dart';

class UserController extends GetxController {
  final users = <dynamic>[].obs;
  final user = <String, dynamic>{}.obs;
  final tiposProveedor = <dynamic>[].obs;

  // Administración de usuarios
  final summary = <String, dynamic>{}.obs;
  final pagination = <String, dynamic>{}.obs;
  final filters = <String, dynamic>{}.obs;
  final userAudit = <dynamic>[].obs;
  final auditPagination = <String, dynamic>{}.obs;
  final isLoadingAudit = false.obs;
  final isLoadingUsers = false.obs;

  void setUsers(List<dynamic> items) {
    users.assignAll(items);
  }

  void setUser(Map<String, dynamic> item) {
    user.assignAll(item);
  }

  void setTiposProveedor(List<dynamic> items) {
    tiposProveedor.assignAll(items);
  }

  void setSummary(Map<String, dynamic>? value) {
    summary.assignAll(value ?? {});
  }

  void setPagination(Map<String, dynamic>? value) {
    pagination.assignAll(value ?? {});
  }

  void setFilters(Map<String, dynamic>? value) {
    filters.assignAll(value ?? {});
  }

  void setLoadingUsers(bool value) {
    isLoadingUsers.value = value;
  }

  void clearUsersAdministration() {
    users.clear();
    summary.clear();
    pagination.clear();
    filters.clear();
  }

  void setUserAudit(
      List<dynamic> items,
      ) {
    userAudit.assignAll(
      items,
    );
  }

  void setAuditPagination(
      Map<String, dynamic>? value,
      ) {
    auditPagination.assignAll(
      value ?? {},
    );
  }

  void setLoadingAudit(
      bool value,
      ) {
    isLoadingAudit.value =
        value;
  }

  void clearUserAudit() {
    userAudit.clear();
    auditPagination.clear();
  }

  List<dynamic> get Users => users;
  Map<String, dynamic> get User => user;
  List<dynamic> get TiposProveedor => tiposProveedor;
  Map<String, dynamic> get Summary => summary;
  Map<String, dynamic> get Pagination => pagination;
  Map<String, dynamic> get Filters => filters;
  List<dynamic> get UserAudit => userAudit;
  Map<String, dynamic> get AuditPagination => auditPagination;
}