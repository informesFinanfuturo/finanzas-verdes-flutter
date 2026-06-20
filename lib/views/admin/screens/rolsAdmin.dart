import 'package:finanzas_verdes/app/config/Global.dart';
import 'package:finanzas_verdes/app/routes/subrutes/adminRoutes.dart';
import 'package:finanzas_verdes/controllers/RolController.dart';
import 'package:finanzas_verdes/controllers/UserController.dart';
import 'package:finanzas_verdes/main.dart';
import 'package:finanzas_verdes/models/api/rolApi.dart';
import 'package:finanzas_verdes/models/api/userApi.dart';
import 'package:finanzas_verdes/utils/WidgetsApp.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class Rolsadmin extends StatefulWidget {
  const Rolsadmin({super.key});

  @override
  State<Rolsadmin> createState() => _RolsadminState();
}

class _RolsadminState extends State<Rolsadmin> {
  final RolController rolController = Get.put(RolController());

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getRolsApi(rolController: rolController);
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
        builder: (context, constrains){
          return SizedBox(
            height: constrains.maxHeight,
            child: SingleChildScrollView(
              child: Obx(() => Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  InkWell(
                    borderRadius: BorderRadius.circular(15),
                    onTap: (){
                      controller.setPage(Adminroutes.newRol);
                    },
                    child: Container(
                      width: 220,
                      height: 220,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15),
                          color: Global.container
                      ),
                      child: Center(
                        child: Icon(Icons.add_circle, color: Global.textSecondary, size: 50,),
                      ),
                    ),
                  ),
                  ...
                  rolController.rols.map<Widget>((rol) {
                    return InkWell(
                      borderRadius: BorderRadius.circular(15),
                      onTap: (){
                        rolController.setRol(rol);
                        controller.setPage(Adminroutes.editRol);
                      },
                      child: Container(
                        width: 220,
                        height: 220,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(15),
                            color: Global.container
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(rol["nombre_rol"], style: TextStyle(fontSize: 15),),
                            Text(rol["estado"], style: TextStyle(color: Global.text.withOpacity(0.7)),),
                            SizedBox(height: 5,),
                            Icon(Icons.sentiment_satisfied_alt, color: Global.textSecondary, size: 50,),
                            SizedBox(height: 10,),
                          ],
                        ),
                      ),
                    );
                  }).toList()
                ],
              )),
            ),
          );
        }
    );
  }
}
