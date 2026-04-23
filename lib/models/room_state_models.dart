class RoomStateResponse {
  final bool changed;
  final int version;
  final RoomInfo? room;
  final List<RoomUserDto> roomUsers;
  final List<TeamDto> teams;

  RoomStateResponse({
    required this.changed,
    required this.version,
    required this.room,
    required this.roomUsers,
    required this.teams,
  });

  factory RoomStateResponse.fromJson(Map<String, dynamic> json) {
    final roomJson = json['room'];
    return RoomStateResponse(
      changed: json['changed'] == true,
      version: (json['version'] ?? 0) as int,
      room: roomJson is Map<String, dynamic> ? RoomInfo.fromJson(roomJson) : null,
      roomUsers: (json['room_users'] as List<dynamic>? ?? [])
          .whereType<Map<String, dynamic>>()
          .map(RoomUserDto.fromJson)
          .toList(),
      teams: (json['teams'] as List<dynamic>? ?? [])
          .whereType<Map<String, dynamic>>()
          .map(TeamDto.fromJson)
          .toList(),
    );
  }
}

class RoomInfo {
  final int id;
  final String code;
  final String status;
  final int currentSetNo;
  final int adminUserId;

  RoomInfo({
    required this.id,
    required this.code,
    required this.status,
    required this.currentSetNo,
    required this.adminUserId,
  });

  factory RoomInfo.fromJson(Map<String, dynamic> json) {
    return RoomInfo(
      id: (json['id'] ?? 0) as int,
      code: (json['code'] ?? '') as String,
      status: (json['status'] ?? 'waiting') as String,
      currentSetNo: (json['current_set_no'] ?? 1) as int,
      adminUserId: (json['admin_user_id'] ?? 0) as int,
    );
  }
}

class RoomUserDto {
  final int id;
  final int? userId;
  final bool isGuest;
  final String? guestName;
  final String? guestIconPath;
  final UserDto? user;

  RoomUserDto({
    required this.id,
    required this.userId,
    required this.isGuest,
    required this.guestName,
    required this.guestIconPath,
    required this.user,
  });

  factory RoomUserDto.fromJson(Map<String, dynamic> json) {
    final userJson = json['user'];
    return RoomUserDto(
      id: (json['id'] ?? 0) as int,
      userId: json['user_id'] as int?,
      isGuest: json['is_guest'] == true,
      guestName: json['guest_name'] as String?,
      guestIconPath: json['guest_icon_path'] as String?,
      user: userJson is Map<String, dynamic> ? UserDto.fromJson(userJson) : null,
    );
  }

  String displayName() {
    if (isGuest) return guestName ?? 'ゲスト';
    return user?.name ?? 'NoName';
  }
}

class UserDto {
  final int id;
  final String name;
  final String? iconPath;

  UserDto({
    required this.id,
    required this.name,
    required this.iconPath,
  });

  factory UserDto.fromJson(Map<String, dynamic> json) {
    return UserDto(
      id: (json['id'] ?? 0) as int,
      name: (json['name'] ?? '') as String,
      iconPath: json['icon_path'] as String?,
    );
  }
}

class TeamDto {
  final int id;
  final String name;
  final int totalPoint;
  final String? imagePath;

  TeamDto({
    required this.id,
    required this.name,
    required this.totalPoint,
    required this.imagePath,
  });

  factory TeamDto.fromJson(Map<String, dynamic> json) {
    return TeamDto(
      id: (json['id'] ?? 0) as int,
      name: (json['name'] ?? 'チーム') as String,
      totalPoint: (json['total_point'] ?? 0) as int,
      imagePath: json['image_path'] as String?,
    );
  }
}