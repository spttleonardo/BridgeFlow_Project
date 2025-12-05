import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'email_validation_screen.dart';
import '../widgets/bridgeflow_scaffold.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _cargoController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  List<Map<String, dynamic>> _secretarias = [];
  int? _selectedSecretariaId;
  bool _loadingSecretarias = true;
  String? _secretariaError;

  @override
  void initState() {
    super.initState();
    _loadSecretarias();
  }

  Future<void> _loadSecretarias() async {
    setState(() {
      _loadingSecretarias = true;
      _secretariaError = null;
    });
    try {
      final items = await ApiService.fetchSecretarias(requiresAuth: false);
      if (!mounted) {
        return;
      }
      if (items.isEmpty) {
        setState(() {
          _secretariaError = 'Nenhuma secretaria disponível no momento.';
          _loadingSecretarias = false;
        });
        return;
      }

      final parsed = items
          .map((item) => {
                'id': _parseId(item['id']),
                'nome': (item['nome'] as String?) ?? 'Secretaria sem nome',
              })
          .toList(growable: false);

      setState(() {
        _secretarias = parsed;
        _loadingSecretarias = false;
      });
    } catch (e) {
      if (!mounted) {
        return;
      }
      setState(() {
        final message = e.toString();
        _secretariaError = message.replaceFirst('Exception: ', '');
        _loadingSecretarias = false;
      });
    }
  }

  int _parseId(dynamic value) {
    if (value is int) {
      return value;
    }
    if (value is num) {
      return value.toInt();
    }
    return int.tryParse(value.toString()) ?? 0;
  }

  Future<void> _showErrorDialog(String message) async {
    if (!mounted) {
      return;
    }
    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Erro'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _cargoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BridgeFlowScaffold(
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Crie sua conta', style: TextStyle(fontSize: 18)),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: 300,
                    child: TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(labelText: 'Nome'),
                      validator: (v) =>
                          v == null || v.isEmpty ? 'Informe o nome' : null,
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: 300,
                    child: TextFormField(
                      controller: _emailController,
                      decoration: const InputDecoration(labelText: 'Email'),
                      keyboardType: TextInputType.emailAddress,
                      validator: (v) =>
                          v == null || v.isEmpty ? 'Informe o email' : null,
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: 300,
                    child: TextFormField(
                      controller: _passwordController,
                      decoration: const InputDecoration(labelText: 'Senha'),
                      obscureText: true,
                      validator: (v) => v == null || v.length < 4
                          ? 'Senha muito curta'
                          : null,
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: 300,
                    child: TextFormField(
                      controller: _cargoController,
                      decoration: const InputDecoration(labelText: 'Cargo'),
                      validator: (v) =>
                          v == null || v.isEmpty ? 'Informe o cargo' : null,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildSecretariaSection(),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: 200,
                    child: ElevatedButton(
                      onPressed: () async {
                        final navigator = Navigator.of(context);
                        if (_loadingSecretarias) {
                          await _showErrorDialog(
                              'Aguarde o carregamento das secretarias.');
                          return;
                        }
                        if (_secretariaError != null) {
                          await _showErrorDialog(
                              'Não foi possível carregar as secretarias. Tente novamente.');
                          return;
                        }
                        if (_formKey.currentState?.validate() ?? false) {
                          if (_selectedSecretariaId == null) {
                            await _showErrorDialog('Selecione uma secretaria.');
                            return;
                          }
                          showDialog(
                            context: context,
                            barrierDismissible: false,
                            builder: (ctx) => const Center(
                                child: CircularProgressIndicator()),
                          );
                          final error = await ApiService.register(
                            name: _nameController.text,
                            email: _emailController.text,
                            password: _passwordController.text,
                            cargo: _cargoController.text,
                            secretariaId: _selectedSecretariaId!,
                          );
                          if (!mounted) {
                            return;
                          }
                          navigator.pop();
                          if (error == null) {
                            navigator.pushReplacement(
                              MaterialPageRoute(
                                builder: (_) => EmailValidationScreen(
                                    email: _emailController.text),
                              ),
                            );
                          } else {
                            await _showErrorDialog(error);
                          }
                        }
                      },
                      child: const Text('Registrar'),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/login');
                    },
                    child: const Text('Já tem conta? Faça login'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSecretariaSection() {
    if (_loadingSecretarias) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 8.0),
        child: CircularProgressIndicator(),
      );
    }

    if (_secretariaError != null) {
      return Column(
        children: [
          Text(
            _secretariaError!,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.red),
          ),
          const SizedBox(height: 8),
          OutlinedButton(
            onPressed: _loadSecretarias,
            child: const Text('Tentar novamente'),
          ),
        ],
      );
    }

    return SizedBox(
      width: 300,
      child: DropdownButtonFormField<int>(
        value: _selectedSecretariaId,
        isExpanded: true,
        decoration: const InputDecoration(labelText: 'Secretaria'),
        items: _secretarias
            .map(
              (secretaria) => DropdownMenuItem<int>(
                value: secretaria['id'] as int,
                child: Text(secretaria['nome'] as String),
              ),
            )
            .toList(growable: false),
        onChanged: (value) => setState(() => _selectedSecretariaId = value),
        validator: (value) => value == null ? 'Selecione uma secretaria' : null,
      ),
    );
  }
}
