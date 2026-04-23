class RoomStateResponse {
  final bool changed;
  final int version;
  final RoomInfo? room;
  final List<RoomUserDto> roomUsers;
  final List<TeamDto> teams;
  final List<RoomSetDto> sets;
  final List<TurnDto> turns;

  RoomStateResponse({
    required this.changed,
    required this.version,
    required this.room,
    required this.roomUsers,
    required this.teams,
    required this.sets,
    required this.turns,
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
      sets: (json['sets'] as List<dynamic>? ?? [])
          .whereType<Map<String, dynamic>>()
          .map(RoomSetDto.fromJson)
          .toList(),
      turns: (json['turns'] as List<dynamic>? ?? [])
          .whereType<Map<String, dynamic>>()
          .map(TurnDto.fromJson)
          .toList(),
    );
  }
}

class RoomInfo {
  final int id;
  final String code;
  final String status; // waiting/playing/finished
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
  final int id;          // room_user_id
  final int? userId;     // nullならゲスト
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

  String? iconPath() {
    if (isGuest) return guestIconPath;
    return user?.iconPath;
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
  final String? colorHex;

  TeamDto({
    required this.id,
    required this.name,
    required this.totalPoint,
    required this.imagePath,
    required this.colorHex,
  });

  factory TeamDto.fromJson(Map<String, dynamic> json) {
    return TeamDto(
      id: (json['id'] ?? 0) as int,
      name: (json['name'] ?? 'チーム') as String,
      totalPoint: (json['total_point'] ?? 0) as int,
      imagePath: json['image_path'] as String?,
      colorHex: json['color_hex'] as String?,
    );
  }
}

class RoomSetDto {
  final int id;
  final int roomId;
  final int setNo;
  final bool isConfirmed;
  final List<ScoreDto> scores;
  final List<SetResultDto> results;

  RoomSetDto({
    required this.id,
    required this.roomId,
    required this.setNo,
    required this.isConfirmed,
    required this.scores,
    required this.results,
  });

  factory RoomSetDto.fromJson(Map<String, dynamic> json) {
    return RoomSetDto(
      id: (json['id'] ?? 0) as int,
      roomId: (json['room_id'] ?? 0) as int,
      setNo: (json['set_no'] ?? 0) as int,
      isConfirmed: json['is_confirmed'] == true,
      scores: (json['scores'] as List<dynamic>? ?? [])
          .whereType<Map<String, dynamic>>()
          .map(ScoreDto.fromJson)
          .toList(),
      results: (json['results'] as List<dynamic>? ?? [])
          .whereType<Map<String, dynamic>>()
          .map(SetResultDto.fromJson)
          .toList(),
    );
  }
}

class ScoreDto {
  final int id;
  final int setId;
  final int teamId;
  final int roomUserId;
  final String? songName;
  final String scoreRaw;
  final int thirdDigit;

  ScoreDto({
    required this.id,
    required this.setId,
    required this.teamId,
    required this.roomUserId,
    required this.songName,
    required this.scoreRaw,
    required this.thirdDigit,
  });

  factory ScoreDto.fromJson(Map<String, dynamic> json) {
    return ScoreDto(
      id: (json['id'] ?? 0) as int,
      setId: (json['set_id'] ?? 0) as int,
      teamId: (json['team_id'] ?? 0) as int,
      roomUserId: (json['room_user_id'] ?? 0) as int,
      songName: json['song_name'] as String?,
      scoreRaw: (json['score_raw'] ?? '') as String,
      thirdDigit: (json['third_digit'] ?? 0) as int,
    );
  }
}

class SetResultDto {
  final int id;
  final int setId;
  final int teamId;
  final int diffValue;
  final int point;
  final bool isBestMatch;

  SetResultDto({
    required this.id,
    required this.setId,
    required this.teamId,
    required this.diffValue,
    required this.point,
    required this.isBestMatch,
  });

  factory SetResultDto.fromJson(Map<String, dynamic> json) {
    return SetResultDto(
      id: (json['id'] ?? 0) as int,
      setId: (json['set_id'] ?? 0) as int,
      teamId: (json['team_id'] ?? 0) as int,
      diffValue: (json['diff_value'] ?? 0) as int,
      point: (json['point'] ?? 0) as int,
      isBestMatch: json['is_best_match'] == true,
    );
  }
}

class TurnDto {
  final int setNo;
  final int teamId;
  final String teamName;
  final int roomUserId;
  final String displayName;
  final String? iconPath;

  TurnDto({
    required this.setNo,
    required this.teamId,
    required this.teamName,
    required this.roomUserId,
    required this.displayName,
    required this.iconPath,
  });

  factory TurnDto.fromJson(Map<String, dynamic> json) {
    return TurnDto(
      setNo: (json['set_no'] ?? 0) as int,
      teamId: (json['team_id'] ?? 0) as int,
      teamName: (json['team_name'] ?? '') as String,
      roomUserId: (json['room_user_id'] ?? 0) as int,
      displayName: (json['display_name'] ?? '') as String,
      iconPath: json['icon_path'] as String?,
    );
  }
}