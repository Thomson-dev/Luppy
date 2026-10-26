enum AgeUnit { months, years }

/// Age shown as "1 Yo" / "6 Mo" on dog cards.
class DogAge {
  final int value;
  final AgeUnit unit;

  const DogAge({required this.value, required this.unit});

  String get label => '$value ${unit == AgeUnit.years ? 'Yo' : 'Mo'}';

  factory DogAge.fromJson(Map<String, dynamic> json) => DogAge(
    value: json['value'] as int,
    unit: AgeUnit.values.byName(json['unit'] as String),
  );

  Map<String, dynamic> toJson() => {'value': value, 'unit': unit.name};
}

/// A dog profile: used in "New Matches" and "Popular Dogs".
class Dog {
  final String id;
  final String name;
  final String breed;
  final DogAge age;
  final String imageUrl;
  final bool isVerified; // blue check badge
  final bool isOnline; // green dot

  const Dog({
    required this.id,
    required this.name,
    required this.breed,
    required this.age,
    required this.imageUrl,
    this.isVerified = false,
    this.isOnline = false,
  });

  /// Subtitle on cards, e.g. "6 Mo, Akita".
  String get subtitle => '${age.label}, $breed';

  Dog copyWith({
    String? name,
    String? breed,
    DogAge? age,
    String? imageUrl,
    bool? isVerified,
    bool? isOnline,
  }) => Dog(
    id: id,
    name: name ?? this.name,
    breed: breed ?? this.breed,
    age: age ?? this.age,
    imageUrl: imageUrl ?? this.imageUrl,
    isVerified: isVerified ?? this.isVerified,
    isOnline: isOnline ?? this.isOnline,
  );

  factory Dog.fromJson(Map<String, dynamic> json) {
    final ageJson = json['age'];
    final birthDate = json['birth_date'];
    final age = ageJson is Map<String, dynamic>
        ? DogAge.fromJson(ageJson)
        : birthDate is String
        ? _ageFromBirthDate(DateTime.parse(birthDate))
        : const DogAge(value: 0, unit: AgeUnit.months);
    final photos = json['photos'];
    final imageUrl =
        json['image_url'] as String? ??
        (photos is List && photos.isNotEmpty ? photos.first as String : '');

    return Dog(
      id: json['id'] as String,
      name: json['name'] as String,
      breed: json['breed'] as String,
      age: age,
      imageUrl: imageUrl,
      isVerified: json['is_verified'] as bool? ?? false,
      isOnline: json['is_online'] as bool? ?? false,
    );
  }

  static DogAge _ageFromBirthDate(DateTime birthDate) {
    final today = DateTime.now();
    var months =
        (today.year - birthDate.year) * 12 + today.month - birthDate.month;
    if (today.day < birthDate.day) {
      months--;
    }
    months = months < 0 ? 0 : months;

    return months >= 12
        ? DogAge(value: months ~/ 12, unit: AgeUnit.years)
        : DogAge(value: months, unit: AgeUnit.months);
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'breed': breed,
    'age': age.toJson(),
    'image_url': imageUrl,
    'is_verified': isVerified,
    'is_online': isOnline,
  };
}



final popularDogs = [
  Dog(
    id: 'd_pop_1',
    name: 'Bella',
    breed: 'Golden Retriever',
    age: DogAge(value: 2, unit: AgeUnit.years),
    imageUrl: 'https://images.unsplash.com/photo-1552053831-71594a27632d',
    isVerified: true,
    isOnline: true,
  ),
  Dog(
    id: 'd_pop_2',
    name: 'Milo',
    breed: 'French Bulldog',
    age: DogAge(value: 1, unit: AgeUnit.years),
    imageUrl: 'https://images.unsplash.com/photo-1583511655857-d19b40a7a54e',
    isVerified: true,
    isOnline: false,
  ),
  Dog(
    id: 'd_pop_3',
    name: 'Charlie',
    breed: 'Beagle',
    age: DogAge(value: 8, unit: AgeUnit.months),
    imageUrl: 'https://images.unsplash.com/photo-1537151608828-ea2b11777ee8',
    isVerified: false,
    isOnline: true,
  ),
];

final matches = [
  Dog(
    id: 'd2',
    name: 'Duke',
    breed: 'Boston Terrier',
    age: DogAge(value: 3, unit: AgeUnit.years),
    imageUrl: 'https://images.unsplash.com/photo-1583511655857-d19b40a7a54e',
    isOnline: true,
  ),
  Dog(
    id: 'd1',
    name: 'Biscuit',
    breed: 'Pomeranian',
    age: DogAge(value: 2, unit: AgeUnit.years),
    imageUrl: 'https://images.unsplash.com/photo-1543466835-00a7907e9de1',
  ),
  Dog(
    id: 'd2',
    name: 'Duke',
    breed: 'Boston Terrier',
    age: DogAge(value: 3, unit: AgeUnit.years),
    imageUrl: 'https://images.unsplash.com/photo-1583511655857-d19b40a7a54e',
    isOnline: true,
  ),
  Dog(
    id: 'd1',
    name: 'Biscuit',
    breed: 'Pomeranian',
    age: DogAge(value: 2, unit: AgeUnit.years),
    imageUrl: 'https://images.unsplash.com/photo-1543466835-00a7907e9de1',
  ),
  Dog(
    id: 'd1',
    name: 'Biscuit',
    breed: 'Pomeranian',
    age: DogAge(value: 2, unit: AgeUnit.years),
    imageUrl: 'https://images.unsplash.com/photo-1543466835-00a7907e9de1',
  ),
  Dog(
    id: 'd1',
    name: 'Biscuit',
    breed: 'Pomeranian',
    age: DogAge(value: 2, unit: AgeUnit.years),
    imageUrl: 'https://images.unsplash.com/photo-1543466835-00a7907e9de1',
  ),
  Dog(
    id: 'd2',
    name: 'Duke',
    breed: 'Boston Terrier',
    age: DogAge(value: 3, unit: AgeUnit.years),
    imageUrl: 'https://images.unsplash.com/photo-1583511655857-d19b40a7a54e',
    isOnline: true,
  ),
];
