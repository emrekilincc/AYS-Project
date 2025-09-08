import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart'; // 🔹 Kullanıcı bilgisi için

class AtikEklePage extends StatefulWidget {
  const AtikEklePage({super.key});

  @override
  State<AtikEklePage> createState() => _AtikEklePageState();
}

class _AtikEklePageState extends State<AtikEklePage> {
  final _formKey = GlobalKey<FormState>();

  String? _tur;
  final _miktarController = TextEditingController();
  String? _durum;

  Future<void> _kaydet() async {
    if (_formKey.currentState!.validate()) {
      try {
        final user = FirebaseAuth.instance.currentUser;

        await FirebaseFirestore.instance.collection("atiklar").add({
          "tur": _tur,
          "miktar": int.tryParse(_miktarController.text) ?? 0,
          "durum": _durum ?? "Beklemede",
          "tarih": DateTime.now(),
          "kullanici": user?.email ?? "anonim", // 🔹 giriş yapan kişinin e-postası
        });

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("✅ Atık başarıyla eklendi")),
          );
          Navigator.pop(context); // listeye geri dön
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("❌ Hata: $e")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFECF0F1),
      appBar: AppBar(
        title: const Text("Yeni Atık Ekle"),
        backgroundColor: const Color(0xFF2E7D32),
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // 🔹 Atık Türü Seçimi
              DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  labelText: "Atık Türü",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
                items: ["Plastik", "Cam", "Metal", "Kağıt"]
                    .map((tur) => DropdownMenuItem(
                  value: tur.toLowerCase(),
                  child: Text(tur),
                ))
                    .toList(),
                onChanged: (val) => setState(() => _tur = val),
                validator: (val) =>
                val == null ? "Atık türü seçiniz" : null,
              ),
              const SizedBox(height: 16),

              // 🔹 Miktar Girişi
              TextFormField(
                controller: _miktarController,
                decoration: InputDecoration(
                  labelText: "Miktar (kg)",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
                keyboardType: TextInputType.number,
                validator: (val) =>
                val == null || val.isEmpty ? "Miktar giriniz" : null,
              ),
              const SizedBox(height: 16),

              // 🔹 Durum Seçimi
              DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  labelText: "Durum",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
                value: _durum ?? "Beklemede",
                items: ["Beklemede", "Toplandı", "Teslim Edildi"]
                    .map((d) =>
                    DropdownMenuItem(value: d, child: Text(d)))
                    .toList(),
                onChanged: (val) => setState(() => _durum = val),
              ),
              const SizedBox(height: 24),

              // 🔹 Kaydet Butonu
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _kaydet,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2E7D32),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  icon: const Icon(Icons.save, color: Colors.white),
                  label: const Text(
                    "Kaydet",
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
