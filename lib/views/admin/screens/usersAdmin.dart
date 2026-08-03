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

class Usersadmin extends StatefulWidget {
  const Usersadmin({super.key});

  @override
  State<Usersadmin> createState() => _UsersadminState();
}

class _UsersadminState extends State<Usersadmin> {
  final UserController userController = Get.put(UserController());
  final RolController rolController = Get.put(RolController());

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
    getUsersApi(userController: userController);
    getRolsApi(rolController: rolController);
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
        builder: (context, constrains){
          return SizedBox(
            height: constrains.maxHeight,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Obx(() => SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                      children: [
                        InkWell(
                          onTap: () async {
                            await getUsersApi(userController: userController);
                          },
                          borderRadius: BorderRadius.circular(15),
                          child: Container(
                            margin: EdgeInsets.only(right: 10),
                            padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                            decoration: BoxDecoration(
                              border: Border.all(
                                  color: Global.contrast
                              ),
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: Text("Todos", style: TextStyle(color: Global.contrast),),
                          ),
                        ),
                        ...
                        rolController.Rols.map<Widget>((rol) {
                          return InkWell(
                            onTap: () async {
                              await getUsersByRolApi(userController: userController, idRol: rol["id_rol"]);
                            },
                            borderRadius: BorderRadius.circular(15),
                            child: Container(
                              margin: EdgeInsets.only(right: 10),
                              padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                              decoration: BoxDecoration(
                                border: Border.all(
                                    color: Global.contrast
                                ),
                                borderRadius: BorderRadius.circular(15),
                              ),
                              child: Text(rol["nombre_rol"], style: TextStyle(color: Global.contrast),),
                            ),
                          );
                        }).toList(),
                      ]
                  ),
                ),),
                SizedBox(height: 10,),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(child: _searchBar()),
                    SizedBox(width: 10),
                    _usersCounter(),
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
                            controller.setPage(Adminroutes.newUser);
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
                        userController.Users.where((client) {

                          final filtro = search.value;

                          if (filtro.isEmpty) {
                            return true;
                          }

                          final nombre = (client["nombre_usuario"] ?? "")
                              .toString()
                              .toLowerCase();

                          final email = (client["email"] ?? "")
                              .toString()
                              .toLowerCase();

                          final documento = (client["documento"] ?? "")
                              .toString()
                              .toLowerCase();

                          return nombre.contains(filtro) ||
                              email.contains(filtro) ||
                              documento.contains(filtro);

                        }).map<Widget>((user) {
                          return InkWell(
                            borderRadius: BorderRadius.circular(15),
                            onTap: () async {
                              userController.setUser(await getUserDetailApi(idUsuario: user["id_usuario"]));
                              controller.setPage(Adminroutes.editUser);
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
                                  Text(user["nombre_usuario"], style: TextStyle(fontSize: 15),),
                                  Text(user["email"], style: TextStyle(color: Global.text.withOpacity(0.7)),),
                                  SizedBox(height: 5,),
                                  Icon(CupertinoIcons.person_alt_circle, color: Global.textSecondary, size: 50,),
                                  SizedBox(height: 10,),
                                  Wrap(
                                    spacing: 5,
                                    runSpacing: 5,
                                    children: [
                                      IntrinsicWidth(
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                                          decoration: BoxDecoration(
                                            border: Border.all(
                                                color: Global.contrast
                                            ),
                                            borderRadius: BorderRadius.circular(15),
                                          ),
                                          child: Row(
                                            children: [
                                              Icon(Icons.credit_card, color: Global.contrast, size: 20,),
                                              Text(user["documento"], style: TextStyle(color: Global.contrast),),
                                            ],
                                          ),
                                        ),
                                      ),
                                      IntrinsicWidth(
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                                          decoration: BoxDecoration(
                                            border: Border.all(
                                                color: Global.contrast
                                            ),
                                            borderRadius: BorderRadius.circular(15),
                                          ),
                                          child: Row(
                                            children: [
                                              Icon(Icons.supervised_user_circle, color: Global.contrast, size: 20,),
                                              Text(user["nombre_rol"], style: TextStyle(color: Global.contrast),),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
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
            ),
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
        "Buscar usuario, documento o email",
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
  Widget _usersCounter() {
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
              userController.Users.where((client) {

                final filtro = search.value;

                if (filtro.isEmpty) {
                  return true;
                }

                final nombre = (client["nombre_usuario"] ?? "")
                    .toString()
                    .toLowerCase();

                final email = (client["email"] ?? "")
                    .toString()
                    .toLowerCase();

                final documento = (client["documento"] ?? "")
                    .toString()
                    .toLowerCase();

                return nombre.contains(filtro) ||
                    email.contains(filtro) ||
                    documento.contains(filtro);

              }).length
          } usuarios""",
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
