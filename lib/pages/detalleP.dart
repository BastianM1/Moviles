import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_material_design_icons/flutter_material_design_icons.dart';
import 'package:trabajomoviles/utils/constantes.dart';
import 'package:trabajomoviles/utils/formatos.dart';

class DetalleP extends StatelessWidget {
  const DetalleP({super.key, required this.datos});

  final Map<String, dynamic> datos;

  @override
  Widget build(BuildContext context) {
    Blob? foto = datos['imagen'];
    Timestamp? fecha = datos['fecha'];
    DateTime? fechaFormateada = fecha?.toDate();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: kPrimaryColor,
        foregroundColor: kTextColor,
        title: Text(datos['titulo'] ?? 'detalle'),
      ),
      body: Padding(
        padding: EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            foto != null
                ? Image.memory(foto.bytes, height: 220, fit: BoxFit.cover)
                : Icon(MdiIcons.imageOff, size: 120),
            Divider(color: kPrimaryColor, thickness: 4),
            Text(
              datos['titulo'],
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            ),
            Divider(),
            Text('tipo: ${datos['tipo']}'),
            Text('estado: ${datos['estado']}'),
            Text('categoria: ${datos['categoria']}'),
            Text('lugar: ${datos['lugar']}'),
            Text(
              'fecha: ${fechaFormateada != null ? formatearFecha(fechaFormateada.toString()) : ''}',
            ),
            Text('autor: ${datos['autor']}'),
            Divider(),
            Text('descripcion: ${datos['descripcion']}'),
          ],
        ),
      ),
    );
  }
}
