import 'package:get/get.dart';

class RolController extends GetxController {
  final RxList<dynamic> rols =
      <dynamic>[].obs;

  final RxMap<String, dynamic> rol =
      <String, dynamic>{}.obs;

  final RxMap<String, dynamic> summary =
      <String, dynamic>{}.obs;

  final RxnInt selectedRoleId =
  RxnInt();

  final RxSet<int> selectedPermissionIds =
      <int>{}.obs;

  final RxSet<int> originalPermissionIds =
      <int>{}.obs;

  final RxBool isLoading =
      false.obs;

  final RxBool isSaving =
      false.obs;

  // =====================================
  // ROLES
  // =====================================

  void setRols(
      List<dynamic> items,
      ) {
    rols.assignAll(items);

    /*
     * Si ya había un rol seleccionado,
     * intentamos conservarlo después
     * de actualizar la información.
     */
    final currentRoleId =
        selectedRoleId.value;

    if (currentRoleId != null) {
      final selected =
      _findRoleById(
        currentRoleId,
      );

      if (selected != null) {
        selectRole(selected);
        return;
      }
    }

    /*
     * Si no había selección o el rol
     * dejó de existir, seleccionamos
     * el primer rol disponible.
     */
    if (rols.isNotEmpty) {
      final firstRole =
          rols.first;

      if (firstRole is Map) {
        selectRole(
          Map<String, dynamic>.from(
            firstRole,
          ),
        );
      }
    } else {
      clearSelectedRole();
    }
  }

  void setSummary(
      Map<String, dynamic>? value,
      ) {
    summary.assignAll(
      value ??
          <String, dynamic>{},
    );
  }

  void setRol(
      Map<dynamic, dynamic> item,
      ) {
    selectRole(
      Map<String, dynamic>.from(
        item,
      ),
    );
  }

  void selectRole(Map<String, dynamic> role,) {
    rol.assignAll(role);

    selectedRoleId.value =
        _toInt(
          role['id_rol'],
        );

    final rawPermissions =
    role['permisos'];

    final List<dynamic> permissions =
    rawPermissions is List
        ? rawPermissions
        : <dynamic>[];

    final Set<int> assignedIds =
    <int>{};

    for (final item in permissions) {
      if (item is! Map) {
        continue;
      }

      final permission =
      Map<String, dynamic>.from(
        item,
      );

      final permissionId =
      _toInt(
        permission['id_permiso'],
      );

      if (permissionId == null ||
          permissionId <= 0) {
        continue;
      }

      /*
     * El backend actual utiliza "enabled".
     * También dejamos soporte para "asignado"
     * por compatibilidad futura.
     */
      final bool assigned =
          _isAssigned(
            permission['enabled'],
          ) ||
              _isAssigned(
                permission['asignado'],
              );

      if (assigned) {
        assignedIds.add(
          permissionId,
        );
      }
    }

    originalPermissionIds.assignAll(
      assignedIds,
    );

    selectedPermissionIds.assignAll(
      assignedIds,
    );

    originalPermissionIds.refresh();
    selectedPermissionIds.refresh();
    rol.refresh();
  }

  void clearSelectedRole() {
    rol.clear();

    selectedRoleId.value =
    null;

    originalPermissionIds.clear();
    selectedPermissionIds.clear();

    rol.refresh();
    originalPermissionIds.refresh();
    selectedPermissionIds.refresh();
  }

  // =====================================
  // PERMISOS
  // =====================================

  void togglePermission(
      int permissionId,
      ) {
    if (permissionId <= 0) {
      return;
    }

    if (
    selectedPermissionIds.contains(
      permissionId,
    )
    ) {
      selectedPermissionIds.remove(
        permissionId,
      );
    } else {
      selectedPermissionIds.add(
        permissionId,
      );
    }

    selectedPermissionIds.refresh();
  }

  void selectPermissions(
      Iterable<int> permissionIds,
      ) {
    final validIds =
    permissionIds.where(
          (id) => id > 0,
    );

    selectedPermissionIds.addAll(
      validIds,
    );

    selectedPermissionIds.refresh();
  }

  void removePermissions(
      Iterable<int> permissionIds,
      ) {
    selectedPermissionIds.removeAll(
      permissionIds,
    );

    selectedPermissionIds.refresh();
  }

  void discardPermissionChanges() {
    selectedPermissionIds.assignAll(
      originalPermissionIds,
    );

    selectedPermissionIds.refresh();
  }

  /*
   * Puedes llamarlo después de que
   * el backend confirme el guardado.
   */
  void confirmPermissionChanges() {
    originalPermissionIds.assignAll(
      selectedPermissionIds,
    );

    originalPermissionIds.refresh();
    selectedPermissionIds.refresh();
  }

  // =====================================
  // ESTADOS DE CARGA
  // =====================================

  void setLoading(
      bool value,
      ) {
    isLoading.value =
        value;
  }

  void setSaving(
      bool value,
      ) {
    isSaving.value =
        value;
  }

  // =====================================
  // BÚSQUEDAS
  // =====================================

  Map<String, dynamic>?
  _findRoleById(
      int id,
      ) {
    for (final item in rols) {
      if (item is! Map) {
        continue;
      }

      final itemId =
      _toInt(
        item['id_rol'],
      );

      if (itemId == id) {
        return Map<String, dynamic>.from(
          item,
        );
      }
    }

    return null;
  }

  // =====================================
  // CONVERSIONES
  // =====================================

  int? _toInt(
      dynamic value,
      ) {
    if (value == null) {
      return null;
    }

    if (value is int) {
      return value;
    }

    if (value is num) {
      return value.toInt();
    }

    return int.tryParse(
      value.toString(),
    );
  }

  bool _isAssigned(
      dynamic value,
      ) {
    if (value == true ||
        value == 1) {
      return true;
    }

    final normalized =
    value
        ?.toString()
        .trim()
        .toLowerCase();

    return normalized == '1' ||
        normalized == 'true' ||
        normalized == 'si' ||
        normalized == 'sí';
  }

  // =====================================
  // CAMBIOS PENDIENTES
  // =====================================

  bool get hasPermissionChanges {
    if (
    selectedPermissionIds.length !=
        originalPermissionIds.length
    ) {
      return true;
    }

    return !selectedPermissionIds
        .containsAll(
      originalPermissionIds,
    );
  }

  int get addedPermissionsCount {
    return selectedPermissionIds
        .difference(
      originalPermissionIds,
    )
        .length;
  }

  int get removedPermissionsCount {
    return originalPermissionIds
        .difference(
      selectedPermissionIds,
    )
        .length;
  }

  // =====================================
  // COMPATIBILIDAD CON LA VISTA
  // =====================================

  List<dynamic> get Rols =>
      rols;

  Map<String, dynamic> get Rol =>
      rol;

  Map<String, dynamic> get Summary =>
      summary;
}