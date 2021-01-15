import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat_real_time/models/user_app.dart';
import 'package:chat_real_time/pages/chat_screen.dart';
import 'package:chat_real_time/services/auth_service.dart';
import 'package:chat_real_time/services/firestore_service.dart';
import 'package:chat_real_time/widgets/lista_contactos.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
// ignore: must_be_immutable
class ListaConversaciones extends StatelessWidget {
  
  FirestoreService firestoreService;
  AuthService authService;
  UserApp userApp;

  ListaConversaciones(
    this.userApp
  );

  @override
  Widget build(BuildContext context) {
    firestoreService = Provider.of<FirestoreService>(context);
    authService = Provider.of<AuthService>(context);
    return Scaffold(
      appBar: AppBar(
        title:Text(
          "Mis contactos",
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.exit_to_app),
            onPressed: (){
              authService.signOut();
              Navigator.pushReplacementNamed(context, 'login');
            },
          )
        ],
        centerTitle: true,
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: (){
          showDialog(
            context: context,
            barrierDismissible: true,
            child: AlertDialog(
              contentPadding: EdgeInsets.all(20),
              content: Expanded(child: ListaContactos(userApp)),
            )
          );
        },
      ),
      body: StreamBuilder(
        stream: firestoreService.streamConversacion(userApp.uid),
        builder: (BuildContext context, AsyncSnapshot snapshot){
          switch(snapshot.connectionState){
            case ConnectionState.waiting: return Container();
            case ConnectionState.none: return Container();
            case ConnectionState.active: return crearConversacion(snapshot.data.docs);
            case ConnectionState.done: return crearConversacion(snapshot.data.docs);
          }
          return Container();
        },
      )
    );
  }
  Widget crearConversacion(List<DocumentSnapshot> snapshots){
    return ListView.builder(
      itemCount: snapshots.length,
      itemBuilder: (BuildContext context, int indice){
        final data = snapshots[indice];
        String conversacionID = data.data()["cid"];
        List<String> integrantes = List<String>.from(data.data()["uidUsers"]);
        List<String> photosUsers = List<String>.from(data.data()["photosUsers"]);
        List<String> nombresUsers = List<String>.from(data.data()["nombresUsers"]);
        int miIndice = integrantes.indexOf(userApp.uid);
        int contactoIndice = miIndice == 0 ? 1 : 0;
        return Column(
          children: [
            Container(
              margin: EdgeInsets.only(top: 10),
              child: ListTile(
                leading: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    image: DecorationImage(
                      image: CachedNetworkImageProvider(photosUsers[contactoIndice])
                    )
                  ),
                ),
                trailing: IconButton(
                  icon: Icon(Icons.arrow_forward_ios),
                  onPressed: (){
                    Navigator.push(context, MaterialPageRoute(builder: (context) => ChatScreen(userApp, conversacionID)));
                  },
                ),
                title: Text(nombresUsers[contactoIndice]),
              ),
            ),
            Divider()
          ],
        );
      }
    );
  }
}

