# Flutter JSON Plus

JSON verilerini Dart sınıflarına dönüştüren güçlü ve kullanıcı dostu bir Flutter uygulaması.

## 🚀 Özellikler

- **JSON'dan Dart Class Dönüştürme**: JSON verilerinizi otomatik olarak Dart sınıflarına dönüştürün
- **Nested Class Desteği**: İç içe geçmiş JSON objelerini ayrı Dart sınıflarına otomatik dönüştürme
- **Syntax Highlighting**: Üretilen kodları renklendirilmiş görüntüleme
- **7 Konfigürasyon Seçeneği**:
  - `final` keyword kullanımı (varsayılan: aktif)
  - Nullable/Optional tipler (varsayılan: aktif)
  - `fromJson` ve `toJson` metodları (varsayılan: aktif)
  - `copyWith` metodu
  - `required` parametreler
  - Sadece tip tanımlamaları (method'suz)
  - Data class (== ve hashCode override)
- **Tek Tıkla Kopyalama**: Üretilen kodu panoya kopyalama
- **Akıllı Tip Algılama**: JSON değerlerinden otomatik tip çıkarımı
- **Hata Yönetimi**: Geçersiz JSON için kullanıcı dostu hata mesajları

## 📸 Ekran Görüntüsü

Uygulama iki panel düzeninde çalışır:
- **Sol Panel**: JSON girişi, sınıf adı ve konfigürasyon seçenekleri
- **Sağ Panel**: Syntax highlighting ile üretilen Dart kodu

## 🛠️ Kurulum

### Gereksinimler

- Flutter SDK (3.10.0 veya üzeri)
- Dart SDK (3.10.0 veya üzeri)

### Bağımlılıklar

```yaml
dependencies:
  flutter: sdk: flutter
  flutter_highlight: ^0.7.0
```

### Projeyi Çalıştırma

1. Depoyu klonlayın:
```bash
git clone <repo-url>
cd flutter_json_plus
```

2. Bağımlılıkları yükleyin:
```bash
flutter pub get
```

3. Uygulamayı çalıştırın:
```bash
# Web için
flutter run -d chrome

# macOS için
flutter run -d macos

# Diğer platformlar için
flutter run
```

## 📖 Kullanım

1. **Class İsmi Girin**: Oluşturulacak ana sınıf için bir isim belirleyin (örn: `User`)

2. **JSON Verisi Yapıştırın**: JSON verinizi büyük metin alanına yapıştırın

3. **Seçenekleri Ayarlayın**: İhtiyacınıza göre switch'leri açın/kapatın:
   - **Use final**: Alanları `final` yapar
   - **Nullable**: Alanları nullable yapar
   - **fromJson / toJson**: Serileştirme metodları ekler
   - **copyWith**: Immutable güncellemeler için copyWith metodu ekler
   - **Required parameters**: Constructor parametrelerini `required` yapar
   - **Types only**: Sadece alan tanımları oluşturur (metodsuz)
   - **Data class**: Değer eşitliği için == ve hashCode override eder

4. **Generate**: Butona tıklayarak kodu oluşturun

5. **Kopyala**: Sağ üst köşedeki kopyala butonuna tıklayarak kodu panoya kopyalayın

### Örnek

**Giriş JSON:**
```json
{
  "name": "John Doe",
  "age": 30,
  "email": "john@example.com",
  "address": {
    "street": "123 Main St",
    "city": "New York"
  }
}
```

**Çıktı (tüm seçenekler varsayılan):**
```dart
class User {
  final String? name;
  final int? age;
  final String? email;
  final Address? address;

  User({
    this.name,
    this.age,
    this.email,
    this.address,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      name: json['name'],
      age: json['age'],
      email: json['email'],
      address: json['address'] != null ? Address.fromJson(json['address']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'age': age,
      'email': email,
      'address': address?.toJson(),
    };
  }
}

class Address {
  final String? street;
  final String? city;

  Address({
    this.street,
    this.city,
  });

  factory Address.fromJson(Map<String, dynamic> json) {
    return Address(
      street: json['street'],
      city: json['city'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'street': street,
      'city': city,
    };
  }
}
```

## 🏗️ Proje Yapısı

```
lib/
├── main.dart                           # Uygulama giriş noktası
├── models/
│   ├── generation_options.dart        # Kod üretim seçenekleri modeli
│   └── field_info.dart                # Alan bilgisi modeli
├── services/
│   ├── type_detector.dart             # Tip algılama servisi
│   ├── json_parser.dart               # JSON parsing servisi
│   └── dart_generator.dart            # Dart kod üretici servisi
├── widgets/
│   ├── json_input_panel.dart          # Giriş paneli widget'ı
│   ├── options_panel.dart             # Seçenekler paneli widget'ı
│   └── output_panel.dart              # Çıktı paneli widget'ı
└── screens/
    └── converter_screen.dart          # Ana dönüştürücü ekranı
```

## 🔧 Teknik Detaylar

### Tip Algılama
- `bool`, `int`, `double`, `String` gibi primitive tipler otomatik algılanır
- `List<T>` tipleri dizideki ilk elemana göre belirlenir
- Nested objeler için otomatik sınıf isimleri üretilir (field adından PascalCase'e dönüştürme)

### Kod Üretimi
- 2 boşluk girintileme kullanılır
- Ana sınıf en üstte, nested sınıflar alfabetik sırada altta gösterilir
- Null-safety uyumlu kod üretilir
- `StringBuffer` ile verimli string birleştirme

### Edge Case'ler
- Boş diziler → `List<dynamic>` olarak işlenir
- Mixed type diziler → `List<dynamic>` olarak işlenir
- Null değerler → nullable olarak işaretlenir
- Geçersiz JSON → Kullanıcıya hata mesajı gösterilir

## 🤝 Katkıda Bulunma

Katkılarınızı bekliyoruz! Lütfen bir issue açın veya pull request gönderin.

## 📝 Lisans

Bu proje MIT lisansı altında lisanslanmıştır.

## 👨‍💻 Geliştirici

Berkay Çaylı

---

**Not**: Bu uygulama Flutter web, macOS, Windows, Linux platformlarında çalışabilir.
