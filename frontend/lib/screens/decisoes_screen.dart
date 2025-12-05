import 'package:flutter/material.dart';

import '../services/api_service.dart';

class DecisoesScreen extends StatefulWidget {
  static const routeName = '/decisoes';

  const DecisoesScreen({super.key});

  @override
  State<DecisoesScreen> createState() => _DecisoesScreenState();
}

class _DecisoesScreenState extends State<DecisoesScreen> {
  late Future<List<Map<String, dynamic>>> _decisoesFuture;

  @override
  void initState() {
    super.initState();
    _decisoesFuture = ApiService.fetchDecisoes();
  }

  Future<void> _reload() async {
    setState(() {
      _decisoesFuture = ApiService.fetchDecisoes();
    });
    await _decisoesFuture;
  }

  String _formatDate(dynamic value) {
    if (value is String) {
      final parsed = DateTime.tryParse(value);
      if (parsed != null) {
        final local = parsed.toLocal();
        final day = local.day.toString().padLeft(2, '0');
        final month = local.month.toString().padLeft(2, '0');
        final year = local.year;
        return '$day/$month/$year';
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
      appBar: AppBar(title: const Text('Decisões')),
      body: RefreshIndicator(
        onRefresh: _reload,
        child: FutureBuilder<List<Map<String, dynamic>>>(
          future: _decisoesFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return ListView(
                children: const [
                  SizedBox(height: 180),
                  Center(child: Text('Erro ao carregar decisões.')),
                ],
              );
            }

            final decisoes = snapshot.data ?? const [];
            if (decisoes.isEmpty) {
              return ListView(
                children: const [
                  SizedBox(height: 180),
                  Center(child: Text('Nenhuma decisão encontrada.')),
                ],
              );
            }

            return ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: decisoes.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final decisao = decisoes[index];
                final titulo = (decisao['titulo'] as String?) ?? 'Sem título';
                final status = _humanizeEnum(decisao['status']);
                final responsavel = (decisao['responsavelNome'] as String?) ??
                    'Sem responsável';
                final prazo = _formatDate(decisao['prazo']);
                final descricao = (decisao['descricao'] as String?) ?? '';

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
                            Chip(label: Text('Status: $status')),
                            Chip(label: Text('Responsável: $responsavel')),
                            Chip(label: Text('Prazo: $prazo')),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          descricao,
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
    );
  }
}
