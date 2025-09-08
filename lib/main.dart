import 'package:flutter/foundation.dart'; // kIsWeb için
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart'; // 🔥 Firebase core
import 'package:firebase_storage/firebase_storage.dart'; // ✅ Storage için eklendi
import 'theme.dart';
import 'pages/splash_page.dart'; // ✅ Splash var

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized(); // ✅ Firebase için gerekli

  if (kIsWeb) {
    // 🔥 Web için FirebaseOptions gerekli
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: "AIzaSyBzOmfvplwYQp5LBJOjHLM-cEtDFrav9I8",
        appId: "1:699423359862:web:71e0eaa589ca5dbe163057",
        messagingSenderId: "699423359862",
        projectId: "mioteays",
        authDomain: "mioteays.firebaseapp.com",
        storageBucket: "mioteays.firebasestorage.app",
      ),
    );
  } else {
    // 🔥 Android/iOS için varsayılan Firebase init
    await Firebase.initializeApp();
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Atık Yönetim Sistemi',
      debugShowCheckedModeBanner: false,
      theme: appTheme,
      home: const SplashPage(), // ✅ İlk açılış Splash
    );
  }
}
