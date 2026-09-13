# AYS - Atık Yönetim Sistemi

[English Documentation](README.md)

Flutter ve Firebase teknolojileri kullanılarak geliştirilmiş, platformlar arası çalışabilen bir Atık Yönetim Sistemi uygulamasıdır. Atık takibini dijitalleştirmek, yönetici kontrollerini kolaylaştırmak ve raporlama süreçlerini otomatikleştirmek amacıyla tasarlanmıştır.

---

## Özellikler

- **Kimlik Doğrulama ve Yetkilendirme:** Firebase Auth ile güvenli kayıt/giriş ve rol tabanlı erişim kontrolü (Yönetici / Standart Kullanıcı).
- **Gerçek Zamanlı Veri Depolama:** Cloud Firestore ile atık verilerinin anlık senkronizasyonu ve yönetimi.
- **Grafiksel Raporlama:** Pasta (Pie), Çubuk (Bar) ve Çizgi (Line) grafikleriyle dinamik veri görselleştirme.
- **Yönetici Araçları:**
  - Sistem raporlarını PDF formatında indirme.
  - EmailJS entegrasyonu ile raporları otomatik e-posta olarak gönderme.
  - Atık verilerini silme ve yönetme yetkisi.
- **Çapraz Platform Desteği:** Android, iOS, Windows, Web, macOS ve Linux üzerinde sorunsuz çalışma.

---

## Kullanılan Teknolojiler

- **Ön Yüz & Çerçeve:** Flutter (Dart)
- **Arka Yüz & Veritabanı:** Firebase (Authentication, Cloud Firestore, Firebase Storage)
- **E-posta Servisi:** EmailJS
- **Görselleştirme:** Charts_flutter

---

## Kurulum

Projeyi kendi bilgisayarınızda çalıştırmak için aşağıdaki adımları izleyin:

1. **Depoyu klonlayın:**
   ```bash
   git clone [https://github.com/emrekilincc/AYS-Project.git](https://github.com/emrekilincc/AYS-Project.git)
   cd AYS-Project
Gerekli bağımlılıkları yükleyin:

Bash
flutter pub get
Firebase Yapılandırması:
Kendi google-services.json (Android) ve GoogleService-Info.plist (iOS) dosyalarınızı ilgili platform klasörlerine ekleyin.

Uygulamayı çalıştırın:

Bash
flutter run
Katkıda Bulunma
Katkılarınız bizim için değerlidir!

Depoyu forklayın (Fork)

Yeni bir dal açın (git checkout -b ozellik/YeniOzellik)

Değişikliklerinizi kaydedin (git commit -m 'Yeni özellik eklendi')

Dalınızı gönderin (git push origin ozellik/YeniOzellik)

Bir Pull Request oluşturun
