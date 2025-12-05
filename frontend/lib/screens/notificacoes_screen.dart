import 'package:flutter/material.dart';

import '../services/api_service.dart';

class NotificacoesScreen extends StatefulWidget {
  static const routeName = '/notificacoes';

  const NotificacoesScreen({super.key});

  @override
  State<NotificacoesScreen> createState() => _NotificacoesScreenState();
}

class _NotificacoesScreenState extends State<NotificacoesScreen> {
  late Future<List<Map<String, dynamic>>> _notificacoesFuture;
  bool _apenasNaoLidas = false;

  @override
  void initState() {
    super.initState();
    _notificacoesFuture = ApiService.fetchNotificacoes();
  }

  Future<void> _reload() async {
    setState(() {
      _notificacoesFuture =
          ApiService.fetchNotificacoes(apenasNaoLidas: _apenasNaoLidas);
    });
    await _notificacoesFuture;
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
      return lower.split(' ').map((word) {
        if (word.isEmpty) return word;
        return word[0].toUpperCase() + word.substring(1);
      }).join(' ');
    }
    return '-';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Notificações')),
      body: RefreshIndicator(
        onRefresh: _reload,
        child: Column(
          children: [
            SwitchListTile(
              title: const Text('Mostrar apenas não lidas'),
              value: _apenasNaoLidas,
              onChanged: (value) {
                setState(() {
                  _apenasNaoLidas = value;
                  _notificacoesFuture =
                      ApiService.fetchNotificacoes(apenasNaoLidas: value);
                });
              },
            ),
            Expanded(
              child: FutureBuilder<List<Map<String, dynamic>>>(
                future: _notificacoesFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return ListView(
                      children: const [
                        SizedBox(height: 180),
                        Center(child: Text('Erro ao carregar notificações.')),
                      ],
                    );
                  }

                  final notificacoes = snapshot.data ?? const [];
                  if (notificacoes.isEmpty) {
                    return ListView(
                      children: const [
                        SizedBox(height: 180),
                        Center(child: Text('Nenhuma notificação encontrada.')),
                      ],
                    );
                  }

                  return ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: notificacoes.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final notificacao = notificacoes[index];
                      final titulo =
                          (notificacao['titulo'] as String?) ?? 'Sem título';
                      final mensagem =
                          (notificacao['mensagem'] as String?) ?? '';
                      final tipo = _humanizeEnum(notificacao['tipo']);
                      final data = _formatDate(notificacao['dataCriacao']);
                      final lida = notificacao['lida'] == true;

                      return Card(
                        elevation: 1,
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(titulo,
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleMedium
                                      ?.copyWith(fontWeight: FontWeight.bold)),
                              const SizedBox(height: 8),
                              Wrap(
                                spacing: 8,
                                runSpacing: 4,
                                children: [
                                  Chip(label: Text('Tipo: $tipo')),
                                  Chip(label: Text(lida ? 'Lida' : 'Não lida')),
                                  Chip(label: Text('Criada: $data')),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                mensagem,
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
            ),
          ],
        ),
      ),
    );
  }
}
