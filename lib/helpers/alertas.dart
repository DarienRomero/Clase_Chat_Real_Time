part of 'helpers.dart';

showAlert(BuildContext context, String titulo, String contenido){
  showDialog(
    context: context,
    barrierDismissible: true,
    builder: (_){
      return AlertDialog(
        title: Text("Titulo"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(contenido),
            MaterialButton(
              onPressed: (){
                Navigator.pop(context);
              },  
              child: Text("Listo"),
            )
          ],
        ),
      );
    }
  );
}