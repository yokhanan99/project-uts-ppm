import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../viewmodels/activity_viewmodel.dart';
import 'home_view.dart';

/// VIEW: Halaman Tambah / Edit aktivitas.
/// Jika [activityId] null -> mode tambah, jika ada -> mode edit.
class ActivityFormView extends StatefulWidget {
  final ActivityViewModel viewModel;
  final String? activityId;

  const ActivityFormView({
    super.key,
    required this.viewModel,
    this.activityId,
  });

  @override
  State<ActivityFormView> createState() => _ActivityFormViewState();
}

class _ActivityFormViewState extends State<ActivityFormView> {
  static const _suggestions = [
    'Olahraga',
    'Membaca Buku',
    'Minum Air',
    'Mengerjakan Tugas',
    'Meditasi',
  ];

  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _controller;

  bool get _isEdit => widget.activityId != null;

  @override
  void initState() {
    super.initState();
    final existing =
        _isEdit ? widget.viewModel.getById(widget.activityId!) : null;
    _controller = TextEditingController(text: existing?.name ?? '');
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _save() {
    // Validasi: nama tidak boleh kosong
    if (!_formKey.currentState!.validate()) return;

    final messenger = ScaffoldMessenger.of(context);
    final name = _controller.text;

    if (_isEdit) {
      widget.viewModel.editActivity(widget.activityId!, name);
    } else {
      widget.viewModel.addActivity(name);
    }

    Navigator.pop(context);
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(
        content: Text(_isEdit
            ? 'Aktivitas berhasil diubah'
            : 'Aktivitas berhasil ditambahkan'),
      ));
  }

  OutlineInputBorder _border(Color color, [double width = 0]) =>
      OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: width == 0
            ? BorderSide.none
            : BorderSide(color: color, width: width),
      );

  @override
  Widget build(BuildContext context) {
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
                  8, MediaQuery.of(context).padding.top + 8, 24, 28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  IconButton(
                    color: Colors.white,
                    icon: const Icon(Icons.arrow_back_ios_new_rounded),
                    onPressed: () => Navigator.pop(context),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _isEdit ? 'Edit Aktivitas' : 'Aktivitas Baru',
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 26,
                              fontWeight: FontWeight.w800),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          _isEdit
                              ? 'Ubah nama aktivitas yang sudah ada.'
                              : 'Beri nama aktivitas yang ingin kamu hitung.',
                          style: TextStyle(
                              color: Colors.white.withAlpha(210),
                              fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // ---------- Form ----------
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF3D3B9E).withAlpha(22),
                        blurRadius: 18,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Text('Nama Aktivitas',
                            style: TextStyle(
                                fontWeight: FontWeight.w700, color: kDark)),
                        const SizedBox(height: 10),
                        // TextFormField = TextField yang mendukung validator
                        TextFormField(
                          controller: _controller,
                          autofocus: true,
                          textInputAction: TextInputAction.done,
                          onFieldSubmitted: (_) => _save(),
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w600),
                          decoration: InputDecoration(
                            hintText: 'contoh: Olahraga',
                            filled: true,
                            fillColor: kBackground,
                            prefixIcon: const Icon(Icons.edit_note_rounded),
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 18),
                            border: _border(Colors.transparent),
                            enabledBorder: _border(Colors.transparent),
                            focusedBorder:
                                _border(const Color(0xFF6C63FF), 2),
                            errorBorder: _border(Colors.red.shade400, 1.5),
                            focusedErrorBorder:
                                _border(Colors.red.shade400, 2),
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Nama aktivitas tidak boleh kosong';
                            }
                            return null;
                          },
                        ),
                        if (!_isEdit) ...[
                          const SizedBox(height: 20),
                          Text('Saran cepat',
                              style: TextStyle(
                                  fontSize: 13, color: Colors.grey.shade600)),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: _suggestions
                                .map(
                                  (s) => ActionChip(
                                    label: Text(s),
                                    backgroundColor: const Color(0xFFEEECFF),
                                    side: BorderSide.none,
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(12)),
                                    labelStyle: const TextStyle(
                                        color: Color(0xFF5B52E8),
                                        fontWeight: FontWeight.w600),
                                    onPressed: () {
                                      _controller.text = s;
                                      _controller.selection =
                                          TextSelection.collapsed(
                                              offset: s.length);
                                    },
                                  ),
                                )
                                .toList(),
                          ),
                        ],
                        const SizedBox(height: 28),
                        ElevatedButton.icon(
                          onPressed: _save,
                          icon: const Icon(Icons.check_rounded),
                          label: const Text('Simpan',
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.w700)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF5B52E8),
                            foregroundColor: Colors.white,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
