// atik_list_page.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'atik_ekle_page.dart';

class AtikListPage extends StatefulWidget {
  const AtikListPage({super.key});

  @override
  State<AtikListPage> createState() => _AtikListPageState();
}

class _AtikListPageState extends State<AtikListPage> {
  String searchText = "";
  String? selectedDurum;
  String? selectedUser;
  bool _isAdmin = false; // 🔹 Firestore'dan gelen admin bilgisi

  @override
  void initState() {
    super.initState();
    _checkIfAdmin(); // girişte admin kontrolü
  }

  Future<void> _checkIfAdmin() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      final doc = await FirebaseFirestore.instance.collection("users").doc(user.uid).get();
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        setState(() {
          _isAdmin = data["isAdmin"] == true;
        });
      }
    } catch (_) {
      setState(() => _isAdmin = false);
    }
  }

  Future<void> _deleteAtik(DocumentSnapshot doc) async {
    try {
      await FirebaseFirestore.instance.collection("atiklar").doc(doc.id).delete();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text("🗑️ Atık silindi"),
            action: SnackBarAction(
              label: "GERİ AL",
              onPressed: () async {
                await FirebaseFirestore.instance.collection("atiklar").doc(doc.id).set(doc.data() as Map<String, dynamic>);
              },
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
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
        title: const Text("Atık Listesi"),
        backgroundColor: const Color(0xFF2E7D32),
        elevation: 0,
      ),
      body: Column(
        children: [
          // 🔍 Arama + Durum Filtre Barı
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: "Atık ara...",
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    onChanged: (val) => setState(() => searchText = val),
                  ),
                ),
                const SizedBox(width: 10),
                DropdownButton<String>(
                  value: selectedDurum ?? "Tümü",
                  items: ["Tümü", "Beklemede", "Toplandı", "Teslim Edildi"]
                      .map((d) => DropdownMenuItem(value: d, child: Text(d)))
                      .toList(),
                  onChanged: (val) => setState(() => selectedDurum = val),
                ),
              ],
            ),
          ),

          // 🔹 Admin için kullanıcı filtre dropdown
          if (_isAdmin)
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection("atiklar").snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const SizedBox();
                final users = snapshot.data!.docs
                    .map((doc) => (doc["kullanici"] ?? "Anonim").toString())
                    .toSet()
                    .toList();

                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0),
                  child: DropdownButton<String>(
                    value: selectedUser ?? "Tümü",
                    isExpanded: true,
                    items: ["Tümü", ...users]
                        .map((u) => DropdownMenuItem(value: u, child: Text(u)))
                        .toList(),
                    onChanged: (val) => setState(() => selectedUser = val),
                  ),
                );
              },
            ),

          // 🔹 Firestore Liste
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection("atiklar")
                  .orderBy("tarih", descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return const Center(child: Text("❌ Hata oluştu"));
                }
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final docs = snapshot.data!.docs;

                // 🔹 Filtreleme
                final filtered = docs.where((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  final tur = (data["tur"] ?? "").toString().toLowerCase();
                  final durum = (data["durum"] ?? "").toString();
                  final kullanici = (data["kullanici"] ?? "Anonim").toString();

                  final matchesSearch = tur.contains(searchText.toLowerCase());
                  final matchesDurum = selectedDurum == null || selectedDurum == "Tümü" || durum == selectedDurum;
                  final matchesUser = !_isAdmin || selectedUser == null || selectedUser == "Tümü" || kullanici == selectedUser;

                  return matchesSearch && matchesDurum && matchesUser;
                }).toList();

                if (filtered.isEmpty) {
                  return const Center(child: Text("📭 Uygun atık bulunamadı"));
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16.0),
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    final doc = filtered[index];
                    final data = doc.data() as Map<String, dynamic>;

                    final tur = data["tur"] ?? "Bilinmiyor";
                    final miktar = data["miktar"]?.toString() ?? "-";
                    final durum = data["durum"] ?? "Beklemede";
                    final kullanici = data["kullanici"] ?? "Anonim";
                    final tarih = data["tarih"] is Timestamp
                        ? (data["tarih"] as Timestamp).toDate()
                        : DateTime.now();

                    return Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 3,
                      color: Colors.white,
                      margin: const EdgeInsets.only(bottom: 16),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 28,
                              backgroundColor: const Color(0xFF2E7D32).withOpacity(0.15),
                              child: const Icon(Icons.recycling, size: 32, color: Color(0xFF2E7D32)),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(tur.toString(),
                                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF263238))),
                                  const SizedBox(height: 4),
                                  Text("Durum: $durum",
                                      style: TextStyle(fontSize: 14, color: _getDurumColor(durum), fontWeight: FontWeight.w600)),
                                  const SizedBox(height: 4),
                                  Text("Kullanıcı: $kullanici", style: const TextStyle(fontSize: 13, color: Colors.black87)),
                                  Text("Tarih: $tarih", style: const TextStyle(fontSize: 12, color: Colors.black54)),
                                ],
                              ),
                            ),
                            Text(miktar,
                                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF263238))),
                            if (_isAdmin)
                              IconButton(
                                icon: const Icon(Icons.delete, color: Colors.red),
                                onPressed: () {
                                  showDialog(
                                    context: context,
                                    builder: (_) => AlertDialog(
                                      title: const Text("Silme Onayı"),
                                      content: const Text("Bu atığı silmek istediğinize emin misiniz?"),
                                      actions: [
                                        TextButton(onPressed: () => Navigator.pop(context), child: const Text("İptal")),
                                        TextButton(
                                          onPressed: () {
                                            Navigator.pop(context);
                                            _deleteAtik(doc);
                                          },
                                          child: const Text("Sil", style: TextStyle(color: Colors.red)),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),

      // ➕ Yeni Atık Ekle
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => const AtikEklePage()));
        },
        backgroundColor: const Color(0xFF2E7D32),
        icon: const Icon(Icons.add),
        label: const Text("Yeni Atık Ekle"),
      ),
    );
  }

  static Color _getDurumColor(String durum) {
    switch (durum) {
      case "Beklemede":
        return const Color(0xFFFFB300);
      case "Toplandı":
        return const Color(0xFF42A5F5);
      case "Teslim Edildi":
        return const Color(0xFF66BB6A);
      default:
        return Colors.grey;
    }
  }
}
