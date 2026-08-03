import 'package:finanzas_verdes/app/config/Global.dart';
import 'package:finanzas_verdes/app/config/Images.dart';
import 'package:finanzas_verdes/app/routes/subrutes/asesorRoutes.dart';
import 'package:finanzas_verdes/app/routes/subrutes/clienteRoutes.dart';
import 'package:finanzas_verdes/main.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class Leftmenucliente extends StatefulWidget {
  const Leftmenucliente({super.key});

  @override
  State<Leftmenucliente> createState() => _LeftmenuclienteState();
}

class _LeftmenuclienteState extends State<Leftmenucliente> {

  final modules = [
    {"nombre" : "Inicio", "logo" : Icons.home_filled, "route" : ClienteRoutes.home, "inPage" : [ClienteRoutes.home]},
    {"nombre" : "Activos", "logo" : Icons.electric_bolt, "route" : ClienteRoutes.activos, "inPage" : [ClienteRoutes.activos]},
    {"nombre" : "Facturas", "logo" : Icons.receipt_long, "route" : ClienteRoutes.consumos, "inPage" : [ClienteRoutes.consumos]},
    {"nombre" : "Diagnósticos", "logo" : Icons.psychology, "route" : ClienteRoutes.diagnosticos, "inPage" : [ClienteRoutes.diagnosticos]},
  ];

  bool isCollapsed = false;

  @override
  Widget build(BuildContext context) {

    if (MediaQuery.of(context).size.width < 800) {
      return const SizedBox();
    }

    return Obx(() => AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      width: isCollapsed ? 80 : 300,
      height: double.infinity,
      color: Global.container,
      child: Column(
        children: [

          /// HEADER
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              mainAxisAlignment: isCollapsed
                  ? MainAxisAlignment.start
                  : MainAxisAlignment.spaceBetween,
              children: [
                if (!isCollapsed)
                  Image.asset(Images.logo, width: 30),

                InkWell(
                  onTap: () {
                    setState(() => isCollapsed = !isCollapsed);
                  },
                  child: Icon(
                    isCollapsed ? Icons.menu : Icons.menu_open,
                    color: Global.primary,
                    size: 30,
                  ),
                )
              ],
            ),
          ),

          const SizedBox(height: 10),

          /// MENU PRINCIPAL
          Expanded(
            child: Column(
              children: [

                ...modules.map<Widget>((module) {
                  final IconData logo = module["logo"] as IconData;
                  final String nombre = module["nombre"] as String;
                  final String route = module["route"] as String;

                  final bool isSelected = (module["inPage"] as List)
                      .any((item) => item == controller.Page);

                  return Tooltip(
                    message: nombre, // ✅ tooltip pro en colapsado
                    child: ListTile(
                      dense: true,
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: isCollapsed ? 8 : 16,
                      ),

                      leading: Icon(
                        logo,
                        color: isSelected
                            ? Global.primary
                            : Global.textSecondary,
                      ),

                      title: isCollapsed
                          ? null
                          : Text(
                        nombre,
                        style: TextStyle(
                          color: isSelected
                              ? Global.primary
                              : Global.textSecondary,
                        ),
                      ),

                      onTap: () => controller.setPage(route),
                    ),
                  );
                }),

                /// SECCIÓN MÁS
                if (!isCollapsed)
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 15),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text("Más"),
                    ),
                  ),

                const SizedBox(height: 5),

                /// TEMA
                ListTile(
                  dense: true,
                  contentPadding: EdgeInsets.symmetric(
                      horizontal: isCollapsed ? 8 : 16),
                  leading: Icon(controller.isDark.value
                      ? CupertinoIcons.sun_max_fill
                      : CupertinoIcons.moon_fill),
                  title: isCollapsed ? null : const Text("Cambiar tema"),
                  subtitle: isCollapsed
                      ? null
                      : Text(controller.isDark.value
                      ? 'Modo claro'
                      : 'Modo oscuro'),
                  onTap: controller.toggleTheme,
                ),

                ListTile(
                  dense: true,
                  contentPadding: EdgeInsets.symmetric(
                      horizontal: isCollapsed ? 8 : 16),
                  leading: const Icon(CupertinoIcons.info),
                  title: isCollapsed ? null : const Text("Acerca de"),
                ),

                ListTile(
                  dense: true,
                  contentPadding: EdgeInsets.symmetric(
                      horizontal: isCollapsed ? 8 : 16),
                  leading: const Icon(CupertinoIcons.doc_text),
                  title: isCollapsed ? null : const Text("Términos"),
                ),

                ListTile(
                  dense: true,
                  contentPadding: EdgeInsets.symmetric(
                      horizontal: isCollapsed ? 8 : 16),
                  leading: const Icon(CupertinoIcons.gear),
                  title: isCollapsed ? null : const Text("Configuración"),
                ),
              ],
            ),
          ),

          /// FOOTER USER
          controller.User["nombre_usuario"] == null
              ? const Padding(
            padding: EdgeInsets.all(20),
            child: CircularProgressIndicator(),
          )
              : ListTile(
            dense: true,
            contentPadding:
            EdgeInsets.symmetric(horizontal: isCollapsed ? 8 : 16),

            leading: const Icon(CupertinoIcons.person_alt_circle),

            title: isCollapsed
                ? null
                : Text(controller.User["nombre_usuario"],
                maxLines: 1),

            subtitle: isCollapsed
                ? null
                : Text(controller.User["email"], maxLines: 1),

            trailing: isCollapsed
                ? null // ✅ CLAVE: evita el crash
                : InkWell(
              onTap: controller.logOut,
              child: const Padding(
                padding: EdgeInsets.all(8),
                child: Icon(Icons.logout_outlined),
              ),
            ),
          ),
        ],
      ),
    ));
  }
}