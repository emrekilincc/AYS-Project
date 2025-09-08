// rapor_page.dart
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/pdf_service.dart';
import '../services/mail_service.dart';

class RaporPage extends StatelessWidget {
  const RaporPage({super.key});

  Future<Map<String, dynamic>> _getData() async {
    try {
      final snapshot =
      await FirebaseFirestore.instance.collection("atiklar").get();

      if (snapshot.docs.isEmpty) return _demoData();

      int plastik = 0, cam = 0, kagit = 0, metal = 0;

      // 🔹 Pazartesi–Cuma için dizi
      final haftalik = [0, 0, 0, 0, 0];

      // 🔹 Ocak–Aralık için 12 aylık dizi
      final aylik = List.filled(12, 0);

      for (var doc in snapshot.docs) {
        final data = doc.data();
        final tur = (data["tur"] ?? "").toString().toLowerCase();
        final tarihRaw = data["tarih"];

        DateTime tarih;
        if (tarihRaw is Timestamp) {
          tarih = tarihRaw.toDate();
        } else if (tarihRaw is DateTime) {
          tarih = tarihRaw;
        } else {
          continue;
        }

        // 🔹 Tür sayıları
        switch (tur) {
          case "plastik":
            plastik++;
            break;
          case "cam":
            cam++;
            break;
          case "kağıt":
          case "kagit":
            kagit++;
            break;
          case "metal":
            metal++;
            break;
        }

        // 🔹 Haftalık dağılım (Pzt=1, Cuma=5)
        int gun = tarih.weekday;
        if (gun >= 1 && gun <= 5) {
          haftalik[gun - 1]++;
        }

        // 🔹 Aylık dağılım
        int ay = tarih.month; // 1–12
        aylik[ay - 1]++;
      }

      return {
        "plastik": plastik,
        "cam": cam,
        "kağıt": kagit,
        "metal": metal,
        "haftalik": haftalik,
        "aylik": aylik,
        "hedef": 200,
        "toplanan": plastik + cam + kagit + metal,
      };
    } catch (_) {
      return _demoData();
    }
  }

  Map<String, dynamic> _demoData() {
    return {
      "plastik": 40,
      "cam": 30,
      "kağıt": 20,
      "metal": 10,
      "haftalik": [50, 70, 30, 90, 60],
      "aylik": [20, 40, 60, 30, 50, 80, 100, 70, 60, 40, 20, 10],
      "hedef": 200,
      "toplanan": 150,
    };
  }

  Future<bool> _checkIfAdmin(String uid) async {
    try {
      final doc =
      await FirebaseFirestore.instance.collection("users").doc(uid).get();
      if (!doc.exists) return false;
      final data = doc.data() as Map<String, dynamic>;
      return data["isAdmin"] == true;
    } catch (e) {
      return false;
    }
  }

  Future<void> _sendReport(BuildContext context, String email) async {
    try {
      await MailService.sendMonthlyReport(email);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("✅ Rapor mail olarak gönderildi")),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("❌ Mail gönderilemedi: $e")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Raporlar"),
        backgroundColor: const Color(0xFF27AE60),
        elevation: 0,
      ),
      backgroundColor: const Color(0xFFF4F6F7),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _getData(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final data = snapshot.data!;

          final hedef = (data["hedef"] as num?)?.toDouble() ?? 200;
          final toplanan = (data["toplanan"] as num?)?.toDouble() ?? 0;
          final oran = (hedef > 0) ? (toplanan / hedef) * 100 : 0;

          return FutureBuilder<bool>(
            future: _checkIfAdmin(user!.uid),
            builder: (context, adminSnapshot) {
              if (adminSnapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              final isAdmin = adminSnapshot.data ?? false;

              return SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    // 📊 Pie Chart
                    _buildCard(
                      title: " Atık Türlerine Göre Dağılım",
                      child: SizedBox(
                        height: 200,
                        child: PieChart(
                          PieChartData(
                            sections: [
                              PieChartSectionData(
                                  value: (data["plastik"] ?? 0).toDouble(),
                                  color: Colors.green.shade600,
                                  title: "Plastik"),
                              PieChartSectionData(
                                  value: (data["cam"] ?? 0).toDouble(),
                                  color: Colors.blue.shade400,
                                  title: "Cam"),
                              PieChartSectionData(
                                  value: (data["kağıt"] ?? 0).toDouble(),
                                  color: Colors.orange.shade400,
                                  title: "Kağıt"),
                              PieChartSectionData(
                                  value: (data["metal"] ?? 0).toDouble(),
                                  color: Colors.red.shade400,
                                  title: "Metal"),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // 📊 Bar Chart (HAFTALIK)
                    _buildCard(
                      title: " Haftalık Toplanan Atık",
                      child: SizedBox(
                        height: 200,
                        child: BarChart(
                          BarChartData(
                            gridData: FlGridData(show: false),
                            titlesData: FlTitlesData(
                              bottomTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  getTitlesWidget: (value, meta) {
                                    const days = [
                                      "Pzt",
                                      "Salı",
                                      "Çar",
                                      "Per",
                                      "Cum"
                                    ];
                                    if (value.toInt() < days.length) {
                                      return Text(days[value.toInt()],
                                          style: const TextStyle(fontSize: 12));
                                    }
                                    return const Text("");
                                  },
                                ),
                              ),
                              leftTitles: AxisTitles(
                                sideTitles: SideTitles(showTitles: false),
                              ),
                            ),
                            borderData: FlBorderData(show: false),
                            barGroups: List.generate(
                              (data["haftalik"] as List).length,
                                  (i) => BarChartGroupData(x: i, barRods: [
                                BarChartRodData(
                                    toY: (data["haftalik"][i] as num).toDouble(),
                                    gradient: _barGradient)
                              ]),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // 📊 Line Chart (AYLIK GERÇEK VERİDEN)
                    _buildCard(
                      title: " Aylık Toplama Trendi",
                      child: SizedBox(
                        height: 200,
                        child: LineChart(
                          LineChartData(
                            gridData: FlGridData(show: false),
                            titlesData: FlTitlesData(
                              bottomTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  getTitlesWidget: (value, meta) {
                                    const months = [
                                      "Oca",
                                      "Şub",
                                      "Mar",
                                      "Nis",
                                      "May",
                                      "Haz",
                                      "Tem",
                                      "Ağu",
                                      "Eyl",
                                      "Eki",
                                      "Kas",
                                      "Ara"
                                    ];
                                    if (value.toInt() >= 0 &&
                                        value.toInt() < months.length) {
                                      return Text(months[value.toInt()],
                                          style: const TextStyle(fontSize: 10));
                                    }
                                    return const Text("");
                                  },
                                ),
                              ),
                              leftTitles: AxisTitles(
                                sideTitles: SideTitles(showTitles: false),
                              ),
                            ),
                            borderData: FlBorderData(show: false),
                            lineBarsData: [
                              LineChartBarData(
                                isCurved: true,
                                gradient: _lineGradient,
                                barWidth: 3,
                                dotData: FlDotData(show: true),
                                belowBarData: BarAreaData(
                                  show: true,
                                  gradient: LinearGradient(
                                    colors: [
                                      Colors.green.withOpacity(0.3),
                                      Colors.transparent
                                    ],
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                  ),
                                ),
                                spots: (data["aylik"] as List)
                                    .asMap()
                                    .entries
                                    .map((e) => FlSpot(
                                    e.key.toDouble(),
                                    (e.value as num).toDouble()))
                                    .toList(),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // 📊 Circular Progress
                    _buildCard(
                      title: " Günlük Hedef Durumu",
                      child: Center(
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            SizedBox(
                              height: 150,
                              width: 150,
                              child: CircularProgressIndicator(
                                value: oran / 100,
                                strokeWidth: 12,
                                backgroundColor: Colors.grey[300],
                                color: Colors.green,
                              ),
                            ),
                            Text(
                              "${oran.toStringAsFixed(0)}%\n($toplanan / $hedef kg)",
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // ✅ Admin butonları
                    if (isAdmin) ...[
                      ElevatedButton.icon(
                        onPressed: () => PdfService.previewAndPrint(),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.purple,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 24, vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        icon: const Icon(Icons.picture_as_pdf,
                            color: Colors.white),
                        label: const Text("PDF Rapor İndir",
                            style: TextStyle(color: Colors.white)),
                      ),
                      const SizedBox(height: 10),
                      ElevatedButton.icon(
                        onPressed: () => _sendReport(context, user.email ?? ""),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 24, vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        icon: const Icon(Icons.email, color: Colors.white),
                        label: const Text("Raporu Mail Olarak Gönder",
                            style: TextStyle(color: Colors.white)),
                      ),
                    ],
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildCard({required String title, required Widget child}) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 4,
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Text(title,
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 10),
            child,
          ],
        ),
      ),
    );
  }

  static final LinearGradient _barGradient = LinearGradient(
    colors: [Colors.green.shade400, Colors.green.shade700],
    begin: Alignment.bottomCenter,
    end: Alignment.topCenter,
  );

  static final LinearGradient _lineGradient = LinearGradient(
    colors: [Colors.green.shade400, Colors.green.shade700],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );
}
