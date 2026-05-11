import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:table_calendar/table_calendar.dart';

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


  List<DateTime> selectedDates = [];
  DateTime focusedDay = DateTime.now();

  LatLng? selectedLocation;
  TimeOfDay? selectedTime;

  final TextEditingController noteController =
      TextEditingController();

  String status = "form";

  int get totalPrice =>
    widget.mentor.price *
    selectedDates.length;

  @override
  void initState() {
    super.initState();

    if (widget.isReschedule &&
        widget.oldData != null) {
      final data = widget.oldData!;

      selectedDates =
          List<DateTime>.from(data["dates"] ?? []);

      noteController.text = data["note"] ?? "";
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
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
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
                title: Text(
                  widget.mentor.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle:
                    Text(widget.mentor.category),
              ),
            ),

            const SizedBox(height: 20),

            /// ================= CALENDAR =================

            const Text(
              "Select Mentoring Dates",
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius:
                    BorderRadius.circular(20),
              ),
              child: TableCalendar(
                firstDay: DateTime.now(),
                lastDay: DateTime(2030),
                focusedDay: focusedDay,

                selectedDayPredicate: (day) {
                  return selectedDates.any(
                    (selectedDay) =>
                        isSameDay(
                            selectedDay, day),
                  );
                },

                onDaySelected:
                    (selectedDay, focusedDay) {
                  setState(() {
                    this.focusedDay =
                        focusedDay;

                    final exists =
                        selectedDates.any(
                      (d) => isSameDay(
                          d, selectedDay),
                    );

                    if (exists) {
                      selectedDates.removeWhere(
                        (d) => isSameDay(
                            d, selectedDay),
                      );
                    } else {
                      selectedDates
                          .add(selectedDay);
                    }
                  });
                },

                calendarStyle: CalendarStyle(
                  todayDecoration:
                      BoxDecoration(
                    color:
                        primary.withValues(alpha:0.4),
                    shape: BoxShape.circle,
                  ),

                  selectedDecoration:
                      BoxDecoration(
                    color: primary,
                    shape: BoxShape.circle,
                  ),
                ),

                headerStyle:
                    const HeaderStyle(
                  formatButtonVisible: false,
                  titleCentered: true,
                ),
              ),
            ),

            const SizedBox(height: 15),

            if (selectedDates.isNotEmpty)
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children:
                    selectedDates.map((date) {
                  return Chip(
                    backgroundColor:
                        primary.withValues(alpha:0.1),
                    label: Text(
                      "${date.day}/${date.month}/${date.year}",
                    ),
                    deleteIcon: const Icon(
                      Icons.close,
                      size: 18,
                    ),
                    onDeleted: () {
                      setState(() {
                        selectedDates
                            .remove(date);
                      });
                    },
                  );
                }).toList(),
              ),

            const SizedBox(height: 20),

            /// ================= TIME =================

            _card(
              child: ListTile(
                leading:
                    const Icon(Icons.access_time),

                title: Text(
                  selectedTime == null
                      ? "Select Session Time"
                      : "Time: ${selectedTime!.format(context)}",
                ),

                onTap: () async {
                  final time =
                      await showTimePicker(
                    context: context,
                    initialTime:
                        selectedTime ??
                            TimeOfDay.now(),
                  );

                  if (time != null) {
                    setState(() {
                      selectedTime = time;
                    });
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
                    setState(() {
                      selectedLocation =
                          result;
                    });
                  }
                },
              ),
            ),

            const SizedBox(height: 10),

            _input(
              "Note (optional)",
              noteController,
            ),

            const SizedBox(height: 15),

            /// ================= PRICE =================

            _card(
              child: Padding(
                padding:
                    const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [

                    const Text(
                      "Price Detail",
                      style: TextStyle(
                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 8),

                    Text(
                      "Rp ${widget.mentor.price} x ${selectedDates.length} session",
                    ),

                    const SizedBox(height: 10),

                    const Divider(),

                    Row(
                      mainAxisAlignment:
                          MainAxisAlignment
                              .spaceBetween,
                      children: [

                        const Text(
                          "Total Price",
                        ),

                        Text(
                          "Rp $totalPrice",
                          style: TextStyle(
                            fontWeight:
                                FontWeight.bold,
                            color: primary,
                            fontSize: 18,
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ),

            const SizedBox(height: 25),

            /// ================= BUTTON =================

            ElevatedButton(
              style:
                  ElevatedButton.styleFrom(
                backgroundColor: primary,
                minimumSize:
                    const Size.fromHeight(55),
                shape:
                    RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(
                          15),
                ),
              ),

              onPressed: () {
                if (selectedDates
                        .isNotEmpty &&
                    selectedTime != null &&
                    selectedLocation != null) {

                  setState(() {
                    status = "review";
                  });

                } else {

                  ScaffoldMessenger.of(context)
                      .showSnackBar(
                    const SnackBar(
                      content: Text(
                        "Please complete all data",
                      ),
                    ),
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
                      FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// ================= REVIEW =================

  Widget _buildReview() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),

      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [

          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),

            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  primary.withValues(alpha:0.9),
                  primary.withValues(alpha:0.7),
                ],
              ),
              borderRadius:
                  BorderRadius.circular(20),
            ),

            child: const Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [

                Text(
                  "Booking Summary",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight:
                        FontWeight.bold,
                    color: Colors.white,
                  ),
                ),

                SizedBox(height: 4),

                Text(
                  "Review your booking",
                  style: TextStyle(
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius:
                  BorderRadius.circular(20),
            ),

            child: Padding(
              padding:
                  const EdgeInsets.all(18),

              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [

                  Row(
                    children: [

                      CircleAvatar(
                        radius: 26,
                        backgroundColor:
                            primary.withValues(alpha:0.1),
                        child: Icon(
                          Icons.person,
                          color: primary,
                        ),
                      ),

                      const SizedBox(width: 12),

                      Column(
                        crossAxisAlignment:
                            CrossAxisAlignment
                                .start,
                        children: [

                          Text(
                            widget.mentor.name,
                            style:
                                const TextStyle(
                              fontWeight:
                                  FontWeight
                                      .bold,
                              fontSize: 16,
                            ),
                          ),

                          Text(
                            widget
                                .mentor.category,
                            style:
                                const TextStyle(
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      )
                    ],
                  ),

                  const SizedBox(height: 20),

                  const Divider(),

                  _summaryItem(
                    Icons.calendar_month,
                    "Selected Dates",
                    "${selectedDates.length} Dates",
                  ),

                  _summaryItem(
                    Icons.schedule,
                    "Time",
                    selectedTime != null
                        ? selectedTime!
                            .format(context)
                        : "-",
                  ),

                  _summaryItem(
                    Icons.location_on,
                    "Location",
                    selectedLocation ==
                            null
                        ? "-"
                        : "Selected ✔",
                  ),

                  if (noteController
                      .text.isNotEmpty)
                    _summaryItem(
                      Icons.note,
                      "Note",
                      noteController.text,
                    ),

                  const SizedBox(height: 15),

                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: selectedDates
                        .map((date) {
                      return Container(
                        padding:
                            const EdgeInsets
                                .symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),

                        decoration:
                            BoxDecoration(
                          color: primary.withValues(alpha:0.08),
                          borderRadius:
                              BorderRadius
                                  .circular(
                                      12),
                        ),

                        child: Text(
                          "${date.day}/${date.month}/${date.year}",

                          style: TextStyle(
                            color: primary,
                            fontWeight:
                                FontWeight
                                    .w600,
                          ),
                        ),
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 20),

                  Container(
                    padding:
                        const EdgeInsets.all(
                            14),

                    decoration: BoxDecoration(
                      color:
                          primary.withValues(alpha:0.05),

                      borderRadius:
                          BorderRadius
                              .circular(15),
                    ),

                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment
                              .start,

                      children: [

                        const Text(
                          "Price Detail",
                          style: TextStyle(
                            fontWeight:
                                FontWeight
                                    .bold,
                          ),
                        ),

                        const SizedBox(
                            height: 6),

                        Text(
                          "Rp ${widget.mentor.price} x ${selectedDates.length} session",
                        ),

                        const SizedBox(
                            height: 12),

                        Row(
                          mainAxisAlignment:
                              MainAxisAlignment
                                  .spaceBetween,

                          children: [

                            const Text(
                              "Total Price",
                              style:
                                  TextStyle(
                                fontWeight:
                                    FontWeight
                                        .bold,
                              ),
                            ),

                            Text(
                              "Rp $totalPrice",

                              style: TextStyle(
                                fontWeight:
                                    FontWeight
                                        .bold,
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

          ElevatedButton(
            style:
                ElevatedButton.styleFrom(
              backgroundColor: primary,
              minimumSize:
                  const Size.fromHeight(55),
            ),

            onPressed: () {
              setState(() {
                status = "pending";
              });
            },

            child: const Text(
              "Submit Booking",

              style: TextStyle(
                color: Colors.white,
                fontWeight:
                    FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// ================= SUMMARY ITEM =================

  Widget _summaryItem(
    IconData icon,
    String title,
    String value,
  ) {
    return Padding(
      padding:
          const EdgeInsets.symmetric(
              vertical: 8),

      child: Row(
        children: [

          Icon(
            icon,
            size: 18,
            color: Colors.grey,
          ),

          const SizedBox(width: 10),

          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                color: Colors.grey,
              ),
            ),
          ),

          Text(
            value,
            style: const TextStyle(
              fontWeight:
                  FontWeight.w600,
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
        mainAxisAlignment:
            MainAxisAlignment.center,
        children: [

          const Icon(
            Icons.schedule,
            size: 80,
            color: Colors.orange,
          ),

          const SizedBox(height: 20),

          const Text(
            "Booking Submitted",

            style: TextStyle(
              fontSize: 18,
              fontWeight:
                  FontWeight.bold,
            ),
          ),

          const SizedBox(height: 10),

          const Text(
            "Your booking request has been sent.\nPlease wait for mentor approval.",

            textAlign: TextAlign.center,

            style: TextStyle(
              color: Colors.grey,
            ),
          ),

          const SizedBox(height: 30),

          ElevatedButton(
            style:
                ElevatedButton.styleFrom(
              backgroundColor: primary,
              minimumSize:
                  const Size.fromHeight(50),
            ),

            onPressed: () {
              Navigator.pop(context);
            },

            child: const Text(
              "Back to Home",

              style: TextStyle(
                color: Colors.white,
              ),
            ),
          )
        ],
      ),
    );
  }

  /// ================= UI =================

  Widget _card({
    required Widget child,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(15),
      ),
      child: child,
    );
  }

  Widget _input(
    String hint,
    TextEditingController controller,
  ) {
    return Container(
      padding:
          const EdgeInsets.symmetric(
              horizontal: 12),

      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(15),
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