import 'package:cloud_firestore/cloud_firestore.dart';

class FsService {
  Stream<QuerySnapshot> publicaciones() {
    return FirebaseFirestore.instance.collection('publicaciones').snapshots();
  }

  Future<List<String>> categorias() async {
    var datos = await FirebaseFirestore.instance.collection('categoria').get();
    return datos.docs.map((d) => d['nombre'].toString()).toList();
  }

  Future<void> agregarPublicacion(
    String titulo,
    String descripcion,
    String tipo,
    String categoria,
    String lugar,
    String autor,
    String autorEmail,
    String autorUid,
    Blob imagen,
  ) {
    return FirebaseFirestore.instance.collection('publicaciones').doc().set({
      'titulo': titulo,
      'descripcion': descripcion,
      'tipo': tipo,
      'categoria': categoria,
      'lugar': lugar,
      'fecha': Timestamp.now(),
      'estado': 'Vigente',
      'autor': autor,
      'autorEmail': autorEmail,
      'autorUid': autorUid,
      'imagen': imagen,
    });
  }

  Future<void> marcarDevuelto(String id) {
    return FirebaseFirestore.instance
        .collection('publicaciones')
        .doc(id)
        .update({'estado': 'Devuelto'});
  }

  Future<void> borrarPublicacion(String id) {
    return FirebaseFirestore.instance
        .collection('publicaciones')
        .doc(id)
        .delete();
  }
}
