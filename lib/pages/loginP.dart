import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_material_design_icons/flutter_material_design_icons.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:trabajomoviles/utils/constantes.dart';

class LoginP extends StatefulWidget {
  const LoginP({super.key});

  @override
  State<LoginP> createState() => _LoginPState();
}

class _LoginPState extends State<LoginP> {
  String mensajeError = "";
  bool hayError = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(30),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(MdiIcons.account, color: kPrimaryColor, size: 60),
              const SizedBox(height: 15),
              const Text(
                'Objetos sansanos perdidos',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 25),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () async {
                    try {
                      hayError = false;
                      mensajeError = "";
                      await GoogleSignIn.instance.initialize();
                      final GoogleSignInAccount cuenta = await GoogleSignIn
                          .instance
                          .authenticate();
                      final GoogleSignInAuthentication auth =
                          cuenta.authentication;
                      final OAuthCredential credential =
                          GoogleAuthProvider.credential(idToken: auth.idToken);
                      await FirebaseAuth.instance.signInWithCredential(
                        credential,
                      );
                    } catch (ex) {
                      hayError = true;
                      mensajeError = "No se pudo inciiar la sesion";
                      setState(() {});
                    }
                  },
                  icon: Icon(MdiIcons.google, color: Colors.white),
                  label: const Text(
                    'ingresar con google',
                    style: TextStyle(color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kSecondaryColor,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              hayError
                  ? Container(
                      padding: const EdgeInsets.symmetric(horizontal: 5),
                      height: 45,
                      width: double.infinity,
                      alignment: Alignment.centerLeft,
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        border: Border.all(color: Colors.red.shade200),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          Icon(MdiIcons.alert, color: Colors.red),
                          const SizedBox(width: 10),
                          Text(
                            mensajeError,
                            style: const TextStyle(color: Colors.red),
                          ),
                        ],
                      ),
                    )
                  : const SizedBox(height: 45),
            ],
          ),
        ),
      ),
    );
  }
}
