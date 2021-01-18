import 'dart:io';

import 'package:chat_real_time/models/message.dart';
import 'package:chat_real_time/models/user_app.dart';
import 'package:chat_real_time/services/files_manager.dart';
import 'package:chat_real_time/services/firestore_service.dart';
import 'package:chat_real_time/services/storage_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

// ignore: must_be_immutable
class ChatScreen extends StatelessWidget {
  
  final UserApp user;
  final String conversacionID;
  ChatScreen(
    this.user,
    this.conversacionID
  );

  String mensaje = "";
  final TextEditingController _controllerInputText = TextEditingController();
  FirestoreService firestoreService;
  StorageService storageService;

  @override
  Widget build(BuildContext context) {
    
    firestoreService = Provider.of<FirestoreService>(context);
    storageService = Provider.of<StorageService>(context);

    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios),
          color: Colors.white,
          onPressed:(){
            Navigator.pop(context);
          }
        ),
        title: Text(
          "Chat",
          style: TextStyle(
            fontSize: 16,
            color: Colors.white,
            letterSpacing: 0.5,
          )
        ),
        centerTitle: true,
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Column(
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                ),
                child: _cargaDataMensajes(context)
              ),
            ),
            _buildMessageComposer(context),
          ],
        ),
      ),
    );
  }
  StreamBuilder _cargaDataMensajes(BuildContext context) {
    return StreamBuilder(
      stream: firestoreService.streamMensajes(conversacionID),
      builder:(BuildContext context, AsyncSnapshot snapshot){
        switch (snapshot.connectionState) {
          case ConnectionState.waiting: return Center(child: CircularProgressIndicator());
          case ConnectionState.none: return Center(child: CircularProgressIndicator());
          case ConnectionState.active: return mostrarMensajes(firestoreService.cargarMensajes(snapshot.data.docs));
          case ConnectionState.done: return mostrarMensajes(firestoreService.cargarMensajes(snapshot.data.docs));
        }
        return CircularProgressIndicator();
      }
      );
  }
  ListView mostrarMensajes(List<Message> messages){
    return ListView.builder(
      physics: BouncingScrollPhysics(),
      reverse: true,
      shrinkWrap: true,
      padding: EdgeInsets.only(top: 15.0),
      itemCount: messages.length,
      itemBuilder: (BuildContext context, int index) {
        final Message message = messages[index];
        final bool isMe = message.userId == user.uid;
        if(message.tipo == "texto"){
          return _buildMessageText(context, message, isMe);
        }else if (message.tipo == "imagen"){
          return _buildMessageImage(context, message, isMe);
        }else if (message.tipo == "documento"){
          //return _buildMessageDocument(context, message, isMe);
        }
      },
    );
  }
  Widget _buildMessageText(BuildContext context, Message message, bool isMe) {
    final Container msg = Container(
      margin: isMe ? 
      EdgeInsets.only(
        top: 8.0,
        bottom: 8.0,
        left: 80.0,
        right: 8.0
      ): 
      EdgeInsets.only(
        top: 8.0,
        right: 80.0,
        left: 8.0,
        bottom: 8.0,
      ),
      padding: EdgeInsets.symmetric(horizontal: 15.0, vertical: 15.0),
      width: MediaQuery.of(context).size.width * 0.75,
      decoration: BoxDecoration(
        color: isMe ? Theme.of(context).accentColor : Color(0xFFFFEFEE),
        borderRadius: BorderRadius.all(
          Radius.circular(15.0),
        )
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: [
              Text(
                message.userName,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16.0,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Expanded(child: Container()),
              Text(
                _crearHora(message.instante),
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16.0,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          SizedBox(height: 8.0),
          Text(
            message.mensaje,
            style: TextStyle(
              color: Colors.white,
              fontSize: 16.0,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
    if (isMe) {
      return msg;
    }
    return msg;
  }
  _buildMessageImage(BuildContext context, Message message, bool isMe) {
    final Container msg = Container(
      margin: isMe
        ? EdgeInsets.only(
            top: 8.0,
            bottom: 8.0,
            left: 80.0,
            right: 8.0
          )
        : EdgeInsets.only(
            top: 8.0,
            right: 80.0,
            left: 8.0,
            bottom: 8.0,
          ),
      padding: EdgeInsets.symmetric(horizontal: 15.0, vertical: 15.0),
      decoration: BoxDecoration(
        color: isMe ? Theme.of(context).accentColor : Color(0xFFFFEFEE),
        borderRadius: BorderRadius.all(
          Radius.circular(15.0),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              InkWell(
                highlightColor: Theme.of(context).primaryColor,
                child: Text(
                  message.userName,
                  style: TextStyle(
                    color: Colors.blueGrey,
                    fontSize: 16.0,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                onTap: (){
                  /* Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => PerfilResumen(userActivo: user, uidUsuarioNuevo: message.userId)),
                  ); */
                }
              ),
              Expanded(child: Container()),
              Text(
                _crearHora(message.instante),
                style: TextStyle(
                  color: Colors.blueGrey,
                  fontSize: 16.0,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          SizedBox(height: 8.0),
          GestureDetector(
            onLongPress: (){
              //downloadImage(context, message.url);
            },
            onTap: (){
              /* Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => VisualizadorImagen(message.url)),
              ); */
            },
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: FadeInImage(
                image: NetworkImage(message.url),
                placeholder: AssetImage("assets/images/cargarFoto.gif"),
                fadeInDuration: Duration(milliseconds: 200),
                fit: BoxFit.contain
              )
            ),
          )
        ],
      ),
    );
    if (isMe) {
      return msg;
    }
    return msg;
  }
  String _crearHora(DateTime time){
    String horayMinuto = "";
    bool am = false;
    int hora = time.hour;
    int minuto = time.minute;
    if(hora < 10){
      am = true;
      horayMinuto += '0';
      horayMinuto += hora.toString();
    } else if(hora < 12){
      am = true;
      horayMinuto += hora.toString();
    }else if(hora < 13){
      am = false;
      horayMinuto += hora.toString();
    }else{
      am = false;
      horayMinuto += (hora - 12).toString();
    }
    if(minuto < 10){
      horayMinuto+=":0$minuto ";
    }else{
      horayMinuto+=":$minuto ";
    }
    if(am == true){
      horayMinuto+= "a. m.";
    }else{
      horayMinuto+= "p. m.";
    }
    return horayMinuto;
  }
  _buildMessageComposer(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 5.0),
      height: 70.0,
      color: Colors.white,
      child: Row(
        children: <Widget>[
          IconButton(
            icon: Icon(Icons.insert_drive_file),
            iconSize: 25.0,
            color: Theme.of(context).primaryColor,
            onPressed: () {
              
            },
          ),
          IconButton(
            icon: Icon(Icons.camera_alt),
            iconSize: 25.0,
            color: Theme.of(context).primaryColor,
            onPressed: () {
              
            },
          ),
          IconButton(
            icon: Icon(Icons.photo),
            iconSize: 25.0,
            color: Theme.of(context).primaryColor,
            onPressed: () async {
              FilesManager filesManager = new FilesManager();
              final File pickedFile = await filesManager.getImageFromGallery();
              if(pickedFile == null) return;
              final String storagePath =  "archivos_grupos/$conversacionID/${DateTime.now().toString()}.jpg";
              await storageService.uploadFile(storagePath, pickedFile);
              final String downloadURL = await storageService.getDownloadURL(storagePath);
              await firestoreService.agregarImagen(user, conversacionID, downloadURL);
              print(downloadURL);
            },
          ),
          Expanded(
            child: TextField(
              controller: _controllerInputText,
              textCapitalization: TextCapitalization.sentences,
              onChanged: (value) {
                mensaje = value;
              },
              decoration: InputDecoration.collapsed(
                hintText: 'Escribe un mensaje',
              ),
            ),
          ),
          IconButton(
            icon: Icon(Icons.send),
            iconSize: 25.0,
            color: Theme.of(context).primaryColor,
            onPressed: () async {
              _controllerInputText.text = "";
              if(mensaje.isNotEmpty){
                await firestoreService.agregarMensaje(
                  user, 
                  conversacionID,
                  Message(
                    userId: user.uid,
                    instante: DateTime.now(),
                    mensaje: mensaje,
                    tipo: "texto"
                  )
                );
                mensaje = "";
              }
            },
          ),
        ],
      ),
    );
  }
}