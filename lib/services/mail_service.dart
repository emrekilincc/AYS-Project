// mail_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';

class MailService {
  static const String _serviceId = "service_s6rg7z8";
  static const String _templateId = "template_96dwce4";
  static const String _publicKey = "iXO15IT5RBxalt8Kk";

  static Future<void> sendMonthlyReport(String adminEmail) async {
    try {
      final snapshot =
      await FirebaseFirestore.instance.collection("atiklar").get();

      int plastik = 0, cam = 0, kagit = 0, metal = 0, total = 0;
      StringBuffer rows = StringBuffer(); // tablo satırları için buffer

      for (var doc in snapshot.docs) {
        final data = doc.data();
        final tur = (data["tur"] ?? "").toString();
        final miktarStr = data["miktar"]?.toString() ?? "0";
        final kullanici = data["kullanici"]?.toString() ?? "Bilinmiyor";
        final tarih =
            data["tarih"]?.toDate().toString().split(" ").first ?? "-";

        final miktar =
            int.tryParse(miktarStr.replaceAll(RegExp(r'[^0-9]'), "")) ?? 0;

        if (tur.toLowerCase() == "plastik") plastik += miktar;
        if (tur.toLowerCase() == "cam") cam += miktar;
        if (tur.toLowerCase() == "kağıt" || tur.toLowerCase() == "kagit") {
          kagit += miktar;
        }
        if (tur.toLowerCase() == "metal") metal += miktar;

        total += miktar;

        // 🔹 HTML satırları düzgün basılsın
        rows.writeln(
            "<tr><td>$kullanici</td><td>$tur</td><td>${miktar} kg</td><td>$tarih</td></tr>");
      }

      final url = Uri.parse("https://api.emailjs.com/api/v1.0/email/send");

      final body = {
        "service_id": _serviceId,
        "template_id": _templateId,
        "user_id": _publicKey,
        "template_params": {
          "to_email": adminEmail,
          "from_name": "Atık Yönetim Sistemi",
          "total": "$total kg",
          "plastik": "$plastik kg",
          "cam": "$cam kg",
          "kagit": "$kagit kg",
          "metal": "$metal kg",
          "rows": rows.toString(), // 🔹 tüm satırları HTML string olarak gönder
        }
      };

      final response = await http.post(
        url,
        headers: {
          "origin": "http://localhost",
          "Content-Type": "application/json",
        },
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        print("✅ Mail gönderildi, tablolu rapor EmailJS şablonunda render edilecek.");
      } else {
        print("❌ Mail gönderim hatası: ${response.statusCode} - ${response.body}");
      }
    } catch (e) {
      print("❌ Mail gönderim istisnası: $e");
    }
  }
}
