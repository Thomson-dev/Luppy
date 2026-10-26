import 'package:luppy/home/model/Dog.dart';

/// Data models for the 3-step Luppy sign-up flow.
///   Step 1: email
///   Step 2: dog's name, age (picked as a birth date), breed, gender, size
///   Step 3: temperament and interests (multi-select chips)

enum SignUpStep { account, dogInfo, personality }

enum DogGender {
  male('Male'),
  female('Female');

  final String label;
  const DogGender(this.label);
}

enum DogSize {
  small('S'),
  medium('M'),
  large('L');

  final String label;
  const DogSize(this.label);
}

enum Temperament {
  playful('Playful'),
  friendly('Friendly'),
  energetic('Energetic'),
  adaptable('Adaptable'),
  calm('Calm'),
  intelligent('Intelligent'),
  protective('Protective'),
  sensitive('Sensitive'),
  loyal('Loyal'),
  spirited('Spirited'),
  trainable('Trainable'),
  watchful('Watchful');

  final String label;
  const Temperament(this.label);
}

enum DogInterest {
  playingFetch('Playing fetch'),
  goingForWalks('Going for walks'),
  swimming('Swimming'),
  digging('Digging'),
  fetchingBalls('Fetching balls'),
  goingToThePark('Going to the park'),
  givingPaw('Giving paw'),
  rollingOver('Rolling over'),
  goingForHikes('Going for hikes'),
  playingDead('Playing dead'),
  beggingForTreats('Begging for treats'),
  flyball('Flyball');

  final String label;
  const DogInterest(this.label);
}

/// Everything collected across the sign-up steps.
class SignUpData {
  final String email;
  final String password;
  final String dogName;
  final DateTime? dogBirthDate;
  final String breed;
  final DogGender? gender;
  final DogSize? size;
  final Set<Temperament> temperaments;
  final Set<DogInterest> interests;

  const SignUpData({
    this.email = '',
    this.password = '',
    this.dogName = '',
    this.dogBirthDate,
    this.breed = '',
    this.gender,
    this.size,
    this.temperaments = const {},
    this.interests = const {},
  });

  // ── Derived values ──────────────────────────────────────────────────────

  /// Age shown in the "Select Age" field, derived from the picked date.
  DogAge? ageAt(DateTime now) {
    final born = dogBirthDate;
    if (born == null || born.isAfter(now)) return null;

    var months = (now.year - born.year) * 12 + (now.month - born.month);
    if (now.day < born.day) months--;
    if (months < 0) months = 0;

    return months < 12
        ? DogAge(value: months, unit: AgeUnit.months)
        : DogAge(value: months ~/ 12, unit: AgeUnit.years);
  }

  // ── Per-step validation (enables the Continue button) ───────────────────

  static final _emailPattern = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

  bool get isEmailValid => _emailPattern.hasMatch(email.trim());
  bool get isPasswordValid => password.length >= 8;

  bool get isDogInfoValid =>
      dogName.trim().isNotEmpty &&
      dogBirthDate != null &&
      breed.trim().isNotEmpty &&
      gender != null &&
      size != null;

  bool get isPersonalityValid =>
      temperaments.isNotEmpty && interests.isNotEmpty;

  bool isStepValid(SignUpStep step) => switch (step) {
    SignUpStep.account => isEmailValid && isPasswordValid,
    SignUpStep.dogInfo => isDogInfoValid,
    SignUpStep.personality => isPersonalityValid,
  };

  bool get isComplete => SignUpStep.values.every(isStepValid);

  // ── Updating ────────────────────────────────────────────────────────────

  /// Pass `clearBirthDate`, `clearGender` or `clearSize` to reset a field to
  /// null, since a null argument alone means "keep the current value".
  SignUpData copyWith({
    String? email,
    String? password,
    String? dogName,
    DateTime? dogBirthDate,
    bool clearBirthDate = false,
    String? breed,
    DogGender? gender,
    bool clearGender = false,
    DogSize? size,
    bool clearSize = false,
    Set<Temperament>? temperaments,
    Set<DogInterest>? interests,
  }) => SignUpData(
    email: email ?? this.email,
    password: password ?? this.password,
    dogName: dogName ?? this.dogName,
    dogBirthDate: clearBirthDate ? null : (dogBirthDate ?? this.dogBirthDate),
    breed: breed ?? this.breed,
    gender: clearGender ? null : (gender ?? this.gender),
    size: clearSize ? null : (size ?? this.size),
    temperaments: temperaments ?? this.temperaments,
    interests: interests ?? this.interests,
  );

  /// Adds the item if missing, removes it if present (chip tap).
  SignUpData toggleTemperament(Temperament t) {
    final next = {...temperaments};
    next.contains(t) ? next.remove(t) : next.add(t);
    return copyWith(temperaments: next);
  }

  SignUpData toggleInterest(DogInterest i) {
    final next = {...interests};
    next.contains(i) ? next.remove(i) : next.add(i);
    return copyWith(interests: next);
  }

  // ── Serialization ───────────────────────────────────────────────────────

  Map<String, dynamic> toJson() => {
    'email': email.trim(),
    'dog': {
      'name': dogName.trim(),
      'birth_date': dogBirthDate?.toIso8601String(),
      'breed': breed.trim(),
      'gender': gender?.name,
      'size': size?.name,
      'temperaments': temperaments.map((t) => t.name).toList(),
      'interests': interests.map((i) => i.name).toList(),
    },
  };

  factory SignUpData.fromJson(Map<String, dynamic> json) {
    final dog = json['dog'] as Map<String, dynamic>? ?? const {};
    final birth = dog['birth_date'] as String?;
    final gender = dog['gender'] as String?;
    final size = dog['size'] as String?;

    return SignUpData(
      email: json['email'] as String? ?? '',
      dogName: dog['name'] as String? ?? '',
      dogBirthDate: birth == null ? null : DateTime.parse(birth),
      breed: dog['breed'] as String? ?? '',
      gender: gender == null ? null : DogGender.values.byName(gender),
      size: size == null ? null : DogSize.values.byName(size),
      temperaments: (dog['temperaments'] as List? ?? const [])
          .map((e) => Temperament.values.byName(e as String))
          .toSet(),
      interests: (dog['interests'] as List? ?? const [])
          .map((e) => DogInterest.values.byName(e as String))
          .toSet(),
    );
  }
}
