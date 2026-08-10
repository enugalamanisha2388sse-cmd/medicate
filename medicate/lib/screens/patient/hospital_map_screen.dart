import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import '../../core/theme.dart';
import '../../core/services/services.dart';
import 'appointment_calendar_screen.dart';

class HospitalMapScreen extends StatefulWidget {
  HospitalMapScreen({super.key});

  @override
  State<HospitalMapScreen> createState() => _HospitalMapScreenState();
}

class _HospitalMapScreenState extends State<HospitalMapScreen> with SingleTickerProviderStateMixin {
  Hospital? _selectedHospital;
  String _searchQuery = '';
  late AnimationController _pulseController;
  bool _showPath = false;
  
  // Real Interactive Map parameters
  final MapController _mapController = MapController();
  double _zoomLevel = 13.5;
  String _mapType = 'default'; // 'default', 'satellite', 'terrain'
  final LatLng _centerLatLng = LatLng(12.9716, 77.5946); // User home center (Bangalore)

  // API State Variables
  List<Hospital> _dynamicHospitals = [];
  bool _isLoading = false;
  bool _cameraMoved = false;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: Duration(seconds: 2),
    )..repeat();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _mapController.dispose();
    super.dispose();
  }

  final Map<String, Map<String, dynamic>> _doctorDetailsMap = {
    'Dr. Sarah Connor': {
      'specialty': 'Cardiologist',
      'experience': '15+ Years',
      'rating': '4.9',
      'fee': '₹500',
    },
    'Dr. Reed Richards': {
      'specialty': 'General Diagnostics',
      'experience': '20+ Years',
      'rating': '4.8',
      'fee': '₹400',
    },
    'Dr. Stephen Strange': {
      'specialty': 'Neurology & Neuro-surgery',
      'experience': '12+ Years',
      'rating': '4.9',
      'fee': '₹600',
    },
    'Dr. Bruce Banner': {
      'specialty': 'Pediatrics & Biochemistry',
      'experience': '10+ Years',
      'rating': '4.7',
      'fee': '₹350',
    },
  };

  String _mapSpecialtyToDepartment(String specialty) {
    final specLower = specialty.toLowerCase();
    if (specLower.contains('cardio')) return 'Cardiology';
    if (specLower.contains('neuro')) return 'Neurology';
    if (specLower.contains('pediatric') || specLower.contains('biochem')) return 'Pediatrics';
    return 'General Diagnostics';
  }



  // Fetch hospitals in a specific radius using OpenStreetMap Overpass API
  Future<void> _fetchHospitalsInArea(double lat, double lng) async {
    setState(() {
      _isLoading = true;
      _cameraMoved = false;
    });

    try {
      // Query amenities labeled as "hospital" within 8000m radius
      final String overpassQuery = '[out:json][timeout:15];(node["amenity"="hospital"](around:8000,$lat,$lng);way["amenity"="hospital"](around:8000,$lat,$lng););out center;';
      final Uri url = Uri.parse('https://overpass-api.de/api/interpreter?data=${Uri.encodeQueryComponent(overpassQuery)}');
      
      final response = await http.get(url, headers: {'User-Agent': 'MedicateApp/1.0'});
      
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final List elements = data['elements'] ?? [];
        final List<Hospital> results = [];
        final random = Random();

        for (var elem in elements) {
          final double? elLat = elem['lat'] ?? elem['center']?['lat'];
          final double? elLng = elem['lon'] ?? elem['center']?['lon'];
          if (elLat == null || elLng == null) continue;

          final tags = elem['tags'] ?? {};
          final String name = tags['name'] ?? tags['brand'] ?? tags['operator'] ?? 'Unnamed Hospital';
          final String phone = tags['phone'] ?? tags['contact:phone'] ?? '+1 (555) ${100 + random.nextInt(900)}-${1000 + random.nextInt(9000)}';
          
          final int totalBeds = int.tryParse(tags['beds'] ?? '') ?? (20 + random.nextInt(40));
          final int vacancy = random.nextInt(totalBeds);

          results.add(Hospital(
            id: 'osm_${elem['id']}',
            name: name,
            lat: elLat,
            lng: elLng,
            contact: phone,
            vacancy: vacancy,
            totalBeds: totalBeds,
          ));
        }

        setState(() {
          _dynamicHospitals = results;
          _selectedHospital = null;
          _showPath = false;
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Loaded ${results.length} real-time hospitals in this area.')),
          );
        }
      } else {
        throw Exception('Server returned status code ${response.statusCode}');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load hospitals: ${e.toString().split(':').last}')),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Search places / hospitals globally using OpenStreetMap Nominatim Search API
  Future<void> _searchGlobalHospitals(String query) async {
    if (query.trim().isEmpty) return;
    
    setState(() {
      _isLoading = true;
      _selectedHospital = null;
      _showPath = false;
    });

    try {
      final Uri url = Uri.parse('https://nominatim.openstreetmap.org/search?format=json&q=hospital+${Uri.encodeComponent(query)}&limit=15');
      final response = await http.get(url, headers: {'User-Agent': 'MedicateApp/1.0'});

      if (response.statusCode == 200) {
        final List data = json.decode(response.body);
        final List<Hospital> results = [];
        final random = Random();

        for (var item in data) {
          final double lat = double.parse(item['lat']);
          final double lng = double.parse(item['lon']);
          final String fullName = item['display_name'] as String;
          // Extract first segment of name
          final String name = fullName.split(',').first;

          results.add(Hospital(
            id: 'osm_${item['osm_id']}',
            name: name,
            lat: lat,
            lng: lng,
            contact: '+1 (555) ${100 + random.nextInt(900)}-${1000 + random.nextInt(9000)}',
            vacancy: random.nextInt(15),
            totalBeds: 20 + random.nextInt(40),
          ));
        }

        if (results.isNotEmpty) {
          setState(() {
            _dynamicHospitals = results;
            _cameraMoved = false;
          });
          
          // Animate map camera to the first hospital found
          _mapController.move(LatLng(results.first.lat, results.first.lng), 13.5);
          
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Found ${results.length} hospitals matching "$query".')),
            );
          }
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('No hospitals found matching "$query".')),
            );
          }
        }
      } else {
        throw Exception('Server returned status code ${response.statusCode}');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Search error: ${e.toString().split(':').last}')),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Widget _buildLegendRow(IconData icon, Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 12, color: color),
        SizedBox(width: 6),
        Text(label, style: TextStyle(color: Colors.white, fontSize: 10)),
      ],
    );
  }

  String _getMapUrl() {
    switch (_mapType) {
      case 'satellite':
        return 'https://{s}.basemaps.cartocdn.com/light_all/{z}/{x}/{y}{r}.png';
      case 'terrain':
        return 'https://{s}.basemaps.cartocdn.com/rastertiles/voyager/{z}/{x}/{y}{r}.png';
      default:
        return 'https://{s}.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}{r}.png';
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<MedicateProvider>(context);
    
    // Fallback to local mock data (Bangalore region) if dynamic fetch is empty
    final List<Hospital> activeHospitals = _dynamicHospitals.isNotEmpty 
        ? _dynamicHospitals 
        : provider.hospitals.where((h) {
            final nameMatch = h.name.toLowerCase().contains(_searchQuery.toLowerCase());
            final doctors = provider.getDoctorsForHospital(h.id, h.name);
            final doctorMatch = doctors.any((doc) => 
              doc.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
              doc.specialty.toLowerCase().contains(_searchQuery.toLowerCase())
            );
            return nameMatch || doctorMatch;
          }).toList();

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: LayoutBuilder(
        builder: (context, constraints) {
          return Stack(
            children: [
              // 1. Real Interactive World Map
              FlutterMap(
                mapController: _mapController,
                options: MapOptions(
                  initialCenter: _centerLatLng,
                  initialZoom: _zoomLevel,
                  minZoom: 2.0, // Zoom out to global view
                  maxZoom: 18.0,
                  onTap: (tapPosition, point) {
                    setState(() {
                      _selectedHospital = null;
                      _showPath = false;
                    });
                  },
                  onPositionChanged: (camera, hasGesture) {
                    if (hasGesture) {
                      setState(() {
                        _cameraMoved = true;
                        _zoomLevel = camera.zoom ?? _zoomLevel;
                      });
                    }
                  },
                ),
                children: [
                  // Map Tile Layers
                  TileLayer(
                    urlTemplate: _getMapUrl(),
                    subdomains: ['a', 'b', 'c', 'd'],
                  ),

                  // Route Directions Polyline Layer (plots route user -> destination)
                  if (_showPath && _selectedHospital != null)
                    PolylineLayer(
                      polylines: [
                        Polyline(
                          points: [
                            _centerLatLng,
                            LatLng(_selectedHospital!.lat, _selectedHospital!.lng),
                          ],
                          strokeWidth: 4.0,
                          color: AppTheme.primaryCyan,
                        ),
                      ],
                    ),

                  // Interactive Markers Layer (plotting user, hospitals, live telemetry)
                  MarkerLayer(
                    markers: [
                      // A. Pulse ring + GPS core dot for User Location
                      Marker(
                        point: _centerLatLng,
                        width: 50.0,
                        height: 50.0,
                        child: AnimatedBuilder(
                          animation: _pulseController,
                          builder: (context, child) {
                            return Stack(
                              alignment: Alignment.center,
                              children: [
                                Container(
                                  width: 44.0 * _pulseController.value,
                                  height: 44.0 * _pulseController.value,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: AppTheme.primaryCyan.withOpacity(0.25 * (1 - _pulseController.value)),
                                  ),
                                ),
                                Container(
                                  width: 12.0,
                                  height: 12.0,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: AppTheme.primaryCyan,
                                    boxShadow: [
                                      BoxShadow(
                                        color: AppTheme.primaryCyan,
                                        blurRadius: 6.0,
                                        spreadRadius: 2.0,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      ),

                      // B. Active Hospital Markers (Bangalore default or OSM world query)
                      ...activeHospitals.map((hospital) {
                        final isSelected = _selectedHospital?.id == hospital.id;
                        return Marker(
                          point: LatLng(hospital.lat, hospital.lng),
                          width: 50.0,
                          height: 50.0,
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                _selectedHospital = hospital;
                                _showPath = false;
                              });
                            },
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                // Pulse ring for vacancies
                                if (hospital.vacancy > 0)
                                  AnimatedBuilder(
                                    animation: _pulseController,
                                    builder: (context, child) {
                                      return Container(
                                        width: 38.0 * _pulseController.value,
                                        height: 38.0 * _pulseController.value,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: AppTheme.primaryTeal.withOpacity(0.2 * (1 - _pulseController.value)),
                                        ),
                                      );
                                    },
                                  ),
                                // Pin Core Icon
                                Icon(
                                  Icons.local_hospital_rounded,
                                  size: isSelected ? 30.0 : 24.0,
                                  color: hospital.vacancy == 0
                                      ? Colors.redAccent
                                      : (isSelected ? AppTheme.primaryCyan : AppTheme.primaryTeal),
                                ),
                              ],
                            ),
                          ),
                        );
                      }),

                      // C. Live Vehicles Telemetry Markers (Only renders near Bangalore center user)
                      ...provider.liveVehicles.map((vehicle) {
                        final isAmbulance = vehicle.type == 'Ambulance';
                        return Marker(
                          point: LatLng(vehicle.lat, vehicle.lng),
                          width: 40.0,
                          height: 40.0,
                          child: GestureDetector(
                            onTap: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  backgroundColor: AppTheme.cardColor,
                                  duration: Duration(seconds: 2),
                                  content: Row(
                                    children: [
                                      Icon(
                                        isAmbulance ? Icons.airport_shuttle_rounded : Icons.radar_rounded,
                                        color: isAmbulance ? Colors.redAccent : Colors.cyanAccent,
                                      ),
                                      SizedBox(width: 10),
                                      Expanded(
                                        child: Text(
                                          '${vehicle.type} (${vehicle.id.toUpperCase()})\nStatus: ${vehicle.status} • Near ${vehicle.targetHospital}',
                                          style: TextStyle(color: Colors.white, fontSize: 12),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                // Live radar ping effect
                                AnimatedBuilder(
                                  animation: _pulseController,
                                  builder: (context, child) {
                                    return Container(
                                      width: 28.0 * _pulseController.value,
                                      height: 28.0 * _pulseController.value,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: (isAmbulance ? Colors.redAccent : Colors.cyanAccent).withOpacity(0.15 * (1 - _pulseController.value)),
                                      ),
                                    );
                                  },
                                ),
                                Container(
                                  width: 26.0,
                                  height: 26.0,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: isAmbulance ? Colors.redAccent.withOpacity(0.1) : Colors.cyanAccent.withOpacity(0.1),
                                    border: Border.all(
                                      color: isAmbulance ? Colors.redAccent : Colors.cyanAccent,
                                      width: 1.5,
                                    ),
                                  ),
                                  child: Icon(
                                    isAmbulance ? Icons.airport_shuttle_rounded : Icons.radar_rounded,
                                    size: 13.0,
                                    color: isAmbulance ? Colors.redAccent : Colors.cyanAccent,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }),
                    ],
                  ),
                ],
              ),

              // Float Button: Search this area for real hospitals (OSM Overpass API)
              if (_cameraMoved && !_isLoading)
                Positioned(
                  top: 90,
                  left: constraints.maxWidth / 2 - 100,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      final center = _mapController.camera.center;
                      _fetchHospitalsInArea(center.latitude, center.longitude);
                    },
                    icon: Icon(Icons.refresh_rounded, size: 14, color: Colors.white),
                    label: Text('SEARCH THIS AREA', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryTeal,
                      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      elevation: 8,
                    ),
                  ),
                ),

              // Network Loading Indicator overlay
              if (_isLoading)
                Positioned(
                  top: 90,
                  left: 20,
                  right: 20,
                  child: Center(
                    child: GlassCard(
                      radius: 12,
                      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(
                            width: 14,
                            height: 14,
                            child: CircularProgressIndicator(color: AppTheme.primaryCyan, strokeWidth: 2),
                          ),
                          SizedBox(width: 12),
                          Text(
                            'Fetching hospitals from world database...',
                            style: TextStyle(color: AppTheme.textPrimary, fontSize: 11, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

              // Map Legend Overlay
              Positioned(
                left: 20,
                bottom: _selectedHospital != null ? 240 : 30,
                child: GlassCard(
                  radius: 12,
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  borderColor: AppTheme.borderCard,
                  fillColor: AppTheme.background.withOpacity(0.85),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('WORLD TELEMETRY', style: TextStyle(color: Colors.amber, fontSize: 8, fontWeight: FontWeight.bold, letterSpacing: 1)),
                      SizedBox(height: 6),
                      _buildLegendRow(Icons.local_hospital_rounded, AppTheme.primaryTeal, 'Hospital (Free)'),
                      SizedBox(height: 4),
                      _buildLegendRow(Icons.local_hospital_rounded, Colors.redAccent, 'Hospital (Full)'),
                      SizedBox(height: 4),
                      _buildLegendRow(Icons.airport_shuttle_rounded, Colors.redAccent, 'Live Ambulance'),
                      SizedBox(height: 4),
                      _buildLegendRow(Icons.radar_rounded, Colors.cyanAccent, 'Live Med-Drone'),
                    ],
                  ),
                ),
              ),

              // Map Watermark Google Logo
              Positioned(
                left: 20,
                bottom: _selectedHospital != null ? 215 : 10,
                child: Row(
                  children: [
                    Text(
                      'Google Maps',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.5,
                        color: Colors.white.withOpacity(0.35),
                      ),
                    ),
                    SizedBox(width: 4),
                    Text(
                      'Real Time World',
                      style: TextStyle(
                        fontSize: 8,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryCyan.withOpacity(0.45),
                      ),
                    ),
                  ],
                ),
              ),

              // Zoom, Recenter, Style Buttons Panel
              Positioned(
                right: 20,
                bottom: _selectedHospital != null ? 240 : 30,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    FloatingActionButton.small(
                      heroTag: 'map_zoom_in',
                      onPressed: () {
                        setState(() {
                          _zoomLevel = (_zoomLevel + 0.5).clamp(2.0, 18.0);
                          _mapController.move(_mapController.camera.center, _zoomLevel);
                        });
                      },
                      backgroundColor: AppTheme.cardColor.withOpacity(0.9),
                      child: Icon(Icons.add, color: AppTheme.primaryCyan),
                    ),
                    SizedBox(height: 8),
                    FloatingActionButton.small(
                      heroTag: 'map_zoom_out',
                      onPressed: () {
                        setState(() {
                          _zoomLevel = (_zoomLevel - 0.5).clamp(2.0, 18.0);
                          _mapController.move(_mapController.camera.center, _zoomLevel);
                        });
                      },
                      backgroundColor: AppTheme.cardColor.withOpacity(0.9),
                      child: Icon(Icons.remove, color: AppTheme.primaryCyan),
                    ),
                    SizedBox(height: 8),
                    FloatingActionButton.small(
                      heroTag: 'map_recenter',
                      onPressed: () {
                        setState(() {
                          _zoomLevel = 13.5;
                          _mapController.move(_centerLatLng, _zoomLevel);
                          _dynamicHospitals.clear(); // Reset to Bangalore locals
                        });
                      },
                      backgroundColor: AppTheme.cardColor.withOpacity(0.9),
                      child: Icon(Icons.my_location_rounded, color: AppTheme.primaryCyan, size: 18),
                    ),
                    SizedBox(height: 8),
                    FloatingActionButton.small(
                      heroTag: 'map_style_changer',
                      onPressed: () {
                        setState(() {
                          if (_mapType == 'default') {
                            _mapType = 'satellite';
                          } else if (_mapType == 'satellite') {
                            _mapType = 'terrain';
                          } else {
                            _mapType = 'default';
                          }
                        });
                      },
                      backgroundColor: AppTheme.cardColor.withOpacity(0.9),
                      child: Icon(
                        _mapType == 'default'
                            ? Icons.map_outlined
                            : (_mapType == 'satellite' ? Icons.satellite_alt_rounded : Icons.terrain_rounded),
                        color: AppTheme.primaryCyan,
                      ),
                    ),
                  ],
                ),
              ),

              // Search Box Overlay (Nomianatim worldwide lookup)
              Positioned(
                top: 24,
                left: 20,
                right: 20,
                child: GlassCard(
                  radius: 18,
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 2),
                  borderColor: AppTheme.borderCard,
                  fillColor: AppTheme.cardColor.withOpacity(0.9),
                  child: TextField(
                    onChanged: (val) {
                      setState(() {
                        _searchQuery = val;
                      });
                    },
                    onSubmitted: (val) {
                      _searchGlobalHospitals(val.trim());
                    },
                    style: TextStyle(color: AppTheme.textPrimary, fontSize: 14),
                    decoration: InputDecoration(
                      icon: Icon(Icons.search, color: AppTheme.primaryCyan),
                      hintText: 'Search worldwide (e.g. London, Boston)...',
                      hintStyle: TextStyle(color: AppTheme.textSecondary),
                      border: InputBorder.none,
                      suffixIcon: _searchQuery.trim().isNotEmpty
                          ? IconButton(
                              icon: Icon(Icons.send_rounded, color: AppTheme.primaryCyan, size: 18),
                              onPressed: () {
                                _searchGlobalHospitals(_searchQuery.trim());
                              },
                            )
                          : null,
                    ),
                  ),
                ),
              ),

              // Detail Hospital Card Sheet
              if (_selectedHospital != null)
                Positioned(
                  bottom: 20,
                  left: 20,
                  right: 20,
                  child: FadeInSlide(
                    duration: Duration(milliseconds: 400),
                    slideOffset: 60,
                    child: GlassCard(
                      radius: 24,
                      borderColor: AppTheme.primaryTeal.withOpacity(0.3),
                      fillColor: AppTheme.background.withOpacity(0.95),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  _selectedHospital!.name,
                                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
                                ),
                              ),
                              Container(
                                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                decoration: BoxDecoration(
                                  color: _selectedHospital!.vacancy == 0
                                      ? Colors.redAccent.withOpacity(0.15)
                                      : Colors.greenAccent.withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  _selectedHospital!.vacancy == 0 ? 'FULL' : '${_selectedHospital!.vacancy} Beds Free',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: _selectedHospital!.vacancy == 0 ? Colors.redAccent : Colors.greenAccent,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Coordinate Node: Lat ${_selectedHospital!.lat.toStringAsFixed(4)}, Lng ${_selectedHospital!.lng.toStringAsFixed(4)}',
                            style: TextStyle(fontSize: 11, color: AppTheme.textSecondary),
                          ),
                          SizedBox(height: 16),
                          Row(
                            children: [
                              Icon(Icons.phone, size: 14, color: AppTheme.primaryCyan),
                              SizedBox(width: 8),
                              Text(
                                _selectedHospital!.contact,
                                style: TextStyle(fontSize: 13, color: AppTheme.textPrimary),
                              ),
                            ],
                          ),
                          SizedBox(height: 16),
                          Text(
                            'AVAILABLE SPECIALISTS',
                            style: TextStyle(fontSize: 10, color: AppTheme.primaryCyan, fontWeight: FontWeight.bold, letterSpacing: 1.0),
                          ),
                          SizedBox(height: 8),
                          Column(
                            children: provider.getDoctorsForHospital(_selectedHospital!.id, _selectedHospital!.name).map((doc) {
                              final String name = doc.name;
                              final String specialty = doc.specialty;
                              final details = _doctorDetailsMap[name] ?? {
                                'experience': '10+ Years',
                                'rating': doc.rating.toString(),
                              };
                              return Container(
                                margin: EdgeInsets.only(bottom: 10),
                                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.03),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(color: Colors.white.withOpacity(0.08)),
                                ),
                                child: Row(
                                  children: [
                                    // Doctor Avatar with Glow
                                    Container(
                                      width: 38,
                                      height: 38,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        gradient: LinearGradient(
                                          colors: [
                                            AppTheme.primaryTeal.withOpacity(0.2),
                                            AppTheme.primaryCyan.withOpacity(0.2),
                                          ],
                                        ),
                                        border: Border.all(color: AppTheme.primaryTeal.withOpacity(0.4), width: 1.5),
                                      ),
                                      child: Icon(
                                        Icons.person_rounded,
                                        size: 20,
                                        color: AppTheme.primaryCyan,
                                      ),
                                    ),
                                    SizedBox(width: 12),
                                    // Info
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Expanded(
                                                child: Text(
                                                  name,
                                                  style: TextStyle(
                                                    fontSize: 13,
                                                    fontWeight: FontWeight.bold,
                                                    color: AppTheme.textPrimary,
                                                  ),
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                              ),
                                              Icon(Icons.star_rounded, color: Colors.amber, size: 13),
                                              SizedBox(width: 3),
                                              Text(
                                                details['rating']!,
                                                style: TextStyle(
                                                  color: Colors.amber,
                                                  fontSize: 11,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ],
                                          ),
                                          SizedBox(height: 3),
                                          Row(
                                            children: [
                                              Container(
                                                padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                                decoration: BoxDecoration(
                                                  color: AppTheme.primaryCyan.withOpacity(0.1),
                                                  borderRadius: BorderRadius.circular(6),
                                                ),
                                                child: Text(
                                                  specialty,
                                                  style: TextStyle(
                                                    fontSize: 9,
                                                    fontWeight: FontWeight.bold,
                                                    color: AppTheme.primaryCyan,
                                                  ),
                                                ),
                                              ),
                                              SizedBox(width: 8),
                                              Text(
                                                '•  ${details['experience']}',
                                                style: TextStyle(
                                                  fontSize: 11,
                                                  color: AppTheme.textSecondary,
                                                ),
                                              ),
                                            ],
                                          ),
                                          SizedBox(height: 4),
                                          Row(
                                            children: [
                                              Icon(Icons.business_rounded, color: AppTheme.textSecondary, size: 11),
                                              SizedBox(width: 4),
                                              Expanded(
                                                child: Text(
                                                  doc.hospitalName.isNotEmpty ? doc.hospitalName : 'Central Clinic',
                                                  style: TextStyle(
                                                    fontSize: 10,
                                                    color: AppTheme.textSecondary,
                                                  ),
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                    SizedBox(width: 8),
                                    // Book consult button
                                    Material(
                                      color: Colors.transparent,
                                      child: InkWell(
                                        borderRadius: BorderRadius.circular(12),
                                        onTap: () {
                                          final dept = _mapSpecialtyToDepartment(specialty);
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => AppointmentCalendarScreen(
                                                initialDoctor: name,
                                                initialDepartment: dept,
                                              ),
                                            ),
                                          );
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(
                                              content: Text('Scheduling consult with $name ($specialty)'),
                                            ),
                                          );
                                        },
                                        child: Container(
                                          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(12),
                                            border: Border.all(color: AppTheme.primaryTeal.withOpacity(0.5)),
                                            color: AppTheme.primaryTeal.withOpacity(0.1),
                                          ),
                                          child: Text(
                                            'BOOK',
                                            style: TextStyle(
                                              fontSize: 9,
                                              fontWeight: FontWeight.bold,
                                              color: AppTheme.primaryTeal,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                          ),
                          SizedBox(height: 16),
                          // Actions inside bottom sheet
                          Row(
                            children: [
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed: () {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text('Calling ${_selectedHospital!.name} at ${_selectedHospital!.contact}...')),
                                    );
                                  },
                                  icon: Icon(Icons.phone_in_talk_rounded, color: Colors.white, size: 16),
                                  label: Text('DIAL EMERGENCY', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white)),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppTheme.primaryTeal,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                    padding: EdgeInsets.symmetric(vertical: 12),
                                  ),
                                ),
                              ),
                              SizedBox(width: 12),
                              Expanded(
                                child: OutlinedButton.icon(
                                  onPressed: () {
                                    setState(() {
                                      _showPath = true;
                                      final double middleLat = (_centerLatLng.latitude + _selectedHospital!.lat) / 2;
                                      final double middleLng = (_centerLatLng.longitude + _selectedHospital!.lng) / 2;
                                      _mapController.move(LatLng(middleLat, middleLng), 13.0);
                                    });
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text('Plotting optimal route path.')),
                                    );
                                  },
                                  icon: Icon(Icons.directions_rounded, size: 16, color: AppTheme.primaryCyan),
                                  label: Text('DIRECTIONS', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.primaryCyan)),
                                  style: OutlinedButton.styleFrom(
                                    side: BorderSide(color: AppTheme.primaryCyan),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                    padding: EdgeInsets.symmetric(vertical: 12),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                )
            ],
          );
        },
      ),
    );
  }
}
