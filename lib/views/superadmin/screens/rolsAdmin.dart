import 'package:finanzas_verdes/app/config/Global.dart';
import 'package:finanzas_verdes/controllers/RolController.dart';
import 'package:finanzas_verdes/main.dart';
import 'package:finanzas_verdes/models/api/rolApi.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class Rolsadmin extends StatefulWidget {
  const Rolsadmin({
    super.key,
  });

  @override
  State<Rolsadmin> createState() =>
      _RolsadminState();
}

class _RolsadminState
    extends State<Rolsadmin> {

  late final RolController
  rolController;

  final roleSearchController =
  TextEditingController();

  final permissionSearchController =
  TextEditingController();

  String roleStatusFilter =
      'todos';

  String permissionSearch =
      '';

  String? loadError;

  @override
  void initState() {
    super.initState();

    rolController =
    Get.isRegistered<
        RolController>()
        ? Get.find<
        RolController>()
        : Get.put(
      RolController(),
    );

    _load();
  }

  @override
  void dispose() {
    roleSearchController
        .dispose();

    permissionSearchController
        .dispose();

    super.dispose();
  }

  Future<void> _load() async {

    if (rolController.isLoading.value) return;

    setState(() {
      loadError = null;
    });

    try {
      await getRolsApi(
        rolController:
        rolController,
      );
    } catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        loadError =
            error
                .toString()
                .replaceFirst(
              'Exception: ',
              '',
            );
      });
    }
  }

  int _number(
      dynamic value,
      ) {
    return int.tryParse(
      value?.toString() ??
          '',
    ) ??
        0;
  }

  bool _boolean(
      dynamic value,
      ) {
    return value == true ||
        value
            ?.toString()
            .toLowerCase() ==
            'true';
  }

  List<Map<String, dynamic>>
  get _filteredRoles {
    final search =
    roleSearchController
        .text
        .trim()
        .toLowerCase();

    return rolController.Rols
        .whereType<Map>()
        .map(
          (item) =>
      Map<String, dynamic>.from(
        item,
      ),
    )
        .where(
          (role) {
        final name =
            role['nombre_rol']
                ?.toString()
                .toLowerCase() ??
                '';

        final status =
            role['estado']
                ?.toString()
                .toLowerCase() ??
                '';

        final matchesSearch =
            search.isEmpty ||
                name.contains(
                  search,
                );

        final matchesStatus =
            roleStatusFilter ==
                'todos' ||
                status ==
                    roleStatusFilter;

        return matchesSearch &&
            matchesStatus;
      },
    )
        .toList();
  }

  List<Map<String, dynamic>>
  get _currentPermissions {
    final permissions =
    rolController
        .Rol['permisos'];

    if (permissions is! List) {
      return [];
    }

    return permissions
        .whereType<Map>()
        .map(
          (item) =>
      Map<String, dynamic>.from(
        item,
      ),
    )
        .toList();
  }

  Map<String,
      List<Map<String, dynamic>>>
  get _groupedPermissions {
    final groups = <String,
        List<Map<String, dynamic>>>{};

    for (
    final permission
    in _currentPermissions
    ) {
      final name =
          permission[
          'nombre_permiso']
              ?.toString() ??
              '';

      if (
      permissionSearch
          .trim()
          .isNotEmpty &&
          !name
              .toLowerCase()
              .contains(
            permissionSearch
                .trim()
                .toLowerCase(),
          )
      ) {
        continue;
      }

      final backendModule =
      permission['modulo']
          ?.toString()
          .trim();

      final group =
      backendModule != null &&
          backendModule
              .isNotEmpty
          ? backendModule
          : _permissionGroup(
        name,
      );

      groups.putIfAbsent(
        group,
            () => [],
      );

      groups[group]!.add(
        permission,
      );
    }

    final entries =
    groups.entries.toList()
      ..sort(
            (a, b) =>
            a.key.compareTo(
              b.key,
            ),
      );

    return Map.fromEntries(
      entries,
    );
  }

  String _permissionGroup(
      String name,
      ) {
    final normalized =
    name.toLowerCase();

    if (
    normalized.contains(
      'usuario',
    ) ||
        normalized.contains(
          'contraseña',
        ) ||
        normalized.contains(
          'auditoría usuario',
        )
    ) {
      return 'Usuarios';
    }

    if (
    normalized.contains(
      'rol',
    ) ||
        normalized.contains(
          'permiso',
        )
    ) {
      return 'Roles y permisos';
    }

    if (
    normalized.contains(
      'cliente',
    ) ||
        normalized.contains(
          'mipyme',
        ) ||
        normalized.contains(
          'empresa',
        )
    ) {
      return 'Clientes';
    }

    if (
    normalized.contains(
      'diagnóstico',
    ) ||
        normalized.contains(
          'diagnostico',
        )
    ) {
      return 'Diagnósticos';
    }

    if (
    normalized.contains(
      'activo',
    )
    ) {
      return 'Activos';
    }

    if (
    normalized.contains(
      'factura',
    ) ||
        normalized.contains(
          'consumo',
        )
    ) {
      return 'Facturas y consumos';
    }

    if (
    normalized.contains(
      'calendario',
    ) ||
        normalized.contains(
          'agenda',
        ) ||
        normalized.contains(
          'visita',
        )
    ) {
      return 'Calendario';
    }

    if (
    normalized.contains(
      'catálogo',
    ) ||
        normalized.contains(
          'catalogo',
        ) ||
        normalized.contains(
          'producto',
        ) ||
        normalized.contains(
          'item',
        )
    ) {
      return 'Catálogo';
    }

    if (
    normalized.contains(
      'proveedor',
    )
    ) {
      return 'Proveedores';
    }

    if (
    normalized.contains(
      'plan',
    ) ||
        normalized.contains(
          'tarea',
        )
    ) {
      return 'Planes de trabajo';
    }

    if (
    normalized.contains(
      'reporte',
    ) ||
        normalized.contains(
          'informe',
        )
    ) {
      return 'Reportes';
    }

    return 'Otros';
  }

  @override
  Widget build(
      BuildContext context,
      ) {
    return Obx(
            () {
          final _ = controller.isDark.value;
          return LayoutBuilder(
            builder: (
                context,
                constraints,
                ) {
              final isDesktop =
                  constraints.maxWidth >=
                      1000;

              if (
              rolController
                  .isLoading.value &&
                  rolController
                      .Rols.isEmpty
              ) {
                return _loading();
              }

              if (
              loadError != null &&
                  rolController
                      .Rols.isEmpty
              ) {
                return _error();
              }

              if (isDesktop) {
                return Column(
                  crossAxisAlignment:
                  CrossAxisAlignment
                      .start,
                  children: [
                    _header(
                      isDesktop: true,
                    ),

                    const SizedBox(
                      height: 18,
                    ),

                    _summary(),

                    const SizedBox(
                      height: 18,
                    ),

                    Expanded(
                      child: Row(
                        crossAxisAlignment:
                        CrossAxisAlignment
                            .stretch,
                        children: [
                          SizedBox(
                            width: 350,
                            child:
                            _rolesPanel(
                              scrollable:
                              true,
                            ),
                          ),

                          const SizedBox(
                            width: 18,
                          ),

                          Expanded(
                            child:
                            _detailPanel(
                              scrollable:
                              true,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              }

              return RefreshIndicator(
                onRefresh: _load,
                color:
                Global.primary,
                child:
                SingleChildScrollView(
                  physics:
                  const AlwaysScrollableScrollPhysics(),
                  padding:
                  const EdgeInsets.only(
                    bottom: 90,
                  ),
                  child: Column(
                    crossAxisAlignment:
                    CrossAxisAlignment
                        .start,
                    children: [
                      _header(
                        isDesktop:
                        false,
                      ),

                      const SizedBox(
                        height: 16,
                      ),

                      _summary(),

                      const SizedBox(
                        height: 16,
                      ),

                      _rolesPanel(
                        scrollable:
                        false,
                      ),

                      const SizedBox(
                        height: 16,
                      ),

                      _detailPanel(
                        scrollable:
                        false,
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        }
    );
  }

  Widget _loading() {
    return Center(
      child: Column(
        mainAxisSize:
        MainAxisSize.min,
        children: [
          CircularProgressIndicator(
            color:
            Global.primary,
          ),
          const SizedBox(
            height: 14,
          ),
          Text(
            'Cargando roles y permisos...',
            style:
            GoogleFonts.poppins(
              fontSize: 12,
              color:
              Global.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _error() {
    return Center(
      child: Container(
        constraints:
        const BoxConstraints(
          maxWidth: 460,
        ),
        padding:
        const EdgeInsets.all(
          24,
        ),
        decoration:
        _panelDecoration(),
        child: Column(
          mainAxisSize:
          MainAxisSize.min,
          children: [
            const Icon(
              Icons
                  .cloud_off_outlined,
              color:
              Colors.red,
              size: 40,
            ),
            const SizedBox(
              height: 12,
            ),
            Text(
              loadError ??
                  'No fue posible cargar la información.',
              textAlign:
              TextAlign.center,
              style:
              GoogleFonts.poppins(
                fontSize: 12,
                color:
                Global.text,
              ),
            ),
            const SizedBox(
              height: 16,
            ),
            FilledButton.icon(
              onPressed:
              _load,
              icon:
              const Icon(
                Icons
                    .refresh_rounded,
              ),
              label:
              const Text(
                'Reintentar',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _header({
    required bool isDesktop,
  }) {
    return Container(
      width:
      double.infinity,
      padding:
      EdgeInsets.all(
        isDesktop
            ? 20
            : 16,
      ),
      decoration:
      _panelDecoration(),
      child: isDesktop
          ? Row(
        children: [
          Expanded(
            child:
            _headerText(),
          ),
          const SizedBox(
            width: 16,
          ),
          _refreshButton(),
          const SizedBox(
            width: 9,
          ),
          _newRoleButton(),
        ],
      )
          : Column(
        crossAxisAlignment:
        CrossAxisAlignment
            .start,
        children: [
          _headerText(),
          const SizedBox(
            height: 16,
          ),
          Row(
            children: [
              _refreshButton(),
              const SizedBox(
                width: 8,
              ),
              Expanded(
                child:
                _newRoleButton(),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _headerText() {
    return Row(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration:
          BoxDecoration(
            color:
            Global.primary
                .withOpacity(
              0.11,
            ),
            borderRadius:
            BorderRadius
                .circular(
              14,
            ),
          ),
          child: Icon(
            Icons
                .shield_outlined,
            color:
            Global.primary,
            size: 25,
          ),
        ),
        const SizedBox(
          width: 13,
        ),
        Expanded(
          child: Column(
            crossAxisAlignment:
            CrossAxisAlignment
                .start,
            children: [
              Text(
                'Roles y permisos',
                style:
                GoogleFonts
                    .poppins(
                  fontSize: 18,
                  fontWeight:
                  FontWeight
                      .w600,
                  color:
                  Global.text,
                ),
              ),
              const SizedBox(
                height: 2,
              ),
              Text(
                'Administra los perfiles de acceso y sus acciones disponibles.',
                style:
                GoogleFonts
                    .poppins(
                  fontSize: 10.5,
                  height: 1.45,
                  color:
                  Global
                      .textSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _refreshButton() {
    return IconButton(
      onPressed:
      rolController
          .isLoading.value
          ? null
          : _load,
      tooltip:
      'Actualizar',
      style:
      IconButton.styleFrom(
        backgroundColor:
        Global.bg,
        foregroundColor:
        Global.text,
        side: BorderSide(
          color:
          Global.text
              .withOpacity(
            0.08,
          ),
        ),
      ),
      icon:
      rolController
          .isLoading.value
          ? const SizedBox(
        width: 18,
        height: 18,
        child:
        CircularProgressIndicator(
          strokeWidth:
          2,
        ),
      )
          : const Icon(
        Icons
            .refresh_rounded,
      ),
    );
  }

  Widget _newRoleButton() {
    return FilledButton.icon(
      onPressed:
      _showCreateRoleDialog,
      icon:
      const Icon(
        Icons.add_rounded,
      ),
      label:
      const Text(
        'Nuevo rol',
      ),
      style:
      FilledButton.styleFrom(
        backgroundColor:
        Global.primary,
        foregroundColor:
        Colors.white,
        padding:
        const EdgeInsets
            .symmetric(
          horizontal: 17,
          vertical: 14,
        ),
        shape:
        RoundedRectangleBorder(
          borderRadius:
          BorderRadius
              .circular(
            11,
          ),
        ),
      ),
    );
  }

  Widget _summary() {
    final summary =
        rolController.Summary;

    final items = [
      (
      'Roles',
      _number(
        summary[
        'total_roles'
        ],
      ),
      Icons
          .admin_panel_settings_outlined,
      const Color(
        0xFF3976D3,
      ),
      ),
      (
      'Activos',
      _number(
        summary[
        'roles_activos'
        ],
      ),
      Icons
          .verified_outlined,
      const Color(
        0xFF278568,
      ),
      ),
      (
      'Permisos',
      _number(
        summary[
        'total_permisos'
        ],
      ),
      Icons
          .key_outlined,
      const Color(
        0xFF7455C6,
      ),
      ),
      (
      'Sin permisos',
      _number(
        summary[
        'roles_sin_permisos'
        ],
      ),
      Icons
          .warning_amber_rounded,
      const Color(
        0xFFE88725,
      ),
      ),
    ];

    return LayoutBuilder(
      builder: (
          context,
          constraints,
          ) {
        final columns =
        constraints
            .maxWidth >=
            1000
            ? 4
            : constraints
            .maxWidth >=
            540
            ? 2
            : 1;

        const spacing =
        10.0;

        final width =
        columns == 1
            ? constraints
            .maxWidth
            : (
            constraints
                .maxWidth -
                spacing *
                    (
                        columns -
                            1
                    )
        ) /
            columns;

        return Wrap(
          spacing:
          spacing,
          runSpacing:
          spacing,
          children:
          items.map(
                (item) {
              return SizedBox(
                width: width,
                child: Container(
                  padding:
                  const EdgeInsets
                      .all(
                    14,
                  ),
                  decoration:
                  _panelDecoration(
                    borderColor:
                    item.$4
                        .withOpacity(
                      0.16,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 42,
                        height: 42,
                        decoration:
                        BoxDecoration(
                          color:
                          item.$4
                              .withOpacity(
                            0.10,
                          ),
                          borderRadius:
                          BorderRadius
                              .circular(
                            12,
                          ),
                        ),
                        child:
                        Icon(
                          item.$3,
                          color:
                          item.$4,
                          size: 21,
                        ),
                      ),
                      const SizedBox(
                        width: 11,
                      ),
                      Expanded(
                        child:
                        Column(
                          crossAxisAlignment:
                          CrossAxisAlignment
                              .start,
                          children: [
                            Text(
                              item.$2
                                  .toString(),
                              style:
                              GoogleFonts
                                  .poppins(
                                fontSize:
                                18,
                                fontWeight:
                                FontWeight
                                    .w600,
                                color:
                                Global
                                    .text,
                              ),
                            ),
                            Text(
                              item.$1,
                              style:
                              GoogleFonts
                                  .poppins(
                                fontSize:
                                10,
                                color:
                                Global
                                    .textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ).toList(),
        );
      },
    );
  }

  Widget _rolesPanel({
    required bool scrollable,
  }) {
    final roles =
        _filteredRoles;

    final list =
    roles.isEmpty
        ? _empty(
      'No encontramos roles con estos filtros.',
    )
        : ListView.separated(
      shrinkWrap:
      !scrollable,
      physics:
      scrollable
          ? const BouncingScrollPhysics()
          : const NeverScrollableScrollPhysics(),
      itemCount:
      roles.length,
      separatorBuilder:
          (_, __) =>
      const SizedBox(
        height: 8,
      ),
      itemBuilder:
          (
          context,
          index,
          ) {
        return _roleCard(
          roles[index],
        );
      },
    );

    return Container(
      padding:
      const EdgeInsets.all(
        14,
      ),
      decoration:
      _panelDecoration(),
      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment
            .start,
        mainAxisSize:
        scrollable
            ? MainAxisSize.max
            : MainAxisSize.min,
        children: [
          Text(
            'Roles',
            style:
            GoogleFonts.poppins(
              fontSize: 14,
              fontWeight:
              FontWeight.w600,
              color:
              Global.text,
            ),
          ),

          const SizedBox(
            height: 11,
          ),

          TextField(
            controller:
            roleSearchController,
            onChanged: (_) {
              setState(() {});
            },
            style:
            GoogleFonts.poppins(
              fontSize: 11,
              color:
              Global.text,
            ),
            decoration:
            InputDecoration(
              hintText:
              'Buscar rol...',
              prefixIcon:
              const Icon(
                Icons.search_rounded,
                size: 19,
              ),
              filled: true,
              fillColor:
              Global.bg,
              isDense: true,
              border:
              OutlineInputBorder(
                borderRadius:
                BorderRadius
                    .circular(
                  11,
                ),
                borderSide:
                BorderSide.none,
              ),
            ),
          ),

          const SizedBox(
            height: 9,
          ),

          DropdownButtonFormField<
              String>(
            initialValue:
            roleStatusFilter,
            decoration:
            InputDecoration(
              filled: true,
              fillColor:
              Global.bg,
              isDense: true,
              border:
              OutlineInputBorder(
                borderRadius:
                BorderRadius
                    .circular(
                  11,
                ),
                borderSide:
                BorderSide.none,
              ),
            ),
            items:
            const [
              DropdownMenuItem(
                value:
                'todos',
                child:
                Text(
                  'Todos los estados',
                ),
              ),
              DropdownMenuItem(
                value:
                'activo',
                child:
                Text(
                  'Activos',
                ),
              ),
              DropdownMenuItem(
                value:
                'inactivo',
                child:
                Text(
                  'Inactivos',
                ),
              ),
            ],
            onChanged:
                (value) {
              setState(() {
                roleStatusFilter =
                    value ??
                        'todos';
              });
            },
          ),

          const SizedBox(
            height: 13,
          ),

          if (scrollable)
            Expanded(
              child:
              list,
            )
          else
            list,
        ],
      ),
    );
  }

  Widget _roleCard(
      Map<String, dynamic> role,
      ) {
    final id =
    _number(
      role['id_rol'],
    );

    final selected =
        rolController
            .selectedRoleId
            .value ==
            id;

    final active =
        role['estado']
            ?.toString()
            .toLowerCase() ==
            'activo';

    final administrative =
    _boolean(
      role[
      'es_rol_administrativo'
      ],
    );

    return Material(
      color:
      Colors.transparent,
      child: InkWell(
        onTap: () {
          if (
          rolController
              .hasPermissionChanges
          ) {
            _confirmRoleChange(
              role,
            );
          } else {
            rolController.selectRole(
              role,
            );

            permissionSearchController
                .clear();

            setState(() {
              permissionSearch =
              '';
            });
          }
        },
        borderRadius:
        BorderRadius.circular(
          13,
        ),
        child:
        AnimatedContainer(
          duration:
          const Duration(
            milliseconds: 180,
          ),
          padding:
          const EdgeInsets.all(
            13,
          ),
          decoration:
          BoxDecoration(
            color:
            selected
                ? Global.primary
                .withOpacity(
              0.10,
            )
                : Global.bg,
            borderRadius:
            BorderRadius.circular(
              13,
            ),
            border:
            Border.all(
              color:
              selected
                  ? Global.primary
                  .withOpacity(
                0.45,
              )
                  : Global.text
                  .withOpacity(
                0.06,
              ),
            ),
          ),
          child: Column(
            crossAxisAlignment:
            CrossAxisAlignment
                .start,
            children: [
              Row(
                children: [
                  Container(
                    width: 37,
                    height: 37,
                    decoration:
                    BoxDecoration(
                      color:
                      Global.primary
                          .withOpacity(
                        0.10,
                      ),
                      borderRadius:
                      BorderRadius
                          .circular(
                        10,
                      ),
                    ),
                    child:
                    Icon(
                      administrative
                          ? Icons
                          .shield_outlined
                          : Icons
                          .badge_outlined,
                      size: 19,
                      color:
                      Global.primary,
                    ),
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  Expanded(
                    child:
                    Text(
                      role['nombre_rol']
                          ?.toString() ??
                          'Sin nombre',
                      maxLines:
                      1,
                      overflow:
                      TextOverflow
                          .ellipsis,
                      style:
                      GoogleFonts
                          .poppins(
                        fontSize:
                        11.5,
                        fontWeight:
                        FontWeight
                            .w600,
                        color:
                        Global.text,
                      ),
                    ),
                  ),
                  Container(
                    width: 8,
                    height: 8,
                    decoration:
                    BoxDecoration(
                      color:
                      active
                          ? const Color(
                        0xFF278568,
                      )
                          : const Color(
                        0xFF8A8F98,
                      ),
                      shape:
                      BoxShape
                          .circle,
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 10,
              ),
              Row(
                children: [
                  _miniValue(
                    Icons
                        .people_outline,
                    '${_number(role['total_usuarios'])} usuarios',
                  ),
                  const SizedBox(
                    width: 12,
                  ),
                  _miniValue(
                    Icons
                        .key_outlined,
                    '${_number(role['permisos_asignados'])} permisos',
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _miniValue(
      IconData icon,
      String value,
      ) {
    return Expanded(
      child: Row(
        children: [
          Icon(
            icon,
            size: 14,
            color:
            Global.textSecondary,
          ),
          const SizedBox(
            width: 4,
          ),
          Expanded(
            child:
            Text(
              value,
              maxLines:
              1,
              overflow:
              TextOverflow
                  .ellipsis,
              style:
              GoogleFonts
                  .poppins(
                fontSize:
                8.5,
                color:
                Global
                    .textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _detailPanel({
    required bool scrollable,
  }) {
    if (
    rolController.Rol.isEmpty
    ) {
      return Container(
        padding:
        const EdgeInsets.all(
          24,
        ),
        decoration:
        _panelDecoration(),
        child: _empty(
          'Selecciona un rol para administrar sus permisos.',
        ),
      );
    }

    final body =
    Column(
      crossAxisAlignment:
      CrossAxisAlignment
          .start,
      children: [
        _roleDetailHeader(),

        const SizedBox(
          height: 14,
        ),

        _saveBar(),

        const SizedBox(
          height: 16,
        ),

        TextField(
          controller:
          permissionSearchController,
          onChanged: (value) {
            setState(() {
              permissionSearch =
                  value;
            });
          },
          style:
          GoogleFonts.poppins(
            fontSize: 11,
            color:
            Global.text,
          ),
          decoration:
          InputDecoration(
            hintText:
            'Buscar permiso...',
            prefixIcon:
            const Icon(
              Icons.search_rounded,
              size: 19,
            ),
            suffixIcon:
            permissionSearch
                .isEmpty
                ? null
                : IconButton(
              onPressed: () {
                permissionSearchController
                    .clear();

                setState(() {
                  permissionSearch =
                  '';
                });
              },
              icon:
              const Icon(
                Icons
                    .close_rounded,
                size: 18,
              ),
            ),
            filled: true,
            fillColor:
            Global.bg,
            isDense: true,
            border:
            OutlineInputBorder(
              borderRadius:
              BorderRadius
                  .circular(
                11,
              ),
              borderSide:
              BorderSide.none,
            ),
          ),
        ),

        const SizedBox(
          height: 14,
        ),

        ..._groupedPermissions
            .entries
            .map(
              (entry) =>
              _permissionGroupCard(
                entry.key,
                entry.value,
              ),
        ),

        if (
        _groupedPermissions
            .isEmpty
        )
          _empty(
            'No hay permisos que coincidan con la búsqueda.',
          ),
      ],
    );

    return Container(
      padding:
      const EdgeInsets.all(
        16,
      ),
      decoration:
      _panelDecoration(),
      child:
      scrollable
          ? SingleChildScrollView(
        child:
        body,
      )
          : body,
    );
  }

  Widget _roleDetailHeader() {
    return Obx(
          () {
        final role =
            rolController.rol;

        final bool active =
            role['estado']
                ?.toString()
                .trim()
                .toLowerCase() ==
                'activo';

        final int selectedPermissions =
            rolController
                .selectedPermissionIds
                .length;

        return Row(
          crossAxisAlignment:
          CrossAxisAlignment.start,
          children: [
            Container(
              width: 45,
              height: 45,
              decoration: BoxDecoration(
                color: Global.primary
                    .withOpacity(0.11),
                borderRadius:
                BorderRadius.circular(13),
              ),
              child: Icon(
                Icons
                    .admin_panel_settings_outlined,
                color: Global.primary,
              ),
            ),

            const SizedBox(
              width: 12,
            ),

            Expanded(
              child: Column(
                crossAxisAlignment:
                CrossAxisAlignment.start,
                children: [
                  Text(
                    role['nombre_rol']
                        ?.toString() ??
                        '',
                    style:
                    GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight:
                      FontWeight.w600,
                      color: Global.text,
                    ),
                  ),

                  const SizedBox(
                    height: 4,
                  ),

                  Wrap(
                    spacing: 7,
                    runSpacing: 6,
                    children: [
                      _detailChip(
                        active
                            ? 'Activo'
                            : 'Inactivo',
                        active
                            ? const Color(
                          0xFF278568,
                        )
                            : const Color(
                          0xFF8A8F98,
                        ),
                      ),
                      _detailChip(
                        '${_number(role['total_usuarios'])} usuarios',
                        const Color(
                          0xFF3976D3,
                        ),
                      ),
                      _detailChip(
                        '$selectedPermissions permisos',
                        const Color(
                          0xFF7455C6,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            IconButton(
              onPressed:
              _showEditRoleDialog,
              tooltip:
              'Editar nombre',
              icon: const Icon(
                Icons.edit_outlined,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _detailChip(
      String label,
      Color color,
      ) {
    return Container(
      padding:
      const EdgeInsets
          .symmetric(
        horizontal: 9,
        vertical: 5,
      ),
      decoration:
      BoxDecoration(
        color:
        color.withOpacity(
          0.10,
        ),
        borderRadius:
        BorderRadius
            .circular(
          20,
        ),
      ),
      child:
      Text(
        label,
        style:
        GoogleFonts.poppins(
          fontSize: 8.5,
          fontWeight:
          FontWeight.w500,
          color:
          color,
        ),
      ),
    );
  }

  Widget _permissionGroupCard(
      String group,
      List<Map<String, dynamic>> permissions,
      ) {
    return Obx(
          () {
        final Set<int> activeIds =
        permissions.where(_isPermissionActive).map(
              (permission) => _number(
            permission['id_permiso'],
          ),
        )
            .where(
              (id) => id > 0,
        )
            .toSet();

        final int selectedCount =
            activeIds
                .where(
                  (id) => rolController
                  .selectedPermissionIds
                  .contains(id),
            )
                .length;

        return Container(
          margin: const EdgeInsets.only(
            bottom: 10,
          ),
          decoration: BoxDecoration(
            color: Global.bg,
            borderRadius:
            BorderRadius.circular(13),
            border: Border.all(
              color: Global.text.withOpacity(
                0.07,
              ),
            ),
          ),
          child: ExpansionTile(
            initiallyExpanded: true,
            tilePadding:
            const EdgeInsets.symmetric(
              horizontal: 13,
              vertical: 2,
            ),
            childrenPadding:
            const EdgeInsets.only(
              left: 8,
              right: 8,
              bottom: 10,
            ),
            shape: const Border(),
            collapsedShape:
            const Border(),

            // =================================
            // ENCABEZADO DEL GRUPO
            // =================================

            title: Text(
              group,
              style: GoogleFonts.poppins(
                fontSize: 11.5,
                fontWeight:
                FontWeight.w600,
                color: Global.text,
              ),
            ),

            subtitle: Text(
              '$selectedCount de '
                  '${activeIds.length} seleccionados',
              style: GoogleFonts.poppins(
                fontSize: 8.5,
                color:
                Global.textSecondary,
              ),
            ),

            // =================================
            // ACCIONES DEL GRUPO
            // =================================

            trailing:
            PopupMenuButton<String>(
              tooltip:
              'Acciones del grupo',
              onSelected: (value) {
                if (value == 'select') {
                  rolController
                      .selectPermissions(
                    activeIds,
                  );
                }

                if (value == 'clear') {
                  rolController
                      .removePermissions(
                    activeIds,
                  );
                }
              },
              itemBuilder: (_) =>
              const [
                PopupMenuItem<String>(
                  value: 'select',
                  child: Row(
                    children: [
                      Icon(
                        Icons
                            .done_all_rounded,
                        size: 18,
                      ),
                      SizedBox(
                        width: 9,
                      ),
                      Text(
                        'Seleccionar grupo',
                      ),
                    ],
                  ),
                ),
                PopupMenuItem<String>(
                  value: 'clear',
                  child: Row(
                    children: [
                      Icon(
                        Icons
                            .remove_done_rounded,
                        size: 18,
                      ),
                      SizedBox(
                        width: 9,
                      ),
                      Text(
                        'Limpiar grupo',
                      ),
                    ],
                  ),
                ),
              ],
            ),

            // =================================
            // PERMISOS
            // =================================

            children:
            permissions.map(
                  (permission) {
                final int id =
                _number(
                  permission[
                  'id_permiso'],
                );

                final bool active = _isPermissionActive(permission,);

                final bool selected =
                rolController
                    .selectedPermissionIds
                    .contains(id);

                return CheckboxListTile(
                  key: ValueKey(
                    'permission_${id}_$selected',
                  ),
                  value: selected,
                  onChanged:
                  active && id > 0
                      ? (_) {
                    rolController
                        .togglePermission(
                      id,
                    );
                  }
                      : null,
                  dense: true,
                  contentPadding:
                  const EdgeInsets
                      .symmetric(
                    horizontal: 6,
                  ),
                  controlAffinity:
                  ListTileControlAffinity
                      .leading,
                  activeColor:
                  Global.primary,
                  checkColor:
                  Colors.white,
                  title: Text(
                    permission[
                    'nombre_permiso']
                        ?.toString() ??
                        'Permiso',
                    style:
                    GoogleFonts.poppins(
                      fontSize: 10,
                      fontWeight:
                      FontWeight.w500,
                      color: active
                          ? Global.text
                          : Global
                          .textSecondary,
                    ),
                  ),
                  subtitle: active
                      ? null
                      : Text(
                    'Permiso inactivo',
                    style: GoogleFonts
                        .poppins(
                      fontSize: 8,
                      color:
                      Colors.red,
                    ),
                  ),
                );
              },
            ).toList(),
          ),
        );
      },
    );
  }

  Widget _saveBar() {
    return Obx(
          () {
        /*
       * Estas lecturas se hacen dentro
       * del Obx para que GetX registre
       * correctamente las dependencias.
       */
        final int selectedCount =
            rolController
                .selectedPermissionIds
                .length;

        final int originalCount =
            rolController
                .originalPermissionIds
                .length;

        final bool saving =
            rolController
                .isSaving
                .value;

        final bool changed =
            selectedCount !=
                originalCount ||
                !rolController
                    .selectedPermissionIds
                    .containsAll(
                  rolController
                      .originalPermissionIds,
                );

        final int addedCount =
            rolController
                .selectedPermissionIds
                .difference(
              rolController
                  .originalPermissionIds,
            )
                .length;

        final int removedCount =
            rolController
                .originalPermissionIds
                .difference(
              rolController
                  .selectedPermissionIds,
            )
                .length;

        return AnimatedContainer(
          duration: const Duration(
            milliseconds: 180,
          ),
          padding: const EdgeInsets.all(
            13,
          ),
          decoration: BoxDecoration(
            color: changed
                ? Global.primary
                .withOpacity(0.08)
                : Global.bg,
            borderRadius:
            BorderRadius.circular(13),
            border: Border.all(
              color: changed
                  ? Global.primary
                  .withOpacity(0.28)
                  : Global.text
                  .withOpacity(0.06),
            ),
          ),
          child: LayoutBuilder(
            builder: (
                context,
                constraints,
                ) {
              final bool compact =
                  constraints.maxWidth <
                      550;

              final information =
              Column(
                crossAxisAlignment:
                CrossAxisAlignment.start,
                children: [
                  Text(
                    changed
                        ? 'Cambios pendientes'
                        : 'Configuración guardada',
                    style:
                    GoogleFonts.poppins(
                      fontSize: 10.5,
                      fontWeight:
                      FontWeight.w600,
                      color: Global.text,
                    ),
                  ),
                  if (changed)
                    Text(
                      '$addedCount agregados · '
                          '$removedCount retirados',
                      style:
                      GoogleFonts.poppins(
                        fontSize: 8.5,
                        color: Global
                            .textSecondary,
                      ),
                    ),
                ],
              );

              final actions =
              Row(
                mainAxisSize:
                MainAxisSize.min,
                children: [
                  OutlinedButton(
                    onPressed: changed &&
                        !saving
                        ? rolController
                        .discardPermissionChanges
                        : null,
                    child: const Text(
                      'Descartar',
                    ),
                  ),

                  const SizedBox(
                    width: 8,
                  ),

                  FilledButton.icon(
                    onPressed: changed &&
                        !saving
                        ? _showSaveDialog
                        : null,
                    icon: saving
                        ? const SizedBox(
                      width: 16,
                      height: 16,
                      child:
                      CircularProgressIndicator(
                        strokeWidth: 2,
                        color:
                        Colors.white,
                      ),
                    )
                        : const Icon(
                      Icons
                          .save_outlined,
                      size: 18,
                    ),
                    label: Text(
                      saving
                          ? 'Guardando...'
                          : 'Guardar',
                    ),
                    style:
                    FilledButton.styleFrom(
                      backgroundColor:
                      Global.primary,
                      foregroundColor:
                      Colors.white,
                    ),
                  ),
                ],
              );

              if (compact) {
                return Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,
                  children: [
                    information,

                    const SizedBox(
                      height: 11,
                    ),

                    SizedBox(
                      width:
                      double.infinity,
                      child: actions,
                    ),
                  ],
                );
              }

              return Row(
                children: [
                  Expanded(
                    child: information,
                  ),
                  actions,
                ],
              );
            },
          ),
        );
      },
    );
  }

  Future<void>
  _confirmRoleChange(
      Map<String, dynamic> role,
      ) async {
    final discard =
    await Get.dialog<bool>(
      AlertDialog(
        backgroundColor:
        Global.container,
        surfaceTintColor:
        Colors.transparent,
        title:
        const Text(
          'Cambios sin guardar',
        ),
        content:
        const Text(
          'Si cambias de rol perderás las modificaciones pendientes.',
        ),
        actions: [
          TextButton(
            onPressed: () =>
                Get.back(
                  result:
                  false,
                ),
            child:
            const Text(
              'Continuar editando',
            ),
          ),
          FilledButton(
            onPressed: () =>
                Get.back(
                  result:
                  true,
                ),
            child:
            const Text(
              'Descartar',
            ),
          ),
        ],
      ),
      barrierDismissible:
      false,
    );

    if (
    discard == true
    ) {
      rolController.selectRole(
        role,
      );

      permissionSearchController
          .clear();

      setState(() {
        permissionSearch =
        '';
      });
    }
  }

  Future<void>
  _showSaveDialog() async {
    final reasonController =
    TextEditingController();

    String? error;
    bool saving = false;

    await Get.dialog(
      StatefulBuilder(
        builder:
            (
            context,
            setDialogState,
            ) {
          return AlertDialog(
            backgroundColor:
            Global.container,
            surfaceTintColor:
            Colors.transparent,
            title:
            const Text(
              'Confirmar cambios',
            ),
            content:
            SizedBox(
              width: 460,
              child:
              Column(
                mainAxisSize:
                MainAxisSize.min,
                crossAxisAlignment:
                CrossAxisAlignment
                    .start,
                children: [
                  Text(
                    '${rolController.addedPermissionsCount} permisos agregados\n'
                        '${rolController.removedPermissionsCount} permisos retirados\n'
                        '${_number(rolController.Rol['total_usuarios'])} usuarios afectados',
                    style:
                    GoogleFonts
                        .poppins(
                      fontSize: 11,
                      height: 1.6,
                      color:
                      Global.text,
                    ),
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                  TextField(
                    controller:
                    reasonController,
                    maxLines: 3,
                    decoration:
                    const InputDecoration(
                      labelText:
                      'Motivo del cambio',
                      hintText:
                      'Explique brevemente la razón...',
                      border:
                      OutlineInputBorder(),
                    ),
                  ),
                  if (error !=
                      null) ...[
                    const SizedBox(
                      height: 10,
                    ),
                    Text(
                      error!,
                      style:
                      GoogleFonts
                          .poppins(
                        fontSize: 10,
                        color:
                        Colors.red,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed:
                saving
                    ? null
                    : Get.back,
                child:
                const Text(
                  'Cancelar',
                ),
              ),
              FilledButton(
                onPressed:
                saving
                    ? null
                    : () async {
                  if (reasonController
                      .text
                      .trim()
                      .length <
                      5) {
                    setDialogState(
                          () {
                        error =
                        'El motivo debe tener al menos 5 caracteres.';
                      },
                    );

                    return;
                  }

                  setDialogState(
                        () {
                      saving =
                      true;
                      error =
                      null;
                    },
                  );

                  try {
                    await replaceRolePermissionsApi(
                      idRol: rolController.selectedRoleId.value!,
                      permissionIds: rolController.selectedPermissionIds,
                      motivo: reasonController.text,
                      rolController: rolController,
                    );
                    rolController.confirmPermissionChanges();

                    if (
                    Get.isDialogOpen ==
                        true
                    ) {
                      Get.back();
                    }

                    Get.snackbar(
                      'Cambios guardados',
                      'Los permisos del rol fueron actualizados.',
                      snackPosition:
                      SnackPosition.BOTTOM,
                    );
                  } catch (exception) {
                    setDialogState(
                          () {
                        saving =
                        false;
                        error =
                            exception
                                .toString()
                                .replaceFirst(
                              'Exception: ',
                              '',
                            );
                      },
                    );
                  }
                },
                child:
                const Text(
                  'Confirmar',
                ),
              ),
            ],
          );
        },
      ),
      barrierDismissible:
      false,
    );

    reasonController
        .dispose();
  }

  Future<void>
  _showCreateRoleDialog() async {
    final nameController =
    TextEditingController();

    final formKey =
    GlobalKey<FormState>();

    bool saving = false;
    String? error;

    await Get.dialog(
      StatefulBuilder(
        builder:
            (
            context,
            setDialogState,
            ) {
          return AlertDialog(
            backgroundColor:
            Global.container,
            surfaceTintColor:
            Colors.transparent,
            title:
            const Text(
              'Nuevo rol',
            ),
            content:
            SizedBox(
              width: 430,
              child:
              Form(
                key:
                formKey,
                child:
                Column(
                  mainAxisSize:
                  MainAxisSize.min,
                  children: [
                    TextFormField(
                      controller:
                      nameController,
                      autofocus:
                      true,
                      decoration:
                      const InputDecoration(
                        labelText:
                        'Nombre del rol',
                        prefixIcon:
                        Icon(
                          Icons
                              .badge_outlined,
                        ),
                        border:
                        OutlineInputBorder(),
                      ),
                      validator:
                          (value) {
                        final name =
                            value
                                ?.trim() ??
                                '';

                        if (
                        name.isEmpty
                        ) {
                          return 'El nombre es obligatorio';
                        }

                        if (
                        name.length <
                            3
                        ) {
                          return 'Debe tener al menos 3 caracteres';
                        }

                        return null;
                      },
                    ),
                    if (error !=
                        null) ...[
                      const SizedBox(
                        height: 10,
                      ),
                      Text(
                        error!,
                        style:
                        const TextStyle(
                          color:
                          Colors.red,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed:
                saving
                    ? null
                    : Get.back,
                child:
                const Text(
                  'Cancelar',
                ),
              ),
              FilledButton(
                onPressed:
                saving
                    ? null
                    : () async {
                  if (
                  !formKey
                      .currentState!
                      .validate()
                  ) {
                    return;
                  }

                  setDialogState(
                        () {
                      saving =
                      true;
                      error =
                      null;
                    },
                  );

                  try {
                    await newRolApi(
                      nombre:
                      nameController.text.trim(),
                      rolController:
                      rolController,
                    );

                    if (
                    Get.isDialogOpen ==
                        true
                    ) {
                      Get.back();
                    }

                    Get.snackbar(
                      'Rol creado',
                      'El nuevo rol ya está disponible.',
                      snackPosition:
                      SnackPosition.BOTTOM,
                    );
                  } catch (exception) {
                    setDialogState(
                          () {
                        saving =
                        false;
                        error =
                            exception
                                .toString()
                                .replaceFirst(
                              'Exception: ',
                              '',
                            );
                      },
                    );
                  }
                },
                child:
                saving
                    ? const SizedBox(
                  width:
                  17,
                  height:
                  17,
                  child:
                  CircularProgressIndicator(
                    strokeWidth:
                    2,
                    color:
                    Colors.white,
                  ),
                )
                    : const Text(
                  'Crear rol',
                ),
              ),
            ],
          );
        },
      ),
      barrierDismissible:
      false,
    );

    nameController
        .dispose();
  }

  Future<void>
  _showEditRoleDialog() async {
    final role =
        rolController.Rol;

    final id =
    _number(
      role['id_rol'],
    );

    final nameController =
    TextEditingController(
      text:
      role['nombre_rol']
          ?.toString() ??
          '',
    );

    bool saving = false;
    String? error;

    await Get.dialog(
      StatefulBuilder(
        builder:
            (
            context,
            setDialogState,
            ) {
          return AlertDialog(
            backgroundColor:
            Global.container,
            surfaceTintColor:
            Colors.transparent,
            title:
            const Text(
              'Editar rol',
            ),
            content:
            SizedBox(
              width: 430,
              child:
              Column(
                mainAxisSize:
                MainAxisSize.min,
                children: [
                  TextField(
                    controller:
                    nameController,
                    decoration:
                    const InputDecoration(
                      labelText:
                      'Nombre del rol',
                      prefixIcon:
                      Icon(
                        Icons
                            .badge_outlined,
                      ),
                      border:
                      OutlineInputBorder(),
                    ),
                  ),
                  if (error !=
                      null) ...[
                    const SizedBox(
                      height: 10,
                    ),
                    Text(
                      error!,
                      style:
                      const TextStyle(
                        color:
                        Colors.red,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed:
                saving
                    ? null
                    : Get.back,
                child:
                const Text(
                  'Cancelar',
                ),
              ),
              FilledButton(
                onPressed:
                saving
                    ? null
                    : () async {
                  final name =
                  nameController
                      .text
                      .trim();

                  if (
                  name.length <
                      3
                  ) {
                    setDialogState(
                          () {
                        error =
                        'El nombre debe tener al menos 3 caracteres.';
                      },
                    );

                    return;
                  }

                  setDialogState(
                        () {
                      saving =
                      true;
                      error =
                      null;
                    },
                  );

                  try {
                    await editRolApi(
                      id:
                      id,
                      nombre:
                      name,
                      rolController:
                      rolController,
                    );

                    if (
                    Get.isDialogOpen ==
                        true
                    ) {
                      Get.back();
                    }
                  } catch (exception) {
                    setDialogState(
                          () {
                        saving =
                        false;
                        error =
                            exception
                                .toString()
                                .replaceFirst(
                              'Exception: ',
                              '',
                            );
                      },
                    );
                  }
                },
                child:
                const Text(
                  'Guardar',
                ),
              ),
            ],
          );
        },
      ),
      barrierDismissible:
      false,
    );

    nameController
        .dispose();
  }

  Widget _empty(
      String message,
      ) {
    return Padding(
      padding:
      const EdgeInsets
          .symmetric(
        vertical: 28,
      ),
      child:
      Center(
        child:
        Column(
          mainAxisSize:
          MainAxisSize.min,
          children: [
            Icon(
              Icons
                  .inbox_outlined,
              size: 35,
              color:
              Global.textSecondary,
            ),
            const SizedBox(
              height: 8,
            ),
            Text(
              message,
              textAlign:
              TextAlign.center,
              style:
              GoogleFonts.poppins(
                fontSize: 10,
                color:
                Global.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  BoxDecoration _panelDecoration({
    Color? borderColor,
  }) {
    return BoxDecoration(
      color:
      Global.container,
      borderRadius:
      BorderRadius.circular(
        17,
      ),
      border:
      Border.all(
        color:
        borderColor ??
            Global.text
                .withOpacity(
              0.07,
            ),
      ),
    );
  }

  bool _isPermissionActive(
      Map<String, dynamic> permission,
      ) {
    final value =
        permission['estado_permiso'] ??
            permission['estado'];

    /*
   * Si el backend no devuelve estado,
   * se considera activo porque el permiso
   * aparece en el catálogo disponible.
   */
    if (value == null) {
      return true;
    }

    if (value == true ||
        value == 1) {
      return true;
    }

    final normalized =
    value
        .toString()
        .trim()
        .toLowerCase();

    return normalized == 'activo' ||
        normalized == 'active' ||
        normalized == 'true' ||
        normalized == '1';
  }
}