import 'package:flutter/foundation.dart';

import '../models/activity_model.dart';
import '../repositories/activity_repository.dart';

/// VIEWMODEL: logika aplikasi & state. Memberi tahu View lewat notifyListeners().
class ActivityViewModel extends ChangeNotifier {
  final ActivityRepository _repository;

  ActivityViewModel(this._repository);

  /// Meminta seluruh data aktivitas dari Repository.
  List<ActivityModel> get activities => _repository.getAll();

  ActivityModel? getById(String id) => _repository.getById(id);

  void addActivity(String name) {
    _repository.add(name.trim());
    notifyListeners();
  }

  void editActivity(String id, String newName) {
    _repository.update(id, newName.trim());
    notifyListeners();
  }

  void deleteActivity(String id) {
    _repository.delete(id);
    notifyListeners();
  }

  void increment(String id) {
    final activity = _repository.getById(id);
    if (activity == null) return;
    _repository.updateCounter(id, activity.counter + 1);
    notifyListeners();
  }

  /// Mengembalikan false jika counter sudah 0 (tidak boleh kurang dari 0).
  bool decrement(String id) {
    final activity = _repository.getById(id);
    if (activity == null || activity.counter <= 0) return false;
    _repository.updateCounter(id, activity.counter - 1);
    notifyListeners();
    return true;
  }

  void reset(String id) {
    _repository.updateCounter(id, 0);
    notifyListeners();
  }
}
