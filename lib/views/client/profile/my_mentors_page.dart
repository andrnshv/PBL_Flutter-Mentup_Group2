import 'package:flutter/material.dart';
import '../../../controller/client/my_mentors_controller.dart';

// ================================================================
//  MY MENTORS PAGE (VIEW) — MentUp
//  File: lib/views/client/profile/my_mentors_page.dart
//
//  Tampilan sama dengan desain awal, tapi data dari Supabase
//  (bukan dummy). Active = sesi berjalan, Past = selesai/batal.
// ================================================================

class MyMentorsPage extends StatefulWidget {
  const MyMentorsPage({super.key});

  @override
  State<MyMentorsPage> createState() => _MyMentorsPageState();
}

class _MyMentorsPageState extends State<MyMentorsPage> {
  final MyMentorsController _controller = MyMentorsController();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    await _controller.fetchMyMentors();
    if (mounted) setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("My Mentors")),
      backgroundColor: const Color(0xFFF8F9FB),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : (_controller.errorMessage != null)
              ? _buildError()
              : RefreshIndicator(
                  onRefresh: () async {
                    setState(() => _isLoading = true);
                    await _load();
                  },
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ── ACTIVE MENTORS ──────────────
                        const Text(
                          "Active Mentors",
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        const SizedBox(height: 10),

                        if (_controller.activeMentors.isEmpty)
                          _emptyState("Belum ada mentor aktif")
                        else
                          ..._controller.activeMentors.map((mentor) {
                            return _mentorCard(
                              name: mentor.name,
                              role: mentor.role,
                              foto: mentor.fotoUrl,
                              status: "Active",
                              color: Colors.green,
                            );
                          }),

                        const SizedBox(height: 20),

                        // ── PAST MENTORS ────────────────
                        const Text(
                          "Past Mentors",
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        const SizedBox(height: 10),

                        if (_controller.pastMentors.isEmpty)
                          _emptyState("Belum ada riwayat mentor")
                        else
                          ..._controller.pastMentors.map((m) {
                            return _mentorCard(
                              name: m.name,
                              role: m.role,
                              foto: m.fotoUrl,
                              status: m.status,
                              color: m.status == "Done"
                                  ? Colors.blue
                                  : Colors.grey,
                            );
                          }),
                      ],
                    ),
                  ),
                ),
    );
  }

  Widget _buildError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.wifi_off_rounded, size: 56, color: Colors.grey),
            const SizedBox(height: 12),
            Text(
              _controller.errorMessage ?? 'Terjadi kesalahan',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () {
                setState(() => _isLoading = true);
                _load();
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Coba lagi'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _emptyState(String text) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 24),
      alignment: Alignment.center,
      child: Text(text, style: const TextStyle(color: Colors.grey)),
    );
  }

  Widget _mentorCard({
    required String name,
    required String role,
    required String? foto,
    required String status,
    required Color color,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 25,
            backgroundColor: const Color(0xFFEDEDED),
            backgroundImage:
                (foto != null && foto.isNotEmpty) ? NetworkImage(foto) : null,
            child: (foto == null || foto.isEmpty)
                ? Text(
                    name.isNotEmpty ? name[0].toUpperCase() : '?',
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.grey),
                  )
                : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
                Text(role),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              status,
              style: TextStyle(color: color, fontSize: 12),
            ),
          )
        ],
      ),
    );
  }
}
