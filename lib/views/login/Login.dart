import 'package:finanzas_verdes/app/config/Global.dart';
import 'package:finanzas_verdes/app/config/Images.dart';
import 'package:finanzas_verdes/app/routes/routeNames.dart';
import 'package:finanzas_verdes/main.dart';
import 'package:finanzas_verdes/models/api/userApi.dart';
import 'package:finanzas_verdes/utils/WidgetsApp.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool showPassword = false;
  final FocusNode emailFocus = FocusNode();
  final FocusNode passwordFocus = FocusNode();

  @override
  void dispose() {
    emailFocus.dispose();
    passwordFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final _ = controller.isDark.value;
      return Scaffold(
        body: SizedBox(
          height: double.infinity,
          width: double.infinity,
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 500),
                child: SafeArea(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final bool isWide = constraints.maxWidth >= 800;

                      return Center(
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.all(20),
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(
                              maxWidth: 500,
                            ),
                            child: Container(
                              padding: const EdgeInsets.all(24),
                              decoration: BoxDecoration(
                                color: Global.container,
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.08),
                                    blurRadius: 20,
                                    offset: const Offset(0, 10),
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  // 🌙 Toggle tema
                                  Align(
                                    alignment: Alignment.topRight,
                                    child: InkWell(
                                      onTap: (){
                                        controller.toggleTheme();
                                      },
                                      borderRadius: BorderRadius.circular(15),
                                      child: CircleAvatar(
                                        backgroundColor:
                                        Global.primary.withOpacity(0.2),
                                        child: Icon(
                                          controller.isDark.value
                                              ? CupertinoIcons.moon_fill
                                              : Icons.wb_sunny_rounded,
                                          color: Global.primary,
                                        ),
                                      ),
                                    ),
                                  ),

                                  // 🖼️ Logo
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Image.asset(
                                        Images.logo,
                                        height: isWide ? 140 : 110,
                                      ),
                                      Container(
                                        margin: EdgeInsets.only(left: 30, right: 10),
                                        height: isWide ? 100 : 80,
                                        width: 1,
                                        color: Global.text.withOpacity(0.3),
                                      ),
                                      SizedBox(width: 10,),
                                      Image.asset(
                                        width: 130,
                                        Images.logoFinanfuturo,
                                        height: isWide ? 140 : 110,
                                      ),
                                    ],
                                  ),

                                  const SizedBox(height: 30),
                                  Text(
                                    "Inicio de sesión",
                                    textAlign: TextAlign.center,
                                    style: GoogleFonts.poppins(
                                      color: Global.text,
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),

                                  const SizedBox(height: 30),

                                  // 📧 Email
                                  TextField(
                                    focusNode: emailFocus,
                                    controller: emailController,
                                    textInputAction: TextInputAction.next,
                                    decoration: Wapp.TextFieldDecoration(
                                      Global.text,
                                      true,
                                      "Email",
                                      Icons.person,
                                    ),
                                  ),

                                  const SizedBox(height: 20),

                                  // 🔒 Password
                                  TextField(
                                    focusNode: passwordFocus,
                                    controller: passwordController,
                                    textInputAction: TextInputAction.done,
                                    obscureText: !showPassword,
                                    decoration:
                                    InputDecoration(
                                      border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(15),
                                          borderSide: BorderSide(
                                              color: Global.text
                                          )
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(15),
                                          borderSide: BorderSide(
                                            color: Colors.transparent,
                                          )
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(15),
                                          borderSide: BorderSide(
                                              color: Global.text,
                                              width: 2
                                          )
                                      ),
                                      filled: true,
                                      fillColor: Global.text.withOpacity(0.1),
                                      prefixIcon: Icon(Icons.lock, color: Global.text,),
                                      hintText: "Contraseña",
                                      hintStyle: TextStyle(color: Global.text.withOpacity(0.4)),
                                      suffixIcon: InkWell(
                                        onTap: () {
                                          setState(() {
                                            showPassword = !showPassword;
                                          });
                                        },
                                        child: Icon(
                                          showPassword
                                              ? CupertinoIcons.eye_slash_fill
                                              : CupertinoIcons.eye_solid,
                                          color: Global.text,
                                        ),
                                      ),
                                    ),
                                    onSubmitted: (_) async {
                                      await loginUserApi(email: emailController.text, password: passwordController.text);
                                    },
                                  ),

                                  const SizedBox(height: 10),

                                  // ❓ Forgot password
                                  Align(
                                    alignment: Alignment.centerRight,
                                    child: InkWell(
                                      onTap: () {
                                        Get.snackbar(
                                          "Próximamente",
                                          "Funcionalidad no disponible",
                                        );
                                      },
                                      child: Text(
                                        "¿Olvidaste tu contraseña?",
                                        style: TextStyle(
                                          color: Global.text,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),

                                  const SizedBox(height: 30),
                                  
                                  InkWell(
                                    onTap: () async {
                                      await loginUserApi(email: emailController.text, password: passwordController.text);
                                    },
                                    child: Container(
                                      height: 50,
                                      decoration: Wapp.ButtonDecorationGradient(
                                        Global.primary,
                                        Global.secondary,
                                      ),
                                      child: const Center(
                                        child: Text(
                                          "Iniciar sesión",
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),

                                  const SizedBox(height: 10),
                                  
                                  TextButton(
                                    onPressed: () {

                                    },
                                    child: Text(
                                      "Registrarse",
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Global.primary,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ), // tu card actual
              ),
            ),
          ),
        ),
      );
    });
  }
}