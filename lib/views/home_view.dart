import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../viewmodels/activity_viewmodel.dart';
import 'activity_detail_view.dart';
import 'activity_form_view.dart';

// ---------- Konstanta desain yang dipakai bersama oleh semua View ----------
const kGradient = LinearGradient(
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
  colors: [Color(0xFF7B6CF6), Color(0xFF3D3B9E)],
);
const kBackground = Color(0xFFF4F5FB);
const kDark = Color(0xFF1F2040);

const _palette = [
  Color(0xFF6C63FF),
  Color(0xFFFF7A59),
  Color(0xFF14B8A6),
  Color(0xFFF59E0B),
  Color(0xFFEC4899),
  Color(0xFF3B82F6),
];

/// Warna unik untuk tiap aktivitas (berdasarkan id).
Color activityColor(String id) {
  final sum = id.codeUnits.fold<int>(0, (a, b) => a + b);
  return _palette[sum % _palette.length];
}

/// Avatar bulat berisi huruf pertama nama aktivitas (dengan animasi Hero).
class ActivityAvatar extends StatelessWidget {
  final String id;
  final String name;
  final double size;

  const ActivityAvatar({
    super.key,
    required this.id,
    required this.name,
    this.size = 52,
  });

  @override
  Widget build(BuildContext context) {
    final color = activityColor(id);
    return Hero(
      tag: 'avatar_$id',
      child: Material(
        type: MaterialType.transparency,
        child: Container(
          width: size,
          height: size,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [color, color.withAlpha(170)],
            ),
          ),
          child: Text(
            name.isEmpty ? '?' : name[0].toUpperCase(),
            style: TextStyle(
              color: Colors.white,
              fontSize: size * 0.42,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}

/// VIEW: Halaman Home (daftar aktivitas).
class HomeView extends StatelessWidget {
  final ActivityViewModel viewModel;

  const HomeView({super.key, required this.viewModel});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackground,
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.light,
        // Tampilan dibangun ulang otomatis saat ViewModel memanggil notifyListeners()
        child: ListenableBuilder(
          listenable: viewModel,
          builder: (context, _) {
            final activities = viewModel.activities;
            final total = activities.fold<int>(0, (s, a) => s + a.counter);

            return Column(
              children: [
                _Header(count: activities.length, total: total),
                const Padding(
                  padding: EdgeInsets.fromLTRB(24, 22, 24, 6),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Daftar Aktivitas',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: kDark,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: activities.isEmpty
                      ? const _EmptyState()
                      : ListView.builder(
                          padding: const EdgeInsets.fromLTRB(20, 8, 20, 110),
                          itemCount: activities.length,
                          itemBuilder: (context, index) {
                            final activity = activities[index];
                            return _ActivityCard(
                              viewModel: viewModel,
                              id: activity.id,
                              name: activity.name,
                              counter: activity.counter,
                            );
                          },
                        ),
                ),
              ],
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color(0xFF5B52E8),
        foregroundColor: Colors.white,
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Aktivitas Baru',
            style: TextStyle(fontWeight: FontWeight.w600)),
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ActivityFormView(viewModel: viewModel),
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final int count;
  final int total;

  const _Header({required this.count, required this.total});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: kGradient,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(36)),
      ),
      padding: EdgeInsets.fromLTRB(
          24, MediaQuery.of(context).padding.top + 20, 24, 26),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha(45),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(Icons.bolt_rounded,
                    color: Colors.white, size: 26),
              ),
              const SizedBox(width: 12),
              const Text(
                'Activity Counter',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            'Catat dan pantau progres aktivitasmu setiap hari.',
            style: TextStyle(color: Colors.white.withAlpha(210), fontSize: 14),
          ),
          const SizedBox(height: 22),
          Row(
            children: [
              Expanded(
                child: _StatCard(
                    icon: Icons.checklist_rounded,
                    label: 'Aktivitas',
                    value: '$count'),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _StatCard(
                    icon: Icons.trending_up_rounded,
                    label: 'Total Hitungan',
                    value: '$total'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _StatCard(
      {required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(38),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.white, size: 26),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(value,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w800)),
                Text(label,
                    style: TextStyle(
                        color: Colors.white.withAlpha(210), fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ActivityCard extends StatelessWidget {
  final ActivityViewModel viewModel;
  final String id;
  final String name;
  final int counter;

  const _ActivityCard({
    required this.viewModel,
    required this.id,
    required this.name,
    required this.counter,
  });

  @override
  Widget build(BuildContext context) {
    final color = activityColor(id);
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF3D3B9E).withAlpha(22),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(22),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) =>
                    ActivityDetailView(viewModel: viewModel, activityId: id),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 8, 14),
              child: Row(
                children: [
                  ActivityAvatar(id: id, name: name),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              fontSize: 16.5,
                              fontWeight: FontWeight.w700,
                              color: kDark),
                        ),
                        const SizedBox(height: 4),
                        Text('Ketuk untuk melihat detail',
                            style: TextStyle(
                                fontSize: 12.5, color: Colors.grey.shade600)),
                      ],
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: color.withAlpha(30),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Text(
                      '$counter',
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: color),
                    ),
                  ),
                  IconButton(
                    tooltip: 'Edit',
                    icon: Icon(Icons.edit_rounded,
                        color: Colors.grey.shade500, size: 22),
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ActivityFormView(
                            viewModel: viewModel, activityId: id),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.inbox_rounded, size: 72, color: Colors.grey.shade400),
          const SizedBox(height: 12),
          const Text('Belum ada aktivitas',
              style: TextStyle(
                  fontSize: 17, fontWeight: FontWeight.w700, color: kDark)),
          const SizedBox(height: 4),
          Text('Tekan tombol "Aktivitas Baru" untuk memulai.',
              style: TextStyle(color: Colors.grey.shade600)),
        ],
      ),
    );
  }
}
