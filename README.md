# 🏛️ BlockCore Studio · The Living Protocol
### *Sovereign Web3 Neobank, Proof-of-Reserves (PoR) & Cryptographic Merkle Auditor*

[![Flutter](https://img.shields.io/badge/Flutter-3.24+-02569B?style=for-the-badge&logo=flutter&logoColor=white)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.4+-0175C2?style=for-the-badge&logo=dart&logoColor=white)](https://dart.dev)
[![Web3](https://img.shields.io/badge/Architecture-Web3_Neobank-0D47E8?style=for-the-badge&logo=ethereum&logoColor=white)](https://ethereum.org)
[![Security](https://img.shields.io/badge/Audit-Merkle_Sum_Tree-00D09C?style=for-the-badge&logo=shield&logoColor=white)](https://en.wikipedia.org/wiki/Merkle_tree)
[![Design](https://img.shields.io/badge/UI/UX-Revolut_iOS_Design_System-1A1F2C?style=for-the-badge&logo=apple&logoColor=white)](https://mobbin.com)

---

## 📌 Proje Vizyonu ve Genel Bakış (Executive Summary)

**BlockCore Studio**, geleneksel merkezi bankacılığın (Neobank) kullanıcı dostu, pürüzsüz arayüz standartlarını (Revolut iOS Design System); blokzincirinin şeffaflık, matematiksel kesinlik ve kendi varlığının egemeni olma (self-custody) ilkeleriyle birleştiren yeni nesil bir **Sovereign Web3 Neobank & Rezerv Denetim Platformudur**.

Klasik finans uygulamalarının aksine, BlockCore Studio'da kullanıcı bakiyeleri gizli veritabanlarında değil; **SHA-256 Merkle Sum Tree (Kriptografik Rezerv Kanıtı)** ile zincir üzerindeki akıllı sözleşme kasasında %100 matematiksel olarak doğrulanabilir şekilde tutulur.

---

## 💎 Temel Mimari Sütunlar ve Özellikler

### 1. 🛡️ Proof of Reserves (PoR) & İnteraktif Merkle Ağacı Denetçisi
* **%102.0 Aşırı Teminatlandırma (Over-Collateralized):** Akıllı sözleşme kasasındaki rezervler ($1,518,984) ile müşteri yükümlülükleri ($1,489,200) canlı olarak karşılaştırılır.
* **Görselleştirilmiş Merkle Ağacı:** 
  * `Merkle Root (0x8F2C...9E41)` kök düğümünden başlayarak ara dallar (`Branch L1`, `Branch L2`) ve kullanıcı yaprakları (`Leaf Nodes`) hiyerarşik olarak modellenmiştir.
  * Kullanıcının kendi hesabı (`@meryemgcl`), ağaç üzerinde **Neon Cyan** renginde görselleştirilir.
* **3 Aşamalı Kriptografik Doğrulama Motoru:**
  1. *Kullanıcı Yaprağı:* $\text{Hash} = \text{SHA-256}(\text{revtag} + \text{balance} + \text{nonce})$
  2. *Sibling Hash Kombinasyonu:* Komşu düğümle ara kök hesabı.
  3. *Kök Doğrulama:* Üretilen kökün bloktaki State Root ile eşleştiğinin ispatı (`VERIFIED ✓`).
* **Audit Receipt:** Denetim kanıtını JSON formatında dışa aktarma ve panoya kopyalama desteği.

---

### 2. 🪄 Web3 Onboarding & Egemen Kimlik Sihirbazı (`OnboardingWizardPage`)
Revolut'un iOS onboarding tasarım dilini (Mobbin standartları) blokzinciri ihtiyaçlarına uyarlayan 5 adımlı interaktif akış:
* **Adım 1: Vizyon & Açılış:** 3D neon metal sikke animasyonu ve egemen cüzdan karşılama manifestosu.
* **Adım 2: Amaç & Modül Kişiselleştirme:** Dokunmatik parlayan çoklu seçim hapları (*Transfers, Smart Metal Card, PoS Staking, Crypto Portfolio, zk-ID*).
* **Adım 3: On-Chain Revtag / ENS Kaydı:** Kullanıcı adı yazılırken gerçek zamanlı akıllı sözleşme sorgusu (`✓ Revtag @meryemgcl available on BlockCore Registry`).
* **Adım 4: Zero-Knowledge (zk-KYC) Kimlik Doğrulama:** Kişisel veriyi sızdırmadan anonim zk-SNARK kanıtı ile cüzdana *Tier 2 Verified* rozeti alma simülasyonu.
* **Adım 5: Web3 Üyelik Katmanı:** *Ultra Sovereign Plan (10 BLC/ay)* ile Sıfır Gas Paymaster ve Titanyum Kart avantajları.

---

### 3. ✍️ Hold-to-Sign (Kriptografik İşlem Onayı)
* Basit ve kazara dokunmaları önleyen, dokunsal geri bildirimli **1.1 saniyelik basılı tutma** mekanizması.
* Durum Geçişleri: `Idle` $\rightarrow$ `Mempool (0/3 Onay)` $\rightarrow$ `Doğrulandı (CONFIRMED Blok #)`.
* HMAC-SHA256 dijital imza özeti ile işlemlerin kurcalanamazlığını garanti altına alır.

---

### 4. 📊 İnteraktif Dokunmatik Grafikler (Touch-Scrubbing Sparklines)
* **Crypto (Bitcoin/BTC) & Invest (S&P 500 / RWA):** 24 saatlik fiyat trendi.
* Parmağınızı/farenizi grafik üzerinde kaydırdığınızda (`onPanUpdate`) anlık kılavuz çizgisi ve geçmiş zaman noktalarındaki fiyatı gösteren dinamik `CustomPainter` motoru.
* `1D`, `1W`, `1M`, `1Y`, `ALL` zaman filtreleri.

---

### 5. 💳 Akıllı Kartlar & Güvenlik Yönetimi (`CardsPage`)
* **3D Gradient / Dondurulmuş Buz Kartı:** Uzay Grisi, Gül Kurusu ve Lavanta renk temaları.
* **Anlık Güvenlik Kontrolleri:** Kart dondurma (`Freeze/Unfreeze`), CVV ve kart numarası maskesini kaldırma (`Eye Toggle`).
* **Aylık Harcama Limiti:** İnteraktif dinamik slider ($500 - $10,000) ve harcama göstergesi.
* **Apple & Google Wallet:** Tek tıkla dijital cüzdan entegrasyonu.
* **Kart İptal / Anahtar Yakma:** Kartı bloklayıp sıfırdan yeni Web3 soğuk cüzdan donanım anahtarı türetme diyaloğu.

---

### 6. 🌍 Çoklu Para Birimi & Hazine Motoru (`CurrencyRegistry`)
* 9 Küresel Para Birimi: `USD`, `EUR`, `GBP`, `TRY`, `SGD`, `JPY`, `CHF`, `CAD`, `AUD`.
* Kayan dengeli animasyonlu bakiye gösterimi (`AnimatedBalanceText`).
* On-chain Minting (Para Yükleme) ve Çapraz Kur Dönüştürme (`Move / Exchange`).

---

## 🏗️ Proje Dizin Yapısı (Clean Architecture)

```
flutter_app/
├── lib/
│   ├── main.dart                                # Uygulama giriş noktası ve temalandırma
│   ├── core/
│   │   ├── data/
│   │   │   ├── currency_models.dart             # 9 global kur modeli ve arbitraj oranları
│   │   │   └── dataset_repository.dart          # Kalıcı yerel defter ve shared_preferences
│   │   ├── mock/
│   │   │   └── mock_data.dart                   # İşlem modelleri ve hazır veri seti
│   │   ├── state/
│   │   │   └── wallet_state.dart                # Merkezi reaktif durum motoru (ChangeNotifier)
│   │   └── theme/
│   │       ├── app_icons.dart                   # Sıfır kırılganlıklı yerel ikon haritası
│   │       ├── app_theme.dart                   # Revolut Royal Blue & Koyu yüzey renk paleti
│   │       └── console_theme.dart               # Terminal & telemetri stilleri
│   ├── presentation/
│   │   ├── shell/
│   │   │   └── main_shell_page.dart             # 5 sekmeli kalıcı IndexedStack kabuğu
│   │   ├── pages/
│   │   │   ├── home/home_page.dart              # Ana ekran, hero bakiye ve PoR bannerı
│   │   │   ├── invest/invest_page.dart          # RWA hisse/fon takibi ve interaktif grafik
│   │   │   ├── payments/payments_page.dart      # P2P kişiler, QR kod ve transfer seçenekleri
│   │   │   ├── crypto/crypto_page.dart          # Kripto portföyü ve BTC canlı grafiği
│   │   │   ├── cards/cards_page.dart            # Banka kartı, harcama limiti ve Apple Wallet
│   │   │   ├── cards/card_customizer_page.dart  # 3 farklı kart rengi özelleştirici
│   │   │   ├── add_money/add_money_page.dart    # Karttan on-chain bakiye basma (Mint)
│   │   │   └── onboarding/                      # Web3 kimlik ve kayıt sihirbazı
│   │   │       └── onboarding_wizard_page.dart
│   │   ├── modals/
│   │   │   ├── proof_of_reserves_modal.dart     # Merkle Tree rezerv kanıtı ve denetim motoru
│   │   │   ├── profile_modal.dart               # Profil, zk-KYC rozeti, seed phrase ve ağ seçimi
│   │   │   ├── search_modal.dart                # Gerçek zamanlı arama ve filtreleme
│   │   │   ├── analytics_modal.dart             # Düğüm telemetrisi (TPS, Gas, Blok süresi)
│   │   │   ├── notification_modal.dart          # Canlı ağ bildirimleri ve olay günlüğü
│   │   │   ├── exchange_modal.dart              # Çapraz döviz arbitrajı ve dönüştürme
│   │   │   ├── send_money_modal.dart            # Hold-to-Sign transfer modalı
│   │   │   ├── spending_limit_modal.dart        # Harcama limiti ayarlayıcısı
│   │   │   ├── split_bill_modal.dart            # Bahşişli hesap bölüştürme hesaplayıcısı
│   │   │   └── crypto_trade_modal.dart          # Kripto alım/satım modalı
│   │   └── widgets/
│   │       ├── animated_balance_text.dart       # Kayan bakiye animasyonu
│   │       ├── hold_to_sign_button.dart         # Basılı tutarak imzalama butonu
│   │       ├── interactive_chart_widget.dart    # Dokunmatik parmak takipli sparkline grafik
│   │       ├── quick_action_button.dart         # Dairesel aksiyon butonları
│   │       └── transaction_tile.dart            # Çift bayraklı işlem kartı
```

---

## 🚀 Kurulum ve Çalıştırma Rehberi

### Gereksinimler
* [Flutter SDK](https://flutter.dev) (v3.22 veya üzeri)
* [Dart SDK](https://dart.dev) (v3.4 veya üzeri)
* Modern bir web tarayıcısı (Google Chrome / Brave / Edge)

### Adımlar

1. **Depoyu Klonlayın:**
```bash
git clone https://github.com/meryemgcl/BlockCore-Studio-The-Living-Protocol.git
cd BlockCore-Studio-The-Living-Protocol/flutter_app
```

2. **Bağımlılıkları Yükleyin:**
```bash
flutter pub get
```

3. **Geliştirme Ortamında Çalıştırın:**
```bash
flutter run -d chrome
```

4. **Production Web Sürümünü Derleme ve Dağıtma:**
```bash
flutter build web --release
# Derlenen web sürümünü yerel sunucuda test etmek için:
python -m http.server 8088 --directory build/web
```
Tarayıcınızda `http://localhost:8088` adresini açarak uygulamayı test edebilirsiniz.

---

## 👩‍💻 Geliştirici & Lisans
* **Geliştirici:** Meryem Güçlü ([@meryemgcl](https://github.com/meryemgcl))
* **Proje Türü:** Mobil Programlama Bitirme / Mezuniyet Projesi
* **Lisans:** MIT License
