import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AccountPage extends StatefulWidget {
  const AccountPage({super.key});

  @override
  State<AccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  final User? currentUser = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    final String name = currentUser?.displayName ?? "Usuário";
    final String email = currentUser?.email ?? "email@exemplo.com";

    final Size screenSize = MediaQuery.of(context).size;
    final double responsiveAreaWidth = screenSize.width * 0.8;
    double buttonWidth = (responsiveAreaWidth - 20) / 2;
    buttonWidth = buttonWidth.clamp(130.0, 180.0);
    final double buttonHeight = buttonWidth * (100 / 180);

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background
          Image.asset(
            'assets/images/hud/background_menu.gif',
            fit: BoxFit.cover,
          ),

          Container(
            color: Colors.black.withOpacity(0.5),
          ), // Usei withOpacity para clareza
          // Main
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Title
                  const Text(
                    "Meu Perfil",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 40),

                  // Profile Card
                  Card(
                    color: Colors.black.withOpacity(0.4), // Usei withOpacity
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(30),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const SizedBox(height: 20),
                          Row(
                            children: [
                              Expanded(
                                child: _buildInfoField(
                                  icon: Icons.person,
                                  label: "Nome",
                                  value: name,
                                ),
                              ),
                              const SizedBox(width: 16), // Espaçador
                              Expanded(
                                child: _buildInfoField(
                                  icon: Icons.email,
                                  label: "Email",
                                  value: email,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 40),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _styledButton(
                        text: "Voltar",
                        onTap: () {
                          Navigator.of(context).pop();
                        },
                        width: buttonWidth,
                        height: buttonHeight,
                      ),
                      const SizedBox(width: 30),
                      _styledButton(
                        text: "Editar Perfil",
                        width: buttonWidth,
                        height: buttonHeight,
                        onTap: () {
                          Navigator.of(context).pop();
                        },
                      ),
                      const SizedBox(width: 30),
                      _styledButton(
                        text: "Sair (logout)",
                        width: buttonWidth,
                        height: buttonHeight,
                        onTap: () async {
                          await FirebaseAuth.instance.signOut();
                          if (context.mounted) {
                            // Verificação de segurança
                            Navigator.of(context).pop();
                          }
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Widget _buildProfileImage({String? imageUrl}) {
  //   return Container(
  //     width: 120,
  //     height: 120,
  //     decoration: BoxDecoration(
  //       color: Colors.black.withOpacity(0.4), // Usei withOpacity
  //       borderRadius: BorderRadius.circular(60),
  //       border: Border.all(color: Colors.white, width: 4),
  //       boxShadow: [
  //         BoxShadow(
  //           color: Colors.black.withOpacity(0.2), // Usei withOpacity
  //           blurRadius: 8,
  //           offset: const Offset(0, 4),
  //         ),
  //       ],
  //     ),
  //     child: ClipOval(
  //       child: (imageUrl != null && imageUrl.isNotEmpty)
  //           ? Image.network(
  //               imageUrl,
  //               fit: BoxFit.cover,
  //               width: 120,
  //               height: 120,
  //               loadingBuilder: (context, child, loadingProgress) {
  //                 if (loadingProgress == null) return child;
  //                 return const Center(child: CircularProgressIndicator());
  //               },
  //               errorBuilder: (context, error, stackTrace) {
  //                 // Fallback em caso de erro ao carregar a imagem
  //                 return const Icon(
  //                   Icons.account_circle,
  //                   size: 90,
  //                   color: Colors.white,
  //                 );
  //               },
  //             )
  //           : const Icon(Icons.account_circle, size: 90, color: Colors.white),
  //     ),
  //   );
  // }

  Widget _buildInfoField({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Container(
      width: double.infinity, // Isso funciona bem dentro do Expanded
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.4), // Usei withOpacity
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white, width: 1),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.white, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow
                      .ellipsis, // Evita quebra de linha se o texto for muito longo
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _styledButton({
    required String text,
    required VoidCallback? onTap,
    required double width,
    required double height,
  }) {
    return SizedBox(
      width: width,
      height: height,
      child: InkWell(
        onTap: onTap,
        child: DecoratedBox(
          decoration: BoxDecoration(
            image: const DecorationImage(
              image: AssetImage('assets/images/hud/backgroundButton.png'),
              fit: BoxFit.fill,
            ),
          ),
          child: Center(
            child: Text(
              text,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
