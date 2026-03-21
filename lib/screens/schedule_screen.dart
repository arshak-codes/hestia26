import 'package:flutter/material.dart';

import '../models/schedule_event.dart';
import '../services/schedule_service.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/hestia_loader.dart';

class ScheduleScreen extends StatefulWidget {
  const ScheduleScreen({super.key});

  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
  final ScheduleService _scheduleService = ScheduleService();
  String? _selectedDay;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'SCHEDULE'),
      body: StreamBuilder<List<String>>(
        stream: _scheduleService.streamScheduleDays(),
        builder: (context, daySnapshot) {
          if (daySnapshot.hasError) {
            return const _ScheduleState(
              title: 'Schedule unavailable',
              subtitle: 'Could not load the live schedule right now.',
            );
          }

          if (!daySnapshot.hasData) {
            return const Center(
              child: HestiaLoader(label: 'Loading schedule'),
            );
          }

          final days = daySnapshot.data!;
          if (days.isEmpty) {
            return const _ScheduleState(
              title: 'No schedule published',
              subtitle: 'Live events will appear here once they are added.',
            );
          }

          final selectedDay =
              days.contains(_selectedDay) ? _selectedDay! : days.first;

          return Column(
            children: [
              const SizedBox(height: 10),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children:
                      days.map((day) {
                        final isSelected = day == selectedDay;
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedDay = day;
                            });
                          },
                          child: Container(
                            margin: const EdgeInsets.only(right: 12),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color:
                                    isSelected
                                        ? Colors.transparent
                                        : Colors.white24,
                              ),
                              gradient:
                                  isSelected
                                      ? const LinearGradient(
                                        colors: [
                                          Color(0xFFE28B9B),
                                          Color(0xFF9070E0),
                                        ],
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      )
                                      : null,
                              color: isSelected ? null : Colors.transparent,
                            ),
                            child: Text(
                              _formatDayLabel(day),
                              style: TextStyle(
                                color: isSelected ? Colors.white : Colors.white54,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.2,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                ),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: StreamBuilder<List<ScheduleEvent>>(
                  stream: _scheduleService.streamEventsForDay(selectedDay),
                  builder: (context, eventSnapshot) {
                    if (eventSnapshot.hasError) {
                      return const _ScheduleState(
                        title: 'Events unavailable',
                        subtitle: 'Could not load events for this day.',
                      );
                    }

                    if (!eventSnapshot.hasData) {
                      return const Center(
                        child: HestiaLoader(label: 'Loading events'),
                      );
                    }

                    final events = eventSnapshot.data!;
                    if (events.isEmpty) {
                      return const _ScheduleState(
                        title: 'No events for this day',
                        subtitle:
                            'This schedule slot is empty right now. Check again soon.',
                      );
                    }

                    return ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: events.length,
                      itemBuilder: (context, index) {
                        final event = events[index];
                        return _ScheduleEventCard(event: event);
                      },
                    );
                  },
                ),
              ),
              const SizedBox(height: 100),
            ],
          );
        },
      ),
    );
  }

  static String _formatDayLabel(String value) {
    final normalized = value.trim();
    final match = RegExp(
      r'^([a-zA-Z]{3})(\d{1,2})$',
    ).firstMatch(normalized);
    if (match == null) {
      return normalized.toUpperCase();
    }

    final month = (match.group(1) ?? '').toUpperCase();
    final day = (match.group(2) ?? '').padLeft(2, '0');
    return '$month $day';
  }
}

class _ScheduleEventCard extends StatelessWidget {
  const _ScheduleEventCard({required this.event});

  final ScheduleEvent event;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF131316),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white12, width: 1),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              event.name.toUpperCase(),
              style: const TextStyle(
                color: Colors.white70,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.1,
                fontSize: 14,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                event.stage.toUpperCase(),
                style: const TextStyle(
                  color: Colors.white38,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                event.time,
                style: const TextStyle(color: Colors.white54, fontSize: 12),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ScheduleState extends StatelessWidget {
  const _ScheduleState({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white60,
                fontSize: 14,
                height: 1.45,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
