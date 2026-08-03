import 'package:finanzas_verdes/app/config/Global.dart';
import 'package:finanzas_verdes/app/routes/subrutes/adminRoutes.dart';
import 'package:finanzas_verdes/main.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class Bottommenuadmin extends StatefulWidget {
  const Bottommenuadmin({super.key});

  @override
  State<Bottommenuadmin> createState() => _BottommenuadminState();
}

class _BottommenuadminState extends State<Bottommenuadmin> {
  final modules = [
    {"nombre" : "Inicio", "logo" : Icons.home_filled, "route" : Adminroutes.home, "inPage" : [Adminroutes.home]},
    {"nombre" : "Usuarios", "logo" : Icons.person, "route" : Adminroutes.users, "inPage" : [Adminroutes.users, Adminroutes.newUser, Adminroutes.editUser]},
    {"nombre" : "Roles", "logo" : Icons.admin_panel_settings, "route" : Adminroutes.rols, "inPage" : [Adminroutes.rols, Adminroutes.editRol, Adminroutes.newRol]},
    {"nombre" : "Permisos", "logo" : Icons.security, "route" : Adminroutes.permissions, "inPage" : [Adminroutes.permissions, Adminroutes.newPermission, Adminroutes.editPermission]},
    {"nombre" : "Más", "logo" : Icons.menu, "route" : Adminroutes.more, "inPage" : [Adminroutes.more]},
  ];
  @override
  Widget build(BuildContext context) {
    if(MediaQuery.of(context).size.width >= 800){
      return SizedBox();
    }else{
      return Obx(() => Container(
        height: 75,
        width: double.infinity,
        decoration: BoxDecoration(
          color: Global.container,
          boxShadow: [
            // 🌫 sombra principal (volumen)
            BoxShadow(
              color: Colors.black.withOpacity(0.25),
              offset: Offset(0, 8),
              blurRadius: 20,
              spreadRadius: -5,
            ),

            // 💡 sombra suave (profundidad)
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              offset: Offset(0, 4),
              blurRadius: 10,
              spreadRadius: -2,
            ),

            // 🔷 toque moderno (muy sutil color)
            BoxShadow(
              color: Global.primary.withOpacity(0.05),
              offset: Offset(0, 2),
              blurRadius: 8,
              spreadRadius: 0,
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: modules.map((module){
            final IconData logo = module["logo"] as IconData;
            final String nombre = module["nombre"] as String;
            final bool isSelected = (module["inPage"] as List).any((item) => item == controller.Page);
            final String route = module["route"] as String;
            return InkWell(
                borderRadius: BorderRadius.circular(15),
                onTap: (){
                  controller.setPage(route);
                },
                child: Column(
                  children: [
                    Icon(logo, color: isSelected ? Global.primary : Global.textSecondary, size: 50,),
                    Text(nombre, style: TextStyle(color: isSelected ? Global.primary : Global.textSecondary),)
                  ],
                )
            );
          }).toList(),
        ),
      ));
    }
  }
}