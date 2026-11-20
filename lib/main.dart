import 'package:flutter/material.dart';

import 'data/activity_data.dart';
import 'repositories/activity_repository.dart';
import 'viewmodels/activity_viewmodel.dart';
import 'views/home_view.dart';

void main() {
  runApp(const ActivityCounterApp());
}

class ActivityCounterApp extends StatefulWidget {
  const ActivityCounterApp({super.key});

  @override
  State<ActivityCounterApp> createState() => _ActivityCounterAppState();
}

class _ActivityCounterAppState extends State<ActivityCounterApp> {
  // Rantai dependensi: Data -> Repository -> ViewModel -> View
  late final ActivityViewModel _viewModel = ActivityViewModel(
    ActivityRepository(ActivityData()),
  );

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Activity Counter',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6C63FF),
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: kBackground,
        snackBarTheme: SnackBarThemeData(
          behavior: SnackBarBehavior.floating,
          backgroundColor: kDark,
          contentTextStyle: const TextStyle(color: Colors.white, fontSize: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
      home: HomeView(viewModel: _viewModel),
    );
  }
}
