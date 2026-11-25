import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_material_design_icons/flutter_material_design_icons.dart';
import 'package:image_picker/image_picker.dart';
import 'package:trabajomoviles/services/firestore_service.dart';
import 'package:trabajomoviles/utils/constantes.dart';

class PublicacionAgregar extends StatefulWidget {
  const PublicacionAgregar({super.key, required this.user});

  final User? user;

  @override
  State<PublicacionAgregar> createState() => _PublicacionAgregarState();
}

class _PublicacionAgregarState extends State<PublicacionAgregar> {
  final tituloCtrl = TextEditingController();
  final lugarCtrl = TextEditingController();
  final descripcionCtrl = TextEditingController();
  String tipoSeleccionado = 'Perdido';
  String? categoriaSeleccionada;
  List<String> categorias = [];
  Uint8List? imagenBytes;
  bool guardando = false;
  bool seleccionandoFoto = false;
  String errorFoto = '';
  final formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    FsService().categorias().then((lista) {
      if (!mounted) return;
      setState(() {
        categorias = lista;
        if (categorias.isNotEmpty) {
          categoriaSeleccionada = categorias.first;
        }
      });
    });
  }

  @override
  void dispose() {
    tituloCtrl.dispose();
    lugarCtrl.dispose();
    descripcionCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: kPrimaryColor,
        foregroundColor: kTextColor,
        title: Text('nueva publicacion'),
      ),
      body: Padding(
        padding: EdgeInsets.all(8),
        child: Form(
          key: formKey,
          child: Column(
            children: [
              TextFormField(
                controller: tituloCtrl,
                decoration: InputDecoration(labelText: 'titulo'),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'indique el titulo';
                  }
                  return null;
                },
              ),
              SizedBox(height: 10),
              TextFormField(
                controller: lugarCtrl,
                decoration: InputDecoration(labelText: 'lugar'),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'indique el lugar';
                  }
                  return null;
                },
              ),
              SizedBox(height: 10),
              TextFormField(
                controller: descripcionCtrl,
                decoration: InputDecoration(labelText: 'descripcion'),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'indique la descripcion';
                  }
                  return null;
                },
              ),
              SizedBox(height: 10),
              DropdownButtonFormField<String>(
                initialValue: tipoSeleccionado,
                decoration: InputDecoration(labelText: 'tipo'),
                isExpanded: true,
                items: ['Perdido', 'Encontrado']
                    .map(
                      (tipo) =>
                          DropdownMenuItem(value: tipo, child: Text(tipo)),
                    )
                    .toList(),
                onChanged: (tipo) {
                  if (tipo != null) {
                    tipoSeleccionado = tipo;
                  }
                },
              ),
              SizedBox(height: 10),
              if (categorias.isNotEmpty)
                DropdownButtonFormField<String>(
                  initialValue: categoriaSeleccionada,
                  decoration: InputDecoration(labelText: 'categoria'),
                  isExpanded: true,
                  items: categorias
                      .map(
                        (cat) => DropdownMenuItem(value: cat, child: Text(cat)),
                      )
                      .toList(),
                  onChanged: (cat) => categoriaSeleccionada = cat,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'seleccione una categoria';
                    }
                    return null;
                  },
                ),
              SizedBox(height: 15),
              Row(
                children: [
                  Text('foto: '),
                  Text(
                    imagenBytes != null ? 'lista' : 'sin foto',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Spacer(),
                  IconButton(
                    onPressed: () async {
                      if (seleccionandoFoto) return;
                      seleccionandoFoto = true;
                      try {
                        final picker = ImagePicker();
                        final foto = await picker.pickImage(
                          source: ImageSource.camera,
                          imageQuality: 75,
                          maxWidth: 1024,
                          maxHeight: 1024,
                        );
                        if (foto != null) {
                          final bytes = await foto.readAsBytes();
                          setState(() {
                            imagenBytes = bytes;
                            errorFoto = '';
                          });
                        }
                      } finally {
                        seleccionandoFoto = false;
                      }
                    },
                    icon: Icon(MdiIcons.camera),
                  ),
                  IconButton(
                    onPressed: () async {
                      if (seleccionandoFoto) return;
                      seleccionandoFoto = true;
                      try {
                        final picker = ImagePicker();
                        final foto = await picker.pickImage(
                          source: ImageSource.gallery,
                          imageQuality: 75,
                          maxWidth: 1024,
                          maxHeight: 1024,
                        );
                        if (foto != null) {
                          final bytes = await foto.readAsBytes();
                          setState(() {
                            imagenBytes = bytes;
                            errorFoto = '';
                          });
                        }
                      } finally {
                        seleccionandoFoto = false;
                      }
                    },
                    icon: Icon(MdiIcons.image),
                  ),
                ],
              ),
              if (errorFoto.isNotEmpty)
                Text(errorFoto, style: TextStyle(color: Colors.red)),
              Spacer(),
              Container(
                margin: EdgeInsets.only(bottom: 30),
                width: double.infinity,
                child: FilledButton(
                  onPressed: () {
                    if (!formKey.currentState!.validate()) {
                      return;
                    }
                    if (imagenBytes == null) {
                      setState(() {
                        errorFoto = 'debe seleccionar una foto';
                      });
                      return;
                    }
                    if (imagenBytes!.lengthInBytes > 950000) {
                      setState(() {
                        errorFoto = 'la foto supera el limite de 1 mb';
                      });
                      return;
                    }

                    if (guardando) return;
                    guardando = true;

                    try {
                      FsService().agregarPublicacion(
                        tituloCtrl.text.trim(),
                        descripcionCtrl.text.trim(),
                        tipoSeleccionado,
                        categoriaSeleccionada ?? 'Otros',
                        lugarCtrl.text.trim(),
                        widget.user?.displayName ?? 'usuario',
                        widget.user?.email ?? '',
                        widget.user?.uid ?? '',
                        Blob(imagenBytes!),
                      );

                      if (!context.mounted) return;
                      Navigator.pop(context);
                    } finally {
                      guardando = false;
                    }
                  },
                  style: FilledButton.styleFrom(
                    backgroundColor: kSecondaryColor,
                  ),
                  child: Text('publicar'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
