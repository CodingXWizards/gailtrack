enum UserType {
  user("USER"),
  hr("HR");

  final String value;
  const UserType(this.value);

  static UserType fromString(String value) {
    return UserType.values
        .firstWhere((e) => e.value == value, orElse: () => UserType.user);
  }
}

class User {
  int id;
  String uuidFirebase;
  String email;
  String phoneNumber;
  String displayName;
  String dept;
  UserType userType;
  String? photoUrl;

  User({
    required this.id,
    required this.uuidFirebase,
    required this.email,
    required this.phoneNumber,
    required this.displayName,
    required this.dept,
    required this.userType,
    this.photoUrl,
  });

  User.noUser()
      : id = 0,
        uuidFirebase = '',
        email = '',
        phoneNumber = '',
        displayName = 'Guest',
        photoUrl = null,
        dept = '',
        userType = UserType.user;

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      uuidFirebase: json['uuid_firebase'],
      email: json['email'],
      phoneNumber: json['phone_number'],
      displayName: json['display_name'],
      photoUrl: json['photo_url'] ?? "",
      dept: json['dept'],
      userType: UserType.fromString(json['user_type']),
    );
  }
}
