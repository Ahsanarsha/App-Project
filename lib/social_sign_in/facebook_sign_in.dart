import 'package:card_club/resources/cache_manager.dart';
import 'package:card_club/social_sign_in/phone_number.dart';
import 'package:card_club/utills/app_color.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_login_facebook/flutter_login_facebook.dart';
import 'package:get/get.dart';
import '../screens/register/bloc/social_bloc.dart';

class AuthService with CacheManager {
  fbSignIn(BuildContext context) async {
    final fb = FacebookLogin();

    final res = await fb.logIn(permissions: [
      FacebookPermission.publicProfile,
      FacebookPermission.email,
    ]);

    // Check result status
    switch (res.status) {
      case FacebookLoginStatus.success:

        // Send access token to server for validation and auth
        final FacebookAccessToken? accessToken = res.accessToken;
        final AuthCredential authCredential =
            FacebookAuthProvider.credential(accessToken!.token);
        await FirebaseAuth.instance.signInWithCredential(authCredential);

        // Get profile data

        final profile = await fb.getUserProfile();

        var name = profile!.name;
        var uid = profile.userId;
        final email = await fb.getUserEmail();
        final imageUrl = await fb.getProfileImageUrl(width: 100);

        print('Hello, $name! You ID: ${profile.userId}');
        print('Your profile image: $imageUrl');
        if (email != null) {
          print('And your email is $email');
        }

        showDialog(
            barrierDismissible: false,
            context: context,
            builder: (dialogContext) {
              return Center(
                  child: CircularProgressIndicator(
                color: main_color,
              ));
            });

        break;
      case FacebookLoginStatus.cancel:
        // User cancel log in
        break;
      case FacebookLoginStatus.error:
        // Log in failed
        print('Error while log in: ${res.error}');
        break;
    }
  }

  //Sign out
  signOut() {
    FirebaseAuth.instance.signOut();
  }
}
