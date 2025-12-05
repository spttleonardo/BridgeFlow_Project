import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/api_service.dart';

typedef _RouteCallback = void Function(String route);

class BridgeFlowScaffold extends StatefulWidget {
  const BridgeFlowScaffold({
    super.key,
    required this.body,
    this.extraActions = const <Widget>[],
    this.showSidebar = true,
    this.backgroundColor,
  });

  final Widget body;
  final List<Widget> extraActions;
  final bool showSidebar;
  final Color? backgroundColor;

  @override
  State<BridgeFlowScaffold> createState() => _BridgeFlowScaffoldState();
}

class _BridgeFlowScaffoldState extends State<BridgeFlowScaffold> {
  bool _loggedIn = false;

  @override
  void initState() {
    super.initState();
    _checkLogin();
  }

  Future<void> _checkLogin() async {
    try {
      await ApiService.restoreAuthFromStorage();
      final autenticado = await AuthService.isLoggedIn();
      if (!mounted) return;
      setState(() {
        _loggedIn = autenticado;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _loggedIn = false;
      });
    }
  }

  static const _navItems = <_NavItem>[
    _NavItem(label: 'Início', route: '/home'),
    _NavItem(label: 'Serviços', route: '/servicos'),
    _NavItem(label: 'Contato', route: '/contato'),
  ];

  static const _sidebarItems = <_SidebarItem>[
    _SidebarItem(label: 'Dashboard', icon: Icons.dashboard_outlined, route: '/dashboard'),
    _SidebarItem(label: 'Comunicados', icon: Icons.announcement_outlined, route: '/comunicados'),
    _SidebarItem(label: 'Decisões', icon: Icons.gavel_outlined, route: '/decisoes'),
    _SidebarItem(label: 'Notificações', icon: Icons.notifications_outlined, route: '/notificacoes'),
    _SidebarItem(label: 'Serviços', icon: Icons.miscellaneous_services_outlined, route: '/servicos'),
    _SidebarItem(label: 'Contato', icon: Icons.contact_mail_outlined, route: '/contato'),
  ];

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width >= 900;
    final currentRoute = ModalRoute.of(context)?.settings.name;
    final theme = Theme.of(context);
    final appBarColor = theme.appBarTheme.backgroundColor ?? theme.colorScheme.primary;

    void navigateTo(String route) {
      if (ModalRoute.of(context)?.settings.name == route) {
        return;
      }
      Navigator.pushNamed(context, route);
    }

    Widget buildHeaderButton(_NavItem item) {
      final isActive = currentRoute == item.route;
      return TextButton(
        onPressed: () => navigateTo(item.route),
        style: TextButton.styleFrom(
          foregroundColor: Colors.white,
          textStyle: theme.textTheme.labelLarge?.copyWith(
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        child: Text(item.label),
      );
    }

    Widget buildSidebar(bool isDrawer) {
      return _BridgeFlowSidebar(
        currentRoute: currentRoute,
        isDrawer: isDrawer,
        items: _sidebarItems,
        onNavigate: navigateTo,
        loggedIn: _loggedIn,
        onLogout: () async {
          await ApiService.clearAuth();
          if (!mounted) return;
          setState(() {
            _loggedIn = false;
          });
          Navigator.pushNamedAndRemoveUntil(context, '/login', (_) => false);
        },
      );
    }

    final sidebarColor = Colors.grey[200];
    return Scaffold(
      backgroundColor: widget.backgroundColor,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: appBarColor,
        titleSpacing: 16,
        title: Row(
          children: [
            Image.asset(
              'assets/Flag_bnu.png',
              height: 32,
              errorBuilder: (ctx, error, stackTrace) => const Icon(Icons.error, color: Colors.red),
            ),
            const SizedBox(width: 12),
            const Text('BridgeFlow'),
          ],
        ),
        actions: [
          for (final item in _navItems) buildHeaderButton(item),
          // Login or Logout icon
          _loggedIn
              ? IconButton(
                  tooltip: 'Sair',
                  icon: const Icon(Icons.logout, color: Colors.white),
                  onPressed: () async {
                    await ApiService.clearAuth();
                    if (!mounted) return;
                    setState(() {
                      _loggedIn = false;
                    });
                    Navigator.pushNamedAndRemoveUntil(context, '/login', (_) => false);
                  },
                )
              : TextButton(
                  onPressed: () => navigateTo('/login'),
                  child: const Text('Login', style: TextStyle(color: Colors.white)),
                ),
          ...widget.extraActions,
          const SizedBox(width: 12),
        ],
      ),
      drawer: widget.showSidebar && !isWide ? Drawer(child: buildSidebar(true)) : null,
      body: Row(
        children: [
          if (widget.showSidebar && isWide)
            SizedBox(
              width: 260,
              child: Material(
                elevation: 2,
                color: sidebarColor,
                child: buildSidebar(false),
              ),
            ),
          Expanded(
            child: Column(
              children: [
                Expanded(child: widget.body),
                const _BridgeFlowFooter(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _NavItem {
  const _NavItem({required this.label, required this.route});

  final String label;
  final String route;
}

class _SidebarItem {
  const _SidebarItem({
    required this.label,
    required this.icon,
    required this.route,
  });

  final String label;
  final IconData icon;
  final String route;
}

class _BridgeFlowSidebar extends StatelessWidget {
  const _BridgeFlowSidebar({
    required this.items,
    required this.onNavigate,
    required this.currentRoute,
    required this.isDrawer,
    required this.loggedIn,
    required this.onLogout,
  });

  final List<_SidebarItem> items;
  final _RouteCallback onNavigate;
  final String? currentRoute;
  final bool isDrawer;
  final bool loggedIn;
  final VoidCallback onLogout;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const SizedBox(height: 24),
          for (final item in items)
            ListTile(
              leading: Icon(item.icon),
              title: Text(item.label),
              selected: currentRoute == item.route,
              onTap: () {
                if (isDrawer) {
                  Navigator.of(context).pop();
                }
                if (currentRoute == item.route) {
                  return;
                }
                onNavigate(item.route);
              },
            ),
          const Divider(height: 8),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Sair'),
            enabled: loggedIn,
            onTap: !loggedIn
                ? null
                : () {
                    if (isDrawer) {
                      Navigator.of(context).pop();
                    }
                    onLogout();
                  },
          ),
        ],
      ),
    );
  }
}

class _BridgeFlowFooter extends StatelessWidget {
  const _BridgeFlowFooter();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: Colors.grey[200],
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: const Center(
        child: Text(
          'Copyright © 2025 Prefeitura de Blumenau | Todos os direitos reservados',
          style: TextStyle(fontSize: 14, color: Colors.black54),
        ),
      ),
    );
  }
}
