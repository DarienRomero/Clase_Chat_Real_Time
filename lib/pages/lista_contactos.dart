import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat_real_time/models/user_app.dart';
import 'package:chat_real_time/services/firestore_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
class ListaContactos extends StatelessWidget {
  FirestoreService firestoreService;
  @override
  Widget build(BuildContext context) {
    firestoreService = Provider.of<FirestoreService>(context);
    return Scaffold(
      appBar: AppBar(
        title:Text(
          "Mis contactos",
        ),
        centerTitle: true,
      ),
      body: StreamBuilder(
        stream: firestoreService.getUsers(),
        builder: (BuildContext context, AsyncSnapshot snapshot){
          switch(snapshot.connectionState){
            case ConnectionState.waiting: return Container();
            case ConnectionState.none: return Container();
            case ConnectionState.active: return crearUsuarios(firestoreService.cargarUsuarios(snapshot.data.docs));
            case ConnectionState.done: return crearUsuarios(firestoreService.cargarUsuarios(snapshot.data.docs));
          }
          return Container();
        },
      )
    );
  }
}

Widget crearUsuarios(List<UserApp> users){
  return ListView.builder(
    itemCount: users.length,
    itemBuilder: (BuildContext context, int indice){
      final userApp = users[indice];
      return Column(
        children: [
          ListTile(
            leading: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                image: DecorationImage(
                  image: CachedNetworkImageProvider(userApp.photoURL)
                )
              ),
            ),
            subtitle: Text(userApp.profesion),
            trailing: IconButton(
              icon: Icon(Icons.arrow_forward_ios),
              onPressed: (){
                print(userApp.nombre);
              },
            ),
            title: Text(userApp.nombre),
          ),
          Divider()
        ],
      );
    }
  );
}
