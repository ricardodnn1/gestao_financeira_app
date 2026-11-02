import 'package:flutter/material.dart';
import 'package:gestao_financeira/src/app/bootstrap.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final bootstrap = AppBootstrap();
  final router = await bootstrap.initialize();

  runApp(bootstrap.buildApp(router));
}