import 'package:finanzas_verdes/app/config/Global.dart';
import 'package:finanzas_verdes/models/api/fveApi.dart';
import 'package:finanzas_verdes/models/api/fveNegociacionApi.dart';
import 'package:file_picker/file_picker.dart';
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
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
  static const etiquetas=['Diagnóstico','Reemplazos','Propuesta','Revisar y emitir','Decisión','Financiación','Viabilidad','Cierre'];
  Map<String,dynamic> info={};
  List<Map<String,dynamic>> seleccion=[];
  bool cargando=true, trabajando=false;
  String? error;
  Uint8List? vistaPreviaBytes;
  int? vistaPreviaId;
  bool cargandoVistaPrevia=false;
  String? errorVistaPrevia;
  String? decisionElegida;
  String? errorDecision;
  final TextEditingController motivoDecision = TextEditingController();
  String modalidad='recursos_propios',credito='no_aplica';
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
    if(old.proceso['id_proceso']!=widget.proceso['id_proceso'] ||
      (old.proceso['paso_actual']!=widget.proceso['paso_actual'] && paso==5)) {
      decisionElegida=null;
      errorDecision=null;
      motivoDecision.clear();
    }
    if(old.proceso['paso_actual']!=widget.proceso['paso_actual']||
       old.proceso['id_proceso']!=widget.proceso['id_proceso']) {
      WidgetsBinding.instance.addPostFrameCallback((_)=>_cargar());
    }
  }
  @override void dispose(){motivoDecision.dispose();observacion.dispose();propios.dispose();solicitado.dispose();aprobado.dispose();soporte.dispose();super.dispose();}
  Future<void> _cargar() async {
    if(!mounted || idProceso<=0)return;
    setState((){cargando=true;error=null;});
    try{
      final r=await FveNegociacionApi.solicitud(idProceso,'GET','');
      final a=await obtenerSeleccionFveApi(idProceso:idProceso);
      if(!mounted)return;
      setState((){info=r;seleccion=_lista(a['lineas']);});
      if (paso == 4) {
        final propuestas = _lista(r['propuestas']);
        if (propuestas.isNotEmpty && propuestas.first['estado']=='borrador') {
          final borrar = propuestas.first;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) _actualizarVistaPrevia(borrar);
          });
        }
      } else if (vistaPreviaBytes != null || errorVistaPrevia != null) {
        setState(() { vistaPreviaBytes=null; vistaPreviaId=null; errorVistaPrevia=null; });
      }
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
  Future<void> _actualizarVistaPrevia(Map<String,dynamic> propuesta) async {
    if (cargandoVistaPrevia || !mounted || paso!=4) return;
    final id=_numero(propuesta['id_propuesta']);
    if (id<=0) return;
    setState(() { cargandoVistaPrevia=true; errorVistaPrevia=null; vistaPreviaBytes=null; vistaPreviaId=id; });
    try {
      final bytes=await FveNegociacionApi.vistaPreviaPdf(idProceso,id);
      if (!mounted || paso!=4 || vistaPreviaId!=id) return;
      setState(() => vistaPreviaBytes=bytes);
    } catch(e) {
      if (mounted && paso==4 && vistaPreviaId==id) {
        setState(() => errorVistaPrevia=e.toString());
      }
    } finally {
      if (mounted) setState(() => cargandoVistaPrevia=false);
    }
  }
  Future<void> _confirmarPresentacion() async {
    if (trabajando || cargandoVistaPrevia || vistaPreviaBytes==null) return;
    final aceptar=await showDialog<bool>(
      context:context,
      builder:(ctx)=>AlertDialog(
        title:const Text('Emitir propuesta definitiva'),
        content:const Text('Esta versi\u00f3n se registrar\u00e1 como presentada y no podr\u00e1 editarse. Revisa el PDF antes de continuar.'),
        actions:[
          TextButton(onPressed:()=>Navigator.pop(ctx,false),child:const Text('Cancelar')),
          FilledButton(onPressed:()=>Navigator.pop(ctx,true),child:const Text('Presentar propuesta')),
        ],
      ),
    );
    if (aceptar==true && mounted) await _accion('/presentar');
  }
  Future<void> _registrarDecision() async {
    if(trabajando || cargando || !mounted || paso!=5) return;
    final elegida=decisionElegida;
    if(elegida==null || !['interesado','suspendido','desinteresado'].contains(elegida)) return;
    final motivo=motivoDecision.text.trim();
    if(elegida!='interesado' && motivo.isEmpty){
      setState(()=>errorDecision='Registra el motivo que expresó el cliente antes de continuar.');
      return;
    }
    if(motivo.length>1500){
      setState(()=>errorDecision='La observación no puede superar 1.500 caracteres.');
      return;
    }
    setState(()=>errorDecision=null);
    final nombre=elegida=='interesado' ? 'continuar' : elegida=='suspendido' ? 'esperar' : 'no continuar';
    final consecuencia=elegida=='interesado'
      ? 'Al registrar esta respuesta se avanzará al paso 6.'
      : elegida=='suspendido'
        ? 'La negociación quedará suspendida y podrá reanudarse.'
        : 'Se registrará el desistimiento de esta propuesta y el proceso pasará al cierre.';
    final confirmado=await showDialog<bool>(
      context:context,
      builder:(ctx)=>AlertDialog(
        title:const Text('Confirmar decisión del cliente'),
        content:Text('El cliente decidió $nombre.\n\n$consecuencia\n\n¿Confirmas que esta fue su respuesta?'),
        actions:[
          TextButton(onPressed:()=>Navigator.of(ctx).pop(false),child:const Text('Volver')),
          FilledButton(onPressed:()=>Navigator.of(ctx).pop(true),child:const Text('Confirmar y registrar')),
        ],
      ),
    );
    if(confirmado!=true || !mounted || paso!=5) return;
    await _accion('/decision',{'decision':elegida,'observacion':motivo});
  }

  Future<void> _reanudarDecision() async {
    if(trabajando || !mounted || paso!=5)return;
    await _accion('/reanudar');
    if(!mounted)return;
    final eventos=_lista(info['historial']);
    if(eventos.isNotEmpty && eventos.first['accion']=='NEGOCIACION_REANUDADA'){
      setState((){
        decisionElegida=null;
        errorDecision=null;
        motivoDecision.clear();
      });
    }
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
      final items = seleccion;
      num totalEstimado = 0;
      int equiposConProducto = 0;
      int pendientesSeleccion = 0;
      int elegibles = 0;
      int pendientesElegibilidad = 0;
      final beneficios = <Map<String,String>>[];

      for(final l in items){
        final cantidad = _numero(l['cantidad']) <= 0 ? 1 : _numero(l['cantidad']);
        final precioBase = num.tryParse('${l['precio_base']}') ?? num.tryParse('${l['precio_unitario']}') ?? 0;
        final subtotal = num.tryParse('${l['subtotal']}');
        totalEstimado += subtotal != null && subtotal > 0 ? subtotal : precioBase * cantidad;
        if(l['id_item'] != null){
          equiposConProducto++;
        }else{
          pendientesSeleccion++;
        }
        final ahorro = num.tryParse(_texto(l['ahorro_estimado_anual']));
        final unidad = _texto(l['unidad_ahorro']);
        final estado = _texto(l['estado_ambiental']).toLowerCase();
        if(estado == 'elegible' && ahorro != null && ahorro.isFinite && ahorro > 0 && unidad.isNotEmpty){
          beneficios.add({
            'titulo': _texto(l['activo_nombre'],'Activo'),
            'valor': '$ahorro $unidad',
          });
        }
        if(estado == 'elegible'){
          elegibles++;
        }else if(estado.isEmpty || estado == 'pendiente' || estado == 'pendiente_dato'){
          pendientesElegibilidad++;
        }
      }

      Widget indicador(String titulo, String valor, {String? detalle, bool compacto=false}) {
        return Container(
          width: 220,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Global.container,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Global.textSecondary.withOpacity(.18)),
          ),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(titulo, style: TextStyle(color: Global.textSecondary, fontSize: 12, fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            Text(valor, style: TextStyle(color: Global.text, fontSize: compacto ? 18 : 24, fontWeight: FontWeight.w800)),
            if (detalle != null && detalle.isNotEmpty) ...[
              const SizedBox(height: 6),
              Text(detalle, style: TextStyle(color: Global.textSecondary, fontSize: 12, height: 1.25)),
            ]
          ]),
        );
      }

      Widget bloque(String titulo, List<Widget> children) {
        return Container(
          width: double.infinity,
          margin: const EdgeInsets.only(top: 14),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Global.container,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Global.textSecondary.withOpacity(.18)),
          ),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(titulo, style: TextStyle(color: Global.text, fontSize: 16, fontWeight: FontWeight.w800)),
            const SizedBox(height: 12),
            ...children,
          ]),
        );
      }

      Widget resumenIntervencion(Map<String,dynamic> l) {
        final cantidad = _numero(l['cantidad']) <= 0 ? 1 : _numero(l['cantidad']);
        final precioBase = num.tryParse('${l['precio_base']}') ?? num.tryParse('${l['precio_unitario']}') ?? 0;
        final subtotal = num.tryParse('${l['subtotal']}');
        final valor = subtotal != null && subtotal > 0 ? subtotal : precioBase * cantidad;
        final tieneProducto = l['id_item'] != null;
        return Container(
          width: double.infinity,
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Global.bg,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Global.textSecondary.withOpacity(.14)),
          ),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(_texto(l['activo_nombre'],'Activo del diagnóstico'),
              style: TextStyle(color: Global.text, fontSize: 15, fontWeight: FontWeight.w700)),
            const SizedBox(height: 6),
            Text(tieneProducto ? _texto(l['nombre_producto'],'Producto seleccionado') : 'Sin tecnología seleccionada',
              style: TextStyle(color: Global.textSecondary, fontSize: 13, height: 1.3)),
            const SizedBox(height: 10),
            Wrap(spacing: 16, runSpacing: 8, children: [
              Text('Proveedor: ${_texto(l['nombre_proveedor'],'Pendiente')}',
                style: TextStyle(color: Global.textSecondary, fontSize: 12)),
              Text('Cantidad: $cantidad', style: TextStyle(color: Global.textSecondary, fontSize: 12)),
              Text('Inversión estimada: ${pesos(valor)}',
                style: TextStyle(color: Global.text, fontSize: 12, fontWeight: FontWeight.w700)),
            ]),
          ]),
        );
      }

      return Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
        Text('Propuesta de inversión verde', style: TextStyle(color: Global.text, fontSize: 20, fontWeight: FontWeight.w800)),
        const SizedBox(height:6),
        Text('Aquí se consolida la inversión estimada y la justificación básica de la intervención antes de generar el borrador en PDF.',
          style: TextStyle(color: Global.textSecondary, fontSize: 13, height: 1.35)),
        const SizedBox(height:14),
        Wrap(spacing:12, runSpacing:12, children:[
          indicador('Inversión estimada', pesos(totalEstimado), detalle:'Suma de los productos seleccionados con precio vigente de catálogo.'),
          indicador('Equipos por intervenir', '$equiposConProducto', detalle: pendientesSeleccion > 0 ? '$pendientesSeleccion pendiente(s) de selección.' : 'Todos los equipos tienen tecnología propuesta.'),
          indicador('Beneficio ambiental',
            beneficios.isEmpty ? 'Sin cálculo disponible' :
              (beneficios.length == 1 ? beneficios.first['valor']! : '${beneficios.length} ahorros estimados'),
            detalle: beneficios.isEmpty
              ? 'No hay datos de ahorro en la selección recibida. No significa que el beneficio sea cero.'
              : (beneficios.length == 1
                ? 'Estimación registrada para un activo; consultar su soporte técnico.'
                : 'Consulta cada activo: no se suman ahorros con unidades diferentes.'),
            compacto: true),
        ]),
        bloque('Resumen de las intervenciones',[
          if(items.isEmpty)
            Text('Todavía no hay productos confirmados para esta propuesta.', style: TextStyle(color: Global.textSecondary))
          else
            for(final l in items) resumenIntervencion(l),
        ]),
        bloque('Impacto ambiental esperado',[
          if(beneficios.isEmpty)
            Text('Aún no hay ahorros técnicos consolidados para mostrar en este paso. El borrador mantendrá estos datos como pendientes cuando no exista soporte.',
              style: TextStyle(color: Global.textSecondary, fontSize: 13, height: 1.35))
          else ...[
            for(final b in beneficios)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Expanded(child: Text(b['titulo']!, style: TextStyle(color: Global.text, fontWeight: FontWeight.w600))),
                  const SizedBox(width: 12),
                  Text(b['valor']!, style: TextStyle(color: Global.primary, fontWeight: FontWeight.w700)),
                ]),
              ),
          ],
          const SizedBox(height: 10),
          Text(
            elegibles > 0 || pendientesElegibilidad > 0
              ? 'Elegibilidad ambiental: $elegibles registrada(s) como elegible(s) y $pendientesElegibilidad pendiente(s) de validar.'
              : 'La elegibilidad ambiental se mostrará aquí cuando exista información registrada para las tecnologías seleccionadas.',
            style: TextStyle(color: Global.textSecondary, fontSize: 12, height: 1.3),
          ),
        ]),
        bloque('Justificación y condiciones',[
          Text('• La propuesta se arma con los equipos seleccionados en el diagnóstico y con los precios vigentes del catálogo.',
            style: TextStyle(color: Global.textSecondary, fontSize: 13, height: 1.35)),
          const SizedBox(height: 6),
          Text('• Los beneficios ambientales y de ahorro solo se muestran cuando existe un dato técnico registrado en el proceso.',
            style: TextStyle(color: Global.textSecondary, fontSize: 13, height: 1.35)),
          const SizedBox(height: 6),
          Text('• El paso siguiente genera un borrador que servirá como base del documento formal en PDF.',
            style: TextStyle(color: Global.textSecondary, fontSize: 13, height: 1.35)),
        ]),
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
      final bytes=vistaPreviaBytes;
      final tieneBorrador=prop != null && prop['estado']=='borrador';
      return Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
        Text('Revisar y emitir propuesta',
          style:TextStyle(color:Global.text,fontSize:21,fontWeight:FontWeight.w800)),
        const SizedBox(height:7),
        Text(_texto(d['nombre_mipyme'],_texto(widget.proceso['nombre_mipyme'],'Empresa')),
          style:TextStyle(color:Global.text,fontSize:14)),
        const SizedBox(height:14),
        if(cargandoVistaPrevia) ...[
          const LinearProgressIndicator(),
          const SizedBox(height:10),
          Text('Preparando el PDF real para revisi\u00f3n...',
            style:TextStyle(color:Global.textSecondary)),
        ] else if(errorVistaPrevia!=null) ...[
          Text(errorVistaPrevia!,style:const TextStyle(color:Colors.red)),
          const SizedBox(height:8),
          if(tieneBorrador) _boton('Reintentar vista previa',()=>_actualizarVistaPrevia(prop!),principal:false),
        ] else if(bytes!=null && vistaPreviaId==_numero(prop?['id_propuesta'])) ...[
          SizedBox(
            height:(MediaQuery.sizeOf(context).height*0.74).clamp(520.0,860.0).toDouble(),
            child:PdfPreview(
              key:ValueKey('fve-vista-previa-${vistaPreviaId}'),
              build:(formato) async => bytes,
              initialPageFormat:PdfPageFormat.a4,
              canChangePageFormat:false,
              canChangeOrientation:false,
              allowPrinting:false,
              allowSharing:false,
              canDebug:false,
              maxPageWidth:800,
              pdfFileName:'FVE_${idProceso}_V${prop?['numero_version']}_vista-previa.pdf',
            ),
          ),
        ] else ...[
          Text(tieneBorrador ? 'La vista previa se generar\u00e1 autom\u00e1ticamente.' :
            'No hay un borrador disponible para revisar.',
            style:TextStyle(color:Global.textSecondary)),
        ],
        const SizedBox(height:14),
        Wrap(spacing:10,runSpacing:10,children:[
          _boton('Volver a propuesta',tieneBorrador ? ()=>_accion('/volver-propuesta') : null,principal:false),
          _boton('Actualizar vista previa',tieneBorrador && !cargandoVistaPrevia
            ? ()=>_actualizarVistaPrevia(prop!) : null,principal:false),
          _boton('Presentar y generar PDF definitivo',
            tieneBorrador && !cargandoVistaPrevia && vistaPreviaBytes!=null
              ? _confirmarPresentacion : null),
        ]),
        const SizedBox(height:8),
        Text('La vista previa no presenta ni modifica la propuesta. Al emitirla, la versi\u00f3n quedar\u00e1 registrada como inmutable.',
          style:TextStyle(color:Global.textSecondary,fontSize:12)),
      ]);
    }
    if(paso==5){
      final decisiones=_lista(info['decisiones']);
      final eventos=_lista(info['historial']);
      final reanudada=eventos.isNotEmpty && eventos.first['accion']=='NEGOCIACION_REANUDADA';
      final suspendida=decisiones.isNotEmpty && decisiones.first['decision']=='suspendido' && !reanudada;
      final seleccion=decisionElegida;
      final requiereMotivo=seleccion=='suspendido' || seleccion=='desinteresado';
      final explicacion=seleccion=='interesado'
        ? 'Al registrar esta respuesta se avanzará al paso 6'
        : seleccion=='suspendido'
          ? 'La negociación permanecerá en este paso hasta que se reanude.'
          : 'Se registrará el desistimiento y el proceso pasará al cierre.';

      Widget opcion(String valor,String titulo,String descripcion){
        final activo=seleccion==valor;
        return InkWell(
          onTap:trabajando?null:()=>setState((){
            decisionElegida=valor;
            errorDecision=null;
          }),
          borderRadius:BorderRadius.circular(12),
          child:AnimatedContainer(
            duration:const Duration(milliseconds:160),
            constraints:const BoxConstraints(minHeight:104),
            padding:const EdgeInsets.all(15),
            decoration:BoxDecoration(
              color:activo?Global.primary.withOpacity(.07):Global.container,
              borderRadius:BorderRadius.circular(12),
              border:Border.all(color:activo?Global.primary:Global.textSecondary.withOpacity(.23),width:activo?1.8:1),
            ),
            child:Row(crossAxisAlignment:CrossAxisAlignment.start,children:[
              Icon(activo?Icons.radio_button_checked:Icons.radio_button_unchecked,
                color:activo?Global.primary:Global.textSecondary,size:22),
              const SizedBox(width:11),
              Expanded(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
                Text(titulo,style:TextStyle(color:Global.text,fontSize:14,fontWeight:FontWeight.w700)),
                const SizedBox(height:6),
                Text(descripcion,style:TextStyle(color:Global.textSecondary,fontSize:12.5,height:1.35)),
              ])),
            ]),
          ),
        );
      }

      return Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
        Text('Decisión del cliente',style:TextStyle(color:Global.text,fontSize:20,fontWeight:FontWeight.w800)),
        const SizedBox(height:12),
        Container(
          width:double.infinity,
          padding:const EdgeInsets.all(16),
          decoration:BoxDecoration(
            color:Global.bg,
            borderRadius:BorderRadius.circular(12),
            border:Border.all(color:Global.textSecondary.withOpacity(.18)),
          ),
          child:Wrap(spacing:28,runSpacing:13,crossAxisAlignment:WrapCrossAlignment.center,children:[
            Column(crossAxisAlignment:CrossAxisAlignment.start,mainAxisSize:MainAxisSize.min,children:[
              Text('EMPRESA',style:TextStyle(color:Global.textSecondary,fontSize:10,fontWeight:FontWeight.w700,letterSpacing:.6)),
              const SizedBox(height:5),
              Text(_texto(widget.proceso['nombre_mipyme'],'Empresa'),
                style:TextStyle(color:Global.text,fontSize:15,fontWeight:FontWeight.w700)),
            ]),
            Column(crossAxisAlignment:CrossAxisAlignment.start,mainAxisSize:MainAxisSize.min,children:[
              Text('PROPUESTA V${actual?['numero_version'] ?? '-'}',
                style:TextStyle(color:Global.textSecondary,fontSize:10,fontWeight:FontWeight.w700,letterSpacing:.6)),
              const SizedBox(height:5),
              Text(pesos(actual?['total_inversion']),
                style:TextStyle(color:Global.text,fontSize:19,fontWeight:FontWeight.w800)),
            ]),
            if(actual!=null)
              OutlinedButton.icon(
                onPressed:trabajando?null:()=>_descargar(actual),
                icon:const Icon(Icons.picture_as_pdf_outlined,size:18),
                label:const Text('Descargar PDF'),
              ),
          ]),
        ),
        const SizedBox(height:24),
        if(suspendida)...[
          Text('La negociación está suspendida.',
            style:TextStyle(color:Global.text,fontSize:16,fontWeight:FontWeight.w700)),
          const SizedBox(height:7),
          Text('Cuando el cliente tome una nueva decisión, reanuda el proceso para registrarla.',
            style:TextStyle(color:Global.textSecondary,fontSize:13)),
          const SizedBox(height:16),
          _boton('Reanudar negociación',_reanudarDecision),
        ] else ...[
          Text('¿Qué decidió el cliente después de revisar la propuesta?',
            style:TextStyle(color:Global.text,fontSize:17,fontWeight:FontWeight.w800,height:1.25)),
          const SizedBox(height:7),
          Text('Selecciona la respuesta manifestada por el cliente.',
            style:TextStyle(color:Global.textSecondary,fontSize:13)),
          const SizedBox(height:15),
          LayoutBuilder(builder:(ctx,limites){
            final alternativas=[
              opcion('interesado','Desea continuar','Quiere avanzar hacia el análisis de financiación.'),
              opcion('suspendido','Prefiere esperar','Necesita más tiempo antes de tomar una decisión.'),
              opcion('desinteresado','No desea continuar','Decidió no seguir adelante con esta propuesta.'),
            ];
            if(limites.maxWidth>=850){
              return Row(crossAxisAlignment:CrossAxisAlignment.start,children:[
                for(final tarjeta in alternativas)...[
                  Expanded(child:tarjeta),
                  if(tarjeta!=alternativas.last)const SizedBox(width:12),
                ],
              ]);
            }
            return Column(children:[
              for(final tarjeta in alternativas)...[
                SizedBox(width:double.infinity,child:tarjeta),
                if(tarjeta!=alternativas.last)const SizedBox(height:10),
              ],
            ]);
          }),
          if(seleccion!=null)...[
            const SizedBox(height:18),
            if(seleccion!='interesado') ...[
              Text('Al registrar esta respuesta',
                style:TextStyle(color:Global.text,fontSize:13,fontWeight:FontWeight.w700)),
              const SizedBox(height:5),
            ],
            Text(explicacion,style:TextStyle(color:Global.textSecondary,fontSize:13,height:1.35)),
            const SizedBox(height:16),
            TextField(
              controller:motivoDecision,
              maxLines:3,
              maxLength:1500,
              onChanged:(_){if(errorDecision!=null)setState(()=>errorDecision=null);},
              decoration:InputDecoration(
                labelText:requiereMotivo?'Motivo expresado por el cliente (obligatorio)':'Observaciones del cliente (opcional)',
                alignLabelWithHint:true,
                border:const OutlineInputBorder(),
              ),
            ),
            if(errorDecision!=null)...[
              const SizedBox(height:5),
              Text(errorDecision!,style:const TextStyle(color:Colors.red,fontSize:12)),
            ],
            const SizedBox(height:9),
            FilledButton(
              onPressed:trabajando || actual==null ? null : _registrarDecision,
              child:Text(seleccion=='interesado'?'Registrar interés y continuar':
                seleccion=='suspendido'?'Registrar suspensión':'Confirmar desistimiento'),
            ),
          ]else...[
            const SizedBox(height:13),
            Text('Elige una respuesta para habilitar su registro.',
              style:TextStyle(color:Global.textSecondary,fontSize:12)),
          ],
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
  @override Widget build(BuildContext context) => Obx(() => ColoredBox(
    color: Global.bg,
    child: _buildVista(context),
  ));

  Widget _buildVista(BuildContext context){
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
