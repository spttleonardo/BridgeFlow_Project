import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../theme.dart';
import 'comunicados_screen.dart';
import 'decisoes_screen.dart';
import 'notificacoes_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  late Future<Map<String, dynamic>?> _statsFuture;

  @override
  void initState() {
    super.initState();
    _statsFuture = ApiService.fetchDashboardStats();
  }

  Future<void> _reload() async {
    setState(() {
      _statsFuture = ApiService.fetchDashboardStats();
    });
    await _statsFuture;
  }

  int _asInt(dynamic value) {
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) {
      return int.tryParse(value) ?? 0;
    }
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final userName = ApiService.currentUser?['nome'] as String?;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        backgroundColor: bridgeFlowTheme.appBarTheme.backgroundColor,
        actions: [
          IconButton(
            tooltip: 'Atualizar',
            onPressed: _reload,
            icon: const Icon(Icons.refresh),
          ),
          IconButton(
            tooltip: 'Sair',
            onPressed: () {
              ApiService.clearAuth();
              Navigator.pushNamedAndRemoveUntil(
                  context, '/login', (_) => false);
            },
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _reload,
        child: FutureBuilder<Map<String, dynamic>?>(
          future: _statsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return _DashboardError(message: 'Erro inesperado ao carregar.');
            }
            final data = snapshot.data;
            if (data == null) {
              return _DashboardError(message: 'Sem dados disponíveis.');
            }
            final errorMessage = data['error'] as String?;
            if (errorMessage != null) {
              return _DashboardError(
                message: errorMessage,
                onAction: () {
                  if (errorMessage.toLowerCase().contains('sessão expirada')) {
                    Navigator.pushNamedAndRemoveUntil(
                        context, '/login', (_) => false);
                  } else {
                    _reload();
                  }
                },
              );
            }

            final totalComunicados = _asInt(data['totalComunicados']);
            final comunicadosPendentes = _asInt(data['comunicadosPendentes']);
            final comunicadosLidos = _asInt(data['comunicadosLidos']);
            final totalDecisoes = _asInt(data['totalDecisoes']);
            final notificacoesNaoLidas = _asInt(data['notificacoesNaoLidas']);

            final decisoesPorStatus =
                (data['decisoesPorStatus'] as Map?)?.cast<String, dynamic>() ??
                    {};
            final atividadesPorSecretaria =
                (data['atividadesPorSecretaria'] as Map?)
                        ?.cast<String, dynamic>() ??
                    {};

            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                if (userName != null && userName.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Text(
                      'Olá, $userName!',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    _StatCard(
                        title: 'Comunicados',
                        value: totalComunicados,
                        subtitle:
                            '$comunicadosPendentes pendentes, $comunicadosLidos lidos',
                        onTap: () {
                          Navigator.pushNamed(
                                  context, ComunicadosScreen.routeName)
                              .then((_) {
                            if (mounted) {
                              _reload();
                            }
                          });
                        }),
                    _StatCard(
                        title: 'Decisões',
                        value: totalDecisoes,
                        subtitle:
                            '${decisoesPorStatus.length} status acompanhados',
                        onTap: () {
                          Navigator.pushNamed(context, DecisoesScreen.routeName)
                              .then((_) {
                            if (mounted) {
                              _reload();
                            }
                          });
                        }),
                    _StatCard(
                        title: 'Notificações',
                        value: notificacoesNaoLidas,
                        subtitle: 'não lidas',
                        onTap: () {
                          Navigator.pushNamed(
                                  context, NotificacoesScreen.routeName)
                              .then((_) {
                            if (mounted) {
                              _reload();
                            }
                          });
                        }),
                  ],
                ),
                const SizedBox(height: 16),
                _QuickActions(
                  onCreateComunicado: _openComunicadoDialog,
                  onCreateDecisao: _openDecisaoDialog,
                  onCreateComentario: _openComentarioDialog,
                  onCreateNotificacao: _openNotificacaoDialog,
                ),
                const SizedBox(height: 16),
                _DataCard(
                  title: 'Decisões por status',
                  items: decisoesPorStatus,
                  emptyMessage: 'Nenhuma decisão registrada ainda.',
                ),
                const SizedBox(height: 16),
                _DataCard(
                  title: 'Atividades por secretaria',
                  items: atividadesPorSecretaria,
                  emptyMessage: 'Nenhum comunicado associado às secretarias.',
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  void _openCreationDialog(
      BuildContext context, String titulo, String descricao) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Criar $titulo'),
        content: Text(descricao),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Cancelar')),
          ElevatedButton(
              onPressed: () {
                Navigator.of(ctx).pop();
                _reload();
              },
              child: const Text('Continuar')),
        ],
      ),
    );
  }

  Future<void> _openComunicadoDialog() async {
    final created = await showDialog<bool>(
      context: context,
      builder: (ctx) => const _ComunicadoDialog(),
    );
    if (created == true && mounted) {
      await _reload();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Comunicado criado com sucesso.')),
      );
    }
  }

  Future<void> _openDecisaoDialog() async {
    final created = await showDialog<bool>(
      context: context,
      builder: (ctx) => const _DecisaoDialog(),
    );
    if (created == true && mounted) {
      await _reload();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Decisão criada com sucesso.')),
      );
    }
  }

  Future<void> _openComentarioDialog() async {
    final created = await showDialog<bool>(
      context: context,
      builder: (ctx) => const _ComentarioDialog(),
    );
    if (created == true && mounted) {
      await _reload();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Comentário registrado com sucesso.')),
      );
    }
  }

  Future<void> _openNotificacaoDialog() async {
    final created = await showDialog<bool>(
      context: context,
      builder: (ctx) => const _NotificacaoDialog(),
    );
    if (created == true && mounted) {
      await _reload();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Notificação enviada com sucesso.')),
      );
    }
  }
}

class _QuickActions extends StatelessWidget {
  final VoidCallback onCreateComunicado;
  final VoidCallback onCreateDecisao;
  final VoidCallback onCreateComentario;
  final VoidCallback onCreateNotificacao;

  const _QuickActions({
    required this.onCreateComunicado,
    required this.onCreateDecisao,
    required this.onCreateComentario,
    required this.onCreateNotificacao,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Ações rápidas',
                style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                _ActionChip(
                    icon: Icons.campaign_outlined,
                    label: 'Novo comunicado',
                    onPressed: onCreateComunicado),
                _ActionChip(
                    icon: Icons.task_alt_outlined,
                    label: 'Nova decisão',
                    onPressed: onCreateDecisao),
                _ActionChip(
                    icon: Icons.chat_bubble_outline,
                    label: 'Novo comentário',
                    onPressed: onCreateComentario),
                _ActionChip(
                    icon: Icons.notifications_active_outlined,
                    label: 'Nova notificação',
                    onPressed: onCreateNotificacao),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  const _ActionChip(
      {required this.icon, required this.label, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon),
      label: Text(label),
      style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12)),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final int value;
  final String? subtitle;
  final VoidCallback? onTap;

  const _StatCard({
    required this.title,
    required this.value,
    this.subtitle,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 220,
      child: Card(
        elevation: 2,
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 8),
                Text('$value',
                    style: const TextStyle(
                        fontSize: 32, fontWeight: FontWeight.bold)),
                if (subtitle != null) ...[
                  const SizedBox(height: 4),
                  Text(subtitle!,
                      style: Theme.of(context).textTheme.bodyMedium),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DataCard extends StatelessWidget {
  final String title;
  final Map<String, dynamic> items;
  final String emptyMessage;

  const _DataCard({
    required this.title,
    required this.items,
    required this.emptyMessage,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 12),
            if (items.isEmpty)
              Text(emptyMessage, style: Theme.of(context).textTheme.bodyMedium)
            else
              ...items.entries.map(
                (entry) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                          child: Text(entry.key,
                              style: Theme.of(context).textTheme.bodyMedium)),
                      const SizedBox(width: 12),
                      Text('${entry.value}',
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _DashboardError extends StatelessWidget {
  final String message;
  final VoidCallback? onAction;

  const _DashboardError({required this.message, this.onAction});

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.6,
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(message, textAlign: TextAlign.center),
                const SizedBox(height: 12),
                if (onAction != null)
                  ElevatedButton(
                    onPressed: onAction,
                    child: const Text('Tentar novamente'),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _ComunicadoDialog extends StatefulWidget {
  const _ComunicadoDialog();

  @override
  State<_ComunicadoDialog> createState() => _ComunicadoDialogState();
}

class _ComunicadoDialogState extends State<_ComunicadoDialog> {
  final _formKey = GlobalKey<FormState>();
  final _tituloController = TextEditingController();
  final _conteudoController = TextEditingController();
  final _emailController = TextEditingController();

  List<Map<String, dynamic>>? _secretarias;
  bool _loadingSecretarias = true;
  String? _loadError;

  List<Map<String, dynamic>>? _usuarios;
  bool _loadingUsuarios = false;
  String? _usuarioError;
  int? _selectedUsuarioId;

  bool _submitting = false;
  String _prioridade = 'MEDIA';
  int? _secretariaDestinoId;

  String _formatError(Object error) {
    final message = error.toString();
    const prefix = 'Exception: ';
    if (message.startsWith(prefix)) {
      return message.substring(prefix.length);
    }
    return message;
  }

  @override
  void initState() {
    super.initState();
    _fetchSecretarias();
  }

  @override
  void dispose() {
    _tituloController.dispose();
    _conteudoController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _fetchSecretarias() async {
    setState(() {
      _loadingSecretarias = true;
      _loadError = null;
    });
    try {
      final items = await ApiService.fetchSecretarias();
      if (!mounted) return;
      setState(() {
        _secretarias = items;
        _loadingSecretarias = false;
      });
      if (!mounted) return;
      if (_secretariaDestinoId != null) {
        await _fetchUsuarios(_secretariaDestinoId);
      }
    } catch (e) {
      setState(() {
        _loadError = _formatError(e);
        _loadingSecretarias = false;
      });
    }
  }

  int? _parseId(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value);
    return null;
  }

  Future<void> _fetchUsuarios(int? secretariaId) async {
    if (!mounted) return;
    setState(() {
      _loadingUsuarios = true;
      _usuarioError = null;
      _usuarios = null;
      _selectedUsuarioId = null;
    });

    if (secretariaId == null) {
      setState(() {
        _loadingUsuarios = false;
      });
      _emailController.clear();
      return;
    }

    try {
      final items = await ApiService.fetchUsuarios(secretariaId: secretariaId);
      if (!mounted) return;
      setState(() {
        _usuarios = items;
        _loadingUsuarios = false;
      });
      if (items.isEmpty) {
        _emailController.clear();
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _usuarioError = _formatError(e);
        _loadingUsuarios = false;
        _usuarios = null;
      });
      _emailController.clear();
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    setState(() {
      _submitting = true;
    });

    try {
      final result = await ApiService.criarComunicado(
        titulo: _tituloController.text.trim(),
        conteudo: _conteudoController.text.trim(),
        prioridade: _prioridade,
        secretariaDestinoId: _secretariaDestinoId,
        emailNotificacao: _emailController.text.trim().isEmpty
            ? null
            : _emailController.text.trim(),
      );
      final error = result?['error'] as String?;
      if (error != null) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error)),
        );
      } else {
        if (!mounted) return;
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_formatError(e))),
      );
    } finally {
      if (mounted) {
        setState(() {
          _submitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Novo comunicado'),
      content: SizedBox(
        width: 460,
        child: _loadingSecretarias
            ? const SizedBox(
                height: 120, child: Center(child: CircularProgressIndicator()))
            : _loadError != null
                ? Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(_loadError!, textAlign: TextAlign.center),
                      const SizedBox(height: 12),
                      ElevatedButton(
                        onPressed: _fetchSecretarias,
                        child: const Text('Tentar novamente'),
                      ),
                    ],
                  )
                : Form(
                    key: _formKey,
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          TextFormField(
                            controller: _tituloController,
                            decoration:
                                const InputDecoration(labelText: 'Título'),
                            textInputAction: TextInputAction.next,
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Informe o título';
                              }
                              if (value.trim().length > 255) {
                                return 'Título muito longo';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: _conteudoController,
                            decoration:
                                const InputDecoration(labelText: 'Conteúdo'),
                            maxLines: 4,
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Informe o conteúdo';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 12),
                          DropdownButtonFormField<String>(
                            value: _prioridade,
                            decoration:
                                const InputDecoration(labelText: 'Prioridade'),
                            items: const [
                              DropdownMenuItem(
                                  value: 'BAIXA', child: Text('Baixa')),
                              DropdownMenuItem(
                                  value: 'MEDIA', child: Text('Média')),
                              DropdownMenuItem(
                                  value: 'ALTA', child: Text('Alta')),
                              DropdownMenuItem(
                                  value: 'URGENTE', child: Text('Urgente')),
                            ],
                            onChanged: (value) {
                              if (value != null) {
                                setState(() {
                                  _prioridade = value;
                                });
                              }
                            },
                          ),
                          const SizedBox(height: 12),
                          DropdownButtonFormField<int?>(
                            value: _secretariaDestinoId,
                            decoration: const InputDecoration(
                                labelText: 'Secretaria destino (opcional)'),
                            items: [
                              const DropdownMenuItem<int?>(
                                value: null,
                                child: Text('Nenhuma'),
                              ),
                              ...?_secretarias?.map(
                                (item) {
                                  final idRaw = item['id'];
                                  final id = idRaw is int
                                      ? idRaw
                                      : (idRaw is num ? idRaw.toInt() : null);
                                  final label = (item['nome'] ??
                                          item['sigla'] ??
                                          'Sem nome')
                                      .toString();
                                  return DropdownMenuItem<int?>(
                                    value: id,
                                    child: Text(label),
                                  );
                                },
                              ),
                            ],
                            onChanged: (value) {
                              setState(() {
                                _secretariaDestinoId = value;
                              });
                              _fetchUsuarios(value);
                            },
                          ),
                          const SizedBox(height: 12),
                          if (_loadingUsuarios)
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 8),
                              child: LinearProgressIndicator(),
                            )
                          else if (_usuarioError != null)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _usuarioError!,
                                    style: const TextStyle(color: Colors.red),
                                  ),
                                  TextButton(
                                    onPressed: () =>
                                        _fetchUsuarios(_secretariaDestinoId),
                                    child: const Text('Tentar novamente'),
                                  ),
                                ],
                              ),
                            )
                          else if (_usuarios != null && _usuarios!.isNotEmpty)
                            DropdownButtonFormField<int>(
                              value: _selectedUsuarioId,
                              decoration: const InputDecoration(
                                  labelText:
                                      'Destinatário (usuário da secretaria)'),
                              items: _usuarios!
                                  .map((item) {
                                    final id = _parseId(item['id']);
                                    if (id == null) {
                                      return null;
                                    }
                                    final nome =
                                        (item['nome'] ?? 'Sem nome').toString();
                                    final cargo =
                                        (item['cargo'] ?? '').toString().trim();
                                    final label = cargo.isNotEmpty
                                        ? '$nome ($cargo)'
                                        : nome;
                                    return DropdownMenuItem<int>(
                                      value: id,
                                      child: Text(label),
                                    );
                                  })
                                  .whereType<DropdownMenuItem<int>>()
                                  .toList(growable: false),
                              onChanged: (value) {
                                setState(() {
                                  _selectedUsuarioId = value;
                                  if (value != null) {
                                    final selected = _usuarios!.firstWhere(
                                      (item) => _parseId(item['id']) == value,
                                    );
                                    final email =
                                        selected['email']?.toString() ?? '';
                                    if (email.isNotEmpty &&
                                        _emailController.text.trim().isEmpty) {
                                      _emailController.text = email;
                                    }
                                  }
                                });
                              },
                            )
                          else if (_usuarios != null)
                            const Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                  'Nenhum usuário ativo nessa secretaria.'),
                            ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: _emailController,
                            decoration: const InputDecoration(
                              labelText: 'E-mail para notificação (opcional)',
                            ),
                            keyboardType: TextInputType.emailAddress,
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return null;
                              }
                              final email = value.trim();
                              final emailRegex = RegExp(
                                  r'^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$');
                              if (!emailRegex.hasMatch(email)) {
                                return 'E-mail inválido';
                              }
                              return null;
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
      ),
      actions: _loadingSecretarias
          ? []
          : [
              TextButton(
                onPressed:
                    _submitting ? null : () => Navigator.of(context).pop(false),
                child: const Text('Cancelar'),
              ),
              ElevatedButton(
                onPressed: _submitting ? null : _submit,
                child: _submitting
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Criar'),
              ),
            ],
    );
  }
}

class _DecisaoDialog extends StatefulWidget {
  const _DecisaoDialog();

  @override
  State<_DecisaoDialog> createState() => _DecisaoDialogState();
}

class _DecisaoDialogState extends State<_DecisaoDialog> {
  final _formKey = GlobalKey<FormState>();
  final _tituloController = TextEditingController();
  final _descricaoController = TextEditingController();
  final _emailController = TextEditingController();
  final _prazoController = TextEditingController();

  List<Map<String, dynamic>>? _usuarios;
  bool _loadingUsuarios = true;
  String? _loadError;

  bool _submitting = false;
  int? _responsavelId;
  DateTime? _prazo;

  @override
  void initState() {
    super.initState();
    _fetchUsuarios();
  }

  @override
  void dispose() {
    _tituloController.dispose();
    _descricaoController.dispose();
    _emailController.dispose();
    _prazoController.dispose();
    super.dispose();
  }

  String _formatError(Object error) {
    final message = error.toString();
    const prefix = 'Exception: ';
    if (message.startsWith(prefix)) {
      return message.substring(prefix.length);
    }
    return message;
  }

  Future<void> _fetchUsuarios() async {
    setState(() {
      _loadingUsuarios = true;
      _loadError = null;
    });
    try {
      final items = await ApiService.fetchUsuarios();
      if (!mounted) return;
      setState(() {
        _usuarios = items;
        _loadingUsuarios = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loadError = _formatError(e);
        _loadingUsuarios = false;
      });
    }
  }

  int? _parseId(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value);
    return null;
  }

  String _formatPrazo(DateTime dateTime) {
    final local = dateTime.toLocal();
    String twoDigits(int value) => value.toString().padLeft(2, '0');
    return '${local.year}-${twoDigits(local.month)}-${twoDigits(local.day)} '
        '${twoDigits(local.hour)}:${twoDigits(local.minute)}';
  }

  Future<void> _pickPrazo() async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final initialDate = _prazo ?? now;
    final initialForPicker = initialDate.isBefore(today) ? today : initialDate;
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: initialForPicker,
      firstDate: today,
      lastDate: DateTime(now.year + 2, 12, 31),
    );
    if (pickedDate == null) {
      return;
    }
    final pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_prazo ?? now),
    );
    if (pickedTime == null) {
      return;
    }
    final combined = DateTime(
      pickedDate.year,
      pickedDate.month,
      pickedDate.day,
      pickedTime.hour,
      pickedTime.minute,
    );
    setState(() {
      _prazo = combined;
      _prazoController.text = _formatPrazo(combined);
    });
  }

  void _clearPrazo() {
    setState(() {
      _prazo = null;
      _prazoController.clear();
    });
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _submitting = true;
    });

    try {
      final result = await ApiService.criarDecisao(
        titulo: _tituloController.text.trim(),
        descricao: _descricaoController.text.trim(),
        responsavelId: _responsavelId!,
        prazo: _prazo,
        emailNotificacao: _emailController.text.trim().isEmpty
            ? null
            : _emailController.text.trim(),
      );
      final error = result?['error'] as String?;
      if (error != null) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error)),
        );
      } else {
        if (!mounted) return;
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_formatError(e))),
      );
    } finally {
      if (mounted) {
        setState(() {
          _submitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Nova decisão'),
      content: SizedBox(
        width: 460,
        child: _loadingUsuarios
            ? const SizedBox(
                height: 120,
                child: Center(child: CircularProgressIndicator()),
              )
            : _loadError != null
                ? Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(_loadError!, textAlign: TextAlign.center),
                      const SizedBox(height: 12),
                      ElevatedButton(
                        onPressed: _fetchUsuarios,
                        child: const Text('Tentar novamente'),
                      ),
                    ],
                  )
                : Form(
                    key: _formKey,
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          TextFormField(
                            controller: _tituloController,
                            decoration:
                                const InputDecoration(labelText: 'Título'),
                            textInputAction: TextInputAction.next,
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Informe o título';
                              }
                              if (value.trim().length > 255) {
                                return 'Título muito longo';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: _descricaoController,
                            decoration:
                                const InputDecoration(labelText: 'Descrição'),
                            maxLines: 4,
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Informe a descrição';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 12),
                          DropdownButtonFormField<int>(
                            value: _responsavelId,
                            decoration:
                                const InputDecoration(labelText: 'Responsável'),
                            items: _usuarios!
                                .map((item) {
                                  final id = _parseId(item['id']);
                                  if (id == null) {
                                    return null;
                                  }
                                  final nome =
                                      (item['nome'] ?? 'Sem nome').toString();
                                  final cargo =
                                      (item['cargo'] ?? '').toString().trim();
                                  final secretaria =
                                      (item['secretariaNome'] ?? '')
                                          .toString()
                                          .trim();
                                  final subtitleParts = [cargo, secretaria]
                                      .where((part) => part.isNotEmpty)
                                      .join(' • ');
                                  final label = subtitleParts.isEmpty
                                      ? nome
                                      : '$nome ($subtitleParts)';
                                  return DropdownMenuItem<int>(
                                    value: id,
                                    child: Text(label),
                                  );
                                })
                                .whereType<DropdownMenuItem<int>>()
                                .toList(growable: false),
                            onChanged: (value) {
                              setState(() {
                                _responsavelId = value;
                                if (value != null) {
                                  final selected = _usuarios!.firstWhere(
                                      (item) => _parseId(item['id']) == value,
                                      orElse: () => <String, dynamic>{});
                                  final email =
                                      selected['email']?.toString() ?? '';
                                  if (_emailController.text.trim().isEmpty &&
                                      email.isNotEmpty) {
                                    _emailController.text = email;
                                  }
                                }
                              });
                            },
                            validator: (value) {
                              if (value == null) {
                                return 'Selecione o responsável';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: _prazoController,
                            readOnly: true,
                            decoration: InputDecoration(
                              labelText: 'Prazo (opcional)',
                              suffixIcon: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  if (_prazo != null)
                                    IconButton(
                                      icon: const Icon(Icons.clear),
                                      tooltip: 'Limpar prazo',
                                      onPressed:
                                          _submitting ? null : _clearPrazo,
                                    ),
                                  IconButton(
                                    icon: const Icon(
                                        Icons.calendar_month_outlined),
                                    tooltip: 'Selecionar prazo',
                                    onPressed: _submitting ? null : _pickPrazo,
                                  ),
                                ],
                              ),
                            ),
                            onTap: _submitting ? null : _pickPrazo,
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: _emailController,
                            decoration: const InputDecoration(
                              labelText: 'E-mail para notificação (opcional)',
                            ),
                            keyboardType: TextInputType.emailAddress,
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return null;
                              }
                              final email = value.trim();
                              final emailRegex = RegExp(
                                  r'^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$');
                              if (!emailRegex.hasMatch(email)) {
                                return 'E-mail inválido';
                              }
                              return null;
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
      ),
      actions: _loadingUsuarios
          ? []
          : [
              TextButton(
                onPressed:
                    _submitting ? null : () => Navigator.of(context).pop(false),
                child: const Text('Cancelar'),
              ),
              ElevatedButton(
                onPressed: _submitting ? null : _submit,
                child: _submitting
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Criar'),
              ),
            ],
    );
  }
}

class _ComentarioDialog extends StatefulWidget {
  const _ComentarioDialog();

  @override
  State<_ComentarioDialog> createState() => _ComentarioDialogState();
}

class _ComentarioDialogState extends State<_ComentarioDialog> {
  final _formKey = GlobalKey<FormState>();
  final _comentarioController = TextEditingController();

  List<Map<String, dynamic>>? _decisoes;
  bool _loadingDecisoes = true;
  String? _loadError;
  int? _decisaoSelecionadaId;
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    _fetchDecisoes();
  }

  @override
  void dispose() {
    _comentarioController.dispose();
    super.dispose();
  }

  String _formatError(Object error) {
    final message = error.toString();
    const prefix = 'Exception: ';
    if (message.startsWith(prefix)) {
      return message.substring(prefix.length);
    }
    return message;
  }

  String _formatStatus(dynamic statusRaw) {
    if (statusRaw == null) {
      return 'Desconhecido';
    }
    final value = statusRaw.toString().toLowerCase();
    if (value.isEmpty) return 'Desconhecido';
    return value[0].toUpperCase() + value.substring(1).replaceAll('_', ' ');
  }

  int? _parseId(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value);
    return null;
  }

  DateTime? _parseDate(dynamic value) {
    if (value is String && value.isNotEmpty) {
      return DateTime.tryParse(value);
    }
    return null;
  }

  Future<void> _fetchDecisoes() async {
    setState(() {
      _loadingDecisoes = true;
      _loadError = null;
    });
    try {
      final items = await ApiService.fetchDecisoes();
      if (!mounted) return;
      final filtered = items.where((item) {
        final status = item['status']?.toString();
        return status != 'CANCELADA';
      }).toList(growable: false);
      filtered.sort((a, b) {
        final dateA = _parseDate(a['dataCriacao']);
        final dateB = _parseDate(b['dataCriacao']);
        if (dateA == null && dateB == null) return 0;
        if (dateA == null) return 1;
        if (dateB == null) return -1;
        return dateB.compareTo(dateA);
      });
      setState(() {
        _decisoes = filtered;
        _loadingDecisoes = false;
        _decisaoSelecionadaId =
            filtered.isNotEmpty ? _parseId(filtered.first['id']) : null;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loadError = _formatError(e);
        _loadingDecisoes = false;
      });
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_decisaoSelecionadaId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecione a decisão.')),
      );
      return;
    }

    setState(() {
      _submitting = true;
    });

    try {
      final result = await ApiService.criarComentario(
        decisaoId: _decisaoSelecionadaId!,
        conteudo: _comentarioController.text.trim(),
      );
      final error = result?['error'] as String?;
      if (error != null) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error)),
        );
      } else {
        if (!mounted) return;
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_formatError(e))),
      );
    } finally {
      if (mounted) {
        setState(() {
          _submitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Novo comentário'),
      content: SizedBox(
        width: 460,
        child: _loadingDecisoes
            ? const SizedBox(
                height: 120,
                child: Center(child: CircularProgressIndicator()),
              )
            : _loadError != null
                ? Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(_loadError!, textAlign: TextAlign.center),
                      const SizedBox(height: 12),
                      ElevatedButton(
                        onPressed: _fetchDecisoes,
                        child: const Text('Tentar novamente'),
                      ),
                    ],
                  )
                : _decisoes == null || _decisoes!.isEmpty
                    ? SizedBox(
                        height: 120,
                        child: Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: const [
                              Icon(Icons.info_outline, size: 32),
                              SizedBox(height: 8),
                              Text(
                                'Não há decisões disponíveis para comentar.',
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      )
                    : Form(
                        key: _formKey,
                        child: SingleChildScrollView(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              DropdownButtonFormField<int>(
                                value: _decisaoSelecionadaId,
                                decoration:
                                    const InputDecoration(labelText: 'Decisão'),
                                items: _decisoes!
                                    .map((item) {
                                      final id = _parseId(item['id']);
                                      if (id == null) {
                                        return null;
                                      }
                                      final titulo =
                                          (item['titulo'] ?? 'Sem título')
                                              .toString();
                                      final status =
                                          _formatStatus(item['status']);
                                      final responsavel =
                                          (item['responsavelNome'] ?? '')
                                              .toString()
                                              .trim();
                                      final label = StringBuffer(titulo);
                                      if (responsavel.isNotEmpty) {
                                        label.write(' • $responsavel');
                                      }
                                      label.write(' • $status');
                                      return DropdownMenuItem<int>(
                                        value: id,
                                        child: Text(label.toString()),
                                      );
                                    })
                                    .whereType<DropdownMenuItem<int>>()
                                    .toList(growable: false),
                                onChanged: (value) {
                                  setState(() {
                                    _decisaoSelecionadaId = value;
                                  });
                                },
                                validator: (value) {
                                  if (value == null) {
                                    return 'Selecione a decisão';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 12),
                              TextFormField(
                                controller: _comentarioController,
                                decoration: const InputDecoration(
                                  labelText: 'Comentário',
                                ),
                                maxLines: 4,
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'Informe o comentário';
                                  }
                                  return null;
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
      ),
      actions: _loadingDecisoes
          ? []
          : [
              TextButton(
                onPressed:
                    _submitting ? null : () => Navigator.of(context).pop(false),
                child: const Text('Cancelar'),
              ),
              ElevatedButton(
                onPressed:
                    _submitting || _decisoes == null || _decisoes!.isEmpty
                        ? null
                        : _submit,
                child: _submitting
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Registrar'),
              ),
            ],
    );
  }
}

class _NotificacaoDialog extends StatefulWidget {
  const _NotificacaoDialog();

  @override
  State<_NotificacaoDialog> createState() => _NotificacaoDialogState();
}

class _NotificacaoDialogState extends State<_NotificacaoDialog> {
  final _formKey = GlobalKey<FormState>();
  final _tituloController = TextEditingController();
  final _mensagemController = TextEditingController();
  final _emailController = TextEditingController();

  List<Map<String, dynamic>>? _usuarios;
  bool _loadingUsuarios = true;
  String? _loadError;
  int? _usuarioDestinoId;

  String _tipo = 'SISTEMA';
  bool _submitting = false;

  static const _tipoOpcoes = [
    {'value': 'SISTEMA', 'label': 'Sistema'},
    {'value': 'NOVO_COMUNICADO', 'label': 'Novo comunicado'},
    {'value': 'NOVA_DECISAO', 'label': 'Nova decisão'},
    {'value': 'PRAZO_DECISAO', 'label': 'Lembrete de prazo'},
    {'value': 'COMENTARIO_DECISAO', 'label': 'Comentário em decisão'},
  ];

  @override
  void initState() {
    super.initState();
    _fetchUsuarios();
  }

  @override
  void dispose() {
    _tituloController.dispose();
    _mensagemController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  String _formatError(Object error) {
    final message = error.toString();
    const prefix = 'Exception: ';
    if (message.startsWith(prefix)) {
      return message.substring(prefix.length);
    }
    return message;
  }

  int? _parseId(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value);
    return null;
  }

  Future<void> _fetchUsuarios() async {
    setState(() {
      _loadingUsuarios = true;
      _loadError = null;
    });
    try {
      final items = await ApiService.fetchUsuarios();
      if (!mounted) return;
      setState(() {
        _usuarios = items;
        _loadingUsuarios = false;
        _usuarioDestinoId =
            items.isNotEmpty ? _parseId(items.first['id']) : null;
      });
      if (_usuarioDestinoId != null) {
        final firstEmail = items.first['email']?.toString();
        if (firstEmail != null && firstEmail.isNotEmpty) {
          _emailController.text = firstEmail;
        }
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loadError = _formatError(e);
        _loadingUsuarios = false;
      });
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    if (_usuarioDestinoId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecione o destinatário.')),
      );
      return;
    }

    setState(() {
      _submitting = true;
    });

    try {
      final result = await ApiService.criarNotificacao(
        titulo: _tituloController.text.trim(),
        mensagem: _mensagemController.text.trim(),
        tipo: _tipo,
        usuarioDestinoId: _usuarioDestinoId!,
        emailNotificacao: _emailController.text.trim().isEmpty
            ? null
            : _emailController.text.trim(),
      );
      final error = result?['error'] as String?;
      if (error != null) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error)),
        );
      } else {
        if (!mounted) return;
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_formatError(e))),
      );
    } finally {
      if (mounted) {
        setState(() {
          _submitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Nova notificação'),
      content: SizedBox(
        width: 460,
        child: _loadingUsuarios
            ? const SizedBox(
                height: 120,
                child: Center(child: CircularProgressIndicator()),
              )
            : _loadError != null
                ? Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(_loadError!, textAlign: TextAlign.center),
                      const SizedBox(height: 12),
                      ElevatedButton(
                        onPressed: _fetchUsuarios,
                        child: const Text('Tentar novamente'),
                      ),
                    ],
                  )
                : _usuarios == null || _usuarios!.isEmpty
                    ? SizedBox(
                        height: 120,
                        child: Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: const [
                              Icon(Icons.info_outline, size: 32),
                              SizedBox(height: 8),
                              Text(
                                'Não há usuários ativos para receber notificações.',
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      )
                    : Form(
                        key: _formKey,
                        child: SingleChildScrollView(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              TextFormField(
                                controller: _tituloController,
                                decoration: const InputDecoration(
                                  labelText: 'Título',
                                ),
                                textInputAction: TextInputAction.next,
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'Informe o título';
                                  }
                                  if (value.trim().length > 255) {
                                    return 'Título muito longo';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 12),
                              TextFormField(
                                controller: _mensagemController,
                                decoration: const InputDecoration(
                                  labelText: 'Mensagem',
                                ),
                                maxLines: 4,
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'Informe a mensagem';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 12),
                              DropdownButtonFormField<String>(
                                value: _tipo,
                                decoration: const InputDecoration(
                                    labelText: 'Tipo de notificação'),
                                items: _tipoOpcoes
                                    .map((item) => DropdownMenuItem<String>(
                                          value: item['value']!,
                                          child: Text(item['label']!),
                                        ))
                                    .toList(growable: false),
                                onChanged: (value) {
                                  if (value != null) {
                                    setState(() {
                                      _tipo = value;
                                    });
                                  }
                                },
                              ),
                              const SizedBox(height: 12),
                              DropdownButtonFormField<int>(
                                value: _usuarioDestinoId,
                                decoration: const InputDecoration(
                                    labelText: 'Destinatário'),
                                items: _usuarios!
                                    .map((item) {
                                      final id = _parseId(item['id']);
                                      if (id == null) {
                                        return null;
                                      }
                                      final nome = (item['nome'] ?? 'Sem nome')
                                          .toString();
                                      final cargo = (item['cargo'] ?? '')
                                          .toString()
                                          .trim();
                                      final label = cargo.isNotEmpty
                                          ? '$nome ($cargo)'
                                          : nome;
                                      return DropdownMenuItem<int>(
                                        value: id,
                                        child: Text(label),
                                      );
                                    })
                                    .whereType<DropdownMenuItem<int>>()
                                    .toList(growable: false),
                                onChanged: (value) {
                                  setState(() {
                                    _usuarioDestinoId = value;
                                    if (value != null) {
                                      final selected = _usuarios!.firstWhere(
                                        (item) => _parseId(item['id']) == value,
                                      );
                                      final email =
                                          selected['email']?.toString() ?? '';
                                      if (_emailController.text
                                              .trim()
                                              .isEmpty &&
                                          email.isNotEmpty) {
                                        _emailController.text = email;
                                      }
                                    }
                                  });
                                },
                                validator: (value) {
                                  if (value == null) {
                                    return 'Selecione o destinatário';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 12),
                              TextFormField(
                                controller: _emailController,
                                decoration: const InputDecoration(
                                  labelText:
                                      'E-mail para notificação (opcional)',
                                ),
                                keyboardType: TextInputType.emailAddress,
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return null;
                                  }
                                  final email = value.trim();
                                  final emailRegex = RegExp(
                                      r'^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$');
                                  if (!emailRegex.hasMatch(email)) {
                                    return 'E-mail inválido';
                                  }
                                  return null;
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
      ),
      actions: _loadingUsuarios
          ? []
          : [
              TextButton(
                onPressed:
                    _submitting ? null : () => Navigator.of(context).pop(false),
                child: const Text('Cancelar'),
              ),
              ElevatedButton(
                onPressed:
                    _submitting || _usuarios == null || _usuarios!.isEmpty
                        ? null
                        : _submit,
                child: _submitting
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Enviar'),
              ),
            ],
    );
  }
}
