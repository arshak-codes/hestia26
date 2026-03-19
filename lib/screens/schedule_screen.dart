import 'package:flutter/material.dart';
import '../widgets/custom_app_bar.dart';

class ScheduleScreen extends StatefulWidget {
  const ScheduleScreen({super.key});

  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
  int _selectedDayIndex = 0;
  final List<String> _days = ['MAR 22', 'MAR 23', 'MAR 24'];

  final List<Map<String, String>> _events = [
    {'title': 'INAUGURATION', 'stage': 'MAIN STAGE', 'time': '4:00 PM'},
    {'title': 'STOMP THE YARD', 'stage': 'MAIN STAGE', 'time': '4:00 PM'},
    {'title': 'DANCE ITEM', 'stage': 'MAIN STAGE', 'time': '4:00 PM'},
    {'title': 'MUSIC SHOW', 'stage': 'MAIN STAGE', 'time': '4:00 PM'},
    {'title': 'SPORTS', 'stage': 'MAIN STAGE', 'time': '4:00 PM'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'SCHEDULE'),
      body: Column(
        children: [
          const SizedBox(height: 10),
          // Date Tabs
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: List.generate(_days.length, (index) {
                final isSelected = _selectedDayIndex == index;
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedDayIndex = index;
                    });
                  },
                  child: Container(
                    margin: const EdgeInsets.only(right: 12),
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isSelected ? Colors.transparent : Colors.white24,
                      ),
                      gradient: isSelected
                          ? const LinearGradient(
                              colors: [Color(0xFFE28B9B), Color(0xFF9070E0)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            )
                          : null,
                      color: isSelected ? null : Colors.transparent,
                    ),
                    child: Text(
                      _days[index],
                      style: TextStyle(
                        color: isSelected ? Colors.white : Colors.white54,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
          const SizedBox(height: 20),
          // Events List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _events.length,
              itemBuilder: (context, index) {
                final event = _events[index];
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
                      Text(
                        event['title']!,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.1,
                          fontSize: 14,
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            event['stage']!,
                            style: const TextStyle(
                              color: Colors.white38,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            event['time']!,
                            style: const TextStyle(
                              color: Colors.white54,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 100), // padding for bottom nav
        ],
      ),
    );
  }
}
