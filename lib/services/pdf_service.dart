import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';
import 'package:flutter/services.dart' show rootBundle;

class PdfService {
  static Future<Uint8List> generateReport() async {
    final pdf = pw.Document();

    // 🔹 Türkçe karakterler için Roboto variable font yükle
    final fontData = await rootBundle.load("assets/fonts/Roboto-VariableFont_wdth,wght.ttf");
    final ttf = pw.Font.ttf(fontData.buffer.asByteData());

    int plastik = 0, cam = 0, kagit = 0, metal = 0;
    List<List<String>> rows = [];
    Map<String, int> userTotals = {};

    try {
      final snapshot = await FirebaseFirestore.instance.collection("atiklar").get();

      for (var doc in snapshot.docs) {
        final data = doc.data();
        final tur = (data["tur"] ?? "").toString().toLowerCase();
        final miktarStr = data["miktar"]?.toString() ?? "0";
        final kullanici = data["kullanici"]?.toString() ?? "Bilinmiyor";

        String tarih = "-";
        if (data["tarih"] != null) {
          try {
            tarih = (data["tarih"] as Timestamp).toDate().toString().split(" ").first;
          } catch (_) {
            tarih = data["tarih"].toString();
          }
        }

        final miktar = int.tryParse(miktarStr.replaceAll(RegExp(r'[^0-9]'), "")) ?? 0;

        if (tur == "plastik") plastik += miktar > 0 ? miktar : 1;
        if (tur == "cam") cam += miktar > 0 ? miktar : 1;
        if (tur == "kağıt" || tur == "kagit") kagit += miktar > 0 ? miktar : 1;
        if (tur == "metal") metal += miktar > 0 ? miktar : 1;

        rows.add([kullanici, tur, "$miktar kg", tarih]);
        userTotals[kullanici] = (userTotals[kullanici] ?? 0) + (miktar > 0 ? miktar : 1);
      }
    } catch (_) {
      // ❌ Firestore erişilemezse demo veriler
      plastik = 40;
      cam = 30;
      kagit = 20;
      metal = 10;
      rows = [
        ["Demo Kullanıcı", "plastik", "25 kg", "2025-08-27"],
        ["Demo Kullanıcı", "cam", "15 kg", "2025-08-27"],
      ];
      userTotals = {"Demo Kullanıcı": 40};
    }

    final total = plastik + cam + kagit + metal;

    // 🔹 Kullanıcı bazlı özet tablo satırları
    final userSummaryRows = userTotals.entries.map((e) => [e.key, "${e.value} kg"]).toList();

    pdf.addPage(
      pw.MultiPage(
        build: (context) => [
          pw.Header(
            level: 0,
            child: pw.Text("Aylık Atık Raporu", style: pw.TextStyle(font: ttf, fontSize: 20)),
          ),
          pw.Paragraph(
            text: "Toplam Atık Miktarı: $total kg",
            style: pw.TextStyle(font: ttf),
          ),
          pw.Paragraph(
            text: "Plastik: $plastik kg | Cam: $cam kg | Kağıt: $kagit kg | Metal: $metal kg",
            style: pw.TextStyle(font: ttf),
          ),

          pw.SizedBox(height: 20),
          pw.Text("Kullanıcı Bazlı Toplam Atıklar:", style: pw.TextStyle(font: ttf, fontSize: 16)),
          pw.Table.fromTextArray(
            headers: ["Kullanıcı", "Toplam Atık"],
            data: userSummaryRows,
            headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.white, font: ttf),
            headerDecoration: const pw.BoxDecoration(color: PdfColors.teal),
            cellStyle: pw.TextStyle(fontSize: 10, font: ttf),
            border: pw.TableBorder.all(width: 0.5, color: PdfColors.grey),
          ),

          pw.SizedBox(height: 20),
          pw.Text("Tüm Atık Listesi:", style: pw.TextStyle(font: ttf, fontSize: 16)),
          pw.Table.fromTextArray(
            headers: ["Kullanıcı", "Tür", "Miktar", "Tarih"],
            data: rows,
            headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.white, font: ttf),
            headerDecoration: const pw.BoxDecoration(color: PdfColors.blueGrey),
            cellStyle: pw.TextStyle(fontSize: 10, font: ttf),
            border: pw.TableBorder.all(width: 0.5, color: PdfColors.grey),
          ),
        ],
      ),
    );

    return pdf.save();
  }

  static Future<void> previewAndPrint() async {
    final pdfBytes = await generateReport();
    await Printing.layoutPdf(onLayout: (PdfPageFormat format) async => pdfBytes);
  }
}
