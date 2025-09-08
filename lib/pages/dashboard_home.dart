// dashboard_home.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fl_chart/fl_chart.dart';

class DashboardHome extends StatelessWidget {
  const DashboardHome({super.key});

  // 🔹 Firestore'dan verileri topla
  Future<Map<String, dynamic>> _getDashboardData() async {
    final snapshot = await FirebaseFirestore.instance.collection("atiklar").get();

    double toplam = 0;
    double bugun = 0;
    int beklemede = 0;
    int tamamlanan = 0;

    // son 5 gün için (bar chart)
    final now = DateTime.now();
    final haftalik = List<double>.filled(5, 0);

    // son eklenen 5 kayıt (bildirimler için)
    final bildirimler = <String>[];

    for (var doc in snapshot.docs) {
      final data = doc.data() as Map<String, dynamic>;
      final tur = (data["tur"] ?? "-").toString();
      final miktar = (data["miktar"] ?? 0).toDouble();
      final durum = (data["durum"] ?? "Beklemede").toString();
      final kullanici = (data["kullanici"] ?? "Anonim").toString();

      DateTime tarih;
      if (data["tarih"] is Timestamp) {
        tarih = (data["tarih"] as Timestamp).toDate();
      } else {
        tarih = DateTime.tryParse(data["tarih"].toString()) ?? now;
      }

      toplam += miktar;

      // bugünkü atık
      if (tarih.year == now.year &&
          tarih.month == now.month &&
          tarih.day == now.day) {
        bugun += miktar;
      }

      if (durum == "Beklemede") beklemede++;
      if (durum == "Teslim Edildi") tamamlanan++;

      // haftalık (son 5 gün)
      final diff = now.difference(tarih).inDays;
      if (diff >= 0 && diff < 5) {
        haftalik[4 - diff] += miktar; // sondan başa doldur
      }

      // bildirim satırı hazırla
      bildirimler.add("$kullanici, $miktar kg $tur ekledi");
    }

    return {
      "toplam": toplam,
      "bugun": bugun,
      "beklemede": beklemede,
      "tamamlanan": tamamlanan,
      "haftalik": haftalik,
      "bildirimler": bildirimler.reversed.take(5).toList(), // son 5 kayıt
    };
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: const Color(0xFFECF0F1),
      appBar: AppBar(
        title: const Text("Atık Yönetim Sistemi"),
        backgroundColor: const Color(0xFF2E7D32),
        elevation: 0,
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _getDashboardData(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final data = snapshot.data!;
          final oran =
          (200 > 0) ? ((data["bugun"] as double) / 200) * 100 : 0; // günlük hedef %200 kg

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                //---------------- HEADER ----------------//
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    CircleAvatar(
                      radius: 24,
                      backgroundColor: Colors.green.shade100,
                      child: const Icon(Icons.account_circle,
                          color: Color(0xFF2E7D32), size: 40),
                    )
                  ],
                ),
                const SizedBox(height: 20),

                //---------------- İSTATİSTİK KARTLARI ----------------//
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  children: [
                    _statCard("Toplam Atık", "${data["toplam"]} kg",
                        Icons.recycling, const Color(0xFF2E7D32)),
                    _statCard("Bugün", "${data["bugun"]} kg", Icons.today,
                        const Color(0xFFFFB300)),
                    _statCard("Beklemede", "${data["beklemede"]}", Icons.timer,
                        const Color(0xFF42A5F5)),
                    _statCard("Tamamlanan", "${data["tamamlanan"]}",
                        Icons.check_circle, const Color(0xFF66BB6A)),
                  ],
                ),
                const SizedBox(height: 20),

                //---------------- MINI BAR CHART ----------------//
                _buildCard(
                  title: "Bu Hafta Toplanan Atıklar",
                  child: SizedBox(
                    height: 150,
                    child: BarChart(
                      BarChartData(
                        gridData: FlGridData(show: false),
                        titlesData: FlTitlesData(
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (value, meta) {
                                const days = ["Pzt", "Salı", "Çar", "Per", "Cum"];
                                if (value.toInt() < days.length) {
                                  return Text(days[value.toInt()],
                                      style: const TextStyle(
                                          fontSize: 12,
                                          color: Color(0xFF263238)));
                                }
                                return const Text("");
                              },
                            ),
                          ),
                          leftTitles:
                          AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        ),
                        borderData: FlBorderData(show: false),
                        barGroups: List.generate(
                          (data["haftalik"] as List).length,
                              (i) => BarChartGroupData(x: i, barRods: [
                            BarChartRodData(
                              toY: (data["haftalik"][i] as double),
                              gradient: const LinearGradient(
                                colors: [Color(0xFF66BB6A), Color(0xFF42A5F5)],
                                begin: Alignment.bottomCenter,
                                end: Alignment.topCenter,
                              ),
                            )
                          ]),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                //---------------- GÜNLÜK HEDEF ----------------//
                _buildCard(
                  title: "Günlük Hedef",
                  child: Center(
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        SizedBox(
                          height: 120,
                          width: 120,
                          child: CircularProgressIndicator(
                            value: oran / 100,
                            strokeWidth: 10,
                            backgroundColor: Colors.grey[300],
                            color: const Color(0xFF2E7D32),
                          ),
                        ),
                        Text(
                          "${oran.toStringAsFixed(0)}%\n(${data["bugun"]} / 200 kg)",
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF263238)),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                //---------------- SON BİLDİRİMLER ----------------//
                _buildCard(
                  title: "Son Bildirimler",
                  child: Column(
                    children: (data["bildirimler"] as List<String>)
                        .map(
                          (b) => ListTile(
                        leading: const Icon(Icons.notifications,
                            color: Color(0xFFFFB300)),
                        title: Text(b,
                            style: const TextStyle(
                                fontSize: 14, color: Color(0xFF263238))),
                      ),
                    )
                        .toList(),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // 🔹 İstatistik Kartı
  Widget _statCard(String title, String value, IconData icon, Color color) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 4,
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: color.withOpacity(0.15),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(height: 10),
            Text(value,
                style: TextStyle(
                    fontSize: 20, fontWeight: FontWeight.bold, color: color)),
            const SizedBox(height: 5),
            Text(title,
                style:
                const TextStyle(fontSize: 14, color: Color(0xFF263238))),
          ],
        ),
      ),
    );
  }

  // 🔹 Ortak Kart Şablonu
  Widget _buildCard({required String title, required Widget child}) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 4,
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Text(title,
                  style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF263238))),
            ),
            const SizedBox(height: 10),
            child,
          ],
        ),
      ),
    );
  }
}
