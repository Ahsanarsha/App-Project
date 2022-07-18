import 'package:card_club/resources/cache_manager.dart';

import 'package:card_club/screens/register/bloc/social_bloc.dart';
import 'package:card_club/social_sign_in/phone_number.dart';
import 'package:card_club/utills/app_color.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';

class GoogleSignInProvider extends ChangeNotifier with CacheManager {
  final googleSingIn = GoogleSignIn();
  GoogleSignInAccount? _user;
  GoogleSignInAccount get user => _user!;
  final FirebaseAuth auth = FirebaseAuth.instance;

  Future googleLogin(BuildContext context) async {
    final googleUser = await googleSingIn.signIn();

    if (googleUser == null) return;
    _user = googleUser;

    final googleAuth = await googleUser.authentication;

    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    print(credential);

    UserCredential userCredential = await auth.signInWithCredential(credential);
    notifyListeners();

    final User? user = auth.currentUser;
    final uid = user!.uid.toString();

    var email = userCredential.user!.email;
    var name = userCredential.user!.displayName;

    print(email);
    print(name);
    print(uid);

    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (dialogContext) {
          return Center(
              child: CircularProgressIndicator(
            color: main_color,
          ));
        });
  }
}
