import 'package:flutter/material.dart';

class Prueba extends StatefulWidget {
  Prueba({Key key}) : super(key: key);

  @override
  _PruebaState createState() => _PruebaState();
}

class _PruebaState extends State<Prueba> {
  List<String> dias = ["lunes", "martes", "miercoles"];
  /* @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      String content = await http.get("url");
      setState(() {
        dias = content.dias;
      });
    });
    super.initState();
  } */
  @override
  Widget build(BuildContext context) {
    return Container(
       child: Text(dias.toString())
    );
  }
}