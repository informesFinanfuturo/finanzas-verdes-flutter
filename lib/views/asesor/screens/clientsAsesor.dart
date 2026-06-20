import 'package:finanzas_verdes/app/config/Global.dart';
import 'package:finanzas_verdes/app/routes/subrutes/adminRoutes.dart';
import 'package:finanzas_verdes/app/routes/subrutes/asesorRoutes.dart';
import 'package:finanzas_verdes/controllers/ClientController.dart';
import 'package:finanzas_verdes/controllers/UserController.dart';
import 'package:finanzas_verdes/main.dart';
import 'package:finanzas_verdes/models/api/clientApi.dart';
import 'package:finanzas_verdes/models/api/userApi.dart';
import 'package:finanzas_verdes/utils/WidgetsApp.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart';

class Clientsasesor extends StatefulWidget {
  const Clientsasesor({super.key});

  @override
  State<Clientsasesor> createState() => _ClientsasesorState();
}

class _ClientsasesorState extends State<Clientsasesor> {
  final ClientController clientController = Get.put(ClientController());

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getClientApi(clientController: clientController);
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
                      controller.setPage(AsesorRoutes.newClient);
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
                  clientController.clients.map<Widget>((client) {
                    return InkWell(
                      borderRadius: BorderRadius.circular(15),
                      onTap: () async {
                        clientController.setClient(await getClientDetailApi(idUsuario: client["id_usuario"]));
                        controller.setPage(AsesorRoutes.dashBoardClient);
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
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                InkWell(
                                  onTap: (){
                                    clientController.setClient(client);
                                    controller.setPage(AsesorRoutes.editClient);
                                  },
                                  borderRadius: BorderRadius.circular(15),
                                  child: Icon(Icons.edit),
                                ),
                                SizedBox(width: 10,)
                              ],
                            ),
                            Text(client["nombre_usuario"], style: TextStyle(fontSize: 15),),
                            Text(client["email"], style: TextStyle(color: Global.text.withOpacity(0.7)),),
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
                                        Text(client["documento"], style: TextStyle(color: Global.contrast),),
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
                                        Text(client["nombre_rol"], style: TextStyle(color: Global.contrast),),
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
          );
        }
    );
  }
}
