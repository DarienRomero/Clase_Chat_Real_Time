import 'package:chat_real_time/models/user_app.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService{
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  
  Stream<QuerySnapshot> getUsers() => _db.collection("users").snapshots(); 
  
  List<UserApp> cargarUsuarios(List<DocumentSnapshot> snapshots){
    List<UserApp> listaUsuarios = new List<UserApp>();
    if(snapshots.isEmpty) return  listaUsuarios;
    for(DocumentSnapshot snapshot in snapshots){
      listaUsuarios.add(
        UserApp(
          id: "123",
          nombre: snapshot.data()["nombre"],
          photoURL: snapshot.data()["photoURL"],
          profesion: snapshot.data()["profesion"],
        )
      );
    }
    return listaUsuarios;
  }
}