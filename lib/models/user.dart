class User {
  const User({
    required this.id,
    required this.username,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.image,
    this.gender = '',
    this.phone = '',
    this.university = '',
    this.accessToken = '',
    this.refreshToken = '',
  });

  final int id;
  final String username;
  final String firstName;
  final String lastName;
  final String email;
  final String image;
  final String gender;
  final String phone;
  final String university;
  final String accessToken;
  final String refreshToken;

  String get fullName => '$firstName $lastName'.trim();

  User copyWith({String? accessToken, String? refreshToken}) {
    return User(
      id: id,
      username: username,
      firstName: firstName,
      lastName: lastName,
      email: email,
      image: image,
      gender: gender,
      phone: phone,
      university: university,
      accessToken: accessToken ?? this.accessToken,
      refreshToken: refreshToken ?? this.refreshToken,
    );
  }

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: (json['id'] as num?)?.toInt() ?? 0,
      username: json['username'] as String? ?? '',
      firstName: json['firstName'] as String? ?? '',
      lastName: json['lastName'] as String? ?? '',
      email: json['email'] as String? ?? '',
      image: json['image'] as String? ?? '',
      gender: json['gender'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      university: json['university'] as String? ?? '',
      accessToken: json['accessToken'] as String? ?? '',
      refreshToken: json['refreshToken'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'image': image,
      'gender': gender,
      'phone': phone,
      'university': university,
      'accessToken': accessToken,
      'refreshToken': refreshToken,
    };
  }
}
