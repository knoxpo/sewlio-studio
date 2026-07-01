import 'package:flutter/material.dart';
import 'package:studio_bindings/studio_bindings.dart';
import 'package:studio_design_system/studio_design_system.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initEngine();
  runApp(const StudioApp());
}

class StudioApp extends StatelessWidget {
  const StudioApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sewlio Studio',
      theme: ThemeData(
        colorSchemeSeed: AppTokens.seed,
        useMaterial3: true,
      ),
      home: const _HomePage(),
    );
  }
}

class _HomePage extends StatelessWidget {
  const _HomePage();

  @override
  Widget build(BuildContext context) {
    // Proves the Flutter → FFI → Rust round trip: the version string comes from
    // es_core via the flutter_rust_bridge boundary.
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppTokens.spacing * 2),
          child: Text(appVersion(), key: const Key('engine-version')),
        ),
      ),
    );
  }
}
