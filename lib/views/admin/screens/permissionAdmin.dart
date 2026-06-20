import 'package:finanzas_verdes/app/config/Global.dart';
import 'package:finanzas_verdes/app/routes/subrutes/adminRoutes.dart';
import 'package:finanzas_verdes/controllers/PermissionController.dart';
import 'package:finanzas_verdes/controllers/UserController.dart';
import 'package:finanzas_verdes/main.dart';
import 'package:finanzas_verdes/models/api/permissionApi.dart';
import 'package:finanzas_verdes/models/api/userApi.dart';
import 'package:finanzas_verdes/utils/WidgetsApp.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class Permissionsadmin extends StatefulWidget {
  const Permissionsadmin({super.key});

  @override
  State<Permissionsadmin> createState() => _PermissionsadminState();
}

class _PermissionsadminState extends State<Permissionsadmin> {
  final PermissionController permissionController = Get.put(PermissionController());

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getPermissionsApi(permissionController: permissionController);
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
                      controller.setPage(Adminroutes.newPermission);
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
                  permissionController.Permissions.map<Widget>((permission) {
                    return InkWell(
                      borderRadius: BorderRadius.circular(15),
                      onTap: (){
                        permissionController.setPermission(permission);
                        controller.setPage(Adminroutes.editPermission);
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
                            Text(permission["nombre"], style: TextStyle(fontSize: 15),),
                            Text(permission["estado"], style: TextStyle(color: Global.text.withOpacity(0.7)),),
                            SizedBox(height: 5,),
                            Icon(Icons.key, color: Global.textSecondary, size: 50,),
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
