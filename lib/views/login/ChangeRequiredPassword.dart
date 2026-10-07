import 'package:finanzas_verdes/app/config/Global.dart';
import 'package:finanzas_verdes/app/routes/routeNames.dart';
import 'package:finanzas_verdes/main.dart';
import 'package:finanzas_verdes/models/api/loginApi.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_fonts/google_fonts.dart';

class ChangeRequiredPassword
    extends StatefulWidget {
  const ChangeRequiredPassword({
    super.key,
  });

  @override
  State<ChangeRequiredPassword>
  createState() =>
      _ChangeRequiredPasswordState();
}

class _ChangeRequiredPasswordState
    extends State<ChangeRequiredPassword> {
  final currentPasswordController =
  TextEditingController();

  final newPasswordController =
  TextEditingController();

  final confirmPasswordController =
  TextEditingController();

  bool loading = false;
  bool showCurrentPassword = false;
  bool showNewPassword = false;
  bool showConfirmPassword = false;
  late final bool isRequired;

  @override
  void initState() {
    super.initState();

    final arguments = Get.arguments;

    isRequired = arguments is Map
        ? arguments['required'] != false
        : true;
  }

  @override
  void dispose() {
    currentPasswordController.dispose();
    newPasswordController.dispose();
    confirmPasswordController.dispose();

    super.dispose();
  }

  String? validatePassword() {
    final currentPassword =
        currentPasswordController.text;

    final newPassword =
        newPasswordController.text;

    final confirmation =
        confirmPasswordController.text;

    if (currentPassword.isEmpty) {
      return isRequired
          ? 'Ingresa la contraseña temporal'
          : 'Ingresa tu contraseña actual';
    }

    if (newPassword.length < 8) {
      return 'La contraseña debe tener al menos 8 caracteres';
    }

    if (!RegExp(r'[A-Z]').hasMatch(
      newPassword,
    )) {
      return 'Debe contener al menos una letra mayúscula';
    }

    if (!RegExp(r'[a-z]').hasMatch(
      newPassword,
    )) {
      return 'Debe contener al menos una letra minúscula';
    }

    if (!RegExp(r'[0-9]').hasMatch(
      newPassword,
    )) {
      return 'Debe contener al menos un número';
    }

    if (!RegExp(
      r'[!@#$%^&*(),.?":{}|<>_\-]',
    ).hasMatch(newPassword)) {
      return 'Debe contener al menos un carácter especial';
    }

    if (newPassword == currentPassword) {
      return 'La nueva contraseña debe ser diferente';
    }

    if (newPassword != confirmation) {
      return 'Las contraseñas no coinciden';
    }

    return null;
  }

  Future<void> changePassword() async {
    final validation =
    validatePassword();

    if (validation != null) {
      Get.snackbar(
        'Revisa la contraseña',
        validation,
        colorText: Colors.white,
        backgroundColor: Colors.orange,
        snackPosition:
        SnackPosition.BOTTOM,
        margin:
        const EdgeInsets.all(16),
      );

      return;
    }

    setState(() {
      loading = true;
    });

    try {
      await changeOwnPasswordApi(
        currentPassword:
        currentPasswordController.text,
        newPassword:
        newPasswordController.text,
      );

      final box = GetStorage();

      await box.remove('token');
      await box.remove('user');
      await box.remove(
        'must_change_password',
      );

      controller.setUser({});

      Get.offAllNamed(
        Routes.login,
      );

      Get.snackbar(
        'Contraseña actualizada',
        'Inicia sesión con tu nueva contraseña',
        colorText: Colors.white,
        backgroundColor: Colors.green,
        snackPosition:
        SnackPosition.BOTTOM,
        margin:
        const EdgeInsets.all(16),
      );
    } catch (error) {
      final message = error
          .toString()
          .replaceFirst(
        'Exception: ',
        '',
      );

      Get.snackbar(
        'No fue posible continuar',
        message,
        colorText: Colors.white,
        backgroundColor: Colors.red,
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

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !isRequired,
      child: Scaffold(
        backgroundColor:
        Global.bg,
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(24),
              child: ConstrainedBox(
                constraints:
                const BoxConstraints(
                  maxWidth: 520,
                ),
                child: Container(
                  padding:
                  const EdgeInsets.all(
                    28,
                  ),
                  decoration: BoxDecoration(
                    color:
                    Global.container,
                    borderRadius:
                    BorderRadius.circular(
                      24,
                    ),
                    border: Border.all(
                      color: Global.primary
                          .withOpacity(0.15),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black
                            .withOpacity(0.08),
                        blurRadius: 30,
                        offset:
                        const Offset(
                          0,
                          12,
                        ),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment:
                    CrossAxisAlignment
                        .stretch,
                    children: [
                      if (!isRequired) ...[
                        Align(
                          alignment: Alignment.centerLeft,
                          child: IconButton(
                            onPressed: loading ? null : Get.back,
                            tooltip: 'Regresar',
                            icon: Icon(
                              Icons.arrow_back_rounded,
                              color: Global.text,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                      ],
                      Container(
                        width: 64,
                        height: 64,
                        decoration:
                        BoxDecoration(
                          color: Global
                              .primary
                              .withOpacity(
                            0.12,
                          ),
                          borderRadius:
                          BorderRadius
                              .circular(
                            18,
                          ),
                        ),
                        child: Icon(
                          Icons
                              .lock_reset_rounded,
                          color:
                          Global.primary,
                          size: 32,
                        ),
                      ),

                      const SizedBox(
                        height: 22,
                      ),

                      Text(
                        isRequired
                            ? 'Crea una nueva contraseña'
                            : 'Cambia tu contraseña',
                        style: GoogleFonts.poppins(
                          color: Global.text,
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                        ),
                      ),

                      const SizedBox(
                        height: 8,
                      ),

                      Text(
                        isRequired
                            ? 'Por seguridad debes cambiar la contraseña temporal antes de continuar.'
                            : 'Ingresa tu contraseña actual y establece una nueva contraseña segura.',
                        style: GoogleFonts.poppins(
                          color: Global.textSecondary,
                          fontSize: 13,
                          height: 1.5,
                        ),
                      ),

                      const SizedBox(
                        height: 28,
                      ),

                      _PasswordField(
                        controller:
                        currentPasswordController,
                        label: isRequired
                            ? 'Contraseña temporal'
                            : 'Contraseña actual',
                        visible:
                        showCurrentPassword,
                        onToggle: () {
                          setState(() {
                            showCurrentPassword =
                            !showCurrentPassword;
                          });
                        },
                      ),

                      const SizedBox(
                        height: 16,
                      ),

                      _PasswordField(
                        controller:
                        newPasswordController,
                        label:
                        'Nueva contraseña',
                        visible:
                        showNewPassword,
                        onToggle: () {
                          setState(() {
                            showNewPassword =
                            !showNewPassword;
                          });
                        },
                      ),

                      const SizedBox(
                        height: 16,
                      ),

                      _PasswordField(
                        controller:
                        confirmPasswordController,
                        label:
                        'Confirmar contraseña',
                        visible:
                        showConfirmPassword,
                        onToggle: () {
                          setState(() {
                            showConfirmPassword =
                            !showConfirmPassword;
                          });
                        },
                      ),

                      const SizedBox(
                        height: 18,
                      ),

                      Text(
                        'Debe incluir 8 caracteres, mayúscula, minúscula, número y carácter especial.',
                        style:
                        GoogleFonts.poppins(
                          color: Global
                              .textSecondary,
                          fontSize: 11,
                          height: 1.5,
                        ),
                      ),

                      const SizedBox(
                        height: 24,
                      ),

                      SizedBox(
                        height: 52,
                        child:
                        ElevatedButton(
                          onPressed:
                          loading
                              ? null
                              : changePassword,
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
                                14,
                              ),
                            ),
                          ),
                          child:
                          loading
                              ? const SizedBox(
                            width: 22,
                            height: 22,
                            child:
                            CircularProgressIndicator(
                              strokeWidth:
                              2,
                              color: Colors
                                  .white,
                            ),
                          )
                              : const Text(
                            'Actualizar contraseña',
                            style:
                            TextStyle(
                              fontWeight:
                              FontWeight
                                  .w600,
                            ),
                          ),
                        ),
                      ),
                      if (!isRequired) ...[
                        const SizedBox(height: 10),
                        TextButton(
                          onPressed: loading ? null : Get.back,
                          child: Text(
                            'Cancelar',
                            style: TextStyle(
                              color: Global.textSecondary,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _PasswordField
    extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final bool visible;
  final VoidCallback onToggle;

  const _PasswordField({
    required this.controller,
    required this.label,
    required this.visible,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: !visible,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon:
        const Icon(
          Icons.lock_outline_rounded,
        ),
        suffixIcon: IconButton(
          onPressed: onToggle,
          icon: Icon(
            visible
                ? Icons
                .visibility_off_outlined
                : Icons
                .visibility_outlined,
          ),
        ),
        filled: true,
        fillColor:
        Global.text.withOpacity(
          0.05,
        ),
        border: OutlineInputBorder(
          borderRadius:
          BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        enabledBorder:
        OutlineInputBorder(
          borderRadius:
          BorderRadius.circular(14),
          borderSide: BorderSide(
            color: Global.text
                .withOpacity(0.10),
          ),
        ),
        focusedBorder:
        OutlineInputBorder(
          borderRadius:
          BorderRadius.circular(14),
          borderSide: BorderSide(
            color: Global.primary,
            width: 1.5,
          ),
        ),
      ),
    );
  }
}