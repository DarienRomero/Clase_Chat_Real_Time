import 'package:firebase_auth/firebase_auth.dart';

class AuthResponse{
  final bool success;
  final String mensaje;
  final User user;

  AuthResponse({this.success, this.mensaje, this.user});
}