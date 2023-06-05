import 'package:app_first/constants/routes.dart';
import 'package:app_first/services/auth/auth_service.dart';
import 'package:flutter/material.dart';

class VerifyEmailView extends StatefulWidget {
  const VerifyEmailView({super.key});

  @override
  State<VerifyEmailView> createState() => _VerifyEmailViewState();
}

class _VerifyEmailViewState extends State<VerifyEmailView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: const Text("Verify email")),
        body: Column(
          children: [
            const Text(
                "If you have not received a verification email yet, press this button below"),
            TextButton(
              onPressed: () async {
                await AuthService.firebase().sendEmailVerification();
              },
              child: const Text("Send email verification"),
            ),
            TextButton(
                onPressed: () async {
                  await AuthService.firebase().logOut();
                  // ignore: use_build_context_synchronously
                  Navigator.of(context)
                      .pushNamedAndRemoveUntil(registerRoute, (route) => false);
                },
                child: const Text("Restart"))
          ],
        ));
  }
}
