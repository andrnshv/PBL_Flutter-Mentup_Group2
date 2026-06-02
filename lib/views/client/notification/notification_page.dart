import 'package:flutter/material.dart';
import '../../../controller/client/notification_controller.dart';

// ================================================================
//  NOTIFICATION PAGE — MentUp
//  File: lib/views/client/notification/notification_page.dart
//
//  Tampilan sama dengan desain awal. Data dari Supabase:
//   - Upcoming Session   : booking dibayar, jadwal mendatang
//   - New Mentor Available: mentor punya slot hari ini
//   - Booking Confirmed  : booking sudah dibayar & dikonfirmasi
// ================================================================

class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  final NotificationController _controller = NotificationController();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    await _controller.fetchNotifications();
    if (mounted) setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          "Notifications",
          style: TextStyle(color: Colors.black),
        ),
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : (_controller.errorMessage != null)
              ? _buildError()
              : (_controller.notifications.isEmpty
                  ? _emptyState()
                  : RefreshIndicator(
                      onRefresh: () async {
                        setState(() => _isLoading = true);
                        await _load();
                      },
                      child: ListView(
                        padding: const EdgeInsets.all(16),
                        children: _controller.notifications.map((n) {
                          return _notifItem(
                            icon: n.icon,
                            title: n.title,
                            subtitle: n.subtitle,
                            time: n.time,
                          );
                        }).toList(),
                      ),
                    )),
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

  Widget _emptyState() {
    return ListView(
      // pakai ListView agar tetap bisa pull-to-refresh saat kosong
      children: [
        const SizedBox(height: 120),
        Icon(Icons.notifications_off_outlined,
            size: 56, color: Colors.grey[400]),
        const SizedBox(height: 12),
        const Center(
          child: Text(
            "Belum ada notifikasi",
            style: TextStyle(color: Colors.grey),
          ),
        ),
      ],
    );
  }

  Widget _notifItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required String time,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.deepPurple.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: Colors.deepPurple),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
          ),
          Text(
            time,
            style: const TextStyle(fontSize: 11, color: Colors.grey),
          )
        ],
      ),
    );
  }
}
