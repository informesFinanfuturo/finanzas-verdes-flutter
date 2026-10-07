import 'package:finanzas_verdes/app/config/Global.dart';
import 'package:finanzas_verdes/controllers/UserController.dart';
import 'package:finanzas_verdes/models/api/userApi.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class UserAuditPanel
    extends StatefulWidget {
  final int idUsuario;

  const UserAuditPanel({
    super.key,
    required this.idUsuario,
  });

  @override
  State<UserAuditPanel> createState() =>
      _UserAuditPanelState();
}

class _UserAuditPanelState
    extends State<UserAuditPanel> {
  final UserController userController =
  Get.find<UserController>();

  bool initialized = false;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance
        .addPostFrameCallback((_) {
      _loadAudit();
    });
  }

  Future<void> _loadAudit({
    int page = 1,
  }) async {
    try {
      await getUserAuditApi(
        idUsuario:
        widget.idUsuario,
        userController:
        userController,
        page:
        page,
        limit:
        15,
      );

      if (mounted) {
        setState(() {
          initialized = true;
        });
      }
    } catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        initialized = true;
      });

      Get.snackbar(
        'No fue posible cargar la actividad',
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

  @override
  Widget build(
      BuildContext context,
      ) {
    return Obx(() {
      if (
      userController
          .isLoadingAudit.value &&
          !initialized
      ) {
        return _loading();
      }

      if (
      userController
          .UserAudit.isEmpty
      ) {
        return _empty();
      }

      return Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Historial de actividad',
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
                      'Registro de cambios administrativos y de seguridad.',
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

              IconButton(
                tooltip:
                'Actualizar historial',
                onPressed:
                userController
                    .isLoadingAudit
                    .value
                    ? null
                    : () => _loadAudit(
                  page: 1,
                ),
                icon:
                userController
                    .isLoadingAudit
                    .value
                    ? SizedBox(
                  width: 18,
                  height: 18,
                  child:
                  CircularProgressIndicator(
                    strokeWidth:
                    2,
                    color:
                    Global.primary,
                  ),
                )
                    : Icon(
                  Icons
                      .refresh_rounded,
                  color:
                  Global.primary,
                ),
              ),
            ],
          ),

          const SizedBox(
            height: 18,
          ),

          ...userController
              .UserAudit
              .map<Widget>(
                (item) {
              return _auditItem(
                Map<String, dynamic>.from(
                  item,
                ),
              );
            },
          ),

          _pagination(),
        ],
      );
    });
  }

  Widget _auditItem(
      Map<String, dynamic> item,
      ) {
    final action =
        item['accion']
            ?.toString() ??
            'UNKNOWN';

    final previousData =
    item['datos_anteriores']
    is Map
        ? Map<String, dynamic>.from(
      item['datos_anteriores'],
    )
        : <String, dynamic>{};

    final newData =
    item['datos_nuevos'] is Map
        ? Map<String, dynamic>.from(
      item['datos_nuevos'],
    )
        : <String, dynamic>{};

    final visual =
    _actionVisual(
      action,
    );

    return Container(
      margin:
      const EdgeInsets.only(
        bottom: 12,
      ),
      padding:
      const EdgeInsets.all(15),
      decoration:
      BoxDecoration(
        color: visual.color
            .withOpacity(0.055),
        borderRadius:
        BorderRadius.circular(15),
        border:
        Border.all(
          color: visual.color
              .withOpacity(0.16),
        ),
      ),
      child: Row(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration:
            BoxDecoration(
              color: visual.color
                  .withOpacity(0.12),
              borderRadius:
              BorderRadius.circular(
                12,
              ),
            ),
            child: Icon(
              visual.icon,
              color:
              visual.color,
              size: 20,
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
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        visual.label,
                        style:
                        GoogleFonts.poppins(
                          color:
                          Global.text,
                          fontSize: 12,
                          fontWeight:
                          FontWeight.w600,
                        ),
                      ),
                    ),

                    Text(
                      _formatDate(
                        item['created_at'],
                      ),
                      style:
                      GoogleFonts.poppins(
                        color: Global
                            .textSecondary,
                        fontSize: 9,
                      ),
                    ),
                  ],
                ),

                const SizedBox(
                  height: 3,
                ),

                Text(
                  _actorText(item),
                  style:
                  GoogleFonts.poppins(
                    color: Global
                        .textSecondary,
                    fontSize: 9.5,
                  ),
                ),

                if (
                item['motivo'] != null &&
                    item['motivo']
                        .toString()
                        .trim()
                        .isNotEmpty
                ) ...[
                  const SizedBox(
                    height: 9,
                  ),

                  Container(
                    width:
                    double.infinity,
                    padding:
                    const EdgeInsets
                        .all(10),
                    decoration:
                    BoxDecoration(
                      color: Global.text
                          .withOpacity(
                        0.035,
                      ),
                      borderRadius:
                      BorderRadius
                          .circular(
                        10,
                      ),
                    ),
                    child: Text(
                      item['motivo']
                          .toString(),
                      style:
                      GoogleFonts.poppins(
                        color:
                        Global.text,
                        fontSize: 9.5,
                        height: 1.45,
                      ),
                    ),
                  ),
                ],

                if (
                previousData.isNotEmpty ||
                    newData.isNotEmpty
                ) ...[
                  const SizedBox(
                    height: 10,
                  ),

                  _changes(
                    previousData:
                    previousData,
                    newData:
                    newData,
                  ),
                ],

                const SizedBox(
                  height: 8,
                ),

                Wrap(
                  spacing: 10,
                  runSpacing: 5,
                  children: [
                    if (
                    item['ip'] != null &&
                        item['ip']
                            .toString()
                            .isNotEmpty
                    )
                      _metadata(
                        Icons
                            .language_rounded,
                        item['ip']
                            .toString(),
                      ),

                    if (
                    item['id_audit'] !=
                        null
                    )
                      _metadata(
                        Icons
                            .fingerprint_rounded,
                        'Registro #${item['id_audit']}',
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _changes({
    required Map<String, dynamic>
    previousData,
    required Map<String, dynamic>
    newData,
  }) {
    final keys = <String>{
      ...previousData.keys,
      ...newData.keys,
    };

    final visibleKeys =
    keys.where((key) {
      final normalized =
      key.toLowerCase();

      return !normalized.contains(
        'password',
      ) &&
          !normalized.contains(
            'token',
          ) &&
          !normalized.contains(
            'hash',
          ) &&
          !normalized.contains(
            'secret',
          );
    }).toList();

    if (visibleKeys.isEmpty) {
      return const SizedBox.shrink();
    }

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children:
      visibleKeys.map((key) {
        final previous =
        previousData[key];

        final next =
        newData[key];

        if (
        previous?.toString() ==
            next?.toString()
        ) {
          return const SizedBox
              .shrink();
        }

        return Container(
          padding:
          const EdgeInsets.symmetric(
            horizontal: 9,
            vertical: 7,
          ),
          decoration:
          BoxDecoration(
            color: Global.container,
            borderRadius:
            BorderRadius.circular(
              9,
            ),
            border:
            Border.all(
              color: Global.text
                  .withOpacity(0.08),
            ),
          ),
          child: Column(
            crossAxisAlignment:
            CrossAxisAlignment.start,
            children: [
              Text(
                _fieldLabel(key),
                style:
                GoogleFonts.poppins(
                  color: Global
                      .textSecondary,
                  fontSize: 8.5,
                ),
              ),
              const SizedBox(
                height: 2,
              ),
              Text(
                '${_displayValue(previous)} → ${_displayValue(next)}',
                style:
                GoogleFonts.poppins(
                  color:
                  Global.text,
                  fontSize: 9,
                  fontWeight:
                  FontWeight.w600,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _metadata(
      IconData icon,
      String value,
      ) {
    return Row(
      mainAxisSize:
      MainAxisSize.min,
      children: [
        Icon(
          icon,
          color:
          Global.textSecondary,
          size: 12,
        ),
        const SizedBox(
          width: 4,
        ),
        Text(
          value,
          style:
          GoogleFonts.poppins(
            color:
            Global.textSecondary,
            fontSize: 8.5,
          ),
        ),
      ],
    );
  }

  Widget _pagination() {
    final pagination =
        userController
            .AuditPagination;

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

    if (
    totalPages <= 1 &&
        total <= 15
    ) {
      return const SizedBox
          .shrink();
    }

    return Container(
      margin:
      const EdgeInsets.only(
        top: 6,
      ),
      padding:
      const EdgeInsets.symmetric(
        vertical: 8,
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              '$total registros · Página $page de $totalPages',
              style:
              GoogleFonts.poppins(
                color:
                Global.textSecondary,
                fontSize: 9.5,
              ),
            ),
          ),

          IconButton(
            tooltip:
            'Página anterior',
            onPressed:
            page > 1
                ? () => _loadAudit(
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
                ? () => _loadAudit(
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

  Widget _loading() {
    return Container(
      width: double.infinity,
      constraints:
      const BoxConstraints(
        minHeight: 260,
      ),
      alignment:
      Alignment.center,
      child:
      CircularProgressIndicator(
        color:
        Global.primary,
      ),
    );
  }

  Widget _empty() {
    return Container(
      width: double.infinity,
      constraints:
      const BoxConstraints(
        minHeight: 260,
      ),
      padding:
      const EdgeInsets.all(30),
      alignment:
      Alignment.center,
      child: Column(
        mainAxisSize:
        MainAxisSize.min,
        children: [
          Icon(
            Icons
                .history_toggle_off_rounded,
            color: Global
                .textSecondary
                .withOpacity(0.60),
            size: 46,
          ),
          const SizedBox(
            height: 12,
          ),
          Text(
            'Sin actividad registrada',
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
            'Las acciones administrativas y de seguridad aparecerán aquí.',
            textAlign:
            TextAlign.center,
            style:
            GoogleFonts.poppins(
              color:
              Global.textSecondary,
              fontSize: 10,
            ),
          ),
          const SizedBox(
            height: 12,
          ),
          TextButton.icon(
            onPressed:
                () => _loadAudit(),
            icon:
            const Icon(
              Icons.refresh_rounded,
            ),
            label:
            const Text(
              'Actualizar',
            ),
          ),
        ],
      ),
    );
  }

  _AuditVisual _actionVisual(
      String action,
      ) {
    final normalized =
    action.toUpperCase();

    if (
    normalized.contains(
      'PASSWORD',
    )
    ) {
      return const _AuditVisual(
        label:
        'Contraseña actualizada',
        icon:
        Icons.key_rounded,
        color:
        Color(0xFF7657D6),
      );
    }

    if (
    normalized.contains('BLOCK')
    ) {
      return const _AuditVisual(
        label:
        'Usuario bloqueado',
        icon:
        Icons.lock_rounded,
        color:
        Color(0xFFD84A4A),
      );
    }

    if (
    normalized.contains(
      'ACCESS',
    ) ||
        normalized.contains(
          'STATUS',
        )
    ) {
      return const _AuditVisual(
        label:
        'Estado de acceso modificado',
        icon:
        Icons
            .verified_user_rounded,
        color:
        Color(0xFFE49B22),
      );
    }

    if (
    normalized.contains('ROLE')
    ) {
      return const _AuditVisual(
        label:
        'Rol modificado',
        icon:
        Icons.badge_rounded,
        color:
        Color(0xFF3578D4),
      );
    }

    if (
    normalized.contains(
      'UPDATE',
    ) ||
        normalized.contains(
          'EDIT',
        )
    ) {
      return _AuditVisual(
        label:
        'Información actualizada',
        icon:
        Icons.edit_rounded,
        color:
        Global.primary,
      );
    }

    return _AuditVisual(
      label:
      _fieldLabel(action),
      icon:
      Icons.history_rounded,
      color:
      Global.primary,
    );
  }

  String _actorText(
      Map<String, dynamic> item,
      ) {
    final actorName =
        item['actor_nombre']
            ?.toString() ??
            'Sistema';

    final actorEmail =
        item['actor_email']
            ?.toString() ??
            '';

    if (actorEmail.isEmpty) {
      return 'Realizado por $actorName';
    }

    return 'Realizado por $actorName · $actorEmail';
  }

  String _fieldLabel(
      String value,
      ) {
    return value
        .replaceAll('_', ' ')
        .toLowerCase()
        .split(' ')
        .where(
          (item) => item.isNotEmpty,
    )
        .map(
          (item) =>
      item[0].toUpperCase() +
          item.substring(1),
    )
        .join(' ');
  }

  String _displayValue(
      dynamic value,
      ) {
    if (value == null) {
      return 'Sin dato';
    }

    if (value is bool) {
      return value
          ? 'Sí'
          : 'No';
    }

    final text =
    value.toString();

    return text.isEmpty
        ? 'Sin dato'
        : text;
  }

  String _formatDate(
      dynamic value,
      ) {
    if (value == null) {
      return 'Sin fecha';
    }

    final date =
    DateTime.tryParse(
      value.toString(),
    );

    if (date == null) {
      return 'Sin fecha';
    }

    final local =
    date.toLocal();

    String twoDigits(
        int number,
        ) {
      return number
          .toString()
          .padLeft(
        2,
        '0',
      );
    }

    return '${twoDigits(local.day)}/'
        '${twoDigits(local.month)}/'
        '${local.year} · '
        '${twoDigits(local.hour)}:'
        '${twoDigits(local.minute)}';
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

class _AuditVisual {
  final String label;
  final IconData icon;
  final Color color;

  const _AuditVisual({
    required this.label,
    required this.icon,
    required this.color,
  });
}