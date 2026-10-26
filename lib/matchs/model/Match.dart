import 'package:luppy/home/model/Dog.dart';

class MatchCandidate {
  final Dog dog; // name, age, breed, verified badge, main photo
  final List<String> photos;
  final double distanceKm;

  const MatchCandidate({
    required this.dog,
    required this.photos,
    required this.distanceKm,
  });

  /// "Less than 1km" / "3km"
  String get distanceLabel =>
      distanceKm < 1 ? 'Less than 1km' : '${distanceKm.round()}km';

  factory MatchCandidate.fromJson(Map<String, dynamic> json) => MatchCandidate(
    dog: Dog.fromJson(json['dog'] as Map<String, dynamic>),
    photos: (json['photos'] as List).cast<String>(),
    distanceKm: (json['distance_km'] as num).toDouble(),
  );

  Map<String, dynamic> toJson() => {
    'dog': dog.toJson(),
    'photos': photos,
    'distance_km': distanceKm,
  };
}

/// Shown on the "It's a Match" screen: you and the dog that liked you back.
class DogMatch {
  final String id;
  final Dog me;
  final Dog other;
  final DateTime matchedAt;

  const DogMatch({
    required this.id,
    required this.me,
    required this.other,
    required this.matchedAt,
  });

  factory DogMatch.fromJson(Map<String, dynamic> json) => DogMatch(
    id: json['id'] as String,
    me: Dog.fromJson(json['me'] as Map<String, dynamic>),
    other: Dog.fromJson(json['other'] as Map<String, dynamic>),
    matchedAt: DateTime.parse(json['matched_at'] as String),
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'me': me.toJson(),
    'other': other.toJson(),
    'matched_at': matchedAt.toIso8601String(),
  };
}

const myDog = Dog(
  id: 'u_loki',
  name: 'Loki',
  breed: 'Husky',
  age: DogAge(value: 2, unit: AgeUnit.years),
  imageUrl: 'https://images.unsplash.com/photo-1605568427561-40dd23c2acea',
);

List<String> _photos(String name) {
  final photoMap = <String, List<String>>{
    'luna': [
      'https://images.unsplash.com/photo-1543466835-00a7907e9de1',
      'https://images.unsplash.com/photo-1583511655857-d19b40a7a54e',
      'https://images.unsplash.com/photo-1537151625747-768eb6cf92b2',
      'https://images.unsplash.com/photo-1517849845537-4d257902454a',
    ],
    'bobi': [
      'https://images.unsplash.com/photo-1583337130417-3346a1be7dee',
      'https://images.unsplash.com/photo-1546182990-dffeafbe841d',
      'https://images.unsplash.com/photo-1518717758536-85ae29035b6d',
      'https://images.unsplash.com/photo-1530281700549-e82e7bf110d6',
    ],
    'bjorn': [
      'https://images.unsplash.com/photo-1552053831-71594a27632d',
      'https://images.unsplash.com/photo-1561037404-61cd46aa615b',
      'https://images.unsplash.com/photo-1587300003388-59208cc962cb',
      'https://images.unsplash.com/photo-1514989940723-e8e51635b782',
    ],
  };

  return photoMap[name] ?? [];
}

final candidates = <MatchCandidate>[
  MatchCandidate(
    dog: const Dog(
      id: 'c_luna',
      name: 'Luna',
      breed: 'Spitz',
      age: DogAge(value: 6, unit: AgeUnit.months),
      imageUrl: 'https://images.unsplash.com/photo-1543466835-00a7907e9de1',
      isVerified: true,
    ),
    photos: _photos('luna'),
    distanceKm: 0.5,
  ),
  MatchCandidate(
    dog: const Dog(
      id: 'c_bobi',
      name: 'Bobi',
      breed: 'Poodle',
      age: DogAge(value: 1, unit: AgeUnit.years),
      imageUrl: 'https://images.unsplash.com/photo-1583337130417-3346a1be7dee',
      isVerified: true,
    ),
    photos: _photos('bobi'),
    distanceKm: 2.4,
  ),
  MatchCandidate(
    dog: const Dog(
      id: 'c_bjorn',
      name: 'Björn',
      breed: 'Akita',
      age: DogAge(value: 3, unit: AgeUnit.years),
      imageUrl: 'https://images.unsplash.com/photo-1552053831-71594a27632d',
    ),
    photos: _photos('bjorn'),
    distanceKm: 5,
  ),
];

/// Sample data for the Matches screen. Image paths are placeholders.
const likedYouIds = {'c_luna', 'c_bjorn'};
