import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/routes/app_routes.dart';
import '../controllers/social_auth_controller.dart';
import 'package:o2_clinic/common/widgets/common_loading_indicator.dart';

class AuthGateScreen extends StatefulWidget {
  const AuthGateScreen({super.key});

  @override
  State<AuthGateScreen> createState() => _AuthGateScreenState();
}

class _AuthGateScreenState extends State<AuthGateScreen> {
  final c = Get.put(SocialAuthController(), permanent: true);

  @override
  void initState() {
    super.initState();
    _go();
  }

  Future<void> _go() async {
    await c.handleAutoLogin();

    // ✅ لو مفيش user -> Welcome
    if (FirebaseAuth.instance.currentUser == null) {
      Get.offAllNamed(AppRoutes.login);
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: CommonLoadingIndicator()));
  }
}
