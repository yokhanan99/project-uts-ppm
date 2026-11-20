import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../viewmodels/activity_viewmodel.dart';
import 'activity_form_view.dart';
import 'home_view.dart';

/// VIEW: Halaman Detail aktivitas (counter +, -, reset, hapus).
class ActivityDetailView extends StatelessWidget {
  final ActivityViewModel viewModel;
  final String activityId;

  const ActivityDetailView({
    super.key,
    required this.viewModel,
    required this.activityId,
  });

  void _showSnack(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 1),
      ));
  }

  /// AlertDialog konfirmasi yang dipakai untuk Reset dan Hapus.
  Future<bool> _confirm(
    BuildContext context, {
    required IconData icon,
    required Color color,
    required String title,
    required String message,
    required String confirmLabel,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        icon: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color.withAlpha(30),
          ),
          child: Icon(icon, color: color, size: 32),
        ),
        title: Text(title,
            textAlign: TextAlign.center,
            style: const TextStyle(fontWeight: FontWeight.w800, color: kDark)),
        content: Text(message, textAlign: TextAlign.center),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: color,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            child: Text(confirmLabel),
          ),
        ],
      ),
    );
    return result == true;
  }

  Future<void> _confirmReset(BuildContext context) async {
    final ok = await _confirm(
      context,
      icon: Icons.refresh_rounded,
      color: const Color(0xFFF59E0B),
      title: 'Reset Counter?',
      message: 'Nilai counter akan dikembalikan menjadi 0.',
      confirmLabel: 'Reset',
    );
    if (ok && context.mounted) {
      viewModel.reset(activityId);
      _showSnack(context, 'Counter di-reset menjadi 0');
    }
  }

  Future<void> _confirmDelete(BuildContext context) async {
    final ok = await _confirm(
      context,
      icon: Icons.delete_rounded,
      color: const Color(0xFFE53935),
      title: 'Hapus Aktivitas?',
      message: 'Aktivitas ini akan dihapus dari daftar.',
      confirmLabel: 'Hapus',
    );
    if (ok && context.mounted) {
      final messenger = ScaffoldMessenger.of(context);
      Navigator.pop(context); // kembali ke Home dulu
      viewModel.deleteActivity(activityId);
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(
            const SnackBar(content: Text('Aktivitas berhasil dihapus')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: viewModel,
      builder: (context, _) {
        final activity = viewModel.getById(activityId);

        // Aktivitas sudah dihapus (transisi pop sedang berjalan)
        if (activity == null) {
          return const Scaffold(body: SizedBox.shrink());
        }

        final color = activityColor(activityId);
        final counter = activity.counter;
        // Cincin progres: berputar setiap kelipatan 10
        final step = counter == 0 ? 0 : ((counter - 1) % 10) + 1;
        final round = counter == 0 ? 1 : ((counter - 1) ~/ 10) + 1;
        final progress = step / 10;

        return Scaffold(
          backgroundColor: kBackground,
          body: AnnotatedRegion<SystemUiOverlayStyle>(
            value: SystemUiOverlayStyle.light,
            child: Column(
              children: [
                // ---------- Header ----------
                Container(
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    gradient: kGradient,
                    borderRadius:
                        BorderRadius.vertical(bottom: Radius.circular(36)),
                  ),
                  padding: EdgeInsets.fromLTRB(
                      8, MediaQuery.of(context).padding.top + 8, 8, 26),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          IconButton(
                            color: Colors.white,
                            icon: const Icon(Icons.arrow_back_ios_new_rounded),
                            onPressed: () => Navigator.pop(context),
                          ),
                          const Spacer(),
                          IconButton(
                            tooltip: 'Edit',
                            color: Colors.white,
                            icon: const Icon(Icons.edit_rounded),
                            onPressed: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ActivityFormView(
                                  viewModel: viewModel,
                                  activityId: activityId,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      ActivityAvatar(
                          id: activityId, name: activity.name, size: 72),
                      const SizedBox(height: 14),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Text(
                          activity.name,
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 26,
                              fontWeight: FontWeight.w800),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text('Detail Aktivitas',
                          style: TextStyle(
                              color: Colors.white.withAlpha(200),
                              fontSize: 13)),
                    ],
                  ),
                ),

                // ---------- Isi ----------
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
                    child: Column(
                      children: [
                        SizedBox(
                          width: 230,
                          height: 230,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              Positioned.fill(
                                child: Container(
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.white,
                                    boxShadow: [
                                      BoxShadow(
                                        color: color.withAlpha(60),
                                        blurRadius: 30,
                                        offset: const Offset(0, 12),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              Positioned.fill(
                                child: Padding(
                                  padding: const EdgeInsets.all(14),
                                  child: TweenAnimationBuilder<double>(
                                    tween: Tween<double>(
                                        begin: 0, end: progress),
                                    duration:
                                        const Duration(milliseconds: 500),
                                    curve: Curves.easeOutCubic,
                                    builder: (context, value, _) =>
                                        CircularProgressIndicator(
                                      value: value,
                                      strokeWidth: 12,
                                      backgroundColor: color.withAlpha(35),
                                      valueColor:
                                          AlwaysStoppedAnimation<Color>(color),
                                    ),
                                  ),
                                ),
                              ),
                              AnimatedSwitcher(
                                duration: const Duration(milliseconds: 250),
                                transitionBuilder: (child, anim) =>
                                    ScaleTransition(
                                  scale: anim,
                                  child: FadeTransition(
                                      opacity: anim, child: child),
                                ),
                                child: Text(
                                  '$counter',
                                  key: ValueKey<int>(counter),
                                  style: const TextStyle(
                                      fontSize: 72,
                                      fontWeight: FontWeight.w800,
                                      color: kDark),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 6),
                          decoration: BoxDecoration(
                            color: color.withAlpha(28),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            'Putaran $round  •  $step / 10',
                            style: TextStyle(
                                color: color, fontWeight: FontWeight.w700),
                          ),
                        ),
                        const SizedBox(height: 28),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Tombol kurang (-)
                            Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white,
                                border: Border.all(
                                    color: const Color(0xFF5B52E8), width: 2),
                              ),
                              child: IconButton(
                                tooltip: 'Kurang',
                                iconSize: 34,
                                padding: const EdgeInsets.all(14),
                                color: const Color(0xFF5B52E8),
                                icon: const Icon(Icons.remove_rounded),
                                onPressed: () {
                                  final success =
                                      viewModel.decrement(activityId);
                                  _showSnack(
                                    context,
                                    success
                                        ? 'Counter berkurang menjadi ${viewModel.getById(activityId)?.counter}'
                                        : 'Counter tidak boleh kurang dari 0',
                                  );
                                },
                              ),
                            ),
                            const SizedBox(width: 36),
                            // Tombol tambah (+)
                            Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: kGradient,
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFF5B52E8)
                                        .withAlpha(90),
                                    blurRadius: 20,
                                    offset: const Offset(0, 8),
                                  ),
                                ],
                              ),
                              child: IconButton(
                                tooltip: 'Tambah',
                                iconSize: 44,
                                padding: const EdgeInsets.all(18),
                                color: Colors.white,
                                icon: const Icon(Icons.add_rounded),
                                onPressed: () {
                                  viewModel.increment(activityId);
                                  _showSnack(
                                    context,
                                    'Counter bertambah menjadi ${viewModel.getById(activityId)?.counter}',
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 32),
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: () => _confirmReset(context),
                                icon: const Icon(Icons.refresh_rounded),
                                label: const Text('Reset'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFFFF4DC),
                                  foregroundColor: const Color(0xFFB7791F),
                                  elevation: 0,
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 16),
                                  textStyle: const TextStyle(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 15),
                                  shape: RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.circular(16)),
                                ),
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: () => _confirmDelete(context),
                                icon: const Icon(Icons.delete_rounded),
                                label: const Text('Hapus'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFFFEBEE),
                                  foregroundColor: const Color(0xFFC62828),
                                  elevation: 0,
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 16),
                                  textStyle: const TextStyle(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 15),
                                  shape: RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.circular(16)),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
