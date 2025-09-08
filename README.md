# AYS-Project

AYS-Project, Flutter ve Firebase teknolojileri kullanılarak geliştirilmiş modern bir **Atık Yönetim Sistemi** uygulamasıdır.  
Bu proje, kullanıcıların atık verilerini kaydedebilmesi, listeleyebilmesi, raporlayabilmesi ve yöneticilerin (admin) özel yetkilerle bu verileri yönetebilmesi amacıyla hazırlanmıştır.  

---

## Projenin Amacı
Bu projenin amacı, atıkların dijital ortamda kolayca takip edilmesini ve yönetilmesini sağlamaktır.  
- Kullanıcılar atık verilerini ekleyebilir, görüntüleyebilir ve rapor alabilir.  
- Yöneticiler (admin) kullanıcıların eklediği verileri silebilir, rapor indirebilir veya e-posta yoluyla paylaşabilir.  

---

## Özellikler
- Kullanıcı kayıt ve giriş sistemi (Firebase Authentication)
- Rol tabanlı erişim (Kullanıcı / Admin)
- Atık verilerinin Firestore üzerinde saklanması
- Egzersiz listesi ve video entegrasyonu (örnek modül)
- Raporlama ekranı (grafiksel gösterimler: Pie Chart, Bar Chart, Line Chart)
- Admin için:
  - PDF rapor indirme
  - Raporu e-posta ile gönderme
- Platform bağımsız çalışma (Android, iOS, Windows, Web, macOS, Linux)

---

## Kullanılan Teknolojiler
- **Flutter** (Dart dili ile)
- **Firebase Authentication** – kullanıcı kayıt/giriş işlemleri
- **Cloud Firestore** – veritabanı yönetimi
- **Firebase Storage** – medya ve dosya depolama
- **EmailJS** – raporların e-posta ile gönderilmesi
- **Charts_flutter** ve benzeri grafik paketleri – raporlamada görselleştirme

---

## Kurulum
Projeyi kendi bilgisayarınızda çalıştırmak için aşağıdaki adımları takip edin:

1. Depoyu klonlayın:
   ```bash
   git clone https://github.com/emrekilincc/AYS-Project.git

2. Proje klasörüne gidin:

cd AYS-Project

3. Gerekli bağımlılıkları yükleyin:

flutter pub get

4. Firebase yapılandırması için kendi google-services.json (Android) ve GoogleService-Info.plist (iOS) dosyalarınızı ekleyin.

5. Uygulamayı çalıştırın:

flutter run
--------------------------------------------------------------------------------------------------------------------------------------
Katkıda Bulunma

Katkıda bulunmak isteyenler aşağıdaki adımları takip edebilir:

-Depoyu forklayın

-Yeni bir branch açın (git checkout -b yeni-özellik)

-Değişikliklerinizi commit edin (git commit -m 'Yeni özellik eklendi')

-Branch’inizi push edin (git push origin yeni-özellik)

-Pull Request oluşturun
