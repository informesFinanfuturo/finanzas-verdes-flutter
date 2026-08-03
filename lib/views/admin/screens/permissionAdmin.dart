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
  final searchCtrl = TextEditingController();
  final search = ''.obs;

  @override
  void dispose() {
    searchCtrl.dispose();
    super.dispose();
  }

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
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(child: _searchBar()),
                  SizedBox(width: 10),
                  _permissionCounter(),
                ],
              ),
              SizedBox(height: 10,),
              Expanded(
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
                      permissionController.Permissions.where((client) {

                        final filtro = search.value;

                        if (filtro.isEmpty) {
                          return true;
                        }

                        final nombre = (client["nombre"] ?? "")
                            .toString()
                            .toLowerCase();

                        return nombre.contains(filtro);

                      }).map<Widget>((permission) {
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
              ),
            ],
          );
        }
    );
  }

  Widget _searchBar() {
    return TextField(
      controller: searchCtrl,
      onChanged: (value) {
        search.value = value.toLowerCase().trim();
        setState(() {});
      },
      decoration: Wapp.TextFieldDecoration(
        Global.primary,
        true,
        "Buscar permiso",
        Icons.search,
      ).copyWith(
        suffixIcon: searchCtrl.text.isEmpty
            ? null
            : IconButton(
          icon: const Icon(Icons.close),
          onPressed: () {
            searchCtrl.clear();
            search.value = '';
            setState(() {});
          },
        ),
      ),
    );
  }

  Widget _permissionCounter() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 15,
        vertical: 10,
      ),
      decoration: BoxDecoration(
        color: Global.container,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Obx(
            () => Text(
          """${
              permissionController.Permissions.where((client) {

                final filtro = search.value;

                if (filtro.isEmpty) {
                  return true;
                }

                final nombre = (client["nombre"] ?? "")
                    .toString()
                    .toLowerCase();

                return nombre.contains(filtro);

              }).length
          } permisos""",
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
