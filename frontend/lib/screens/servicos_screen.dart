import 'package:flutter/material.dart';

import '../services/auth_service.dart';
import '../widgets/bridgeflow_scaffold.dart';
import 'comunicados_screen.dart';
import 'decisoes_screen.dart';
import 'notificacoes_screen.dart';
import 'dashboard_screen.dart';
import 'contato_screen.dart';

class ServicosScreen extends StatefulWidget {
  const ServicosScreen({super.key});

  @override
  State<ServicosScreen> createState() => _ServicosScreenState();
}

class _ServicosScreenState extends State<ServicosScreen> {
  bool? _logado;

  @override
  void initState() {
    super.initState();
    _verificarLogin();
  }

  Future<void> _verificarLogin() async {
    final autenticado = await AuthService.isLoggedIn();
    if (!mounted) return;
    setState(() {
      _logado = autenticado;
    });
  }

  @override
  Widget build(BuildContext context) {
    final servicos = <Map<String, String>>[
      {
        'titulo': 'Comunicados',
        'descricao':
            'Envie e visualize comunicados internos entre secretarias.',
      },
      {
        'titulo': 'Decisões',
        'descricao': 'Gerencie decisões e acompanhe o status de aprovações.',
      },
      {
        'titulo': 'Notificações',
        'descricao': 'Receba notificações importantes em tempo real.',
      },
      {
        'titulo': 'Dashboard',
        'descricao': 'Visualize indicadores e relatórios do sistema.',
      },
      {
        'titulo': 'Contato',
        'descricao': 'Fale com a equipe de suporte ou envie sugestões.',
      },
    ];

    Widget bodyContent;
    if (_logado == null) {
      bodyContent = const Center(child: CircularProgressIndicator());
    } else if (_logado!) {
      bodyContent = ListView.separated(
        padding: const EdgeInsets.all(24),
        itemCount: servicos.length,
        separatorBuilder: (_, __) => const SizedBox(height: 16),
        itemBuilder: (context, index) {
          final servico = servicos[index];
          return Card(
            child: ListTile(
              title: Text(servico['titulo'] ?? ''),
              subtitle: Text(servico['descricao'] ?? ''),
              onTap: () => _onServicoTap(servico['titulo'] ?? ''),
            ),
          );
        },
      );
    } else {
      bodyContent = const Center(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: Text(
            'Para acessar os serviços, faça login no sistema.',
            style: TextStyle(fontSize: 18, color: Colors.black54),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    return BridgeFlowScaffold(body: bodyContent);
  }

  Future<void> _onServicoTap(String titulo) async {
    final escolha = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(titulo),
        content: const Text('Você deseja visualizar ou enviar?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop('visualizar'),
            child: const Text('Visualizar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop('enviar'),
            child: const Text('Enviar'),
          ),
        ],
      ),
    );

    if (!mounted || escolha == null) return;

    switch (titulo) {
      case 'Comunicados':
        if (escolha == 'visualizar') {
          Navigator.pushNamed(context, ComunicadosScreen.routeName);
        } else {
          Navigator.pushNamed(context, '/dashboard', arguments: {'create': 'comunicado'});
        }
        break;
      case 'Decisões':
        if (escolha == 'visualizar') {
          Navigator.pushNamed(context, DecisoesScreen.routeName);
        } else {
          Navigator.pushNamed(context, '/dashboard', arguments: {'create': 'decisao'});
        }
        break;
      case 'Notificações':
        if (escolha == 'visualizar') {
          Navigator.pushNamed(context, NotificacoesScreen.routeName);
        } else {
          Navigator.pushNamed(context, '/dashboard', arguments: {'create': 'notificacao'});
        }
        break;
      case 'Dashboard':
        Navigator.pushNamed(context, '/dashboard');
        break;
      case 'Contato':
        Navigator.pushNamed(context, '/contato');
        break;
      default:
        break;
    }
  }
}
