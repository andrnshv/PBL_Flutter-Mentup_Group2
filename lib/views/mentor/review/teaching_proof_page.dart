import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cherry_toast/cherry_toast.dart';
import 'package:cherry_toast/resources/arrays.dart';
import 'package:image_picker/image_picker.dart';
import '../../../controller/mentor/teaching_proof_controller.dart';
import '../../../models/mentor/teaching_proof_model.dart';
import '../../../routes/app_routes.dart';

// ================================================================
//  TEACHING PROOF PAGE — MentUp
//  File: lib/views/mentor/review/teaching_proof_page.dart
//
//  Tampilan sama dengan desain awal. Data dari Supabase.
//
//  Tab Required         → booking confirmed (belum upload bukti)
//  Tab In Review        → awaiting_verification (menunggu client)
//  Tab Verified         → done / completed (sudah di-verify client)
//
//  Submit proof → upload foto ke Storage → status: awaiting_verification
// ================================================================

class TeachingProofPage extends StatefulWidget {
  const TeachingProofPage({super.key});

  @override
  State<TeachingProofPage> createState() => _TeachingProofPageState();
}

class _TeachingProofPageState extends State<TeachingProofPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final TeachingProofController _controller = TeachingProofController();

  String _searchQuery = '';
  bool _isAscending = true;
  String? _expandedId; // bookingId yang sedang dibuka
  File? _capturedImage; // foto yang dipilih untuk card yang expand
  bool _isLoading = true;
  bool _isSubmitting = false;

  final TextEditingController _summaryCtrl = TextEditingController();
  final ImagePicker _picker = ImagePicker();

  final Color primaryColor = const Color(0xFF5B62CC);
  final Color pastelPink = const Color(0xFFF5B3CE);
  final Color pastelBlue = const Color(0xFFA7C7E7);
  final Color pastelLavender = const Color(0xFFCDB4DB);

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _load();
  }

  Future<void> _load() async {
    setState(() => _isLoading = true);
    await _controller.fetchProofs(searchQuery: _searchQuery);
    if (mounted) setState(() => _isLoading = false);
  }

  List<TeachingProofModel> _sorted(List<TeachingProofModel> list) {
    final copy = [...list];
    copy.sort((a, b) => _isAscending
        ? a.dateLabel.compareTo(b.dateLabel)
        : b.dateLabel.compareTo(a.dateLabel));
    return copy;
  }

  @override
  void dispose() {
    _tabController.dispose();
    _summaryCtrl.dispose();
    super.dispose();
  }

  // ─────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      appBar: AppBar(
        toolbarHeight: 90,
        title: const Text(
          "Teaching Proof",
          style: TextStyle(
            fontFamily: 'Nunito',
            fontWeight: FontWeight.w900,
            fontSize: 24,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.black87,
      ),
      body: Column(
        children: [
          _buildTopTools(),
          _buildTabBar(),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : (_controller.errorMessage != null
                    ? _buildError()
                    : TabBarView(
                        controller: _tabController,
                        children: [
                          _buildList(
                              _sorted(_controller.requiredList), 'Required'),
                          _buildList(
                              _sorted(_controller.inReviewList), 'In Review'),
                          _buildList(
                              _sorted(_controller.verifiedList), 'Verified'),
                        ],
                      )),
          ),
        ],
      ),
    );
  }

  Widget _buildError() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.wifi_off_rounded, size: 50, color: Colors.grey[300]),
          const SizedBox(height: 12),
          Text(_controller.errorMessage ?? 'Error',
              style: TextStyle(color: Colors.grey[500])),
          const SizedBox(height: 12),
          ElevatedButton.icon(
            onPressed: _load,
            icon: const Icon(Icons.refresh),
            label: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────
  // TOP TOOLS (sama dengan desain awal)
  // ─────────────────────────────────────────────────────────
  Widget _buildTopTools() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 15),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 48,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: TextField(
                onChanged: (val) {
                  setState(() => _searchQuery = val);
                  _load();
                },
                decoration: InputDecoration(
                  hintText: "Search student...",
                  hintStyle: const TextStyle(
                      fontFamily: 'Nunito', color: Colors.grey, fontSize: 13),
                  prefixIcon: Icon(Icons.search, color: primaryColor, size: 20),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 0),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          GestureDetector(
            onTap: () => setState(() => _isAscending = !_isAscending),
            child: Container(
              height: 48,
              width: 48,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Icon(
                _isAscending ? Icons.sort_rounded : Icons.sort_by_alpha_rounded,
                color: primaryColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────
  // TAB BAR
  // ─────────────────────────────────────────────────────────
  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.black12, width: 1)),
      ),
      child: TabBar(
        controller: _tabController,
        indicatorColor: primaryColor,
        indicatorWeight: 3,
        labelColor: primaryColor,
        unselectedLabelColor: Colors.grey,
        labelStyle: const TextStyle(
            fontFamily: 'Nunito', fontWeight: FontWeight.w900, fontSize: 14),
        unselectedLabelStyle: const TextStyle(
            fontFamily: 'Nunito', fontWeight: FontWeight.w600, fontSize: 14),
        tabs: const [
          Tab(text: "Required"),
          Tab(text: "In Review"),
          Tab(text: "Verified"),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────
  // LIST PER TAB
  // ─────────────────────────────────────────────────────────
  Widget _buildList(List<TeachingProofModel> list, String tab) {
    if (list.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.assignment_turned_in_outlined,
                size: 60, color: Colors.grey[300]),
            const SizedBox(height: 15),
            Text("No sessions found",
                style: TextStyle(
                    fontFamily: 'Nunito',
                    color: Colors.grey[400],
                    fontWeight: FontWeight.bold)),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _load,
      child: ListView.builder(
        padding: const EdgeInsets.all(20),
        physics: const BouncingScrollPhysics(),
        itemCount: list.length,
        itemBuilder: (_, i) => _buildCard(list[i], tab),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────
  // CARD
  // ─────────────────────────────────────────────────────────
  Widget _buildCard(TeachingProofModel item, String tab) {
    final isExpanded = _expandedId == item.bookingId;
    final color = item.accentColor;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color:
              isExpanded ? primaryColor.withOpacity(0.3) : Colors.transparent,
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          ListTile(
            onTap: () {
              setState(() {
                _expandedId = isExpanded ? null : item.bookingId;
                _capturedImage = null;
                _summaryCtrl.text = item.sessionSummary ?? '';
              });
            },
            contentPadding: const EdgeInsets.all(16),
            leading: CircleAvatar(
              radius: 25,
              backgroundColor: color.withOpacity(0.2),
              backgroundImage: (item.clientPhotoUrl != null &&
                      item.clientPhotoUrl!.isNotEmpty)
                  ? NetworkImage(item.clientPhotoUrl!)
                  : null,
              child:
                  (item.clientPhotoUrl == null || item.clientPhotoUrl!.isEmpty)
                      ? Text(
                          item.clientInitial,
                          style: TextStyle(
                              color: color,
                              fontWeight: FontWeight.bold,
                              fontSize: 18),
                        )
                      : null,
            ),
            title: Text(
              item.clientName,
              style: const TextStyle(
                  fontFamily: 'Nunito',
                  fontWeight: FontWeight.w800,
                  fontSize: 16),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text(item.categoryName,
                    style: TextStyle(
                        fontFamily: 'Nunito',
                        color: primaryColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 12)),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.calendar_month,
                        size: 12, color: Colors.grey[400]),
                    const SizedBox(width: 4),
                    Text(
                      '${item.dateLabel} • ${item.timeLabel}',
                      style: TextStyle(
                          fontFamily: 'Nunito',
                          color: Colors.grey[600],
                          fontSize: 11),
                    ),
                  ],
                ),
              ],
            ),
            trailing: _statusChip(item),
          ),
          if (isExpanded) _buildExpansion(item, tab),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────
  // EXPANSION CONTENT
  // ─────────────────────────────────────────────────────────
  Widget _buildExpansion(TeachingProofModel item, String tab) {
    if (tab == 'Required') {
      return Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        child: Column(
          children: [
            const Divider(height: 30),
            _buildUploadZone(),
            const SizedBox(height: 15),
            _buildSummaryInput(),
            const SizedBox(height: 20),
            _buildSubmitButton(item),
          ],
        ),
      );
    } else {
      return _buildViewOnly(item, tab);
    }
  }

  // ── Upload zone ──
  Widget _buildUploadZone() {
    return GestureDetector(
      onTap: () async {
        final XFile? photo =
            await _picker.pickImage(source: ImageSource.gallery);
        if (photo != null) {
          setState(() => _capturedImage = File(photo.path));
        }
      },
      child: Container(
        height: 140,
        width: double.infinity,
        decoration: BoxDecoration(
          color: pastelBlue.withOpacity(0.1),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: pastelBlue.withOpacity(0.5), width: 1.5),
          image: _capturedImage != null
              ? DecorationImage(
                  image: FileImage(_capturedImage!), fit: BoxFit.cover)
              : null,
        ),
        child: _capturedImage == null
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.add_photo_alternate_rounded,
                      color: primaryColor, size: 30),
                  const SizedBox(height: 8),
                  const Text("Upload Session Photo",
                      style: TextStyle(
                          fontFamily: 'Nunito',
                          fontSize: 13,
                          fontWeight: FontWeight.bold)),
                  Text("Tap to open gallery",
                      style: TextStyle(
                          fontFamily: 'Nunito',
                          fontSize: 10,
                          color: Colors.grey[500])),
                ],
              )
            : Align(
                alignment: Alignment.topRight,
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: CircleAvatar(
                    backgroundColor: Colors.white,
                    radius: 16,
                    child: IconButton(
                      icon: const Icon(Icons.close_rounded,
                          color: Colors.redAccent, size: 16),
                      onPressed: () => setState(() => _capturedImage = null),
                    ),
                  ),
                ),
              ),
      ),
    );
  }

  // ── Summary input ──
  Widget _buildSummaryInput() {
    return TextField(
      controller: _summaryCtrl,
      maxLines: 2,
      style: const TextStyle(fontFamily: 'Nunito', fontSize: 13),
      decoration: InputDecoration(
        hintText: "What was discussed? (Optional)",
        hintStyle: TextStyle(color: Colors.grey[400]),
        filled: true,
        fillColor: const Color(0xFFF4F6FA),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  // ── Submit button ──
  Widget _buildSubmitButton(TeachingProofModel item) {
    return ElevatedButton(
      onPressed: _isSubmitting ? null : () => _handleSubmit(item),
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        minimumSize: const Size.fromHeight(50),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        elevation: 0,
      ),
      child: _isSubmitting
          ? const SizedBox(
              width: 22,
              height: 22,
              child: CircularProgressIndicator(
                  color: Colors.white, strokeWidth: 2))
          : const Text("Submit Teaching Proof",
              style:
                  TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
    );
  }

  // ── View only (In Review & Verified) ──
  Widget _buildViewOnly(TeachingProofModel item, String tab) {
    final isDone = tab == 'Verified';
    return Column(
      children: [
        // Foto proof kalau ada
        if (item.proofUrl != null && item.proofUrl!.isNotEmpty)
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.network(
                item.proofUrl!,
                height: 140,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  height: 80,
                  color: Colors.grey[100],
                  child: const Center(
                      child: Icon(Icons.broken_image, color: Colors.grey)),
                ),
              ),
            ),
          ),
        // Catatan sesi
        if (item.sessionSummary != null && item.sessionSummary!.isNotEmpty)
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(14),
              ),
              child: Text('"${item.sessionSummary!}"',
                  style: const TextStyle(
                      fontFamily: 'Nunito',
                      fontSize: 12,
                      fontStyle: FontStyle.italic,
                      color: Colors.black54)),
            ),
          ),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          margin: EdgeInsets.fromLTRB(20, 0, 20, isDone ? 10 : 20),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              Icon(
                isDone ? Icons.verified_rounded : Icons.hourglass_empty_rounded,
                color: isDone ? Colors.green : Colors.orange,
                size: 20,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  isDone
                      ? "Session verified. You've earned the fee!"
                      : "Waiting for client to verify your submission.",
                  style: const TextStyle(
                      fontFamily: 'Nunito',
                      fontSize: 12,
                      fontStyle: FontStyle.italic),
                ),
              ),
            ],
          ),
        ),
        if (isDone)
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            child: OutlinedButton.icon(
              onPressed: () => Navigator.pushNamed(
                context,
                AppRoutes.clientReviews,
                arguments: {'studentName': item.clientName},
              ),
              icon: const Icon(Icons.star_rounded, color: Colors.amber),
              label: Text("View Client Rating",
                  style: TextStyle(
                      fontFamily: 'Nunito',
                      fontWeight: FontWeight.bold,
                      color: primaryColor)),
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: primaryColor.withOpacity(0.4)),
                minimumSize: const Size.fromHeight(45),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
              ),
            ),
          ),
      ],
    );
  }

  // ─────────────────────────────────────────────────────────
  // SUBMIT HANDLER
  // ─────────────────────────────────────────────────────────
  Future<void> _handleSubmit(TeachingProofModel item) async {
    if (_capturedImage == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        CherryToast.error(
          title: const Text("Proof Required",
              style:
                  TextStyle(fontWeight: FontWeight.bold, fontFamily: 'Nunito')),
          description: const Text("You must attach a session photo!",
              style: TextStyle(fontFamily: 'Nunito')),
          animationType: AnimationType.fromTop,
          toastPosition: Position.top,
          autoDismiss: true,
        ).show(context);
      });
      return;
    }

    setState(() => _isSubmitting = true);

    final err = await _controller.submitProof(
      bookingId: item.bookingId,
      imageFile: _capturedImage!,
      summary:
          _summaryCtrl.text.trim().isEmpty ? null : _summaryCtrl.text.trim(),
    );

    if (!mounted) return;
    setState(() => _isSubmitting = false);

    if (err == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        CherryToast.success(
          title: const Text("Success",
              style:
                  TextStyle(fontWeight: FontWeight.bold, fontFamily: 'Nunito')),
          description: const Text(
              "Proof has been sent to client for verification.",
              style: TextStyle(fontFamily: 'Nunito')),
          animationType: AnimationType.fromTop,
          toastPosition: Position.top,
          autoDismiss: true,
        ).show(context);
      });

      // Refresh & tutup card
      Future.delayed(const Duration(milliseconds: 800), () {
        if (mounted) {
          setState(() {
            _expandedId = null;
            _capturedImage = null;
            _summaryCtrl.clear();
          });
          _load();
        }
      });
    } else {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        CherryToast.error(
          title: const Text("Gagal",
              style:
                  TextStyle(fontWeight: FontWeight.bold, fontFamily: 'Nunito')),
          description: Text(err, style: const TextStyle(fontFamily: 'Nunito')),
          animationType: AnimationType.fromTop,
          toastPosition: Position.top,
          autoDismiss: true,
        ).show(context);
      });
    }
  }

  // ─────────────────────────────────────────────────────────
  Widget _statusChip(TeachingProofModel item) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: item.statusChipColor.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        item.statusChipLabel,
        style: TextStyle(
            color: item.statusChipColor,
            fontSize: 10,
            fontWeight: FontWeight.bold),
      ),
    );
  }
}
