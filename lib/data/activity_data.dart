import '../models/activity_model.dart';

/// DATA: sumber data & penyimpanan sementara (List) selama aplikasi berjalan.
class ActivityData {
  final List<ActivityModel> _activities = [
    const ActivityModel(id: '1', name: 'Olahraga', counter: 3),
    const ActivityModel(id: '2', name: 'Membaca Buku', counter: 5),
    const ActivityModel(id: '3', name: 'Mengerjakan Tugas', counter: 2),
  ];

  /// Daftar aktivitas (dapat dimodifikasi oleh Repository).
  List<ActivityModel> get activities => _activities;
}
