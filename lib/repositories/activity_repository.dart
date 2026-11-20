import '../data/activity_data.dart';
import '../models/activity_model.dart';

/// REPOSITORY: mengelola akses & manipulasi data (CRUD) pada Data.
class ActivityRepository {
  final ActivityData _data;

  ActivityRepository(this._data);

  /// Mengambil seluruh aktivitas.
  List<ActivityModel> getAll() => List.unmodifiable(_data.activities);

  /// Mengambil satu aktivitas berdasarkan id (null jika tidak ada).
  ActivityModel? getById(String id) {
    final index = _data.activities.indexWhere((a) => a.id == id);
    return index == -1 ? null : _data.activities[index];
  }

  /// Menambahkan aktivitas baru.
  void add(String name) {
    _data.activities.add(
      ActivityModel(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        name: name,
      ),
    );
  }

  /// Mengubah nama aktivitas.
  void update(String id, String newName) {
    final index = _data.activities.indexWhere((a) => a.id == id);
    if (index != -1) {
      _data.activities[index] = _data.activities[index].copyWith(name: newName);
    }
  }

  /// Menghapus aktivitas.
  void delete(String id) {
    _data.activities.removeWhere((a) => a.id == id);
  }

  /// Memperbarui nilai counter.
  void updateCounter(String id, int value) {
    final index = _data.activities.indexWhere((a) => a.id == id);
    if (index != -1) {
      _data.activities[index] =
          _data.activities[index].copyWith(counter: value);
    }
  }
}
