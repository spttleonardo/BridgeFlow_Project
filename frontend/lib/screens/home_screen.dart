import 'package:flutter/material.dart';
import '../widgets/bridgeflow_scaffold.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BridgeFlowScaffold(
      body: Container(
        width: double.infinity,
        color: Theme.of(context).colorScheme.surface,
        child: const Center(
          child: Padding(
            padding: EdgeInsets.all(32),
            child: Text(
              'Bem-vindo ao BridgeFlow!',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }
}
