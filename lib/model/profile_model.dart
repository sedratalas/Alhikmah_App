class ProfileModel {
  final String username;
  final String email;
  final int id;

//<editor-fold desc="Data Methods">
  const ProfileModel({
    required this.username,
    required this.email,
    required this.id,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          (other is ProfileModel &&
              runtimeType == other.runtimeType &&
              username == other.username &&
              email == other.email &&
              id == other.id);

  @override
  int get hashCode => username.hashCode ^ email.hashCode ^ id.hashCode;

  @override
  String toString() {
    return 'ProfileModel{' +
        ' username: $username,' +
        ' email: $email,' +
        ' id: $id,' +
        '}';
  }

  ProfileModel copyWith({
    String? username,
    String? email,
    int? id,
  }) {
    return ProfileModel(
      username: username ?? this.username,
      email: email ?? this.email,
      id: id ?? this.id,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'username': this.username,
      'email': this.email,
      'id': this.id,
    };
  }

  factory ProfileModel.fromMap(Map<String, dynamic> map) {
    return ProfileModel(
      username: map['username'] as String,
      email: map['email'] as String,
      id: map['id'] as int,
    );
  }

//</editor-fold>
}