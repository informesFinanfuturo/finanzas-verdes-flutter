import 'package:finanzas_verdes/app/config/Global.dart';
import 'package:finanzas_verdes/controllers/ClientController.dart';
import 'package:finanzas_verdes/main.dart';
import 'package:finanzas_verdes/models/api/calendarioApi.dart';
import 'package:finanzas_verdes/models/api/clientApi.dart';
import 'package:finanzas_verdes/views/asesor/asesor/clienteAgendaCard.dart';
import 'package:finanzas_verdes/views/asesor/asesor/clientesTableAsesor.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class Homeasesor extends StatefulWidget {
  const Homeasesor({super.key});

  @override
  State<Homeasesor> createState() => _HomeasesorState();
}

class _HomeasesorState extends State<Homeasesor> {
  ClientController clientController = Get.put(ClientController());

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getClientsAgendaApi();
    getClientApi(clientController: clientController);
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          Text("Agenda de hoy", style: GoogleFonts.poppins(fontSize: 18),),
          SizedBox(height: 10,),
          Container(
            width: MediaQuery.of(context).size.width,
            margin: const EdgeInsets.only(bottom: 20),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: Row(
                  spacing: 16,
                  children: controller.Agenda.map<Widget>((cliente) {
                    return ClienteAgendaCard(
                      cliente: cliente,
                    );

                  }).toList(),
                ),
              ),
            ),
          ),
      
          const SizedBox(height: 20),
      
          Expanded(
            child: ClientesTable(),
          ),
      
        ],
      );
    });
  }
}
