import 'package:flutter/material.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/home_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/comunicados_screen.dart';
import 'screens/decisoes_screen.dart';
import 'screens/notificacoes_screen.dart';
import 'theme.dart';

void main() {
  runApp(const BridgeFlowApp());
}

class BridgeFlowApp extends StatelessWidget {
  const BridgeFlowApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BridgeFlow',
      debugShowCheckedModeBanner: false,
      theme: bridgeFlowTheme,
      initialRoute: '/home',
      routes: {
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/home': (context) => const HomeScreen(),
        '/dashboard': (context) => const DashboardScreen(),
        ComunicadosScreen.routeName: (context) => const ComunicadosScreen(),
        DecisoesScreen.routeName: (context) => const DecisoesScreen(),
        NotificacoesScreen.routeName: (context) => const NotificacoesScreen(),
        // Para navegação programática, use Navigator.push com MaterialPageRoute
      },
    );
  }
}
