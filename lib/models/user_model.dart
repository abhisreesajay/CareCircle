class UserModel {
  final String uid;
  final String email;
  final String role;
  final List<String> linkedElders;
  final List<String> caregivers;
  final String? inviteCode;

  UserModel({
    required this.uid,
    required this.email,
    required this.role,
    this.linkedElders = const [],
    this.caregivers = const [],
    this.inviteCode,
  });

  factory UserModel.fromMap(
    String uid,
    Map<String, dynamic> data,
  ) {
    return UserModel(
      uid: uid,
      email: data['email']?.toString() ?? '',
      role: data['role']?.toString() ?? 'elder',

      linkedElders:
          (data['linkedElders'] as List<dynamic>?)
                  ?.map((e) => e.toString())
                  .toList() ??
              const [],

      caregivers:
          (data['caregivers'] as List<dynamic>?)
                  ?.map((e) => e.toString())
                  .toList() ??
              const [],

      inviteCode:
          data['inviteCode']?.toString(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'role': role,
      'linkedElders': linkedElders,
      'caregivers': caregivers,
      'inviteCode': inviteCode,
    };
  }
}
