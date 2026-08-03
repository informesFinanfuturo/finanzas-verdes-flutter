import 'package:finanzas_verdes/app/config/Global.dart';
import 'package:finanzas_verdes/app/routes/subrutes/adminRoutes.dart';
import 'package:finanzas_verdes/app/routes/subrutes/asesorRoutes.dart';
import 'package:finanzas_verdes/controllers/ClientController.dart';
import 'package:finanzas_verdes/controllers/UserController.dart';
import 'package:finanzas_verdes/main.dart';
import 'package:finanzas_verdes/models/api/clientApi.dart';
import 'package:finanzas_verdes/models/api/userApi.dart';
import 'package:finanzas_verdes/utils/WidgetsApp.dart';
import 'package:finanzas_verdes/utils/autoScroll.dart';
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
    getClientApi(clientController: clientController);
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
        builder: (context, constrains){
          return SizedBox(
            height: constrains.maxHeight,
            child: Obx(() => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _searchBar(),
                    ),
                    SizedBox(width: 10),
                    _searchButton(),
                  ],
                ),
                SizedBox(height: 10,),
                Expanded(
                  child: SingleChildScrollView(
                    child: SizedBox(
                      width: double.infinity,
                      child: Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: [
                          InkWell(
                            borderRadius: BorderRadius.circular(15),
                            onTap: (){
                              //controller.setPage(AsesorRoutes.newClient);
                              controller.setPage(AsesorRoutes.newClientMipyme);
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
                          clientController.clients.where((client) {

                            final filtro = search.value;

                            if (filtro.isEmpty) {
                              return true;
                            }

                            final nombre = (client["nombre_usuario"] ?? "")
                                .toString()
                                .toLowerCase();

                            final empresa = (client["nombre_mipyme"] ?? "")
                                .toString()
                                .toLowerCase();

                            final documento = (client["documento"] ?? "")
                                .toString()
                                .toLowerCase();

                            return nombre.contains(filtro) ||
                                empresa.contains(filtro) ||
                                documento.contains(filtro);

                          }).map<Widget>((client) {
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
                                    Text(client["nombre_mipyme"] ?? client["nombre_usuario"], style: TextStyle(fontSize: 15), textAlign: TextAlign.center,),
                                    Text(client["nombre_mipyme"] == null ? client["email"] : client["nombre_usuario"], style: TextStyle(color: Global.text.withOpacity(0.7)),),
                                    SizedBox(height: 5,),
                                    Icon(CupertinoIcons.person_alt_circle, color: Global.textSecondary, size: 50,),
                                    SizedBox(height: 10,),
                                    AutoScrollRow(
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
                                                Icon(CupertinoIcons.location_solid, color: Global.contrast, size: 20,),
                                                Text(client["municipio"] ?? "Sin municipio", style: TextStyle(color: Global.contrast),),
                                              ],
                                            ),
                                          ),
                                        ),
                                        SizedBox(width: 5,),
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
                                                Icon(Icons.phone, color: Global.contrast, size: 20,),
                                                Text(client["telefono"], style: TextStyle(color: Global.contrast),),
                                              ],
                                            ),
                                          ),
                                        ),
                                        SizedBox(width: 5,),
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
                                                Icon(Icons.apartment, color: Global.contrast, size: 20,),
                                                Text(client["tipo_empresa"] ?? " - ", style: TextStyle(color: Global.contrast),),
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
                          }).toList(),
                          SizedBox(width: double.infinity,)
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            )),
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
        "Buscar cliente o empresa",
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

  Widget _searchButton() {
    return ElevatedButton.icon(
      icon: const Icon(Icons.search),
      label: const Text("Buscar"),
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(
          horizontal: 15,
          vertical: 15,
        ),
      ),
      onPressed: () async {

        if (searchCtrl.text.trim().isEmpty) {
          Get.snackbar(
            "Error",
            "Ingrese un NIT o documento",
          );
          return;
        }

        try {

          final cliente =
          await searchClient(
            query: searchCtrl.text.trim(),
          );

          clientController.setClient(
            await getClientDetailApi(idUsuario: cliente["id_usuario"]),
          );

          controller.setPage(
            AsesorRoutes.dashBoardClient,
          );

        } catch (e) {

          Get.snackbar(
            "Error",
            e.toString(),
          );
        }
      },
    );
  }
}
