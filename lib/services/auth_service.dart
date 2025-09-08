// lib/services/auth_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final String apiKey = "AIzaSyBzOmfvplwYQp5LBJOjHLM-cEtDFrav9I8"; // 🔑 Web API Key

  // 🔹 Register (Kayıt Ol)
  Future<Map<String, dynamic>> register(String email, String password) async {
    final url = Uri.parse(
      "https://identitytoolkit.googleapis.com/v1/accounts:signUp?key=$apiKey",
    );

    try {
      final response = await http.post(
        url,
        body: json.encode({
          "email": email,
          "password": password,
          "returnSecureToken": true,
        }),
        headers: {"Content-Type": "application/json"},
      );

      final data = json.decode(response.body);

      if (response.statusCode != 200) {
        // ❌ Firebase hata mesajını dön
        return {"error": data["error"] ?? {"message": "Bilinmeyen hata"}};
      }

      // ✅ Firestore’a kullanıcı kaydı ekle
      final uid = data["localId"]; // Firebase UID
      await FirebaseFirestore.instance.collection("users").doc(uid).set({
        "email": email,
        "isAdmin": false, // yeni kullanıcı default admin değil
      });

      return data; // ✅ Başarılı kayıt
    } catch (e) {
      return {"error": {"message": e.toString()}};
    }
  }

  // 🔹 Login (Giriş Yap)
  Future<Map<String, dynamic>> login(String email, String password) async {
    final url = Uri.parse(
      "https://identitytoolkit.googleapis.com/v1/accounts:signInWithPassword?key=$apiKey",
    );

    try {
      final response = await http.post(
        url,
        body: json.encode({
          "email": email,
          "password": password,
          "returnSecureToken": true,
        }),
        headers: {"Content-Type": "application/json"},
      );

      final data = json.decode(response.body);

      if (response.statusCode != 200) {
        return {"error": data["error"] ?? {"message": "Bilinmeyen hata"}};
      }

      // ✅ Login sonrası Firestore kontrol
      final uid = data["localId"];
      final userDoc =
      FirebaseFirestore.instance.collection("users").doc(uid);

      final snapshot = await userDoc.get();

      // Eğer kullanıcı Firestore’da yoksa, ekle
      if (!snapshot.exists) {
        await userDoc.set({
          "email": email,
          "isAdmin": false,
        });
      }

      return data; // ✅ Başarılı giriş
    } catch (e) {
      return {"error": {"message": e.toString()}};
    }
  }
}
