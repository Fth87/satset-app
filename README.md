# SatSet Logistics

SatSet adalah platform manajemen logistik kurir mutakhir yang dirancang untuk mengoptimalkan operasional pengiriman barang melalui integrasi kecerdasan buatan dan algoritma optimasi rute. Sistem ini dikembangkan untuk meminimalisir input manual, mengurangi kesalahan pengiriman, dan memaksimalkan efisiensi waktu kurir di lapangan.


## Analisis Fitur Mendalam

### 1. Smart Manifest Parsing dengan Google Gemini AI
Sistem menggunakan model bahasa besar (LLM) Google Gemini untuk memproses data manifest yang tidak terstruktur. Fitur ini memungkinkan aplikasi untuk:
*   **Pemrosesan Gambar dan Teks**: Kurir dapat memotret lembar manifest fisik atau menyalin teks mentah dari sistem lain.
*   **Ekstraksi Entitas Otomatis**: AI secara cerdas memisahkan nama penerima, alamat tujuan, nomor telepon, dan instruksi khusus tanpa memerlukan format input yang kaku.
*   **Normalisasi Alamat**: Data alamat yang diekstrak kemudian diproses untuk memastikan kompatibilitas dengan layanan geocoding guna akurasi penempatan titik di peta.

### 2. Optimasi Rute Bertahap (Multi-Step Optimization)
Berbeda dengan sistem navigasi standar yang hanya menghitung jarak antar titik, SatSet menerapkan proses dua tahap:
*   **Tahap Optimasi (Vroom/ORS)**: Menggunakan algoritma Vroom melalui OpenRouteService untuk menentukan urutan kunjungan yang paling logis berdasarkan lokasi geografis, meminimalkan jarak tempuh total.
*   **Tahap Geometri Jalan (Directions API)**: Setelah urutan ditentukan, sistem mengambil data geometri jalan yang detail. Hal ini menghasilkan jalur navigasi yang mengikuti jalan raya yang sebenarnya, bukan sekadar garis lurus antar koordinat.
*   **Pembedaan Visual Jalur**:
    *   **Jalur Pergi**: Ditampilkan dengan garis biru solid yang tebal untuk panduan pengiriman aktif.
    *   **Jalur Pulang**: Ditampilkan dengan garis ungu putus-putus (dashed) dengan outline putih untuk memberikan pembeda visual yang jelas saat kurir harus kembali ke titik awal.

### 3. Arsitektur State Persistence
Aplikasi menggunakan pola arsitektur yang memastikan konsistensi data visual:
*   **AppController (GetX)**: Berfungsi sebagai Single Source of Truth untuk status peta global, koordinat paket, dan titik rute yang sudah dihitung.
*   **Lifecycle Management**: Rute yang sudah dihitung tetap tersimpan dalam memori meskipun pengguna berpindah layar (seperti melihat detail paket atau mengedit manifest), sehingga menghindari pemrosesan ulang yang memakan kuota API dan waktu.

### 4. Alat Produktivitas Lapangan
*   **Integrasi Komunikasi**: Tombol akses cepat untuk panggilan suara dan WhatsApp yang terintegrasi langsung dengan nomor telepon yang diekstrak oleh AI.
*   **Manajemen Titik Awal Kustom**: Kurir dapat menentukan lokasi awal (gudang/basecamp) secara dinamis dengan melakukan long-press pada peta, yang kemudian disimpan secara permanen di perangkat menggunakan Shared Preferences.
*   **Shortcut Navigasi Cepat**: Fitur "Go to Delivery" memungkinkan kurir memusatkan peta ke lokasi paket tertentu dalam hitungan detik.


## Arsitektur Teknis dan Stack Teknologi

### Pengembangan Mobile
*   **Framework**: Flutter (Dart) untuk pengembangan cross-platform yang responsif.
*   **Peta**: Flutter Map dengan integrasi OpenStreetMap sebagai tile provider.
*   **State Management**: GetX untuk reactive programming dan manajemen dependensi yang efisien.

### Layanan Cloud dan API
*   **Backend-as-a-Service (BaaS)**: Supabase untuk otentikasi pengguna, penyimpanan data real-time, dan manajemen basis data PostgreSQL.
*   **AI Engine**: Google Gemini API untuk pemrosesan bahasa alami (NLP) pada data manifest.
*   **Routing Engine**: OpenRouteService (ORS) untuk optimasi rute (Vroom) dan layanan directions.


## Panduan Instalasi dan Konfigurasi

### Prasyarat Sistem
*   Flutter SDK versi terbaru.
*   Android Studio / Xcode untuk build platform spesifik.
*   Akses internet untuk sinkronisasi API.

### Langkah Instalasi
1.  **Clone Repositori**:
    ```bash
    git clone https://github.com/username/ngetestaja.git
    cd ngetestaja
    ```

2.  **Konfigurasi Variabel Lingkungan**:
    Buat file `.env` pada direktori root project. Masukkan kunci API berikut:
    ```env
    SUPABASE_URL=url_proyek_anda
    SUPABASE_ANON_KEY=kunci_anon_anda
    GEMINI_API_KEY=kunci_api_gemini_anda
    ORS_API_KEY=kunci_api_openrouteservice_anda
    ```

3.  **Keamanan Variabel**:
    Project ini menggunakan `envied` untuk mengaburkan (obfuscate) kunci API dalam kode biner. Jalankan generator kode:
    ```bash
    flutter pub run build_runner build --delete-conflicting-outputs
    ```

4.  **Kompilasi dan Jalankan**:
    ```bash
    flutter run
    ```


## Keamanan dan Optimalisasi Produksi

Aplikasi telah melewati proses pengerasan (hardening) untuk lingkungan produksi:
*   **ProGuard/R8**: Konfigurasi khusus pada `android/app/proguard-rules.pro` telah diterapkan untuk menjaga integritas library ML Kit dan mencegah penghapusan class penting saat proses minifikasi kode.
*   **Android Build System**: Menggunakan Gradle dengan konfigurasi Kotlin DSL (`build.gradle.kts`) untuk manajemen dependensi yang lebih modern dan aman.
*   **Obfuscation**: Variabel sensitif tidak disimpan dalam bentuk teks biasa di dalam kode aplikasi yang sudah dikompilasi.


## Struktur Proyek

*   `lib/core/`: Berisi logika bisnis inti, integrasi layanan API, dan utilitas global.
*   `lib/models/`: Representasi objek data (POJO) untuk konsistensi struktur data.
*   `lib/screens/`: Implementasi antarmuka pengguna (UI) untuk setiap fitur utama.
*   `lib/widgets/`: Komponen UI kustom yang dioptimalkan untuk penggunaan ulang.
*   `assets/`: Aset statis seperti gambar dan ikon aplikasi.


## Informasi Akun Tes

Untuk menguji aplikasi, Anda dapat menggunakan akun berikut:

**Courier Account**
- *Email:* courier@test.com
- *Password:* password123

**Dispatcher Account**
- *Email:* dispatcher@test.com
- *Password:* password123


## Kontribusi

Kontribusi untuk pengembangan SatSet sangat kami hargai. Jika Anda menemukan bug, memiliki saran fitur, atau ingin berkontribusi pada kode, silakan buka Issue atau kirimkan Pull Request melalui repositori resmi ini.

**SatSet Team** - Deliver Faster, Smarter, and Safer.
