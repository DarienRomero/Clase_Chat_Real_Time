import 'package:chat_real_time/models/auth_response.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService{
  FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn googleSignIn = GoogleSignIn();
  
  Future<AuthResponse> registroGoogle() async {
    try{
      //UserCredential userCredential = await _auth.signInAnonymously();
      GoogleSignInAccount googleSignInAccount = await googleSignIn.signIn();
      GoogleSignInAuthentication gSA = await googleSignInAccount.authentication;
      UserCredential result = await _auth.signInWithCredential(
        GoogleAuthProvider.credential(
          idToken: gSA.idToken, 
          accessToken: gSA.accessToken
        )
      );
      User user = result.user;
      return AuthResponse(
        success: true,
        user: user
      );
    }catch(error){
      return AuthResponse(
        success: false,
        mensaje: error.code,
      );
    }
  }
  Future signOut() async {
    try {
      return await _auth.signOut();
    } catch (error) {
      print(error.toString());
      return null;
    }
  }
}