import 'package:flutter/material.dart';
import 'package:lsp_mobile/cores/constants/color_const.dart';
import 'package:lsp_mobile/src/features/splash/views/splash_view.dart';
import 'package:lsp_mobile/src/repositories/sqlite_repository.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SQLiteRepository().database;
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'LSP MOBILE',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: ColorConst.primary500),
        useMaterial3: true,
      ),
      debugShowCheckedModeBanner: false,
      home: const SplashView(),
    );
  }
}
