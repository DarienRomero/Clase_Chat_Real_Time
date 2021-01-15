import 'package:chat_real_time/helpers/helpers.dart';
import 'package:chat_real_time/models/auth_response.dart';
import 'package:chat_real_time/models/user_app.dart';
import 'package:chat_real_time/pages/lista_conversaciones.dart';
import 'package:chat_real_time/services/auth_service.dart';
import 'package:chat_real_time/services/firestore_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// ignore: must_be_immutable
class LoginPage extends StatelessWidget {
  AuthService authService;
  FirestoreService firestoreService;
  @override
  Widget build(BuildContext context) {
    authService = Provider.of<AuthService>(context);
    firestoreService = Provider.of<FirestoreService>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text("Registro"),
        centerTitle: true,
      ),
      body: Center(
        child: FlatButton(
          child: Text("Ingresar con Google"),
          onPressed: () async {
            final AuthResponse response = await authService.registroGoogle();
            if(response.success){
              UserApp user;
              user = await firestoreService.getUserData(response.user.uid);
              if(user == null){
                await firestoreService.registrarUsuario(response.user);
                user = UserApp(
                  uid: response.user.uid,
                  nombre: response.user.displayName,
                  photoURL: response.user.photoURL,
                  misConversaciones: List<String>()
                );
              }
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => ListaConversaciones(user)));
            }else{
              showAlert(context, "Error al autenticar", "Vuelve a intentarlo");
            }
          },
        ) 
      ),
    );
  }
}