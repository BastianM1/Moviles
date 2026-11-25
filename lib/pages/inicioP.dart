import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_material_design_icons/flutter_material_design_icons.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:trabajomoviles/pages/agregarP.dart';
import 'package:trabajomoviles/pages/detalleP.dart';
import 'package:trabajomoviles/services/auth_service.dart';
import 'package:trabajomoviles/services/firestore_service.dart';
import 'package:trabajomoviles/utils/constantes.dart';

class InicioP extends StatefulWidget {
  const InicioP({super.key});

  @override
  State<InicioP> createState() => _InicioPState();
}

class _InicioPState extends State<InicioP> {
  User? user;
  String filtro = 'Todos';
  bool borrando = false;

  @override
  void initState() {
    AuthService().currentUser().then((u) {
      if (!mounted) return;
      setState(() {
        user = u;
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundColor,
      appBar: AppBar(
        backgroundColor: kPrimaryColor,
        leading: Icon(MdiIcons.account, color: kTextColor, size: 28),
        title: Text(
          user?.displayName ?? user?.email ?? 'cargando usuario',
          style: TextStyle(color: kTextColor, fontSize: 19),
        ),
        actions: [
          PopupMenuButton(
            onSelected: (value) async {
              await GoogleSignIn.instance.signOut();
              await FirebaseAuth.instance.signOut();
            },
            iconColor: kTextColor,
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'logout',
                child: Text(
                  'cerrar sesion',
                  style: TextStyle(color: kPrimaryColor),
                ),
              ),
            ],
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(8),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                TextButton(
                  onPressed: () => setState(() => filtro = 'Todos'),
                  child: Text('todos'),
                ),
                TextButton(
                  onPressed: () => setState(() => filtro = 'Perdido'),
                  child: Text('perdidos'),
                ),
                TextButton(
                  onPressed: () => setState(() => filtro = 'Encontrado'),
                  child: Text('encontrados'),
                ),
                TextButton(
                  onPressed: () => setState(() => filtro = 'Devuelto'),
                  child: Text('devueltos'),
                ),
                TextButton(
                  onPressed: () => setState(() => filtro = 'Mios'),
                  child: Text('yo'),
                ),
              ],
            ),
            Expanded(
              child: StreamBuilder(
                stream: FsService().publicaciones(),
                builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (!snapshot.hasData ||
                      snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }

                  var docs = snapshot.data!.docs.where((doc) {
                    var data = doc.data() as Map<String, dynamic>;
                    if (filtro == 'Perdido') return data['tipo'] == 'Perdido';
                    if (filtro == 'Encontrado') {
                      return data['tipo'] == 'Encontrado';
                    }
                    if (filtro == 'Devuelto') {
                      return data['estado'] == 'Devuelto';
                    }
                    if (filtro == 'Mios') return data['autorUid'] == user?.uid;
                    return true;
                  }).toList();

                  if (docs.isEmpty) {
                    return Center(child: Text('no hay publicaciones'));
                  }

                  return ListView.separated(
                    separatorBuilder: (context, index) => Divider(),
                    itemCount: docs.length,
                    itemBuilder: (context, index) {
                      var doc = docs[index];
                      var data = doc.data() as Map<String, dynamic>;
                      var esAutor = data['autorUid'] == user?.uid;
                      var estado = data['estado'] ?? 'Vigente';
                      Blob? foto = data['imagen'];

                      return ListTile(
                        leading: foto != null
                            ? Image.memory(
                                foto.bytes,
                                width: 50,
                                height: 50,
                                fit: BoxFit.cover,
                              )
                            : Icon(MdiIcons.iceCream, size: 40),
                        title: Text('${data['titulo']} (${data['tipo']})'),
                        subtitle: Text(
                          '${data['lugar']} - ${data['categoria']} - $estado',
                          style: TextStyle(
                            color: estado == 'Devuelto'
                                ? Colors.green
                                : Colors.orange,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        trailing: esAutor
                            ? PopupMenuButton<String>(
                                onSelected: (value) {
                                  if (value == 'estado') {
                                    FsService().marcarDevuelto(doc.id);
                                  } else if (value == 'borrar') {
                                    showDialog(
                                      barrierDismissible: false,
                                      context: context,
                                      builder: (dialogContext) => AlertDialog(
                                        backgroundColor: Colors.white,
                                        title: Text(
                                          'borrar publicacion',
                                          style: TextStyle(fontSize: 18),
                                        ),
                                        content: Text(
                                          'confirma borrar ${data['titulo']}?',
                                        ),
                                        actions: [
                                          TextButton(
                                            onPressed: () =>
                                                Navigator.pop(dialogContext),
                                            child: Text('cancelar'),
                                          ),
                                          FilledButton(
                                            onPressed: () async {
                                              if (borrando) return;
                                              borrando = true;
                                              try {
                                                await FsService()
                                                    .borrarPublicacion(doc.id);
                                                if (!mounted ||
                                                    !dialogContext.mounted) {
                                                  return;
                                                }
                                                Navigator.pop(dialogContext);
                                              } finally {
                                                borrando = false;
                                              }
                                            },
                                            style: FilledButton.styleFrom(
                                              backgroundColor: kPrimaryColor,
                                            ),
                                            child: Text('borrar'),
                                          ),
                                        ],
                                      ),
                                    );
                                  }
                                },
                                itemBuilder: (context) => [
                                  if (estado == 'Vigente')
                                    PopupMenuItem(
                                      value: 'estado',
                                      child: Text('devuelto'),
                                    ),
                                  PopupMenuItem(
                                    value: 'borrar',
                                    child: Text('borrar'),
                                  ),
                                ],
                              )
                            : null,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => DetalleP(datos: data),
                            ),
                          );
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PublicacionAgregar(user: user),
            ),
          );
        },
        backgroundColor: kSecondaryColor,
        foregroundColor: kTextColor,
        child: Icon(Icons.add),
      ),
    );
  }
}
