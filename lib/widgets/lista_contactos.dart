import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat_real_time/models/user_app.dart';
import 'package:chat_real_time/pages/chat_screen.dart';
import 'package:chat_real_time/services/firestore_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';


class ListaContactos extends StatelessWidget {
  UserApp user;
  ListaContactos(this.user);
  FirestoreService firestoreService;
  @override
  Widget build(BuildContext context) {
    firestoreService = Provider.of<FirestoreService>(context);
    return StreamBuilder(
      stream: firestoreService.streamContactos(user.uid),
      builder: (BuildContext context, AsyncSnapshot snapshot){
        switch(snapshot.connectionState){
          case ConnectionState.waiting: return Container();
          case ConnectionState.none: return Container();
          case ConnectionState.active: return crearUsuarios(firestoreService.cargarUsuarios(snapshot.data.docs), context);
          case ConnectionState.done: return crearUsuarios(firestoreService.cargarUsuarios(snapshot.data.docs), context);
        }
        return Container();
      },
    );
  }
  Widget crearUsuarios(List<UserApp> users, BuildContext context){
    List<Widget> usuariosWidgets = List<Widget>();
    for(UserApp contacto in users){
      usuariosWidgets.add( 
        Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        image: DecorationImage(
                          image: CachedNetworkImageProvider(contacto.photoURL),
                          fit: BoxFit.cover
                        )
                      ),
                    ),
                    Text(contacto.nombre),
                  ],
                ),
                IconButton(
                  icon: Icon(Icons.arrow_forward_ios),
                  onPressed: () async {
                    final String conversacionID = await firestoreService.crearConversacion(user, contacto);
                    Navigator.pop(context);
                    Navigator.push(context, MaterialPageRoute(builder: (context) => ChatScreen(user, conversacionID)));
                  },
                ),
              ],
            ),
            Divider()
          ],
        )
      );
    }
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: usuariosWidgets
    );
  }
}