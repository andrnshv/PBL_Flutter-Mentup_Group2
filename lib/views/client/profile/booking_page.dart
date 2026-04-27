import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../../models/mentor_model.dart';
import '../map/map_picker_page.dart';

class BookingPage extends StatefulWidget {
  final MentorModel mentor;

  const BookingPage({super.key, required this.mentor});

  @override
  State<BookingPage> createState() => _BookingPageState();
}

class _BookingPageState extends State<BookingPage> {
  final Color primary = const Color(0xFF6C63FF);

  int selectedMonth = 1;
  int selectedHours = 1;

  DateTime? selectedDate;
  LatLng? selectedLocation;

  final TextEditingController noteController = TextEditingController();

  String status = "form"; // form | review | pending

  List<String> selectedDays = [];

  final List<String> days = [
    "Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"
  ];

  int get totalPrice =>
      widget.mentor.price * selectedHours * selectedMonth;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FA),
      appBar: AppBar(
        title: const Text("Booking Mentor"),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: _buildContent(),
      ),
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _card(
          child: ListTile(
            leading: CircleAvatar(
              backgroundImage: AssetImage(widget.mentor.image),
            ),
            title: Text(widget.mentor.name,
                style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text(widget.mentor.category),
          ),
        ),

        const SizedBox(height: 20),

        const Text("Duration (Month)",
            style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),

        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(6, (index) {
            final month = index + 1;
            final isSelected = selectedMonth == month;

            return GestureDetector(
              onTap: () => setState(() => selectedMonth = month),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isSelected ? primary : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: primary),
                ),
                child: Text("$month",
                    style: TextStyle(
                        color:
                            isSelected ? Colors.white : primary)),
              ),
            );
          }),
        ),

        const SizedBox(height: 20),

        const Text("Session Duration (Hours)",
            style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),

        Row(
          children: List.generate(4, (index) {
            final hour = index + 1;
            final isSelected = selectedHours == hour;

            return Expanded(
              child: GestureDetector(
                onTap: () => setState(() => selectedHours = hour),
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isSelected ? primary : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: primary),
                  ),
                  child: Center(
                    child: Text("$hour h",
                        style: TextStyle(
                            color: isSelected
                                ? Colors.white
                                : primary)),
                  ),
                ),
              ),
            );
          }),
        ),

        const SizedBox(height: 20),

        _card(
          child: ListTile(
            leading: const Icon(Icons.calendar_today),
            title: Text(
              selectedDate == null
                  ? "Select Start Date"
                  : "Start: ${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}",
            ),
            onTap: () async {
              final date = await showDatePicker(
                context: context,
                initialDate: DateTime.now(),
                firstDate: DateTime.now(),
                lastDate: DateTime(2030),
              );
              if (date != null) setState(() => selectedDate = date);
            },
          ),
        ),

        const SizedBox(height: 20),

        const Text("Select Days",
            style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),

        Wrap(
          spacing: 8,
          children: days.map((day) {
            final isSelected = selectedDays.contains(day);

            return ChoiceChip(
              label: Text(day),
              selected: isSelected,
              selectedColor: primary,
              onSelected: (_) {
                setState(() {
                  isSelected
                      ? selectedDays.remove(day)
                      : selectedDays.add(day);
                });
              },
              labelStyle: TextStyle(
                  color:
                      isSelected ? Colors.white : Colors.black),
            );
          }).toList(),
        ),

        const SizedBox(height: 20),

        _card(
          child: ListTile(
            leading: const Icon(Icons.location_on),
            title: Text(
              selectedLocation == null
                  ? "Select Location"
                  : "Location selected ✔",
            ),
            onTap: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const MapPickerPage(),
                ),
              );

              if (result != null) {
                setState(() => selectedLocation = result);
              }
            },
          ),
        ),

        const SizedBox(height: 10),

        _input("Note (optional)", noteController),

        const SizedBox(height: 10),

        _card(
          child: ListTile(
            title: const Text("Total Price"),
            trailing: Text("Rp $totalPrice",
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: primary)),
          ),
        ),

        const Spacer(),

        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: primary,
            minimumSize: const Size.fromHeight(50),
          ),
          onPressed: () {
            if (selectedDate != null &&
                selectedLocation != null &&
                selectedDays.isNotEmpty) {
              setState(() => status = "review");
            }
          },
          child: const Text(
            "Review Booking",
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        )
      ],
    );
  }

  /// ================= REVIEW =================
  Widget _buildReview() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Booking Summary",
            style:
                TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),

        const SizedBox(height: 20),

        _card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _summaryItem(
                Icons.person,
                "Mentor",
                widget.mentor.name,
                ),
                _summaryItem(
                Icons.calendar_month,
                "Duration",
                "$selectedMonth Month(s)",
                ),
                _summaryItem(
                Icons.access_time,
                "Session",
                "$selectedHours Hour(s)",
                ),
                _summaryItem(
                Icons.repeat,
                "Days",
                selectedDays.join(", "),
                ),
                _summaryItem(
                Icons.play_arrow,
                "Start Date",
                "${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}",
                ),

                const Divider(height: 30),

                ///Total
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Total Price",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
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
        ),

        const Spacer(),

        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: primary,
            minimumSize: const Size.fromHeight(50),
          ),
          onPressed: () {
            setState(() => status = "pending");
          },
          child: const Text(
            "Submit Booking",
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        )
      ],
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

  Widget _summaryItem(IconData icon, String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: primary),
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
}