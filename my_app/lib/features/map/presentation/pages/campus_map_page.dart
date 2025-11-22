import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import '../../domain/entities/campus_facilities.dart';
import '../../data/campus_facilities_repo.dart';
import '../../config/ors_api_key.dart';//n
import 'dart:convert'; //n
import 'package:http/http.dart' as http;//n

class CampusMapPage extends StatefulWidget {
  const CampusMapPage({super.key});

  @override
  State<CampusMapPage> createState() => _CampusMapPageState();
}
class _CampusMapPageState extends State<CampusMapPage> {
  final _repo = CampusFacilitiesRepository();
  final MapController _mapController = MapController();

  List<CampusFacilities> _allFacilities = [];
  bool _loadingFacilities = true;
  String? _error;

  // filter
  String _selectedCategory = 'All';

  // user location
  Position? _userPosition;
  bool _locating = false;

  // selected facility (for sheet + path)
  CampusFacilities? _selectedFacility;

  // ⭐ ADD: storage for ORS walking path
  List<LatLng> _routePoints = [];

  static const double _initialZoom = 17;

  // UoM approximate center
  static const LatLng _campusCenter = LatLng(-20.2333, 57.4950);
    // Limit the visible area to a box around UoM
 
  final List<String> _categories = [
    'All',
    'Food',
    'Study',
    'Admin',
    'Sports',
    'Parking',
    'Lab',
    'Other',
  ];

  @override
  void initState() {
    super.initState();
    _loadFacilities();
    _initLocation();
  }

  Future<void> _loadFacilities() async {
    try {
      final facilities = await _repo.fetchAllFacilities();
      setState(() {
        _allFacilities = facilities;
        _loadingFacilities = false;
        _error = null;
      });
    } catch (e) {
      setState(() {
        _loadingFacilities = false;
        _error = 'Failed to load campus facilities: $e';
      });
    }
  }

  // Future<void> _initLocation() async {
  //   setState(() {
  //     _locating = true;
  //   });

  //   try {
  //     final permission = await Geolocator.checkPermission();
  //     LocationPermission finalPerm = permission;

  //     if (permission == LocationPermission.denied ||
  //         permission == LocationPermission.deniedForever) {
  //       finalPerm = await Geolocator.requestPermission();
  //     }

  //     if (finalPerm == LocationPermission.denied ||
  //         finalPerm == LocationPermission.deniedForever) {
  //       setState(() {
  //         _locating = false;
  //       });
  //       return;
  //     }

  //     final pos = await Geolocator.getCurrentPosition(
  //       locationSettings: AndroidSettings(
  //         accuracy: LocationAccuracy.best,
  //         forceLocationManager: true,      // Forces GPS instead of Google Play services
  //         distanceFilter: 0,
  //       ),
  //     );


  //     setState(() {
  //       _userPosition = pos;
  //       _locating = false;
  //     });
  //   } catch (e) {
  //     setState(() {
  //       _locating = false;
  //       _error = 'Could not get your location: $e';
  //     });
  //   }
  // }

  Future<void> _initLocation() async {
  setState(() {
    _locating = true;
  });

  // 🔹 Fake position: pretend user is here
  const fakeLat = -20.233970699744738;
  const fakeLng = 57.497591135995656;

  // Create a Position object with those coordinates
  _userPosition = Position(
    latitude: fakeLat,
    longitude: fakeLng,
    timestamp: DateTime.now(),
    accuracy: 1,          // dummy values
    altitude: 0,
    heading: 0,
    speed: 0,
    speedAccuracy: 1,
    altitudeAccuracy: 1,
    headingAccuracy: 1,
    isMocked: true,
  );

  setState(() {
    _locating = false;
  });
}

// ⭐ ADD: OpenRouteService walking path fetcher
Future<List<LatLng>> fetchWalkingRoute(
  double startLat,
  double startLng,
  double endLat,
  double endLng,
) async {
  final url = Uri.parse(
    "https://api.openrouteservice.org/v2/directions/foot-walking?"
    "api_key=$ORS_API_KEY"
    "&start=$startLng,$startLat"
    "&end=$endLng,$endLat",
  );

  final res = await http.get(url);

  if (res.statusCode != 200) {
    print("Route API ERROR: ${res.body}");
    throw Exception("Failed to fetch walking route.");
  }

  final data = jsonDecode(res.body);
  final coords = data["features"][0]["geometry"]["coordinates"];

  return coords
      .map<LatLng>((c) => LatLng(c[1].toDouble(), c[0].toDouble()))
      .toList();
}

  void _recenterOnCampus() {
    _mapController.move(_campusCenter, _initialZoom);
  }

  void _focusOnFacility(CampusFacilities f) {
    _mapController.move(LatLng(f.lat, f.lng), 18);
    setState(() {
      _selectedFacility = f;
    });
    _openFacilitySheet(f);
  }

  void _openFacilitySheet(CampusFacilities f) {
  showModalBottomSheet(
    context: context,
    showDragHandle: true,
    isScrollControlled: true, // <-- important
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (ctx) {
      final maxHeight = MediaQuery.of(ctx).size.height * 0.7; // 70% of screen

      return SafeArea(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxHeight: maxHeight),
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [                
                if (f.imageName != null && f.imageName!.isNotEmpty)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: SizedBox(
                      height: 180,
                      width: double.infinity,
                      child: Image.asset(
                        'assets/facilities/${f.imageName}',
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) =>
                            const Center(child: Icon(Icons.broken_image)),
                      )
                    ),
                  ),
                if (f.imageName != null && f.imageName!.isNotEmpty)
                  const SizedBox(height: 12),
                Text(
                  f.name,
                  style: Theme.of(ctx).textTheme.titleLarge,
                ),
                const SizedBox(height: 4),
                Text(
                  f.description,
                  style: Theme.of(ctx).textTheme.bodyMedium,
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.access_time, size: 18),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        f.openingHours,
                        style: Theme.of(ctx).textTheme.bodyMedium,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    FilledButton.icon(
                      onPressed: () => _focusOnFacility(f),
                      icon: const Icon(Icons.place),
                      label: const Text('Focus on map'),
                    ),
                    const SizedBox(width: 12),
                    if (_userPosition != null)
                      OutlinedButton.icon(
                        onPressed: () async {
                          Navigator.of(ctx).pop();
                              if (_userPosition == null) return;
                                // Reset route first (prevents stale frames)
                                setState(() {
                                _routePoints = [];
                                });
                              // ⭐ Request ORS walking path
                              final points = await fetchWalkingRoute(
                                _userPosition!.latitude,
                                _userPosition!.longitude,
                                f.lat,
                                f.lng,
                              );

                              setState(() {
                                _selectedFacility = f;
                                _routePoints = points; // ⭐ store route
                              });                             
                              // ⭐ Move map to show path nicely
                              if (_routePoints.isNotEmpty) {
                                _mapController.fitCamera(
                                  CameraFit.coordinates(
                                    coordinates: _routePoints,
                                    padding: const EdgeInsets.all(40),
                                  ),
                                );
                              }
                        },
                        icon: const Icon(Icons.directions_walk),
                        label: const Text('See path'),
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Category: ${f.category}',
                  style: Theme.of(ctx).textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}

  List<CampusFacilities> get _filteredFacilities {
    if (_selectedCategory == 'All') return _allFacilities;
    final lower = _selectedCategory.toLowerCase();
    return _allFacilities
        .where((f) => f.category.toLowerCase() == lower)
        .toList();
  }

  List<Marker> _buildFacilityMarkers() {
    return _filteredFacilities.map((f) {
      return Marker(
        point: LatLng(f.lat, f.lng),
        width: 44,
        height: 44,
        child: GestureDetector(
          onTap: () {
            setState(() {
              _selectedFacility = f;
            });
            _openFacilitySheet(f);
          },
          child: Icon(
            Icons.location_on,
            size: 40,
            color: Theme.of(context).colorScheme.primary,
            shadows: const [Shadow(blurRadius: 4, color: Colors.black26)],
          ),
        ),
      );
    }).toList();
  }

  Marker? _buildUserMarker() {
    if (_userPosition == null) return null;
    final pos = _userPosition!;
    return Marker(
      point: LatLng(pos.latitude, pos.longitude),
      width: 40,
      height: 40,
      child: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.blueAccent.withOpacity(0.8),
          boxShadow: const [BoxShadow(blurRadius: 4, color: Colors.black26)],
        ),
        child: const Center(
          child: Icon(Icons.person_pin_circle, color: Colors.white, size: 20),
        ),
      ),
    );
  }

  Polyline? _buildPathPolyline() {
    if (_userPosition == null || _selectedFacility == null) return null;
    final pos = _userPosition!;
    final facility = _selectedFacility!;
    return Polyline(
      points: [
        LatLng(pos.latitude, pos.longitude),
        LatLng(facility.lat, facility.lng),
      ],
      strokeWidth: 4,
      color: Colors.blueAccent.withOpacity(0.7),
    );
  }

  @override
  Widget build(BuildContext context) {
    final userMarker = _buildUserMarker();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Campus Map'),
      ),
      body: Column(
        children: [
          // Category chips
          SizedBox(
            height: 52,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              scrollDirection: Axis.horizontal,
              itemCount: _categories.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, i) {
                final cat = _categories[i];
                final selected = _selectedCategory == cat;
                return ChoiceChip(
                  label: Text(cat),
                  selected: selected,
                  onSelected: (_) {
                    setState(() {
                      _selectedCategory = cat;
                    });
                  },
                );
              },
            ),
          ),
          Expanded(
            child: Stack(
              children: [
                if (_loadingFacilities)
                  const Center(child: CircularProgressIndicator())
                else if (_error != null)
                  Center(child: Text(_error!))
                else
                  FlutterMap(
                    mapController: _mapController,
                   options: MapOptions(
                      initialCenter: _campusCenter,
                      initialZoom: _initialZoom,

                      // 🔥 Proper bounding box for entire UoM area
                      cameraConstraint: CameraConstraint.contain(
                        bounds: LatLngBounds(
                          const LatLng(-20.2380, 57.4915), // south-west (min lat, min lon)
                          const LatLng(-20.2310, 57.5050), // north-east (max lat, max lon)
                        ),
                      ),
                    ),
                   
                    children: [
                      TileLayer(
                        urlTemplate:
                            'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                        subdomains: const ['a', 'b', 'c'],
                        userAgentPackageName:
                            'com.example.induction_app',
                      ),
                      if (_routePoints.isNotEmpty)
                      PolylineLayer(
                        polylines: [
                          Polyline(
                            points: _routePoints,
                            color: Colors.blueAccent,
                            strokeWidth: 4,
                          ),
                        ],
                      ),
                      MarkerLayer(
                        markers: [
                          ..._buildFacilityMarkers(),
                          if (userMarker != null) userMarker,
                        ],
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton.small(
            heroTag: 'locate_me',
            onPressed: _initLocation,
            child: const Icon(Icons.my_location),
          ),
          const SizedBox(height: 10),
          FloatingActionButton.small(
            heroTag: 'recenter',
            onPressed: _recenterOnCampus,
            child: const Icon(Icons.school),
          ),
        ],
      ),
    );
  }
}
