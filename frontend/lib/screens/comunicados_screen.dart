import 'package:flutter/material.dart';

import '../services/api_service.dart';
import '../services/auth_service.dart';
import '../widgets/bridgeflow_scaffold.dart';

class ComunicadosScreen extends StatefulWidget {
  static const routeName = '/comunicados';

  const ComunicadosScreen({super.key});

  @override
  State<ComunicadosScreen> createState() => _ComunicadosScreenState();
}

class _ComunicadosScreenState extends State<ComunicadosScreen> {
  bool? _logado;
  late Future<List<Map<String, dynamic>>> _comunicadosFuture;

  @override
  void initState() {
    super.initState();
    _verificarLogin();
    _comunicadosFuture = ApiService.fetchComunicados();
  }

  Future<void> _verificarLogin() async {
    await ApiService.restoreAuthFromStorage();
    final autenticado = await AuthService.isLoggedIn();
    if (!mounted) return;
    setState(() {
      _logado = autenticado;
    });
  }

  Future<void> _reload() async {
    setState(() {
      _comunicadosFuture = ApiService.fetchComunicados();
    });
    await _comunicadosFuture;
  }

  String _formatDate(dynamic value) {
    if (value is String) {
      final parsed = DateTime.tryParse(value);
      if (parsed != null) {
        final local = parsed.toLocal();
        final day = local.day.toString().padLeft(2, '0');
        final month = local.month.toString().padLeft(2, '0');
        final year = local.year;
        final hour = local.hour.toString().padLeft(2, '0');
        final minute = local.minute.toString().padLeft(2, '0');
        return '$day/$month/$year às $hour:$minute';
      }
    }
    return '-';
  }

  String _humanizeEnum(dynamic value) {
    if (value is String && value.isNotEmpty) {
      final lower = value.toLowerCase().replaceAll('_', ' ');
      return lower
          .split(' ')
          .map((word) =>
              word.isEmpty ? word : word[0].toUpperCase() + word.substring(1))
          .join(' ');
    }
    return '-';
  }

  @override
  Widget build(BuildContext context) {
    Widget bodyContent;
    if (_logado == null) {
      bodyContent = const Center(child: CircularProgressIndicator());
    } else if (_logado!) {
      bodyContent = RefreshIndicator(
        onRefresh: _reload,
        child: FutureBuilder<List<Map<String, dynamic>>>(
          future: _comunicadosFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return ListView(
                children: const [
                  SizedBox(height: 180),
                  Center(child: Text('Erro ao carregar comunicados.')),
                ],
              );
            }
            final comunicados = snapshot.data ?? <Map<String, dynamic>>[];
            if (comunicados.isEmpty) {
              return ListView(
                children: const [
                  SizedBox(height: 180),
                  Center(child: Text('Nenhum comunicado encontrado.')),
                ],
              );
            }
            return ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: comunicados.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final comunicado = comunicados[index];
                final titulo = (comunicado['titulo'] as String?) ?? 'Sem título';
                final prioridade = _humanizeEnum(comunicado['prioridade']);
                final status = _humanizeEnum(comunicado['status']);
                final secretariaDestino =
                    (comunicado['secretariaDestinoNome'] as String?) ?? 'N/A';
                final dataCriacao = _formatDate(comunicado['dataCriacao']);
                final conteudo = (comunicado['conteudo'] as String?) ?? '';

                return Card(
                  elevation: 1,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          titulo,
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 4,
                          children: [
                            Chip(label: Text('Prioridade: $prioridade')),
                            Chip(label: Text('Status: $status')),
                            Chip(label: Text('Destino: $secretariaDestino')),
                            Chip(label: Text('Criado em $dataCriacao')),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          conteudo,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      );
    } else {
      bodyContent = const Center(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: Text(
            'Para acessar os comunicados, faça login no sistema.',
            style: TextStyle(fontSize: 18, color: Colors.black54),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    return BridgeFlowScaffold(body: bodyContent);
  }
}
