import 'package:hive/hive.dart';

part 'user_session.g.dart';

@HiveType(typeId: 0)
enum UserRole {
  @HiveField(0)
  admin,
  @HiveField(1)
  standardUser,
}

@HiveType(typeId: 1)
class UserSession extends HiveObject {
  @HiveField(0)
  final String displayName;
  
  @HiveField(1)
  final String normalizedName;
  
  @HiveField(2)
  final UserRole role;
  
  @HiveField(3)
  final String? defaultLocation;
  
  @HiveField(4)
  final String? defaultSiteName;
  
  @HiveField(5)
  final String? defaultJobNumber;
  
  @HiveField(6)
  final String? defaultTruckNumber;
  
  @HiveField(7)
  final DateTime startedAt;

  UserSession({
    required this.displayName,
    required this.normalizedName,
    required this.role,
    this.defaultLocation,
    this.defaultSiteName,
    this.defaultJobNumber,
    this.defaultTruckNumber,
    required this.startedAt,
  });

  factory UserSession.create({
    required String displayName,
    String? defaultLocation,
    String? defaultSiteName,
    String? defaultJobNumber,
    String? defaultTruckNumber,
  }) {
    final normalized = displayName.trim().toLowerCase();
    final role = (normalized == 'bryan' || normalized == 'jared') ? UserRole.admin : UserRole.standardUser;
    
    return UserSession(
      displayName: displayName.trim(),
      normalizedName: normalized,
      role: role,
      defaultLocation: defaultLocation,
      defaultSiteName: defaultSiteName,
      defaultJobNumber: defaultJobNumber,
      defaultTruckNumber: defaultTruckNumber,
      startedAt: DateTime.now(),
    );
  }

  bool get isAdmin => role == UserRole.admin;
}
