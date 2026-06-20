import 'package:finanzas_verdes/app/config/Global.dart';
import 'package:finanzas_verdes/app/routes/subrutes/adminRoutes.dart';
import 'package:finanzas_verdes/app/routes/subrutes/asesorRoutes.dart';
import 'package:finanzas_verdes/main.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class Bottommenuasesor extends StatefulWidget {
  const Bottommenuasesor({super.key});

  @override
  State<Bottommenuasesor> createState() => _BottommenuasesorState();
}

class _BottommenuasesorState extends State<Bottommenuasesor> {
  final modules = [
    {"nombre" : "Inicio", "logo" : Icons.home_filled, "route" : AsesorRoutes.home, "inPage" : [AsesorRoutes.home]},
    {"nombre" : "Clientes", "logo" : Icons.groups, "route" : AsesorRoutes.clients, "inPage" : [
      AsesorRoutes.clients,
      AsesorRoutes.newClient,
      AsesorRoutes.editClient,
      AsesorRoutes.dashBoardClient,
      AsesorRoutes.newMipyme,
      AsesorRoutes.editMipyme,
      AsesorRoutes.newActivo,
      AsesorRoutes.editActivo,
      AsesorRoutes.newConsumo,
      AsesorRoutes.editConsumo
    ]},
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
            color: Global.container
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