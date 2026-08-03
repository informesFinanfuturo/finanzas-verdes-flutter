import 'package:finanzas_verdes/controllers/ProveedorController.dart';
import 'package:finanzas_verdes/models/api/proveedorApi.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

void openCreateTipoProveedorDialog() {
  final nombreCtrl = TextEditingController();
  final descripcionCtrl = TextEditingController();
  
  final ProveedorController proveedorController = Get.put(ProveedorController());
  getTipoProveedoresApi(proveedorController: proveedorController);

  final _formKey = GlobalKey<FormState>();

  Get.defaultDialog(
    title: "Nuevo tipo de proveedor",
    radius: 15,
    content: Column(
      children: [
        Form(
          key: _formKey,
          child: Column(
            children: [
        
              // ✅ NOMBRE
              TextFormField(
                controller: nombreCtrl,
                decoration: InputDecoration(
                  labelText: "Nombre",
                  prefixIcon: Icon(Icons.category),
                ),
                validator: (v) =>
                (v == null || v.trim().isEmpty) ? "Campo obligatorio" : null,
              ),
        
              const SizedBox(height: 10),
        
              // ✅ DESCRIPCIÓN
              TextFormField(
                controller: descripcionCtrl,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: "Descripción",
                  prefixIcon: Icon(Icons.description),
                ),
              ),
        
              const SizedBox(height: 20),
        
              Row(
                children: [
        
                  // ❌ CANCELAR
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Get.back(),
                      child: Text("Cancelar"),
                    ),
                  ),
        
                  const SizedBox(width: 10),
        
                  // ✅ GUARDAR
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        if (!_formKey.currentState!.validate()) return;
        
                        try {
                          await createTipoProveedorApi(
                            nombreTipo: nombreCtrl.text.trim(),
                            descripcion: descripcionCtrl.text.trim().isEmpty
                                ? null
                                : descripcionCtrl.text.trim(),
                          );
        
                          Get.back();
        
                          Get.snackbar(
                            "OK",
                            "Tipo de proveedor creado",
                            snackPosition: SnackPosition.BOTTOM,
                          );
        
                        } catch (e) {
                          Get.snackbar(
                            "Error",
                            e.toString(),
                            snackPosition: SnackPosition.BOTTOM,
                          );
                        }
                      },
                      child: Text("Guardar"),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        SizedBox(height: 10,),
        Divider(),
        SizedBox(height: 10,),
        ...
        proveedorController.TiposProveedores.map<Widget>((tipo){
          return Card(
            elevation: 4,
            child: ListTile(
              title: Text(tipo["nombre_tipo"]),
              subtitle: Text(tipo["descripcion"]),
            ),
          );
        })
      ],
    ),
  );
}