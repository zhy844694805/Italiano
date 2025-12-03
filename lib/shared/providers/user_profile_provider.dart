import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider/path_provider.dart';

// 用户配置数据
class UserProfile {
  final String nickname;
  final String? avatarPath;

  const UserProfile({
    this.nickname = '意大利语学习者',
    this.avatarPath,
  });

  UserProfile copyWith({
    String? nickname,
    String? avatarPath,
    bool clearAvatar = false,
  }) {
    return UserProfile(
      nickname: nickname ?? this.nickname,
      avatarPath: clearAvatar ? null : (avatarPath ?? this.avatarPath),
    );
  }
}

// 用户配置状态管理
class UserProfileNotifier extends StateNotifier<UserProfile> {
  UserProfileNotifier() : super(const UserProfile()) {
    _loadProfile();
  }

  static const String _nicknameKey = 'user_nickname';
  static const String _avatarKey = 'user_avatar_path';

  Future<void> _loadProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final nickname = prefs.getString(_nicknameKey) ?? '意大利语学习者';
    final avatarPath = prefs.getString(_avatarKey);

    state = UserProfile(
      nickname: nickname,
      avatarPath: avatarPath,
    );
  }

  Future<void> setNickname(String nickname) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_nicknameKey, nickname);
    state = state.copyWith(nickname: nickname);
  }

  Future<void> setAvatar(String sourcePath) async {
    // 复制图片到应用目录
    final appDir = await getApplicationDocumentsDirectory();
    final avatarDir = Directory('${appDir.path}/avatar');
    if (!avatarDir.existsSync()) {
      avatarDir.createSync(recursive: true);
    }

    // 删除旧头像
    if (state.avatarPath != null) {
      final oldFile = File(state.avatarPath!);
      if (oldFile.existsSync()) {
        oldFile.deleteSync();
      }
    }

    // 复制新头像
    final sourceFile = File(sourcePath);
    final extension = sourcePath.split('.').last;
    final newPath = '${avatarDir.path}/avatar_${DateTime.now().millisecondsSinceEpoch}.$extension';
    await sourceFile.copy(newPath);

    // 保存路径
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_avatarKey, newPath);
    state = state.copyWith(avatarPath: newPath);
  }

  Future<void> clearAvatar() async {
    // 删除头像文件
    if (state.avatarPath != null) {
      final file = File(state.avatarPath!);
      if (file.existsSync()) {
        file.deleteSync();
      }
    }

    // 清除保存的路径
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_avatarKey);
    state = state.copyWith(clearAvatar: true);
  }
}

// Provider
final userProfileProvider = StateNotifierProvider<UserProfileNotifier, UserProfile>((ref) {
  return UserProfileNotifier();
});
