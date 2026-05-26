import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geocoding/geocoding.dart';

import '../../../controller/client/mentor_search_controller.dart';
import '../../../models/client/mentor_search_model.dart';
import '../profile/mentor_profile_page.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final MentorSearchController _controller = MentorSearchController();
  GoogleMapController? _mapController;

  Set<Marker> _mapMarkers = {};

  final currencyFormat = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  bool _isLoading = true;
  bool _isMapView = false;

  final Color primaryPurple = const Color(0xFF7E7BB9);
  final Color bgGray = const Color(0xFFF8F9FB);

  final LatLng _defaultCenter =
      const LatLng(-7.9425, 112.6131);

  @override
  void initState() {
    super.initState();
    _initData();
  }

  Future<void> _initData() async {
    await Future.wait<void>([
      _controller.fetchCategories(),
      _controller.fetchMentors(),
    ]);

    await _generateMarkersFromAddresses();

    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _generateMarkersFromAddresses() async {
    final Set<Marker> temporaryMarkers = {};

    for (final mentor in _controller.filteredMentors) {
      if (mentor.alamat == null || mentor.alamat!.isEmpty) continue;

      try {
        List<Location> locations =
            await locationFromAddress(mentor.alamat!);

        if (locations.isNotEmpty) {
          final targetLoc = locations.first;
          final latLng =
              LatLng(targetLoc.latitude, targetLoc.longitude);

          temporaryMarkers.add(
            Marker(
              markerId: MarkerId(mentor.userId),
              position: latLng,
              infoWindow: InfoWindow(
                title: mentor.namaLengkap,
                snippet: mentor.categoryName ?? 'Mentor',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          MentorProfilePage(
                            mentorId: mentor.userId,
                          ),
                    ),
                  );
                },
              ),
              icon: BitmapDescriptor.defaultMarkerWithHue(
                BitmapDescriptor.hueViolet,
              ),
            ),
          );
        }
      } catch (e) {
        debugPrint(
          "Failed to convert mentor address ${mentor.namaLengkap}: $e",
        );
      }
    }

    if (mounted) {
      setState(() {
        _mapMarkers = temporaryMarkers;
      });
    }
  }

  void _animateToSelectedCity(String city) {
    if (_mapController == null || !mounted) return;

    LatLng targetCoords = _defaultCenter;
    double zoomLevel = 12.0;

    if (city != 'All' &&
        MentorSearchController.cityCoordinates.containsKey(city)) {
      targetCoords =
          MentorSearchController.cityCoordinates[city]!;
      zoomLevel = 13.5;
    }

    try {
      _mapController!.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: targetCoords,
            zoom: zoomLevel,
          ),
        ),
      );
    } catch (e) {
      debugPrint("Failed to move camera: $e");
    }
  }

  void _openFilter() {
    int tempMaxPrice = _controller.maxPrice;
    String tempAlamat = _controller.selectedAlamat;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFFF8F1FB),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(30),
        ),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModal) {
            return Padding(
              padding: EdgeInsets.only(
                left: 24,
                right: 24,
                top: 18,
                bottom:
                    MediaQuery.of(context).viewInsets.bottom + 24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 50,
                      height: 5,
                      margin:
                          const EdgeInsets.only(bottom: 20),
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius:
                            BorderRadius.circular(20),
                      ),
                    ),
                  ),

                  Text(
                    "Filter Mentors",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      fontFamily: 'Nunito',
                      color: primaryPurple,
                    ),
                  ),

                  const SizedBox(height: 24),

                  Row(
                    mainAxisAlignment:
                        MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Max Price",
                        style: TextStyle(
                          fontFamily: 'Nunito',
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        currencyFormat
                            .format(tempMaxPrice),
                        style: TextStyle(
                          fontFamily: 'Nunito',
                          color: primaryPurple,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),

                  Slider(
                    value: tempMaxPrice.toDouble(),
                    min: 0,
                    max: 1000000,
                    divisions: 20,
                    activeColor: primaryPurple,
                    onChanged: (value) {
                      setModal(() {
                        tempMaxPrice = value.toInt();
                      });
                    },
                  ),

                  const SizedBox(height: 10),

                  const Text(
                    "Location",
                    style: TextStyle(
                      fontFamily: 'Nunito',
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 10),

                  Container(
                    width: double.infinity,
                    padding:
                        const EdgeInsets.symmetric(
                      horizontal: 14,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius:
                          BorderRadius.circular(12),
                      border: Border.all(
                        color: primaryPurple
                            .withOpacity(0.4),
                      ),
                    ),
                    child: DropdownButton<String>(
                      value: tempAlamat,
                      isExpanded: true,
                      underline: const SizedBox(),
                      items: _controller.uniqueAlamatList
                          .map((dom) {
                        return DropdownMenuItem(
                          value: dom,
                          child: Text(
                            dom,
                            overflow:
                                TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontFamily: 'Nunito',
                            ),
                          ),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setModal(() {
                          tempAlamat = value!;
                        });
                      },
                    ),
                  ),

                  const SizedBox(height: 24),

                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            setModal(() {
                              tempMaxPrice = 500000;
                              tempAlamat = 'All';
                            });
                          },
                          style:
                              OutlinedButton.styleFrom(
                            side: BorderSide(
                              color: primaryPurple,
                            ),
                            shape:
                                RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(
                                      12),
                            ),
                            padding:
                                const EdgeInsets.symmetric(
                              vertical: 15,
                            ),
                          ),
                          child: Text(
                            "Reset",
                            style: TextStyle(
                              fontFamily: 'Nunito',
                              fontWeight:
                                  FontWeight.bold,
                              color: primaryPurple,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(width: 14),

                      Expanded(
                        flex: 2,
                        child: ElevatedButton(
                          onPressed: () async {
                            setState(() {
                              _isLoading = true;
                            });

                            Navigator.pop(context);

                            _controller.maxPrice =
                                tempMaxPrice;

                            _controller.selectedAlamat =
                                tempAlamat;

                            _controller.applyFilter();

                            await _generateMarkersFromAddresses();

                            if (mounted) {
                              setState(() {
                                _isLoading = false;
                              });
                            }

                            await Future.delayed(
                              const Duration(
                                  milliseconds: 100),
                            );

                            if (_isMapView) {
                              _animateToSelectedCity(
                                tempAlamat,
                              );
                            }
                          },
                          style:
                              ElevatedButton.styleFrom(
                            backgroundColor:
                                primaryPurple,
                            shape:
                                RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(
                                      12),
                            ),
                            padding:
                                const EdgeInsets.symmetric(
                              vertical: 15,
                            ),
                          ),
                          child: const Text(
                            "Apply Filter",
                            style: TextStyle(
                              fontFamily: 'Nunito',
                              fontWeight:
                                  FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgGray,

      appBar: AppBar(
        automaticallyImplyLeading: false,
        elevation: 0,
        backgroundColor: bgGray,

        title: const Text(
          "Search Mentors",
          style: TextStyle(
            fontFamily: 'Nunito',
            fontWeight: FontWeight.w900,
            fontSize: 24,
            color: Colors.black,
          ),
        ),

        actions: [
          IconButton(
            icon: Icon(
              _isMapView
                  ? Icons.list_rounded
                  : Icons.map_rounded,
              color: primaryPurple,
            ),
            onPressed: _isLoading
                ? null
                : () {
                    setState(() {
                      _isMapView = !_isMapView;
                    });
                  },
          ),

          IconButton(
            icon: Icon(
              Icons.tune_rounded,
              color: primaryPurple,
            ),
            onPressed:
                _isLoading ? null : _openFilter,
          ),
        ],
      ),

      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(
                color: primaryPurple,
              ),
            )
          : _controller.errorMessage != null
              ? _buildError()
              : Padding(
                  padding:
                      const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 10,
                  ),
                  child: Column(
                    children: [
                      _buildSearchBar(),

                      const SizedBox(height: 14),

                      _buildCategoryChips(),

                      const SizedBox(height: 18),

                      Expanded(
                        child: _isMapView
                            ? _buildMapView()
                            : _buildMentorList(),
                      ),

                      const SizedBox(height: 14),

                      // RESULT SEARCH DI BAWAH
                      Container(
                        padding:
                            const EdgeInsets.symmetric(
                          horizontal: 18,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius:
                              BorderRadius.circular(
                                  30),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black
                                  .withValues(alpha: 0.05),
                              blurRadius: 8,
                            ),
                          ],
                        ),
                        child: Text(
                          "${_controller.filteredMentors.length} Mentors Found",
                          style: TextStyle(
                            fontFamily: 'Nunito',
                            fontSize: 12,
                            fontWeight:
                                FontWeight.bold,
                            color: Colors.grey[600],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }

  Widget _buildSearchBar() {
    return TextField(
      controller:
          _controller.searchTextController,
      onChanged: (value) async {
        _controller.searchQuery = value;

        _controller.applyFilter();

        await _generateMarkersFromAddresses();

        setState(() {});
      },
      decoration: InputDecoration(
        hintText: "Search Mentors",
        hintStyle: const TextStyle(
          fontFamily: 'Nunito',
        ),

        prefixIcon: Icon(
          Icons.search_rounded,
          color: primaryPurple,
        ),

        suffixIcon:
            _controller.searchQuery.isNotEmpty
                ? IconButton(
                    icon: const Icon(
                      Icons.clear_rounded,
                      size: 18,
                    ),
                    onPressed: () async {
                      _controller
                          .searchTextController
                          .clear();

                      _controller.searchQuery = '';

                      _controller.applyFilter();

                      await _generateMarkersFromAddresses();

                      setState(() {});
                    },
                  )
                : null,

        filled: true,
        fillColor: Colors.white,

        border: OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(30),
          borderSide: BorderSide.none,
        ),

        contentPadding:
            const EdgeInsets.symmetric(
          vertical: 14,
        ),
      ),
    );
  }

  Widget _buildCategoryChips() {
    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _controller.categories.length,
        separatorBuilder: (_, __) =>
            const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final cat =
              _controller.categories[index];

          final isSelected =
              _controller.selectedCategory ==
                  cat;

          return GestureDetector(
            onTap: () async {
              _controller.selectedCategory =
                  cat;

              _controller.applyFilter();

              await _generateMarkersFromAddresses();

              setState(() {});
            },
            child: AnimatedContainer(
              duration:
                  const Duration(milliseconds: 200),
              padding:
                  const EdgeInsets.symmetric(
                horizontal: 18,
                vertical: 9,
              ),
              decoration: BoxDecoration(
                color: isSelected
                    ? primaryPurple
                    : Colors.white,
                borderRadius:
                    BorderRadius.circular(20),
              ),
              child: Text(
                cat,
                style: TextStyle(
                  fontFamily: 'Nunito',
                  fontWeight:
                      FontWeight.bold,
                  fontSize: 13,
                  color: isSelected
                      ? Colors.white
                      : Colors.grey[700],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildMapView() {
    final initialTarget =
        _controller.selectedAlamat != 'All' &&
                MentorSearchModel.cityCoordinates
                    .containsKey(
                        _controller
                            .selectedAlamat)
            ? MentorSearchModel.cityCoordinates[
                _controller.selectedAlamat]!
            : _defaultCenter;

    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: GoogleMap(
        initialCameraPosition:
            CameraPosition(
          target: initialTarget,
          zoom: _controller
                      .selectedAlamat !=
                  'All'
              ? 13.5
              : 12.0,
        ),
        markers: _mapMarkers,
        onMapCreated: (controller) {
          _mapController = controller;
        },
        myLocationButtonEnabled: false,
        zoomControlsEnabled: true,
      ),
    );
  }

  Widget _buildMentorList() {
    if (_controller.filteredMentors.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.search_off_rounded,
              size: 60,
              color: Colors.grey[300],
            ),

            const SizedBox(height: 12),

            Text(
              "No Mentors Found",
              style: TextStyle(
                fontFamily: 'Nunito',
                fontSize: 15,
                color: Colors.grey[400],
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      physics:
          const BouncingScrollPhysics(),
      itemCount:
          _controller.filteredMentors.length,
      itemBuilder: (context, index) {
        return _buildMentorCard(
          _controller.filteredMentors[index],
        );
      },
    );
  }

  Widget _buildMentorCard(
      MentorSearchModel mentor) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) =>
                MentorProfilePage(
              mentorId: mentor.userId,
            ),
          ),
        );
      },
      child: Container(
        margin:
            const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius:
              BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color:
                  Colors.black.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 30,
              backgroundColor:
                  primaryPurple.withValues(alpha: 0.15),
              backgroundImage:
                  mentor.fotoUrl != null
                      ? NetworkImage(
                          mentor.fotoUrl!)
                      : null,
              child: mentor.fotoUrl == null
                  ? Text(
                      mentor.namaLengkap
                              .isNotEmpty
                          ? mentor
                              .namaLengkap[0]
                              .toUpperCase()
                          : '?',
                      style: TextStyle(
                        fontFamily: 'Nunito',
                        fontWeight:
                            FontWeight.w900,
                        color:
                            primaryPurple,
                        fontSize: 22,
                      ),
                    )
                  : null,
            ),

            const SizedBox(width: 14),

            Expanded(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Text(
                    mentor.namaLengkap,
                    style: const TextStyle(
                      fontFamily: 'Nunito',
                      fontWeight:
                          FontWeight.w900,
                      fontSize: 15,
                    ),
                  ),

                  const SizedBox(height: 4),

                  if (mentor.categoryName != null)
                    Container(
                      padding:
                          const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: primaryPurple
                            .withValues(alpha: 0.1),
                        borderRadius:
                            BorderRadius.circular(
                                8),
                      ),
                      child: Text(
                        mentor.categoryName!,
                        style: TextStyle(
                          fontFamily:
                              'Nunito',
                          fontSize: 11,
                          color:
                              primaryPurple,
                          fontWeight:
                              FontWeight.bold,
                        ),
                      ),
                    ),

                  const SizedBox(height: 5),

                  Row(
                    children: [
                      Icon(
                        Icons
                            .location_on_outlined,
                        size: 13,
                        color:
                            Colors.grey[400],
                      ),

                      const SizedBox(width: 3),

                      Flexible(
                        child: Text(
                          mentor.alamat ??
                              'Location unavailable',
                          overflow:
                              TextOverflow
                                  .ellipsis,
                          style: TextStyle(
                            fontFamily:
                                'Nunito',
                            fontSize: 11,
                            color: Colors
                                .grey[500],
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 5),

                  Text(
                    mentor.pricePerSession !=
                            null
                        ? currencyFormat
                            .format(mentor
                                .pricePerSession)
                        : 'Price not set',
                    style: TextStyle(
                      fontFamily: 'Nunito',
                      fontSize: 13,
                      fontWeight:
                          FontWeight.w900,
                      color: mentor
                                  .pricePerSession !=
                              null
                          ? const Color(
                              0xFF5B62CC)
                          : Colors.grey,
                    ),
                  ),
                ],
              ),
            ),

            if (mentor.rating != null)
              Column(
                children: [
                  const Icon(
                    Icons.star_rounded,
                    color: Colors.amber,
                    size: 18,
                  ),

                  Text(
                    mentor.rating!
                        .toStringAsFixed(1),
                    style: const TextStyle(
                      fontFamily: 'Nunito',
                      fontWeight:
                          FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildError() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.wifi_off_rounded,
            size: 60,
            color: Colors.grey[300],
          ),

          const SizedBox(height: 12),

          Text(
            "Failed to Load Data",
            style: TextStyle(
              fontFamily: 'Nunito',
              fontWeight: FontWeight.bold,
              color: Colors.grey[500],
            ),
          ),

          const SizedBox(height: 8),

          ElevatedButton.icon(
            onPressed: () {
              setState(() {
                _isLoading = true;
              });

              _initData();
            },
            icon:
                const Icon(Icons.refresh_rounded),

            label: const Text("Retry"),

            style: ElevatedButton.styleFrom(
              backgroundColor: primaryPurple,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }
}