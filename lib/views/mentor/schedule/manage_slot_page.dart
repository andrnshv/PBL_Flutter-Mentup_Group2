import 'package:flutter/material.dart';
import 'package:cherry_toast/cherry_toast.dart';
import 'package:cherry_toast/resources/arrays.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../../controller/mentor/manage_slot_controller.dart';
import '../../../models/mentor/manage_slot_model.dart';

class ManageSlotPage extends StatefulWidget {
  const ManageSlotPage({super.key});

  @override
  State<ManageSlotPage> createState() => _ManageSlotPageState();
}

class _ManageSlotPageState extends State<ManageSlotPage> {
  final ManageSlotController _controller = ManageSlotController();

  static const Color _primary = Color(0xFF5B62CC);
  static const Color _bgColor = Color(0xFFF4F6FA);

  // ── Kalender ───────────────────────────────────────────
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay  = DateTime.now();
  DateTime _selectedDay = DateTime.now();

  // ── State lokal ────────────────────────────────────────
  // Slot yang sudah tersimpan di DB untuk tanggal terpilih
  List<ManageSlotModel> _savedSlots = [];

  // Slot baru yang belum disimpan (hanya ada di memory)
  // Map: startTime → endTime
  final List<Map<String, TimeOfDay>> _pendingSlots = [];

  // Tanggal yang punya slot di DB (untuk dot kalender)
  Set<DateTime> _slotDates = {};

  bool _isLoading    = false;
  bool _isSaving     = false;

  // ──────────────────────────────────────────────────────
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadSlotDates();
      _loadSlotsForDate(_selectedDay);
    });
  }

@override
void dispose() {
  super.dispose();
}

  // ── Fetch dot kalender ────────────────────────────────
  Future<void> _loadSlotDates() async {
    final dates = await _controller.fetchAllSlotDates();
    if (mounted) setState(() => _slotDates = dates);
  }

  // ── Fetch slot DB untuk tanggal dipilih ───────────────
  Future<void> _loadSlotsForDate(DateTime date) async {
    setState(() => _isLoading = true);
    final slots = await _controller.fetchSlotsForDate(date);
    if (mounted) {
      setState(() {
        _savedSlots   = slots;
        _pendingSlots.clear(); // reset pending saat ganti tanggal
        _isLoading    = false;
      });
    }
  }

  // ── Helpers waktu ─────────────────────────────────────
  int _toMinutes(TimeOfDay t) => t.hour * 60 + t.minute;

  String _formatTime(TimeOfDay t) =>
      '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

  String _formatDate(DateTime d) {
    const months = [
      'Jan','Feb','Mar','Apr','May','Jun',
      'Jul','Aug','Sep','Oct','Nov','Dec',
    ];
    return '${d.day} ${months[d.month - 1]} ${d.year}';
  }

  DateTime _normalize(DateTime d) => DateTime(d.year, d.month, d.day);

  // ── Semua time range yang sudah ada (DB + pending) ────
  List<_TimeRange> get _allRanges {
    final result = <_TimeRange>[];

    for (final s in _savedSlots) {
      final start = _parseTime(s.startTime);
      final end   = s.endTime != null ? _parseTime(s.endTime!) : null;
      if (start != null) result.add(_TimeRange(start: start, end: end, savedId: s.id));
    }

    for (final p in _pendingSlots) {
      result.add(_TimeRange(start: p['start']!, end: p['end']));
    }

    return result;
  }

  TimeOfDay? _parseTime(String timeStr) {
    // format: "HH:mm" atau "HH:mm:ss"
    final parts = timeStr.split(':');
    if (parts.length < 2) return null;
    return TimeOfDay(
      hour:   int.tryParse(parts[0]) ?? 0,
      minute: int.tryParse(parts[1]) ?? 0,
    );
  }

  // ── Pick time range & validasi ─────────────────────────
  Future<void> _pickTimeRange() async {
    final start = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 9, minute: 0),
    );
    if (start == null || !mounted) return;

    final end = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 10, minute: 0),
    );
    if (end == null || !mounted) return;

    final newStart = _toMinutes(start);
    final newEnd   = _toMinutes(end);

    // Validasi 1: end > start
    if (newEnd <= newStart) {
      _showToast('error', 'Invalid Time', 'End time must be after start time.');
      return;
    }

    // Validasi 2: minimal 1 jam
    if (newEnd - newStart < 60) {
      _showToast('warning', 'Duration Too Short',
          'Minimum session duration is 1 hour.');
      return;
    }

    // Validasi 3: overlap dengan DB + pending
    for (final r in _allRanges) {
      final exStart = _toMinutes(r.start);
      final exEnd   = r.end != null ? _toMinutes(r.end!) : exStart + 60;
      if (newStart < exEnd && newEnd > exStart) {
        _showToast('warning', 'Overlap Detected',
            'This time range overlaps with an existing slot!');
        return;
      }
    }

    // Tambah ke pending (belum disimpan ke DB)
    setState(() {
      _pendingSlots.add({'start': start, 'end': end});
      _pendingSlots.sort(
        (a, b) => _toMinutes(a['start']!).compareTo(_toMinutes(b['start']!)),
      );
    });
  }

  // ── Hapus slot DB ─────────────────────────────────────
  Future<void> _deleteSlot(ManageSlotModel slot) async {
    // Cegah hapus slot yang sudah di-booking
    if (slot.isBooked) {
      _showToast('warning', 'Cannot Delete',
          'This slot is already booked by a client.');
      return;
    }

    final error = await _controller.deleteSlot(slot.id);
    if (!mounted) return;

    if (error != null) {
      _showToast('error', 'Failed', error);
    } else {
      setState(() => _savedSlots.remove(slot));
      _loadSlotDates(); // refresh dot kalender
    }
  }

  // ── Hapus slot pending (belum disimpan) ──────────────
  void _removePending(Map<String, TimeOfDay> slot) {
    setState(() => _pendingSlots.remove(slot));
  }

  // ── Simpan semua pending slot ke DB ──────────────────
  Future<void> _saveAll() async {
    if (_pendingSlots.isEmpty) {
      _showToast('warning', 'Nothing to Save',
          'Add at least one new slot before saving.');
      return;
    }

    setState(() => _isSaving = true);

    final date = _normalize(_selectedDay);
    final errors = <String>[];

    for (final slot in _pendingSlots) {
      final err = await _controller.insertSlot(
        date:      date,
        startTime: _formatTime(slot['start']!),
        endTime:   _formatTime(slot['end']!),
      );
      if (err != null) errors.add(err);
    }

    if (!mounted) return;
    setState(() => _isSaving = false);

    if (errors.isNotEmpty) {
      _showToast('error', 'Save Failed', errors.first);
    } else {
    CherryToast.success(
      title: const Text(
        'Saved!',
        style: TextStyle(
          fontFamily: 'Nunito',
          fontWeight: FontWeight.bold,
        ),
      ),
      description: Text(
        '${_pendingSlots.length} slot saved successfully.',
        style: const TextStyle(fontFamily: 'Nunito'),
      ),
      animationType: AnimationType.fromTop,
      toastPosition: Position.top,
      autoDismiss: true,
      onToastClosed: () {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            Navigator.pop(context);
          }
        });
      },
    ).show(context);

      // Refresh data
      await _loadSlotsForDate(_selectedDay);
      await _loadSlotDates();
    }
  }

  // ── Toast helper ──────────────────────────────────────
  void _showToast(String type, String title, String desc) {
    final titleWidget = Text(title,
        style: const TextStyle(
            fontFamily: 'Nunito', fontWeight: FontWeight.bold));
    final descWidget = Text(desc,
        style: const TextStyle(fontFamily: 'Nunito'));
    const anim = AnimationType.fromTop;
    const pos  = Position.top;

    switch (type) {
      case 'error':
        CherryToast.error(
          title: titleWidget, description: descWidget,
          animationType: anim, toastPosition: pos, autoDismiss: true,
        ).show(context);
      case 'warning':
        CherryToast.warning(
          title: titleWidget, description: descWidget,
          animationType: anim, toastPosition: pos, autoDismiss: true,
        ).show(context);
      default:
        CherryToast.success(
          title: titleWidget, description: descWidget,
          animationType: anim, toastPosition: pos, autoDismiss: true,
        ).show(context);
    }
  }

  // ──────────────────────────────────────────────────────
  // BUILD
  // ──────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgColor,
      appBar: AppBar(
        title: const Text('Manage Availability',
            style: TextStyle(
                fontFamily: 'Nunito', fontWeight: FontWeight.w900)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.black87,
      ),
      body: Column(
        children: [
          // ── Guideline card ─────────────────────────────
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF7E7BB9), _primary],
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: _primary.withOpacity(0.3),
                  blurRadius: 15,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: const Row(
              children: [
                Icon(Icons.info_outline_rounded,
                    color: Colors.white, size: 30),
                SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Guideline',
                          style: TextStyle(
                            fontFamily: 'Nunito',
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          )),
                      SizedBox(height: 4),
                      Text(
                        'Select a date, add time slots, then tap Save. '
                        'Booked slots cannot be deleted.',
                        style: TextStyle(
                          fontFamily: 'Nunito',
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // ── Kalender + slot list ───────────────────────
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(
                  horizontal: 20, vertical: 10),
              physics: const BouncingScrollPhysics(),
              children: [
                _buildCalendar(),
                const SizedBox(height: 25),
                _buildSlotHeader(),
                const SizedBox(height: 10),
                _buildSlotList(),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildSaveButton(),
    );
  }

  // ── Kalender ──────────────────────────────────────────
  Widget _buildCalendar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
          ),
        ],
      ),
      padding: const EdgeInsets.all(10),
      child: TableCalendar(
        firstDay: DateTime.now(),
        lastDay: DateTime.now().add(const Duration(days: 365)),
        focusedDay: _focusedDay,
        calendarFormat: _calendarFormat,
        selectedDayPredicate: (d) => isSameDay(_selectedDay, d),

        // Dot dari DB + pending lokal
        eventLoader: (day) {
          final norm = _normalize(day);
          // Dot biru jika ada di DB
          if (_slotDates.contains(norm)) return [true];
          // Dot orange jika ada pending di hari itu
          if (isSameDay(day, _selectedDay) && _pendingSlots.isNotEmpty) {
            return [true];
          }
          return [];
        },

        onDaySelected: (selected, focused) {
          setState(() {
            _selectedDay = selected;
            _focusedDay  = focused;
          });
          _loadSlotsForDate(selected);
        },
        onFormatChanged: (f) => setState(() => _calendarFormat = f),

        calendarBuilders: CalendarBuilders(
          markerBuilder: (ctx, day, events) {
            if (events.isEmpty) return const SizedBox();
            final isPending = isSameDay(day, _selectedDay) &&
                _pendingSlots.isNotEmpty;
            return Positioned(
              bottom: 4,
              child: Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  color: isPending ? Colors.orange : _primary,
                  shape: BoxShape.circle,
                ),
              ),
            );
          },
        ),

        calendarStyle: CalendarStyle(
          selectedDecoration: const BoxDecoration(
            color: _primary, shape: BoxShape.circle,
          ),
          todayDecoration: BoxDecoration(
            color: _primary.withOpacity(0.15),
            shape: BoxShape.circle,
          ),
          todayTextStyle: const TextStyle(
            color: _primary, fontWeight: FontWeight.bold,
          ),
        ),
        headerStyle: const HeaderStyle(
          formatButtonVisible: false,
          titleCentered: true,
          titleTextStyle: TextStyle(
            fontFamily: 'Nunito', fontWeight: FontWeight.bold, fontSize: 16,
          ),
          leftChevronIcon: Icon(
              Icons.chevron_left_rounded, color: Colors.black87),
          rightChevronIcon: Icon(
              Icons.chevron_right_rounded, color: Colors.black87),
        ),
      ),
    );
  }

  // ── Header slot ───────────────────────────────────────
  Widget _buildSlotHeader() {
    final pendingCount = _pendingSlots.length;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Slots for ${_formatDate(_selectedDay)}',
              style: const TextStyle(
                fontFamily: 'Nunito',
                fontSize: 18,
                fontWeight: FontWeight.w900,
              ),
            ),
            if (pendingCount > 0)
              Text(
                '$pendingCount unsaved slot${pendingCount > 1 ? 's' : ''}',
                style: const TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 12,
                  color: Colors.orange,
                  fontWeight: FontWeight.bold,
                ),
              ),
          ],
        ),
        IconButton(
          icon: const Icon(Icons.add_circle, color: _primary, size: 30),
          onPressed: _pickTimeRange,
        ),
      ],
    );
  }

  // ── Slot list ─────────────────────────────────────────
  Widget _buildSlotList() {
    if (_isLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(30),
          child: CircularProgressIndicator(color: _primary),
        ),
      );
    }

    if (_savedSlots.isEmpty && _pendingSlots.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(25),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.grey.withOpacity(0.2)),
        ),
        child: Column(
          children: [
            Icon(Icons.event_busy_rounded, color: Colors.grey[400], size: 40),
            const SizedBox(height: 10),
            Text(
              'No slots for this date.',
              style: TextStyle(
                fontFamily: 'Nunito',
                color: Colors.grey[500],
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              'Tap + to add a new slot.',
              style: TextStyle(
                fontFamily: 'Nunito', fontSize: 12, color: Colors.grey[400],
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        // ── Slot tersimpan di DB ───────────────────────
        ..._savedSlots.map((slot) {
          final start = _parseTime(slot.startTime);
          final end   = slot.endTime != null
              ? _parseTime(slot.endTime!)
              : null;
          final timeLabel = end != null
              ? '${_formatTime(start!)} - ${_formatTime(end)}'
              : _formatTime(start!);

          return _slotTile(
            timeLabel: timeLabel,
            isBooked:  slot.isBooked,
            badge:     slot.isBooked ? slot.bookingStatus : null,
            onDelete:  () => _deleteSlot(slot),
          );
        }),

        // ── Slot pending (belum disimpan) ──────────────
        ..._pendingSlots.map((p) {
          return _slotTile(
            timeLabel: '${_formatTime(p['start']!)} - ${_formatTime(p['end']!)}',
            isPending: true,
            onDelete:  () => _removePending(p),
          );
        }),
      ],
    );
  }

  Widget _slotTile({
    required String timeLabel,
    bool isBooked   = false,
    bool isPending  = false,
    String? badge,
    required VoidCallback onDelete,
  }) {
    Color borderColor = _primary.withOpacity(0.2);
    Color bgColor     = _primary.withOpacity(0.05);

    if (isPending) {
      borderColor = Colors.orange.withOpacity(0.4);
      bgColor     = Colors.orange.withOpacity(0.05);
    } else if (isBooked) {
      borderColor = Colors.green.withOpacity(0.3);
      bgColor     = Colors.green.withOpacity(0.05);
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(Icons.access_time_filled_rounded,
                  color: isPending
                      ? Colors.orange
                      : isBooked
                          ? Colors.green
                          : _primary,
                  size: 20),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    timeLabel,
                    style: const TextStyle(
                      fontFamily: 'Nunito',
                      fontWeight: FontWeight.w900,
                      fontSize: 16,
                      color: Colors.black87,
                    ),
                  ),
                  // Badge status
                  if (isPending)
                    const Text('Unsaved',
                        style: TextStyle(
                          fontFamily: 'Nunito',
                          fontSize: 11,
                          color: Colors.orange,
                          fontWeight: FontWeight.bold,
                        ))
                  else if (badge != null)
                    Text(badge,
                        style: TextStyle(
                          fontFamily: 'Nunito',
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: _badgeColor(badge),
                        )),
                ],
              ),
            ],
          ),
          // Tombol hapus — disabled jika sudah booked
          GestureDetector(
            onTap: isBooked ? null : onDelete,
            child: Icon(
              Icons.cancel_rounded,
              color: isBooked ? Colors.grey[300] : Colors.redAccent,
              size: 24,
            ),
          ),
        ],
      ),
    );
  }

  Color _badgeColor(String status) {
    switch (status) {
      case 'Accepted': return Colors.green;
      case 'Pending':  return Colors.orange;
      case 'Rejected': return Colors.red;
      case 'Done':     return Colors.blue;
      default:         return Colors.grey;
    }
  }

  // ── Save button ───────────────────────────────────────
  Widget _buildSaveButton() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: _pendingSlots.isEmpty
              ? Colors.grey[300]
              : _primary,
          minimumSize: const Size.fromHeight(55),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15)),
          elevation: 0,
        ),
        onPressed: _isSaving || _pendingSlots.isEmpty ? null : _saveAll,
        child: _isSaving
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                    color: Colors.white, strokeWidth: 2.5),
              )
            : Text(
                _pendingSlots.isEmpty
                    ? 'No Changes to Save'
                    : 'Save ${_pendingSlots.length} Slot${_pendingSlots.length > 1 ? 's' : ''}',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
      ),
    );
  }
}

// Helper class untuk range waktu (DB + pending dalam satu struktur)
class _TimeRange {
  final TimeOfDay  start;
  final TimeOfDay? end;
  final String?    savedId; // null jika pending

  _TimeRange({required this.start, this.end, this.savedId});
}