import 'package:finanzas_verdes/app/config/Global.dart';
import 'package:finanzas_verdes/app/routes/subrutes/adminRoutes.dart';
import 'package:finanzas_verdes/controllers/PermissionController.dart';
import 'package:finanzas_verdes/controllers/RolController.dart';
import 'package:finanzas_verdes/controllers/UserController.dart';
import 'package:finanzas_verdes/main.dart';
import 'package:finanzas_verdes/models/api/permissionApi.dart';
import 'package:finanzas_verdes/models/api/rolApi.dart';
import 'package:finanzas_verdes/models/api/userApi.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class Homeadmin extends StatefulWidget {
  const Homeadmin({super.key});

  @override
  State<Homeadmin> createState() =>
      _HomeadminState();
}

class _HomeadminState extends State<Homeadmin> {
  late final UserController userController;
  late final RolController rolController;

  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();

    userController =
    Get.isRegistered<UserController>()
        ? Get.find<UserController>()
        : Get.put(UserController());

    rolController =
    Get.isRegistered<RolController>()
        ? Get.find<RolController>()
        : Get.put(RolController());

    _loadDashboard();
  }

  Future<void> _loadDashboard() async {
    if (mounted) {
      setState(() {
        _loading = true;
        _error = null;
      });
    }

    try {
      await Future.wait([
        getUsersApi(
          userController:
          userController,
        ),
        getRolsApi(
          rolController:
          rolController,
        ),
      ]);
    } catch (error) {
      if (mounted) {
        setState(() {
          _error = error
              .toString()
              .replaceFirst(
            'Exception: ',
            '',
          );
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  List<Map<String, dynamic>>
  get _users {
    return userController.Users
        .map<Map<String, dynamic>>(
          (item) =>
      Map<String, dynamic>.from(
        item,
      ),
    )
        .toList();
  }

  List<Map<String, dynamic>>
  get _roles {
    return rolController.Rols
        .map<Map<String, dynamic>>(
          (item) =>
      Map<String, dynamic>.from(
        item,
      ),
    )
        .toList();
  }

  int get _totalPermissions {
    return int.tryParse(rolController.Summary['total_permisos']?.toString() ?? '0',) ?? 0;
  }

  int _summaryValue(String key,) {
    return int.tryParse(
      userController.Summary[key]?.toString() ?? '0',
    ) ?? 0;
  }

  List<Map<String, dynamic>>
  get _incompleteUsers {
    return _users.where(
          (user) {
        final value =
        user["usuarioCompleto"];

        return value == false ||
            value?.toString() ==
                'false';
      },
    ).toList();
  }

  List<Map<String, dynamic>>
  get _usersWithoutRole {
    return _users.where(
          (user) {
        final role =
        user["nombre_rol"]
            ?.toString()
            .trim();

        return role == null ||
            role.isEmpty;
      },
    ).toList();
  }

  Map<String, int>
  get _usersByRole {
    final result = <String, int>{};

    for (final user in _users) {
      final role =
      user["nombre_rol"]
          ?.toString()
          .trim();

      final key =
      role == null || role.isEmpty
          ? 'Sin rol'
          : role;

      result[key] =
          (result[key] ?? 0) + 1;
    }

    final entries =
    result.entries.toList()
      ..sort(
            (a, b) =>
            b.value.compareTo(
              a.value,
            ),
      );

    return Map<String, int>.fromEntries(
      entries,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Obx(
          () {
        final _ =
            controller.isDark.value;

        if (_loading &&
            _users.isEmpty &&
            _roles.isEmpty) {
          return _buildLoading();
        }

        if (_error != null &&
            _users.isEmpty &&
            _roles.isEmpty) {
          return _buildError();
        }

        return RefreshIndicator(
          onRefresh: _loadDashboard,
          color: Global.primary,
          child: LayoutBuilder(
            builder:
                (context, constraints) {
              final isDesktop =
                  constraints.maxWidth >=
                      1000;

              return SingleChildScrollView(
                physics:
                const AlwaysScrollableScrollPhysics(),
                padding:
                const EdgeInsets.only(
                  bottom: 32,
                ),
                child: Center(
                  child: ConstrainedBox(
                    constraints:
                    const BoxConstraints(
                      maxWidth: 1450,
                    ),
                    child: Column(
                      crossAxisAlignment:
                      CrossAxisAlignment
                          .start,
                      children: [
                        _buildHeader(
                          isDesktop,
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        _buildMetrics(
                          isDesktop,
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        if (isDesktop)
                          Row(
                            crossAxisAlignment:
                            CrossAxisAlignment
                                .start,
                            children: [
                              Expanded(
                                flex: 6,
                                child:
                                _buildRoleDistribution(),
                              ),
                              const SizedBox(
                                width: 18,
                              ),
                              Expanded(
                                flex: 4,
                                child:
                                _buildAlerts(),
                              ),
                            ],
                          )
                        else ...[
                          _buildRoleDistribution(),
                          const SizedBox(
                            height: 18,
                          ),
                          _buildAlerts(),
                        ],
                        const SizedBox(
                          height: 20,
                        ),
                        _buildQuickActions(
                          isDesktop,
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        _buildRecentUsers(),
                        SizedBox(height: 50,)
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildLoading() {
    return Center(
      child: Column(
        mainAxisSize:
        MainAxisSize.min,
        children: [
          CircularProgressIndicator(
            color: Global.primary,
          ),
          const SizedBox(height: 14),
          Text(
            'Cargando información administrativa...',
            style: GoogleFonts.poppins(
              fontSize: 12,
              color:
              Global.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildError() {
    return Center(
      child: Container(
        constraints:
        const BoxConstraints(
          maxWidth: 480,
        ),
        padding:
        const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Global.container,
          borderRadius:
          BorderRadius.circular(18),
          border: Border.all(
            color:
            Colors.red.withOpacity(
              0.18,
            ),
          ),
        ),
        child: Column(
          mainAxisSize:
          MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color:
                Colors.red.withOpacity(
                  0.10,
                ),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons
                    .cloud_off_outlined,
                color: Colors.red,
                size: 31,
              ),
            ),
            const SizedBox(height: 15),
            Text(
              'No fue posible cargar el panel',
              textAlign:
              TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight:
                FontWeight.w600,
                color: Global.text,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              _error ??
                  'Ocurrió un error inesperado.',
              textAlign:
              TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 11,
                height: 1.5,
                color:
                Global.textSecondary,
              ),
            ),
            const SizedBox(height: 18),
            FilledButton.icon(
              onPressed:
              _loadDashboard,
              icon: const Icon(
                Icons.refresh_rounded,
              ),
              label:
              const Text('Reintentar'),
              style:
              FilledButton.styleFrom(
                backgroundColor:
                Global.primary,
                foregroundColor:
                Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(
      bool isDesktop,
      ) {
    final userName =
    controller.User[
    "nombre_usuario"]
        ?.toString()
        .trim();

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(
        isDesktop ? 22 : 17,
      ),
      decoration: BoxDecoration(
        color: Global.container,
        borderRadius:
        BorderRadius.circular(20),
        border: Border.all(
          color:
          Global.text.withOpacity(
            0.07,
          ),
        ),
      ),
      child: isDesktop
          ? Row(
        children: [
          Expanded(
            child:
            _buildWelcomeContent(
              userName,
            ),
          ),
          const SizedBox(
            width: 20,
          ),
          _buildPrimaryAction(),
        ],
      )
          : Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          _buildWelcomeContent(
            userName,
          ),
          const SizedBox(
            height: 16,
          ),
          SizedBox(
            width: double.infinity,
            child:
            _buildPrimaryAction(),
          ),
        ],
      ),
    );
  }

  Widget _buildWelcomeContent(
      String? userName,
      ) {
    return Row(
      crossAxisAlignment:
      CrossAxisAlignment.center,
      children: [
        Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            color:
            Global.primary.withOpacity(
              0.11,
            ),
            borderRadius:
            BorderRadius.circular(15),
          ),
          child: Icon(
            Icons
                .space_dashboard_rounded,
            color: Global.primary,
            size: 27,
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment:
            CrossAxisAlignment.start,
            children: [
              Text(
                userName == null ||
                    userName.isEmpty
                    ? 'Panel administrativo'
                    : 'Hola, $userName',
                maxLines: 1,
                overflow:
                TextOverflow.ellipsis,
                style:
                GoogleFonts.poppins(
                  fontSize: 19,
                  fontWeight:
                  FontWeight.w600,
                  color: Global.text,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                'Supervisa usuarios, accesos y configuración del aplicativo.',
                style:
                GoogleFonts.poppins(
                  fontSize: 11.5,
                  height: 1.45,
                  color:
                  Global.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPrimaryAction() {
    return FilledButton.icon(
      onPressed: () {
        controller.setPage(
          Adminroutes.newUser,
        );
      },
      icon: const Icon(
        Icons.person_add_alt_1_rounded,
        size: 19,
      ),
      label: const Text(
        'Nuevo usuario',
      ),
      style: FilledButton.styleFrom(
        backgroundColor:
        Global.primary,
        foregroundColor:
        Colors.white,
        elevation: 0,
        padding:
        const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 15,
        ),
        shape: RoundedRectangleBorder(
          borderRadius:
          BorderRadius.circular(12),
        ),
      ),
    );
  }

  Widget _buildMetrics(bool isDesktop,) {
    final cards = [
      _MetricData(
        title: 'Total de usuarios',
        value:
        _summaryValue(
          'total',
        ).toString(),
        subtitle:
        'Cuentas registradas',
        icon:
        Icons.groups_2_outlined,
        color:
        const Color(0xFF3976D3),
      ),
      _MetricData(
        title: 'Usuarios activos',
        value:
        _summaryValue(
          'activos',
        ).toString(),
        subtitle:
        'Con acceso al sistema',
        icon:
        Icons.verified_user_outlined,
        color:
        const Color(0xFF278568),
      ),
      _MetricData(
        title: 'Usuarios inactivos',
        value:
        _summaryValue(
          'inactivos',
        ).toString(),
        subtitle:
        'Acceso deshabilitado',
        icon:
        Icons.person_off_outlined,
        color:
        const Color(0xFF8A8F98),
      ),
      _MetricData(
        title: 'Usuarios bloqueados',
        value:
        _summaryValue(
          'bloqueados',
        ).toString(),
        subtitle:
        'Requieren revisión',
        icon:
        Icons.lock_person_outlined,
        color:
        const Color(0xFFD45A55),
      ),
      _MetricData(
        title: 'Roles configurados',
        value:
        _roles.length.toString(),
        subtitle:
        'Perfiles de acceso',
        icon:
        Icons
            .admin_panel_settings_outlined,
        color:
        const Color(0xFF7455C6),
      ),
      _MetricData(
        title: 'Permisos disponibles',
        value:
        _totalPermissions.toString(),
        subtitle:
        'Asignables a los roles',
        icon:
        Icons.security_outlined,
        color:
        const Color(0xFF3976D3),
      ),
      _MetricData(
        title: 'Perfiles incompletos',
        value:
        _summaryValue(
          'incompletos',
        ).toString(),
        subtitle:
        'Requieren información',
        icon:
        Icons
            .assignment_late_outlined,
        color:
        _summaryValue(
          'incompletos',
        ) >
            0
            ? const Color(
          0xFFE88725,
        )
            : const Color(
          0xFF278568,
        ),
      ),
      _MetricData(
        title: 'Sin primer ingreso',
        value:
        _summaryValue(
          'sin_primer_ingreso',
        ).toString(),
        subtitle:
        'Nunca han iniciado sesión',
        icon:
        Icons
            .login_outlined,
        color:
        const Color(0xFFCC7A20),
      ),
    ];

    return LayoutBuilder(
      builder: (
          context,
          constraints,
          ) {
        final width =
            constraints.maxWidth;

        final columns =
        width >= 1200
            ? 4
            : width >= 700
            ? 2
            : 1;

        const spacing = 12.0;

        final cardWidth =
        columns == 1
            ? width
            : (
            width -
                (
                    spacing *
                        (columns - 1)
                )
        ) /
            columns;

        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children:
          cards.map(
                (data) {
              return SizedBox(
                width:
                cardWidth,
                child:
                _metricCard(
                  data,
                ),
              );
            },
          ).toList(),
        );
      },
    );
  }

  Widget _metricCard(
      _MetricData data,
      ) {
    return Container(
      constraints:
      const BoxConstraints(
        minHeight: 120,
      ),
      padding:
      const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Global.container,
        borderRadius:
        BorderRadius.circular(17),
        border: Border.all(
          color:
          data.color.withOpacity(
            0.17,
          ),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 47,
            height: 47,
            decoration: BoxDecoration(
              color:
              data.color.withOpacity(
                0.11,
              ),
              borderRadius:
              BorderRadius.circular(
                13,
              ),
            ),
            child: Icon(
              data.icon,
              color: data.color,
              size: 24,
            ),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              mainAxisSize:
              MainAxisSize.min,
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                Text(
                  data.value,
                  style:
                  GoogleFonts.poppins(
                    fontSize: 21,
                    fontWeight:
                    FontWeight.w600,
                    color: Global.text,
                  ),
                ),
                Text(
                  data.title,
                  maxLines: 1,
                  overflow:
                  TextOverflow.ellipsis,
                  style:
                  GoogleFonts.poppins(
                    fontSize: 11,
                    fontWeight:
                    FontWeight.w500,
                    color: Global.text,
                  ),
                ),
                const SizedBox(
                  height: 2,
                ),
                Text(
                  data.subtitle,
                  maxLines: 1,
                  overflow:
                  TextOverflow.ellipsis,
                  style:
                  GoogleFonts.poppins(
                    fontSize: 9.5,
                    color: Global
                        .textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRoleDistribution() {
    final distribution =
        _usersByRole;

    final maxValue =
    distribution.values.isEmpty
        ? 1
        : distribution.values
        .reduce(
          (a, b) =>
      a > b ? a : b,
    );

    return _sectionContainer(
      title:
      'Distribución de usuarios',
      subtitle:
      'Usuarios activos agrupados por rol.',
      icon: Icons
          .donut_large_outlined,
      child: distribution.isEmpty
          ? _emptySection(
        'No hay usuarios para mostrar.',
      )
          : Column(
        children:
        distribution.entries.map(
              (entry) {
            final progress =
                entry.value /
                    maxValue;

            return Padding(
              padding:
              const EdgeInsets.only(
                bottom: 14,
              ),
              child: Column(
                crossAxisAlignment:
                CrossAxisAlignment
                    .start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          entry.key,
                          style:
                          GoogleFonts
                              .poppins(
                            fontSize:
                            11.5,
                            fontWeight:
                            FontWeight
                                .w500,
                            color:
                            Global.text,
                          ),
                        ),
                      ),
                      Text(
                        entry.value
                            .toString(),
                        style:
                        GoogleFonts
                            .poppins(
                          fontSize: 12,
                          fontWeight:
                          FontWeight
                              .w600,
                          color: Global
                              .primary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 7,
                  ),
                  ClipRRect(
                    borderRadius:
                    BorderRadius
                        .circular(
                      20,
                    ),
                    child:
                    LinearProgressIndicator(
                      value: progress,
                      minHeight: 7,
                      backgroundColor:
                      Global.primary
                          .withOpacity(
                        0.08,
                      ),
                      valueColor:
                      AlwaysStoppedAnimation<
                          Color>(
                        Global.primary,
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ).toList(),
      ),
    );
  }

  Widget _buildAlerts() {
    final alerts =
    <_AlertData>[];

    final incomplete =
    _summaryValue(
      'incompletos',
    );

    final withoutRole =
    _summaryValue(
      'sin_rol',
    );

    final blocked =
    _summaryValue(
      'bloqueados',
    );

    final temporarilyLocked =
    _summaryValue(
      'bloqueos_temporales',
    );

    final pendingPasswordChange =
    _summaryValue(
      'cambios_password_pendientes',
    );

    final withoutFirstLogin =
    _summaryValue(
      'sin_primer_ingreso',
    );

    if (blocked > 0) {
      alerts.add(
        _AlertData(
          title:
          'Usuarios bloqueados',
          description:
          '$blocked cuentas están bloqueadas administrativamente.',
          icon:
          Icons.lock_person_outlined,
          color:
          const Color(
            0xFFD45A55,
          ),
          route:
          Adminroutes.users,
        ),
      );
    }

    if (temporarilyLocked > 0) {
      alerts.add(
        _AlertData(
          title:
          'Bloqueos temporales',
          description:
          '$temporarilyLocked cuentas superaron el límite de intentos de acceso.',
          icon:
          Icons.timer_off_outlined,
          color:
          const Color(
            0xFFD45A55,
          ),
          route:
          Adminroutes.users,
        ),
      );
    }

    if (incomplete > 0) {
      alerts.add(
        _AlertData(
          title:
          'Perfiles incompletos',
          description:
          '$incomplete usuarios requieren completar información.',
          icon:
          Icons
              .assignment_late_outlined,
          color:
          const Color(
            0xFFE88725,
          ),
          route:
          Adminroutes.users,
        ),
      );
    }

    if (withoutRole > 0) {
      alerts.add(
        _AlertData(
          title:
          'Usuarios sin rol',
          description:
          '$withoutRole usuarios no tienen un rol asignado.',
          icon:
          Icons
              .manage_accounts_outlined,
          color:
          const Color(
            0xFFD45A55,
          ),
          route:
          Adminroutes.users,
        ),
      );
    }

    if (pendingPasswordChange > 0) {
      alerts.add(
        _AlertData(
          title:
          'Cambio de contraseña pendiente',
          description:
          '$pendingPasswordChange usuarios deben establecer una contraseña definitiva.',
          icon:
          Icons.password_outlined,
          color:
          const Color(
            0xFF7455C6,
          ),
          route:
          Adminroutes.users,
        ),
      );
    }

    if (withoutFirstLogin > 0) {
      alerts.add(
        _AlertData(
          title:
          'Usuarios sin primer ingreso',
          description:
          '$withoutFirstLogin cuentas todavía no han iniciado sesión.',
          icon:
          Icons.login_outlined,
          color:
          const Color(
            0xFF3976D3,
          ),
          route:
          Adminroutes.users,
        ),
      );
    }

    if (_roles.isEmpty) {
      alerts.add(
        const _AlertData(
          title:
          'No hay roles configurados',
          description:
          'Crea al menos un rol para organizar los accesos.',
          icon:
          Icons
              .admin_panel_settings_outlined,
          color:
          Color(
            0xFFE88725,
          ),
          route:
          Adminroutes.rols,
        ),
      );
    }

    if (_totalPermissions == 0) {
      alerts.add(
        const _AlertData(
          title:
          'No hay permisos disponibles',
          description:
          'No existen permisos para asignar a los roles.',
          icon:
          Icons.security_outlined,
          color:
          Color(0xFFE88725),
          route:
          Adminroutes.rols,
        ),
      );
    }

    return _sectionContainer(
      title:
      'Requiere atención',
      subtitle:
      'Situaciones administrativas detectadas en todo el sistema.',
      icon:
      Icons.notifications_none_rounded,
      child:
      alerts.isEmpty
          ? Container(
        width:
        double.infinity,
        padding:
        const EdgeInsets.all(
          16,
        ),
        decoration:
        BoxDecoration(
          color:
          const Color(
            0xFF278568,
          ).withOpacity(
            0.08,
          ),
          borderRadius:
          BorderRadius.circular(
            13,
          ),
          border:
          Border.all(
            color:
            const Color(
              0xFF278568,
            ).withOpacity(
              0.16,
            ),
          ),
        ),
        child:
        Row(
          children: [
            const Icon(
              Icons
                  .check_circle_outline_rounded,
              color:
              Color(
                0xFF278568,
              ),
            ),
            const SizedBox(
              width: 10,
            ),
            Expanded(
              child:
              Text(
                'No se detectaron alertas administrativas.',
                style:
                GoogleFonts.poppins(
                  fontSize:
                  11,
                  color:
                  Global.text,
                ),
              ),
            ),
          ],
        ),
      )
          : Column(
        children:
        alerts.map(
              (alert) {
            return _alertCard(
              alert,
            );
          },
        ).toList(),
      ),
    );
  }

  Widget _alertCard(
      _AlertData alert,
      ) {
    return Container(
      margin:
      const EdgeInsets.only(
        bottom: 10,
      ),
      decoration: BoxDecoration(
        color:
        alert.color.withOpacity(
          0.07,
        ),
        borderRadius:
        BorderRadius.circular(13),
        border: Border.all(
          color:
          alert.color.withOpacity(
            0.15,
          ),
        ),
      ),
      child: InkWell(
        onTap: () {
          controller.setPage(
            alert.route,
          );
        },
        borderRadius:
        BorderRadius.circular(13),
        child: Padding(
          padding:
          const EdgeInsets.all(13),
          child: Row(
            children: [
              Icon(
                alert.icon,
                color: alert.color,
                size: 22,
              ),
              const SizedBox(width: 11),
              Expanded(
                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment
                      .start,
                  children: [
                    Text(
                      alert.title,
                      style:
                      GoogleFonts.poppins(
                        fontSize: 11.5,
                        fontWeight:
                        FontWeight.w600,
                        color: Global.text,
                      ),
                    ),
                    const SizedBox(
                      height: 2,
                    ),
                    Text(
                      alert.description,
                      style:
                      GoogleFonts.poppins(
                        fontSize: 9.5,
                        height: 1.4,
                        color: Global
                            .textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons
                    .chevron_right_rounded,
                color: alert.color,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickActions(
      bool isDesktop,
      ) {
    final actions = [
      const _QuickActionData(
        title: 'Usuarios',
        description:
        'Consulta y administra las cuentas.',
        icon: Icons.people_rounded,
        route: Adminroutes.users,
        color: Color(
          0xFF278568,
        ),
      ),
      const _QuickActionData(
        title:
        'Roles y permisos',
        description:
        'Administra perfiles y accesos del sistema.',
        icon:
        Icons.admin_panel_settings_rounded,
        route:
        Adminroutes.rols,
        color:
        Color(0xFF3976D3),
      ),
      const _QuickActionData(
        title: 'Catálogo',
        description:
        'Supervisa proveedores y productos.',
        icon:
        Icons.inventory_2_rounded,
        route: Adminroutes
            .homeProveedores,
        color: Color(
          0xFFE88725,
        ),
      ),
    ];

    return _sectionContainer(
      title: 'Accesos rápidos',
      subtitle:
      'Ingresa directamente a los módulos administrativos.',
      icon: Icons.bolt_rounded,
      child: Wrap(
        spacing: 12,
        runSpacing: 12,
        children: actions.map(
              (action) {
            return SizedBox(
              width: isDesktop
                  ? 250
                  : double.infinity,
              child: _quickActionCard(
                action,
              ),
            );
          },
        ).toList(),
      ),
    );
  }

  Widget _quickActionCard(
      _QuickActionData action,
      ) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          controller.setPage(
            action.route,
          );
        },
        borderRadius:
        BorderRadius.circular(14),
        child: Container(
          constraints:
          const BoxConstraints(
            minHeight: 100,
          ),
          padding:
          const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color:
            action.color.withOpacity(
              0.06,
            ),
            borderRadius:
            BorderRadius.circular(14),
            border: Border.all(
              color:
              action.color.withOpacity(
                0.14,
              ),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 43,
                height: 43,
                decoration: BoxDecoration(
                  color: action.color
                      .withOpacity(0.12),
                  borderRadius:
                  BorderRadius.circular(
                    12,
                  ),
                ),
                child: Icon(
                  action.icon,
                  color: action.color,
                  size: 22,
                ),
              ),
              const SizedBox(width: 11),
              Expanded(
                child: Column(
                  mainAxisSize:
                  MainAxisSize.min,
                  crossAxisAlignment:
                  CrossAxisAlignment
                      .start,
                  children: [
                    Text(
                      action.title,
                      style:
                      GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight:
                        FontWeight.w600,
                        color: Global.text,
                      ),
                    ),
                    const SizedBox(
                      height: 2,
                    ),
                    Text(
                      action.description,
                      maxLines: 2,
                      overflow:
                      TextOverflow
                          .ellipsis,
                      style:
                      GoogleFonts.poppins(
                        fontSize: 9.5,
                        height: 1.4,
                        color: Global
                            .textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_rounded,
                size: 18,
                color: action.color,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecentUsers() {
    final recentUsers =
    _users.take(5).toList();

    return _sectionContainer(
      title:
      'Usuarios recientes',
      subtitle:
      'Últimas cuentas disponibles en el sistema.',
      icon: Icons
          .person_add_alt_1_outlined,
      trailing: TextButton(
        onPressed: () {
          controller.setPage(
            Adminroutes.users,
          );
        },
        child:
        const Text('Ver todos'),
      ),
      child: recentUsers.isEmpty
          ? _emptySection(
        'No hay usuarios registrados.',
      )
          : Column(
        children:
        recentUsers.map(
              (user) {
            return _recentUserItem(
              user,
            );
          },
        ).toList(),
      ),
    );
  }

  Widget _recentUserItem(
      Map<String, dynamic> user,
      ) {
    final name =
        user["nombre_usuario"]
            ?.toString() ??
            'Usuario sin nombre';

    final email =
        user["email"]?.toString() ??
            'Correo no registrado';

    final role =
        user["nombre_rol"]
            ?.toString() ??
            'Sin rol';

    final complete =
        user["usuarioCompleto"] !=
            false &&
            user["usuarioCompleto"]
                ?.toString() !=
                'false';

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () async {
          final id =
          user["id_usuario"];

          if (id == null) {
            return;
          }

          try {
            final detail =
            await getUserDetailApi(
              idUsuario: int.parse(
                id.toString(),
              ),
            );

            userController.setUser(
              detail,
            );

            controller.setPage(
              Adminroutes.editUser,
            );
          } catch (error) {
            Get.snackbar(
              'No fue posible abrir el usuario',
              error
                  .toString()
                  .replaceFirst(
                'Exception: ',
                '',
              ),
              snackPosition:
              SnackPosition.BOTTOM,
            );
          }
        },
        borderRadius:
        BorderRadius.circular(12),
        child: Container(
          padding:
          const EdgeInsets.symmetric(
            horizontal: 10,
            vertical: 11,
          ),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: Global.text
                    .withOpacity(0.06),
              ),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 39,
                height: 39,
                decoration: BoxDecoration(
                  color: Global.primary
                      .withOpacity(0.10),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.person_rounded,
                  size: 20,
                  color: Global.primary,
                ),
              ),
              const SizedBox(width: 11),
              Expanded(
                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment
                      .start,
                  children: [
                    Text(
                      name,
                      maxLines: 1,
                      overflow:
                      TextOverflow
                          .ellipsis,
                      style:
                      GoogleFonts.poppins(
                        fontSize: 11.5,
                        fontWeight:
                        FontWeight.w600,
                        color: Global.text,
                      ),
                    ),
                    Text(
                      email,
                      maxLines: 1,
                      overflow:
                      TextOverflow
                          .ellipsis,
                      style:
                      GoogleFonts.poppins(
                        fontSize: 9.5,
                        color: Global
                            .textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Container(
                padding:
                const EdgeInsets.symmetric(
                  horizontal: 9,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: Global.primary
                      .withOpacity(0.09),
                  borderRadius:
                  BorderRadius.circular(
                    20,
                  ),
                ),
                child: Text(
                  role,
                  style:
                  GoogleFonts.poppins(
                    fontSize: 9,
                    color: Global.primary,
                  ),
                ),
              ),
              if (!complete) ...[
                const SizedBox(width: 7),
                const Tooltip(
                  message:
                  'Perfil incompleto',
                  child: Icon(
                    Icons
                        .warning_amber_rounded,
                    color: Color(
                      0xFFE88725,
                    ),
                    size: 19,
                  ),
                ),
              ],
              const SizedBox(width: 5),
              Icon(
                Icons
                    .chevron_right_rounded,
                color:
                Global.textSecondary,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionContainer({
    required String title,
    required String subtitle,
    required IconData icon,
    required Widget child,
    Widget? trailing,
  }) {
    return Container(
      width: double.infinity,
      padding:
      const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Global.container,
        borderRadius:
        BorderRadius.circular(18),
        border: Border.all(
          color:
          Global.text.withOpacity(
            0.07,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 39,
                height: 39,
                decoration: BoxDecoration(
                  color: Global.primary
                      .withOpacity(0.10),
                  borderRadius:
                  BorderRadius.circular(
                    11,
                  ),
                ),
                child: Icon(
                  icon,
                  color: Global.primary,
                  size: 21,
                ),
              ),
              const SizedBox(width: 11),
              Expanded(
                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment
                      .start,
                  children: [
                    Text(
                      title,
                      style:
                      GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight:
                        FontWeight.w600,
                        color: Global.text,
                      ),
                    ),
                    Text(
                      subtitle,
                      style:
                      GoogleFonts.poppins(
                        fontSize: 10,
                        color: Global
                            .textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              if (trailing != null)
                trailing,
            ],
          ),
          const SizedBox(height: 17),
          child,
        ],
      ),
    );
  }

  Widget _emptySection(
      String message,
      ) {
    return Container(
      width: double.infinity,
      padding:
      const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color:
        Global.absolute.withOpacity(
          0.35,
        ),
        borderRadius:
        BorderRadius.circular(12),
      ),
      child: Text(
        message,
        textAlign: TextAlign.center,
        style: GoogleFonts.poppins(
          fontSize: 10.5,
          color: Global.textSecondary,
        ),
      ),
    );
  }
}

class _MetricData {
  final String title;
  final String value;
  final String subtitle;
  final IconData icon;
  final Color color;

  const _MetricData({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.icon,
    required this.color,
  });
}

class _AlertData {
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final String route;

  const _AlertData({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    required this.route,
  });
}

class _QuickActionData {
  final String title;
  final String description;
  final IconData icon;
  final String route;
  final Color color;

  const _QuickActionData({
    required this.title,
    required this.description,
    required this.icon,
    required this.route,
    required this.color,
  });
}