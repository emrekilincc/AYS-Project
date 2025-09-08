import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../pages/auth_page.dart';

class ProfilPage extends StatelessWidget {
  const ProfilPage({super.key});

  // 🔹 Çıkış
  Future<void> _signOut(BuildContext context) async {
    try {
      await FirebaseAuth.instance.signOut();
      if (context.mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const AuthPage()),
              (route) => false,
        );
      }
    } catch (e) {
      debugPrint("Çıkış hatası: $e");
    }
  }

  // 🔹 Kullanıcıya özel istatistikler
  Future<Map<String, dynamic>> _getUserStats(String email) async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection("atiklar")
          .where("kullanici", isEqualTo: email)
          .orderBy("tarih", descending: true)
          .get();

      if (snapshot.docs.isEmpty) {
        return {"toplam": 0, "enCokTur": "-", "sonAtik": "-", "sonTarih": "-"};
      }

      final docs = snapshot.docs;
      final toplam = docs.length;

      // En çok eklenen tür
      final turCount = <String, int>{};
      for (var d in docs) {
        final tur = (d["tur"] ?? "").toString();
        turCount[tur] = (turCount[tur] ?? 0) + 1;
      }
      final enCokTur = turCount.entries.isNotEmpty
          ? turCount.entries.reduce((a, b) => a.value > b.value ? a : b).key
          : "-";

      // Son eklenen atık
      final son = docs.first.data();
      final sonAtik = son["tur"] ?? "-";
      final sonTarih = son["tarih"] != null
          ? (son["tarih"] as Timestamp).toDate().toString().split(" ").first
          : "-";

      return {
        "toplam": toplam,
        "enCokTur": enCokTur,
        "sonAtik": sonAtik,
        "sonTarih": sonTarih
      };
    } catch (e) {
      return {"toplam": 0, "enCokTur": "-", "sonAtik": "-", "sonTarih": "-"};
    }
  }

  @override
  Widget build(BuildContext context) {
    final firebaseUser = FirebaseAuth.instance.currentUser;

    final Map<String, dynamic> currentUser = {
      "displayName": firebaseUser?.displayName ?? "Bilinmiyor",
      "email": firebaseUser?.email ?? "-",
      "uid": firebaseUser?.uid ?? ""
    };

    return Scaffold(
      backgroundColor: const Color(0xFFECF0F1),
      appBar: AppBar(
        title: const Text("Profilim"),
        backgroundColor: const Color(0xFF2E7D32),
        elevation: 0,
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _getUserStats(currentUser["email"]),
        builder: (context, snapshot) {
          final stats = snapshot.data ??
              {
                "toplam": "-",
                "enCokTur": "-",
                "sonAtik": "-",
                "sonTarih": "-"
              };

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundColor: const Color(0xFF2E7D32).withOpacity(0.15),
                  child: const Icon(Icons.person, size: 60, color: Color(0xFF2E7D32)),
                ),
                const SizedBox(height: 20),

                Card(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                  elevation: 3,
                  color: Colors.white,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        _infoRow("Ad Soyad", currentUser["displayName"]),
                        const Divider(),
                        _infoRow("E-posta", currentUser["email"]),
                        const Divider(),
                        _infoRow("Şirket", "Miote"),
                        const Divider(),
                        _infoRow("Toplam Atık", stats["toplam"].toString()),
                        const Divider(),
                        _infoRow("En Çok Eklenen Tür", stats["enCokTur"]),
                        const Divider(),
                        _infoRow("Son Eklenen Atık",
                            "${stats["sonAtik"]} (${stats["sonTarih"]})"),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 30),

                // Çıkış Yap
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => _signOut(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    icon: const Icon(Icons.logout, color: Colors.white),
                    label: const Text("Çıkış Yap",
                        style: TextStyle(color: Colors.white)),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _infoRow extends StatelessWidget {
  final String label;
  final String value;

  const _infoRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 14, color: Colors.black54)),
        Text(value,
            style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF263238))),
      ],
    );
  }
}
