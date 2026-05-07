import 'package:flutter/material.dart';
// --- TAMBAHAN IMPORT CHERRY TOAST ---
import 'package:cherry_toast/cherry_toast.dart';
import 'package:cherry_toast/resources/arrays.dart';

class ManageSlotPage extends StatefulWidget {
  const ManageSlotPage({super.key});

  @override
  State<ManageSlotPage> createState() => _ManageSlotPageState();
}

class _ManageSlotPageState extends State<ManageSlotPage> {
  final Color primaryColor = const Color(0xFF5B62CC);
  final Color backgroundColor = const Color(0xFFF4F6FA);

  // Palet Pastel untuk tiap hari
  final List<Color> dayColors = [
    const Color(0xFF4A90E2), // Mon - Blue
    const Color(0xFFE24A7C), // Tue - Pink
    const Color(0xFF9013FE), // Wed - Purple
    const Color(0xFFF5B3CE), // Thu - Pastel Pink
    const Color(0xFFA7C7E7), // Fri - Sky Blue
    const Color(0xFFCDB4DB), // Sat - Lavender
    const Color(0xFFF2A65A), // Sun - Peach
  ];

  Map<String, List<Map<String, TimeOfDay>>> availabilityWindows = {
    "Monday": [],
    "Tuesday": [],
    "Wednesday": [],
    "Thursday": [],
    "Friday": [],
    "Saturday": [],
    "Sunday": [],
  };

  int _toMinutes(TimeOfDay time) => time.hour * 60 + time.minute;

  String _formatTime(TimeOfDay time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return "$hour:$minute";
  }

  // --- LOGIKA VALIDASI & INPUT JAM ---
  Future<void> _pickTimeRange(String day, Color color) async {
    TimeOfDay? start = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 9, minute: 0),
    );
    if (start == null) return;
    TimeOfDay? end = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 17, minute: 0),
    );
    if (end == null) return;

    int newStart = _toMinutes(start);
    int newEnd = _toMinutes(end);

    if (newEnd <= newStart) {
      // PERUBAHAN: Notifikasi Error Cherry Toast
      CherryToast.error(
        title: const Text(
          "Invalid Time",
          style: TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.bold),
        ),
        description: const Text(
          "End time must be after start time.",
          style: TextStyle(fontFamily: 'Nunito'),
        ),
        animationType: AnimationType.fromTop,
        toastPosition: Position.top,
        autoDismiss: true,
      ).show(context);
      return;
    }

    bool isOverlapping = false;
    for (var existingRange in availabilityWindows[day]!) {
      int exStart = _toMinutes(existingRange['start']!);
      int exEnd = _toMinutes(existingRange['end']!);
      if (newStart < exEnd && newEnd > exStart) {
        isOverlapping = true;
        break;
      }
    }

    if (isOverlapping) {
      // PERUBAHAN: Notifikasi Warning Cherry Toast
      CherryToast.warning(
        title: const Text(
          "Overlap Detected",
          style: TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.bold),
        ),
        description: const Text(
          "This time range overlaps with an existing slot!",
          style: TextStyle(fontFamily: 'Nunito'),
        ),
        animationType: AnimationType.fromTop,
        toastPosition: Position.top,
        autoDismiss: true,
      ).show(context);
      return;
    }

    setState(() {
      availabilityWindows[day]!.add({"start": start, "end": end});
      availabilityWindows[day]!.sort(
        (a, b) => _toMinutes(a['start']!).compareTo(_toMinutes(b['start']!)),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: const Text(
          "Manage Availability",
          style: TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.w900),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.black87,
      ),
      body: Column(
        children: [
          // --- GUIDELINE CARD ---
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [primaryColor.withOpacity(0.8), primaryColor],
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: primaryColor.withOpacity(0.3),
                  blurRadius: 15,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: const Row(
              children: [
                Icon(Icons.info_outline_rounded, color: Colors.white, size: 30),
                SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Guideline",
                        style: TextStyle(
                          fontFamily: 'Nunito',
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        "Set your regular available time windows. Overlapping ranges are automatically blocked for consistency.",
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

          // --- LIST HARI ---
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              itemCount: availabilityWindows.keys.length,
              itemBuilder: (context, index) {
                String day = availabilityWindows.keys.elementAt(index);
                List<Map<String, TimeOfDay>> ranges = availabilityWindows[day]!;
                Color accentColor = dayColors[index];

                return Container(
                  margin: const EdgeInsets.only(bottom: 15),
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
                  child: Column(
                    children: [
                      ListTile(
                        leading: CircleAvatar(
                          backgroundColor: accentColor.withOpacity(0.1),
                          child: Text(
                            day[0],
                            style: TextStyle(
                              color: accentColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        title: Text(
                          day,
                          style: const TextStyle(
                            fontFamily: 'Nunito',
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        trailing: IconButton(
                          icon: Icon(
                            Icons.add_circle_outline,
                            color: accentColor,
                          ),
                          onPressed: () => _pickTimeRange(day, accentColor),
                        ),
                      ),
                      if (ranges.isEmpty)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 15),
                          child: Text(
                            "No availability set for $day",
                            style: TextStyle(
                              fontFamily: 'Nunito',
                              color: Colors.grey[400],
                              fontSize: 12,
                            ),
                          ),
                        )
                      else
                        Padding(
                          padding: const EdgeInsets.only(
                            left: 15,
                            right: 15,
                            bottom: 15,
                          ),
                          child: Column(
                            children: ranges
                                .map(
                                  (range) => Container(
                                    margin: const EdgeInsets.only(bottom: 8),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 8,
                                    ),
                                    decoration: BoxDecoration(
                                      color: accentColor.withOpacity(0.05),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: accentColor.withOpacity(0.2),
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          "${_formatTime(range['start']!)} - ${_formatTime(range['end']!)}",
                                          style: const TextStyle(
                                            fontFamily: 'Nunito',
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        GestureDetector(
                                          onTap: () => setState(
                                            () => ranges.remove(range),
                                          ),
                                          child: const Icon(
                                            Icons.cancel_rounded,
                                            color: Colors.redAccent,
                                            size: 20,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                )
                                .toList(),
                          ),
                        ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildSaveButton(),
    );
  }

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
          backgroundColor: primaryColor,
          minimumSize: const Size.fromHeight(55),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          elevation: 0,
        ),
        onPressed: () {
          // PERUBAHAN: Notifikasi Success Cherry Toast & Navigator Pop otomatis
          CherryToast.success(
            title: const Text(
              "Success",
              style: TextStyle(
                fontFamily: 'Nunito',
                fontWeight: FontWeight.bold,
              ),
            ),
            description: const Text(
              "Availability schedule saved successfully!",
              style: TextStyle(fontFamily: 'Nunito'),
            ),
            animationType: AnimationType.fromTop,
            toastPosition: Position.top,
            autoDismiss: true,
            onToastClosed: () => Navigator.pop(context),
          ).show(context);
        },
        child: const Text(
          "Save Schedule Changes",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ),
    );
  }
}
