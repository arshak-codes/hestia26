import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

import '../widgets/custom_app_bar.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen>
    with SingleTickerProviderStateMixin {
  static const _campusBounds = _CampusBounds(
    north: 8.915802253656231,
    east: 76.63335249903105,
    south: 8.912196630684209,
    west: 76.63129445428201,
  );

  static final List<_Venue> _venues = [
    _Venue('Main Entrance', 8.914622161600285, 76.6318839556781),
    _Venue('APJ Hall', 8.914479888453087, 76.63222454632742),
    _Venue('Basket Ball Court', 8.914358032536661, 76.63222937942942),
    _Venue('APJ Park', 8.915250704418906, 76.63205634383712),
    _Venue('Auditorium', 8.91381650385731, 76.6321073242981),
    _Venue('ECE Dept', 8.91363937978393, 76.63178537985411),
    _Venue('Civil Block', 8.914672490273906, 76.63225268741371),
    _Venue('CSE Department', 8.914125924547196, 76.63214714018196),
    _Venue('Architecture Block', 8.9133351818716, 76.6323108030619),
    _Venue('Workshop Block', 8.913761383484923, 76.63279160864309),
    _Venue('Mech Block', 8.912907547961488, 76.63175828802486),
    _Venue('Kili Vathil', 8.912565233078535, 76.6312549670317),
    _Venue('Chemical Block', 8.912520993486702, 76.63171856904107),
  ];

  late final AnimationController _pulseController = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1800),
  )..repeat(reverse: true);

  _Venue? _selectedVenue = _venues[4];
  Position? _currentPosition;
  String? _locationError;
  bool _isFetchingLocation = true;

  @override
  void initState() {
    super.initState();
    _loadCurrentLocation();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _loadCurrentLocation() async {
    setState(() {
      _isFetchingLocation = true;
      _locationError = null;
    });

    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw Exception('Turn on location services to track your route.');
      }

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        throw Exception('Location access is required to place you on the map.');
      }

      final position = await Geolocator.getCurrentPosition();
      if (!mounted) {
        return;
      }

      setState(() {
        _currentPosition = position;
      });
    } catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        _locationError = error.toString().replaceFirst('Exception: ', '');
      });
    } finally {
      if (mounted) {
        setState(() {
          _isFetchingLocation = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final startPoint =
        _currentPosition != null
            ? _MapPoint(_currentPosition!.latitude, _currentPosition!.longitude)
            : _selectedVenue != null
            ? _selectedVenue!.point
            : _venues.first.point;
    final destination = _selectedVenue;

    return Scaffold(
      appBar: const CustomAppBar(title: 'MAP'),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: _buildControlPanel(startPoint, destination),
            ),
            const SizedBox(height: 14),
            SizedBox(
              height: 70,
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                scrollDirection: Axis.horizontal,
                itemCount: _venues.length,
                separatorBuilder: (_, _) => const SizedBox(width: 10),
                itemBuilder: (context, index) {
                  final venue = _venues[index];
                  final isSelected = venue == _selectedVenue;
                  return ChoiceChip(
                    label: Text(venue.name),
                    selected: isSelected,
                    onSelected: (_) {
                      setState(() {
                        _selectedVenue = venue;
                      });
                    },
                    selectedColor: const Color(0xFFE28B9B),
                    backgroundColor: const Color(0xFF17171A),
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.black : Colors.white70,
                      fontWeight: FontWeight.w600,
                    ),
                    side: BorderSide(
                      color: isSelected ? Colors.transparent : Colors.white12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 14),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: AnimatedBuilder(
                  animation: _pulseController,
                  builder: (context, _) {
                    return _FantasyMapCard(
                      bounds: _campusBounds,
                      venues: _venues,
                      startPoint: startPoint,
                      selectedVenue: destination,
                      pulseValue: _pulseController.value,
                      hasPreciseLocation: _currentPosition != null,
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildControlPanel(_MapPoint startPoint, _Venue? destination) {
    final hasLocation = _currentPosition != null;
    final subtitle =
        hasLocation
            ? 'Live position: ${_currentPosition!.latitude.toStringAsFixed(5)}, '
                '${_currentPosition!.longitude.toStringAsFixed(5)}'
            : _locationError ?? 'Using the selected venue as the start marker.';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF141417),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Realm Navigator',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              TextButton.icon(
                onPressed: _isFetchingLocation ? null : _loadCurrentLocation,
                icon:
                    _isFetchingLocation
                        ? const SizedBox(
                          width: 14,
                          height: 14,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                        : const Icon(Icons.my_location_rounded, size: 18),
                label: const Text('Locate Me'),
                style: TextButton.styleFrom(
                  foregroundColor: const Color(0xFFE28B9B),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: const TextStyle(
              color: Colors.white60,
              fontSize: 13,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _RouteLegend(
                  title: 'Start',
                  value: hasLocation ? 'Your location' : 'Fallback marker',
                  color: const Color(0xFF5EEAD4),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _RouteLegend(
                  title: 'Destination',
                  value: destination?.name ?? 'Choose a venue',
                  color: const Color(0xFFE28B9B),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            'Projected from ${startPoint.latitude.toStringAsFixed(5)}, '
            '${startPoint.longitude.toStringAsFixed(5)} into campus fantasy space.',
            style: const TextStyle(color: Colors.white38, fontSize: 11),
          ),
        ],
      ),
    );
  }
}

class _FantasyMapCard extends StatelessWidget {
  const _FantasyMapCard({
    required this.bounds,
    required this.venues,
    required this.startPoint,
    required this.selectedVenue,
    required this.pulseValue,
    required this.hasPreciseLocation,
  });

  final _CampusBounds bounds;
  final List<_Venue> venues;
  final _MapPoint startPoint;
  final _Venue? selectedVenue;
  final double pulseValue;
  final bool hasPreciseLocation;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = Size(constraints.maxWidth, constraints.maxHeight);
        final routeTarget = selectedVenue?.point;
        final projectedStart = bounds.project(startPoint, size);
        final projectedEnd =
            routeTarget != null ? bounds.project(routeTarget, size) : null;

        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: const Color(0x33F3D3A2)),
            boxShadow: const [
              BoxShadow(
                color: Color(0x22000000),
                blurRadius: 26,
                offset: Offset(0, 20),
              ),
            ],
          ),
          clipBehavior: Clip.hardEdge,
          child: Stack(
            children: [
              Positioned.fill(
                child: CustomPaint(
                  painter: _FantasyMapPainter(
                    bounds: bounds,
                    venues: venues,
                    startPoint: startPoint,
                    selectedVenue: selectedVenue,
                    pulseValue: pulseValue,
                    hasPreciseLocation: hasPreciseLocation,
                  ),
                ),
              ),
              Positioned(
                top: 18,
                left: 18,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xB219120D),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0x55F5D7A5)),
                  ),
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'KINGDOM OF HESTIA',
                        style: TextStyle(
                          color: Color(0xFFF6E3B4),
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.4,
                          fontSize: 12,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Fantasy routing over real campus GPS',
                        style: TextStyle(
                          color: Color(0xFFD0B98B),
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (projectedEnd != null)
                Positioned(
                  right: 18,
                  bottom: 18,
                  child: _CompassLegend(
                    distanceLabel: _distanceLabel(
                      startPoint,
                      selectedVenue!.point,
                    ),
                  ),
                ),
              _MapLabel(
                offset: projectedStart,
                title: hasPreciseLocation ? 'YOU' : 'START',
                color: const Color(0xFF5EEAD4),
                alignRight: false,
              ),
              if (selectedVenue != null && projectedEnd != null)
                _MapLabel(
                  offset: projectedEnd,
                  title: selectedVenue!.name.toUpperCase(),
                  color: const Color(0xFFE28B9B),
                  alignRight: true,
                ),
            ],
          ),
        );
      },
    );
  }

  String _distanceLabel(_MapPoint start, _MapPoint end) {
    final distance = Geolocator.distanceBetween(
      start.latitude,
      start.longitude,
      end.latitude,
      end.longitude,
    );
    if (distance < 1000) {
      return '${distance.toStringAsFixed(0)} m';
    }
    return '${(distance / 1000).toStringAsFixed(2)} km';
  }
}

class _FantasyMapPainter extends CustomPainter {
  const _FantasyMapPainter({
    required this.bounds,
    required this.venues,
    required this.startPoint,
    required this.selectedVenue,
    required this.pulseValue,
    required this.hasPreciseLocation,
  });

  final _CampusBounds bounds;
  final List<_Venue> venues;
  final _MapPoint startPoint;
  final _Venue? selectedVenue;
  final double pulseValue;
  final bool hasPreciseLocation;

  @override
  void paint(Canvas canvas, Size size) {
    final background =
        Paint()
          ..shader = const LinearGradient(
            colors: [Color(0xFFF0D8A8), Color(0xFFE0BB7B), Color(0xFFC89253)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ).createShader(Offset.zero & size);
    canvas.drawRect(Offset.zero & size, background);

    _paintPaperTexture(canvas, size);
    _paintFantasyTerrain(canvas, size);
    _paintVenueNetwork(canvas, size);
    _paintRoute(canvas, size);
    _paintVenueMarkers(canvas, size);
  }

  void _paintPaperTexture(Canvas canvas, Size size) {
    final borderPaint =
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3
          ..color = const Color(0x806D4B2B);
    final frame = RRect.fromRectAndRadius(
      Offset.zero & size,
      const Radius.circular(28),
    );
    canvas.drawRRect(frame, borderPaint);

    final texture =
        Paint()
          ..color = const Color(0x1A4D3319)
          ..strokeWidth = 1.2;
    for (var i = 0; i < 16; i++) {
      final y = size.height * (i / 15);
      canvas.drawLine(Offset(0, y), Offset(size.width, y + 12), texture);
    }
  }

  void _paintFantasyTerrain(Canvas canvas, Size size) {
    final hillPaint =
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5
          ..color = const Color(0x665F3D22);
    final accentPaint =
        Paint()
          ..color = const Color(0x338A5D2B)
          ..style = PaintingStyle.fill;

    final hillCenters = [
      Offset(size.width * 0.18, size.height * 0.22),
      Offset(size.width * 0.72, size.height * 0.18),
      Offset(size.width * 0.28, size.height * 0.72),
      Offset(size.width * 0.8, size.height * 0.68),
    ];

    for (final center in hillCenters) {
      for (var ring = 1; ring <= 3; ring++) {
        canvas.drawOval(
          Rect.fromCenter(
            center: center,
            width: 80.0 * ring,
            height: 48.0 * ring,
          ),
          hillPaint,
        );
      }
      canvas.drawCircle(center, 18, accentPaint);
    }

    final riverPath =
        Path()
          ..moveTo(size.width * 0.1, size.height * 0.05)
          ..quadraticBezierTo(
            size.width * 0.28,
            size.height * 0.18,
            size.width * 0.22,
            size.height * 0.36,
          )
          ..quadraticBezierTo(
            size.width * 0.14,
            size.height * 0.58,
            size.width * 0.3,
            size.height * 0.92,
          );
    canvas.drawPath(
      riverPath,
      Paint()
        ..color = const Color(0x6654A4C7)
        ..strokeWidth = 12
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round,
    );
  }

  void _paintVenueNetwork(Canvas canvas, Size size) {
    final routePaint =
        Paint()
          ..color = const Color(0x665E3D22)
          ..strokeWidth = 2
          ..style = PaintingStyle.stroke;

    for (var i = 0; i < venues.length - 1; i++) {
      final start = bounds.project(venues[i].point, size);
      final end = bounds.project(venues[i + 1].point, size);
      canvas.drawLine(start, end, routePaint);
    }
  }

  void _paintRoute(Canvas canvas, Size size) {
    if (selectedVenue == null) {
      return;
    }

    final start = bounds.project(startPoint, size);
    final end = bounds.project(selectedVenue!.point, size);
    final midpoint = Offset(
      (start.dx + end.dx) / 2 + 36,
      (start.dy + end.dy) / 2 - 42,
    );

    final path =
        Path()
          ..moveTo(start.dx, start.dy)
          ..quadraticBezierTo(midpoint.dx, midpoint.dy, end.dx, end.dy);

    canvas.drawPath(
      path,
      Paint()
        ..color = const Color(0x99B03A48)
        ..strokeWidth = 10
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round,
    );
    canvas.drawPath(
      path,
      Paint()
        ..color = const Color(0xFFFFF2C0)
        ..strokeWidth = 4
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round,
    );
  }

  void _paintVenueMarkers(Canvas canvas, Size size) {
    final markerPaint = Paint()..color = const Color(0xFF5E3D22);
    final selectedPaint = Paint()..color = const Color(0xFFB03A48);
    final youPaint = Paint()..color = const Color(0xFF0F766E);

    for (final venue in venues) {
      final point = bounds.project(venue.point, size);
      final isSelected = venue == selectedVenue;
      canvas.drawCircle(
        point,
        isSelected ? 8 : 6,
        isSelected ? selectedPaint : markerPaint,
      );
      canvas.drawCircle(
        point,
        isSelected ? 14 : 10,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5
          ..color = (isSelected ? selectedPaint : markerPaint).color.withValues(
            alpha: 0.45,
          ),
      );
    }

    final current = bounds.project(startPoint, size);
    final pulseRadius = 16 + (pulseValue * 14);
    canvas.drawCircle(
      current,
      pulseRadius,
      Paint()..color = const Color(0x445EEAD4),
    );
    canvas.drawCircle(current, 8, hasPreciseLocation ? youPaint : markerPaint);
  }

  @override
  bool shouldRepaint(covariant _FantasyMapPainter oldDelegate) {
    return oldDelegate.startPoint != startPoint ||
        oldDelegate.selectedVenue != selectedVenue ||
        oldDelegate.pulseValue != pulseValue ||
        oldDelegate.hasPreciseLocation != hasPreciseLocation;
  }
}

class _MapLabel extends StatelessWidget {
  const _MapLabel({
    required this.offset,
    required this.title,
    required this.color,
    required this.alignRight,
  });

  final Offset offset;
  final String title;
  final Color color;
  final bool alignRight;

  @override
  Widget build(BuildContext context) {
    final left = alignRight ? null : math.max(8.0, offset.dx - 8).toDouble();
    final right = alignRight ? 8.0 : null;
    final top = math.max(14.0, offset.dy - 34).toDouble();

    return Positioned(
      left: left,
      right: right,
      top: top,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.62),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.65)),
        ),
        child: Text(
          title,
          style: TextStyle(
            color: color,
            fontSize: 10,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.1,
          ),
        ),
      ),
    );
  }
}

class _CompassLegend extends StatelessWidget {
  const _CompassLegend({required this.distanceLabel});

  final String distanceLabel;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xBF1A130F),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0x44F6E3B4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Quest Span',
            style: TextStyle(
              color: Color(0xFFF6E3B4),
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            distanceLabel,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _RouteLegend extends StatelessWidget {
  const _RouteLegend({
    required this.title,
    required this.value,
    required this.color,
  });

  final String title;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF0E0E10),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(color: Colors.white54, fontSize: 11),
                ),
                const SizedBox(height: 3),
                Text(
                  value,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CampusBounds {
  const _CampusBounds({
    required this.north,
    required this.east,
    required this.south,
    required this.west,
  });

  final double north;
  final double east;
  final double south;
  final double west;

  Offset project(_MapPoint point, Size size) {
    final x = ((point.longitude - west) / (east - west)).clamp(0.0, 1.0);
    final y = ((north - point.latitude) / (north - south)).clamp(0.0, 1.0);
    return Offset(24 + (size.width - 48) * x, 24 + (size.height - 48) * y);
  }
}

class _MapPoint {
  const _MapPoint(this.latitude, this.longitude);

  final double latitude;
  final double longitude;
}

class _Venue {
  _Venue(this.name, double latitude, double longitude)
    : point = _MapPoint(latitude, longitude);

  final String name;
  final _MapPoint point;
}
