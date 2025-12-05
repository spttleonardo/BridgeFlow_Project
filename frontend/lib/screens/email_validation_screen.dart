import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../widgets/bridgeflow_scaffold.dart';

class EmailValidationScreen extends StatefulWidget {
  final String email;
  const EmailValidationScreen({super.key, required this.email});
  @override
  State<EmailValidationScreen> createState() => _EmailValidationScreenState();
}

class _EmailValidationScreenState extends State<EmailValidationScreen> {
  final codeController = TextEditingController();
  bool loading = false;
  String? errorMsg;

  Future<void> resendCode() async {
    setState(() { loading = true; errorMsg = null; });
    final result = await ApiService.resendVerificationEmail(widget.email);
    setState(() { loading = false; });
    if (result == null) {
      // Sucesso
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Um novo código foi enviado para o seu email.')),
      );
    } else {
      setState(() { errorMsg = result; });
    }
  }

  Future<void> validateCode() async {
    setState(() { loading = true; errorMsg = null; });
    final result = await ApiService.verifyEmail(widget.email, codeController.text);
    setState(() { loading = false; });
    if (result != null && result['error'] == null) {
      Navigator.pushReplacementNamed(context, '/dashboard');
    } else {
      final msg = result?['error'] as String? ?? 'Erro ao validar email';
      setState(() { errorMsg = msg; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return BridgeFlowScaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Digite o código enviado para ${widget.email}', style: const TextStyle(fontSize: 18)),
              const SizedBox(height: 24),
              SizedBox(
                width: 300,
                child: TextField(
                  controller: codeController,
                  decoration: const InputDecoration(labelText: 'Código de validação'),
                ),
              ),
              const SizedBox(height: 24),
              if (loading) const CircularProgressIndicator(),
              if (errorMsg != null) ...[
                Text(errorMsg!, style: const TextStyle(color: Colors.red)),
                const SizedBox(height: 16),
              ],
              SizedBox(
                width: 300,
                child: ElevatedButton(
                  onPressed: loading ? null : validateCode,
                  child: const Text('Validar'),
                ),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: loading ? null : resendCode,
                child: const Text('Não recebi o código. Enviar novamente.'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
