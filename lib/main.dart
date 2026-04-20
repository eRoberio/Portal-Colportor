import 'package:flutter/foundation.dart' show kIsWeb;
// Importa o pacote para remover o # da URL no web

import 'package:flutter_web_plugins/flutter_web_plugins.dart';
import 'package:flutter_web_plugins/flutter_web_plugins.dart'
    show setUrlStrategy, PathUrlStrategy;

import 'package:colportportal/presentation/pages/reset_password_page.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'presentation/pages/login_page.dart';
import 'presentation/pages/home_page.dart';
import 'application/auth/auth_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (kIsWeb) {
    setUrlStrategy(PathUrlStrategy()); // Remove o # da URL no web
  }

  // Configurações para cada plataforma
  FirebaseOptions firebaseOptions;
  if (kIsWeb) {
    firebaseOptions = const FirebaseOptions(
      apiKey: 'AIzaSyBuFkF-90rv-ksVNX7tmsunYZTPV2aITUY',
      authDomain: 'colportor-portal.firebaseapp.com',
      projectId: 'colportor-portal',
      storageBucket: 'colportor-portal.firebasestorage.app',
      messagingSenderId: '143470236001',
      appId: '1:143470236001:web:a0a0d41bc828b102217520',
    );
  } else if (Platform.isAndroid) {
    firebaseOptions = const FirebaseOptions(
      apiKey: 'AIzaSyBCuzglvOCGJbjWjmkajgLS9bYo0cSy0fM',
      authDomain: 'colportor-portal.firebaseapp.com',
      projectId: 'colportor-portal',
      storageBucket: 'colportor-portal.firebasestorage.app',
      messagingSenderId: '143470236001',
      appId: '1:143470236001:android:c6280d30256d2a7e217520',
      measurementId: 'G-0LJBPP72QF',
    );
  } else if (Platform.isIOS) {
    firebaseOptions = const FirebaseOptions(
      apiKey: 'AIzaSyBCuzglvOCGJbjWjmkajgLS9bYo0cSy0fM',
      authDomain: 'colportor-portal.firebaseapp.com',
      projectId: 'colportor-portal',
      storageBucket: 'colportor-portal.firebasestorage.app',
      messagingSenderId: '143470236001',
      appId:
          '1:143470236001:ios:YOUR_IOS_APP_ID', // Substitua pelo seu appId iOS
      measurementId: 'G-0LJBPP72QF',
    );
  } else {
    // Default para outras plataformas
    firebaseOptions = const FirebaseOptions(
      apiKey: 'AIzaSyBCuzglvOCGJbjWjmkajgLS9bYo0cSy0fM',
      authDomain: 'colportor-portal.firebaseapp.com',
      projectId: 'colportor-portal',
      storageBucket: 'colportor-portal.firebasestorage.app',
      messagingSenderId: '143470236001',
      appId: '1:143470236001:default',
      measurementId: 'G-0LJBPP72QF',
    );
  }

  await Firebase.initializeApp(options: firebaseOptions);
  runApp(const ProviderScope(child: ColportagemApp()));
}

class ColportagemApp extends ConsumerWidget {
  final String? initialMode;
  final String? initialOobCode;

  const ColportagemApp({super.key, this.initialMode, this.initialOobCode});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);

    Widget homeWidget;

    // 4. Verifica usando as variáveis que recebemos do main()
    if (initialMode == 'resetPassword' && initialOobCode != null) {
      homeWidget = ResetPasswordPage(oobCode: initialOobCode!);
    } else {
      homeWidget = authState.when(
        data: (user) => user != null ? const HomePage() : const LoginPage(),
        loading: () =>
            const Scaffold(body: Center(child: CircularProgressIndicator())),
        error: (e, trace) => Scaffold(body: Center(child: Text('Erro: $e'))),
      );
    }

    return MaterialApp(
      title: 'Sistema de Colportagem',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF1E3A8A)),
        useMaterial3: true,
      ),
      home: homeWidget,
    );
  }
}
