import 'package:finanzas_verdes/app/config/Global.dart';
import 'package:finanzas_verdes/app/routes/subrutes/adminRoutes.dart';
import 'package:finanzas_verdes/app/routes/subrutes/asesorRoutes.dart';
import 'package:finanzas_verdes/app/routes/subrutes/clienteRoutes.dart';
import 'package:finanzas_verdes/main.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class Bottommenucliente extends StatefulWidget {
  const Bottommenucliente({super.key});

  @override
  State<Bottommenucliente> createState() => _BottommenuclienteState();
}

class _BottommenuclienteState extends State<Bottommenucliente> {
  final modules = [
    {"nombre" : "Inicio", "logo" : Icons.home_filled, "route" : ClienteRoutes.home, "inPage" : [ClienteRoutes.home]},
    {"nombre" : "Activos", "logo" : Icons.electric_bolt, "route" : ClienteRoutes.activos, "inPage" : [ClienteRoutes.activos]},
    {"nombre" : "Facturas", "logo" : Icons.receipt_long, "route" : ClienteRoutes.consumos, "inPage" : [ClienteRoutes.consumos]},
    {"nombre" : "Diagnósticos", "logo" : Icons.psychology, "route" : ClienteRoutes.diagnosticos, "inPage" : [ClienteRoutes.diagnosticos]},
    {"nombre" : "Más", "logo" : Icons.menu, "route" : ClienteRoutes.more, "inPage" : [ClienteRoutes.more]},
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