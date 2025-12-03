import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_selector/file_selector.dart';
import '../../shared/providers/statistics_provider.dart';
import '../../shared/providers/user_profile_provider.dart';
import '../../core/database/learning_statistics_repository.dart';
import '../settings/settings_screen.dart';
import '../../core/theme/openai_theme.dart';
import 'package:intl/intl.dart';
import 'favorites_screen.dart';
import 'achievements_screen.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statisticsAsync = ref.watch(statisticsProvider);
    final vocabularyStatsAsync = ref.watch(vocabularyStatsProvider);

    return Scaffold(
      backgroundColor: OpenAITheme.bgPrimary,
      appBar: AppBar(
        backgroundColor: OpenAITheme.bgPrimary,
        title: const Text('我的'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const SettingsScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        color: OpenAITheme.openaiGreen,
        onRefresh: () async {
          ref.invalidate(statisticsProvider);
          ref.invalidate(vocabularyStatsProvider);
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 用户信息卡片
              statisticsAsync.when(
                data: (stats) => _UserCard(
                  streak: stats.studyStreak,
                  totalDays: stats.totalStudyDays,
                  onEditProfile: () => _showEditProfileSheet(context, ref),
                ),
                loading: () => _UserCard(streak: 0, totalDays: 0, onEditProfile: () {}),
                error: (_, __) => _UserCard(streak: 0, totalDays: 0, onEditProfile: () {}),
              ),

              const SizedBox(height: 24),

              // 学习统计
              const Text(
                '学习统计',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: OpenAITheme.textPrimary,
                ),
              ),
              const SizedBox(height: 12),

              statisticsAsync.when(
                data: (stats) => Row(
                  children: [
                    Expanded(
                      child: _StatCard(
                        icon: Icons.local_fire_department,
                        iconColor: OpenAITheme.warning,
                        label: '学习天数',
                        value: '${stats.totalStudyDays}',
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _StatCard(
                        icon: Icons.translate,
                        iconColor: OpenAITheme.openaiGreen,
                        label: '学习单词',
                        value: '${stats.totalWordsLearned}',
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _StatCard(
                        icon: Icons.school_outlined,
                        iconColor: OpenAITheme.info,
                        label: '语法点',
                        value: '${stats.totalGrammarStudied}',
                      ),
                    ),
                  ],
                ),
                loading: () => _buildLoadingStats(),
                error: (_, __) => _buildLoadingStats(),
              ),

              const SizedBox(height: 24),

              // 最近7天学习趋势
              const Text(
                '最近7天',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: OpenAITheme.textPrimary,
                ),
              ),
              const SizedBox(height: 12),

              statisticsAsync.when(
                data: (stats) => Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: OpenAITheme.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: OpenAITheme.borderLight),
                  ),
                  child: SizedBox(
                    height: 180,
                    child: _LearningChart(recentStats: stats.recentStats),
                  ),
                ),
                loading: () => Container(
                  height: 180,
                  decoration: BoxDecoration(
                    color: OpenAITheme.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: OpenAITheme.borderLight),
                  ),
                  child: const Center(
                    child: CircularProgressIndicator(color: OpenAITheme.openaiGreen),
                  ),
                ),
                error: (_, __) => const SizedBox(),
              ),

              const SizedBox(height: 24),

              // 词汇掌握
              vocabularyStatsAsync.when(
                data: (vocabStats) => _VocabularyCard(stats: vocabStats),
                loading: () => const SizedBox(),
                error: (_, __) => const SizedBox(),
              ),

              const SizedBox(height: 24),

              // 功能入口
              const Text(
                '更多功能',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: OpenAITheme.textPrimary,
                ),
              ),
              const SizedBox(height: 12),

              _MenuCard(
                items: [
                  _MenuItem(
                    icon: Icons.star_outline,
                    iconColor: OpenAITheme.warning,
                    title: '我的收藏',
                    subtitle: '查看收藏的单词和语法',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const FavoritesScreen(),
                        ),
                      );
                    },
                  ),
                  _MenuItem(
                    icon: Icons.emoji_events_outlined,
                    iconColor: OpenAITheme.openaiGreen,
                    title: '学习成就',
                    subtitle: '查看已获得的成就徽章',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const AchievementsScreen(),
                        ),
                      );
                    },
                  ),
                  _MenuItem(
                    icon: Icons.info_outline,
                    iconColor: OpenAITheme.info,
                    title: '关于应用',
                    subtitle: '版本信息和使用说明',
                    onTap: () => _showAboutSheet(context),
                  ),
                ],
              ),

              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingStats() {
    return Row(
      children: [
        Expanded(child: _StatCard(icon: Icons.local_fire_department, iconColor: OpenAITheme.warning, label: '学习天数', value: '-')),
        const SizedBox(width: 12),
        Expanded(child: _StatCard(icon: Icons.translate, iconColor: OpenAITheme.openaiGreen, label: '学习单词', value: '-')),
        const SizedBox(width: 12),
        Expanded(child: _StatCard(icon: Icons.school_outlined, iconColor: OpenAITheme.info, label: '语法点', value: '-')),
      ],
    );
  }

  void _showEditProfileSheet(BuildContext context, WidgetRef ref) {
    final profile = ref.read(userProfileProvider);
    final nicknameController = TextEditingController(text: profile.nickname);

    showModalBottomSheet(
      context: context,
      backgroundColor: OpenAITheme.white,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 标题
                Row(
                  children: [
                    const Text(
                      '编辑资料',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: OpenAITheme.textPrimary,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // 头像编辑
                Center(
                  child: Consumer(
                    builder: (context, ref, _) {
                      final currentProfile = ref.watch(userProfileProvider);
                      return GestureDetector(
                        onTap: () => _pickAvatar(context, ref),
                        child: Stack(
                          children: [
                            Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                color: OpenAITheme.openaiGreen.withValues(alpha: 0.1),
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: OpenAITheme.borderLight,
                                  width: 2,
                                ),
                              ),
                              child: currentProfile.avatarPath != null
                                  ? ClipOval(
                                      child: Image.file(
                                        File(currentProfile.avatarPath!),
                                        fit: BoxFit.cover,
                                        width: 80,
                                        height: 80,
                                      ),
                                    )
                                  : const Icon(
                                      Icons.person,
                                      size: 40,
                                      color: OpenAITheme.openaiGreen,
                                    ),
                            ),
                            Positioned(
                              right: 0,
                              bottom: 0,
                              child: Container(
                                width: 28,
                                height: 28,
                                decoration: BoxDecoration(
                                  color: OpenAITheme.openaiGreen,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: OpenAITheme.white,
                                    width: 2,
                                  ),
                                ),
                                child: const Icon(
                                  Icons.camera_alt,
                                  size: 14,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 8),
                const Center(
                  child: Text(
                    '点击更换头像',
                    style: TextStyle(
                      fontSize: 12,
                      color: OpenAITheme.textTertiary,
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // 昵称输入
                const Text(
                  '昵称',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: OpenAITheme.textSecondary,
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: nicknameController,
                  decoration: InputDecoration(
                    hintText: '请输入昵称',
                    hintStyle: const TextStyle(color: OpenAITheme.textTertiary),
                    filled: true,
                    fillColor: OpenAITheme.bgSecondary,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: OpenAITheme.openaiGreen),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  ),
                ),
                const SizedBox(height: 24),

                // 保存按钮
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      final nickname = nicknameController.text.trim();
                      if (nickname.isNotEmpty) {
                        await ref.read(userProfileProvider.notifier).setNickname(nickname);
                      }
                      if (context.mounted) {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('资料已更新'),
                            backgroundColor: OpenAITheme.openaiGreen,
                          ),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: OpenAITheme.charcoal,
                      foregroundColor: OpenAITheme.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      '保存',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _pickAvatar(BuildContext context, WidgetRef ref) async {
    // 检查是否是桌面平台
    final isDesktop = !kIsWeb && (Platform.isMacOS || Platform.isWindows || Platform.isLinux);

    if (isDesktop) {
      // 桌面平台使用 file_selector
      await _pickAvatarDesktop(context, ref);
    } else {
      // 移动平台使用 image_picker
      await _pickAvatarMobile(context, ref);
    }
  }

  Future<void> _pickAvatarDesktop(BuildContext context, WidgetRef ref) async {
    final hasAvatar = ref.read(userProfileProvider).avatarPath != null;

    showModalBottomSheet(
      context: context,
      backgroundColor: OpenAITheme.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: const Text('选择图片'),
              onTap: () async {
                Navigator.pop(context);
                const typeGroup = XTypeGroup(
                  label: 'images',
                  extensions: ['jpg', 'jpeg', 'png', 'gif', 'webp'],
                );
                final file = await openFile(acceptedTypeGroups: [typeGroup]);
                if (file != null) {
                  await ref.read(userProfileProvider.notifier).setAvatar(file.path);
                }
              },
            ),
            if (hasAvatar)
              ListTile(
                leading: const Icon(Icons.delete_outline, color: Colors.red),
                title: const Text('删除头像', style: TextStyle(color: Colors.red)),
                onTap: () async {
                  Navigator.pop(context);
                  await ref.read(userProfileProvider.notifier).clearAvatar();
                },
              ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Future<void> _pickAvatarMobile(BuildContext context, WidgetRef ref) async {
    final picker = ImagePicker();
    final hasAvatar = ref.read(userProfileProvider).avatarPath != null;

    showModalBottomSheet(
      context: context,
      backgroundColor: OpenAITheme.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: const Text('从相册选择'),
              onTap: () async {
                Navigator.pop(context);
                final image = await picker.pickImage(
                  source: ImageSource.gallery,
                  maxWidth: 512,
                  maxHeight: 512,
                  imageQuality: 80,
                );
                if (image != null) {
                  await ref.read(userProfileProvider.notifier).setAvatar(image.path);
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt_outlined),
              title: const Text('拍照'),
              onTap: () async {
                Navigator.pop(context);
                final image = await picker.pickImage(
                  source: ImageSource.camera,
                  maxWidth: 512,
                  maxHeight: 512,
                  imageQuality: 80,
                );
                if (image != null) {
                  await ref.read(userProfileProvider.notifier).setAvatar(image.path);
                }
              },
            ),
            if (hasAvatar)
              ListTile(
                leading: const Icon(Icons.delete_outline, color: Colors.red),
                title: const Text('删除头像', style: TextStyle(color: Colors.red)),
                onTap: () async {
                  Navigator.pop(context);
                  await ref.read(userProfileProvider.notifier).clearAvatar();
                },
              ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  void _showAboutSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: OpenAITheme.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // App 图标
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: OpenAITheme.openaiGreen.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.school,
                  size: 40,
                  color: OpenAITheme.openaiGreen,
                ),
              ),
              const SizedBox(height: 16),

              const Text(
                '意大利语学习',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: OpenAITheme.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                '版本 1.0.3',
                style: TextStyle(
                  fontSize: 14,
                  color: OpenAITheme.textTertiary,
                ),
              ),
              const SizedBox(height: 20),

              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: OpenAITheme.bgSecondary,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    _AboutItem(
                      icon: Icons.auto_awesome,
                      title: '科学记忆',
                      description: '基于间隔重复算法，高效记忆单词',
                    ),
                    const SizedBox(height: 12),
                    _AboutItem(
                      icon: Icons.record_voice_over,
                      title: '离线发音',
                      description: '内置 Piper TTS，支持离线语音',
                    ),
                    const SizedBox(height: 12),
                    _AboutItem(
                      icon: Icons.chat_bubble_outline,
                      title: 'AI 对话',
                      description: '与 AI 进行意大利语对话练习',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: OpenAITheme.openaiGreen,
                    foregroundColor: OpenAITheme.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    '知道了',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// 用户卡片
class _UserCard extends ConsumerWidget {
  final int streak;
  final int totalDays;
  final VoidCallback onEditProfile;

  const _UserCard({
    required this.streak,
    required this.totalDays,
    required this.onEditProfile,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(userProfileProvider);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: OpenAITheme.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: OpenAITheme.borderLight),
      ),
      child: Row(
        children: [
          // 头像
          GestureDetector(
            onTap: onEditProfile,
            child: Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: OpenAITheme.openaiGreen.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: OpenAITheme.borderLight),
              ),
              child: profile.avatarPath != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(14),
                      child: Image.file(
                        File(profile.avatarPath!),
                        fit: BoxFit.cover,
                        width: 64,
                        height: 64,
                      ),
                    )
                  : const Icon(
                      Icons.person,
                      size: 36,
                      color: OpenAITheme.openaiGreen,
                    ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  profile.nickname,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: OpenAITheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(
                      Icons.local_fire_department,
                      size: 18,
                      color: OpenAITheme.warning,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      streak > 0 ? '连续学习 $streak 天' : '今天开始学习吧！',
                      style: const TextStyle(
                        fontSize: 14,
                        color: OpenAITheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // 编辑按钮
          IconButton(
            onPressed: onEditProfile,
            icon: const Icon(
              Icons.edit_outlined,
              size: 20,
              color: OpenAITheme.textTertiary,
            ),
          ),
        ],
      ),
    );
  }
}

// 统计卡片
class _StatCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;

  const _StatCard({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: OpenAITheme.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: OpenAITheme.borderLight),
      ),
      child: Column(
        children: [
          Icon(icon, size: 24, color: iconColor),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w600,
              color: OpenAITheme.textPrimary,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: OpenAITheme.textTertiary,
            ),
          ),
        ],
      ),
    );
  }
}

// 词汇统计卡片
class _VocabularyCard extends StatelessWidget {
  final Map<String, dynamic> stats;

  const _VocabularyCard({required this.stats});

  @override
  Widget build(BuildContext context) {
    final mastery = (stats['averageMastery'] as double?) ?? 0.0;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: OpenAITheme.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: OpenAITheme.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '词汇掌握',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: OpenAITheme.textPrimary,
            ),
          ),
          const SizedBox(height: 16),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _VocabItem(
                label: '已学习',
                value: stats['totalWords'] ?? 0,
                color: OpenAITheme.info,
              ),
              _VocabItem(
                label: '已掌握',
                value: stats['masteredWords'] ?? 0,
                color: OpenAITheme.openaiGreen,
              ),
              _VocabItem(
                label: '复习中',
                value: stats['reviewingWords'] ?? 0,
                color: OpenAITheme.warning,
              ),
            ],
          ),
          const SizedBox(height: 20),

          Row(
            children: [
              const Icon(
                Icons.trending_up,
                size: 18,
                color: OpenAITheme.openaiGreen,
              ),
              const SizedBox(width: 8),
              const Text(
                '平均掌握度',
                style: TextStyle(
                  fontSize: 14,
                  color: OpenAITheme.textSecondary,
                ),
              ),
              const Spacer(),
              Text(
                '${(mastery * 100).toStringAsFixed(0)}%',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: OpenAITheme.openaiGreen,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          Container(
            height: 8,
            decoration: BoxDecoration(
              color: OpenAITheme.gray100,
              borderRadius: BorderRadius.circular(4),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: mastery.clamp(0.0, 1.0),
              child: Container(
                decoration: BoxDecoration(
                  color: OpenAITheme.openaiGreen,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _VocabItem extends StatelessWidget {
  final String label;
  final int value;
  final Color color;

  const _VocabItem({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          '$value',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: OpenAITheme.textTertiary,
          ),
        ),
      ],
    );
  }
}

// 菜单卡片
class _MenuCard extends StatelessWidget {
  final List<_MenuItem> items;

  const _MenuCard({required this.items});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: OpenAITheme.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: OpenAITheme.borderLight),
      ),
      child: Column(
        children: items.asMap().entries.map((entry) {
          final index = entry.key;
          final item = entry.value;
          final isLast = index == items.length - 1;

          return Column(
            children: [
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: item.onTap,
                  borderRadius: BorderRadius.vertical(
                    top: index == 0 ? const Radius.circular(12) : Radius.zero,
                    bottom: isLast ? const Radius.circular(12) : Radius.zero,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: item.iconColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            item.icon,
                            size: 22,
                            color: item.iconColor,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.title,
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w500,
                                  color: OpenAITheme.textPrimary,
                                ),
                              ),
                              if (item.subtitle != null)
                                Text(
                                  item.subtitle!,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: OpenAITheme.textTertiary,
                                  ),
                                ),
                            ],
                          ),
                        ),
                        const Icon(
                          Icons.arrow_forward_ios,
                          size: 16,
                          color: OpenAITheme.textTertiary,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              if (!isLast)
                const Divider(
                  height: 1,
                  indent: 70,
                  color: OpenAITheme.borderLight,
                ),
            ],
          );
        }).toList(),
      ),
    );
  }
}

class _MenuItem {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String? subtitle;
  final VoidCallback onTap;

  _MenuItem({
    required this.icon,
    required this.iconColor,
    required this.title,
    this.subtitle,
    required this.onTap,
  });
}

// 关于项
class _AboutItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;

  const _AboutItem({
    required this.icon,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 20, color: OpenAITheme.openaiGreen),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: OpenAITheme.textPrimary,
                ),
              ),
              Text(
                description,
                style: const TextStyle(
                  fontSize: 12,
                  color: OpenAITheme.textTertiary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// 学习趋势图表
class _LearningChart extends StatelessWidget {
  final List<DailyStatistics> recentStats;

  const _LearningChart({required this.recentStats});

  @override
  Widget build(BuildContext context) {
    if (recentStats.isEmpty) {
      return const Center(
        child: Text(
          '暂无学习数据',
          style: TextStyle(color: OpenAITheme.textTertiary),
        ),
      );
    }

    final spots = <FlSpot>[];
    final dates = <String>[];

    for (int i = 0; i < recentStats.length; i++) {
      final stat = recentStats[i];
      final totalActivity = stat.wordsLearned + stat.wordsReviewed +
          stat.grammarPointsStudied + stat.conversationMessages;
      spots.add(FlSpot(i.toDouble(), totalActivity.toDouble()));
      dates.add(DateFormat('MM/dd').format(stat.date));
    }

    final maxY = spots.isEmpty ? 10.0 : spots.map((s) => s.y).reduce((a, b) => a > b ? a : b);
    final yInterval = maxY > 0 ? (maxY / 4).ceilToDouble() : 5.0;

    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: yInterval.toDouble(),
          getDrawingHorizontalLine: (value) {
            return FlLine(
              color: OpenAITheme.borderLight,
              strokeWidth: 1,
            );
          },
        ),
        titlesData: FlTitlesData(
          show: true,
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 28,
              interval: 1,
              getTitlesWidget: (value, meta) {
                final index = value.toInt();
                if (index >= 0 && index < dates.length) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      dates[index],
                      style: const TextStyle(
                        color: OpenAITheme.textTertiary,
                        fontSize: 10,
                      ),
                    ),
                  );
                }
                return const Text('');
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: yInterval.toDouble(),
              reservedSize: 28,
              getTitlesWidget: (value, meta) {
                return Text(
                  value.toInt().toString(),
                  style: const TextStyle(
                    color: OpenAITheme.textTertiary,
                    fontSize: 10,
                  ),
                );
              },
            ),
          ),
        ),
        borderData: FlBorderData(show: false),
        minX: 0,
        maxX: (recentStats.length - 1).toDouble(),
        minY: 0,
        maxY: maxY + yInterval,
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            color: OpenAITheme.openaiGreen,
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, percent, barData, index) {
                return FlDotCirclePainter(
                  radius: 4,
                  color: OpenAITheme.openaiGreen,
                  strokeWidth: 2,
                  strokeColor: OpenAITheme.white,
                );
              },
            ),
            belowBarData: BarAreaData(
              show: true,
              color: OpenAITheme.openaiGreen.withValues(alpha: 0.1),
            ),
          ),
        ],
      ),
    );
  }
}
