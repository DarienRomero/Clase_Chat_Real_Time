import 'package:chat_real_time/models/message.dart';
import 'package:chat_real_time/models/user_app.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirestoreService{
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  
  Stream<QuerySnapshot> getUsers(String uid) => _db.collection("users").where("contactos", arrayContains: uid).snapshots(); 
  
  List<UserApp> cargarUsuarios(List<DocumentSnapshot> snapshots){
    List<UserApp> listaUsuarios = new List<UserApp>.empty(growable: true);
    if(snapshots.isEmpty) return  listaUsuarios;
    for(DocumentSnapshot snapshot in snapshots){
      listaUsuarios.add(
        UserApp(
          uid: snapshot.data()["uid"],
          nombre: snapshot.data()["nombre"],
          photoURL: snapshot.data()["photoURL"],
          profesion: snapshot.data()["profesion"],
        )
      );
    }
    return listaUsuarios;
  }
  Stream<QuerySnapshot> streamMensajes(String cid) =>
   _db.collection("conversaciones").doc(cid).collection("mensajes").orderBy('instante', descending: true)
      .snapshots();

 Stream<QuerySnapshot> streamConversacion(String uid) =>
   _db.collection("conversaciones").where("uidUsers", arrayContains: uid)
      .snapshots();

 Stream<QuerySnapshot> streamContactos(String uid) =>
   _db.collection("users").where("contactos", arrayContains: uid)
      .snapshots();

  Future<void> agregarMensaje(UserApp user, String conversacionID, Message mensaje) async {
    CollectionReference ref = _db.collection("conversaciones")
      .doc(conversacionID)
        .collection("mensajes");

    FieldValue instanteTiempo = FieldValue.serverTimestamp();
    return await ref.add({
      'userId' : user.uid,
      'instante' : instanteTiempo,
      'mensaje': mensaje.mensaje,
      'tipo': mensaje.tipo,
      'url': mensaje.url,
      'userName': user.nombre,
    }).catchError((onError) => print(onError));
  }

  Future<void> agregarImagen(UserApp user, String conversacionID, String urlFirestore) async {
    CollectionReference ref = _db.collection("conversaciones")
      .doc(conversacionID)
        .collection("mensajes");
    return await ref.add({
      'userId' : user.uid,
      'instante' : DateTime.now(),
      'mensaje': "",
      'tipo': "imagen",
      'url': "$urlFirestore",
      'userName': user.nombre,
    }).catchError((onError) => print("Error al subir el archivo"));
  }

  List<Message> cargarMensajes(List<DocumentSnapshot> mensajesSnapshot){
    List<Message> mensajes = List<Message>();
    mensajesSnapshot.forEach((g){
      Map<dynamic, dynamic> info = g.data();
      if(info['instante'] != null){
        Message mensaje = Message(
          userId: info['userId'],
          instante: info['instante'].toDate(),
          mensaje: info['mensaje'],
          id: info['grupoGid'],
          userName: info['userName'],
          fileName: info['fileName'],
          fileType: info['fileType'],
          url: info['url'],
          tipo: info['tipo'],     
        );
        mensajes.add(mensaje);
      }
    });
    return mensajes;
  }

  Future<void> registrarUsuario(User user) async {
    DocumentReference ref = _db.collection("users").doc(user.uid);
    return await ref.set({
      'uid' : user.uid,
      'nombre' : user.displayName,
      'photoURL' : user.photoURL,
    }).catchError((onError) => print(onError));
  }

  Future<UserApp> getUserData(String uid) async {
    DocumentReference ref = _db.collection("users").doc(uid);
    UserApp userApp;
    await ref.get().then((DocumentSnapshot snapshot){
      final data = snapshot.data();
      userApp = UserApp(
        uid:        data["uid"],
        nombre:    data["nombre"],
        photoURL:  (data["photoURL"] != null) ? data["photoURL"] : "",
        profesion: data["id"] ,
        contactos: (data["contactos"] != null) ? List<String>.from(data["photoURL"]) : List<String>(),
        misConversaciones: (data["misConversaciones"] != null) ? List<String>.from(data["misConversaciones"]) : List<String>()
      );
    });
    return userApp;
  }

  Future<String> crearConversacion(UserApp user, UserApp contacto)async { 
    
    CollectionReference refConv = _db.collection("conversaciones");
    DocumentReference refUser = _db.collection("users").doc(user.uid);
    DocumentReference refContacto = _db.collection("users").doc(contacto.uid);
    
    DocumentReference refConversacion = await refConv.add({
      'uidUsers': FieldValue.arrayUnion([user.uid, contacto.uid]),
      'photosUsers': FieldValue.arrayUnion([user.photoURL, contacto.photoURL]),
      'nombresUsers': FieldValue.arrayUnion([user.nombre, contacto.nombre]),
    }).catchError((onError) => print(onError));

    await refConversacion.update({
      'cid': refConversacion.id
    }).catchError((onError) => print(onError));

    await refUser.update({
      'misConversaciones' : FieldValue.arrayUnion([refConversacion.id]),
    }).catchError((onError) => print(onError));

    await refContacto.update({
      'misConversaciones' : FieldValue.arrayUnion([refConversacion.id]),
    }).catchError((onError) => print(onError));

    return refConversacion.id;
  }
}