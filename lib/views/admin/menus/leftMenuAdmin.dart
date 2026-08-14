import 'package:finanzas_verdes/app/config/Global.dart';
import 'package:finanzas_verdes/app/config/Images.dart';
import 'package:finanzas_verdes/app/routes/subrutes/adminRoutes.dart';
import 'package:finanzas_verdes/main.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class Leftmenuadmin extends StatefulWidget {
  const Leftmenuadmin({super.key});

  @override
  State<Leftmenuadmin> createState() => _LeftmenuadminState();
}

class _LeftmenuadminState extends State<Leftmenuadmin> {

  final modules = [
    {
      "nombre": "Inicio",
      "logo": Icons.home_filled,
      "route": Adminroutes.home,
      "inPage": [Adminroutes.home]
    },
    {
      "nombre": "Usuarios",
      "logo": Icons.person,
      "route": Adminroutes.users,
      "inPage": [
        Adminroutes.users,
        Adminroutes.newUser,
        Adminroutes.editUser
      ]
    },
    {
      "nombre": "Roles",
      "logo": Icons.admin_panel_settings,
      "route": Adminroutes.rols,
      "inPage": [
        Adminroutes.rols,
        Adminroutes.newRol,
        Adminroutes.editRol,
      ]
    },
    {
      "nombre": "Permisos",
      "logo": Icons.security,
      "route": Adminroutes.permissions,
      "inPage": [
        Adminroutes.permissions,
        Adminroutes.newPermission,
        Adminroutes.editPermission
      ]
    },
    {"nombre" : "Proveedores", "logo" : Icons.work, "route" : Adminroutes.homeProveedores, "inPage" : [Adminroutes.homeProveedores]},
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
                    size: 30,
                    color: Global.primary,
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

                  final bool isSelected =
                  (module["inPage"] as List).any(
                          (item) => item == controller.Page);

                  return Tooltip(
                    message: nombre,
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

                /// SECCION MÁS
                if (!isCollapsed)
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 15),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text("Más"),
                    ),
                  ),

                const SizedBox(height: 5),

                ListTile(
                  dense: true,
                  contentPadding: EdgeInsets.symmetric(
                      horizontal: isCollapsed ? 8 : 16),
                  leading: Icon(
                    controller.isDark.value
                        ? CupertinoIcons.sun_max_fill
                        : CupertinoIcons.moon_fill,
                  ),
                  title:
                  isCollapsed ? null : const Text("Cambiar tema"),
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
                  title: isCollapsed
                      ? null
                      : const Text("Configuración"),
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
            contentPadding: EdgeInsets.symmetric(
                horizontal: isCollapsed ? 8 : 16),

            leading:
            const Icon(CupertinoIcons.person_alt_circle),

            title: isCollapsed
                ? null
                : Text(controller.User["nombre_usuario"],
                maxLines: 1),

            subtitle: isCollapsed
                ? null
                : Text(controller.User["email"], maxLines: 1),

            trailing: isCollapsed
                ? null // 🔥 evita error de ancho
                : InkWell(
              onTap: controller.logOut,
              child: const Padding(
                padding: EdgeInsets.all(8),
                child:
                Icon(Icons.logout_outlined),
              ),
            ),
          )
        ],
      ),
    ));
  }
}