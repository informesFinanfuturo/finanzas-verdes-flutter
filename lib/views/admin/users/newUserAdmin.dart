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
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class Newuseradmin
    extends StatefulWidget {
  const Newuseradmin({
    super.key,
  });

  @override
  State<Newuseradmin>
  createState() =>
      _NewuseradminState();
}

class _NewuseradminState
    extends State<Newuseradmin> {
  final formKey =
  GlobalKey<FormState>();

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

  final RolController rolController =
  Get.isRegistered<RolController>()
      ? Get.find<RolController>()
      : Get.put(RolController());

  final UserController userController =
  Get.isRegistered<UserController>()
      ? Get.find<UserController>()
      : Get.put(UserController());

  final ProveedorController
  proveedorController =
  Get.isRegistered<
      ProveedorController>()
      ? Get.find<
      ProveedorController>()
      : Get.put(
    ProveedorController(),
  );

  int? selectedRol;

  bool loading = false;
  bool loadingReferences = true;

  @override
  void initState() {
    super.initState();

    userController
        .setTiposProveedor([]);

    WidgetsBinding.instance
        .addPostFrameCallback((_) {
      _loadReferences();
    });
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
        'No fue posible cargar los roles o categorías.',
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

  String get selectedRoleName {
    if (selectedRol == null) {
      return '';
    }

    for (
    final role
    in rolController.Rols
    ) {
      final id =
      _toInt(
        role['id_rol'],
      );

      if (id == selectedRol) {
        return role['nombre_rol']
            ?.toString()
            .trim()
            .toLowerCase() ??
            '';
      }
    }

    return '';
  }

  bool get isAdvisor =>
      selectedRoleName ==
          'asesor';

  bool get isProvider =>
      selectedRoleName ==
          'proveedor';

  @override
  Widget build(
      BuildContext context,
      ) {
    final screenWidth =
        MediaQuery.sizeOf(
          context,
        ).width;

    final isMobile =
        screenWidth < 800;

    return SingleChildScrollView(
      physics:
      const AlwaysScrollableScrollPhysics(),
      padding:
      EdgeInsets.only(
        bottom:
        isMobile
            ? 120
            : 24,
      ),
      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          _header(
            isMobile,
          ),

          const SizedBox(
            height: 18,
          ),

          _securityNotice(),

          const SizedBox(
            height: 16,
          ),

          Container(
            width: double.infinity,
            padding:
            const EdgeInsets.all(
              20,
            ),
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
            child: Form(
              key:
              formKey,
              child: LayoutBuilder(
                builder: (
                    context,
                    constraints,
                    ) {
                  final fieldWidth =
                  constraints
                      .maxWidth >=
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
                    CrossAxisAlignment
                        .start,
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
                            width:
                            fieldWidth,
                            child:
                            _input(
                              documentoCtrl,
                              'Documento',
                              Icons
                                  .badge_outlined,
                            ),
                          ),
                          SizedBox(
                            width:
                            fieldWidth,
                            child:
                            _input(
                              nombreCtrl,
                              'Nombre del usuario',
                              Icons
                                  .person_outline_rounded,
                            ),
                          ),
                          SizedBox(
                            width:
                            fieldWidth,
                            child:
                            _input(
                              emailCtrl,
                              'Correo electrónico',
                              Icons
                                  .email_outlined,
                              keyboardType:
                              TextInputType
                                  .emailAddress,
                              email:
                              true,
                            ),
                          ),
                          SizedBox(
                            width:
                            fieldWidth,
                            child:
                            _input(
                              telefonoCtrl,
                              'Teléfono',
                              Icons
                                  .phone_outlined,
                              required:
                              false,
                              keyboardType:
                              TextInputType
                                  .phone,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(
                        height: 26,
                      ),

                      _sectionTitle(
                        'Rol y perfil',
                        'El rol determina los permisos y datos complementarios.',
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

                      if (isAdvisor) ...[
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
                              child:
                              _input(
                                nombreCargoCtrl,
                                'Nombre del cargo',
                                Icons
                                    .work_outline_rounded,
                              ),
                            ),
                            SizedBox(
                              width:
                              fieldWidth,
                              child:
                              _input(
                                sedeCtrl,
                                'Sede',
                                Icons
                                    .location_on_outlined,
                              ),
                            ),
                          ],
                        ),
                      ],

                      if (isProvider) ...[
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
                              child:
                              _input(
                                razonSocialCtrl,
                                'Razón social',
                                Icons
                                    .business_outlined,
                              ),
                            ),
                            SizedBox(
                              width:
                              fieldWidth,
                              child:
                              _numberInput(
                                nitCtrl,
                                'NIT',
                                Icons
                                    .credit_card_outlined,
                              ),
                            ),
                            SizedBox(
                              width:
                              fieldWidth,
                              child:
                              _input(
                                direccionCtrl,
                                'Dirección',
                                Icons
                                    .location_on_outlined,
                              ),
                            ),
                            SizedBox(
                              width:
                              fieldWidth,
                              child:
                              _input(
                                calificacionCtrl,
                                'Calificación',
                                Icons
                                    .star_outline_rounded,
                                required:
                                false,
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
                          height: 24,
                        ),

                        _providerCategories(),
                      ],

                      const SizedBox(
                        height: 28,
                      ),

                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child:
                        ElevatedButton.icon(
                          onPressed:
                          loading
                              ? null
                              : _submit,
                          icon:
                          loading
                              ? const SizedBox(
                            width: 18,
                            height: 18,
                            child:
                            CircularProgressIndicator(
                              strokeWidth:
                              2,
                              color:
                              Colors.white,
                            ),
                          )
                              : const Icon(
                            Icons
                                .person_add_alt_1_rounded,
                          ),
                          label:
                          Text(
                            loading
                                ? 'Creando usuario...'
                                : 'Crear usuario',
                          ),
                          style:
                          ElevatedButton
                              .styleFrom(
                            backgroundColor:
                            Global.primary,
                            foregroundColor:
                            Colors.white,
                            elevation: 0,
                            shape:
                            RoundedRectangleBorder(
                              borderRadius:
                              BorderRadius
                                  .circular(
                                13,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
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
          width: 5,
        ),

        Container(
          width: 45,
          height: 45,
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
                .person_add_alt_1_rounded,
            color:
            Global.primary,
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
                'Nuevo usuario',
                style:
                GoogleFonts.poppins(
                  color:
                  Global.text,
                  fontSize:
                  isMobile
                      ? 17
                      : 20,
                  fontWeight:
                  FontWeight.w700,
                ),
              ),
              Text(
                'Crea una cuenta y asigna sus responsabilidades.',
                maxLines: 2,
                overflow:
                TextOverflow.ellipsis,
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
      ],
    );
  }

  Widget _securityNotice() {
    return Container(
      width: double.infinity,
      padding:
      const EdgeInsets.all(15),
      decoration:
      BoxDecoration(
        color: Global.primary
            .withOpacity(0.07),
        borderRadius:
        BorderRadius.circular(15),
        border:
        Border.all(
          color: Global.primary
              .withOpacity(0.16),
        ),
      ),
      child: Row(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          Icon(
            Icons
                .verified_user_outlined,
            color:
            Global.primary,
            size: 21,
          ),

          const SizedBox(
            width: 11,
          ),

          Expanded(
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                Text(
                  'Contraseña temporal segura',
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
                  'El sistema generará automáticamente una contraseña temporal. El usuario deberá cambiarla al iniciar sesión.',
                  style:
                  GoogleFonts.poppins(
                    color: Global
                        .textSecondary,
                    fontSize: 9.5,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _roleField() {
    return DropdownButtonFormField<int>(
      initialValue:
      selectedRol,
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
      rolController.Rols
          .map<
          DropdownMenuItem<int>>(
            (role) {
          return DropdownMenuItem<int>(
            value:
            _toInt(
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

          userController
              .setTiposProveedor([]);
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
          fontSize: 10,
        ),
      );
    }

    return Column(
      crossAxisAlignment:
      CrossAxisAlignment.start,
      children: [
        _sectionTitle(
          'Categorías del proveedor',
          'Selecciona los tipos de productos asociados.',
        ),

        const SizedBox(
          height: 10,
        ),

        Wrap(
          spacing: 9,
          runSpacing: 9,
          children:
          types.map<Widget>(
                (type) {
              final id =
              _toInt(
                type[
                'id_tipo_proveedor'],
              );

              final selected =
              userController
                  .TiposProveedor
                  .contains(id);

              return FilterChip(
                selected:
                selected,
                label:
                Text(
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
                  0.15,
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
      TextEditingController
      textController,
      String hint,
      IconData icon, {
        bool required = true,
        bool email = false,
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
      validator: (value) {
        final normalized =
            value?.trim() ?? '';

        if (
        required &&
            normalized.isEmpty
        ) {
          return 'Campo obligatorio';
        }

        if (
        email &&
            normalized.isNotEmpty &&
            !RegExp(
              r'^[^@\s]+@[^@\s]+\.[^@\s]+$',
            ).hasMatch(normalized)
        ) {
          return 'Correo no válido';
        }

        return null;
      },
    );
  }

  Widget _numberInput(
      TextEditingController
      textController,
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

  Future<void> _submit() async {
    if (
    formKey.currentState
        ?.validate() !=
        true
    ) {
      return;
    }

    if (selectedRol == null) {
      return;
    }

    setState(() {
      loading = true;
    });

    try {
      final result =
      await newUserApi(
        documento:
        documentoCtrl.text,
        nombreUsuario:
        nombreCtrl.text,
        email:
        emailCtrl.text,
        telefono:
        telefonoCtrl.text
            .trim()
            .isEmpty
            ? null
            : telefonoCtrl.text,
        idRol:
        selectedRol!,
        userController:
        userController,

        nombreCargo:
        isAdvisor
            ? nombreCargoCtrl.text
            : null,

        sede:
        isAdvisor
            ? sedeCtrl.text
            : null,

        razonSocial:
        isProvider
            ? razonSocialCtrl.text
            : null,

        nit:
        isProvider
            ? nitCtrl.text
            : null,

        direccion:
        isProvider
            ? direccionCtrl.text
            : null,

        calificacion:
        isProvider
            ? double.tryParse(
          calificacionCtrl
              .text,
        )
            : null,

        tiposProveedores:
        isProvider
            ? userController
            .TiposProveedor
            .toList()
            : null,
      );

      final temporaryPassword =
      result[
      'temporary_password']
          ?.toString();

      if (
      temporaryPassword == null ||
          temporaryPassword.isEmpty
      ) {
        throw Exception(
          'El servidor creó el usuario, pero no devolvió la contraseña temporal',
        );
      }

      await _showTemporaryPassword(
        temporaryPassword:
        temporaryPassword,
        userName:
        nombreCtrl.text.trim(),
      );

      controller.setPage(
        Adminroutes.users,
      );
    } catch (error) {
      Get.snackbar(
        'No fue posible crear el usuario',
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

  Future<void>
  _showTemporaryPassword({
    required String
    temporaryPassword,
    required String userName,
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
          Colors.black
              .withOpacity(0.45),
          elevation: 24,
          clipBehavior:
          Clip.antiAlias,
          insetPadding:
          const EdgeInsets
              .symmetric(
            horizontal: 20,
            vertical: 24,
          ),
          shape:
          RoundedRectangleBorder(
            borderRadius:
            BorderRadius.circular(
              20,
            ),
          ),
          title:
          const Text(
            'Usuario creado',
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
                  'Comparte esta contraseña temporal de manera segura con $userName.',
                  style:
                  GoogleFonts.poppins(
                    color: Global
                        .textSecondary,
                    fontSize: 11,
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
                      0.09,
                    ),
                    borderRadius:
                    BorderRadius
                        .circular(
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
                  height: 13,
                ),

                Text(
                  'Esta contraseña solo se mostrará una vez. El usuario deberá cambiarla al iniciar sesión.',
                  style:
                  GoogleFonts.poppins(
                    color: Global
                        .textSecondary,
                    fontSize: 9.5,
                    height: 1.5,
                  ),
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
                  'La contraseña fue copiada al portapapeles.',
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
              ElevatedButton
                  .styleFrom(
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
      barrierColor:
      Colors.black.withOpacity(
        0.72,
      ),
    );
  }

  Color _dialogBackground() {
    return controller.isDark.value
        ? const Color(0xFF172832)
        : Colors.white;
  }

  int _toInt(
      dynamic value,
      ) {
    if (value is int) {
      return value;
    }

    return int.tryParse(
      value?.toString() ?? '',
    ) ??
        0;
  }
}