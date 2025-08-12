class SignupModel {
  String username;
  String email;
  String password;

//<editor-fold desc="Data Methods">
  SignupModel({
    required this.username,
    required this.email,
    required this.password,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SignupModel &&
          runtimeType == other.runtimeType &&
          username == other.username &&
          email == other.email &&
          password == other.password);

  @override
  int get hashCode => username.hashCode ^ email.hashCode ^ password.hashCode;

  @override
  String toString() {
    return 'SignupModel{' +
        ' username: $username,' +
        ' email: $email,' +
        ' password: $password,' +
        '}';
  }

  SignupModel copyWith({
    String? username,
    String? email,
    String? password,
  }) {
    return SignupModel(
      username: username ?? this.username,
      email: email ?? this.email,
      password: password ?? this.password,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'username': this.username,
      'email': this.email,
      'password': this.password,
    };
  }

  factory SignupModel.fromMap(Map<String, dynamic> map) {
    return SignupModel(
      username: map['username'] as String,
      email: map['email'] as String,
      password: map['password'] as String,
    );
  }

//</editor-fold>
}