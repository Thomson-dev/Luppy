 // DogGender, DogSize, Temperament, DogInterest

import 'package:luppy/auth/model/sign_up_models.dart';
import 'package:luppy/home/model/Dog.dart';

/// Models for the Profile, Edit Profile and Preview Profile screens.

/// The logged-in user's dog profile. Everything on the three screens
/// (header, edit form, preview card) is read from this one object.
class DogProfile {
  static const maxPhotos = 6; // six picture slots on the edit screen

  final String id;
  final String name;
  final String about; // "About me", up to 450 characters
  final DateTime? birthDate;
  final String breed;
  final DogGender? gender;
  final DogSize? size;
  final List<String> photos; // first photo is the avatar
  final Set<Temperament> temperaments;
  final Set<DogInterest> interests;
  final double energyLevel; // 0.0 (calm) to 1.0 (very energetic)
  final bool isTrained; // the "Training: Yes" chip
  final String instagram; // e.g. "@LokiThePup", empty if none
  final bool isVerified;

  const DogProfile({
    required this.id,
    this.name = '',
    this.about = '',
    this.birthDate,
    this.breed = '',
    this.gender,
    this.size,
    this.photos = const [],
    this.temperaments = const {},
    this.interests = const {},
    this.energyLevel = 0.5,
    this.isTrained = false,
    this.instagram = '',
    this.isVerified = false,
  });

  // ── Derived values ──────────────────────────────────────────────────────

  /// "2 Yo" / "6 Mo", worked out from the birth date.
  /// (Same calculation as SignUpData.ageAt.)
  DogAge? ageAt(DateTime now) {
    final born = birthDate;
    if (born == null || born.isAfter(now)) return null;

    var months = (now.year - born.year) * 12 + (now.month - born.month);
    if (now.day < born.day) months--;
    if (months < 0) months = 0;

    return months < 12
        ? DogAge(value: months, unit: AgeUnit.months)
        : DogAge(value: months ~/ 12, unit: AgeUnit.years);
  }

  String? get avatarUrl => photos.isEmpty ? null : photos.first;

  /// Decides the Profile button: "Complete My Profile" or "Edit".
  bool get isComplete =>
      name.trim().isNotEmpty &&
      about.trim().isNotEmpty &&
      birthDate != null &&
      breed.trim().isNotEmpty &&
      gender != null &&
      size != null &&
      photos.isNotEmpty;

  bool get canAddPhoto => photos.length < maxPhotos;

  // ── Updating ────────────────────────────────────────────────────────────

  DogProfile copyWith({
    String? id,
    String? name,
    String? about,
    DateTime? birthDate,
    String? breed,
    DogGender? gender,
    DogSize? size,
    List<String>? photos,
    Set<Temperament>? temperaments,
    Set<DogInterest>? interests,
    double? energyLevel,
    bool? isTrained,
    String? instagram,
    bool? isVerified,
  }) =>
      DogProfile(
        id: id ?? this.id,
        name: name ?? this.name,
        about: about ?? this.about,
        birthDate: birthDate ?? this.birthDate,
        breed: breed ?? this.breed,
        gender: gender ?? this.gender,
        size: size ?? this.size,
        photos: photos ?? this.photos,
        temperaments: temperaments ?? this.temperaments,
        interests: interests ?? this.interests,
        energyLevel: energyLevel ?? this.energyLevel,
        isTrained: isTrained ?? this.isTrained,
        instagram: instagram ?? this.instagram,
        isVerified: isVerified ?? this.isVerified,
      );

  // ── Serialization ───────────────────────────────────────────────────────

  factory DogProfile.fromJson(Map<String, dynamic> json) {
    final birth = json['birth_date'] as String?;
    final gender = json['gender'] as String?;
    final size = json['size'] as String?;

    final photosJson = json['photos'];
    final photosList = photosJson is List
        ? photosJson.map((e) => e.toString()).toList()
        : <String>[];
    final imageUrl = json['image_url'] as String?;
    if (photosList.isEmpty && imageUrl != null && imageUrl.isNotEmpty) {
      photosList.add(imageUrl);
    }

    return DogProfile(
      id: (json['id'] ?? '').toString(),
      name: json['name'] as String? ?? '',
      about: json['about'] as String? ?? '',
      birthDate: birth == null ? null : DateTime.tryParse(birth),
      breed: json['breed'] as String? ?? '',
      gender: gender == null
          ? null
          : DogGender.values.where((g) => g.name == gender).firstOrNull,
      size: size == null
          ? null
          : DogSize.values.where((s) => s.name == size).firstOrNull,
      photos: photosList,
      temperaments: (json['temperaments'] as List? ?? const [])
          .map((e) => Temperament.values.where((t) => t.name == e).firstOrNull)
          .whereType<Temperament>()
          .toSet(),
      interests: (json['interests'] as List? ?? const [])
          .map((e) => DogInterest.values.where((i) => i.name == e).firstOrNull)
          .whereType<DogInterest>()
          .toSet(),
      energyLevel: (json['energy_level'] as num? ?? 0.5).toDouble(),
      isTrained: json['is_trained'] as bool? ?? false,
      instagram: json['instagram'] as String? ?? '',
      isVerified: json['is_verified'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'about': about,
        'birth_date': birthDate?.toIso8601String(),
        'breed': breed,
        'gender': gender?.name,
        'size': size?.name,
        'photos': photos,
        'temperaments': temperaments.map((t) => t.name).toList(),
        'interests': interests.map((i) => i.name).toList(),
        'energy_level': energyLevel,
        'is_trained': isTrained,
        'instagram': instagram,
        'is_verified': isVerified,
      };
}

/// One card in the Profile screen's carousel ("No ads  $4,99").
class SubscriptionPlan {
  final String id;
  final String name; // "No ads", "See who liked you", "Unlimited ..."
  final double price;

  const SubscriptionPlan({
    required this.id,
    required this.name,
    required this.price,
  });

  /// "$4,99" (comma as the decimal separator, like the design).
  String get priceLabel => '\$${price.toStringAsFixed(2).replaceAll('.', ',')}';

  factory SubscriptionPlan.fromJson(Map<String, dynamic> json) =>
      SubscriptionPlan(
        id: json['id'] as String,
        name: json['name'] as String,
        price: (json['price'] as num).toDouble(),
      );

  Map<String, dynamic> toJson() => {'id': id, 'name': name, 'price': price};
}





/// Sample data for the Profile screens. Image paths are placeholders.

DateTime _yearsAgo(int years) {
  final now = DateTime.now();
  return DateTime(now.year - years, now.month, 1);
}

/// The finished profile (last screen in the design: "Edit" button).
final lokiProfile = DogProfile(
  id: 'u_loki',
  name: 'Loki',
  about: 'Bulldog by breed, but a lover at heart.',
  birthDate: _yearsAgo(2),
  breed: 'Bulldog',
  gender: DogGender.male,
  size: DogSize.small,
  photos: const [
    'https://images.unsplash.com/photo-1583511655857-d19b40a7a54e',
    'https://images.unsplash.com/photo-1517849845537-4d257902454a',
    'https://images.unsplash.com/photo-1537151608828-ea2b11777ee8',
    'https://images.unsplash.com/photo-1561037404-61cd46aa615b',
  ],
  temperaments: const {
    Temperament.friendly,
    Temperament.adaptable,
    Temperament.calm,
  },
  interests: const {
    DogInterest.goingForWalks,
    DogInterest.rollingOver,
    DogInterest.flyball,
  },
  energyLevel: 0.9,
  isTrained: true,
  instagram: '@LokiThePup',
  isVerified: true,
);

/// A profile that is not finished yet (first screen: camera icon and
/// "Complete My Profile" button).
final newLokiProfile = DogProfile(
  id: 'u_loki',
  name: 'Loki',
  breed: 'Bulldog',
  birthDate: _yearsAgo(2),
);

const plans = <SubscriptionPlan>[
  SubscriptionPlan(id: 'p1', name: 'See who liked you', price: 2.99),
  SubscriptionPlan(id: 'p2', name: 'No ads', price: 4.99),
  SubscriptionPlan(id: 'p3', name: 'Unlimited swipes', price: 6.99),
];