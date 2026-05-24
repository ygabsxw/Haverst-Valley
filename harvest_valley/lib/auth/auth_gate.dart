import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:harvest_valley/pages/login/accountPage.dart';
import 'package:harvest_valley/pages/menu.dart'; // Importe seu MainMenu

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      // Escuta em tempo real as mudanças no estado de autenticação
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // Se o snapshot ainda não tiver dados (ex: checando...),
        // mostre um loading.
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // Se o usuário NÃO estiver logado (sem dados)
        if (!snapshot.hasData) {
          // Mostre o Menu Principal. O usuário pode navegar
          // para o Login a partir daqui.
          return const MainMenu();
        }

        // Se o usuário ESTIVER logado (tem dados)
        // Mostre a página de conta dele.
        return const AccountPage();
      },
    );
  }
}
