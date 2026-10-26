/// Data models for the Luppy login screen.

/// The three social login buttons under "OR".
enum SocialProvider {
  facebook('Facebook'),
  apple('Apple'),
  google('Google');

  final String label;
  const SocialProvider(this.label);
}

/// What the user types on the login screen.
class LoginData {
  final String email;
  final String password;

  const LoginData({this.email = '', this.password = ''});

  static final _emailPattern = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

  bool get isEmailValid => _emailPattern.hasMatch(email.trim());

  /// Login only needs a non-empty password. Length rules belong to sign-up.
  bool get isPasswordValid => password.isNotEmpty;

  /// Enables the "Log In" button.
  bool get canSubmit => isEmailValid && isPasswordValid;

  LoginData copyWith({String? email, String? password}) => LoginData(
        email: email ?? this.email,
        password: password ?? this.password,
      );

  /// Body for the login request. Includes the password, so send it over
  /// HTTPS only and never log or print it.
  Map<String, dynamic> toJson() => {
        'email': email.trim(),
        'password': password,
      };

  factory LoginData.fromJson(Map<String, dynamic> json) => LoginData(
        email: json['email'] as String? ?? '',
        password: json['password'] as String? ?? '',
      );

  /// Hides the password so `print(loginData)` is safe.
  @override
  String toString() =>
      'LoginData(email: $email, password: ${'*' * password.length})';
}

/// Result of a login attempt (email/password or social).
class AuthSession {
  final String userId;
  final String accessToken;
  final String? refreshToken;
  final DateTime? expiresAt;

  const AuthSession({
    required this.userId,
    required this.accessToken,
    this.refreshToken,
    this.expiresAt,
  });

  bool get isExpired =>
      expiresAt != null && DateTime.now().isAfter(expiresAt!);

  factory AuthSession.fromJson(Map<String, dynamic> json) {
    final expires = json['expires_at'] as String?;
    return AuthSession(
      userId: json['user_id'] as String,
      accessToken: json['access_token'] as String,
      refreshToken: json['refresh_token'] as String?,
      expiresAt: expires == null ? null : DateTime.parse(expires),
    );
  }

  Map<String, dynamic> toJson() => {
        'user_id': userId,
        'access_token': accessToken,
        'refresh_token': refreshToken,
        'expires_at': expiresAt?.toIso8601String(),
      };
}