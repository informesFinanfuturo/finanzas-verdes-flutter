import 'dart:async';

import 'package:finanzas_verdes/app/config/Global.dart';
import 'package:finanzas_verdes/app/routes/subrutes/adminRoutes.dart';
import 'package:finanzas_verdes/controllers/RolController.dart';
import 'package:finanzas_verdes/controllers/UserController.dart';
import 'package:finanzas_verdes/main.dart';
import 'package:finanzas_verdes/models/api/rolApi.dart';
import 'package:finanzas_verdes/models/api/userApi.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class Usersadmin extends StatefulWidget {
  const Usersadmin({
    super.key,
  });

  @override
  State<Usersadmin> createState() =>
      _UsersadminState();
}

class _UsersadminState extends State<Usersadmin> {
  final UserController userController =
  Get.put(UserController());

  final RolController rolController =
  Get.put(RolController());

  final searchController =
  TextEditingController();

  Timer? searchDebounce;

  String estadoAcceso = 'todos';
  String estadoProceso = 'todos';
  String perfil = 'todos';
  String orden = 'recientes';

  int selectedRoleId = 0;
  int limit = 20;
  final ScrollController scrollController = ScrollController();

  Color _dialogBackground() {
    return controller.isDark.value
        ? const Color(0xFF172832)
        : const Color(0xFFFFFFFF);
  }

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance
        .addPostFrameCallback((_) {
      _loadInitialData();
    });
  }

  Future<void> _loadInitialData() async {
    await Future.wait([
      getRolsApi(
        rolController:
        rolController,
      ),
      _loadUsers(),
    ]);
  }

  Future<void> _loadUsers({
    int page = 1,
  }) async {
    try {
      await getUsersApi(
        userController:
        userController,
        search:
        searchController.text,
        estadoAcceso:
        estadoAcceso,
        estadoProceso:
        estadoProceso,
        idRol:
        selectedRoleId == 0
            ? null
            : selectedRoleId,
        perfil:
        perfil,
        orden:
        orden,
        page:
        page,
        limit:
        limit,
      );
    } catch (error) {
      if (!mounted) {
        return;
      }

      Get.snackbar(
        'No fue posible cargar usuarios',
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
    }
  }

  void _onSearchChanged(
      String value,
      ) {
    searchDebounce?.cancel();

    searchDebounce = Timer(
      const Duration(
        milliseconds: 450,
      ),
          () {
        _loadUsers();
      },
    );

    setState(() {});
  }

  void _clearFilters() {
    searchDebounce?.cancel();
    searchController.clear();

    setState(() {
      estadoAcceso = 'todos';
      estadoProceso = 'todos';
      perfil = 'todos';
      orden = 'recientes';
      selectedRoleId = 0;
      limit = 20;
    });

    _loadUsers();
  }

  Future<void> _openUser(Map<String, dynamic> user,) async {
    try {
      userController.clearUserAudit();

      final detail = await getUserDetailApi(
        idUsuario: user['id_usuario'],
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
        colorText:
        Colors.white,
        backgroundColor:
        Colors.red,
        snackPosition:
        SnackPosition.BOTTOM,
      );
    }
  }

  Future<String?> _requestReason({
    required String title,
    required String description,
    required String confirmText,
    required Color confirmColor,
  }) async {
    final reasonController =
    TextEditingController();

    String reason = '';

    final result =
    await Get.dialog<String>(
      StatefulBuilder(
        builder: (
            context,
            setDialogState,
            ) {
          final isValid =
              reason.trim().length >= 5;

          return AlertDialog(
            backgroundColor: _dialogBackground(),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18,),
            ),
            title: Text(
              title,
              style:
              GoogleFonts.poppins(
                color:
                Global.text,
                fontWeight:
                FontWeight.w700,
              ),
            ),
            content:
            ConstrainedBox(
              constraints:
              const BoxConstraints(
                maxWidth: 440,
              ),
              child: Column(
                mainAxisSize:
                MainAxisSize.min,
                crossAxisAlignment:
                CrossAxisAlignment.start,
                children: [
                  Text(
                    description,
                    style:
                    GoogleFonts.poppins(
                      color: Global
                          .textSecondary,
                      fontSize: 12,
                      height: 1.5,
                    ),
                  ),

                  const SizedBox(
                    height: 18,
                  ),

                  TextField(
                    controller:
                    reasonController,
                    autofocus: true,
                    maxLines: 3,
                    onChanged: (value) {
                      setDialogState(() {
                        reason = value;
                      });
                    },
                    decoration:
                    InputDecoration(
                      labelText:
                      'Motivo de la acción',
                      hintText:
                      'Escribe una justificación clara',
                      alignLabelWithHint:
                      true,
                      filled: true,
                      fillColor: Global
                          .text
                          .withOpacity(
                        0.04,
                      ),
                      border:
                      OutlineInputBorder(
                        borderRadius:
                        BorderRadius.circular(
                          13,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(
                    height: 8,
                  ),

                  Text(
                    'Mínimo 5 caracteres. Este motivo quedará registrado en la auditoría.',
                    style:
                    GoogleFonts.poppins(
                      color: Global
                          .textSecondary,
                      fontSize: 9.5,
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Get.back();
                },
                child:
                const Text(
                  'Cancelar',
                ),
              ),
              ElevatedButton(
                onPressed:
                !isValid
                    ? null
                    : () {
                  Get.back(
                    result:
                    reasonController
                        .text
                        .trim(),
                  );
                },
                style:
                ElevatedButton.styleFrom(
                  backgroundColor:
                  confirmColor,
                  foregroundColor:
                  Colors.white,
                ),
                child: Text(
                  confirmText,
                ),
              ),
            ],
          );
        },
      ),
      barrierDismissible: false,
    );

    reasonController.dispose();

    return result;
  }

  Future<void> _changeAccessStatus({
    required Map<String, dynamic> user,
    required String newStatus,
  }) async {
    final name =
        user['nombre_usuario']
            ?.toString() ??
            'este usuario';

    late String title;
    late String description;
    late String confirmText;
    late Color color;

    switch (newStatus) {
      case 'inactivo':
        title =
        'Inactivar usuario';
        description =
        '$name perderá el acceso al aplicativo y sus sesiones actuales dejarán de ser válidas.';
        confirmText =
        'Inactivar';
        color =
        const Color(0xFFE49B22);
        break;

      case 'bloqueado':
        title =
        'Bloquear usuario';
        description =
        '$name no podrá iniciar sesión hasta que un administrador desbloquee la cuenta.';
        confirmText =
        'Bloquear';
        color =
        const Color(0xFFD84A4A);
        break;

      default:
        title =
        'Activar usuario';
        description =
        '$name recuperará el acceso al aplicativo de acuerdo con su rol y estado del proceso.';
        confirmText =
        'Activar';
        color =
        const Color(0xFF16865C);
    }

    final reason =
    await _requestReason(
      title: title,
      description: description,
      confirmText: confirmText,
      confirmColor: color,
    );

    if (reason == null) {
      return;
    }

    try {
      await changeUserAccessStatusApi(
        idUsuario:
        _toInt(
          user['id_usuario'],
        ),
        estadoAcceso:
        newStatus,
        motivo:
        reason,
        userController:
        userController,
      );

      Get.snackbar(
        'Estado actualizado',
        '$name ahora se encuentra ${_capitalize(newStatus)}.',
        colorText:
        Colors.white,
        backgroundColor:
        color,
        snackPosition:
        SnackPosition.BOTTOM,
        margin:
        const EdgeInsets.all(16),
      );
    } catch (error) {
      _showActionError(
        error,
      );
    }
  }

  Future<void> _resetPassword(
      Map<String, dynamic> user,
      ) async {
    final name =
        user['nombre_usuario']
            ?.toString() ??
            'este usuario';

    final reason =
    await _requestReason(
      title:
      'Restablecer contraseña',
      description:
      'Se generará una contraseña temporal para $name. Todas las sesiones actuales serán invalidadas.',
      confirmText:
      'Generar contraseña',
      confirmColor:
      Global.primary,
    );

    if (reason == null) {
      return;
    }

    try {
      final temporaryPassword =
      await resetUserPasswordApi(
        idUsuario:
        _toInt(
          user['id_usuario'],
        ),
        motivo:
        reason,
      );

      await _showTemporaryPassword(
        userName: name,
        temporaryPassword:
        temporaryPassword,
      );

      await _loadUsers(
        page: _toInt(
          userController
              .Pagination['page'],
          fallback: 1,
        ),
      );
    } catch (error) {
      _showActionError(
        error,
      );
    }
  }

  Future<void> _showTemporaryPassword({
    required String userName,
    required String temporaryPassword,
  }) async {
    await Get.dialog<void>(
      PopScope(
        canPop: false,
        child: AlertDialog(
          backgroundColor:
          _dialogBackground(),
          surfaceTintColor:
          Colors.transparent,
          shadowColor:
          Colors.black.withOpacity(0.45),
          elevation: 24,
          clipBehavior:
          Clip.antiAlias,
          insetPadding:
          const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 24,
          ),
          title: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration:
                BoxDecoration(
                  color: Global.primary
                      .withOpacity(
                    0.12,
                  ),
                  borderRadius:
                  BorderRadius.circular(
                    12,
                  ),
                ),
                child: Icon(
                  Icons.key_rounded,
                  color:
                  Global.primary,
                ),
              ),
              const SizedBox(
                width: 12,
              ),
              const Expanded(
                child: Text(
                  'Contraseña temporal',
                ),
              ),
            ],
          ),
          content:
          ConstrainedBox(
            constraints:
            const BoxConstraints(
              maxWidth: 460,
            ),
            child: Column(
              mainAxisSize:
              MainAxisSize.min,
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                Text(
                  'Comparte esta contraseña de manera segura con $userName.',
                  style:
                  GoogleFonts.poppins(
                    color: Global
                        .textSecondary,
                    fontSize: 12,
                  ),
                ),

                const SizedBox(
                  height: 18,
                ),

                Container(
                  width: double.infinity,
                  padding:
                  const EdgeInsets.all(
                    16,
                  ),
                  decoration:
                  BoxDecoration(
                    color: Global.primary
                        .withOpacity(
                      0.08,
                    ),
                    borderRadius:
                    BorderRadius.circular(
                      14,
                    ),
                    border:
                    Border.all(
                      color: Global.primary
                          .withOpacity(
                        0.20,
                      ),
                    ),
                  ),
                  child:
                  SelectableText(
                    temporaryPassword,
                    textAlign:
                    TextAlign.center,
                    style:
                    GoogleFonts.poppins(
                      color:
                      Global.primary,
                      fontSize: 20,
                      fontWeight:
                      FontWeight.w700,
                      letterSpacing: 1.5,
                    ),
                  ),
                ),

                const SizedBox(
                  height: 14,
                ),

                Row(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons
                          .warning_amber_rounded,
                      color:
                      Colors.orange,
                      size: 18,
                    ),
                    const SizedBox(
                      width: 8,
                    ),
                    Expanded(
                      child: Text(
                        'Esta contraseña solo se mostrará una vez. El usuario deberá cambiarla al iniciar sesión.',
                        style:
                        GoogleFonts.poppins(
                          color: Global
                              .textSecondary,
                          fontSize: 10,
                          height: 1.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            OutlinedButton.icon(
              onPressed: () async {
                await Clipboard.setData(
                  ClipboardData(
                    text:
                    temporaryPassword,
                  ),
                );

                Get.snackbar(
                  'Contraseña copiada',
                  'La contraseña temporal fue copiada al portapapeles.',
                  snackPosition:
                  SnackPosition.BOTTOM,
                  margin:
                  const EdgeInsets.all(
                    16,
                  ),
                );
              },
              icon:
              const Icon(
                Icons.copy_rounded,
                size: 17,
              ),
              label:
              const Text(
                'Copiar',
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Get.back();
              },
              style:
              ElevatedButton.styleFrom(
                backgroundColor:
                Global.primary,
                foregroundColor:
                Colors.white,
              ),
              child:
              const Text(
                'Ya la guardé',
              ),
            ),
          ],
        ),
      ),
      barrierDismissible: false,
    );
  }

  Widget _userActions(
      Map<String, dynamic> user,
      ) {
    final status =
        user['estado_acceso']
            ?.toString()
            .toLowerCase() ??
            'activo';

    return PopupMenuButton<String>(
      tooltip:
      'Acciones del usuario',
      icon: Icon(
        Icons.more_vert_rounded,
        color:
        Global.textSecondary,
      ),
      onSelected: (action) {
        _handleUserAction(
          action,
          user,
        );
      },
      itemBuilder: (context) {
        return [
          const PopupMenuItem(
            value: 'edit',
            child: ListTile(
              dense: true,
              contentPadding:
              EdgeInsets.zero,
              leading:
              Icon(Icons.edit_outlined),
              title:
              Text('Editar usuario'),
            ),
          ),

          if (status != 'activo')
            const PopupMenuItem(
              value: 'activate',
              child: ListTile(
                dense: true,
                contentPadding:
                EdgeInsets.zero,
                leading: Icon(
                  Icons
                      .check_circle_outline_rounded,
                  color:
                  Color(0xFF16865C),
                ),
                title:
                Text('Activar usuario'),
              ),
            ),

          if (status == 'activo')
            const PopupMenuItem(
              value: 'deactivate',
              child: ListTile(
                dense: true,
                contentPadding:
                EdgeInsets.zero,
                leading: Icon(
                  Icons
                      .pause_circle_outline_rounded,
                  color:
                  Color(0xFFE49B22),
                ),
                title:
                Text('Inactivar usuario'),
              ),
            ),

          if (status != 'bloqueado')
            const PopupMenuItem(
              value: 'block',
              child: ListTile(
                dense: true,
                contentPadding:
                EdgeInsets.zero,
                leading: Icon(
                  Icons.lock_outline_rounded,
                  color:
                  Color(0xFFD84A4A),
                ),
                title:
                Text('Bloquear usuario'),
              ),
            ),

          const PopupMenuDivider(),

          const PopupMenuItem(
            value: 'reset_password',
            child: ListTile(
              dense: true,
              contentPadding:
              EdgeInsets.zero,
              leading: Icon(
                Icons.key_rounded,
              ),
              title: Text(
                'Restablecer contraseña',
              ),
            ),
          ),
        ];
      },
    );
  }

  void _showActionError(
      Object error,
      ) {
    Get.snackbar(
      'No fue posible realizar la acción',
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
  }

  Future<void> _handleUserAction(String action, Map<String, dynamic> user,) async {
    switch (action) {
      case 'edit':
        await _openUser(user);
        break;

      case 'activate':
        await _changeAccessStatus(
          user: user,
          newStatus: 'activo',
        );
        break;

      case 'deactivate':
        await _changeAccessStatus(
          user: user,
          newStatus: 'inactivo',
        );
        break;

      case 'block':
        await _changeAccessStatus(
          user: user,
          newStatus: 'bloqueado',
        );
        break;

      case 'reset_password':
        await _resetPassword(user);
        break;
    }
  }

  @override
  void dispose() {
    searchDebounce?.cancel();
    searchController.dispose();
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context,) {
    final screenWidth =
        MediaQuery.sizeOf(
          context,
        ).width;

    final isDesktop =
        screenWidth >= 1000;

    final isMobile =
        screenWidth < 800;

    /*
   * El dashboard ya limita la altura de
   * esta pantalla mediante Expanded.
   * Por eso no necesitamos LayoutBuilder
   * ni calcular manualmente maxHeight.
   */
    return Obx((){
      final _ = controller.isDark.value;
      return SingleChildScrollView(
        primary: false,
        physics:
        const AlwaysScrollableScrollPhysics(),
        padding:
        EdgeInsets.only(
          bottom:
          isMobile
              ? 125
              : 24,
        ),
        child: Column(
          crossAxisAlignment:
          CrossAxisAlignment.start,
          children: [
            _header(),

            const SizedBox(
              height: 20,
            ),

            Obx(
                  () => _summaryCards(
                userController.Summary,

                /*
             * El dashboard aplica 20 px
             * de padding a cada lado.
             */
                screenWidth - 40,
              ),
            ),

            const SizedBox(
              height: 20,
            ),

            /*
         * Ya no debe estar dentro de Obx.
         * setState se ejecuta cuando
         * getRolsApi termina.
         */
            _filters(),

            const SizedBox(
              height: 16,
            ),

            Container(
              width: double.infinity,
              decoration:
              BoxDecoration(
                color:
                Global.container,
                borderRadius:
                BorderRadius.circular(
                  18,
                ),
                border:
                Border.all(
                  color: Global.text
                      .withOpacity(
                    0.08,
                  ),
                ),
              ),
              child: Obx(() {
                if (
                userController
                    .isLoadingUsers
                    .value &&
                    userController
                        .Users.isEmpty
                ) {
                  return SizedBox(
                    height: 260,
                    child: Center(
                      child:
                      CircularProgressIndicator(
                        color:
                        Global.primary,
                      ),
                    ),
                  );
                }

                if (
                userController
                    .Users.isEmpty
                ) {
                  return SizedBox(
                    height: 300,
                    child:
                    _emptyState(),
                  );
                }

                return Column(
                  mainAxisSize:
                  MainAxisSize.min,
                  children: [
                    isDesktop
                        ? _desktopList()
                        : _mobileList(),

                    _pagination(),
                  ],
                );
              }),
            ),
          ],
        ),
      );
    });
  }

  Widget _header() {
    return Row(
      crossAxisAlignment:
      CrossAxisAlignment.center,
      children: [
        Container(
          width: 46,
          height: 46,
          decoration:
          BoxDecoration(
            color: Global.primary
                .withOpacity(0.12),
            borderRadius:
            BorderRadius.circular(
              13,
            ),
          ),
          child: Icon(
            Icons
                .manage_accounts_rounded,
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
                'Gestión de usuarios',
                style:
                GoogleFonts.poppins(
                  color: Global.text,
                  fontSize: 20,
                  fontWeight:
                  FontWeight.w700,
                ),
              ),
              Text(
                'Administra accesos, roles y seguridad de las cuentas.',
                style:
                GoogleFonts.poppins(
                  color:
                  Global.textSecondary,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ),

        ElevatedButton.icon(
          onPressed: () {
            controller.setPage(
              Adminroutes.newUser,
            );
          },
          icon: const Icon(
            Icons
                .person_add_alt_1_rounded,
            size: 18,
          ),
          label: const Text(
            'Nuevo usuario',
          ),
          style:
          ElevatedButton.styleFrom(
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
            shape:
            RoundedRectangleBorder(
              borderRadius:
              BorderRadius.circular(
                13,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _summaryCards(
      Map<String, dynamic> summary,
      double availableWidth,
      ) {
    final cards = [
      _SummaryItem(
        label: 'Total',
        value:
        _toInt(
          summary['total'],
        ),
        icon:
        Icons.groups_rounded,
        color:
        Global.primary,
      ),
      _SummaryItem(
        label: 'Activos',
        value:
        _toInt(
          summary['activos'],
        ),
        icon:
        Icons.check_circle_rounded,
        color:
        const Color(
          0xFF16865C,
        ),
      ),
      _SummaryItem(
        label: 'Inactivos',
        value:
        _toInt(
          summary['inactivos'],
        ),
        icon:
        Icons.pause_circle_rounded,
        color:
        const Color(
          0xFFE49B22,
        ),
      ),
      _SummaryItem(
        label: 'Bloqueados',
        value:
        _toInt(
          summary['bloqueados'],
        ),
        icon:
        Icons.lock_rounded,
        color:
        const Color(
          0xFFD84A4A,
        ),
      ),
      _SummaryItem(
        label: 'Incompletos',
        value:
        _toInt(
          summary['incompletos'],
        ),
        icon:
        Icons.warning_amber_rounded,
        color:
        const Color(
          0xFF7657D6,
        ),
      ),
    ];

    final cardWidth =
    availableWidth >= 1100
        ? (
        availableWidth -
            48
    ) /
        5
        : availableWidth >=
        650
        ? (
        availableWidth -
            24
    ) /
        3
        : (
        availableWidth -
            12
    ) /
        2;

    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children:
      cards.map((item) {
        return Container(
          width: cardWidth,
          constraints:
          const BoxConstraints(
            minHeight: 92,
          ),
          padding:
          const EdgeInsets.all(
            15,
          ),
          decoration:
          BoxDecoration(
            color:
            item.color.withOpacity(
              0.08,
            ),
            borderRadius:
            BorderRadius.circular(
              16,
            ),
            border:
            Border.all(
              color:
              item.color.withOpacity(
                0.18,
              ),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration:
                BoxDecoration(
                  color: item.color
                      .withOpacity(
                    0.13,
                  ),
                  borderRadius:
                  BorderRadius.circular(
                    12,
                  ),
                ),
                child: Icon(
                  item.icon,
                  color:
                  item.color,
                  size: 21,
                ),
              ),

              const SizedBox(
                width: 12,
              ),

              Expanded(
                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment
                      .start,
                  mainAxisAlignment:
                  MainAxisAlignment
                      .center,
                  children: [
                    Text(
                      item.value
                          .toString(),
                      style:
                      GoogleFonts.poppins(
                        color:
                        Global.text,
                        fontSize: 19,
                        fontWeight:
                        FontWeight
                            .w700,
                      ),
                    ),
                    Text(
                      item.label,
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
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _filters() {
    return Container(
      width: double.infinity,
      padding:
      const EdgeInsets.all(16),
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
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller:
                  searchController,
                  onChanged:
                  _onSearchChanged,
                  decoration:
                  _inputDecoration(
                    label:
                    'Buscar usuario',
                    hint:
                    'Nombre, documento o correo',
                    icon:
                    Icons.search_rounded,
                  ).copyWith(
                    suffixIcon:
                    searchController
                        .text
                        .isEmpty
                        ? null
                        : IconButton(
                      onPressed:
                          () {
                        searchController
                            .clear();

                        setState(
                              () {},
                        );

                        _loadUsers();
                      },
                      icon:
                      const Icon(
                        Icons
                            .close_rounded,
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(
                width: 10,
              ),

              IconButton(
                tooltip:
                'Actualizar',
                onPressed:
                userController
                    .isLoadingUsers
                    .value
                    ? null
                    : () =>
                    _loadUsers(),
                icon: Icon(
                  Icons.refresh_rounded,
                  color:
                  Global.primary,
                ),
              ),

              TextButton.icon(
                onPressed:
                _clearFilters,
                icon: const Icon(
                  Icons
                      .filter_alt_off_rounded,
                  size: 18,
                ),
                label:
                const Text(
                  'Limpiar',
                ),
              ),
            ],
          ),

          const SizedBox(
            height: 12,
          ),

          LayoutBuilder(
            builder: (
                context,
                constraints,
                ) {
              final width =
              constraints.maxWidth >=
                  1000
                  ? (
                  constraints
                      .maxWidth -
                      48
              ) /
                  5
                  : constraints
                  .maxWidth >=
                  600
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
                children: [
                  SizedBox(
                    width: width,
                    child:
                    DropdownButtonFormField<
                        String>(
                      value:
                      estadoAcceso,
                      isExpanded: true,
                      decoration:
                      _inputDecoration(
                        label:
                        'Estado de acceso',
                        icon: Icons
                            .verified_user_outlined,
                      ),
                      items:
                      const [
                        DropdownMenuItem(
                          value:
                          'todos',
                          child:
                          Text('Todos'),
                        ),
                        DropdownMenuItem(
                          value:
                          'activo',
                          child:
                          Text('Activo'),
                        ),
                        DropdownMenuItem(
                          value:
                          'inactivo',
                          child:
                          Text('Inactivo'),
                        ),
                        DropdownMenuItem(
                          value:
                          'bloqueado',
                          child:
                          Text('Bloqueado'),
                        ),
                      ],
                      onChanged:
                          (value) {
                        setState(() {
                          estadoAcceso =
                              value ??
                                  'todos';
                        });

                        _loadUsers();
                      },
                    ),
                  ),

                  SizedBox(
                    width: width,
                    child:
                    DropdownButtonFormField<
                        int>(
                      value:
                      selectedRoleId,
                      isExpanded: true,
                      decoration:
                      _inputDecoration(
                        label: 'Rol',
                        icon: Icons
                            .badge_outlined,
                      ),
                      items: [
                        const DropdownMenuItem(
                          value: 0,
                          child:
                          Text(
                            'Todos los roles',
                          ),
                        ),
                        ...rolController.Rols
                            .map<
                            DropdownMenuItem<
                                int>>(
                              (rol) {
                            return DropdownMenuItem(
                              value:
                              _toInt(
                                rol[
                                'id_rol'],
                              ),
                              child:
                              Text(
                                rol[
                                'nombre_rol']
                                    ?.toString() ??
                                    '',
                                overflow:
                                TextOverflow
                                    .ellipsis,
                              ),
                            );
                          },
                        ),
                      ],
                      onChanged:
                          (value) {
                        setState(() {
                          selectedRoleId =
                              value ?? 0;
                        });

                        _loadUsers();
                      },
                    ),
                  ),

                  SizedBox(
                    width: width,
                    child:
                    DropdownButtonFormField<
                        String>(
                      value:
                      estadoProceso,
                      isExpanded: true,
                      decoration:
                      _inputDecoration(
                        label:
                        'Estado del proceso',
                        icon: Icons
                            .account_tree_outlined,
                      ),
                      items:
                      const [
                        DropdownMenuItem(
                          value:
                          'todos',
                          child:
                          Text('Todos'),
                        ),
                        DropdownMenuItem(
                          value:
                          'nuevo',
                          child:
                          Text('Nuevo'),
                        ),
                        DropdownMenuItem(
                          value:
                          'activo',
                          child:
                          Text('Activo'),
                        ),
                        DropdownMenuItem(
                          value:
                          'pospuesto',
                          child:
                          Text('Pospuesto'),
                        ),
                        DropdownMenuItem(
                          value:
                          'inactivo',
                          child:
                          Text('Inactivo'),
                        ),
                      ],
                      onChanged:
                          (value) {
                        setState(() {
                          estadoProceso =
                              value ??
                                  'todos';
                        });

                        _loadUsers();
                      },
                    ),
                  ),

                  SizedBox(
                    width: width,
                    child:
                    DropdownButtonFormField<
                        String>(
                      value:
                      perfil,
                      isExpanded: true,
                      decoration:
                      _inputDecoration(
                        label:
                        'Información',
                        icon: Icons
                            .fact_check_outlined,
                      ),
                      items:
                      const [
                        DropdownMenuItem(
                          value:
                          'todos',
                          child:
                          Text('Todos'),
                        ),
                        DropdownMenuItem(
                          value:
                          'completos',
                          child:
                          Text(
                            'Completos',
                          ),
                        ),
                        DropdownMenuItem(
                          value:
                          'incompletos',
                          child:
                          Text(
                            'Incompletos',
                          ),
                        ),
                      ],
                      onChanged:
                          (value) {
                        setState(() {
                          perfil =
                              value ??
                                  'todos';
                        });

                        _loadUsers();
                      },
                    ),
                  ),

                  SizedBox(
                    width: width,
                    child:
                    DropdownButtonFormField<
                        String>(
                      value:
                      orden,
                      isExpanded: true,
                      decoration:
                      _inputDecoration(
                        label:
                        'Ordenar por',
                        icon: Icons
                            .sort_rounded,
                      ),
                      items:
                      const [
                        DropdownMenuItem(
                          value:
                          'recientes',
                          child:
                          Text(
                            'Más recientes',
                          ),
                        ),
                        DropdownMenuItem(
                          value:
                          'antiguos',
                          child:
                          Text(
                            'Más antiguos',
                          ),
                        ),
                        DropdownMenuItem(
                          value:
                          'nombre_asc',
                          child:
                          Text(
                            'Nombre A–Z',
                          ),
                        ),
                        DropdownMenuItem(
                          value:
                          'nombre_desc',
                          child:
                          Text(
                            'Nombre Z–A',
                          ),
                        ),
                        DropdownMenuItem(
                          value:
                          'ultimo_acceso',
                          child:
                          Text(
                            'Último acceso',
                          ),
                        ),
                      ],
                      onChanged:
                          (value) {
                        setState(() {
                          orden =
                              value ??
                                  'recientes';
                        });

                        _loadUsers();
                      },
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _desktopList() {
    return Column(
      mainAxisSize:
      MainAxisSize.min,
      children: [
        _desktopHeader(),

        ListView.separated(
          shrinkWrap: true,
          physics:
          const NeverScrollableScrollPhysics(),
          padding:
          const EdgeInsets.only(
            bottom: 10,
          ),
          itemCount:
          userController
              .Users.length,
          separatorBuilder:
              (_, __) => Divider(
            height: 1,
            color: Global.text
                .withOpacity(0.06),
          ),
          itemBuilder:
              (context, index) {
            final user =
            Map<String, dynamic>.from(
              userController
                  .Users[index],
            );

            return _desktopRow(
              user,
            );
          },
        ),
      ],
    );
  }

  Widget _desktopHeader() {
    TextStyle style =
    GoogleFonts.poppins(
      color:
      Global.textSecondary,
      fontSize: 10,
      fontWeight:
      FontWeight.w600,
    );

    return Container(
      padding:
      const EdgeInsets.symmetric(
        horizontal: 18,
        vertical: 13,
      ),
      decoration:
      BoxDecoration(
        color: Global.text
            .withOpacity(0.035),
        borderRadius:
        const BorderRadius.vertical(
          top: Radius.circular(18),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child:
            Text('Usuario', style: style),
          ),
          Expanded(
            flex: 2,
            child:
            Text('Rol', style: style),
          ),
          Expanded(
            flex: 2,
            child: Text(
              'Acceso',
              style: style,
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              'Proceso',
              style: style,
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              'Último acceso',
              style: style,
            ),
          ),
          const SizedBox(
            width: 44,
          ),
        ],
      ),
    );
  }

  Widget _desktopRow(
      Map<String, dynamic> user,
      ) {
    return InkWell(
      onTap: () =>
          _openUser(user),
      child: Padding(
        padding:
        const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 13,
        ),
        child: Row(
          children: [
            Expanded(
              flex: 3,
              child: _userIdentity(
                user,
              ),
            ),
            Expanded(
              flex: 2,
              child: Text(
                user['nombre_rol']
                    ?.toString() ??
                    'Sin rol',
                overflow:
                TextOverflow.ellipsis,
                style:
                _cellStyle(),
              ),
            ),
            Expanded(
              flex: 2,
              child: Align(
                alignment:
                Alignment.centerLeft,
                child:
                _accessChip(
                  user[
                  'estado_acceso'],
                ),
              ),
            ),
            Expanded(
              flex: 2,
              child: Text(
                _capitalize(
                  user['estado']
                      ?.toString() ??
                      'No disponible',
                ),
                style:
                _cellStyle(),
              ),
            ),
            Expanded(
              flex: 2,
              child: Text(
                _formatDate(
                  user[
                  'last_login_at'],
                ),
                style:
                _cellStyle(),
              ),
            ),
            SizedBox(
              width: 44,
              child:
              _userActions(user),
            ),
          ],
        ),
      ),
    );
  }

  Widget _mobileList() {
    return ListView.separated(
      shrinkWrap: true,
      physics:
      const NeverScrollableScrollPhysics(),
      padding:
      const EdgeInsets.all(12),
      itemCount:
      userController.Users.length,
      separatorBuilder:
          (_, __) =>
      SizedBox(height: 10,),
      itemBuilder: (context, index) {
        final user = Map<String, dynamic>.from(
          userController.Users[index],
        );

        return InkWell(
          onTap: () =>
              _openUser(user),
          borderRadius:
          BorderRadius.circular(15),
          child: Container(
            padding:
            const EdgeInsets.all(14),
            decoration:
            BoxDecoration(
              color: Global.text
                  .withOpacity(0.025),
              borderRadius:
              BorderRadius.circular(
                15,
              ),
              border:
              Border.all(
                color: Global.text
                    .withOpacity(0.07),
              ),
            ),
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child:
                      _userIdentity(
                        user,
                      ),
                    ),

                    const SizedBox(
                      width: 8,
                    ),

                    _accessChip(
                      user[
                      'estado_acceso'],
                    ),
                    const SizedBox(
                      width: 2,
                    ),

                    _userActions(user),
                  ],
                ),

                const SizedBox(
                  height: 14,
                ),

                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _smallData(
                      Icons.badge_outlined,
                      user['nombre_rol']
                          ?.toString() ??
                          'Sin rol',
                    ),
                    _smallData(
                      Icons
                          .account_tree_outlined,
                      _capitalize(
                        user['estado']
                            ?.toString() ??
                            'Sin estado',
                      ),
                    ),
                    _smallData(
                      Icons.login_rounded,
                      _formatDate(
                        user[
                        'last_login_at'],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _userIdentity(
      Map<String, dynamic> user,
      ) {
    final name =
        user['nombre_usuario']
            ?.toString() ??
            'Usuario sin nombre';

    final email =
        user['email']
            ?.toString() ??
            'Sin correo';

    return Row(
      children: [
        CircleAvatar(
          radius: 20,
          backgroundColor:
          Global.primary.withOpacity(
            0.12,
          ),
          child: Text(
            name.isNotEmpty
                ? name[0].toUpperCase()
                : '?',
            style:
            GoogleFonts.poppins(
              color:
              Global.primary,
              fontWeight:
              FontWeight.w700,
            ),
          ),
        ),

        const SizedBox(
          width: 10,
        ),

        Expanded(
          child: Column(
            crossAxisAlignment:
            CrossAxisAlignment.start,
            children: [
              Text(
                name,
                maxLines: 1,
                overflow:
                TextOverflow.ellipsis,
                style:
                GoogleFonts.poppins(
                  color:
                  Global.text,
                  fontSize: 12,
                  fontWeight:
                  FontWeight.w600,
                ),
              ),
              Text(
                email,
                maxLines: 1,
                overflow:
                TextOverflow.ellipsis,
                style:
                GoogleFonts.poppins(
                  color: Global
                      .textSecondary,
                  fontSize: 9.5,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _accessChip(
      dynamic rawStatus,
      ) {
    final status =
        rawStatus
            ?.toString()
            .toLowerCase() ??
            'activo';

    Color color;
    IconData icon;

    switch (status) {
      case 'bloqueado':
        color =
        const Color(0xFFD84A4A);
        icon =
            Icons.lock_rounded;
        break;

      case 'inactivo':
        color =
        const Color(0xFFE49B22);
        icon =
            Icons.pause_rounded;
        break;

      default:
        color =
        const Color(0xFF16865C);
        icon =
            Icons.check_rounded;
    }

    return Container(
      padding:
      const EdgeInsets.symmetric(
        horizontal: 9,
        vertical: 5,
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
            color: color,
            size: 13,
          ),
          const SizedBox(
            width: 4,
          ),
          Text(
            _capitalize(status),
            style:
            GoogleFonts.poppins(
              color: color,
              fontSize: 9,
              fontWeight:
              FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _smallData(
      IconData icon,
      String value,
      ) {
    return Container(
      padding:
      const EdgeInsets.symmetric(
        horizontal: 9,
        vertical: 6,
      ),
      decoration:
      BoxDecoration(
        color: Global.text
            .withOpacity(0.045),
        borderRadius:
        BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize:
        MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 13,
            color:
            Global.textSecondary,
          ),
          const SizedBox(
            width: 5,
          ),
          Text(
            value,
            style:
            GoogleFonts.poppins(
              color:
              Global.textSecondary,
              fontSize: 9,
            ),
          ),
        ],
      ),
    );
  }

  Widget _pagination() {
    final pagination =
        userController.Pagination;

    final page =
    _toInt(
      pagination['page'],
      fallback: 1,
    );

    final totalPages =
    _toInt(
      pagination['total_pages'],
      fallback: 1,
    );

    final total =
    _toInt(
      pagination['total'],
    );

    return Container(
      padding:
      const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 11,
      ),
      decoration:
      BoxDecoration(
        border:
        Border(
          top: BorderSide(
            color: Global.text
                .withOpacity(0.07),
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              '$total usuarios · Página $page de $totalPages',
              style:
              GoogleFonts.poppins(
                color:
                Global.textSecondary,
                fontSize: 10,
              ),
            ),
          ),

          IconButton(
            tooltip:
            'Página anterior',
            onPressed:
            page > 1
                ? () => _loadUsers(
              page:
              page - 1,
            )
                : null,
            icon:
            const Icon(
              Icons
                  .chevron_left_rounded,
            ),
          ),

          Container(
            width: 34,
            height: 34,
            alignment:
            Alignment.center,
            decoration:
            BoxDecoration(
              color: Global.primary
                  .withOpacity(0.12),
              borderRadius:
              BorderRadius.circular(
                10,
              ),
            ),
            child: Text(
              page.toString(),
              style:
              GoogleFonts.poppins(
                color:
                Global.primary,
                fontWeight:
                FontWeight.w700,
              ),
            ),
          ),

          IconButton(
            tooltip:
            'Página siguiente',
            onPressed:
            page < totalPages
                ? () => _loadUsers(
              page:
              page + 1,
            )
                : null,
            icon:
            const Icon(
              Icons
                  .chevron_right_rounded,
            ),
          ),
        ],
      ),
    );
  }

  Widget _emptyState() {
    return Center(
      child: Padding(
        padding:
        const EdgeInsets.all(30),
        child: Column(
          mainAxisSize:
          MainAxisSize.min,
          children: [
            Icon(
              Icons
                  .person_search_rounded,
              size: 48,
              color: Global
                  .textSecondary
                  .withOpacity(0.55),
            ),
            const SizedBox(
              height: 12,
            ),
            Text(
              'No encontramos usuarios',
              style:
              GoogleFonts.poppins(
                color:
                Global.text,
                fontWeight:
                FontWeight.w600,
              ),
            ),
            const SizedBox(
              height: 4,
            ),
            Text(
              'Prueba cambiando o limpiando los filtros.',
              textAlign:
              TextAlign.center,
              style:
              GoogleFonts.poppins(
                color:
                Global.textSecondary,
                fontSize: 11,
              ),
            ),
            const SizedBox(
              height: 14,
            ),
            TextButton.icon(
              onPressed:
              _clearFilters,
              icon: const Icon(
                Icons
                    .filter_alt_off_rounded,
              ),
              label:
              const Text(
                'Limpiar filtros',
              ),
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration _inputDecoration({
    required String label,
    String? hint,
    required IconData icon,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      prefixIcon:
      Icon(
        icon,
        size: 19,
      ),
      filled: true,
      fillColor:
      Global.text.withOpacity(
        0.035,
      ),
      contentPadding:
      const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 14,
      ),
      border:
      OutlineInputBorder(
        borderRadius:
        BorderRadius.circular(13),
        borderSide:
        BorderSide.none,
      ),
      enabledBorder:
      OutlineInputBorder(
        borderRadius:
        BorderRadius.circular(13),
        borderSide:
        BorderSide(
          color: Global.text
              .withOpacity(0.08),
        ),
      ),
      focusedBorder:
      OutlineInputBorder(
        borderRadius:
        BorderRadius.circular(13),
        borderSide:
        BorderSide(
          color:
          Global.primary,
          width: 1.4,
        ),
      ),
    );
  }

  TextStyle _cellStyle() {
    return GoogleFonts.poppins(
      color: Global.text,
      fontSize: 10.5,
    );
  }

  String _formatDate(
      dynamic value,
      ) {
    if (
    value == null ||
        value.toString().isEmpty
    ) {
      return 'Sin acceso';
    }

    final date =
    DateTime.tryParse(
      value.toString(),
    );

    if (date == null) {
      return 'Sin acceso';
    }

    final local =
    date.toLocal();

    String twoDigits(int number) =>
        number.toString().padLeft(
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

  int _toInt(
      dynamic value, {
        int fallback = 0,
      }) {
    if (value is int) {
      return value;
    }

    return int.tryParse(
      value?.toString() ?? '',
    ) ??
        fallback;
  }
}

class _SummaryItem {
  final String label;
  final int value;
  final IconData icon;
  final Color color;

  const _SummaryItem({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });
}