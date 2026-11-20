# Activity Counter (Flutter + MVVM)

UTS Pemrograman Mobile — aplikasi pencatat aktivitas dengan arsitektur Model–Data–Repository–ViewModel–View.

## Cara menjalankan
1. Pastikan Flutter SDK terpasang (`flutter --version`).
2. Di folder project, jalankan `flutter create .` (membuat folder android/ios/dll tanpa menimpa `lib/` dan `pubspec.yaml`).
3. `flutter pub get`
4. `flutter run`

## Struktur
lib/
 - main.dart
 - models/activity_model.dart
 - data/activity_data.dart
 - repositories/activity_repository.dart
 - viewmodels/activity_viewmodel.dart
 - views/home_view.dart, activity_form_view.dart, activity_detail_view.dart

## Alur data
View -> ViewModel -> Repository -> Data (List).
Setelah data berubah, ViewModel memanggil `notifyListeners()`, lalu `ListenableBuilder` di View membangun ulang tampilan.

## Identitas
Nama: Yokhanan Haposan Siregar  NIM: 20240040211  Kelas: TI24D

## link record di drive
https://drive.google.com/drive/folders/1fzyjtfa-5sqb1LzgXU2XzZcJ24INHvHB?usp=sharing