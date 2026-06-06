import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../../controller/client/reschedule_page_controller.dart';
import '../../../controller/client/history_controller.dart';

// ================================================================
//  RESCHEDULE PAGE — MentUp (sisi CLIENT)
//  File: lib/views/client/History/reschedule_page.dart
//
//  Form reschedule booking yang di-reject mentor.
//  Mirip BookingPage: pilih tanggal + jam baru (mentor sama).
//  Submit → update booking → status kembali 'paid'
//  → muncul lagi di mentor untuk di-accept/reject.
// ================================================================

class ReschedulePage extends StatefulWidget {
  final HistoryItemModel booking;

  const ReschedulePage({super.key, required this.booking});

  @override
  State<ReschedulePage> createState() => _ReschedulePageState();
}

class _ReschedulePageState extends State<ReschedulePage> {
  final ReschedulePageController _controller = ReschedulePageController();
  final Color primary = const Color(0xFF6C63FF);

  DateTime? selectedDate;
  DateTime focusedDay = DateTime.now();
  TimeOfDay? selectedStart;
  TimeOfDay? selectedEnd;

  bool _loadingSlots = true;
  bool _submitting = false;

  // ── harga per jam (dari pricePerSession di booking jika ada)
  // Kita tidak punya pricePerSession di HistoryItemModel,
  // jadi harga tidak dihitung ulang (sudah tercatat di booking lama)

  @override
  void initState() {
    super.initState();
    _loadSlots();
  }

  Future<void> _loadSlots() async {
    await _controller.fetchAvailableSlots(widget.booking.mentorId);
    if (mounted) setState(() => _loadingSlots = false);
  }

  // ── durasi label ──
  String get _durationLabel {
    if (selectedStart == null || selectedEnd == null) return '';
    final diff = (selectedEnd!.hour * 60 + selectedEnd!.minute) -
        (selectedStart!.hour * 60 + selectedStart!.minute);
    if (diff <= 0) return '';
    final h = diff / 60.0;
    final s = h == h.roundToDouble() ? h.toInt().toString() : h.toString();
    return '$s jam';
  }

  void _snack(String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Future<void> _submit() async {
    if (selectedDate == null || selectedStart == null || selectedEnd == null) {
      _snack('Pilih tanggal dan jam terlebih dahulu', Colors.orange);
      return;
    }

    final err = _controller.validateTime(
      date: selectedDate!,
      start: selectedStart!,
      end: selectedEnd!,
    );
    if (err != null) {
      _snack(err, Colors.redAccent);
      return;
    }

    setState(() => _submitting = true);

    final result = await _controller.submitReschedule(
      bookingId: widget.booking.bookingId,
      newDate: selectedDate!,
      newStart: selectedStart!,
      newEnd: selectedEnd!,
    );

    if (!mounted) return;
    setState(() => _submitting = false);

    if (result == null) {
      // Sukses → pop dengan true supaya History refresh
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Reschedule berhasil! Menunggu konfirmasi mentor.'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );
      await Future.delayed(const Duration(milliseconds: 800));
      if (mounted) Navigator.pop(context, true);
    } else {
      _snack(result, Colors.redAccent);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FA),
      appBar: AppBar(
        title: const Text(
          'Reschedule Booking',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: _loadingSlots
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Info mentor ──
                    _card(
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: primary.withOpacity(0.15),
                          backgroundImage: (widget.booking.fotoUrl != null &&
                                  widget.booking.fotoUrl!.isNotEmpty)
                              ? NetworkImage(widget.booking.fotoUrl!)
                              : null,
                          child: (widget.booking.fotoUrl == null ||
                                  widget.booking.fotoUrl!.isEmpty)
                              ? Text(
                                  widget.booking.name.isNotEmpty
                                      ? widget.booking.name[0].toUpperCase()
                                      : '?',
                                  style: TextStyle(
                                      color: primary,
                                      fontWeight: FontWeight.bold),
                                )
                              : null,
                        ),
                        title: Text(
                          widget.booking.name,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(widget.booking.role),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // ── Info alasan reject ──
                    if (widget.booking.cancelReason != null &&
                        widget.booking.cancelReason!.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.all(14),
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: Colors.orange.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(16),
                          border:
                              Border.all(color: Colors.orange.withOpacity(0.3)),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(Icons.info_outline_rounded,
                                color: Colors.orange, size: 18),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('Alasan penolakan:',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 13)),
                                  const SizedBox(height: 4),
                                  Text(widget.booking.cancelReason!,
                                      style: const TextStyle(fontSize: 13)),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                    // ── Pilih tanggal baru ──
                    const Text('Pilih Tanggal Baru',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 10),

                    _controller.availableSlots.isEmpty
                        ? Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Column(
                              children: [
                                Icon(Icons.event_busy,
                                    size: 48, color: Colors.grey[400]),
                                const SizedBox(height: 10),
                                const Text(
                                  'Tidak ada jadwal tersedia.\nHubungi mentor atau ajukan refund.',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(color: Colors.grey),
                                ),
                              ],
                            ),
                          )
                        : Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: TableCalendar(
                              firstDay: DateTime.now(),
                              lastDay: DateTime(2030),
                              focusedDay: focusedDay,
                              enabledDayPredicate: (day) => _controller
                                  .availableDays
                                  .any((d) => isSameDay(d, day)),
                              selectedDayPredicate: (day) =>
                                  selectedDate != null &&
                                  isSameDay(day, selectedDate!),
                              onDaySelected: (sel, foc) {
                                setState(() {
                                  selectedDate = sel;
                                  focusedDay = foc;
                                  selectedStart = null;
                                  selectedEnd = null;
                                });
                              },
                              calendarBuilders: CalendarBuilders(
                                markerBuilder: (ctx, day, _) {
                                  if (_controller.availableDays
                                      .any((d) => isSameDay(d, day))) {
                                    return Positioned(
                                      bottom: 4,
                                      child: Container(
                                        width: 6,
                                        height: 6,
                                        decoration: BoxDecoration(
                                          color: Colors.green,
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                    );
                                  }
                                  return null;
                                },
                              ),
                              calendarStyle: CalendarStyle(
                                todayDecoration: BoxDecoration(
                                  color: primary.withOpacity(0.4),
                                  shape: BoxShape.circle,
                                ),
                                selectedDecoration: BoxDecoration(
                                  color: primary,
                                  shape: BoxShape.circle,
                                ),
                                disabledTextStyle:
                                    const TextStyle(color: Color(0xFFDADADA)),
                              ),
                              headerStyle: const HeaderStyle(
                                formatButtonVisible: false,
                                titleCentered: true,
                              ),
                            ),
                          ),

                    const SizedBox(height: 20),

                    // ── Pilih jam baru ──
                    _card(
                      child: ListTile(
                        leading: const Icon(Icons.access_time),
                        title: Text(
                          (selectedStart == null)
                              ? 'Pilih Jam Sesi'
                              : (selectedEnd == null
                                  ? 'Mulai: ${selectedStart!.format(context)}'
                                  : '${selectedStart!.format(context)} - ${selectedEnd!.format(context)}'
                                      '${_durationLabel.isNotEmpty ? '  ($_durationLabel)' : ''}'),
                        ),
                        onTap: selectedDate == null
                            ? () => _snack('Pilih tanggal dulu', Colors.orange)
                            : () async {
                                final start = await showTimePicker(
                                  context: context,
                                  initialTime: selectedStart ?? TimeOfDay.now(),
                                  helpText: 'Pilih Jam Mulai',
                                );
                                if (start == null || !mounted) return;

                                final end = await showTimePicker(
                                  context: context,
                                  initialTime: selectedEnd ??
                                      TimeOfDay(
                                          hour: (start.hour + 1) % 24,
                                          minute: start.minute),
                                  helpText: 'Pilih Jam Selesai',
                                );
                                if (end == null || !mounted) return;

                                final err = _controller.validateTime(
                                  date: selectedDate!,
                                  start: start,
                                  end: end,
                                );
                                if (err != null) {
                                  _snack(err, Colors.redAccent);
                                  return;
                                }

                                setState(() {
                                  selectedStart = start;
                                  selectedEnd = end;
                                });
                              },
                      ),
                    ),

                    const SizedBox(height: 30),

                    // ── Tombol Submit ──
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primary,
                        minimumSize: const Size.fromHeight(55),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15)),
                      ),
                      onPressed: _submitting ? null : _submit,
                      child: _submitting
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                  color: Colors.white, strokeWidth: 2),
                            )
                          : const Text(
                              'Ajukan Reschedule',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold),
                            ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _card({required Widget child}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
      ),
      child: child,
    );
  }
}
