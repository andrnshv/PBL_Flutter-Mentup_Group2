import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../../models/mentor_model.dart';
import '../map/map_picker_page.dart';

class BookingPage extends StatefulWidget {
  final MentorModel mentor;
  final bool isReschedule;
  final Map<String, dynamic>? oldData;

  const BookingPage({
    super.key,
    required this.mentor,
    this.isReschedule = false,
    this.oldData,
  });

  @override
  State<BookingPage> createState() => _BookingPageState();
}

class _BookingPageState extends State<BookingPage> {
  final Color primary = const Color(0xFF6C63FF);

  int selectedMonth = 1;
  int selectedHours = 1;
  int sessionPerWeek = 1;

  DateTime? selectedDate;
  LatLng? selectedLocation;
  TimeOfDay? selectedTime;

  final TextEditingController noteController = TextEditingController();

  String status = "form";
  List<String> selectedDays = [];

  final List<String> days = [
    "Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"
  ];

  int get totalPrice =>
      widget.mentor.price *
      selectedHours *
      sessionPerWeek *
      selectedMonth;

  @override
  void initState() {
    super.initState();

    if (widget.isReschedule && widget.oldData != null) {
      final data = widget.oldData!;
      selectedDate = data["dateObject"];
      selectedDays = List<String>.from(data["days"] ?? []);
      selectedHours = data["hours"] ?? 1;
      selectedMonth = data["months"] ?? 1;
      noteController.text = data["note"] ?? "";
      sessionPerWeek =
          selectedDays.isEmpty ? 1 : selectedDays.length;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FA),
      appBar: AppBar(
        title: Text(
          widget.isReschedule
              ? "Reschedule Session"
              : "Booking Mentor",
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: _buildContent(),
    );
  }

  Widget _buildContent() {
    switch (status) {
      case "review":
        return _buildReview();
      case "pending":
        return _buildWaiting();
      default:
        return _buildForm();
    }
  }

  /// ================= FORM =================
  Widget _buildForm() {
    return SafeArea(
      child: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: ConstrainedBox(
              constraints:
                  BoxConstraints(minHeight: constraints.maxHeight),
              child: IntrinsicHeight(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [

                    /// ================= MENTOR =================
                    _card(
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundImage:
                              AssetImage(widget.mentor.image),
                        ),
                        title: Text(widget.mentor.name,
                            style: const TextStyle(
                                fontWeight: FontWeight.bold)),
                        subtitle:
                            Text(widget.mentor.category),
                      ),
                    ),

                  const SizedBox(height: 20),

                    /// ================= HOURS =================
                    const Text("Session Duration (Hours)",
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 10),

                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: List.generate(4, (index) {
                          final hour = index + 1;
                          final isSelected =
                              selectedHours == hour;

                          return GestureDetector(
                            onTap: widget.isReschedule
                                ? null
                                : () => setState(() =>
                                    selectedHours = hour),
                            child: Container(
                              width: 70,
                              margin:
                                  const EdgeInsets.only(right: 8),
                              padding:
                                  const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? primary
                                    : Colors.white,
                                borderRadius:
                                    BorderRadius.circular(12),
                                border:
                                    Border.all(color: primary),
                              ),
                              child: Center(
                                child: Text("$hour h",
                                    style: TextStyle(
                                        color: isSelected
                                            ? Colors.white
                                            : primary)),
                              ),
                            ),
                          );
                        }),
                      ),
                    ),

                    const SizedBox(height: 20),

                    /// ================= SESSION PER WEEK =================
                    const Text("Sessions per Week",
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 10),

                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: List.generate(3, (index) {
                          final value = index + 1;
                          final isSelected =
                              sessionPerWeek == value;

                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                sessionPerWeek = value;
                                if (selectedDays.length >
                                    sessionPerWeek) {
                                  selectedDays =
                                      selectedDays.sublist(
                                          0, sessionPerWeek);
                                }
                              });
                            },
                            child: Container(
                              width: 70,
                              margin:
                                  const EdgeInsets.only(right: 8),
                              padding:
                                  const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? primary
                                    : Colors.white,
                                borderRadius:
                                    BorderRadius.circular(12),
                                border:
                                    Border.all(color: primary),
                              ),
                              child: Center(
                                child: Text("$value x",
                                    style: TextStyle(
                                        color: isSelected
                                            ? Colors.white
                                            : primary,
                                        fontWeight:
                                            FontWeight.bold)),
                              ),
                            ),
                          );
                        }),
                      ),
                    ),

                    const SizedBox(height: 5),
                    Text("Choose $sessionPerWeek day(s)",
                        style: const TextStyle(color: Colors.grey)),

                    const SizedBox(height: 15),

                    /// ================= DAYS =================
                    const Text("Select Days",
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 10),

                    Wrap(
                      spacing: 8,
                      children: days.map((day) {
                        final isSelected =
                            selectedDays.contains(day);

                        return ChoiceChip(
                          label: Text(day),
                          selected: isSelected,
                          selectedColor: primary,
                          onSelected: (_) {
                            setState(() {
                              if (isSelected) {
                                selectedDays.remove(day);
                              } else {
                                if (selectedDays.length <
                                    sessionPerWeek) {
                                  selectedDays.add(day);
                                } else {
                                  ScaffoldMessenger.of(context)
                                      .showSnackBar(
                                    SnackBar(
                                      content: Text(
                                          "Max $sessionPerWeek days"),
                                    ),
                                  );
                                }
                              }
                            });
                          },
                          labelStyle: TextStyle(
                              color: isSelected
                                  ? Colors.white
                                  : Colors.black),
                        );
                      }).toList(),
                    ),

                    const SizedBox(height: 20),

                    /// ================= DATE =================
                    _card(
                      child: ListTile(
                        leading:
                            const Icon(Icons.calendar_today),
                        title: Text(
                          selectedDate == null
                              ? "Select First Session Date"
                              : "Start: ${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}",
                        ),
                        subtitle: selectedDays.isNotEmpty
                            ? Text(
                                "Repeat on: ${selectedDays.join(", ")}")
                            : null,
                        onTap: () async {
                          final date = await showDatePicker(
                            context: context,
                            initialDate:
                                selectedDate ?? DateTime.now(),
                            firstDate: DateTime.now(),
                            lastDate: DateTime(2030),
                          );
                          if (date != null) {
                            setState(() =>
                                selectedDate = date);
                          }
                        },
                      ),
                    ),

                  const SizedBox(height: 20),

                    /// ================= TIME PICKER =================
                    _card(
                      child: ListTile(
                        leading: const Icon(Icons.access_time),
                          title: Text(
                            selectedTime == null
                              ? "Select Session Time"
                              : "Time: ${selectedTime!.format(context)}",
                            ),
                          onTap: () async {
                        final time = await showTimePicker(
                          context: context,
                          initialTime: selectedTime ?? TimeOfDay.now(),
                        );

                        if (time != null) {
                          setState(() => selectedTime = time);
                        }
                      },
                    ),
                  ),

                    const SizedBox(height: 20),

                    /// ================= LOCATION =================
                    _card(
                      child: ListTile(
                        leading:
                            const Icon(Icons.location_on),
                        title: Text(
                          selectedLocation == null
                              ? "Select Location"
                              : "Location selected ✔",
                        ),
                        onTap: () async {
                          final result =
                              await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  const MapPickerPage(),
                            ),
                          );
                          if (result != null) {
                            setState(() =>
                                selectedLocation = result);
                          }
                        },
                      ),
                    ),

                    const SizedBox(height: 10),

                    _input("Note (optional)", noteController),

                    const SizedBox(height: 10),

                    /// ================= PRICE DETAIL =================
                    _card(
                      child: Padding(
                        padding:
                            const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            const Text("Price Detail",
                                style: TextStyle(
                                    fontWeight:
                                        FontWeight.bold)),
                            const SizedBox(height: 8),
                            Text(
                                "Rp ${widget.mentor.price} x $selectedHours jam x $sessionPerWeek sesi/minggu x $selectedMonth bulan"),
                            const SizedBox(height: 8),
                            const Divider(),
                            Row(
                              mainAxisAlignment:
                                  MainAxisAlignment
                                      .spaceBetween,
                              children: [
                                const Text("Total Price"),
                                Text(
                                  "Rp $totalPrice",
                                  style: TextStyle(
                                      fontWeight:
                                          FontWeight.bold,
                                      color: primary),
                                ),
                              ],
                            )
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primary,
                        minimumSize:
                            const Size.fromHeight(50),
                      ),
                      onPressed: () {
                        if (selectedDate != null &&
                            selectedTime != null &&
                            selectedLocation != null &&
                            selectedDays.length ==
                                sessionPerWeek) {
                          setState(
                              () => status = "review");
                        } else {
                          ScaffoldMessenger.of(context)
                              .showSnackBar(
                            const SnackBar(
                                content: Text("Please complete all data")),
                          );
                        }
                      },
                      child: Text(
                        widget.isReschedule
                            ? "Update Schedule"
                            : "Review Booking",
                        style: const TextStyle(
                            color: Colors.white,
                            fontWeight:
                                FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

/// ================= REVIEW =================
Widget _buildReview() {
  return Padding(
    padding: const EdgeInsets.all(16),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        /// ================= HEADER =================
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                primary.withOpacity(0.9),
                primary.withOpacity(0.7),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.receipt_long,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 12),
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Booking Summary",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    "Review your booking before checkout",
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        /// ================= MAIN CARD =================
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 10,
              )
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                /// ===== MENTOR =====
                Row(
                  children: [
                    CircleAvatar(
                      radius: 26,
                      backgroundColor: primary.withOpacity(0.1),
                      child: Icon(Icons.person, color: primary),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.mentor.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          widget.mentor.category,
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    )
                  ],
                ),

                const SizedBox(height: 20),
                const Divider(),

                /// ================= DETAIL =================
                _summaryItem(Icons.calendar_month, "Duration", "$selectedMonth Month(s)"),
                _summaryItem(Icons.access_time, "Session Duration", "$selectedHours Hour(s)"),
                _summaryItem(Icons.repeat, "Sessions / Week", "$sessionPerWeek x"),
                _summaryItem(Icons.date_range, "Days", selectedDays.join(", ")),
                _summaryItem(
                  Icons.play_arrow,
                  "Start Date",
                  selectedDate == null
                      ? "-"
                      : "${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}",
                ),
                _summaryItem(
                  Icons.schedule,
                  "Time",
                  selectedTime != null
                      ? selectedTime!.format(context)
                      : "-",
                ),
                _summaryItem(
                  Icons.location_on,
                  "Location",
                  selectedLocation == null ? "-" : "Selected ✔",
                ),

                if (noteController.text.isNotEmpty)
                  _summaryItem(Icons.note, "Note", noteController.text),

                const SizedBox(height: 20),

                /// ===== PRICE =====
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: primary.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Price Detail",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 6),

                      Text(
                        "Rp ${widget.mentor.price} x $selectedHours jam x $sessionPerWeek sesi/minggu x $selectedMonth bulan x 4 minggu",
                        style: const TextStyle(fontSize: 12),
                      ),

                      const SizedBox(height: 12),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "Total Price",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            "Rp $totalPrice",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              color: primary,
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 20),

        /// ================= BUTTON =================
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: primary,
            minimumSize: const Size.fromHeight(55),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
          ),
          onPressed: () {
            setState(() => status = "pending");
          },
          child: const Text(
            "Submit Booking",
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ),
      ],
    ),
  );
}

/// ================= SUMMARY ITEM =================
Widget _summaryItem(IconData icon, String title, String value) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 8),
    child: Row(
      children: [
        Icon(icon, size: 18, color: Colors.grey),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            title,
            style: const TextStyle(color: Colors.grey),
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    ),
  );
}

/// ================= WAITING =================
  Widget _buildWaiting() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.schedule,
              size: 80, color: Colors.orange),
          const SizedBox(height: 20),
          const Text(
            "Booking Submitted",
            style: TextStyle(
                fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          const Text(
            "Your booking request has been sent.\nPlease wait for mentor approval.",
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 30),

          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: primary,
              minimumSize: const Size.fromHeight(50),
            ),
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text(
              "Back to Home",
              style: TextStyle(color: Colors.white),
            ),
          )
        ],
      ),
    );
  }

  /// ================= UI =================
  Widget _card({required Widget child}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
      ),
      child: child,
    );
  }

  Widget _input(String hint, TextEditingController controller) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
      ),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          hintText: hint,
          border: InputBorder.none,
        ),
      ),
    );
  }
}