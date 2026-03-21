import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:geolocator/geolocator.dart';

import '../widgets/custom_app_bar.dart';
import '../widgets/hestia_loader.dart';

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

  late final Future<_SvgAssetData> _svgAssetFuture;
  late final AnimationController _pulseController;

  _Venue? _selectedVenue = _venues[4];
  Position? _currentPosition;
  String? _locationError;
  bool _isFetchingLocation = true;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);
    _svgAssetFuture = _loadSvgAssetData();
    _loadCurrentLocation();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _loadCurrentLocation() async {
    if (!mounted) {
      return;
    }

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
    final mainEntrance = _venues.first;
    final userPoint =
        _currentPosition != null
            ? _MapPoint(_currentPosition!.latitude, _currentPosition!.longitude)
            : null;
    final hasPreciseLocation =
        userPoint != null && _campusBounds.contains(userPoint);
    final usesEntranceStart = !hasPreciseLocation;
    final startPoint = hasPreciseLocation ? userPoint : mainEntrance.point;
    final destination = _selectedVenue;

    return Scaffold(
      appBar: const CustomAppBar(title: 'MAP'),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: _buildControlPanel(
                startPoint,
                destination,
                hasPreciseLocation: hasPreciseLocation,
                usesEntranceStart: usesEntranceStart,
              ),
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
              child: FutureBuilder<_SvgAssetData>(
                future: _svgAssetFuture,
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return const Padding(
                      padding: EdgeInsets.fromLTRB(16, 0, 16, 16),
                      child: _MapLoadFallback(),
                    );
                  }

                  if (!snapshot.hasData) {
                    return const Padding(
                      padding: EdgeInsets.fromLTRB(16, 0, 16, 16),
                      child: Center(child: HestiaLoader(label: 'Loading map')),
                    );
                  }

                  return Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    child: AnimatedBuilder(
                      animation: _pulseController,
                      builder: (context, _) {
                        return _CampusSvgMapCard(
                          svgData: snapshot.data!,
                          bounds: _campusBounds,
                          venues: _venues,
                          startPoint: startPoint,
                          selectedVenue: destination,
                          pulseValue: _pulseController.value,
                          hasPreciseLocation: hasPreciseLocation,
                          usesEntranceStart: usesEntranceStart,
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildControlPanel(
    _MapPoint startPoint,
    _Venue? destination, {
    required bool hasPreciseLocation,
    required bool usesEntranceStart,
  }) {
    final subtitle =
        hasPreciseLocation
            ? 'Live position: ${_currentPosition!.latitude.toStringAsFixed(5)}, '
                '${_currentPosition!.longitude.toStringAsFixed(5)}'
            : _locationError != null
            ? '$_locationError Routing starts from Main Entrance.'
            : _currentPosition != null
            ? 'Outside campus bounds. Routing starts from Main Entrance.'
            : 'Using Main Entrance as the start marker.';

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
                  'Campus Navigator',
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
                          child: HestiaLoader(size: 14, compact: true),
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
                  value: hasPreciseLocation ? 'Your location' : 'Main Entrance',
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
            'Anchored to the TKMCE campus map from '
            '${startPoint.latitude.toStringAsFixed(5)}, '
            '${startPoint.longitude.toStringAsFixed(5)}.',
            style: const TextStyle(color: Colors.white38, fontSize: 11),
          ),
        ],
      ),
    );
  }

  Future<_SvgAssetData> _loadSvgAssetData() async {
    final rawSvg = await rootBundle.loadString('assets/Frame 1.svg');
    try {
      return _SvgAssetData.fromSvg(rawSvg);
    } catch (_) {
      return _SvgAssetData.fallback(rawSvg);
    }
  }
}

class _CampusSvgMapCard extends StatelessWidget {
  const _CampusSvgMapCard({
    required this.svgData,
    required this.bounds,
    required this.venues,
    required this.startPoint,
    required this.selectedVenue,
    required this.pulseValue,
    required this.hasPreciseLocation,
    required this.usesEntranceStart,
  });

  final _SvgAssetData svgData;
  final _CampusBounds bounds;
  final List<_Venue> venues;
  final _MapPoint startPoint;
  final _Venue? selectedVenue;
  final double pulseValue;
  final bool hasPreciseLocation;
  final bool usesEntranceStart;

  @override
  Widget build(BuildContext context) {
    final routeTarget = selectedVenue?.point;
    final buildingId = _buildingIdForVenue(selectedVenue?.name);
    final overlaySvg = svgData.buildBuildingOverlaySvg(buildingId: buildingId);

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF0E0E11),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: Colors.white12),
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
            child: InteractiveViewer(
              minScale: 1,
              maxScale: 4,
              boundaryMargin: const EdgeInsets.all(24),
              child: AspectRatio(
                aspectRatio: _CampusBounds.svgWidth / _CampusBounds.svgHeight,
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final size = Size(
                      constraints.maxWidth,
                      constraints.maxHeight,
                    );
                    final projectedStart = bounds.project(startPoint, size);
                    final projectedEnd =
                        routeTarget != null
                            ? bounds.project(routeTarget, size)
                            : null;

                    return Stack(
                      children: [
                        Positioned.fill(
                          child: SvgPicture.string(
                            svgData.rawSvg,
                            fit: BoxFit.cover,
                          ),
                        ),
                        if (overlaySvg != null)
                          Positioned.fill(
                            child: IgnorePointer(
                              child: SvgPicture.string(
                                overlaySvg,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        Positioned.fill(
                          child: CustomPaint(
                            painter: _CampusMarkerPainter(
                              bounds: bounds,
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
                              color: Colors.black.withValues(alpha: 0.66),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: Colors.white12),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'TKMCE CAMPUS MAP',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 1.2,
                                    fontSize: 12,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  usesEntranceStart
                                      ? 'Starting from Main Entrance'
                                      : 'Pinch to zoom and inspect venues',
                                  style: TextStyle(
                                    color: Colors.white60,
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
                            alignRight: projectedEnd.dx > size.width * 0.62,
                          ),
                      ],
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
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

  String? _buildingIdForVenue(String? venueName) {
    switch ((venueName ?? '').toLowerCase()) {
      case 'architecture block':
        return 'Architecture block';
      case 'workshop block':
        return 'Workshop block';
      case 'chemical block':
        return 'chemical block';
      case 'auditorium':
        return 'Auditorium';
      default:
        return null;
    }
  }
}

class _CampusMarkerPainter extends CustomPainter {
  const _CampusMarkerPainter({
    required this.bounds,
    required this.startPoint,
    required this.selectedVenue,
    required this.pulseValue,
    required this.hasPreciseLocation,
  });

  final _CampusBounds bounds;
  final _MapPoint startPoint;
  final _Venue? selectedVenue;
  final double pulseValue;
  final bool hasPreciseLocation;

  @override
  void paint(Canvas canvas, Size size) {
    final markerPaint = Paint()..color = Colors.white.withValues(alpha: 0.78);
    final selectedPaint = Paint()..color = const Color(0xFFE28B9B);
    final youPaint = Paint()..color = const Color(0xFF5EEAD4);

    final current = bounds.project(startPoint, size);
    final pulseRadius = 10 + (pulseValue * 12);
    canvas.drawCircle(
      current,
      pulseRadius,
      Paint()..color = const Color(0x445EEAD4),
    );
    canvas.drawCircle(current, 8, hasPreciseLocation ? youPaint : markerPaint);

    if (selectedVenue != null) {
      final point = bounds.project(selectedVenue!.point, size);
      canvas.drawCircle(point, 7, selectedPaint);
      canvas.drawCircle(
        point,
        12,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.2
          ..color = selectedPaint.color.withValues(alpha: 0.45),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _CampusMarkerPainter oldDelegate) {
    return oldDelegate.startPoint != startPoint ||
        oldDelegate.selectedVenue != selectedVenue ||
        oldDelegate.pulseValue != pulseValue ||
        oldDelegate.hasPreciseLocation != hasPreciseLocation;
  }
}

class _MapLoadFallback extends StatelessWidget {
  const _MapLoadFallback();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF0E0E11),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: Colors.white12),
      ),
      clipBehavior: Clip.hardEdge,
      child: SvgPicture.asset('assets/Frame 1.svg', fit: BoxFit.cover),
    );
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
    final left = alignRight ? null : math.max(10.0, offset.dx - 18).toDouble();
    final right = alignRight ? 10.0 : null;
    final top = math.max(14.0, offset.dy - 38).toDouble();

    return Positioned(
      left: left,
      right: right,
      top: top,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 172),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.62),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color.withValues(alpha: 0.65)),
          ),
          child: Text(
            title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: color,
              fontSize: 10,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.1,
            ),
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
            'Distance',
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

  static const double svgWidth = 717;
  static const double svgHeight = 1246;
  static const double mapLeft = 87;
  static const double mapTop = 188;
  static const double mapRight = 630;
  static const double mapBottom = 1001;

  final double north;
  final double east;
  final double south;
  final double west;

  Offset project(_MapPoint point, Size size) {
    return projectSvg(projectToSvg(point), size);
  }

  Offset projectSvg(_SvgPoint point, Size size) {
    return Offset(
      (point.x / svgWidth) * size.width,
      (point.y / svgHeight) * size.height,
    );
  }

  bool contains(_MapPoint point) {
    return point.latitude <= north &&
        point.latitude >= south &&
        point.longitude >= west &&
        point.longitude <= east;
  }

  _SvgPoint projectToSvg(_MapPoint point) {
    final x = ((point.longitude - west) / (east - west)).clamp(0.0, 1.0);
    final y = ((north - point.latitude) / (north - south)).clamp(0.0, 1.0);
    return _SvgPoint(
      mapLeft + (mapRight - mapLeft) * x,
      mapTop + (mapBottom - mapTop) * y,
    );
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

class _SvgPoint {
  const _SvgPoint(this.x, this.y);

  final double x;
  final double y;

  String get key => '${x.toStringAsFixed(3)},${y.toStringAsFixed(3)}';

  double distanceTo(_SvgPoint other) {
    final dx = x - other.x;
    final dy = y - other.y;
    return math.sqrt((dx * dx) + (dy * dy));
  }
}

class _SvgAssetData {
  const _SvgAssetData({
    required this.rawSvg,
    required this.pathById,
    required this.routeNetwork,
  });

  final String rawSvg;
  final Map<String, String> pathById;
  final _RouteNetwork routeNetwork;

  factory _SvgAssetData.fromSvg(String rawSvg) {
    final pathById = <String, String>{};
    final regex = RegExp(r'<path[^>]*id="([^"]+)"[^>]*d="([^"]+)"[^>]*/?>');
    for (final match in regex.allMatches(rawSvg)) {
      final id = match.group(1);
      final d = match.group(2);
      if (id != null && d != null) {
        pathById[id] = d;
      }
    }
    return _SvgAssetData(
      rawSvg: rawSvg,
      pathById: pathById,
      routeNetwork: _RouteNetwork.fromPathMap(
        Map.fromEntries(
          pathById.entries.where(
            (entry) => entry.key.toLowerCase().contains('route'),
          ),
        ),
      ),
    );
  }

  factory _SvgAssetData.fallback(String rawSvg) {
    return const _SvgAssetData(
      rawSvg: '',
      pathById: {},
      routeNetwork: _RouteNetwork(nodes: {}, edges: {}, segments: []),
    ).copyWithRawSvg(rawSvg);
  }

  List<List<_SvgPoint>> buildHighlightPolylines({
    required _SvgPoint startPoint,
    required _SvgPoint? destinationPoint,
    required List<String> fallbackRouteIds,
  }) {
    if (destinationPoint != null) {
      final routePoints = routeNetwork.buildPathPoints(
        startPoint,
        destinationPoint,
      );
      if (routePoints.length >= 2) {
        return [routePoints];
      }
    }

    final polylines = <List<_SvgPoint>>[];
    for (final routeId in fallbackRouteIds) {
      final path = pathById[routeId];
      if (path == null || path.isEmpty) {
        continue;
      }
      polylines.addAll(_RouteNetwork.parseSvgSubpaths(path));
    }
    return polylines;
  }

  String? buildBuildingOverlaySvg({required String? buildingId}) {
    final buffer =
        StringBuffer()..writeln(
          '<svg width="717" height="1246" viewBox="0 0 717 1246" fill="none" xmlns="http://www.w3.org/2000/svg">',
        );
    var hasContent = false;
    if (buildingId != null) {
      final buildingPath = pathById[buildingId];
      if (buildingPath != null) {
        hasContent = true;
        buffer.writeln(
          '<path d="$buildingPath" fill="#E28B9B" fill-opacity="0.16" stroke="#E28B9B" stroke-width="3"/>',
        );
      }
    }

    buffer.writeln('</svg>');
    return hasContent ? buffer.toString() : null;
  }

  _SvgAssetData copyWithRawSvg(String rawSvg) {
    return _SvgAssetData(
      rawSvg: rawSvg,
      pathById: pathById,
      routeNetwork: routeNetwork,
    );
  }
}

class _RouteNetwork {
  const _RouteNetwork({
    required this.nodes,
    required this.edges,
    required this.segments,
  });

  final Map<String, _SvgPoint> nodes;
  final Map<String, List<_RouteEdge>> edges;
  final List<_RouteSegment> segments;

  factory _RouteNetwork.fromPathMap(Map<String, String> pathById) {
    final nodes = <String, _SvgPoint>{};
    final edges = <String, List<_RouteEdge>>{};
    final segments = <_RouteSegment>[];

    String nodeIdFor(_SvgPoint point) {
      final key = point.key;
      nodes.putIfAbsent(key, () => point);
      edges.putIfAbsent(key, () => <_RouteEdge>[]);
      return key;
    }

    for (final d in pathById.values) {
      final subpaths = parseSvgSubpaths(d);
      for (final subpath in subpaths) {
        for (var i = 0; i < subpath.length - 1; i++) {
          final start = subpath[i];
          final end = subpath[i + 1];
          final startId = nodeIdFor(start);
          final endId = nodeIdFor(end);
          final distance = start.distanceTo(end);
          segments.add(
            _RouteSegment(
              startId: startId,
              endId: endId,
              start: start,
              end: end,
            ),
          );
          edges[startId]!.add(_RouteEdge(endId, distance));
          edges[endId]!.add(_RouteEdge(startId, distance));
        }
      }
    }

    return _RouteNetwork(nodes: nodes, edges: edges, segments: segments);
  }

  List<_SvgPoint> buildPathPoints(
    _SvgPoint startPoint,
    _SvgPoint destinationPoint,
  ) {
    if (segments.isEmpty) {
      return const [];
    }

    final startAnchor = _nearestAnchor(startPoint, 'start');
    final endAnchor = _nearestAnchor(destinationPoint, 'end');
    final graphNodes = <String, _SvgPoint>{...nodes};
    final graphEdges = <String, List<_RouteEdge>>{
      for (final entry in edges.entries)
        entry.key: List<_RouteEdge>.from(entry.value),
    };

    void attachAnchor(_Anchor anchor) {
      graphNodes[anchor.id] = anchor.point;
      graphEdges.putIfAbsent(anchor.id, () => <_RouteEdge>[]);

      final toStart = anchor.point.distanceTo(anchor.segment.start);
      final toEnd = anchor.point.distanceTo(anchor.segment.end);

      graphEdges[anchor.id]!.add(_RouteEdge(anchor.segment.startId, toStart));
      graphEdges[anchor.id]!.add(_RouteEdge(anchor.segment.endId, toEnd));
      graphEdges[anchor.segment.startId]!.add(_RouteEdge(anchor.id, toStart));
      graphEdges[anchor.segment.endId]!.add(_RouteEdge(anchor.id, toEnd));
    }

    attachAnchor(startAnchor);
    attachAnchor(endAnchor);

    if (startAnchor.segment.sameAs(endAnchor.segment)) {
      final directDistance = startAnchor.point.distanceTo(endAnchor.point);
      graphEdges[startAnchor.id]!.add(_RouteEdge(endAnchor.id, directDistance));
      graphEdges[endAnchor.id]!.add(_RouteEdge(startAnchor.id, directDistance));
    }

    final nodePath = _shortestPath(
      startAnchor.id,
      endAnchor.id,
      graphNodes.keys,
      graphEdges,
    );
    if (nodePath.isEmpty) {
      return const [];
    }

    final points = <_SvgPoint>[];
    for (var i = 0; i < nodePath.length; i++) {
      final point = graphNodes[nodePath[i]];
      if (point == null) {
        continue;
      }
      if (points.isEmpty || points.last.key != point.key) {
        points.add(point);
      }
    }
    return points;
  }

  _Anchor _nearestAnchor(_SvgPoint point, String prefix) {
    var bestDistance = double.infinity;
    _RouteSegment? bestSegment;
    _SvgPoint? bestProjection;

    for (final segment in segments) {
      final projection = segment.project(point);
      final distance = point.distanceTo(projection);
      if (distance < bestDistance) {
        bestDistance = distance;
        bestSegment = segment;
        bestProjection = projection;
      }
    }

    return _Anchor(
      id: '$prefix-${bestProjection!.key}',
      point: bestProjection,
      segment: bestSegment!,
    );
  }

  static List<String> _shortestPath(
    String startId,
    String endId,
    Iterable<String> nodeIds,
    Map<String, List<_RouteEdge>> edges,
  ) {
    final distances = <String, double>{
      for (final id in nodeIds) id: double.infinity,
    };
    final previous = <String, String?>{};
    final unvisited = nodeIds.toSet();
    distances[startId] = 0;

    while (unvisited.isNotEmpty) {
      String? current;
      var minDistance = double.infinity;

      for (final id in unvisited) {
        final distance = distances[id] ?? double.infinity;
        if (distance < minDistance) {
          minDistance = distance;
          current = id;
        }
      }

      if (current == null || minDistance == double.infinity) {
        break;
      }

      unvisited.remove(current);
      if (current == endId) {
        break;
      }

      for (final edge in edges[current] ?? const <_RouteEdge>[]) {
        if (!unvisited.contains(edge.toId)) {
          continue;
        }

        final alternative =
            (distances[current] ?? double.infinity) + edge.distance;
        if (alternative < (distances[edge.toId] ?? double.infinity)) {
          distances[edge.toId] = alternative;
          previous[edge.toId] = current;
        }
      }
    }

    final path = <String>[];
    String? cursor = endId;
    while (cursor != null) {
      path.insert(0, cursor);
      if (cursor == startId) {
        return path;
      }
      cursor = previous[cursor];
    }

    return const <String>[];
  }

  static List<List<_SvgPoint>> parseSvgSubpaths(String d) {
    final tokens =
        RegExp(
          r'[ML]|-?\d+(?:\.\d+)?',
        ).allMatches(d).map((match) => match.group(0)!).toList();
    final subpaths = <List<_SvgPoint>>[];
    String? command;
    var index = 0;

    while (index < tokens.length) {
      final token = tokens[index];
      if (token == 'M' || token == 'L') {
        command = token;
        index++;
        continue;
      }

      if (command == null || index + 1 >= tokens.length) {
        break;
      }

      final point = _SvgPoint(
        double.parse(tokens[index]),
        double.parse(tokens[index + 1]),
      );
      if (command == 'M' || subpaths.isEmpty) {
        subpaths.add([point]);
        command = 'L';
      } else {
        subpaths.last.add(point);
      }
      index += 2;
    }

    return subpaths.where((subpath) => subpath.length > 1).toList();
  }
}

class _RouteEdge {
  const _RouteEdge(this.toId, this.distance);

  final String toId;
  final double distance;
}

class _RouteSegment {
  const _RouteSegment({
    required this.startId,
    required this.endId,
    required this.start,
    required this.end,
  });

  final String startId;
  final String endId;
  final _SvgPoint start;
  final _SvgPoint end;

  _SvgPoint project(_SvgPoint point) {
    final dx = end.x - start.x;
    final dy = end.y - start.y;
    final lengthSquared = (dx * dx) + (dy * dy);
    if (lengthSquared == 0) {
      return start;
    }
    final t =
        (((point.x - start.x) * dx) + ((point.y - start.y) * dy)) /
        lengthSquared;
    final clamped = t.clamp(0.0, 1.0);
    return _SvgPoint(start.x + (dx * clamped), start.y + (dy * clamped));
  }

  bool sameAs(_RouteSegment other) {
    return (startId == other.startId && endId == other.endId) ||
        (startId == other.endId && endId == other.startId);
  }
}

class _Anchor {
  const _Anchor({required this.id, required this.point, required this.segment});

  final String id;
  final _SvgPoint point;
  final _RouteSegment segment;
}
