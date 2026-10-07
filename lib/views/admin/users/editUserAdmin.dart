import 'package:finanzas_verdes/app/config/Global.dart';
import 'package:finanzas_verdes/app/routes/subrutes/adminRoutes.dart';
import 'package:finanzas_verdes/controllers/ProveedorController.dart';
import 'package:finanzas_verdes/controllers/RolController.dart';
import 'package:finanzas_verdes/controllers/UserController.dart';
import 'package:finanzas_verdes/main.dart';
import 'package:finanzas_verdes/models/api/proveedorApi.dart';
import 'package:finanzas_verdes/models/api/rolApi.dart';
import 'package:finanzas_verdes/models/api/userApi.dart';
import 'package:finanzas_verdes/utils/WidgetsApp.dart';
import 'package:finanzas_verdes/views/admin/users/widgets/userAuditPanel.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class Edituseradmin
    extends StatefulWidget {
  const Edituseradmin({
    super.key,
  });

  @override
  State<Edituseradmin>
  createState() =>
      _EdituseradminState();
}

class _EdituseradminState
    extends State<Edituseradmin> {
  final formKey =
  GlobalKey<FormState>();

  final UserController userController =
  Get.find<UserController>();

  final RolController rolController =
  Get.put(RolController());

  final ProveedorController
  proveedorController =
  Get.put(ProveedorController());

  final documentoCtrl =
  TextEditingController();

  final nombreCtrl =
  TextEditingController();

  final emailCtrl =
  TextEditingController();

  final telefonoCtrl =
  TextEditingController();

  final nombreCargoCtrl =
  TextEditingController();

  final sedeCtrl =
  TextEditingController();

  final razonSocialCtrl =
  TextEditingController();

  final nitCtrl =
  TextEditingController();

  final direccionCtrl =
  TextEditingController();

  final calificacionCtrl =
  TextEditingController();

  static const int rolAsesor = 3;
  static const int rolProveedor = 4;

  int selectedTab = 0;
  int? selectedRol;

  bool loading = false;
  bool loadingReferences = true;

  @override
  void initState() {
    super.initState();

    _initializeForm();

    WidgetsBinding.instance
        .addPostFrameCallback((_) {
      _loadReferences();
    });
  }

  void _initializeForm() {
    final user =
    Map<String, dynamic>.from(
      userController.User,
    );

    documentoCtrl.text =
        user['documento']
            ?.toString() ??
            '';

    nombreCtrl.text =
        user['nombre_usuario']
            ?.toString() ??
            '';

    emailCtrl.text =
        user['email']
            ?.toString() ??
            '';

    telefonoCtrl.text =
        user['telefono']
            ?.toString() ??
            '';

    final role =
    user['rol'] is Map
        ? Map<String, dynamic>.from(
      user['rol'],
    )
        : <String, dynamic>{};

    selectedRol =
        _toIntOrNull(
          role['id_rol'] ??
              user['id_rol'],
        );

    final extra =
    user['extra'] is Map
        ? Map<String, dynamic>.from(
      user['extra'],
    )
        : <String, dynamic>{};

    nombreCargoCtrl.text =
        extra['nombre_cargo']
            ?.toString() ??
            '';

    sedeCtrl.text =
        extra['sede']
            ?.toString() ??
            '';

    razonSocialCtrl.text =
        extra['razon_social']
            ?.toString() ??
            '';

    nitCtrl.text =
        extra['nit']
            ?.toString() ??
            '';

    direccionCtrl.text =
        extra['direccion']
            ?.toString() ??
            '';

    calificacionCtrl.text =
        extra['calificacion']
            ?.toString() ??
            '';

    final rawTypes =
    extra['tipos_proveedor'];

    userController
        .tiposProveedor
        .clear();

    if (rawTypes is List) {
      final typeIds =
      rawTypes
          .map(_toIntOrNull)
          .whereType<int>()
          .toList();

      userController
          .tiposProveedor
          .assignAll(typeIds);
    }
  }

  Future<void> _loadReferences() async {
    try {
      await Future.wait([
        getRolsApi(
          rolController:
          rolController,
        ),
        getTipoProveedoresApi(
          proveedorController:
          proveedorController,
        ),
      ]);
    } catch (error) {
      Get.snackbar(
        'Información incompleta',
        'No fue posible cargar todos los datos auxiliares.',
        snackPosition:
        SnackPosition.BOTTOM,
      );
    } finally {
      if (mounted) {
        setState(() {
          loadingReferences = false;
        });
      }
    }
  }

  @override
  void dispose() {
    documentoCtrl.dispose();
    nombreCtrl.dispose();
    emailCtrl.dispose();
    telefonoCtrl.dispose();

    nombreCargoCtrl.dispose();
    sedeCtrl.dispose();

    razonSocialCtrl.dispose();
    nitCtrl.dispose();
    direccionCtrl.dispose();
    calificacionCtrl.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context,) {
    final screenWidth = MediaQuery.sizeOf(context,).width;

    final isMobile = screenWidth < 800;

    return Obx(() {
      final _ = controller.isDark.value;
      return SingleChildScrollView(
        physics: AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.only(
          bottom:
          isMobile
              ? 120
              : 24,
        ),
        child: Column(
          crossAxisAlignment:
          CrossAxisAlignment.start,
          children: [
            _header(isMobile,),
            SizedBox(height: 18,),
            _userSummary(),
            SizedBox(height: 18,),
            _tabs(),
            SizedBox(height: 16,),

            AnimatedSwitcher(
              duration:
              const Duration(
                milliseconds: 180,
              ),
              child:
              _currentContent(),
            ),
          ],
        ),
      );
    });
  }

  Widget _header(
      bool isMobile,
      ) {
    return Row(
      children: [
        IconButton(
          tooltip:
          'Volver',
          onPressed: () {
            controller.setPage(
              Adminroutes.users,
            );
          },
          icon:
          const Icon(
            Icons.arrow_back_rounded,
          ),
        ),

        const SizedBox(
          width: 4,
        ),

        Expanded(
          child: Column(
            crossAxisAlignment:
            CrossAxisAlignment.start,
            children: [
              Text(
                'Detalle del usuario',
                style:
                GoogleFonts.poppins(
                  color:
                  Global.text,
                  fontSize: isMobile
                      ? 17
                      : 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                'Información, seguridad e historial.',
                style:
                GoogleFonts.poppins(
                  color:
                  Global.textSecondary,
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ),

        if (selectedTab == 0)
          ElevatedButton.icon(
            onPressed:
            loading
                ? null
                : _submit,
            icon:
            loading
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
              isMobile
                  ? 'Guardar'
                  : 'Guardar cambios',
            ),
            style:
            ElevatedButton.styleFrom(
              backgroundColor:
              Global.primary,
              foregroundColor:
              Colors.white,
              elevation: 0,
              shape:
              RoundedRectangleBorder(
                borderRadius:
                BorderRadius.circular(
                  12,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _userSummary() {
    return Obx(() {
      final user =
      Map<String, dynamic>.from(
        userController.User,
      );

      final name =
          user['nombre_usuario']
              ?.toString() ??
              'Usuario';

      final role =
      user['rol'] is Map
          ? Map<String, dynamic>.from(
        user['rol'],
      )
          : <String, dynamic>{};

      return Container(
        width: double.infinity,
        padding:
        const EdgeInsets.all(18),
        decoration:
        BoxDecoration(
          color:
          Global.container,
          borderRadius:
          BorderRadius.circular(18),
          border:
          Border.all(
            color: Global.text
                .withOpacity(0.08),
          ),
        ),
        child: Wrap(
          spacing: 16,
          runSpacing: 14,
          crossAxisAlignment:
          WrapCrossAlignment.center,
          children: [
            CircleAvatar(
              radius: 28,
              backgroundColor:
              Global.primary
                  .withOpacity(
                0.12,
              ),
              child: Text(
                name.isNotEmpty
                    ? name[0]
                    .toUpperCase()
                    : '?',
                style:
                GoogleFonts.poppins(
                  color:
                  Global.primary,
                  fontSize: 20,
                  fontWeight:
                  FontWeight.w700,
                ),
              ),
            ),

            ConstrainedBox(
              constraints:
              const BoxConstraints(
                minWidth: 180,
                maxWidth: 420,
              ),
              child: Column(
                crossAxisAlignment:
                CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style:
                    GoogleFonts.poppins(
                      color:
                      Global.text,
                      fontSize: 16,
                      fontWeight:
                      FontWeight.w700,
                    ),
                  ),
                  Text(
                    user['email']
                        ?.toString() ??
                        'Sin correo',
                    style:
                    GoogleFonts.poppins(
                      color: Global
                          .textSecondary,
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ),

            _summaryChip(
              Icons.badge_outlined,
              role['nombre_rol']
                  ?.toString() ??
                  'Sin rol',
              Global.primary,
            ),

            _summaryChip(
              Icons
                  .verified_user_outlined,
              _capitalize(
                user['estado_acceso']
                    ?.toString() ??
                    'activo',
              ),
              _statusColor(
                user['estado_acceso']
                    ?.toString() ??
                    'activo',
              ),
            ),

            _summaryChip(
              Icons
                  .account_tree_outlined,
              'Proceso: ${_capitalize(
                user['estado']
                    ?.toString() ??
                    'Sin estado',
              )}',
              const Color(
                0xFF3578D4,
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _tabs() {
    final tabs = [
      (
      'Información',
      Icons.person_outline_rounded,
      ),
      (
      'Seguridad',
      Icons.security_rounded,
      ),
      (
      'Actividad',
      Icons.history_rounded,
      ),
    ];

    return SingleChildScrollView(
      scrollDirection:
      Axis.horizontal,
      child: Row(
        children:
        List.generate(
          tabs.length,
              (index) {
            final selected =
                selectedTab == index;

            return Padding(
              padding:
              const EdgeInsets.only(
                right: 8,
              ),
              child: InkWell(
                onTap: () {
                  setState(() {
                    selectedTab = index;
                  });
                },
                borderRadius:
                BorderRadius.circular(
                  12,
                ),
                child:
                AnimatedContainer(
                  duration:
                  const Duration(
                    milliseconds: 160,
                  ),
                  padding:
                  const EdgeInsets
                      .symmetric(
                    horizontal: 16,
                    vertical: 11,
                  ),
                  decoration:
                  BoxDecoration(
                    color:
                    selected
                        ? Global.primary
                        .withOpacity(
                      0.12,
                    )
                        : Global
                        .container,
                    borderRadius:
                    BorderRadius
                        .circular(
                      12,
                    ),
                    border:
                    Border.all(
                      color: selected
                          ? Global.primary
                          : Global.text
                          .withOpacity(
                        0.08,
                      ),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        tabs[index].$2,
                        size: 18,
                        color: selected
                            ? Global.primary
                            : Global
                            .textSecondary,
                      ),
                      const SizedBox(
                        width: 7,
                      ),
                      Text(
                        tabs[index].$1,
                        style:
                        GoogleFonts.poppins(
                          color: selected
                              ? Global.primary
                              : Global.text,
                          fontSize: 11,
                          fontWeight:
                          selected
                              ? FontWeight
                              .w600
                              : FontWeight
                              .w400,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _currentContent() {
    switch (selectedTab) {
      case 1:
        return Container(
          key: const ValueKey(
            'security',
          ),
          child:
          _securityPanel(),
        );

      case 2:
        return Container(
          key: const ValueKey(
            'audit',
          ),
          padding:
          const EdgeInsets.all(18),
          decoration:
          _panelDecoration(),
          child:
          UserAuditPanel(
            idUsuario:
            _toIntOrNull(
              userController.User[
              'id_usuario'],
            ) ??
                0,
          ),
        );

      default:
        return Container(
          key: const ValueKey(
            'information',
          ),
          child:
          _informationForm(),
        );
    }
  }

  Widget _informationForm() {
    return Container(
      width: double.infinity,
      padding:
      const EdgeInsets.all(18),
      decoration:
      _panelDecoration(),
      child: Form(
        key:
        formKey,
        child: LayoutBuilder(
          builder: (
              context,
              constraints,
              ) {
            final fieldWidth =
            constraints.maxWidth >=
                800
                ? (
                constraints
                    .maxWidth -
                    14
            ) /
                2
                : constraints
                .maxWidth;

            return Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                _sectionTitle(
                  'Información básica',
                  'Datos de identificación y contacto.',
                ),

                const SizedBox(
                  height: 18,
                ),

                Wrap(
                  spacing: 14,
                  runSpacing: 14,
                  children: [
                    SizedBox(
                      width: fieldWidth,
                      child: _input(
                        documentoCtrl,
                        'Documento',
                        Icons
                            .badge_outlined,
                      ),
                    ),
                    SizedBox(
                      width: fieldWidth,
                      child: _input(
                        nombreCtrl,
                        'Nombre del usuario',
                        Icons
                            .person_outline_rounded,
                      ),
                    ),
                    SizedBox(
                      width: fieldWidth,
                      child: _input(
                        emailCtrl,
                        'Correo electrónico',
                        Icons
                            .email_outlined,
                        keyboardType:
                        TextInputType
                            .emailAddress,
                      ),
                    ),
                    SizedBox(
                      width: fieldWidth,
                      child: _input(
                        telefonoCtrl,
                        'Teléfono',
                        Icons
                            .phone_outlined,
                        required: false,
                        keyboardType:
                        TextInputType
                            .phone,
                      ),
                    ),
                  ],
                ),

                const SizedBox(
                  height: 24,
                ),

                _sectionTitle(
                  'Rol y perfil',
                  'Define las responsabilidades y datos adicionales.',
                ),

                const SizedBox(
                  height: 18,
                ),

                if (loadingReferences)
                  LinearProgressIndicator(
                    color:
                    Global.primary,
                  )
                else
                  _roleField(),

                if (
                selectedRol ==
                    rolAsesor
                ) ...[
                  const SizedBox(
                    height: 14,
                  ),

                  Wrap(
                    spacing: 14,
                    runSpacing: 14,
                    children: [
                      SizedBox(
                        width:
                        fieldWidth,
                        child: _input(
                          nombreCargoCtrl,
                          'Nombre del cargo',
                          Icons
                              .work_outline_rounded,
                        ),
                      ),
                      SizedBox(
                        width:
                        fieldWidth,
                        child: _input(
                          sedeCtrl,
                          'Sede',
                          Icons
                              .location_on_outlined,
                        ),
                      ),
                    ],
                  ),
                ],

                if (
                selectedRol ==
                    rolProveedor
                ) ...[
                  const SizedBox(
                    height: 14,
                  ),

                  Wrap(
                    spacing: 14,
                    runSpacing: 14,
                    children: [
                      SizedBox(
                        width:
                        fieldWidth,
                        child: _input(
                          razonSocialCtrl,
                          'Razón social',
                          Icons
                              .business_outlined,
                        ),
                      ),
                      SizedBox(
                        width:
                        fieldWidth,
                        child: _numberInput(
                          nitCtrl,
                          'NIT',
                          Icons
                              .credit_card_outlined,
                        ),
                      ),
                      SizedBox(
                        width:
                        fieldWidth,
                        child: _input(
                          direccionCtrl,
                          'Dirección',
                          Icons
                              .location_on_outlined,
                        ),
                      ),
                      SizedBox(
                        width:
                        fieldWidth,
                        child: _input(
                          calificacionCtrl,
                          'Calificación',
                          Icons
                              .star_outline_rounded,
                          keyboardType:
                          const TextInputType
                              .numberWithOptions(
                            decimal:
                            true,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(
                    height: 22,
                  ),

                  _providerCategories(),
                ],
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _roleField() {
    final roles =
        rolController.Rols;

    final roleIds =
    roles
        .map(
          (role) =>
          _toIntOrNull(
            role['id_rol'],
          ),
    )
        .whereType<int>()
        .toSet();

    final validValue =
    roleIds.contains(
      selectedRol,
    )
        ? selectedRol
        : null;

    return DropdownButtonFormField<int>(
      key: ValueKey(
        'role-$selectedRol-${roles.length}',
      ),
      initialValue:
      validValue,
      isExpanded:
      true,
      decoration:
      Wapp.TextFieldDecoration(
        Global.primary,
        true,
        'Rol del usuario',
        Icons
            .admin_panel_settings_outlined,
      ),
      items:
      roles.map<
          DropdownMenuItem<int>>(
            (role) {
          return DropdownMenuItem<int>(
            value:
            _toIntOrNull(
              role['id_rol'],
            ),
            child: Text(
              role['nombre_rol']
                  ?.toString() ??
                  '',
            ),
          );
        },
      ).toList(),
      onChanged: (value) {
        setState(() {
          selectedRol = value;
        });
      },
      validator: (value) {
        if (value == null) {
          return 'Selecciona un rol';
        }

        return null;
      },
    );
  }

  Widget _providerCategories() {
    final types =
        proveedorController
            .TiposProveedores;

    if (types.isEmpty) {
      return Text(
        'No hay categorías disponibles.',
        style:
        GoogleFonts.poppins(
          color:
          Global.textSecondary,
          fontSize: 11,
        ),
      );
    }

    return Column(
      crossAxisAlignment:
      CrossAxisAlignment.start,
      children: [
        _sectionTitle(
          'Categorías del proveedor',
          'Selecciona los tipos de productos que administra.',
        ),

        const SizedBox(
          height: 10,
        ),

        Wrap(
          spacing: 10,
          runSpacing: 10,
          children:
          types.map<Widget>(
                (type) {
              final id =
              _toIntOrNull(
                type[
                'id_tipo_proveedor'],
              );

              if (id == null) {
                return const SizedBox
                    .shrink();
              }

              final selected =
              userController
                  .tiposProveedor
                  .contains(id);

              return FilterChip(
                selected:
                selected,
                label: Text(
                  type['nombre_tipo']
                      ?.toString() ??
                      '',
                ),
                onSelected: (value) {
                  setState(() {
                    if (value) {
                      userController
                          .tiposProveedor
                          .add(id);
                    } else {
                      userController
                          .tiposProveedor
                          .remove(id);
                    }
                  });
                },
                selectedColor:
                Global.primary
                    .withOpacity(
                  0.16,
                ),
                checkmarkColor:
                Global.primary,
              );
            },
          ).toList(),
        ),
      ],
    );
  }

  Widget _securityPanel() {
    return Obx(() {
      final user =
      Map<String, dynamic>.from(
        userController.User,
      );

      final changedBy =
      user['estado_changed_by_user']
      is Map
          ? Map<String, dynamic>.from(
        user[
        'estado_changed_by_user'],
      )
          : <String, dynamic>{};

      final securityItems = [
        _SecurityItem(
          label:
          'Estado de acceso',
          value:
          _capitalize(
            user['estado_acceso']
                ?.toString() ??
                'activo',
          ),
          icon:
          Icons
              .verified_user_outlined,
          color:
          _statusColor(
            user['estado_acceso']
                ?.toString() ??
                'activo',
          ),
        ),
        _SecurityItem(
          label:
          'Último acceso',
          value:
          _formatDate(
            user['last_login_at'],
          ),
          icon:
          Icons.login_rounded,
          color:
          const Color(
            0xFF3578D4,
          ),
        ),
        _SecurityItem(
          label:
          'Intentos fallidos',
          value:
          '${user['failed_login_attempts'] ?? 0}',
          icon:
          Icons
              .password_rounded,
          color:
          const Color(
            0xFFE49B22,
          ),
        ),
        _SecurityItem(
          label:
          'Bloqueo temporal',
          value:
          user['locked_until'] ==
              null
              ? 'Sin bloqueo'
              : _formatDate(
            user[
            'locked_until'],
          ),
          icon:
          Icons
              .lock_clock_outlined,
          color:
          const Color(
            0xFFD84A4A,
          ),
        ),
        _SecurityItem(
          label:
          'Cambio obligatorio',
          value:
          user['must_change_password'] ==
              true
              ? 'Pendiente'
              : 'No requerido',
          icon:
          Icons
              .published_with_changes_rounded,
          color:
          user['must_change_password'] ==
              true
              ? const Color(
            0xFFE49B22,
          )
              : const Color(
            0xFF16865C,
          ),
        ),
        _SecurityItem(
          label:
          'Último cambio de contraseña',
          value:
          _formatDate(
            user[
            'password_changed_at'],
          ),
          icon:
          Icons.key_rounded,
          color:
          const Color(
            0xFF7657D6,
          ),
        ),
        _SecurityItem(
          label:
          'Versión de sesión',
          value:
          '${user['token_version'] ?? 0}',
          icon:
          Icons
              .vpn_key_outlined,
          color:
          Global.primary,
        ),
        _SecurityItem(
          label:
          'Cuenta creada',
          value:
          _formatDate(
            user['created_at'],
          ),
          icon:
          Icons
              .calendar_month_outlined,
          color:
          Global.primary,
        ),
      ];

      return Container(
        width: double.infinity,
        padding:
        const EdgeInsets.all(18),
        decoration:
        _panelDecoration(),
        child: Column(
          crossAxisAlignment:
          CrossAxisAlignment.start,
          children: [
            _sectionTitle(
              'Seguridad de la cuenta',
              'Estado, sesiones y controles de autenticación.',
            ),

            const SizedBox(
              height: 18,
            ),

            LayoutBuilder(
              builder: (
                  context,
                  constraints,
                  ) {
                final width =
                constraints
                    .maxWidth >=
                    800
                    ? (
                    constraints
                        .maxWidth -
                        24
                ) /
                    3
                    : constraints
                    .maxWidth >=
                    520
                    ? (
                    constraints
                        .maxWidth -
                        12
                ) /
                    2
                    : constraints
                    .maxWidth;

                return Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children:
                  securityItems.map(
                        (item) {
                      return SizedBox(
                        width: width,
                        child:
                        _securityCard(
                          item,
                        ),
                      );
                    },
                  ).toList(),
                );
              },
            ),

            if (
            user['estado_observaciones'] !=
                null ||
                changedBy.isNotEmpty
            ) ...[
              const SizedBox(
                height: 18,
              ),

              Container(
                width: double.infinity,
                padding:
                const EdgeInsets.all(
                  14,
                ),
                decoration:
                BoxDecoration(
                  color: Global.text
                      .withOpacity(
                    0.035,
                  ),
                  borderRadius:
                  BorderRadius.circular(
                    13,
                  ),
                ),
                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Último cambio de acceso',
                      style:
                      GoogleFonts.poppins(
                        color:
                        Global.text,
                        fontSize: 11,
                        fontWeight:
                        FontWeight.w600,
                      ),
                    ),

                    const SizedBox(
                      height: 6,
                    ),

                    if (
                    user['estado_observaciones'] !=
                        null
                    )
                      Text(
                        user[
                        'estado_observaciones']
                            .toString(),
                        style:
                        GoogleFonts.poppins(
                          color: Global
                              .textSecondary,
                          fontSize: 10,
                        ),
                      ),

                    if (changedBy.isNotEmpty)
                      Text(
                        'Realizado por ${changedBy['nombre_usuario'] ?? 'Administrador'} · ${_formatDate(user['estado_changed_at'])}',
                        style:
                        GoogleFonts.poppins(
                          color: Global
                              .textSecondary,
                          fontSize: 9,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ],
        ),
      );
    });
  }

  Widget _securityCard(
      _SecurityItem item,
      ) {
    return Container(
      constraints:
      const BoxConstraints(
        minHeight: 104,
      ),
      padding:
      const EdgeInsets.all(14),
      decoration:
      BoxDecoration(
        color:
        item.color.withOpacity(
          0.07,
        ),
        borderRadius:
        BorderRadius.circular(14),
        border:
        Border.all(
          color:
          item.color.withOpacity(
            0.16,
          ),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration:
            BoxDecoration(
              color: item.color
                  .withOpacity(0.13),
              borderRadius:
              BorderRadius.circular(
                11,
              ),
            ),
            child: Icon(
              item.icon,
              color:
              item.color,
              size: 20,
            ),
          ),

          const SizedBox(
            width: 11,
          ),

          Expanded(
            child: Column(
              mainAxisAlignment:
              MainAxisAlignment.center,
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                Text(
                  item.value,
                  maxLines: 2,
                  overflow:
                  TextOverflow.ellipsis,
                  style:
                  GoogleFonts.poppins(
                    color:
                    Global.text,
                    fontSize: 11,
                    fontWeight:
                    FontWeight.w600,
                  ),
                ),
                const SizedBox(
                  height: 3,
                ),
                Text(
                  item.label,
                  style:
                  GoogleFonts.poppins(
                    color: Global
                        .textSecondary,
                    fontSize: 9,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(
      String title,
      String subtitle,
      ) {
    return Column(
      crossAxisAlignment:
      CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style:
          GoogleFonts.poppins(
            color:
            Global.text,
            fontSize: 14,
            fontWeight:
            FontWeight.w700,
          ),
        ),
        Text(
          subtitle,
          style:
          GoogleFonts.poppins(
            color:
            Global.textSecondary,
            fontSize: 9.5,
          ),
        ),
      ],
    );
  }

  Widget _input(
      TextEditingController textController,
      String hint,
      IconData icon, {
        bool required = true,
        TextInputType keyboardType =
            TextInputType.text,
      }) {
    return TextFormField(
      controller:
      textController,
      keyboardType:
      keyboardType,
      decoration:
      Wapp.TextFieldDecoration(
        Global.primary,
        true,
        hint,
        icon,
      ),
      validator:
      !required
          ? null
          : (value) {
        if (
        value == null ||
            value
                .trim()
                .isEmpty
        ) {
          return 'Campo obligatorio';
        }

        return null;
      },
    );
  }

  Widget _numberInput(
      TextEditingController textController,
      String hint,
      IconData icon,
      ) {
    return TextFormField(
      controller:
      textController,
      keyboardType:
      TextInputType.number,
      inputFormatters: [
        FilteringTextInputFormatter
            .digitsOnly,
      ],
      decoration:
      Wapp.TextFieldDecoration(
        Global.primary,
        true,
        hint,
        icon,
      ),
      validator: (value) {
        if (
        value == null ||
            value.trim().isEmpty
        ) {
          return 'Campo obligatorio';
        }

        return null;
      },
    );
  }

  Widget _summaryChip(
      IconData icon,
      String text,
      Color color,
      ) {
    return Container(
      padding:
      const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 7,
      ),
      decoration:
      BoxDecoration(
        color:
        color.withOpacity(0.10),
        borderRadius:
        BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize:
        MainAxisSize.min,
        children: [
          Icon(
            icon,
            color:
            color,
            size: 14,
          ),
          const SizedBox(
            width: 5,
          ),
          Text(
            text,
            style:
            GoogleFonts.poppins(
              color:
              color,
              fontSize: 9.5,
              fontWeight:
              FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  BoxDecoration _panelDecoration() {
    return BoxDecoration(
      color:
      Global.container,
      borderRadius:
      BorderRadius.circular(18),
      border:
      Border.all(
        color: Global.text
            .withOpacity(0.08),
      ),
    );
  }

  Future<void> _submit() async {
    if (
    formKey.currentState
        ?.validate() !=
        true
    ) {
      return;
    }

    setState(() {
      loading = true;
    });

    try {
      final idUsuario =
      _toIntOrNull(
        userController.User[
        'id_usuario'],
      );

      if (idUsuario == null) {
        throw Exception(
          'No fue posible identificar el usuario',
        );
      }

      await editUserApi(
        idUsuario:
        idUsuario,
        updatedBy:
        _toIntOrNull(
          controller.User[
          'id_usuario'],
        ) ??
            0,
        userController:
        userController,

        documento:
        documentoCtrl.text.trim(),
        nombreUsuario:
        nombreCtrl.text.trim(),
        email:
        emailCtrl.text.trim(),
        telefono:
        telefonoCtrl.text.trim(),
        idRol:
        selectedRol,

        nombreCargo:
        selectedRol == rolAsesor
            ? nombreCargoCtrl.text
            .trim()
            : null,

        sede:
        selectedRol == rolAsesor
            ? sedeCtrl.text.trim()
            : null,

        razonSocial:
        selectedRol ==
            rolProveedor
            ? razonSocialCtrl.text
            .trim()
            : null,

        nit:
        selectedRol ==
            rolProveedor
            ? nitCtrl.text.trim()
            : null,

        direccion:
        selectedRol ==
            rolProveedor
            ? direccionCtrl.text
            .trim()
            : null,

        calificacion:
        selectedRol ==
            rolProveedor
            ? double.tryParse(
          calificacionCtrl
              .text
              .trim(),
        )
            : null,

        tiposProveedores:
        selectedRol ==
            rolProveedor
            ? userController
            .tiposProveedor
            .toList()
            : null,
      );

      final updatedUser =
      await getUserDetailApi(
        idUsuario:
        idUsuario,
      );

      userController.setUser(
        updatedUser,
      );

      Get.snackbar(
        'Usuario actualizado',
        'Los cambios fueron guardados correctamente.',
        colorText:
        Colors.white,
        backgroundColor:
        Colors.green,
        snackPosition:
        SnackPosition.BOTTOM,
        margin:
        const EdgeInsets.all(16),
      );
    } catch (error) {
      Get.snackbar(
        'No fue posible guardar',
        error
            .toString()
            .replaceFirst(
          'Exception: ',
          '',
        ),
        colorText:
        Colors.white,
        backgroundColor:
        Colors.red,
        snackPosition:
        SnackPosition.BOTTOM,
        margin:
        const EdgeInsets.all(16),
      );
    } finally {
      if (mounted) {
        setState(() {
          loading = false;
        });
      }
    }
  }

  Color _statusColor(
      String status,
      ) {
    switch (
    status.toLowerCase()
    ) {
      case 'bloqueado':
        return const Color(
          0xFFD84A4A,
        );

      case 'inactivo':
        return const Color(
          0xFFE49B22,
        );

      default:
        return const Color(
          0xFF16865C,
        );
    }
  }

  String _formatDate(
      dynamic value,
      ) {
    if (value == null) {
      return 'No disponible';
    }

    final date =
    DateTime.tryParse(
      value.toString(),
    );

    if (date == null) {
      return 'No disponible';
    }

    final local =
    date.toLocal();

    String twoDigits(int number) =>
        number
            .toString()
            .padLeft(
          2,
          '0',
        );

    return '${twoDigits(local.day)}/'
        '${twoDigits(local.month)}/'
        '${local.year} '
        '${twoDigits(local.hour)}:'
        '${twoDigits(local.minute)}';
  }

  String _capitalize(
      String value,
      ) {
    if (value.isEmpty) {
      return value;
    }

    return value[0].toUpperCase() +
        value.substring(1);
  }

  int? _toIntOrNull(
      dynamic value,
      ) {
    if (value is int) {
      return value;
    }

    return int.tryParse(
      value?.toString() ?? '',
    );
  }
}

class _SecurityItem {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _SecurityItem({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });
}