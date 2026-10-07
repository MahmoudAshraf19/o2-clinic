import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

class SocialAuthService {
  SocialAuthService._();
  static final instance = SocialAuthService._();

  final _auth = FirebaseAuth.instance;

  final GoogleSignIn _google = GoogleSignIn.instance;

  Future<UserCredential> signInWithGoogle() async {
    if (kIsWeb) {
      final provider = GoogleAuthProvider()
        ..addScope('email')
        ..addScope('profile');

      try {
        return await _auth.signInWithPopup(provider);
      } on FirebaseAuthException catch (e) {
        // لو المستخدم قفل الـ popup أو المتصفح منعه
        if (e.code == 'popup-closed-by-user' || e.code == 'popup-blocked') {
          await _auth.signInWithRedirect(provider);
          return await _auth.getRedirectResult().then((r) {
            final cred = r.credential;
            final user = r.user;
            if (cred == null || user == null) {
              throw FirebaseAuthException(
                code: 'redirect-failed',
                message: 'Redirect sign-in did not return a valid user.',
              );
            }
            // getRedirectResult بيرجع UserCredential
            return r;
          });
        }
        rethrow;
      }
    }

    // ✅ Mobile logic (زي ما هو عندك)
    await _google.initialize();
    final GoogleSignInAccount googleUser = await _google.authenticate(
      scopeHint: const ['email', 'profile'],
    );

    final auth = googleUser.authentication;
    final idToken = auth.idToken;

    if (idToken == null || idToken.isEmpty) {
      throw Exception("Missing Google idToken");
    }

    const scopes = <String>[
      'https://www.googleapis.com/auth/userinfo.email',
      'https://www.googleapis.com/auth/userinfo.profile',
    ];

    GoogleSignInClientAuthorization? authorization = await googleUser
        .authorizationClient
        .authorizationForScopes(scopes);

    authorization ??= await googleUser.authorizationClient.authorizeScopes(
      scopes,
    );

    final accessToken = authorization.accessToken;

    final credential = GoogleAuthProvider.credential(
      idToken: idToken,
      accessToken: accessToken,
    );

    return await _auth.signInWithCredential(credential);
  }

  Future<UserCredential> signInWithApple() async {
    if (kIsWeb) {
      final provider = AppleAuthProvider();
      return await _auth.signInWithPopup(provider);
    }

    final rawNonce = _generateNonce();
    final nonce = _sha256OfString(rawNonce);

    final appleCredential = await SignInWithApple.getAppleIDCredential(
      scopes: [
        AppleIDAuthorizationScopes.email,
        AppleIDAuthorizationScopes.fullName,
      ],
      nonce: nonce,
    );

    final oauthCredential = OAuthProvider(
      "apple.com",
    ).credential(idToken: appleCredential.identityToken, rawNonce: rawNonce);

    return await _auth.signInWithCredential(oauthCredential);
  }

  String _generateNonce([int length = 32]) {
    const charset =
        '0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._';
    final random = Random.secure();
    return List.generate(
      length,
      (_) => charset[random.nextInt(charset.length)],
    ).join();
  }

  String _sha256OfString(String input) {
    final bytes = utf8.encode(input);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }
}
