import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/event.dart';

class EventDetailsScreen extends StatelessWidget {
  final Event event;

  const EventDetailsScreen({super.key, required this.event});

  static const List<String> _monthLabels = [
    'JAN',
    'FEB',
    'MAR',
    'APR',
    'MAY',
    'JUN',
    'JUL',
    'AUG',
    'SEP',
    'OCT',
    'NOV',
    'DEC',
  ];

  DateTime? _parseEventDate(String raw) {
    final value = raw.trim();
    if (value.isEmpty) {
      return null;
    }

    final directParse = DateTime.tryParse(value);
    if (directParse != null) {
      return directParse;
    }

    final normalized = value.replaceAll(',', ' ').replaceAll(RegExp(r'\s+'), ' ');

    final monthNameMatch = RegExp(
      r'\b(jan|feb|mar|apr|may|jun|jul|aug|sep|oct|nov|dec)[a-z]*\b[^\d]*(\d{1,2})(?:[^\d]+(\d{4}))?',
      caseSensitive: false,
    ).firstMatch(normalized);
    if (monthNameMatch != null) {
      final monthToken = (monthNameMatch.group(1) ?? '').toLowerCase();
      final day = int.tryParse(monthNameMatch.group(2) ?? '');
      final year =
          int.tryParse(monthNameMatch.group(3) ?? '') ?? DateTime.now().year;
      final monthIndex = const {
        'jan': 1,
        'feb': 2,
        'mar': 3,
        'apr': 4,
        'may': 5,
        'jun': 6,
        'jul': 7,
        'aug': 8,
        'sep': 9,
        'oct': 10,
        'nov': 11,
        'dec': 12,
      }[monthToken];
      if (monthIndex != null && day != null) {
        return DateTime(year, monthIndex, day);
      }
    }

    final slashOrDashMatch = RegExp(
      r'\b(\d{1,4})[/-](\d{1,2})[/-](\d{1,4})\b',
    ).firstMatch(normalized);
    if (slashOrDashMatch != null) {
      final first = int.tryParse(slashOrDashMatch.group(1) ?? '');
      final second = int.tryParse(slashOrDashMatch.group(2) ?? '');
      final third = int.tryParse(slashOrDashMatch.group(3) ?? '');
      if (first != null && second != null && third != null) {
        if (first > 999) {
          return DateTime(first, second, third);
        }
        if (third > 999) {
          return DateTime(third, second, first);
        }
      }
    }

    return null;
  }

  String _getMonth(String dateStr) {
    final parsed = _parseEventDate(dateStr);
    if (parsed == null) {
      return 'DATE';
    }
    return _monthLabels[parsed.month - 1];
  }

  String _getDay(String dateStr) {
    final parsed = _parseEventDate(dateStr);
    if (parsed == null) {
      return '--';
    }
    return parsed.day.toString().padLeft(2, '0');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B0B0C),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Stack(
              children: [
                // Event Image Background
                SizedBox(
                  height: 480,
                  width: double.infinity,
                  child: Image.network(
                    event.image,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(color: const Color(0xFF1B1B1D));
                    },
                  ),
                ),
                // Gradient Fade to Bottom
                Container(
                  height: 480,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withValues(alpha: 0.2),
                        const Color(0xFF0B0B0C).withValues(alpha: 0.5),
                        const Color(0xFF0B0B0C).withValues(alpha: 0.9),
                        const Color(0xFF0B0B0C),
                      ],
                      stops: const [0.0, 0.5, 0.8, 1.0],
                    ),
                  ),
                ),
                // Custom App Bar layer
                SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2),
                            ),
                            child: const Padding(
                              padding: EdgeInsets.only(left: 6.0), // Center the arrow visually
                              child: Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
                            ),
                          ),
                        ),
                        Image.asset(
                          'assets/hestia-logo-final-1.png',
                          height: 40,
                          errorBuilder: (context, error, stackTrace) => const SizedBox(height: 40),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            
            // Textual Details Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  ShaderMask(
                    shaderCallback: (bounds) => const LinearGradient(
                      colors: [Colors.white, Color(0xFFE28B9B)],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ).createShader(bounds),
                    child: Text(
                      event.title.toUpperCase(),
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Date and Quote Row
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 80,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1B1B1D),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          children: [
                            Text(
                              _getMonth(event.date),
                              style: const TextStyle(color: Colors.white70, fontWeight: FontWeight.bold, fontSize: 14, letterSpacing: 1),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _getDay(event.date),
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 26),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 20),
                      if (event.tagline.isNotEmpty)
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                              '"${event.tagline}"',
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 16,
                                fontStyle: FontStyle.italic,
                                height: 1.5,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),

                  const SizedBox(height: 32),

                  // Event Description
                  Text(
                    event.description.isNotEmpty ? event.description : 'No detailed description available for this event.',
                    style: const TextStyle(
                      color: Colors.white54,
                      fontSize: 14,
                      height: 1.6,
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Prize Pool, Reg Fee and Coordinators Row
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Column(
                        children: [
                          if (event.prizePool.isNotEmpty)
                            Container(
                              width: 110,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(
                                color: const Color(0xFF1B1B1D),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Text(
                                    'PRIZE POOL',
                                    style: TextStyle(color: Colors.white70, fontSize: 10, letterSpacing: 1, fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(height: 4),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                    child: FittedBox(
                                      fit: BoxFit.scaleDown,
                                      child: Text(
                                        event.prizePool,
                                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 24),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          if (event.prizePool.isNotEmpty) const SizedBox(height: 12),
                          Container(
                            width: 110,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              color: const Color(0xFF1B1B1D),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text(
                                  'REG FEE',
                                  style: TextStyle(color: Colors.white70, fontSize: 10, letterSpacing: 1, fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 4),
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                  child: FittedBox(
                                    fit: BoxFit.scaleDown,
                                    child: Text(
                                      event.regFee.isNotEmpty ? event.regFee : 'TBA',
                                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 24),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            const Text(
                              'COORDINATORS',
                              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14, letterSpacing: 1),
                            ),
                            const SizedBox(height: 8),
                            if (event.coordinators.isEmpty)
                              const Text('TBA', style: TextStyle(color: Colors.white54, fontSize: 13, height: 1.4)),
                            ...event.coordinators.map((coordinator) {
                              return Text(
                                '${coordinator.name.toUpperCase()} : ${coordinator.phone}', 
                                style: const TextStyle(color: Colors.white54, fontSize: 13, height: 1.4),
                              );
                            }),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 48),

                  // Register Button
                  Center(
                    child: Container(
                      width: double.infinity,
                      height: 56,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.white24),
                      ),
                      child: ElevatedButton(
                        onPressed: () async {
                          if (event.registrationLink.isEmpty) return;
                          String link = event.registrationLink;
                          if (!link.startsWith('http://') && !link.startsWith('https://')) {
                            link = 'https://$link';
                          }
                          final url = Uri.parse(link);
                          try {
                            // ignore: deprecated_member_use
                            if (await canLaunchUrl(url)) {
                              // ignore: deprecated_member_use
                              await launchUrl(url, mode: LaunchMode.externalApplication);
                            }
                          } catch (e) {
                            debugPrint('Could not launch $link: $e');
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        child: ShaderMask(
                          shaderCallback: (bounds) => const LinearGradient(
                            colors: [Color(0xFFE28B9B), Color(0xFF9070E0)],
                          ).createShader(bounds),
                          child: Text(
                            event.registrationLink.isNotEmpty ? 'REGISTER NOW' : 'REGISTRATION CLOSED',
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1.5, color: Colors.white),
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 48),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
