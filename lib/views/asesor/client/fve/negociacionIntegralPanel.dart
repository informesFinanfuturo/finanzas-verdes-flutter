import 'package:finanzas_verdes/app/config/Global.dart';
import 'package:finanzas_verdes/models/api/fveApi.dart';
import 'package:finanzas_verdes/models/api/fveNegociacionApi.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class NegociacionIntegralPanel extends StatefulWidget {
  final Map<String,dynamic> proceso;
  final Future<void> Function() onRefresh;
  final Future<void> Function() onBack;
  final Future<void> Function() onDiagnostico;
  const NegociacionIntegralPanel({super.key,required this.proceso,
    required this.onRefresh,required this.onBack,required this.onDiagnostico});
  @override State<NegociacionIntegralPanel> createState()=>_NegociacionIntegralPanelState();
}

class _NegociacionIntegralPanelState extends State<NegociacionIntegralPanel> {
  static const etiquetas=['Inicio','Confirmar activos','Propuesta','PDF','Decisión','Financiación','Viabilidad','Cierre'];
  Map<String,dynamic> info={};
  List<Map<String,dynamic>> seleccion=[];
  bool cargando=true, trabajando=false;
  String? error;
  String decision='interesado',modalidad='recursos_propios',credito='no_aplica';
  bool propiosConfirmados=false;
  final TextEditingController observacion=TextEditingController();
  final TextEditingController propios=TextEditingController(text:'0');
  final TextEditingController solicitado=TextEditingController(text:'0');
  final TextEditingController aprobado=TextEditingController(text:'0');
  final TextEditingController soporte=TextEditingController();

  int get idProceso=>_numero(widget.proceso['id_proceso']);
  int get paso=>_numero(widget.proceso['paso_actual']).clamp(1,8).toInt();
  static int _numero(dynamic x)=>x is num?x.toInt():int.tryParse('$x')??0;
  static String _texto(dynamic x,[String alt=''])=>x==null||x.toString().isEmpty?alt:x.toString();
  static Map<String,dynamic> _mapa(dynamic x)=>x is Map?Map<String,dynamic>.from(x):<String,dynamic>{};
  static List<Map<String,dynamic>> _lista(dynamic x)=>x is List?x.whereType<Map>().map((m)=>Map<String,dynamic>.from(m)).toList():[];
  static String pesos(dynamic valor){final n=num.tryParse('$valor')??0;
    return NumberFormat.currency(locale:'es_CO',symbol:r'$',decimalDigits:0).format(n);}
  @override void initState(){super.initState();WidgetsBinding.instance.addPostFrameCallback((_)=>_cargar());}
  @override void didUpdateWidget(covariant NegociacionIntegralPanel old){
    super.didUpdateWidget(old);
    if(old.proceso['paso_actual']!=widget.proceso['paso_actual']||
       old.proceso['id_proceso']!=widget.proceso['id_proceso']) {
      WidgetsBinding.instance.addPostFrameCallback((_)=>_cargar());
    }
  }
  @override void dispose(){observacion.dispose();propios.dispose();solicitado.dispose();aprobado.dispose();soporte.dispose();super.dispose();}
  Future<void> _cargar() async {
    if(!mounted || idProceso<=0)return;
    setState((){cargando=true;error=null;});
    try{
      final r=await FveNegociacionApi.solicitud(idProceso,'GET','');
      final a=await obtenerSeleccionFveApi(idProceso:idProceso);
      if(!mounted)return;
      setState((){info=r;seleccion=_lista(a['lineas']);});
      if(paso==6 && propios.text=='0' && solicitado.text=='0') {
        final props=_lista(r['propuestas']);
        if(props.isNotEmpty) propios.text='${_numero(props.first['total_inversion'])}';
      }
      if(paso==7 && credito=='no_aplica') {
        final fin=_lista(r['financiaciones']);
        if(fin.isNotEmpty && _numero(fin.first['credito_solicitado'])>0) credito='pendiente';
      }
    }catch(e){if(mounted)setState(()=>error=e.toString());}
    finally{if(mounted)setState(()=>cargando=false);}
  }
  Future<void> _accion(String ruta,[Map<String,dynamic>? datos]) async{
    if(trabajando)return;
    setState(()=>trabajando=true);
    try{
      await FveNegociacionApi.solicitud(idProceso,'POST',ruta,datos ?? {});
      if(!mounted)return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content:Text('Operación guardada correctamente.')));
      await widget.onRefresh();
      if(mounted)await _cargar();
    }catch(e){if(mounted)ScaffoldMessenger.of(context).showSnackBar(SnackBar(content:Text(e.toString())));}
    finally{if(mounted)setState(()=>trabajando=false);}
  }
  Future<void> _volverSeleccion() async{
    if(trabajando || seleccion.isEmpty)return;
    setState(()=>trabajando=true);
    try{
      await guardarSeleccionFveApi(idProceso:idProceso,lineas:seleccion.map((l)=>{
        'id_activo':_numero(l['id_activo']),
        'id_item':l['id_item'] == null?null:_numero(l['id_item']),
        'cantidad':_numero(l['cantidad']),
      }).toList());
      if(!mounted)return;
      await widget.onRefresh();
    }catch(e){if(mounted)ScaffoldMessenger.of(context).showSnackBar(SnackBar(content:Text(e.toString())));}
    finally{if(mounted)setState(()=>trabajando=false);}
  }
  Future<void> _descargar(Map<String,dynamic> prop) async{
    if(trabajando)return;
    setState(()=>trabajando=true);
    try{
      final bytes=await FveNegociacionApi.pdf(idProceso,_numero(prop['id_propuesta']));
      final destino = await FilePicker.saveFile(
        dialogTitle:'Guardar propuesta FVE',
        fileName:'FVE_${idProceso}_V${prop['numero_version']}.pdf',
        mimeType:'application/pdf',
        type:FileType.custom,allowedExtensions:['pdf'],bytes:bytes,
      );
      // Si se cancela la seleccion de destino, no afirmar que se guardo el PDF.
      if(!mounted || destino == null) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content:Text('Propuesta PDF guardada correctamente.')));
    }catch(e){if(mounted)ScaffoldMessenger.of(context).showSnackBar(SnackBar(content:Text(e.toString())));}
    finally{if(mounted)setState(()=>trabajando=false);}
  }
  Widget _boton(String etiqueta,VoidCallback? fn,{bool principal=true}) =>
    principal?FilledButton(onPressed:trabajando?null:fn,child:Text(etiqueta)):
      OutlinedButton(onPressed:trabajando?null:fn,child:Text(etiqueta));
  Widget _campo(TextEditingController c,String titulo,{bool numerico=false})=>
    TextField(controller:c,keyboardType:numerico?TextInputType.number:TextInputType.text,
      decoration:InputDecoration(labelText:titulo,isDense:true,border:const OutlineInputBorder()));
  Widget _menu(String titulo,String valor,List<String> opciones,ValueChanged<String?> cambio)=>
    DropdownButtonFormField<String>(value:valor,isExpanded:true,
      decoration:InputDecoration(labelText:titulo,isDense:true,border:const OutlineInputBorder()),
      items:opciones.map((e)=>DropdownMenuItem<String>(value:e,child:Text(e.replaceAll('_',' ')))).toList(),
      onChanged:trabajando?null:cambio);

  Widget _pasos() => LayoutBuilder(builder:(context,c){
    return SingleChildScrollView(scrollDirection:Axis.horizontal,child:SizedBox(
      width:c.maxWidth<740?740:c.maxWidth,
      child:Row(children:List.generate(8,(index){
        final n=index+1,hecho=n<paso,actual=n==paso;
        final color=n<=paso?Global.primary:Global.textSecondary;
        return Expanded(child:Column(mainAxisSize:MainAxisSize.min,children:[
          Row(children:[Expanded(child:Divider(color:index==0?Colors.transparent:color.withOpacity(.35))),
            CircleAvatar(radius:13,backgroundColor:hecho?Global.primary:Global.container,
              child:hecho?const Icon(Icons.check,color:Colors.white,size:14):
                Text('$n',style:TextStyle(color:color,fontSize:12,fontWeight:actual?FontWeight.bold:FontWeight.normal))),
            Expanded(child:Divider(color:index==7?Colors.transparent:color.withOpacity(.35)))]),
          const SizedBox(height:5),
          Text(etiquetas[index],style:TextStyle(color:color,fontSize:10,fontWeight:actual?FontWeight.bold:FontWeight.normal),
            maxLines:1,overflow:TextOverflow.ellipsis),
        ]));
      }))));
  });
  Widget _producto(Map<String,dynamic> l,{bool listaOriginal=false}){
    final desde=listaOriginal?_texto(l['activo_nombre'],'Activo'):_texto(l['activo_nombre'],'Activo');
    final hacia=listaOriginal?_texto(l['nombre_producto'],'Producto por elegir'):_texto(l['producto_nombre'],'Producto');
    final precio=listaOriginal?l['precio_base']:l['precio_unitario'];
    final cantidad=_numero(l['cantidad']);
    final subtotal=listaOriginal?(num.tryParse('$precio')??0)*cantidad:l['subtotal'];
    final proveedor=_texto(listaOriginal?l['nombre_proveedor']:l['proveedor_nombre'],'Proveedor sin registrar');
    final ahorro=l['ahorro_estimado_anual'];
    return Padding(padding:const EdgeInsets.symmetric(vertical:8),child:Column(
      crossAxisAlignment:CrossAxisAlignment.start,children:[
        Text('$desde  →  $hacia',style:TextStyle(fontWeight:FontWeight.w600,color:Global.text)),
        Text('Proveedor: $proveedor',style:TextStyle(color:Global.textSecondary,fontSize:12)),
        Text('$cantidad unidad(es) · ${pesos(precio)} por unidad · Subtotal ${pesos(subtotal)}',
          style:TextStyle(color:Global.textSecondary,fontSize:12)),
        if(!listaOriginal) Text('Estado ambiental: ${_texto(l['estado_ambiental'],'pendiente_dato')}',
          style:TextStyle(color:Global.textSecondary,fontSize:12)),
        if(ahorro!=null && !listaOriginal) Text('Ahorro técnico estimado anual: $ahorro ${_texto(l['unidad_ahorro'])}',
          style:TextStyle(color:Global.textSecondary,fontSize:12)),
      ]));
  }
  Map<String,dynamic>? get ultima => _lista(info['propuestas']).isEmpty?null:_lista(info['propuestas']).first;
  Map<String,dynamic>? get presentada {
    for(final p in _lista(info['propuestas'])) {if(p['estado']=='presentada')return p;}
    return null;
  }
  Map<String,dynamic>? get cierre => info['cierre'] is Map?_mapa(info['cierre']):null;
  Widget _contenido(){
    final prop=ultima,actual=presentada;
    if(paso==3){
      return Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
        const Text('Productos confirmados',style:TextStyle(fontWeight:FontWeight.w600)),
        for(final l in seleccion)_producto(l,listaOriginal:true),
        const Divider(),
        const Text('La propuesta tomará el precio vigente del catálogo. Los ahorros no verificados permanecerán pendientes.',
          style:TextStyle(fontSize:12)),
        const SizedBox(height:12),
        _campo(observacion,'Observación (opcional)'),const SizedBox(height:10),
        Wrap(spacing:10,runSpacing:8,children:[
          _boton('Editar selección',_volverSeleccion,principal:false),
          _boton('Generar borrador',()=>_accion('/propuesta',{'observacion':observacion.text})),
        ])
      ]);
    }
    if(paso==4){
      final d=_mapa(prop?['detalle']);
      return Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
        Text('Borrador V${prop?['numero_version'] ?? '-'} · ${pesos(d['total_inversion'])}',
          style:TextStyle(color:Global.text,fontSize:16,fontWeight:FontWeight.w600)),
        for(final l in _lista(d['lineas']))_producto(l),
        const Text('Revisa precios y elegibilidad. Al presentar se genera un PDF inmutable.',style:TextStyle(fontSize:12)),
        const SizedBox(height:12),
        Wrap(spacing:10,runSpacing:8,children:[
          _boton('Actualizar borrador',()=>_accion('/propuesta',{'observacion':observacion.text}),principal:false),
          _boton('Presentar y generar PDF',()=>_accion('/presentar')),
        ]),
      ]);
    }
    if(paso==5){
      final d=_lista(info['decisiones']);
      final eventos=_lista(info['historial']);
      final reanudada=eventos.isNotEmpty && eventos.first['accion']=='NEGOCIACION_REANUDADA';
      final suspendida=d.isNotEmpty&&d.first['decision']=='suspendido'&&!reanudada;
      return Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
        Text('Propuesta presentada V${actual?['numero_version'] ?? '-'} · ${pesos(actual?['total_inversion'])}',
          style:TextStyle(color:Global.text,fontWeight:FontWeight.w600)),
        const SizedBox(height:10),
        if(actual!=null)_boton('Guardar PDF',()=>_descargar(actual),principal:false),
        const SizedBox(height:12),
        if(suspendida)...[
          const Text('Negociación suspendida. Puedes retomarla y registrar una nueva decisión.'),
          _boton('Reanudar',()=>_accion('/reanudar')),
        ]else...[
          _menu('Decisión del cliente',decision,['interesado','suspendido','desinteresado'],(x)=>setState(()=>decision=x??decision)),
          const SizedBox(height:8),_campo(observacion,'Observaciones del cliente'),const SizedBox(height:8),
          _boton('Registrar decisión',()=>_accion('/decision',{'decision':decision,'observacion':observacion.text})),
        ],
      ]);
    }
    if(paso==6){
      final total=_numero(actual?['total_inversion']);
      return Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
        Text('Inversión de la propuesta: ${pesos(total)}',style:TextStyle(color:Global.text,fontWeight:FontWeight.w600)),
        const SizedBox(height:12),
        _menu('Modalidad',modalidad,['recursos_propios','credito_finanfuturo','mixta'],(x){
          setState(() {modalidad=x??modalidad;
            if(modalidad=='recursos_propios'){propios.text='$total';solicitado.text='0';}
            if(modalidad=='credito_finanfuturo'){propios.text='0';solicitado.text='$total';}
          });
        }),
        const SizedBox(height:8),_campo(propios,'Recursos propios (COP)',numerico:true),
        const SizedBox(height:8),_campo(solicitado,'Crédito solicitado (COP)',numerico:true),
        const SizedBox(height:8),_campo(observacion,'Observación (opcional)'),
        const SizedBox(height:10),
        _boton('Guardar financiación',()=>_accion('/financiacion',{
          'modalidad':modalidad,'recursos_propios':_numero(propios.text),
          'credito_solicitado':_numero(solicitado.text),'observacion':observacion.text,
        })),
      ]);
    }
    if(paso==7){
      final f=_lista(info['financiaciones']);
      final financiacion=f.isEmpty?<String,dynamic>{}:f.first;
      final usaCredito=_numero(financiacion['credito_solicitado'])>0;
      final resultado=_lista(info['viabilidades']);
      final ultimo=resultado.isNotEmpty?resultado.first:<String,dynamic>{};
      return Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
        Text('Modalidad: ${_texto(financiacion['modalidad']).replaceAll('_',' ')}',style:TextStyle(color:Global.text,fontWeight:FontWeight.w600)),
        const SizedBox(height:8),
        CheckboxListTile(contentPadding:EdgeInsets.zero,dense:true,
          value:propiosConfirmados,title:const Text('Cliente confirma disponer de recursos propios (declarativo)'),
          onChanged:trabajando?null:(x)=>setState(()=>propiosConfirmados=x??false)),
        if(usaCredito)...[
          const SizedBox(height:8),_menu('Resultado crediticio',credito,['pendiente','aprobado','rechazado'],
            (x)=>setState(()=>credito=x??credito)),
          const SizedBox(height:8),_campo(aprobado,'Monto crédito aprobado (COP)',numerico:true),
          const SizedBox(height:8),_campo(soporte,'Referencia de soporte de aprobación'),
        ],
        const SizedBox(height:8),_campo(observacion,'Observación'),
        const SizedBox(height:10),
        Wrap(spacing:10,runSpacing:8,children:[
          _boton('Registrar viabilidad',()=>_accion('/viabilidad',{
            'recursos_propios_confirmados':propiosConfirmados,
            'estado_credito':usaCredito?credito:'no_aplica',
            'monto_credito_aprobado':usaCredito?_numero(aprobado.text):0,
            'referencia_soporte':soporte.text,'observacion':observacion.text,
          })),
          if(ultimo['estado']=='no_viable')
            _boton('Reformular propuesta',()=>_accion('/reformular',{'observacion':observacion.text}),principal:false),
        ]),
        const SizedBox(height:8),
        const Text('El registro no aprueba créditos. Solo Administración puede registrar una aprobación crediticia sustentada.',style:TextStyle(fontSize:12)),
      ]);
    }
    if(paso==8){
      if(cierre!=null){
        final nombre=cierre?['tipo_cierre']=='aceptada'?'Negociación aceptada':'Negociación desistida';
        return Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
          Text(nombre,style:TextStyle(color:Global.text,fontSize:17,fontWeight:FontWeight.bold)),
          if(actual!=null) _boton('Descargar propuesta aceptada',()=>_descargar(actual),principal:false),
        ]);
      }
      final faltantes=_lista(_mapa(actual?['detalle'])['lineas']).where((l)=>l['estado_ambiental']!='elegible').length;
      return Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
        Text('Financiación viable · Propuesta V${actual?['numero_version']}',style:TextStyle(color:Global.text,fontWeight:FontWeight.w600)),
        const SizedBox(height:8),
        if(faltantes>0)Text('Pendiente: $faltantes equipo(s) requieren elegibilidad técnica antes de cerrar como verde.',
          style:const TextStyle(color:Colors.orange)),
        const SizedBox(height:8),_campo(observacion,'Observación de aceptación'),
        const SizedBox(height:10),
        _boton('Aceptar y cerrar',faltantes>0?null:()=>_accion('/aceptar',{'observacion':observacion.text})),
      ]);
    }
    return const Text('El proceso todavía no está en una etapa comercial.');
  }
  @override Widget build(BuildContext context){
    final p=widget.proceso;
    return Column(children:[
      Container(color:Global.container,padding:const EdgeInsets.symmetric(horizontal:12,vertical:5),
        child:Row(children:[
          IconButton(tooltip:'Volver',onPressed:widget.onBack,icon:const Icon(Icons.arrow_back)),
          const SizedBox(width:4),Expanded(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
            Text('Negociación verde · Paso $paso de 8',style:TextStyle(color:Global.text,fontSize:17,fontWeight:FontWeight.bold)),
            Text(_texto(p['nombre_mipyme'],'Empresa'),maxLines:1,overflow:TextOverflow.ellipsis,
              style:TextStyle(color:Global.textSecondary,fontSize:12)),
          ])),
          IconButton(tooltip:'Actualizar',onPressed:cargando?null:_cargar,icon:const Icon(Icons.refresh)),
        ])),
      Expanded(child:ListView(padding:const EdgeInsets.all(16),children:[
        _pasos(),const SizedBox(height:12),
        Container(padding:const EdgeInsets.all(14),decoration:BoxDecoration(
          color:Global.container,borderRadius:BorderRadius.circular(12),
          border:Border.all(color:Global.textSecondary.withOpacity(.16))),
          child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
            Row(children:[
              Expanded(child:Text(etiquetas[paso-1],style:TextStyle(color:Global.text,fontWeight:FontWeight.w700,fontSize:16))),
              TextButton(onPressed:widget.onDiagnostico,child:const Text('Ver diagnóstico')),
            ]),const Divider(),
            if(cargando)const LinearProgressIndicator()
            else if(error!=null)...[
              Text(error!,style:const TextStyle(color:Colors.red)),
              const SizedBox(height:8),_boton('Reintentar',_cargar,principal:false),
            ]else _contenido(),
          ])),
        if(!cargando&&error==null&&(_lista(info['historial']).isNotEmpty||_lista(info['propuestas']).isNotEmpty))...[
          const SizedBox(height:8),ExpansionTile(title:const Text('Versiones e historial'),children:[
            for(final prop in _lista(info['propuestas']))
              ListTile(dense:true,title:Text('Propuesta V${prop['numero_version']} · ${_texto(prop['estado'])}'),
                subtitle:Text(pesos(prop['total_inversion'])),
                trailing:prop['estado']=='presentada'?
                  TextButton(onPressed:()=>_descargar(prop),child:const Text('PDF')):null),
            for(final e in _lista(info['historial']))
              ListTile(dense:true,title:Text(_texto(e['accion']).replaceAll('_',' ')),
                subtitle:Text(_texto(e['created_at']))),
          ])
        ],
      ])),
    ]);
  }
}
