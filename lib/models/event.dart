class EventCoordinator {
  final String name;
  final String phone;

  EventCoordinator({required this.name, required this.phone});

  factory EventCoordinator.fromJson(Map<String, dynamic> json) {
    return EventCoordinator(
      name: json['name'] ?? '',
      phone: json['phone'] ?? '',
    );
  }
}

class Event {
  final String id;
  final String slug;
  final String title;
  final String tagline;
  final String description;
  final String image;
  final String date;
  final String time;
  final String venue;
  final String regFee;
  final String prizePool;
  final String registrationLink;
  final String instagram;
  final String category;
  final List<EventCoordinator> coordinators;

  Event({
    required this.id,
    required this.slug,
    required this.title,
    required this.tagline,
    required this.description,
    required this.image,
    required this.date,
    required this.time,
    required this.venue,
    required this.regFee,
    required this.prizePool,
    required this.registrationLink,
    required this.instagram,
    required this.category,
    required this.coordinators,
  });

  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
      id: json['_id'] ?? '',
      slug: json['slug'] ?? '',
      title: json['title'] ?? '',
      tagline: json['tagline'] ?? '',
      description: json['description'] ?? '',
      image: json['image'] ?? '',
      date: json['date'] ?? '',
      time: json['time'] ?? '',
      venue: json['venue'] ?? '',
      regFee: json['regFee']?.toString() ?? '',
      prizePool: json['prizePool']?.toString() ?? '',
      registrationLink: json['registrationLink'] ?? '',
      instagram: json['instagram'] ?? '',
      category: json['category'] ?? '',
      coordinators: json['coordinators'] != null
          ? (json['coordinators'] as List<dynamic>)
              .map((e) => EventCoordinator.fromJson(e as Map<String, dynamic>))
              .toList()
          : <EventCoordinator>[],
    );
  }
}
