import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'email_validation_screen.dart';
import '../widgets/bridgeflow_scaffold.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final emailController = TextEditingController();
    final passwordController = TextEditingController();
    final formKey = GlobalKey<FormState>();
    return BridgeFlowScaffold(
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Bem-vindo! Faça login para continuar.', style: TextStyle(fontSize: 18)),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: 300,
                    child: TextFormField(
                      controller: emailController,
                      decoration: const InputDecoration(labelText: 'Email'),
                      keyboardType: TextInputType.emailAddress,
                      validator: (v) => v == null || v.isEmpty ? 'Informe o email' : null,
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: 300,
                    child: TextFormField(
                      controller: passwordController,
                      decoration: const InputDecoration(labelText: 'Senha'),
                      obscureText: true,
                      validator: (v) => v == null || v.isEmpty ? 'Informe a senha' : null,
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: 200,
                    child: ElevatedButton(
                      onPressed: () async {
                        if (formKey.currentState?.validate() ?? false) {
                          showDialog(
                            context: context,
                            barrierDismissible: false,
                            builder: (ctx) => const Center(child: CircularProgressIndicator()),
                          );
                          final result = await ApiService.login(
                            email: emailController.text,
                            password: passwordController.text,
                          );
                          Navigator.of(context).pop();
                          if (result != null && result['error'] == null) {
                            Navigator.pushReplacementNamed(context, '/dashboard');
                          } else {
                            final errorMsg = result?['error'] as String? ?? '';
                            if (errorMsg.toLowerCase().contains('e-mail não verificado')) {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => EmailValidationScreen(email: emailController.text),
                                ),
                              );
                            } else {
                              showDialog(
                                context: context,
                                builder: (ctx) => AlertDialog(
                                  title: const Text('Erro'),
                                  content: Text(errorMsg.isNotEmpty ? errorMsg : 'Erro ao fazer login'),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.of(ctx).pop(),
                                      child: const Text('OK'),
                                    ),
                                  ],
                                ),
                              );
                            }
                          }
                        }
                      },
                      child: const Text('Entrar'),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/register');
                    },
                    child: const Text('Não tem conta? Cadastre-se'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
