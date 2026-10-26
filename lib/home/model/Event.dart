// A person/avatar attached to an event (members list and group admin).
class Member {
  final String id;
  final String name;
  final String avatarUrl;
  final bool isOnline;

  const Member({
    required this.id,
    required this.name,
    required this.avatarUrl,
    this.isOnline = false,
  });

  factory Member.fromJson(Map<String, dynamic> json) => Member(
    id: json['id'] as String,
    name: json['name'] as String,
    avatarUrl: json['avatar_url'] as String,
    isOnline: json['is_online'] as bool? ?? false,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'avatar_url': avatarUrl,
    'is_online': isOnline,
  };
}

class EventLocation {
  final String? venueName; // e.g. "Dog Park" (shown on the home card)
  final String address; // "Bark Park 123 Main Street, Anytown, CA 12345"

  const EventLocation({this.venueName, required this.address});

  factory EventLocation.fromJson(Map<String, dynamic> json) => EventLocation(
    venueName: json['venue_name'] as String?,
    address: json['address'] as String,
  );

  Map<String, dynamic> toJson() => {
    'venue_name': venueName,
    'address': address,
  };
}

/// An event: used in "Top Events" cards and the Event Details screen.
class Event {
  final String id;
  final String name;
  final String description;
  final DateTime startsAt;
  final DateTime endsAt;
  final EventLocation location;
  final List<Member> members;
  final Member admin;
  final bool hasJoined; // toggles the "Join Us" button

  const Event({
    required this.id,
    required this.name,
    required this.description,
    required this.startsAt,
    required this.endsAt,
    required this.location,
    required this.members,
    required this.admin,
    this.hasJoined = false,
  });

  int get memberCount => members.length;

  Event copyWith({
    String? name,
    String? description,
    DateTime? startsAt,
    DateTime? endsAt,
    EventLocation? location,
    List<Member>? members,
    Member? admin,
    bool? hasJoined,
  }) => Event(
    id: id,
    name: name ?? this.name,
    description: description ?? this.description,
    startsAt: startsAt ?? this.startsAt,
    endsAt: endsAt ?? this.endsAt,
    location: location ?? this.location,
    members: members ?? this.members,
    admin: admin ?? this.admin,
    hasJoined: hasJoined ?? this.hasJoined,
  );

  factory Event.fromJson(Map<String, dynamic> json) => Event(
    id: json['id'] as String,
    name: json['name'] as String,
    description: json['description'] as String,
    startsAt: DateTime.parse(json['starts_at'] as String),
    endsAt: DateTime.parse(json['ends_at'] as String),
    location: EventLocation.fromJson(json['location'] as Map<String, dynamic>),
    members: (json['members'] as List)
        .map((m) => Member.fromJson(m as Map<String, dynamic>))
        .toList(),
    admin: Member.fromJson(json['admin'] as Map<String, dynamic>),
    hasJoined: json['has_joined'] as bool? ?? false,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'description': description,
    'starts_at': startsAt.toIso8601String(),
    'ends_at': endsAt.toIso8601String(),
    'location': location.toJson(),
    'members': members.map((m) => m.toJson()).toList(),
    'admin': admin.toJson(),
    'has_joined': hasJoined,
  };
}

// /// Everything the Home screen renders.
// class HomeFeed {
//   final List<Dog> newMatches;
//   final List<Dog> popularDogs;
//   final List<Event> topEvents;

//   const HomeFeed({
//     required this.newMatches,
//     required this.popularDogs,
//     required this.topEvents,
//   });

//   factory HomeFeed.fromJson(Map<String, dynamic> json) => HomeFeed(
//         newMatches: (json['new_matches'] as List)
//             .map((e) => Dog.fromJson(e as Map<String, dynamic>))
//             .toList(),
//         popularDogs: (json['popular_dogs'] as List)
//             .map((e) => Dog.fromJson(e as Map<String, dynamic>))
//             .toList(),
//         topEvents: (json['top_events'] as List)
//             .map((e) => Event.fromJson(e as Map<String, dynamic>))
//             .toList(),
//       );
// }
